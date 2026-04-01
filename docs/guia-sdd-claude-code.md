# Guia SDD (Spec Driven Development) com Claude Code

> **Parte do projeto [Claude Code Jail](../README.md)** — veja também: [Setup do Container](claude-code-container-tutorial.md) · [Guia Claude Code](guia-claude-code.md)

## Guardrail permanente para projetos reais — do zero à produção

> Baseado nas lições empíricas do projeto M.Akita Chronicles (274 commits, 8 dias, 4 aplicações, 1.323 testes, sistema em produção) e no contra-exemplo FrankMD (212 commits, 19 dias, 6 cirurgias de refatoração).

> **Pré-requisitos de leitura:**
> - [Guia Claude Code](guia-claude-code.md) — funcionalidades gerais do Claude Code
> - [Setup do Container](claude-code-container-tutorial.md) — ambiente Docker
>
> Aqui não se repete o que está lá. Aqui se define **como trabalhar**.

---

## O que é SDD e por que importa com IA

SDD é o processo de construir software a partir de especificações que evoluem junto com o código. Não é waterfall — você não escreve uma spec de 50 páginas e entrega pro agente. É o oposto: você escreve specs pequenas, implementa, descobre o que faltou, atualiza a spec, e segue.

Com um agente de IA como o Claude Code, SDD ganha uma propriedade nova: a spec vira o mecanismo de controle do agente. Sem spec, o agente decide tudo sozinho — e ele decide mal em questões de arquitetura, priorização e segurança. Com spec, você mantém o controle sobre *o quê* e *o porquê*, enquanto o agente cuida do *como*.

A diferença prática entre SDD disciplinado e "vibe coding" está nos números:

| Abordagem | Commits/dia | Paradas forçadas | Testes | Resultado |
|-----------|-------------|-------------------|--------|-----------|
| Vibe coding (FrankMD) | 11 | 6 cirurgias grandes | Retroativos | Arquivo de 5.000 linhas, dívida técnica |
| SDD disciplinado (M.Akita) | 34 | 0 | Orgânicos (1.52x ratio) | Produção em 8 dias, zero paradas |

---

## Os 3 papéis na dinâmica humano-agente

Antes de qualquer código, internalize esta divisão:

**Você decide:**
- O quê construir (features, prioridades)
- Por quê construir (contexto de negócio, domínio)
- Quando parar (simplificar, cortar scope)
- O que está errado (revisar, interromper, redirecionar)

**O agente decide:**
- Como implementar (código, padrões, estrutura de arquivos)
- Como testar (edge cases, fixtures, mocks)
- Como refatorar (quando você pede — ele não refatora sozinho)

**Ninguém decide sozinho:**
- Arquitetura — o agente propõe, você simplifica
- Prompts de IA — você define personalidade, ele ajusta formato
- Integração com serviços externos — você traz conhecimento de domínio, ele implementa

A regra de ouro: quando você inverte os papéis (você ditando código exato, o agente apenas digitando), o resultado piora. Quando o agente decide o quê sem supervisão, o resultado também piora.

---

## Fase 0 — Antes de escrever qualquer código

### 0.1 Crie o CLAUDE.md inicial

