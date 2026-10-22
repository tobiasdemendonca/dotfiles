#!/usr/bin/env bash
# Print copy-pasteable commands (bash + fish compatible) that re-clone every
# git repository found at the top level of a directory, restoring its remotes.
# The idea is that you run this on your old machine, and then execute the 
# printed commands on your new machine to recreate the repositories ready for work.


set -euo pipefail

usage() {
    cat <<'EOF'
Usage: git-clone-commands.sh [-q] [DIR]

Print commands to re-clone each git repo in DIR (default: current directory)
and re-add all of its current remotes.

  -q, --quiet  Hide unmerged branch warnings (local commits on no remote).
  -h, --help   Show this help.
EOF
}

# Single quotes are literal in bash; in fish only \' and \\ are special, so
# anything without those characters is safe to single-quote for both shells.
# Fails for values that cannot be quoted portably.
shell_quote() {
    local value="$1"
    if [[ "$value" == *\'* || "$value" == *\\* ]]; then
        return 1
    fi
    if [[ "$value" =~ ^[A-Za-z0-9@%+=:,./_-]+$ ]]; then
        printf '%s' "$value"
    else
        printf "'%s'" "$value"
    fi
}

is_repo_root() {
    local dir="$1"
    [[ "$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" == "$dir" ]]
}

# A linked worktree's git dir differs from the common dir of its main repo.
main_repo_of_worktree() {
    local dir="$1" git_dir common_dir
    git_dir="$(git -C "$dir" rev-parse --absolute-git-dir)"
    common_dir="$(cd "$dir" && cd "$(git rev-parse --git-common-dir)" && pwd)"
    [[ "$git_dir" != "$common_dir" ]] || return 1
    dirname "$common_dir"
}

current_branch() {
    git -C "$1" branch --show-current
}

# Prefer origin; otherwise fall back to the first configured remote.
primary_remote() {
    local dir="$1"
    if git -C "$dir" remote get-url origin >/dev/null 2>&1; then
        echo origin
    else
        git -C "$dir" remote | head -n 1
    fi
}

# Local branches with commits not reachable from any remote-tracking ref,
# i.e. work that a fresh clone would not contain.
print_unmerged_branch_warning() {
    local dir="$1" branch count unit
    local unmerged=()

    while read -r branch; do
        count="$(git -C "$dir" rev-list --count "refs/heads/$branch" \
            --not --remotes)"
        if [[ "$count" -gt 0 ]]; then
            unit=commits
            [[ "$count" -eq 1 ]] && unit=commit
            unmerged+=("$branch ($count $unit)")
        fi
    done < <(git -C "$dir" for-each-ref --format='%(refname:short)' refs/heads)

    if [[ ${#unmerged[@]} -gt 0 ]]; then
        echo "# WARNING: branches with commits not on any remote:"
        printf '#   %s\n' "${unmerged[@]}"
    fi
}

# Builds every command before printing any, so a value that cannot be quoted
# skips the whole repo rather than leaving a half-written set of commands.
print_clone_commands() {
    local dir="$1" name="$2" primary="$3"
    local commands=() remotes=()
    local q_name q_remote q_url clone_opts="" remote fetch_url push_url

    q_name="$(shell_quote "$name")" || return 1
    mapfile -t remotes < <(git -C "$dir" remote)

    if [[ -f "$dir/.gitmodules" ]]; then
        clone_opts+=" --recurse-submodules"
    fi
    if [[ "$primary" != origin ]]; then
        q_remote="$(shell_quote "$primary")" || return 1
        clone_opts+=" --origin $q_remote"
    fi

    q_url="$(shell_quote "$(git -C "$dir" remote get-url "$primary")")" \
        || return 1
    commands+=("git clone$clone_opts $q_url $q_name")

    for remote in "${remotes[@]}"; do
        fetch_url="$(git -C "$dir" remote get-url "$remote")"
        push_url="$(git -C "$dir" remote get-url --push "$remote")"
        q_remote="$(shell_quote "$remote")" || return 1

        if [[ "$remote" != "$primary" ]]; then
            q_url="$(shell_quote "$fetch_url")" || return 1
            commands+=("git -C $q_name remote add $q_remote $q_url")
        fi
        if [[ "$push_url" != "$fetch_url" ]]; then
            q_url="$(shell_quote "$push_url")" || return 1
            commands+=("git -C $q_name remote set-url --push $q_remote $q_url")
        fi
    done

    if [[ ${#remotes[@]} -gt 1 ]]; then
        commands+=("git -C $q_name fetch --all")
    fi

    printf '%s\n' "${commands[@]}"
}

print_repo() {
    local dir="$1" quiet="$2"
    local name branch main_repo primary commands

    name="$(basename "$dir")"
    branch="$(current_branch "$dir")"

    echo
    echo "# --- $name ---"

    if main_repo="$(main_repo_of_worktree "$dir")"; then
        echo "# Worktree of $main_repo (branch: ${branch:-detached}), not cloned."
        echo "# Recreate with: git -C <main repo> worktree add <path> $branch"
        return
    fi

    primary="$(primary_remote "$dir")"
    if [[ -z "$primary" ]]; then
        echo "# No remotes configured; nothing to clone from."
        return
    fi

    if ! commands="$(print_clone_commands "$dir" "$name" "$primary")"; then
        echo "# SKIPPED: name or URL contains a quote or backslash."
        return
    fi

    if [[ "$primary" != origin ]]; then
        echo "# NOTE: no 'origin' remote; cloning from '$primary' instead."
    fi
    if [[ -n "$branch" ]]; then
        echo "# Was on branch: $branch"
    fi
    if [[ "$quiet" == false ]]; then
        print_unmerged_branch_warning "$dir"
    fi
    echo "$commands"
}

main() {
    local quiet=false root=. dir

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -q|--quiet) quiet=true ;;
            -h|--help) usage; exit 0 ;;
            -*) usage >&2; exit 1 ;;
            *) root="$1" ;;
        esac
        shift
    done
    if [[ ! -d "$root" ]]; then
        echo "Error: not a directory: $root" >&2
        exit 1
    fi
    root="$(cd "$root" && pwd)"

    echo "# Re-clone commands generated from $root on $(date -I)"
    echo "# Run from the directory you want the repositories cloned into."

    for dir in "$root"/*/; do
        dir="${dir%/}"
        if is_repo_root "$dir"; then
            print_repo "$dir" "$quiet"
        fi
    done
}

main "$@"
