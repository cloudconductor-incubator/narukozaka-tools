function kill_remove_pidfile() {
  local pidfile=${1}
  [[ -f ${pidfile} ]] || return 0

  local pid=$(head -1 ${pidfile})
  while ps -p ${pid}; do
    kill -TERM ${pid} || kill -KILL ${pid}
    sleep 1
  done

  rm -f ${pidfile}
}