> Para a estrutura básica do CLAUDE.md e como ele funciona, veja [Guia Claude Code — Parte 7](guia-claude-code.md#parte-7--claudemd-o-arquivo-mais-poderoso).

No contexto de SDD, o CLAUDE.md ganha uma responsabilidade extra: ele é a **spec viva** do projeto. Além da estrutura básica (stack, convenções, como rodar), adicione desde o início:

```markdown
## Hurdles conhecidos
- (adicione conforme encontrar problemas reais)

## Design patterns do projeto
- (adicione conforme os padrões emergirem)

## Pipeline
- (documente o fluxo de execução conforme ele se formar)
```

Esse arquivo não é escrito uma vez e esquecido. Ele cresce com o projeto. A cada sessão que revela algo novo (uma API que bloqueia HTTP clients simples, um LLM que suaviza opiniões, um serviço que exige headers específicos), documente no CLAUDE.md. O investimento retorna exponencialmente porque o agente realmente lê.

### 0.2 Defina o CI desde o commit zero

Antes da primeira feature, configure:

1. **Linter** — mantém estilo consistente (RuboCop, ESLint, golangci-lint)
2. **Análise de segurança** — pega vulnerabilidades antes do deploy (Brakeman, gosec, bandit)
3. **Testes** — rodam em cada commit, sem exceção
4. **Audit de dependências** — verifica vulnerabilidades conhecidas

O CI é o que permite velocidade. Sem ele, cada commit é uma aposta. Com ele, cada commit é validado automaticamente. São ~22 segundos por execução, mas multiplicado por centenas de commits, são horas de validação que você não precisa fazer manualmente.

Peça ao agente:

```
Configura o pipeline de CI para este projeto. Preciso de:
- Linter rodando antes dos testes
- Análise de segurança estática
- Audit de dependências
- Testes completos

Tudo deve rodar em cada commit. Se qualquer etapa falhar, o commit não passa.
```

### 0.3 Escreva a spec da primeira feature como user story

Não escreva "faz o sistema de usuários". Escreva:

```
Feature: Health check endpoint

Como operador do sistema,
quero um endpoint GET /health que retorne {"status": "ok", "timestamp": "..."},
para que o monitoramento saiba se a aplicação está viva.

Critérios de aceitação:
- Retorna 200 com JSON válido
- Inclui timestamp ISO 8601
- Tem teste cobrindo o happy path
- Passa no CI completo
```

Essa spec é pequena de propósito. A primeira feature serve para validar que o pipeline inteiro funciona: código → teste → CI → deploy.

---

## Fase 1 — O ciclo de desenvolvimento

### 1.1 Uma feature por sessão

Cada sessão do Claude Code deve ter um objetivo claro e limitado. Quando terminar, `/clear` e comece nova sessão.

Motivos:
- O contexto cresce e fica caro
- Sessões longas fazem o agente "esquecer" decisões do início
- Cada feature terminada é um commit production-ready

Padrão da sessão:

```
1. Descreva a feature (spec pequena, critérios claros)
2. Peça um plano antes de implementar
3. Revise o plano — simplifique se necessário
4. Execute
5. Rode os testes
6. Rode o CI
7. Revise o código gerado
8. Commit
9. /clear
```

### 1.2 Peça plano antes de execução

Para qualquer feature que não seja trivial:

```
Antes de implementar, me mostra um plano detalhado de como
você vai fazer [descrição da feature].

Não começa a codar ainda.
```

Revise o plano. Os pontos mais comuns de intervenção:

- **Over-engineering** — o agente adora state machines com 8 estados, retry queues separadas, dead letter handling. Seu trabalho é dizer: "Simplifica. Quatro estados bastam. Na dúvida, não reenvia."
- **Abstrações prematuras** — se ele propõe uma interface genérica para algo que só tem um caso de uso, corte.
- **Dependências desnecessárias** — questione cada biblioteca externa. Menos dependências = menos superfície de ataque.

### 1.3 TDD como padrão, não exceção

Peça testes junto com a implementação, sempre. Não depois.

```
Implementa [feature] com testes. Quero ver os testes passando
antes de considerar pronto.
```

O ratio alvo é mais linhas de teste do que de código (1.5x é um bom benchmark). Isso não é vaidade — é a infraestrutura que permite velocidade. Com 1.323 testes como rede de segurança, o agente modifica código com confiança. Sem testes, cada mudança é uma aposta.

O que os testes devem cobrir:
- Happy path (o caso normal funciona)
- Edge cases (entrada vazia, nula, muito grande)
- Casos de erro (API fora do ar, timeout, resposta inesperada)
- Regressões (bugs que já foram corrigidos não voltam)

O que não precisa de 100% de coverage:
- Integração com APIs externas — use mocks
- UI boilerplate — teste a lógica, não o HTML

O coverage real em lógica de negócio deve estar acima de 95%. O coverage geral vai ficar em 82-87% — e isso é saudável.

### 1.4 Small releases — cada commit é production-ready

Nunca faça "commit quebrando que vai ser consertado no próximo". Cada commit em master passa no CI, tem testes, e pode ir pra produção.

Se a feature é grande demais para um commit:
- Quebre em partes menores que funcionam independentemente
- Cada parte tem seus próprios testes
- Cada parte passa no CI sozinha

Isso permite reverter um commit sem afetar outros. Se a feature era má ideia, nunca dependeu de outra.

### 1.5 Interrompa o agente quando necessário

Você não é espectador. Interrompa quando:

- **Ele está over-engineering** — "Para, isso tá ficando complicado demais. Simplifica."
- **Ele está no caminho errado** — "Espera. Yahoo faz TLS fingerprinting, vai bloquear qualquer HTTP client que não seja browser real."
- **Ele está adicionando complexidade desnecessária** — "Não precisa de uma abstração pra isso. Implementa direto."
- **Ele está ignorando contexto de domínio** — "O LLM vai suavizar opiniões se você não for explícito. Precisa de instruções mais agressivas no prompt."

O agente nunca diz "não". Isso é um bug, não uma feature. Se você pede algo over-engineered, ele implementa com entusiasmo. Se pede algo inseguro, ele implementa sem reclamar. Você é o freio. Você é o code review. Você é o adulto na sala.

---

## Fase 2 — Refactoring contínuo

### 2.1 Refatore durante o desenvolvimento, não depois

O erro clássico (demonstrado pelo FrankMD): construir-construir-construir e depois parar tudo pra refatorar. Isso produz arquivos de 5.000 linhas e cirurgias de emergência.

O padrão correto: a cada 3-5 features novas, pare e pergunte:

```
Olha o código que temos até agora. Tem duplicação que deveria
ser extraída? Tem arquivo ficando grande demais? Tem abstração
que simplificaria a interface?
```

Refatorações típicas que o agente faz bem (em minutos, não horas):
- Extrair código duplicado para um concern/módulo/helper
- Colapsar métodos copy-paste em um método parametrizado
- Mover lógica do controller para um service
- Renomear para consistência

Refatorações que precisam da sua decisão:
- *O que* extrair e *como* a interface deveria ser
- Quando substituir uma abstração por outra mais simples
- Quando trocar uma dependência por outra

### 2.2 O teste de saúde do código

Sinais de que você precisa refatorar agora:
- Qualquer arquivo com mais de 300 linhas
- Mesmo trecho de código aparecendo em 3+ lugares
- Um módulo que faz duas coisas sem relação entre si
- Testes que precisam de setup muito longo

Sinais de que pode esperar:
- Código funciona, tem testes, mas não está "bonito"
- Naming não é perfeito mas é compreensível
- Uma abstração poderia ser mais elegante mas não causa problemas

---

## Fase 3 — Segurança como hábito

### 3.1 Segurança não é fase — é cada commit

Não existe "sprint de segurança no final". O scanner de segurança roda em cada commit. Vulnerabilidades são corrigidas no momento que aparecem.

Checklist de segurança por commit:
- O scanner de segurança passou sem warnings?
- Há input do usuário chegando em queries SQL? (SQL injection)
- Há input do usuário em paths de arquivo? (path traversal)
- Há redirects baseados em input do usuário? (open redirect)
- Há chamadas HTTP para URLs fornecidas pelo usuário? (SSRF)

### 3.2 O que o agente não faz por conta própria

O agente implementa o que você pede, mas raramente sugere proteções que você não pediu. Você precisa pedir explicitamente:

```
Revisa essa implementação do ponto de vista de segurança.
Especificamente, verifica:
- SSRF em qualquer chamada HTTP
- Rate limiting nos endpoints públicos
- CSP headers
- Encryption at rest para dados sensíveis
- CSRF protection
```

---

## Fase 4 — Evolução da spec

### 4.1 O CLAUDE.md como spec viva

A cada sessão produtiva, atualize o CLAUDE.md com:

- **Novos hurdles** — "Yahoo Finance precisa de headless Chromium com crumb authentication porque faz TLS fingerprinting"
- **Design patterns do projeto** — "Todos os scrapers herdam de BaseScraper e implementam #fetch e #parse"
- **Variáveis de ambiente novas** — documentar cada env var adicionada
- **Pipeline atualizado** — se o fluxo de execução mudou, documentar

Peça ao agente:

```
Atualiza o CLAUDE.md com o que aprendemos nessa sessão.
Adiciona na seção de hurdles/patterns o que for relevante.
```

### 4.2 Features que emergem da iteração

Algumas das features mais importantes não estavam no plano original. Elas nascem quando o sistema encontra a realidade:

- Uma newsletter sai com seção vazia → nasce o ContentPreflight (validação antes do envio)
- Um crash no meio do envio deixa emails em limbo → nasce o RecoverStaleDeliveriesJob
- Um site bloqueia HTTP requests simples → nasce o StealthBrowser

Nenhuma spec do mundo prevê isso. O sistema correto emerge da iteração, não da especificação. O papel da spec é documentar o que emergiu, não prever tudo antecipadamente.

### 4.3 Prompt engineering iterativo

Se o projeto usa LLMs internamente (geração de conteúdo, chatbots, etc.), os prompts são código e devem ser tratados como tal:

- Cada ajuste de prompt é um commit
- Teste com dados reais, não com exemplos inventados
- Documente as personalidades e restrições no CLAUDE.md
- Seja explícito — "Akita nunca diz 'talvez'. Marvin usa 'bom…' e 'enfim'." — porque o LLM vai suavizar tudo se você não instruir com precisão

---

## Fase 5 — Decisões de arquitetura

### 5.1 Quando o agente propõe, você simplifica

O padrão mais comum: o agente propõe uma solução over-engineered e você corta.

Exemplo real: sistema de email delivery. Proposta do agente: state machine com 8 estados, retry queues separadas, dead letter handling. Resultado após intervenção: 4 estados (pending, sending, sent, unknown), 40 linhas, resolve o problema inteiro.

Perguntas para avaliar a proposta do agente:
- Quantos estados/modos/configurações essa solução tem? Se mais de 4-5, provavelmente é demais.
- Isso resolve um problema que *temos* ou um problema que *poderíamos ter*?
- Se eu cortasse metade dessa complexidade, o que quebraria? Se nada, corte.

### 5.2 Traga conhecimento de domínio

O agente não sabe que:
- O Yahoo faz TLS fingerprinting
- O Morningstar bloqueia HTTParty
- O modelo de voz do Qwen produz sotaque europeu
- O Gmail exige List-Unsubscribe desde fevereiro de 2024

Esse tipo de conhecimento vem de experiência e de tentar e falhar. Quando você sabe algo que o agente não sabe, diga antes que ele tome o caminho errado. Isso economiza commits de correção.

### 5.3 Cada linguagem no que faz melhor

Se o projeto envolve múltiplas linguagens, use cada uma no que faz melhor. Exemplo real: Rails orquestra, Python serve TTS via HTTP, conteúdo integra por filesystem. Não force uma linguagem a fazer o trabalho de outra.

---

## Checklist por commit

Antes de cada commit, verifique mentalmente:

```
[ ] O CI passou? (linter + segurança + testes)
[ ] Esse commit funciona sozinho? (não depende de um "próximo commit")
[ ] Tem testes para o que foi adicionado/modificado?
[ ] O CLAUDE.md precisa ser atualizado?
[ ] Tem código duplicado que deveria ser extraído?
[ ] Tem arquivo ficando grande demais?
```

---

## Checklist por sessão

Antes de dar `/clear`:

```
[ ] A feature está completa e testada?
[ ] O CI passou no último commit?
[ ] Descobri algum hurdle novo? Se sim, documentei no CLAUDE.md?
[ ] Tem refatoração pendente que deveria fazer agora?
[ ] O que vou fazer na próxima sessão está claro?
```

---

## Checklist pós-implementação (antes de ir pra produção)

```
[ ] Todos os testes passam?
[ ] Coverage de lógica de negócio acima de 95%?
[ ] Scanner de segurança sem warnings?
[ ] CLAUDE.md atualizado com a arquitetura final?
[ ] Variáveis de ambiente documentadas?
[ ] Pipeline de deploy testado?
[ ] Monitoramento configurado? (health check no mínimo)
[ ] Backups configurados para dados que importam?
```

---

## Anti-padrões — o que não fazer

### "Faz tudo de uma vez"
Nunca peça: "Faz o sistema de auth, produtos, pedidos, pagamentos e relatórios." Isso gera código inconsistente, sem testes adequados, e impossível de revisar.

### "Testes depois"
Testes retroativos cobrem o happy path e nada mais. TDD orgânico pega bugs reais durante o desenvolvimento. No projeto FrankMD, a cobertura teve que ser empurrada de 77% pra 89% num commit tardio de "preencher buracos".

### "Refatora depois"
Quando um arquivo chega a 5.000 linhas, o refactoring não é mais "extrair um concern em 2 minutos". É uma cirurgia de emergência que leva horas e introduz riscos proporcionais ao tamanho da mudança.

### "O agente sabe o que é melhor"
O agente executa qualquer coisa com igual entusiasmo. Não diz "isso é perda de tempo" ou "faça X antes de Y". Não prioriza. Não questiona. Se você pede algo inseguro, ele faz sem reclamar. A responsabilidade é sua.

### "One-shot prompt"
Escrever uma spec detalhada, entregar pro agente e esperar o sistema pronto. Isso produz protótipos sem testes, sem segurança, sem tratamento de erros, sem deploy. Só 37% dos commits de um projeto real são features — o resto é o trabalho que faz software de verdade.

### "Vibe coding é engenharia"
274 commits com CI, testes, security scanning e small releases é o oposto de vibe coding. É engenharia de software com um copiloto que digita rápido. Sem essa disciplina, o mesmo desenvolvedor com o mesmo agente produz resultados drasticamente piores.

---

## O multiplicador real

O agente de IA não é "10x mais código". É a eliminação do tempo morto. Sem agente, 70% do tempo vai em digitar boilerplate, ler docs de API, escrever testes mecânicos, debugar typos. Com agente, esse tempo vira zero e o foco vai 100% para decisões de arquitetura, domínio e qualidade.

Mas isso só funciona se o processo for sólido. O mesmo desenvolvedor com o mesmo agente produziu:
- **Com disciplina:** 34 commits/dia, zero paradas forçadas, produção em 8 dias
- **Sem disciplina:** 11 commits/dia, 6 cirurgias de emergência, 19 dias

A variável não é a IA. É o processo.

> *"A IA é seu espelho — ela revela mais rápido quem você é. Se for incompetente, vai produzir coisas ruins mais rápido. Se for competente, vai produzir coisas boas mais rápido."*
