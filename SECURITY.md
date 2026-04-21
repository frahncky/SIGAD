# Security Policy

## Escopo

Este documento define como reportar vulnerabilidades no SIGAD.

## Como reportar

Nao abra vulnerabilidades em issues publicas.

Envie um relato contendo:
- descricao do problema
- impacto esperado
- passos para reproduzir
- versao/commit afetado
- evidencias (logs, screenshots, payloads sem dados sensiveis)

Canal sugerido para triagem privada:
- mantenedor do repositorio

## Tempo de resposta

Meta de triagem inicial:
- ate 5 dias uteis

Meta de atualizacao de status:
- semanal ate fechamento

## Boas praticas no projeto

- nao commitar segredos, tokens ou credenciais
- evitar logs com dados pessoais
- validar entradas de usuario e payload remoto
- tratar erros sem vazar detalhes sensiveis
- revisar regras de autorizacao por role

## Dependencias

- manter Flutter e pacotes atualizados
- revisar dependencias periodicamente

## Divulgacao responsavel

A correcao deve ser validada antes de divulgacao publica.

Quando necessario:
- publicar nota no CHANGELOG
- informar versao corrigida
