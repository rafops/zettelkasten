_check_zk_home() {
  if [[ -z "${ZK_HOME}" ]]; then
    echo "\$ZK_HOME is not set" >/dev/stderr
    return 1
  fi
}

zk() {
  _check_zk_home || return 1

  cd "${ZK_HOME}"

  curdate=$(date +%Y%m%d%H%M%S)
  title=$(echo "$@" | ruby -r 'active_support/all' -e "puts ARGF.read.parameterize")
  vim "${curdate}-${title}.md"

  git commit -v -a -m "Updates to ${title}"
  git push --set-upstream origin $(git_current_branch)
}

zkf() {
  _check_zk_home || return 1

  cd "${ZK_HOME}"

  ffound=$(echo "$@" | xargs ag -il | fzf)

  if [[ -n "${ffound}" ]]; then
    vim -c "silent! /$@" "${ffound}"
  else
    zk "$@"
  fi
}

zkt() {
}
