#!/usr/bin/env bash

for i_file in "${HOME}/.config/mr/lib/"*.sh
do
  . "${i_file}"
done
