#!/usr/bin/env bash

if [[ -z ${USE_HOSTNAME} ]]
then
  USE_HOSTNAME="${USE_HOSTNAME:="false"}"
fi

if [[ -z ${USE_USERNAME} ]]
then
  USE_USERNAME="${USE_USERNAME:="false"}"
fi

for i_file in "${HOME}/.config/mr/lib/"*.sh
do
  . "${i_file}"
done
