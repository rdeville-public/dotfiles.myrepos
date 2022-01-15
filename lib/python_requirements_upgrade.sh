#!/usr/bin/env bash

python_requirements_upgrade(){
  if compgen -G "${MR_REPO}/requirements*in" > /dev/null
  then
    for i_req in "${MR_REPO}"/requirements*in
    do
      mr_log "Upgrading **${i_req/${MR_REPO}\//}**."
      pip-compile -U ${i_req} 2> /dev/null
    done
  fi
}
