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

_zk_ruby_update() {
  cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1
  git pull origin master
  docker build --target zk-ruby --tag zk-ruby .
}

_zk_ruby() {
  [[ -n "$(docker image ls -q zk-ruby)" ]] || _zk_ruby_update
  docker run -i --rm -v "${ZK_HOME:-$(pwd)}:/root/workdir" -a stdin -a stdout zk-ruby "$@"
}

_zk_find() {
  local filename
  cd "${ZK_HOME}"
  filename=$(echo "$@" | xargs -E '\n' -n1 ag -il | sort -ru | fzf -1)
  cd - >/dev/null
  echo "${filename}"
}

_zk_commit_push() {
  local message="${1:-Updates}"
  local filename="${2:-.}"

  if [[ -d "${ZK_HOME}/.git" ]] && \
     [[ -f "${ZK_HOME}/${filename}" ]] && \
     [[ -n "$(which git)" ]]; then

    cd "${ZK_HOME}"
    git add "${filename}" && \
      git commit -v -a -m "${message}: ${filename}" >/dev/null && \
      git push --set-upstream origin $(git_current_branch) >/dev/null
    cd - >/dev/null

  fi
}

_zk_new() {
  local curdate=$(date +%Y%m%d%H%M%S)
  local filename="${curdate}.md"
  local formatted
  local parameterized
  local titleized="${curdate}"

  if [[ -n "$@" ]]; then
    formatted=$(echo "$@" | _zk_ruby -r 'active_support/all' -e 's=ARGF.read.chop ; print [:parameterize,:titleize].map { |m| s.send(m) }.join(" ")')
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

  escaped=$(echo "$@" | _zk_ruby -r 'shellwords' -e 'print Shellwords.shellescape ARGF.read.chop')
  vim -c "silent! /${escaped}/i" "${ZK_HOME}/${filename}"
  _zk_commit_push "Updated" ${filename}

  # in case there is no updates to the file
  return 0
}

_zk_list_todo() {
  cd "${ZK_HOME}"
  ag --color-match '1;31' --literal -i --nonumbers '[ ]'
  cd - >/dev/null
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
  _zk_check_home || return 1
  _zk_list_todo
}
