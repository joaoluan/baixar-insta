<!-- Mantenha este arquivo conciso. Procedimentos de uso estão no README.md. -->

# Instruções para agentes de IA (`baixar-insta`)

## O que este repositório é

Utilitário desktop e CLI (`baixar-insta`) para baixar fotos, vídeos, carrosséis, stories, destaques e perfis públicos do Instagram no Linux e no Windows, usando uma instância local do [`camofox-browser`](https://github.com/jo-inc/camofox-browser) (`127.0.0.1:9377`).

## Arquitetura essencial

- `baixar-insta` — Script único em Python 3 (apenas biblioteca padrão). Controla abas do Camoufox via HTTP local, extrai os objetos `image_versions2` e `video_versions` do JSON embutido na página (`<script type="application/json">`) e baixa a maior resolução disponível.
- `install.sh` — Instalador idempotente para Linux (Ubuntu/Debian): garante dependências via `apt`, Node.js >= 22 (sistema ou NVM), clona/instala `camofox-browser`, configura `~/.config/systemd/user/camofox.service` e cria atalhos `.desktop`.
- `install.ps1` — Instalador para Windows via PowerShell: garante Python 3, Node.js LTS e Git via `winget`, instala `camofox-browser` e cria atalhos `.lnk` na Área de Trabalho usando `pythonw.exe`.
- `test_baixar_insta.py` — Suíte `unittest` rápida e 100% offline (sem rede e sem abrir navegador).

## Invariantes obrigatórios

1. **Integridade do modo Linux**: O fluxo Linux (`zenity`, `systemctl --user start camofox` e `xdg-open`) é a referência de uso diário. Qualquer ajuste multiplataforma deve ficar isolado sob `IS_WIN` (`os.name == "nt"`), sem alterar o comportamento no Linux.
2. **Zero dependências externas no Python**: Usar exclusivamente a biblioteca padrão do Python 3 (`urllib`, `json`, `subprocess`, `re`, `glob`, `shutil`, `unittest`, `tkinter`/`ctypes`).
3. **Privacidade e Segurança (repositório público)**:
   - Sempre passar `CAMOFOX_BIND_HOST=127.0.0.1` e `CAMOFOX_CRASH_REPORT_ENABLED=false` ao iniciar o Camoufox (nunca expor a porta `9377`/`9378` na rede local nem enviar telemetria).
   - Nunca versionar cookies, sessões (`~/.camofox/profiles`), mídias baixadas, caminhos pessoais fixos (`/home/<usuario>`) ou dados de contas reais.
   - Sanitizar nomes de pastas e arquivos vindos do JSON (`username`, `code`, `pk`, `title` de destaques) contra path traversal (`..`, `/`, `\`) e gravação parcial (baixar em `.part` com timeout e renomear atomicamente com `os.replace`).
4. **Ritmo humano (anti-bloqueio)**: Preservar as pausas aleatórias (`random.uniform(3, 7)` entre itens e `2.5..4.5s` na rolagem) e o aviso de usar **conta secundária** no modo `--login`.

## Fluxo Git e Verificação

1. Criar branch a partir da `main` atualizada, manter commits pequenos e abrir PR em **draft** (`gh pr create --draft`).
2. Nunca fazer merge — apenas o usuário revisa e mescla.
3. Antes de qualquer commit ou push, validar obrigatoriamente:
   ```bash
   python3 -m unittest -v test_baixar_insta.py
   bash -n install.sh
   ```
