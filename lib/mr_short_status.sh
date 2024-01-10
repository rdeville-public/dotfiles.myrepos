#!/usr/bin/env bash

mr_short_status(){
  _git_get_tag()
  {
    # Get tags that contains commit
    git describe --tags --exact-match 2> /dev/null
    return
  }

  _git_get_commit_description()
  {
    # Get the branch that contains the commit
    git describe --contains --all 2> /dev/null
    return
  }

  _git_get_short_sha()
  {
    # Get short SHA
    git rev-parse --short HEAD
    return
  }

  _git_get_friendly_ref()
  {
    # Get commit reference in a friendly name
    # Try the checked-out branch first to avoid collision with branches pointing
    # to the same ref.
    _git_get_branch || _git_get_tag || _git_get_commit_description || _git_get_short_sha
    return
  }

  _git_get_upstream_behind_ahead()
  {
    # Get if the current branch is behind or above HEAD
    git rev-list --left-right --count "origin/${git_branch}...${git_branch}" 2> /dev/null
    return
  }

  _git_get_branch()
  {
    # Get the current branch name
    git symbolic-ref -q --short HEAD 2> /dev/null || return 1
    return
  }

  _git_get_status()
  {
    # Get the information about files, i.e. untracked, tracked and unstaged
    # files.
    local git_status_flags=
    if [[ "${GIT_IGNORE_UNTRACKED}" == "true" ]]
    then
      git_status_flags='-uno'
    fi
    git status --porcelain ${git_status_flags} 2> /dev/null
    return
  }

  _git_get_status_counts()
  {
    # Parse output of method _git_get_status to print only number of tracker,
    # untracked and unstaged files
    _git_get_status | awk '
    BEGIN {
      untracked=0;
      unstaged=0;
      staged=0;
    }
    {
      if ($0 ~ /^\?\? .+/) {
        untracked += 1
      } else {
        if ($0 ~ /^.[^ ] .+/) {
          unstaged += 1
        }
        if ($0 ~ /^[^ ]. .+/) {
          staged += 1
        }
      }
    }
    END {
      print unstaged "\t" staged "\t" untracked
    }'
    return
  }

  _git_set_vars()
  {
    # Set git variable and compute the git info line using method above
    local short=$1
    local colored=$2
    local detached_prefix
    local detached_suffix
    local git_commit
    local git_branch
    local git_ahead
    local git_behind
    local untracked_count
    local unstaged_count
    local staged_count
    local stash_count
    local git_info
    local git_state

    git_commit="$(_git_get_short_sha)"
    git_branch="$(_git_get_branch)"
    git_friendly_name="$(_git_get_friendly_ref)"
    if [[ "${git_friendly_name}" != "${git_branch}" ]]
    then
      if _git_get_tag &> /dev/null;
      then
        detached_prefix=" ${GIT_TAG_PREFIX}"
        detached_suffix="${GIT_TAG_SUFFIX} "
      else
        detached_prefix=" ${GIT_DETACHED_PREFIX}"
        detached_suffix="${GIT_DETACHED_SUFFIX} "
      fi
      git_branch="${git_friendly_name}"
    else
      detached_prefix=""
      detached_suffix=""
    fi

    IFS=$'\t' read -r commits_behind commits_ahead <<< "$(_git_get_upstream_behind_ahead)"
    if [[ "${commits_ahead}" -gt 0 ]]
    then
      git_ahead=" ${GIT_AHEAD_CHAR}${commits_ahead}"
    fi

    if [[ "${commits_behind}" -gt 0 ]]
    then
      git_behind=" ${GIT_BEHIND_CHAR}${commits_behind}"
    fi

    stash_count="$(git stash list 2> /dev/null | wc -l | tr -d ' ')"
    if [[ "${stash_count}" -gt 0 ]]
    then
      stash_count="${GIT_STASH_CHAR_PREFIX}${stash_count}${GIT_STASH_CHAR_SUFFIX}"
    else
      stash_count=""
    fi

    git_state=" ${GIT_PROMPT_CLEAN}"
    IFS=$'\t' read -r unstaged_count staged_count untracked_count <<< "$(_git_get_status_counts)"
    if [[ "${staged_count}" -gt 0 ]]
    then
      staged_count=" ${GIT_STAGED_CHAR}${staged_count}"
      git_state=" ${GIT_PROMPT_DIRTY}"
    else
      staged_count=""
    fi
    if [[ "${unstaged_count}" -gt 0 ]]
    then
      unstaged_count=" ${GIT_UNSTAGED_CHAR}${unstaged_count}"
      git_state=" ${GIT_PROMPT_DIRTY}"
    else
      unstaged_count=""
    fi
    if [[ "${GIT_IGNORE_UNTRACKED}" == "false" ]] \
        && [[ "${untracked_count}" -gt 0 ]]
    then
      untracked_count=" ${GIT_UNTRACKED_CHAR}${untracked_count}"
      git_state=" ${GIT_PROMPT_DIRTY}"
    else
      untracked_count=""
    fi

    if [[ ${colored} == "false" ]]
    then
      git_info="${GIT_CHAR}"
      if [[ ${short} == "false" ]]
      then
        git_info+="${detached_prefix}"
        git_info+="${git_commit}"
        if [[ -n "${git_branch}" ]]
        then
          git_info+="${GIT_BRANCH_PREFIX}${git_branch}"
        fi
        git_info+="${detached_suffix}"
      fi
      git_info+="${stash_count}"
      git_info+="${git_behind}"
      git_info+="${git_ahead}"
      git_info+="${untracked_count}"
      git_info+="${unstaged_count}"
      git_info+="${staged_count}"
      git_info+="${git_state}"
    else
      git_info+="${VCS_DETACHED_FG}${detached_prefix}"
      git_info+="${VCS_COMMIT_FG}${git_commit}"
      if [[ -n "${git_branch}" ]]
      then
        git_info+=" ${VCS_BRANCH_FG}${GIT_BRANCH_PREFIX}${git_branch}"
      fi
      git_info+="${VCS_DETACHED_FG}${detached_suffix}"
      git_info+="${VCS_STASH_FG}${stash_count}"
      git_info+="${VCS_BEHIND_FG}${git_behind}"
      git_info+="${VCS_AHEAD_FG}${git_ahead}"
      git_info+="${VCS_UNTRACKED_FG}${untracked_count}"
      git_info+="${VCS_UNSTAGED_FG}${unstaged_count}"
      git_info+="${VCS_STAGED_FG}${staged_count}"
      if [[ "${git_state}" == " ${GIT_PROMPT_CLEAN}" ]]
      then
        git_info+="${VCS_PROMPT_CLEAN_FG}${git_state}"
      else
        git_info+="${VCS_PROMPT_DIRTY_FG}${git_state}"
      fi
    fi
    echo -e "${git_info}\033[0m"
    return
  }

  GIT_CHAR=" "
  GIT_PROMPT_DIRTY="✗"
  GIT_PROMPT_CLEAN="✓"
  GIT_BRANCH_PREFIX=" "
  GIT_TAG_PREFIX="笠["
  GIT_TAG_SUFFIX="]"
  GIT_DETACHED_PREFIX=" ["
  GIT_DETACHED_SUFFIX="]"
  GIT_AHEAD_CHAR="ﰵ"
  GIT_BEHIND_CHAR="ﰬ"
  GIT_UNTRACKED_CHAR=" "
  GIT_UNSTAGED_CHAR=" "
  GIT_STAGED_CHAR=" "
  GIT_STASH_CHAR_PREFIX="{"
  GIT_STASH_CHAR_SUFFIX="}"

  VCS_PROMPT_DIRTY_FG="\033[38;2;135;0;0m"
  VCS_PROMPT_CLEAN_FG="\033[38;2;0;135;0m"
  VCS_BRANCH_FG="\033[38;2;0;135;250m"
  VCS_TAG_FG="\033[38;2;95;0;0m"
  VCS_DETACHED_FG="\033[38;2;95;0;0m"
  VCS_COMMIT_FG="\033[38;2;0;135;250m"
  VCS_AHEAD_FG="\033[38;2;0;135;0m"
  VCS_BEHIND_FG="\033[38;2;95;0;0m"
  VCS_UNTRACKED_FG="\033[38;2;135;135;135m"
  VCS_UNSTAGED_FG="\033[38;2;135;95;0m"
  VCS_STAGED_FG="\033[38;2;0;95;0m"
  VCS_STASH_FG="\033[38;2;95;0;95m"

  _git_set_vars "$1" "$2"
}
