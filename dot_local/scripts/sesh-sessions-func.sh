sesh_sessions() {
    {
        local fzf_cmd
        if [ -n "$TMUX" ]; then
            fzf_cmd="fzf-tmux -p 55%,60%"
        else
            exec </dev/tty
            exec <&1
            fzf_cmd="fzf --height 40%"
        fi

        session_select_command="sesh list --icons | $fzf_cmd \
            --reverse \
            --ansi \
            --no-sort \
            --border=rounded \
            --border-label ' sesh ' \
            --prompt '  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'ctrl-k:close' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list --icons)'"

        local session
        session=$(eval "$session_select_command")

        zle reset-prompt > /dev/null 2>&1 || true

        [[ -z "$session" ]] && return
        sesh connect $session
    }
}

