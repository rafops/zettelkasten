_zk_check_home() {
  if [[ -z "${ZK_HOME}" ]]; then
    echo "\$ZK_HOME is not set" >/dev/stderr
    return 1
  fi
  if [[ ! -d "${ZK_HOME}" ]]; then
    echo "\$ZK_HOME ${ZK_HOME} is not a directory" >/dev/stderr
    return 1
  fi
}

_zk_cd_in() {
  cd "${ZK_HOME}"
}

_zk_cd_out() {
  cd - >/dev/null
}

_zk_find() {
  local filename

  _zk_cd_in
  filename=$(echo "$@" | xargs -E '\n' -n1 ag -il | sort -ru | fzf -1)
  _zk_cd_out

  echo "${filename}"
}

_zk_commit_push() {
  local message="${1}"
  local filename="${2}"

  if [[ -d "${ZK_HOME}/.git" ]] && [[ -f "${ZK_HOME}/${filename}" ]]; then
    _zk_cd_in
    git add "${filename}" && \
      git commit -v -a -m "${message}: ${filename}" >/dev/null && \
      git push --set-upstream origin $(git_current_branch) >/dev/null
    _zk_cd_out
  fi
}

_zk_new() {
  local curdate=$(date +%Y%m%d%H%M%S)
  local filename="${curdate}.md"
  local formatted
  local parameterized
  local titleized="${curdate}"

  if [[ -n "$@" ]]; then
    formatted=$(echo "$@" | ruby -r 'active_support/all' -e 's=ARGF.read.chop ; print [:parameterize,:titleize].map { |m| s.send(m) }.join(" ")')
    parameterized=$(echo "${formatted}" | cut -d ' ' -f 1)
    titleized=$(echo "${formatted}" | cut -d ' ' -f 2-)

    if [[ -n "${parameterized}" ]]; then
      filename="${curdate}-${parameterized}.md"
    fi
  fi

  echo "# ${titleized}\n\n" | vim +3 - +"file ${ZK_HOME}/${filename}"
  _zk_commit_push "Created" ${filename}
}

_zk_edit() {
  local filename=$(_zk_find "$@")
  local escaped

  [[ -n "${filename}" ]] || return 1

  escaped=$(echo "$@" | ruby -r 'shellwords' -e 'print Shellwords.shellescape ARGF.read.chop')
  vim -c "silent! /${escaped}" "${ZK_HOME}/${filename}"
  _zk_commit_push "Updated" ${filename}

  # in case there is no updates to the file
  return 0
}

# ------------------------------------------------------------------------------

zk() {
  _zk_check_home || return 1
  _zk_new "$@"
}

zkf() {
  _zk_check_home || return 1
  _zk_edit "$@" || _zk_new "$@"
}

zkt() {
}
