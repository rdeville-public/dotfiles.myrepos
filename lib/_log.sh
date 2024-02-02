#!/usr/bin/env bash
# """Log function allowing to echo colored string depending on debug level
# """

# shellcheck disable=SC2034
#   - SC2034: var appears unused, Verify use (or export if used externally)
_log()
{
# """Print debug message in colors depending on message severity on stderr
#
# Echo colored log depending on user provided message severity. Message
# severity are associated to following color output:
#   - `DEBUG` print in the fifth colors of the terminal (usually magenta)
#   - `INFO` print in the second colors of the terminal (usually green)
#   - `WARNING` print in the third colors of the terminal (usually yellow)
#   - `ERROR` print in the third colors of the terminal (usually red)
# If no message severity is provided, severity will automatically be set to
# INFO.
#
# Arguments:
#   $1: string, message severity or message content
#   $@: string, message content
#
# Output:
#   Log informations colored to stderr (to avoid catching by parent call)
#
# """
  _get_level(){
    local array=("error" "warning" "info" "debug" "time")
    local value=$(echo $1 | tr '[:upper:]' '[:lower:]')

    for idx in "${!array[@]}"; do
    if [[ "${array[$idx]}" = "${value}" ]]; then
      echo "${idx}";
      return
    fi
    done
    echo "-1"
    return 1
  }

  # Store color prefixes in variable to ease their use.
  declare -A color
  # Base on only 8 colors to ensure portability of color when in tty
  color["normal"]="\e[0m"     # Normal (usually white fg & transparent bg)
  color["bold"]="\e[1m"       # Bold
  color["underline"]="\e[4:3m"  # Underline
  color["debug"]="\e[34m"   # Fifth term color (usually magenta fg)
  color["info"]="\e[32m"    # Second term color (usually green fg)
  color["warning"]="\e[33m" # Third term color (usually yellow fg)
  color["error"]="\e[31m"   # First term color (usually red fg)


  local severity_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  local severity_upper=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  local prefix="${color["bold"]}${color[$severity_lower]}[${severity_upper}]${color["normal"]}${color[$severity_lower]}"
  local color_output="${color[$severity_lower]}"
  local msg_level=$(_get_level "${severity_lower}")
  local curr_level=$(_get_level "${DEBUG_LEVEL}")
  local msg=""

  if [[ ${curr_level} -ge ${msg_level} ]]
  then
      # Concat all remaining arguments in the message content and apply markdown
      # like syntax.
      # Regex will find all pattern of the form **(string)** or __(string)__ and
      # apply formating, respectively bold and underline.
      # Note: (string) cannot have output pattern (** or __) in them, this is
      # specified by '[^\*\*]' and '[^__]' in group selection.
      shift
      msg_content=$(echo "$*" | \
      sed -r \
          -e "s/\*\*([^\*\*]*)\*\*/\\${color["bold"]}\1\\${color["normal"]}\\${color_output}/g" \
          -e "s/__([^__]*)__/\\${color["underline"]}\1\\${color["normal"]}\\${color_output}/g" \
          )
      msg="${prefix} ${msg_content}${color["normal"]}"
      # Print message
      echo -e "${msg}" 1>&2
      return
  fi
  return
}

# vim: ft=bash: foldmethod=indent