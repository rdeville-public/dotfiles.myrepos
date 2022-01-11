#!/usr/bin/env bash

_add_vcsh_upstream(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  remote=$(vcsh run ${vcsh_repo_name} git config --get remote.origin.url)
  if [[ "${remote}" =~ rdeville.private ]]
  then
    mr_log "INFO" "Adding upstream remote for vcsh **${vcsh_repo_name}**."
    if [[ -n "${upstream_remote}" ]]
    then
      vcsh run ${vcsh_repo_name} git remote add upstream "${upstream_remote}"
    elif [[ -n "${pattern}" ]] && [[ -n "${replace}" ]]
    then
      vcsh run ${vcsh_repo_name} git remote add upstream ${remote/${pattern}/${replace}}
    fi
  fi
}

_add_git_upstream(){
  remote=$(git config --get remote.origin.url)
  if [[ "${remote}" =~ rdeville.private ]]
  then
    mr_log "INFO" "Adding upstream remote for **${MR_REPO/${HOME}/\~}**."
    if [[ -n "${upstream_remote}" ]]
    then
      git remote add upstream "${upstream_remote}"
    elif [[ -n "${pattern}" ]] && [[ -n "${replace}" ]]
    then
      git remote add upstream ${remote/${pattern}/${replace}}
    fi
  fi
}

add_upstream(){
  local pattern
  local replace
  local upstream_remote
  while [[ $# -gt 0 ]]
  do
    case $1 in
      -e)
        pattern=$2
        replace=$3
        shift
        shift
        shift
        ;;
      -r)
        upstream_remote=$2
        shift
        shift
        ;;
    esac
  done
  if [[ -n "${upstream_remote}" ]] && [[ -n "${pattern}" ]]
  then
    mr_log "ERROR" "'add_upstream': option '-r' and '-e' are mutually exclusive !"
    exit 1
  elif ([[ -n "${pattern}" ]] && [[ -z ${replace} ]]) \
    || ([[ -n "${pattern}" ]] && [[ -z ${replace} ]])
  then
    mr_log "ERROR" "'add_upstream': 'pattern' and 'replace' MUST be specified when using '-e'."
  fi
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    echo "vcsh_upstream"
    _add_vcsh_upstream
  else
    echo "git_upstream"
    _add_git_upstream
  fi
}
