# Tarefa: Análise e melhoria da persistência do container

## Contexto

Este é o projeto `claude-code-jail` — um container Docker com Linux completo onde o Claude Code opera como agente autônomo. O projeto usa 3 named volumes para persistência, mas muita coisa se perde entre rebuilds (bashrc, envs, certificados, gitconfig, SSH keys, pacotes instalados).

## O que quero que você faça

### Fase 1 — Diagnóstico (não mude nada ainda)

1. Leia os arquivos: `docker-compose.yml`, `Dockerfile`, `entrypoint.sh`
2. Liste exatamente:
   - Quais volumes existem e o que cada um persiste
   - O que se perde quando faço `docker compose down && docker compose up --build`
   - O tamanho atual de cada volume (rode `du -sh` nos caminhos relevantes)
3. Liste os arquivos/diretórios em `/root/` que existem HOJE e identifique quais são efêmeros vs persistidos

### Fase 2 — Proposta (não execute ainda, só apresente)

Proponha uma solução que garanta que o container "lembra de tudo" entre restarts e rebuilds. Considere estas categorias:

- **Shell config:** `.bashrc`, `.zshrc`, aliases, env vars customizadas
- **Git config:** `.gitconfig`, SSH keys (`~/.ssh/`)
- **Certificados e credenciais:** CA certs, tokens
- **Configs do Claude Code:** já persistido em `/root/.claude` — verificar se está funcionando
- **Pacotes de sistema:** o que foi instalado via `apt-get` depois do build
- **Diretórios de trabalho:** `/workspace` e subdiretórios

Para cada categoria, diga qual estratégia usar:
- Volume Docker (para dados que mudam em runtime)
- Dockerfile (para dependências fixas)
- Git (para código e configs versionáveis)

Apresente as mudanças propostas no `docker-compose.yml` e `Dockerfile` como diff.

### Fase 3 — Checkpoint

**PARE AQUI e me mostre o diagnóstico + proposta.** Só execute as mudanças depois que eu confirmar.

## Restrições

- Mantenha compatibilidade com o fluxo VS Code + Dev Containers
- Não quebre o Docker-in-Docker (DinD)
- Priorize simplicidade: se Git resolve, não crie volume
- O resultado deve permitir que eu destrua e recrie o container perdendo o MÍNIMO possível