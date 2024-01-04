#!/usr/bin/env bash


_python_requirements_upgrade(){
  if compgen -G "${MR_REPO}/requirements*in" &> /dev/null
  then
    for i_req in "${MR_REPO}"/requirements*in
    do
      _log "Upgrading **${i_req/${MR_REPO}\//}**."
      pip-compile -U "${i_req}" 2> /dev/null
    done
  fi
}
_mkdocs_upgrade(){
  local mkdocs_git_base="https://framagit.org/rdeville.public/programs"
  local mkdocs_setup="${mkdocs_git_base}/mkdocs_template/-/raw/master/setup.sh"
  local mkdocs_template="${mkdocs_git_base}/mkdocs_template_rdeville"

  if [[ -e "${MR_REPO}/mkdocs.yml" ]] \
    && grep -q "BEGIN MKDOCS TEMPLATE" "${MR_REPO}/mkdocs.yml"
  then
    _log "Upgrading **mkdocs_template**."
    curl -sfL "${mkdocs_setup}" | bash -s -- -r "${mkdocs_template}" --upgrade
  fi
}

mr_upgrade(){
  _mkdocs_upgrade
  _python_requirements_upgrade
}