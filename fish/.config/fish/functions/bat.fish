# Debian ships bat as `batcat` to avoid a name clash, so alias it back there.
# Distros with a real `bat` binary define nothing and fall through to it.
if command -q batcat
    function bat --wraps=batcat --description 'alias bat batcat'
        batcat $argv
    end
end
