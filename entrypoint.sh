#!/bin/bash
set -e

# ── Agent files ────────────────────────────────────────────────────────────
ln -sf /opt/claude-jail/CLAUDE.md /workspace/CLAUDE.md
ln -sf /opt/claude-jail/github-setup.sh /workspace/github-setup.sh
# ───────────────────────────────────────────────────────────────────────────

# ── Credential persistence ─────────────────────────────────────────────────
ln -sf /root/.claude/.claude.json /root/.claude.json
mkdir -p /root/persist/.ssh && chmod 700 /root/persist/.ssh
[ ! -L /root/.ssh ] && rm -rf /root/.ssh && ln -s /root/persist/.ssh /root/.ssh
[ -f /root/persist/.gitconfig ] && ln -sf /root/persist/.gitconfig /root/.gitconfig
touch /root/persist/.bashrc_custom
grep -q 'bashrc_custom' /root/.bashrc || echo 'source /root/persist/.bashrc_custom' >> /root/.bashrc
# ───────────────────────────────────────────────────────────────────────────

# Start Docker-in-Docker daemon
dockerd > /var/log/dockerd.log 2>&1 &

echo "Starting Docker daemon..."
timeout 30 sh -c 'until docker info >/dev/null 2>&1; do sleep 1; done'
echo "Docker ready."

exec sleep infinity
