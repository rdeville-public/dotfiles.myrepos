#!/usr/bin/env bash

_check_git_repo(){
  local repo_name="${VCSH_REPO_NAME:-${PWD/${HOME}/\~}}"
  if [[ -z "${VCSH_REPO_NAME}" ]] \
    && ! ([[ -d "${PWD}/.git" ]] \
          || git rev-parse --is-inside-work-tree &> /dev/null)
  then
    mr_log "ERROR" "Repo **${repo_name}** is not a git repo, aborting."
    exit 1
  elif [[ $(git remote | wc -l) -eq 0 ]]
  then
    mr_log "ERROR" "No remote defined for **${repo_name}**, aborting."
    exit 1
  elif ! [[ "$(git remote)" =~ origin ]]
  then
    mr_log "ERROR" "No remote **origin** defined for **${repo_name}**, aborting."
    exit 1
  else
    repo_path="$(git rev-parse --show-toplevel)"
    export MR_REPO="$(basename ${repo_path})"
  fi
}


_define_register_path(){
  local dest_dir_suffix=""
  local file_ext="git"
  local repo_type
  if [[ "${option}" == "tree" ]]
  then
    if [[ -n "${VCSH_REPO_NAME}" ]]
    then
      repo_type="vcsh/"
      extension=".vcsh"
    elif [[ "${PWD}" =~ ${HOME}/.config ]] || [[ "${PWD}" =~ ${HOME}/.local ]]
    then
      repo_type="dotfiles/"
    else
      repo_type="$(dirname ${PWD/${HOME}\/})/"
    fi
  fi
  if [[ "${option}" != "append" ]]
  then
    dest="${dest_prefix}/repos/${repo_type}${MR_REPO}.${file_ext}"
    dest_host="${dest_prefix}/hosts/${HOSTNAME}${repo_type}/${MR_REPO}.${file_ext}"
    dest_tmp="/tmp/${repo_type}${MR_REPO}.${file_ext}"
  else
    dest="${dest_prefix}/repos/${append_file}.git"
    dest_host="${dest_prefix}/hosts/${HOSTNAME}/${append_file}.git"
    dest_tmp="/tmp/${repo_type}/${append_file}.git"
  fi
}


_compute_register_content(){
  local remote_origin_url="$(git config --get remote.origin.url)"
  if [[ -n "${VCSH_REPO_NAME}" ]]
  then
    repo_path=".local/share/vcsh/repo.d/${VCSH_REPO_NAME}.git"
  fi

  git_tpl="\
[${repo_path/${HOME}\/}]
checkout =
  mr_checkout \"${remote_origin_url}\" \"\$@\""
}


_register_repo(){
  if [[ "${option}" != "append" ]]
  then
    if [[ -f "${dest}" ]]
    then
      mkdir -p "$(dirname ${dest_tmp})"
      echo "${git_tpl}" > "${dest_tmp}"
      if ! diff -q "${dest}" "${dest_tmp}" &> /dev/null
      then
        mr_log "WARNING" "Old and new registering for **${MR_REPO}** differs."
        mr_log "WARNING" "Backup old registering for **${MR_REPO}**."
        mv "${dest}" "${dest}.bak"
      else
        mr_log "INFO" "Old and new registering for **${MR_REPO}** are the same."
      fi
    fi
    mr_log "INFO" "Registering **${MR_REPO}** in **${dest/${HOME}/\~}**."
    mkdir -p "$(dirname ${dest})"
    echo -e "${git_tpl}\n" > "${dest}"
  else
    if ! [[ -f "${dest}" ]]
    then
      mr_log "INFO" "Registering **${MR_REPO}** in **${dest/${HOME}/\~}**."
      mkdir -p "$(dirname ${dest})"
      echo -e "${git_tpl}\n" >> "${dest}"
    elif ! grep "${repo_path/${HOME}\/}" "${dest}"
    then
      mr_log "INFO" "Adding **${MR_REPO}** in **${dest/${HOME}/\~}**."
      mkdir -p "$(dirname ${dest})"
      echo -e "${git_tpl}\n" >> "${dest}"
    else
      mr_log "WARNING" "Repo **${MR_REPO/${HOME}/\~}** seems to already be registered in **${dest/${HOME}/\~}**."
      mr_log "WARNING" "No new registration will be done."
    fi
  fi
}


_symlink_repo_in_host(){
  local nb_subdir=$(echo ${dest_host/${dest_prefix}\//} | tr -d -c "/" | wc -c)

  if ! [[ -L "${dest_host}" ]]
  then
    mr_log "INFO" "Create symlinks for **${MR_REPO/${HOME}/\~}** for **${HOSTNAME}**."
    mkdir -p "$(dirname ${dest_host})"
    dest="${dest/${dest_prefix}\//}"
    for ((i=0; i<nb_subdir; i++))
    do
      dest="../${dest/${dest_prefix}\//}"
    done
    ln -s "${dest}" "${dest_host}"
  else
    mr_log "INFO" "Symlinks for **${MR_REPO/${HOME}/\~}** for **${HOSTNAME}** already exists."
  fi
}

_test_option(){
  if [[ -n "${option}" ]]
  then
    mr_log "ERROR" "Option '--append', '--tree', '--flat' are mutually exclusive"
    exit 1
  fi
}

mr_register(){
  local dest_prefix="${XDG_DATA_DIR:-${HOME}/.local/share}/mr"
  local append_file="repos"
  local dest_dir=""
  local dest_dir_host=""
  local option=""
  local repo_path=""

  while [[ $# -gt 0 ]]
  do
    case $1 in
      --append|-a)
        _test_option
        option="append"
        shift
        if ! [[ $1 =~ --(flat|f|tree|t|dir|d) ]]
        then
          append_file="$1"
          shift
        fi
        ;;
      --flat|-f)
        _test_option
        option="flat"
        shift
        ;;
      --dir|-d)
        dest_prefix=$2
        shift
        shift
        ;;
    esac
  done

  if [[ -z "${option}" ]]
  then
    option="tree"
  fi

  _check_git_repo
  _define_register_path
  _compute_register_content
  _register_repo
  _symlink_repo_in_host
}

# -----------------------------------------------------------------------------
# VIM MODELINE
# vim: fdm=indent:fdi=
# -----------------------------------------------------------------------------