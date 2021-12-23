#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

get_weather() {
  local location=$(get_tmux_option "@tmux-weather-location")
  local format=$(get_tmux_option "@tmux-weather-format" 1)
  local units=$(get_tmux_option "@tmux-weather-units" "m")

  if [ "$units" != "m" ] && [ "$units" != "u" ]; then
    units="m"
  fi

  curl -s "https://wttr.in/$location?$units&format=$format" | sed "s/[[:space:]]km/km/g"
}

main() {
  local update_interval=$((60 * $(get_tmux_option "@tmux-weather-interval" 15)))
  local current_time=$(date "+%s")
  local previous_update=$(get_tmux_option "@weather-previous-update-time")
  local delta=$((current_time - previous_update))
  local weather_style_left=$(get_tmux_option "@weather-style-left")
  local weather_style_right=$(get_tmux_option "@weather-style-right")

  if [ -z "$(get_tmux_option @weather-previous-value)" ]; then
    $(set_tmux_option "@weather-previous-value" "init...")
  else
    if [ -z "$previous_update" ] || [ $delta -ge $update_interval ]; then
      local value=$(get_weather)
      if [ "$?" -eq 0 ] && [ -n "$value" ]; then
        $(set_tmux_option "@weather-previous-update-time" "$current_time")
        $(set_tmux_option "@weather-previous-value" "$value")
      fi
    fi
  fi

  if [ -n "$(get_tmux_option "@weather-previous-value")" ];then
    echo -n "${weather_style_left}$(get_tmux_option @weather-previous-value)${weather_style_right}"
  fi
}

main
