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
    sleep 3
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
APP_PID=$!
sleep 1
[ $? -ne 0 ] && printf "${BOLD}${RED}Could not start application!!!\n${RESET}" >&2 && exit 1

[ -e ./cloudflared.log ] && rm ./cloudflared.log
cloudflared tunnel --url http://localhost:8099 --output json --logfile cloudflared.log&
TUNNEL_PID=$!
sleep 3

max_retry=5
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
fi

wait
