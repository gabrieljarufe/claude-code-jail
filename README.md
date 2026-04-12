# Claude Code Jail

Ambiente isolado para usar o Claude Code com poder total — sem risco para o seu sistema operacional.

Um container Docker com Linux completo onde o Claude Code opera como agente autônomo: instala dependências, sobe bancos de dados, cria projetos, roda testes — tudo confinado dentro do container, acessível pelo VS Code como se fosse uma máquina local.

---

## Pré-requisitos

- Docker Desktop (Windows/macOS) ou Docker Engine (Linux)
- VS Code com a extensão **Dev Containers** da Microsoft
- Conta no [claude.ai](https://claude.ai) com plano Pro, Max, Team ou Enterprise

---

## Início rápido

```bash
# 1. Clone o repositório
git clone https://github.com/gabrieljarufe/claude-code-jail.git
cd claude-code-jail

# 2. Suba o container (primeiro build leva 3-5 minutos)
docker compose up --build -d

# 3. No VS Code: Ctrl+Shift+P → "Dev Containers: Attach to Running Container" → claude-jail

# 4. No terminal do container:
claude
```

Na primeira execução o Claude Code vai pedir autenticação. Siga as instruções na tela.

---

## Fluxo do dia a dia

```bash
# Ligar
docker compose up -d
# VS Code → Attach to Running Container → claude-jail → cd /workspace && claude

# Desligar
docker compose stop
```

Projetos, login e imagens Docker internas persistem automaticamente entre restarts.

---

## Setup do GitHub (primeira vez)

Dentro do container, rode o script auxiliar:

```bash
bash /workspace/github-setup.sh
```

Ele configura `git config` e gera uma chave SSH ed25519. Siga as instruções na tela para adicionar a chave ao GitHub.

---

## Por que usar um container?

O Claude Code executa comandos reais no sistema operacional. Rodando direto na sua máquina isso significa dar a uma IA acesso ao seu sistema inteiro.

Com o Claude Code Jail, o agente tem controle total — mas dentro de uma sandbox. Se algo der errado, você destrói o container e recria em minutos.

- **Segurança** — o agente não toca no seu sistema
- **Reprodutibilidade** — ambiente consistente, sempre igual
- **Liberdade** — o Claude Code instala o que quiser sem pedir permissão
- **Persistência** — projetos, configuração e login sobrevivem a restarts
- **Docker-in-Docker** — o agente pode subir containers internos (bancos, caches, APIs)

---

## Portas disponíveis

| Porta | Uso típico |
|-------|------------|
| 3000 | Node.js / frontend |
| 8000 | Python (FastAPI, Django) |
| 8080–8090 | APIs (Go, Java, etc.) |
| 5432 | PostgreSQL |
| 3306 | MySQL |
| 6379 | Redis |
| 27017 | MongoDB |

---

## Estrutura do projeto

```
claude-code-jail/
├── CLAUDE.md           ← instruções do agente (baked na imagem)
├── github-setup.sh     ← helper de setup do GitHub (baked na imagem)
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
└── .devcontainer/
    └── devcontainer.json
```

---

## Licença

MIT
