# Baixar do Instagram (`baixar-insta`)

Baixador de fotos, vídeos, carrosséis, stories, destaques e perfis inteiros do Instagram para Linux (Ubuntu/Debian), usando o navegador anti-detecção [camofox-browser](https://github.com/jo-inc/camofox-browser) em segundo plano e janelas simples via `zenity`.

---

## Instalação em um PC novo

Basta clonar o repositório e rodar o instalador:

```bash
mkdir -p ~/Projetos
git clone https://github.com/joaoluan/baixar-insta.git ~/Projetos/baixar-insta
cd ~/Projetos/baixar-insta
./install.sh
```

### O que o `./install.sh` faz sozinho:
1. Instala pacotes do sistema se faltarem (`python3`, `zenity`, `git`, `curl`, `xvfb`).
2. Localiza o **Node.js >= 22** (ou instala automaticamente o Node 24 via NVM se o PC não tiver).
3. Clona o `camofox-browser` em `~/Projetos/camofox-browser` e baixa o navegador Camoufox (`npm install`).
4. Cria o link `~/.local/bin/baixar-insta` apontando para o repositório.
5. Cria e ativa o serviço `~/.config/systemd/user/camofox.service` (`127.0.0.1:9377`, com telemetria desativada).
6. Cria os 2 ícones prontos para clicar na **Área de Trabalho** e no menu de aplicativos:
   - **Baixar do Instagram**
   - **Login Instagram (baixador)**

---

## Como usar

### 1. Conectar uma conta secundária (opcional, recomendado)
Sem login, o Instagram libera apenas posts/reels avulsos e os **12 posts mais recentes** de um perfil público.
Para baixar **stories, destaques e todos os posts** de um perfil:

1. Clique duas vezes no ícone **Login Instagram (baixador)** na Área de Trabalho (ou rode `~/.local/bin/baixar-insta --login`).
2. Uma janela real do navegador Camoufox vai abrir na tela de login do Instagram.
3. Entre em uma **conta secundária** (nunca use sua conta principal para automação).
4. Quando o feed carregar, clique em **OK** na janela de aviso do `zenity`.
5. O navegador fecha e salva a sessão autenticada em `~/.camofox/profiles/`.

### 2. Baixar pelo ícone da Área de Trabalho
1. Clique duas vezes em **Baixar do Instagram**.
2. Cole o link do Instagram:
   - **Post, Reel ou Carrossel**: `https://www.instagram.com/p/CODIGO/` ou `https://www.instagram.com/reel/CODIGO/`
   - **Story**: `https://www.instagram.com/stories/usuario/`
   - **Destaque**: `https://www.instagram.com/stories/highlights/ID/`
   - **Perfil inteiro**: `https://www.instagram.com/usuario/`
3. Ao terminar, clique em **Abrir pasta** para ver os arquivos baixados.

### 3. Baixar pelo terminal
```bash
# Abre a janela gráfica pedindo o link
~/.local/bin/baixar-insta

# Baixa um post/reel/story/perfil direto para ~/Downloads/Instagram/<usuario>
~/.local/bin/baixar-insta https://www.instagram.com/usuario/

# Escolhe outra pasta de destino
~/.local/bin/baixar-insta https://www.instagram.com/p/CODIGO/ ~/Imagens/Insta
```

---

## Onde cada coisa fica salva no PC

| Item | Caminho |
|------|---------|
| Código deste projeto | `~/Projetos/baixar-insta/` |
| Executável | `~/.local/bin/baixar-insta` |
| Motor Camoufox | `~/Projetos/camofox-browser/` |
| Serviço em segundo plano | `~/.config/systemd/user/camofox.service` |
| Sessão/cookies do login | `~/.camofox/profiles/` |
| Fotos e vídeos baixados | `~/Downloads/Instagram/<usuario>/` |

---

## Manutenção e Solução de Problemas

```bash
# Ver se o serviço do navegador está rodando
systemctl --user status camofox

# Reiniciar o navegador em segundo plano
systemctl --user restart camofox

# Ver logs do serviço
journalctl --user -u camofox -f

# Rodar os testes locais do script
python3 test_baixar_insta.py
```
