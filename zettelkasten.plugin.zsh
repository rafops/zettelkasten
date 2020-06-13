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

_zk_find() {
  local filename

  cd "${ZK_HOME}"
  filename=$(echo "$@" | xargs -E '\n' -n1 ag -il | sort -u | fzf)
  cd - >/dev/null

  echo "${filename}"
}

_zk_commit_push() {
  local message="${1}"
  local filename="${2}"

  if [[ -d "${ZK_HOME}/.git" ]] && [[ -f "${ZK_HOME}/${filename}" ]]; then
    cd "${ZK_HOME}"
    git add "${filename}" && \
      git commit -v -a -m "${message}: ${filename}" >/dev/null && \
      git push --set-upstream origin $(git_current_branch) >/dev/null
    cd - >/dev/null
  fi
}

_zk_new() {
  local curdate=$(date +%Y%m%d%H%M%S)
  local formatted=$(echo "$@" | ruby -r 'active_support/all' -e 's=ARGF.read.chop ; print [:parameterize,:titleize].map { |m| s.send(m) }.join(" ")')
  local parameterized=$(echo "${formatted}" | cut -d ' ' -f 1)
  local titleized=$(echo "${formatted}" | cut -d ' ' -f 2-)
  local filename="${curdate}-${parameterized}.md"

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
