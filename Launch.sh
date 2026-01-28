#!/usr/bin/env bash

BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
RESET='\033[0m'
BOLD='\033[1m'

cleanup() {
    printf "${BOLD}${BLUE}\nExiting...\n\n${RESET}"
    kill -9 $APP_PID $TUNNEL_PID
    sleep 1
    while [[ -n "$(pgrep flask | grep $APP_PID)" ]]; do
        printf  "${BOLD}${BLUE}\nClossing flask app...\n${RESET}"
        kill -9 $APP_PID
        sleep 1
    done
    while [[ -n "$(pgrep cloudflared | grep $TUNNEL_PID)" ]]; do
        printf "${BOLD}${BLUE}\nClosing cloudflared tunnel...\n${RESET}"
        kill -9 $TUNNEL_PID
        sleep 1
    done 
    exit 0
}

trap "cleanup" SIGINT

if [ ! -e ./.App-env ] || ! command -v cloudflared >/dev/null 2>&1; then
    [ ! -e ./configure.sh ] && printf "${BOLD}${RED}Missing dependencies, get the 'configure.sh' file on the current directory.\n${RESET}" >&2 && exit 1
    chmod +x ./configure.sh 2>/dev/null
    ./configure.sh
    [ $? -ne 0 ] && exit 1
fi

source ./.App-env/bin/activate

flask run -h localhost -p 8099&
readonly APP_PID=$!
sleep 1

[ -e ./cloudflared.log ] && rm ./cloudflared.log
cloudflared tunnel --url http://localhost:8099 --logfile cloudflared.log&
readonly TUNNEL_PID=$!
sleep 3

readonly max_retry=5
for ((i=0; i<$max_retry; i++)); do
    [ $(wc -l < ./cloudflared.log) -le 5 ] && ((i--))
    url=$(grep -oE "https://[a-z-]{5,}.trycloudflare.com" ./cloudflared.log)
    [ -n "$url" ] && break
    sleep 2
done

if [ -z "$url" ]; then
    printf "\n${BOLD}${RED}Error could start a tunnel!!!\n\n${RESET}"
    kill -9 $APP_PID $TUNNEL_PID
else
    printf "\n${BOLD}${GREEN}Tunnel url: $url${RESET}\n\n"
    sleep 5
    xdg-open "$url"
fi

wait
