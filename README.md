# halcyon-linux-tools

Utilities for deploying and managing the Halcyon Anti-Ransomware agent on Linux systems. Built by the Halcyon SA team.

---

## Tools

### `halcyon-api-install.sh`

Installs the Halcyon Linux agent on a headless machine by authenticating to the Halcyon API, retrieving the current installer and install token for the target tenant, downloading the tarball, and running the standard installer. No browser required.

**Requirements:** `curl`, `python3`, `tar` (all standard on supported Halcyon Linux distributions)

**Supported distributions:** RHEL 8/9, Debian 11/12, Ubuntu 22.04/24.04 LTS, AWS Linux 2023, Oracle Linux 8/9, Rocky Linux 8/9, AlmaLinux 8/9

#### One-liner install

```bash
HAL_USER='user@example.com' \
HAL_PASS='yourpassword' \
HAL_TENANT='<tenant-uuid>' \
bash <(curl -fsSL https://raw.githubusercontent.com/jharrisHalcyon/halcyon-linux-tools/main/halcyon-api-install.sh)
```

#### Interactive install

```bash
curl -fsSL https://raw.githubusercontent.com/jharrisHalcyon/halcyon-linux-tools/main/halcyon-api-install.sh -o halcyon-api-install.sh
bash halcyon-api-install.sh
```

Prompts for login email, password, and tenant ID if not supplied as environment variables.

#### Parameters

| Variable | Description |
|---|---|
| `HAL_USER` | Halcyon console login email |
| `HAL_PASS` | Halcyon console password |
| `HAL_TENANT` | Tenant UUID (found in the Halcyon console under Deploy) |

#### Security note

Passing `HAL_PASS` inline exposes the password in shell history and the process list. For automation, prefer sourcing credentials from a secrets manager or environment file. The interactive prompt avoids both risks.

---

### `halcyon-linux-agent-tenant-migration.md`

Step-by-step procedure for migrating an already-registered Halcyon Linux agent from one tenant to another without a full reinstall. Covers the registration mechanism, minimal file changes required, verification steps, and troubleshooting for common failure modes.

Suitable for import into Confluence or any Markdown-capable wiki.

---

## Requirements

- Valid Halcyon console credentials (non-SSO account or dedicated service account)
- Outbound HTTPS to `api.halcyon.ai` and the Halcyon installer CDN
- The Linux add-on must be enabled on the target tenant
- `sudo` or root access on the target machine

---

## Notes

This tooling was developed and validated against Halcyon agent `v2.0.2602.28`. File paths and internal mechanisms may change in future agent releases. Version output is displayed during install for reference.

This is not an official Halcyon product. It is a community utility maintained by the SA team.

---

*jharris*
