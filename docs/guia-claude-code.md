# Guia Completo — Claude Code

> **Parte do projeto [Claude Code Jail](../README.md)** — veja também: [Setup do Container](claude-code-container-tutorial.md) · [Guia SDD](guia-sdd-claude-code.md)

## Do básico ao avançado, do mais importante ao menos importante

---

## Parte 1 — O que é o Claude Code e como ele pensa

O Claude Code não é um assistente de chat que escreve código para você copiar e colar. Ele é um **agente autônomo** que opera no seu sistema de arquivos. A diferença é fundamental:

- Um assistente de chat **sugere** — você implementa
- O Claude Code **age** — ele lê, escreve, executa e corrige sozinho

Quando você diz *"cria uma API REST em Go"*, ele vai:
1. Criar a estrutura de pastas
2. Escrever os arquivos
3. Instalar dependências
4. Tentar rodar
5. Ver os erros
6. Corrigir
7. Testar de novo

Tudo isso sem você precisar fazer nada. Seu papel é **dar direção e revisar**.

---

## Parte 2 — Os três modos de uso

### Modo conversa (o mais comum)

Simplesmente escreva o que quer em português:

```
❯ Cria um projeto Go com uma API REST, endpoint /health que retorna JSON
```

O Claude Code vai pensar, planejar e executar. Você acompanha tudo em tempo real.

### Modo bash (`!`)

Executa comandos shell direto, sem passar pela IA. **Não consome tokens.**

```
❯ ! ls -la
❯ ! docker ps
❯ ! cat arquivo.go
```

Útil para inspecionar o ambiente sem gastar créditos.

### Modo comando (`/`)

Acessa funções internas do Claude Code:

```
/help          — lista todos os comandos
/model         — troca o modelo de IA
/clear         — limpa o contexto da conversa
/status        — mostra uso de tokens da sessão
/cost          — mostra custo da sessão (se usando API key)
/keybindings   — personaliza atalhos
/voice         — ativa modo de voz
```

---

## Parte 3 — Como você é cobrado

### Se usa plano Pro/Max via login (recomendado)

Você **não paga por token** — o uso do Claude Code está incluído na sua assinatura mensal do claude.ai.

O que existe é um **limite de uso mensal** que varia conforme o plano:
- **Pro** — uso moderado, suficiente para desenvolvimento normal
- **Max** — limite muito maior, para uso intenso e sessões longas

Quando você atinge o limite, o Claude Code para de responder até o ciclo mensal renovar.

### Se usa API key (console.anthropic.com)

Você paga por token consumido. Tokens são as unidades de texto que a IA processa:

| Ação | Consome token? |
|------|---------------|
| Escrever uma mensagem para a IA | Sim |
| Receber resposta da IA | Sim |
| `! comando bash` | Não |
| Navegar menus, `/help`, `Esc` | Não |
| Arquivos que o Claude Code lê para contexto | Sim |

O custo real depende do modelo:
- **Sonnet** — mais rápido, mais barato, ótimo para tarefas do dia a dia
- **Opus** — mais lento, mais caro, melhor para decisões arquiteturais complexas

### Como ver o custo da sessão

```
/cost
```

Mostra quantos tokens foram usados e o custo estimado da sessão atual.

---

## Parte 4 — Contexto: o conceito mais importante

**Contexto** é tudo que o Claude Code tem em memória numa sessão. Quanto maior o contexto, mais caro e mais lento fica.

O contexto de uma sessão inclui:
- Toda a conversa até agora
- Os arquivos que ele leu
- Os outputs dos comandos que rodou

### Como gerenciar contexto

**`/clear`** — limpa toda a conversa e começa do zero. Use quando:
- Você terminou uma tarefa e vai começar outra diferente
- A sessão ficou longa demais e ele está "esquecendo" coisas do início
- Você quer economizar tokens

**`/compact`** — resume o contexto atual sem perder o essencial. Use quando:
- Quer continuar o trabalho mas a sessão está ficando pesada

**Regra prática:** uma sessão por tarefa. Terminou a feature, `/clear`, começa nova sessão para a próxima.

---

## Parte 5 — Como dar boas instruções

A qualidade do resultado depende diretamente de como você instrui.

### Instruções vagas — resultado mediano

```
❯ Faz uma API
```

