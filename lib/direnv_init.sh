#!/usr/bin/env bash

direnv_init()
{
  if [[ -d "${HOME}/.config/direnv" ]]
  then
    mr_log "INFO" "Init direnv."
    envrc="${MR_REPO}/.envrc"
    envrc_tpl="${HOME}/.config/direnv/templates/envrc.template"
    if [[ -e "${envrc_tpl}" ]] && ! [[ -e "${envrc}" ]]
    then
      mr_log "INFO" "Create symlink **${envrc_tpl//${HOME}/\~}**."
      ln -s "${envrc_tpl}" "${envrc}"
    fi
    envrc_ini="${HOME}/.config/envrc${MR_REPO//${HOME}}/envrc.ini"
    envrc_ini_tpl="${HOME}/.config/direnv/templates/envrc.ini.template"
    mr_repo_envrc_ini="${MR_REPO//${HOME}/\~}/.envrc.ini"
    if ! [[ -e "${envrc_ini}" ]]
    then
      mr_log "INFO" "Install base envrc.ini file in **${envrc_ini//${HOME}/\~}**."
      mkdir -p "$(dirname ${envrc_ini})"
      cp "${envrc_ini_tpl}" "${envrc_ini}"
      mr_log "WARNING" "Do not forget to update **${mr_repo_envrc_ini}**."
    else
      mr_log "INFO" "Base envrc.ini file in **~/.config/envrc** already exists."
      mr_log "WARNING" "Do not forget to check **${mr_repo_envrc_ini}**."
    fi
    if ! [[ -e "${MR_REPO}/.envrc.ini" ]] && [[ -e "${envrc_ini}" ]]
    then
      mr_log "INFO" "Create symlink **${mr_repo_envrc_ini}**."
      ln -s "${envrc_ini}" "${MR_REPO}/.envrc.ini"
    fi
  fi
}
