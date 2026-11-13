# Instruções para agentes de IA (`baixar-insta`)

## Visão geral

Utilitário desktop Linux para baixar mídias do Instagram (posts, reels, carrosséis, stories, destaques e perfis) usando uma instância local do `camofox-browser` (`127.0.0.1:9377`) e diálogos `zenity`.

## Arquivos principais

- `baixar-insta` — Script Python 3 (stdlib pura) com CLI + GUI `zenity` e modo `--login`.
- `install.sh` — Instalador idempotente (dependências, `camofox-browser`, `camofox.service` e atalhos `.desktop`).
- `test_baixar_insta.py` — Testes unitários do parser de URLs, extração de mídia JSON e resolução do binário `node`.

## Regras do repositório

1. Manter `baixar-insta` sem dependências externas de Python (apenas biblioteca padrão do Python 3).
2. Nunca habilitar telemetria no serviço `camofox` (`CAMOFOX_CRASH_REPORT_ENABLED=false` sempre ativo).
3. Nunca fazer commit de cookies, sessões (`~/.camofox/profiles`) ou mídias baixadas.
4. Rodar `python3 test_baixar_insta.py` e `bash -n install.sh` antes de qualquer commit/push.