### Instruções específicas — resultado muito melhor

```
❯ Cria uma API REST em Go usando gin framework
  com os endpoints:
  - GET /users — lista usuários
  - POST /users — cria usuário
  - GET /users/:id — busca por ID

  Usa PostgreSQL para persistência.
  Inclui docker-compose.yml com a aplicação e o banco.
  Inclui um arquivo README com instruções de como rodar.
```

### Dicas para boas instruções

- **Especifique a stack** — linguagem, framework, banco de dados
- **Liste os requisitos** — o que deve fazer, não como fazer
- **Mencione restrições** — "sem bibliotecas externas", "compatível com Go 1.21"
- **Peça o que você quer junto** — testes, docker, readme, na mesma instrução
- Use `Shift+Enter` para quebrar linha e escrever instruções longas antes de enviar

---

## Parte 6 — Referenciando arquivos com `@`

O `@` permite referenciar arquivos específicos do projeto sem precisar copiar o conteúdo:

```
❯ @src/main.go tem um bug na linha 45, consegue identificar e corrigir?
```

```
❯ Olha o @docker-compose.yml e adiciona um serviço de Redis
```

```
❯ Refatora @src/handlers/user.go para seguir o padrão do @src/handlers/product.go
```

Isso é muito mais eficiente do que descrever o arquivo — o Claude Code lê o conteúdo real.

---

## Parte 7 — CLAUDE.md: o arquivo mais poderoso

O `CLAUDE.md` é um arquivo que você cria na raiz do projeto. O Claude Code **lê automaticamente** esse arquivo no início de cada sessão — é como uma instrução permanente que você não precisa repetir toda vez.

Crie em `/workspace/CLAUDE.md`:

```markdown
# Instruções do projeto

## Stack
- Linguagem: Go 1.23
- Framework HTTP: gin
- Banco de dados: PostgreSQL 16
- Cache: Redis 7
- Infraestrutura: Docker Compose

## Convenções de código
- Todos os handlers ficam em /internal/handlers
- Toda lógica de negócio em /internal/services
- Erros sempre retornam JSON no formato: {"error": "mensagem"}
- Testes obrigatórios para toda função de serviço

## Como rodar
- `docker compose up -d` para subir a infra
- `go run ./cmd/api` para iniciar a aplicação
- `go test ./...` para rodar os testes

## O que não fazer
- Não usar ORM — SQL puro com pgx
- Não commitar credenciais
- Não criar arquivos na raiz do projeto
```

Com esse arquivo, você não precisa repetir a stack e as convenções em cada sessão. O Claude Code já sabe como o projeto funciona.

---

## Parte 8 — Skills: ensinando o Claude Code a trabalhar do seu jeito

Skills são instruções reutilizáveis que você cria para tarefas que se repetem. Em vez de explicar como fazer algo toda vez, você cria uma skill uma vez e referencia sempre que precisar.

### Onde ficam as skills

O Claude Code lê automaticamente arquivos `.md` em:

```
/workspace/.claude/
├── skills/
│   ├── criar-endpoint.md
│   ├── criar-migration.md
│   └── review-codigo.md
└── CLAUDE.md
```

### Exemplo de skill — criar endpoint

Crie `/workspace/.claude/skills/criar-endpoint.md`:

```markdown
# Skill: criar endpoint

Quando pedido para criar um novo endpoint, sempre:

1. Criar o handler em /internal/handlers/nome.go
2. Criar o service em /internal/services/nome.go
3. Criar o repository em /internal/repository/nome.go
4. Registrar a rota em /internal/routes/routes.go
5. Criar teste em /internal/handlers/nome_test.go
6. Atualizar o README com a documentação do endpoint

Padrão de response de sucesso:
{"data": {}, "message": ""}

Padrão de response de erro:
{"error": "mensagem do erro"}
```

Agora quando você diz *"cria o endpoint de produtos seguindo nossa skill"*, ele segue exatamente esse padrão sem você precisar repetir.

### Como acumular skills ao longo do tempo

Sempre que você perceber que está repetindo uma instrução, transforme em skill:

1. Terminou uma tarefa e ficou satisfeito com o resultado
2. Peça: *"Documenta como você fez isso numa skill em .claude/skills/"*
3. Ele cria o arquivo automaticamente
4. Na próxima vez, você referencia a skill

