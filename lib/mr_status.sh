#!/usr/bin/env bash

mr_status(){
  git status -s "$@" || true
  git --no-pager log --branches --not --remotes --simplify-by-decoration --decorate --oneline || true
  git --no-pager stash list
}