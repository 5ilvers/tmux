#!/usr/bin/env bash

get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value=$(tmux show-option -gqv "$option")
    if [ -z $option_value ]; then
        echo $default_value
    else
        echo $option_value
    fi
}

main()
{
    # set current directory variable
    current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # set configuration option variables
    show_battery=$(get_tmux_option "@dracula-show-battery" true)
    show_network=$(get_tmux_option "@dracula-show-network" true)
    show_weather=$(get_tmux_option "@dracula-show-weather" false)
    show_fahrenheit=$(get_tmux_option "@dracula-show-fahrenheit" false)
    show_powerline=$(get_tmux_option "@dracula-show-powerline" false)
    show_cpu_percentage=$(get_tmux_option "@dracula-cpu-percent" false)

    # Dracula Color Pallette
    black='#282c34'
    white='#abb2bf'
    light_red='#e06c75'
    dark_red='#be5046'
    green='#98c379'
    light_yellow='#e5c07b'
    dark_yellow='#d19a66'
    blue='#61afef'
    magenta='#c678dd'
    cyan='#56b6c2'
    grey1='#4b5263'
    grey2='#5c6370'
    gray='#3e4452'
    dark_purple='#6272a4'
    light_purple='#bd93f9'


    left_icon="  "

    # start weather script in background
    if $show_weather; then
        $current_dir/sleep_weather.sh $show_fahrenheit &
    fi
  
    # sets refresh interval to every 5 seconds
    tmux set-option -g status-interval 5

    # set clock to 12 hour by default
    tmux set-option -g clock-mode-style 24

    # set length 
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100

    # pane border styling
    tmux set-option -g pane-active-border-style "fg=${dark_purple}"
    tmux set-option -g pane-border-style "fg=${gray}"

    # message styling
    tmux set-option -g message-style "bg=${gray},fg=${white}"

    # status bar
    tmux set-option -g status-style "bg=${gray},fg=${white}"


    tmux set-option -g status-left "#[bg=${green},fg=${black}]#{?client_prefix,#[bg=${light_yellow}],} ${left_icon}"

    tmux set-option -g  status-right ""

    if $show_battery; then # battery
        tmux set-option -g status-right "#[fg=${black},bg=${magenta}] #($current_dir/battery.sh) "
    fi

    if $show_cpu_percentage; then
        tmux set-option -ga status-right "#[fg=${black},bg=${light_yellow}] #($current_dir/cpu_info.sh) "
    fi

    if $show_network; then # network
        tmux set-option -ga status-right "#[fg=${black},bg=${cyan}] #($current_dir/network.sh) "
    fi

    if $show_weather; then # weather
        tmux set-option -ga status-right "#[fg=${black},bg=${light_yellow}] #(cat $current_dir/../data/weather.txt) "
    fi

    tmux set-option -ga status-right "#[fg=${white},bg=${gray}] %a %m/%d %R #(date +%Z) "

    tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${dark_purple}] #I #W "

    tmux set-window-option -g window-status-format "#[fg=${white}]#[bg=${gray}] #I #W "
}

# run main function
main
