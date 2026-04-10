#!/bin/bash
set -e

# ── Persistence bootstrap ──────────────────────────────────────────────────
ln -sf /root/.claude/.claude.json /root/.claude.json
mkdir -p /root/persist/.ssh && chmod 700 /root/persist/.ssh
[ ! -L /root/.ssh ] && rm -rf /root/.ssh && ln -s /root/persist/.ssh /root/.ssh
[ -f /root/persist/.gitconfig ] && ln -sf /root/persist/.gitconfig /root/.gitconfig
touch /root/persist/.bashrc_custom
grep -q 'bashrc_custom' /root/.bashrc || echo 'source /root/persist/.bashrc_custom' >> /root/.bashrc
# ───────────────────────────────────────────────────────────────────────────

# Sobe o Docker daemon interno (DinD)
dockerd > /var/log/dockerd.log 2>&1 &

# Aguarda o daemon ficar pronto
echo "Iniciando Docker daemon..."
timeout 30 sh -c 'until docker info >/dev/null 2>&1; do sleep 1; done'
echo "Docker pronto."

# Mantém o container vivo
exec sleep infinity