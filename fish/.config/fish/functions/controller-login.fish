function controller-login
             set CREDS (terragrunt stack output juju_bootstrap.juju_controller --json | jq -r '.juju_bootstrap.juju_controller | [.controller_addresses[0], .username,
       .password] | @tsv')
             echo $CREDS | read -l JUJU_CONTROLLER_ADDRESS JUJU_USERNAME JUJU_PASSWORD
             echo "$JUJU_PASSWORD" | juju login -c maas-controller "$JUJU_CONTROLLER_ADDRESS" -u "$JUJU_USERNAME" --trust --no-prompt
	     juju switch maas
         
end
