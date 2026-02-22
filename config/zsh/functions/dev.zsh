watch() {
  case "$1" in
    ng)
      local p1=$(tmux split-window -h -d -l 25% -P -F '#{pane_id}')
      local p2=$(tmux split-window -h -d -t "$p1" -l 50% -P -F '#{pane_id}')
      tmux send-keys -t "$p1" 'ng serve' Enter
      tmux send-keys -t "$p2" 'ng test --watch' Enter
      ;;
    sb)
      local p1=$(tmux split-window -h -d -l 25% -P -F '#{pane_id}')
      tmux send-keys -t "$p1" 'mvn spring-boot:run -pl api -Dspring.profiles=local' Enter
      ;;
    *)
      echo "Usage: watch <ng|sb>"
      return 1
      ;;
  esac
}

dev() {
  local p1=$(tmux split-window -h -d -l 20% -P -F '#{pane_id}')
  local p2=$(tmux split-window -v -d -l 20% -P -F '#{pane_id}')
  tmux send-keys 'nvim' Enter
  tmux send-keys -t "$p1" 'claude' Enter
  tmux select-pane -t "$p2"

  if [[ -n "$1" ]]; then
    watch "$1"
  fi
}
