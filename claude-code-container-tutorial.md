# Claude Code em Container Docker no Windows

> **Parte do projeto [Claude Code Jail](README.md)** — veja também: [Guia Claude Code](guia-claude-code.md) · [Guia SDD](guia-sdd-claude-code.md)

## O que você vai ter no final

Um Linux rodando dentro do Docker, persistente como uma VM, onde o Claude Code tem controle total para instalar o que quiser, subir bancos, criar projetos em Go, Python ou Java — tudo acessível pelo VS Code do seu Windows como se fosse uma máquina local.

---

## Pré-requisitos

- Windows com Docker Desktop instalado e **rodando**
- VS Code instalado
- Hyper-V ativo (necessário para Docker Desktop)

```powershell
# PowerShell como admin — ativar Hyper-V
bcdedit /set hypervisorlaunchtype auto
# Reiniciar o PC após esse comando
```

> **Nota para jogadores:** Se você usa Valorant ou jogos com anti-cheat, o Hyper-V precisa estar desligado para jogar. Alterne com `bcdedit /set hypervisorlaunchtype off` + reiniciar quando for jogar, e reverta quando for desenvolver.

> **Importante:** Antes de qualquer comando Docker, verifique se o Docker Desktop está aberto e com o ícone da baleia ativo na bandeja do sistema (canto inferior direito do Windows). Se não estiver rodando, qualquer comando vai falhar com o erro `The system cannot find the file specified`.

---

## Passo 1 — Instalar a extensão Dev Containers no VS Code

Abra o VS Code, pressione `Ctrl+Shift+X`, pesquise `Dev Containers` e instale a extensão da Microsoft.

---

## Passo 2 — Criar a estrutura de pastas

