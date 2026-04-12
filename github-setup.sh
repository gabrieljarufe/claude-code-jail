#!/bin/bash
set -e

echo "=== GitHub setup ==="
echo ""

# Git identity
CURRENT_NAME=$(git config --global user.name 2>/dev/null || true)
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || true)

if [ -z "$CURRENT_NAME" ]; then
    read -rp "Git name:  " GIT_NAME
    git config --global user.name "$GIT_NAME"
else
    echo "Git name:  $CURRENT_NAME (already set)"
fi

if [ -z "$CURRENT_EMAIL" ]; then
    read -rp "Git email: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
else
    echo "Git email: $CURRENT_EMAIL (already set)"
fi

echo ""

# SSH key
KEY=/root/.ssh/id_ed25519
if [ ! -f "$KEY" ]; then
    mkdir -p /root/.ssh && chmod 700 /root/.ssh
    ssh-keygen -t ed25519 -N "" -f "$KEY" -C "$(git config --global user.email)"
    echo "SSH key created."
else
    echo "SSH key already exists: $KEY"
fi

echo ""
echo "=== Add this public key to GitHub ==="
echo "   GitHub → Settings → SSH and GPG keys → New SSH key"
echo ""
cat "$KEY.pub"
echo ""
echo "Test with: ssh -T git@github.com"
