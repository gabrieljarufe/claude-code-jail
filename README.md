# Claude Code Jail

![GitHub repo size](https://img.shields.io/github/repo-size/gabrieljarufe/claude-code-jail?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/gabrieljarufe/claude-code-jail?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/gabrieljarufe/claude-code-jail?style=for-the-badge)
![GitHub open issues](https://img.shields.io/github/issues/gabrieljarufe/claude-code-jail?style=for-the-badge)
![GitHub License](https://img.shields.io/github/license/gabrieljarufe/claude-code-jail?style=for-the-badge)

Ambiente isolado para usar o Claude Code com poder total — sem risco para o seu sistema operacional.

Um container Docker com Linux completo onde o Claude Code opera como agente autônomo: instala dependências, sobe bancos de dados, cria projetos, roda testes e deploya — tudo confinado dentro do container, acessível pelo VS Code como se fosse uma máquina local.

Além do ambiente pronto, o projeto inclui três guias completos de setup, uso e metodologia — sem paywall.

---

## 💻 Pré-requisitos

- Docker Desktop (Windows/macOS) ou Docker Engine (Linux)
- VS Code com a extensão **Dev Containers** da Microsoft
- Conta no [claude.ai](https://claude.ai) com plano Pro, Max, Team ou Enterprise

> **Windows:** Hyper-V precisa estar ativo. Detalhes e nota sobre anti-cheat no [tutorial do container](docs/claude-code-container-tutorial.md#pré-requisitos).

---

## 🚀 Início rápido

```bash
# 1. Clone o repositório
git clone https://github.com/gabrieljarufe/claude-code-jail.git
cd claude-code-jail

# 2. Suba o container (primeiro build leva 3-5 minutos)
docker compose up --build

# 3. No VS Code: Ctrl+Shift+P (Cmd+Shift+P no macOS)
#    → "Dev Containers: Attach to Running Container" → claude-jail

# 4. No terminal integrado do container, clone o repo para popular o brain:
cd /workspace
git clone https://github.com/gabrieljarufe/claude-code-jail.git

# 5. Reinicie o container para ativar os symlinks do brain:
#    (no host) docker compose restart
#    (depois re-attach no VS Code)

# 6. No terminal do container:
cd /workspace
claude
```

> O passo 4 só é necessário na primeira vez. O conteúdo de `/workspace` persiste no volume `workspace-data` entre restarts.

Na primeira execução, o Claude Code vai pedir autenticação. Siga o [passo a passo completo](docs/claude-code-container-tutorial.md#passo-6--autenticar-o-claude-code-com-seu-plano-pro) se precisar de ajuda.

Pronto. A partir daqui, o Claude Code tem poder total — e o seu sistema está intocado.

---

## 🔄 Fluxo do dia a dia

```bash
# Ligar
docker compose up -d
# VS Code: Ctrl+Shift+P (Cmd+Shift+P no macOS) → Attach to Running Container → claude-jail
# Terminal: cd /workspace && claude

# Desligar
docker compose stop
```

Projetos, login e imagens Docker internas persistem automaticamente entre restarts.

---

## Por que usar um container?

O Claude Code é um agente que **executa comandos reais** no sistema operacional. Ele instala pacotes, cria e deleta arquivos, roda scripts, sobe serviços. Rodando direto na sua máquina, isso significa dar a uma IA acesso ao seu sistema inteiro.

Com o Claude Code Jail, o agente tem controle total — mas dentro de uma sandbox. Se algo der errado, você destrói o container e recria em minutos. Seus arquivos, seu sistema operacional e seus dados pessoais ficam intocados.

O que você ganha:

- **Segurança** — o agente não toca no seu sistema
- **Reprodutibilidade** — ambiente consistente, sempre igual
- **Liberdade** — o Claude Code pode instalar o que quiser sem pedir permissão
- **Persistência** — projetos, configuração e login sobrevivem a restarts
- **Docker-in-Docker** — o agente pode subir containers dentro do container (bancos, caches, APIs)

> Essa abordagem foi validada empiricamente no artigo de [Akita OnRails](https://akitaonrails.com/2026/02/20/do-zero-a-pos-producao-em-1-semana-como-usar-ia-em-projetos-de-verdade-bastidores-do-the-m-akita-chronicles/): 274 commits, 8 dias, sistema em produção.

> **Plataforma:** funciona em Windows, macOS e Linux — qualquer sistema que rode Docker + VS Code.

---

## 📚 Documentação

O projeto inclui três guias que se complementam. Leia na ordem sugerida:

### 1. [Setup do Container](docs/claude-code-container-tutorial.md)

Tudo sobre o ambiente Docker: como funciona o Dockerfile, os volumes, as portas expostas, a autenticação, o fluxo do dia a dia e o que persiste entre restarts. Comece por aqui se é a primeira vez.

**Cobre:** Dockerfile, docker-compose, Dev Containers, autenticação, Docker-in-Docker, portas, persistência.

### 2. [Guia Claude Code](docs/guia-claude-code.md)

Como usar o Claude Code de forma eficiente: os três modos de operação (conversa, bash, comandos), como dar boas instruções, gerenciamento de contexto, CLAUDE.md, skills reutilizáveis, Sonnet vs Opus, e fluxos de trabalho para projetos novos e existentes.

**Cobre:** modos de uso, instruções eficientes, `@` referências, CLAUDE.md, skills, `/clear`, `/compact`, Sonnet vs Opus, fluxo de trabalho.

### 3. [Guia SDD — Spec Driven Development](docs/guia-sdd-claude-code.md)

Como desenvolver projetos reais com disciplina de engenharia de software usando o Claude Code como par de pair programming. Baseado nas lições empíricas do projeto M.Akita Chronicles (274 commits, 8 dias, sistema em produção).

**Cobre:** divisão de papéis humano-agente, CI desde o commit zero, TDD como padrão, small releases, refactoring contínuo, segurança como hábito, specs que evoluem, checklists por commit/sessão/deploy.

---

## 🌐 Portas disponíveis

Aplicações rodando no container são acessíveis diretamente na sua máquina via `localhost`:

| Porta | Uso típico |
|-------|------------|
| 3000 | Node.js, frontend |
| 8000 | Python (FastAPI, Django) |
| 8080–8090 | APIs (Go, Java, etc.) |
| 5432 | PostgreSQL |
| 3306 | MySQL |
| 6379 | Redis |
| 27017 | MongoDB |

---

## 📁 Estrutura do projeto

```
claude-code-jail/
├── README.md                            ← você está aqui
├── Dockerfile                           ← imagem base do container
├── docker-compose.yml                   ← orquestração e volumes
├── entrypoint.sh                        ← inicialização do Docker-in-Docker
├── .devcontainer/
│   └── devcontainer.json                ← configuração do VS Code
└── docs/
    ├── claude-code-container-tutorial.md ← setup detalhado do ambiente
    ├── guia-claude-code.md              ← como usar o Claude Code
    └── guia-sdd-claude-code.md          ← como desenvolver com disciplina
```

---

## 📎 Referências

- [Artigo original do Akita OnRails](https://akitaonrails.com/2026/02/20/do-zero-a-pos-producao-em-1-semana-como-usar-ia-em-projetos-de-verdade-bastidores-do-the-m-akita-chronicles/) — a base empírica do guia SDD
- [Documentação oficial do Claude Code](https://docs.claude.com/en/docs/claude-code)
- [Extensão Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) — para conectar o VS Code ao container

---

## 🤝 Contribuindo

1. Fork este repositório
2. Crie sua branch: `git checkout -b minha-feature`
3. Faça suas alterações e commit: `git commit -m 'feat: minha feature'`
4. Envie para o remote: `git push origin minha-feature`
5. Abra um Pull Request

---

## 📝 Licença

MIT