Crie a seguinte estrutura. O nome da pasta raiz pode ser qualquer um — neste tutorial usamos `D:\claude-code\`:

```
D:\claude-code\
├── .devcontainer\
│   └── devcontainer.json
├── Dockerfile
├── docker-compose.yml
└── entrypoint.sh
```

---

## Passo 3 — Criar os arquivos

### `Dockerfile`

```dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Sistema base
RUN apt-get update && apt-get install -y \
    curl wget git vim nano build-essential \
    ca-certificates gnupg lsb-release \
    openssh-client zsh htop unzip \
    && rm -rf /var/lib/apt/lists/*

# Node.js (obrigatório pro Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Docker CLI (para o Claude Code controlar o DinD)
RUN curl -fsSL https://get.docker.com | sh

# Claude Code
RUN npm install -g @anthropic-ai/claude-code

WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

### `entrypoint.sh`

```bash
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
```

### `docker-compose.yml`

> **Atenção:** Não use `version:` no topo do arquivo — a versão atual do Docker Compose ignora esse campo e exibe um aviso. O arquivo começa direto com `services:`.

```yaml
services:
  claude-jail:
    build: .
    container_name: claude-jail
    hostname: claude-jail
    privileged: true
    stdin_open: true
    tty: true
    volumes:
      - workspace-data:/workspace
      - claude-config:/root/.claude
      - dind-storage:/var/lib/docker
    ports:
      - "8080-8090:8080-8090"
      - "3000:3000"
      - "8000:8000"
      - "5432:5432"
      - "3306:3306"
      - "6379:6379"
      - "27017:27017"
    restart: unless-stopped

volumes:
  workspace-data:
  claude-config:
  dind-storage:
```

> **Por que três volumes em vez de um único volume na raiz?** O Docker não permite montar um volume em `/` — isso resulta no erro `destination can't be '/'`. A solução é persistir os diretórios que realmente importam: projetos, configuração do Claude Code e imagens Docker internas.

### `.devcontainer/devcontainer.json`

```json
{
  "name": "claude-jail",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "claude-jail",
  "workspaceFolder": "/workspace",
  "remoteUser": "root",
  "shutdownAction": "none",
  "customizations": {
    "vscode": {
      "extensions": [
        "golang.go",
        "ms-python.python",
        "redhat.java",
        "ms-azuretools.vscode-docker",
        "eamodio.gitlens"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
      }
    }
  }
}
```

---

## Passo 4 — Build e primeiro boot

Abra o terminal do Windows na pasta do projeto e rode:

```powershell
docker compose up --build
```

> **Não use `-d`** no primeiro build — assim você vê os logs em tempo real e confirma que tudo subiu corretamente.

Aguarde 3 a 5 minutos. Quando terminar, aparecerá:

```
Iniciando Docker daemon...
Docker pronto.
```

O terminal vai mostrar também três opções — ignore todas:

```
v View in Docker Desktop   o View Config   w Enable Watch
```

O container está rodando. **Deixe esse terminal aberto** e siga para o próximo passo.

---

## Passo 5 — Conectar pelo VS Code

Abra o VS Code, pressione `Ctrl+Shift+P` e digite:

```
Dev Containers: Attach to Running Container
```

Selecione `claude-jail`. O VS Code vai abrir uma nova janela já dentro do Linux.

Para abrir o terminal integrado pressione `Ctrl+` ` ` (acento grave — a tecla abaixo do `Esc`).

Você verá o prompt do Linux:

```bash
root@claude-jail:/workspace#
```

> **Orientação no terminal Linux:** o símbolo antes do `#` indica onde você está.
> - `~` significa `/root` (pasta home do usuário root — equivale a `C:\Users\Administrador` no Windows)
> - `/` significa a raiz do sistema (equivale a `C:\` no Windows)
> - `/workspace` é onde seus projetos ficam
>
> Se você se perder, use `cd /workspace` para voltar ao lugar certo.

---

## Passo 6 — Autenticar o Claude Code com seu plano Pro

No terminal integrado, inicie o Claude Code:

```bash
cd /workspace
claude
```

Aparecerão algumas perguntas em sequência:

**Pergunta 1 — método de login:**
```
Select login method:
❯ 1. Claude account with subscription · Pro, Max, Team, or Enterprise
  2. Anthropic Console account · API usage billing
  3. 3rd-party platform · Amazon Bedrock, Microsoft Foundry, or Vertex AI
```
Selecione **1** — você tem plano Pro, o uso é coberto pela assinatura sem custo adicional por token.

**Pergunta 2 — configuração do terminal:**
```
Use Claude Code's terminal setup?
❯ 1. Yes, use recommended settings
  2. No, maybe later with /terminal-setup
```
Selecione **1** — configura o `Shift+Enter` para quebrar linha sem enviar a mensagem.

**Pergunta 3 — confiança na pasta:**
```
Accessing workspace: /workspace
Quick safety check: Is this a project you created or one you trust?
❯ 1. Yes, I trust this folder
  2. No, exit
```
Selecione **1** — é sua própria pasta, dentro do container isolado do seu Windows.

---

## Passo 7 — Resolver o problema de autenticação via browser

O Claude Code vai exibir uma URL para autorizar no browser:

```
Please open this URL in your browser:
https://claude.ai/oauth/authorize?...
```

Copie a URL, abra no navegador do Windows e clique em **Authorize**.

> **Problema conhecido com Dev Containers:** após clicar em Authorize, o browser tenta redirecionar para `localhost:PORTA` dentro do container — mas esse endereço não é acessível do Windows. O terminal fica aguardando e nada acontece.

**Solução:** após clicar em Authorize, olhe a barra de endereços do browser. Vai aparecer uma URL no formato:

```
http://localhost:39481/callback?code=XXXX&state=YYYY
```

Copie essa URL completa e execute no terminal do container com `curl`:

```bash
curl "http://localhost:39481/callback?code=XXXX&state=YYYY"
```

Para confirmar que funcionou:

```bash
ls -a ~
```

Se aparecer `.claude.json` na listagem, a autenticação foi bem-sucedida. O login fica salvo no volume `claude-config` — você só precisa fazer isso uma vez.

---

## Passo 8 — Tela inicial do Claude Code

Após a autenticação, o Claude Code abre com esta tela:

```
╭─── Claude Code v2.x.x ──────────────────────────────────────╮
│                                                              │
│              Welcome back [seu nome]!                        │
│                                                              │
│         Sonnet 4.6 · Claude Pro · seu@email.com              │
│                      /workspace                              │
╰──────────────────────────────────────────────────────────────╯
  ✻ Voice mode is now available · /voice to enable
```

Pressione **Enter** para continuar. Você está pronto.

---

## Passo 9 — Começar a usar o Claude Code

Com o Claude Code autenticado e rodando, você está pronto para desenvolver. Consulte os guias complementares para aproveitar o máximo:

- **[Guia Claude Code](guia-claude-code.md)** — modos de uso, instruções eficientes, CLAUDE.md, skills, gerenciamento de contexto e fluxo de trabalho completo
- **[Guia SDD](guia-sdd-claude-code.md)** — como desenvolver projetos reais com disciplina: TDD, CI, small releases, refactoring contínuo e specs que evoluem com o código

Comandos rápidos para referência:

```
/model     — trocar o modelo de IA (Sonnet ou Opus)
/voice     — ativar modo de voz
/clear     — limpar contexto e começar nova sessão
/help      — ver todos os comandos disponíveis
```

---

## Fluxo do dia a dia

```powershell
# 1. Abrir o Docker Desktop e aguardar a baleia ficar ativa na bandeja

# 2. Ligar o ambiente
cd D:\claude-code
docker compose up -d

# 3. Abrir o VS Code
# Ctrl+Shift+P → Dev Containers: Attach to Running Container → claude-jail

# 4. Abrir o terminal integrado
# Ctrl+` (acento grave — tecla abaixo do Esc)

# 5. Iniciar o Claude Code
cd /workspace
claude

# Ao terminar o dia — desligar o ambiente
docker compose stop
```

---

## Portas disponíveis no Windows

Qualquer aplicação que o Claude Code subir nessas portas estará acessível diretamente no seu Windows:

| Porta | Uso |
|-------|-----|
| 8080–8090 | APIs e aplicações (Go, Java Spring Boot, Python) |
| 3000 | Node.js / frontend |
| 8000 | Python (FastAPI, Django) |
| 5432 | PostgreSQL |
| 3306 | MySQL |
| 6379 | Redis |
| 27017 | MongoDB |

---

## O que persiste entre restarts

| O que | Volume | Persiste |
|-------|--------|----------|
| Projetos em `/workspace` | `workspace-data` | Sim |
| Login e configuração do Claude Code | `claude-config` | Sim |
| Imagens Docker internas | `dind-storage` | Sim |
| Pacotes instalados via `apt` | — | Não* |

> *Pacotes instalados pelo Claude Code via `apt` não persistem porque o sistema de arquivos base do container não é salvo em volume. Para linguagens que você sempre usa (Go, Java, Python), adicione-as ao `Dockerfile` e faça rebuild uma vez com `docker compose up --build`.

---

## Sobre autenticação — plano Pro vs API key

O Claude Code suporta dois modos:

- **Plano Pro via login (recomendado):** usa sua assinatura existente do claude.ai, sem custo adicional por token. Tem limite de uso mensal.
- **API key:** cobrança por token, sem limite fixo. Requer conta separada em console.anthropic.com.

Para desenvolvimento normal, o plano Pro é suficiente.

---

## Por que o VS Code no Windows executa tudo no Linux

O VS Code instala automaticamente um servidor dentro do container quando você conecta via Dev Containers. A janela do VS Code no Windows é apenas a interface visual — o terminal, os arquivos, as extensões e todo o código executam dentro do Linux no container. É a mesma experiência de estar na frente de uma máquina Linux, mas com a janela no seu Windows.

As extensões listadas no `devcontainer.json` são instaladas automaticamente no container na primeira conexão — é por isso que a extensão do Claude Code aparece sem você ter instalado manualmente.
