_zk_set_home() {
  if [[ -z "${ZK_HOME}" ]]; then
    echo "Warning: \$ZK_HOME is not set, using ${HOME}/Documents by default" >/dev/stderr
    export ZK_HOME="${HOME}/Documents"
    return 0
  fi
  if [[ ! -d "${ZK_HOME}" ]]; then
    echo "Error: \$ZK_HOME ${ZK_HOME} is not a directory" >/dev/stderr
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
  filename=$(echo "$@" | xargs -E '\n' -n1 ag -il | sort -ru | fzf -1 --preview 'bat --style=numbers --color=always {}')
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
  local curtime=$(date +%s)
  local curdate=$(date -u -r ${curtime} +"%Y%m%d%H%M%S") # UTC
  local filename="${curdate}.md"
  local formatted
  local parameterized
  local titleized=$(date -r ${curtime} +"%Y-%m-%d %H:%M:%S %Z") # Current timezone

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
  ag --color-match '1;31' -i --nonumbers '(\[\s\]|TODO)'
  cd - >/dev/null
}

_zk_help() {
  echo "Usage:"
  echo "  zk                 \tCreate a new document without a title"
  echo "  zk <search>        \tCreate/edit a document from <search>"
  echo "  zk -n 'A document' \tCreate a new document with title 'A Document'"
  echo "  zk -f <query>      \tFind and edit an existing document containing <query>"
  echo "  zk -t              \tShow TODO list from existing documents"
  echo "  zk -h              \tShow this menu"
}

# ------------------------------------------------------------------------------

zk() {
  local search
  local _new=0
  local edit=0
  local todo=0
  local help=0

  while getopts nfth option
  do
  case "${option}"
  in
  n) _new=1;;
  f) edit=1;;
  t) todo=1;;
  h) help=1;;
  esac
  done

  # Help
  if [[ ${help} -eq 1 ]]; then
    _zk_help
    return 0
  fi

  # Set ZK_HOME or fail
  _zk_set_home
  [[ $? -eq 1 ]] && return 1

  # Empty arguments -> New document
  if [[ -z "$@" ]]; then
    _zk_new
    return 0
  fi

  # New with title
  if [[ ${_new} -eq 1 ]]; then
    shift
    _zk_new "$@"
    return 0
  fi

  # Find and edit from query
  if [[ ${edit} -eq 1 ]]; then
    shift
    _zk_edit "$@"
    return 0
  fi

  # Show TODO list
  if [[ ${todo} -eq 1 ]]; then
    _zk_list_todo
    return 0
  fi

  # Create/edit document from search
  _zk_edit "$@" || _zk_new "$@"
}
