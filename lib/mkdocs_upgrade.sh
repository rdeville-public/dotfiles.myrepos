#!/usr/bin/env bash

mkdocs_upgrade(){
  local mkdocs_git_base="https://framagit.org/rdeville.public/my_programs"
  local mkdocs_setup="${mkdocs_git_base}/mkdocs_template/-/raw/master/setup.sh"
  local mkdocs_template="${mkdocs_git_base}/mkdocs_template_rdeville"

  if [[ -e "${MR_REPO}/mkdocs.yml" ]] \
    && grep -q "BEGIN MKDOCS TEMPLATE" "${MR_REPO}/mkdocs.yml"
  then
    mr_log "Upgrading **mkdocs_template**."
    curl -sfL "${mkdocs_setup}" | bash -s -- -r "${mkdocs_template}" --upgrade
  fi
}