Com o tempo, o Claude Code vai aprender cada vez mais como você gosta de trabalhar.

---

## Parte 9 — Modos avançados de operação

### Modo planejamento — antes de agir

Para tarefas grandes, peça um plano antes de executar:

```
❯ Antes de implementar, me mostra um plano detalhado de como você vai
  adicionar autenticação JWT nessa API
```

Você revisa o plano, ajusta o que não gostou, depois diz *"pode executar"*.

### Modo revisão — depois de agir

Depois que ele implementar algo:

```
❯ Revisa o que você acabou de implementar e me diz se tem algo
  que poderia ser melhorado em termos de performance ou segurança
```

### Modo debug — quando algo quebra

```
❯ O teste em handlers/user_test.go está falhando com esse erro:
  [cola o erro]
  Analisa a causa raiz e corrige
```

### Tarefas em background com `&`

Para tarefas longas que você quer rodar enquanto continua trabalhando:

```
❯ & rode todos os testes e me avisa quando terminar
```

---

## Parte 10 — Como usar Sonnet vs Opus

### Use Sonnet (padrão) para

- Criar arquivos e estruturas de projeto
- Implementar features bem definidas
- Corrigir bugs com erro claro
- Refatorações simples
- Escrever testes
- Tarefas do dia a dia em geral

### Troque para Opus quando

- A decisão arquitetural é complexa e tem múltiplos tradeoffs
- O bug é difícil de reproduzir e tem causas não óbvias
- Você precisa que ele entenda um sistema grande e tome decisões coerentes
- Sessões longas de desenvolvimento autônomo onde erros custam caro

Para trocar:

```
/model
```

Ou use `Meta+P` (Alt+P no Windows).

---

## Parte 11 — Fluxo de trabalho recomendado

### Para um projeto novo

```
1. Crie o CLAUDE.md descrevendo a stack e convenções
2. Peça um plano antes de implementar
3. Revise o plano e ajuste
4. Execute em partes — não peça tudo de uma vez
5. Teste cada parte antes de seguir
6. Ao terminar uma feature, /clear para nova sessão
```

### Para um projeto existente

```
1. Abra o projeto em /workspace/meu-projeto
2. Peça: "Leia o projeto e me dê um resumo do que está aqui"
3. Ele vai mapear a estrutura antes de agir
4. Crie um CLAUDE.md baseado no que ele encontrar
5. Trabalhe em features isoladas com sessões separadas
```

### Para manutenção

```
1. Descreva o problema claramente
2. Cole o erro se houver
3. Referencie os arquivos relevantes com @
4. Peça análise antes de correção
```

---

## Parte 12 — O que evitar

**Sessões muito longas sem `/clear`**
O contexto cresce, fica caro e ele começa a perder coerência.

**Instruções vagas em tarefas grandes**
*"Faz o sistema de usuários"* é vago demais. Especifique o que o sistema de usuários deve fazer.

**Não revisar antes de continuar**
Sempre leia o que ele implementou antes de pedir a próxima tarefa. Um erro no início se propaga para tudo que vem depois.

**Pedir tudo de uma vez**
*"Faz o sistema de auth, produtos, pedidos, pagamentos e relatórios"* é uma instrução que vai gerar código inconsistente. Feature por feature, sessão por sessão.

---

## Resumo rápido — referência do dia a dia

```
# Começar uma sessão
cd /workspace/meu-projeto
claude

# Comandos mais usados
/clear         — nova sessão (use entre tarefas diferentes)
/model         — trocar Sonnet/Opus
/status        — ver uso de tokens
! comando      — bash direto sem IA
@ arquivo      — referenciar arquivo no prompt
Shift+Enter    — quebrar linha no prompt
Ctrl+C         — interromper o que ele está fazendo

# Arquivos importantes
CLAUDE.md                    — instruções permanentes do projeto
.claude/skills/              — skills reutilizáveis

# Ordem de aprendizado sugerida
1. Dar instruções em português e ver o que acontece
2. Usar @ para referenciar arquivos
3. Criar o CLAUDE.md do seu projeto
4. Criar suas primeiras skills
5. Aprender a usar /clear estrategicamente
6. Experimentar Sonnet vs Opus
7. Explorar modo background com &
```
