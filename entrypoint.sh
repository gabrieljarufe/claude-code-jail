#!/bin/bash
set -e

# Sobe o Docker daemon interno (DinD)
dockerd > /var/log/dockerd.log 2>&1 &

# Aguarda o daemon ficar pronto
echo "Iniciando Docker daemon..."
timeout 30 sh -c 'until docker info >/dev/null 2>&1; do sleep 1; done'
echo "Docker pronto."

# Mantém o container vivo
exec sleep infinity