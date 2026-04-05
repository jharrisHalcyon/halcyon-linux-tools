# Halcyon Linux Agent: Tenant Migration Procedure Without Reinstall

**Category:** Deployment / Operations  
**Platform:** Linux (x86_64)  
**Audience:** Halcyon SA, IT Operations

---

## Overview

This document describes how to migrate an already-registered Halcyon Linux agent from one tenant to another without a full reinstall and without wiping operational cached data. This is useful when an agent was installed against the wrong tenant, or when a device needs to be moved to a different tenant as part of an org restructure or POV teardown.

The procedure was discovered empirically during a live troubleshooting session and has been validated on the agent version noted below. The underlying mechanism may change in future releases, so verify before applying to newer versions.

---

## How Tenant Registration Works

When the agent is installed, `install.sh` reads the `HALCYON_TOKEN` environment variable and writes it to:

```
/opt/halcyon/halcyonar/token.toml
```

Content:
```toml
install_token = "<token>"
```

On first startup, the agent reads `token.toml`, hits `global.halcyon.ai/v1/installers/environment` to resolve the correct regional API endpoint, then performs a gRPC registration call. On success, the cloud issues a device ID and API key, which the agent stores in:

```
/opt/halcyon/halcyonar/info.dat
```

After registration completes, `token.toml` is deleted by the agent. On subsequent startups, the agent uses `info.dat` exclusively. The installation token is no longer referenced.

To migrate to a new tenant, the agent's identity must be reset by replacing `token.toml` with the new tenant token and removing `info.dat` so the agent re-registers from scratch.

---

## Prerequisites

- Root or sudo access on the target Linux host
- The installation token for the destination tenant (available in the Halcyon console under **Deploy**)
- Confirmation that the destination tenant has the Linux add-on enabled
- The source device should be removed from the origin tenant console after migration to avoid a stale orphaned record

---

## Step 0: Identify Agent Version

Before proceeding, capture the current agent version. Include this in any support tickets or change records.

```bash
echo "Product : $(cat /opt/halcyon/halcyonar/PRODUCT-VERSION.txt)"
echo "Agent   : $(cat /opt/halcyon/halcyonar/AGENT-VERSION.txt)"
echo "eBPF    : $(cat /opt/halcyon/halcyonar/EBPF_DRIVER_VERSION.txt)"
```

Example output:
```
Product : v2.0.2602.28
Agent   : v2.0.2602.28
eBPF    : v2.0.2602.28
```

---

## Migration Procedure

### Step 1: Stop the Agent Services

Both services must be stopped. Stop `halcyonagent` first, then `halcyonebpf`.

```bash
sudo systemctl stop halcyonagent halcyonebpf
```

Confirm both are stopped:

```bash
systemctl is-active halcyonagent halcyonebpf
```

Both should return `inactive`.

### Step 2: Write the New Tenant Token

Replace the token file with the destination tenant's installation token. The token is available in the Halcyon console under **Deploy > Installation Token**.

```bash
echo 'install_token = "<new-tenant-token>"' | sudo tee /opt/halcyon/halcyonar/token.toml
```

Verify:
```bash
sudo cat /opt/halcyon/halcyonar/token.toml
```

### Step 3: Remove the Stored Device Identity

Delete `info.dat` to clear the existing device ID and API key. This is the only file that needs to be removed. The operational database files (`agent_db`, `halcyon*_db`) contain hash caches and list data and should be left in place.

```bash
sudo rm -f /opt/halcyon/halcyonar/info.dat
```

### Step 4: Start the Services

Start `halcyonebpf` first. It owns the IPC socket that `halcyonagent` depends on.

```bash
sudo systemctl start halcyonebpf halcyonagent
```

### Step 5: Verify Registration

The agent deletes `token.toml` after reading it. Confirm the file is gone (expected):

```bash
sudo ls /opt/halcyon/halcyonar/token.toml 2>/dev/null || echo "token.toml consumed -- expected"
```

Check the agent log for a successful registration line:

```bash
sudo grep "c2::service Regist" /opt/halcyon/halcyonar/logs/agent.log | tail -5
```

A successful migration shows:

```
DEBUG agent::c2::service Not Registered!
DEBUG agent::c2::service Registration successful.
```

The `Not Registered!` line confirms the identity was cleared. The `Registration successful.` line confirms the new tenant accepted the token.

### Step 6: Confirm in the Console

Log into the destination tenant console and navigate to **Assets**. The device should appear within a minute or two of registration. Confirm the hostname, OS, agent version, and policy assignment look correct.

Then log into the origin tenant console and delete the orphaned device record to keep the asset list clean.

---

## Troubleshooting

**401 Unauthorized on `global.halcyon.ai`**

The agent reads `token.toml` once and deletes it immediately. If a prior failed attempt already consumed the file, token.toml will not exist and the next startup will fail with a 401 because there is nothing to authenticate with. Solution: re-write token.toml and restart.

```bash
echo 'install_token = "<new-tenant-token>"' | sudo tee /opt/halcyon/halcyonar/token.toml
sudo systemctl restart halcyonebpf halcyonagent
```

**Registration line not appearing in log**

Check that the current agent PID is generating log entries. Substitute the real PID from `systemctl status halcyonagent`:

```bash
sudo grep "\[$(systemctl show halcyonagent -p MainPID --value)\]" \
  /opt/halcyon/halcyonar/logs/agent.log | grep -E "Regist|401|token|Device Id" | head -20
```

**Device appears in wrong tenant after migration**

`info.dat` was likely not deleted before restart. Stop services, confirm the file is gone, and repeat from Step 3.

**Linux add-on not enabled on destination tenant**

If the token is valid but registration fails, confirm the destination tenant has the Linux add-on active. Check **Add-ons** in the Halcyon console. A tenant without Linux enabled will reject registration even with a valid token.

---

## Summary of Files

| File | Purpose | Action During Migration |
|---|---|---|
| `token.toml` | Installation token (transient) | Write new token, agent deletes after reading |
| `info.dat` | Device ID and API key (binary) | Delete to force re-registration |
| `agent_db` | Operational SQLite data | Leave in place |
| `halcyon*_db` | Hash caches and list stores | Leave in place |
| `logs/agent.log` | Agent log | Read-only, use for verification |

---

## Version Note

This procedure was validated on:

```
Product : v2.0.2602.28
Agent   : v2.0.2602.28
eBPF    : v2.0.2602.28
```

The file paths and filenames (`info.dat`, `token.toml`) are not guaranteed to remain stable across major releases. Verify before applying to a significantly newer agent version.

---

*jharris*