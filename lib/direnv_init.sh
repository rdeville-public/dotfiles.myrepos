#!/usr/bin/env bash

_direnv_init_git()
{
  if [[ -d "${HOME}/.config/direnv" ]]
  then
    mr_log "INFO" "Init **direnv**."
    envrc="${MR_REPO}/.envrc"
    envrc_tpl="${HOME}/.config/direnv/templates/envrc.template"
    if [[ -e "${envrc_tpl}" ]] && ! [[ -e "${envrc}" ]]
    then
      mr_log "INFO" "Create symlink __${envrc_tpl//${HOME}/\~}__."
      ln -s "${envrc_tpl}" "${envrc}"
    fi
    envrc_ini="${HOME}/.config/envrc${MR_REPO//${HOME}}/envrc.ini"
    envrc_ini_tpl="${HOME}/.config/direnv/templates/envrc.ini.template"
    mr_repo_envrc_ini="${MR_REPO//${HOME}/\~}/.envrc.ini"
    if ! [[ -e "${envrc_ini}" ]]
    then
      mr_log "INFO" "Install source envrc.ini file in __${envrc_ini//${HOME}/\~}__."
      mkdir -p "$(dirname ${envrc_ini})"
      cp "${envrc_ini_tpl}" "${envrc_ini}"
      mr_log "WARNING" "Do not forget to update __${mr_repo_envrc_ini}__."
    else
      mr_log "INFO" "Source envrc.ini file in __${envrc_ini//${HOME}/\~}__ already exists."
      mr_log "WARNING" "Do not forget to check __${mr_repo_envrc_ini}__."
    fi
    if ! [[ -e "${MR_REPO}/.envrc.ini" ]] && [[ -e "${envrc_ini}" ]]
    then
      mr_log "INFO" "Create symlink __${mr_repo_envrc_ini}__."
      ln -s "${envrc_ini}" "${MR_REPO}/.envrc.ini"
    fi
  fi
}

direnv_init(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    mr_log "WARNING" "`direnv_init` is not support for **vcsh** repo, nothing to do."
  else
    _direnv_init_git "$@"
  fi
}
