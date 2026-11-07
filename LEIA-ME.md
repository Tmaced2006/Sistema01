# Programação de Manutenção (PCM)

Sistema para o PCM programar as atividades da semana e para mecânicos, eletricistas e equipe predial registrarem, pelo celular, se terminaram o serviço e o que encontraram. Cada pessoa entra com a própria matrícula e PIN e vê só as suas atividades.

Tem duas partes que rodam juntas num único programa:

- **Frontend** (`frontend/`): as telas, que abrem no navegador do celular ou do computador.
- **Backend** (`backend/`): o servidor, que guarda tudo num banco de dados MySQL, confere o login e aplica as regras de quem pode ver e mexer em quê.

## O que cada pessoa faz

| Quem | O que vê e faz |
|---|---|
| **PCM** | Programa, edita e exclui atividades. Vê a semana inteira, o andamento de cada pessoa e as observações. Cadastra a equipe, troca PIN e desativa usuários. |
| **Mecânico, Eletricista, Predial** | Vê só as atividades em que é o responsável. Marca **Finalizada** ou **Ainda não finalizada** e escreve uma observação. |

Atividades não concluídas de semanas anteriores aparecem em vermelho como **atrasadas**, para nada se perder. Cada mudança de situação fica no histórico da atividade, com quem fez e quando.

## Estrutura das pastas

```
sistema-pcm/
├── frontend/              as telas
│   ├── index.html
│   ├── css/estilos.css
│   └── js/                util.js (apoio) · api.js (fala com o servidor) · app.js (telas)
├── backend/
│   ├── src/               servidor, banco, login e rotas
│   └── scripts/backup.js  cópia de segurança (usa o mysqldump do MySQL)
├── banco/criar-banco.sql  cria o banco, o usuário e as tabelas no MySQL
├── configuracao.env       dados de conexão com o MySQL (você edita)
├── tests/api.test.js      testes automáticos do servidor
├── data/                  criada sozinha: segredo do login e backups
├── iniciar.bat            liga o sistema no Windows (duplo clique)
├── iniciar.sh             liga o sistema no Linux ou Mac
└── package.json
```

## Passo a passo: rodar no computador da empresa

O sistema fica ligado num computador (ou servidor) da empresa e todos acessam pela rede interna, pelo celular no Wi-Fi. O MySQL pode ficar no mesmo computador ou em outro.

### A. Preparar o MySQL (uma vez só)

1. **Instale o MySQL 8** (Windows: "MySQL Installer" em `dev.mysql.com/downloads/installer`, opção *Server only*; Ubuntu: `sudo apt install mysql-server`). Anote a senha do usuário `root` que você definir.
2. **Abra o arquivo `banco/criar-banco.sql` no Bloco de Notas** e troque `troque-esta-senha` (aparece 2 vezes) por uma senha sua. Salve.
3. **Rode o script.** No Windows, abra o **MySQL 8.0 Command Line Client** pelo menu Iniciar, digite a senha do `root` e rode (use `/` nas barras do caminho):
   ```
   source C:/sistema-pcm/banco/criar-banco.sql
   ```
   Em Linux/Mac, dentro da pasta do sistema: `mysql -u root -p < banco/criar-banco.sql`.
4. **Abra o arquivo `configuracao.env`** e coloque, em `DB_PASSWORD`, a mesma senha do passo 2. Se o MySQL estiver em outro computador, troque `DB_HOST` pelo endereço dele.

### B. Ligar o sistema

1. **Instale o Node.js** em `nodejs.org`, versão **18 ou mais nova** (a LTS atual serve).
2. **Copie a pasta `sistema-pcm`** para o computador que vai ficar ligado.
3. **Ligue o sistema**:
   - Windows: dê duplo clique em `iniciar.bat`. Na primeira vez ele instala o que precisa (precisa de internet).
   - Linux ou Mac: no terminal, dentro da pasta, rode `sh iniciar.sh`.
4. Quando aparecer **"Programação de Manutenção no ar"**, abra `http://localhost:3000` no navegador desse computador. Se aparecer "NÃO FOI POSSÍVEL CONECTAR AO BANCO DE DADOS", leia a explicação logo abaixo da mensagem (ela diz se o problema é MySQL desligado, senha errada ou banco inexistente).
5. **Crie o acesso do PCM** (nome, matrícula e PIN de 4 a 8 números). Faça isso antes de passar o endereço para a equipe: quem criar o primeiro acesso vira o PCM. Depois disso a tela de configuração não aparece mais.
6. Na aba **Equipe**, cadastre cada pessoa com nome, matrícula, função e PIN inicial.
7. **Acesso pelo celular:** descubra o endereço do computador na rede (no Windows, abra o Prompt de Comando e rode `ipconfig`; procure "Endereço IPv4", algo como `192.168.0.25`). No celular, conectado ao mesmo Wi-Fi, abra `http://192.168.0.25:3000`. Se não abrir, o firewall do computador pode estar bloqueando a porta 3000: peça ao TI para liberar. No celular, use "Adicionar à tela inicial" para virar um ícone.

Para desligar, feche a janela do `iniciar.bat` (ou `Ctrl+C` no terminal). O computador e o MySQL precisam ficar ligados para o pessoal usar.

## Colocar na internet (para acessar fora da empresa)

Você precisa de uma hospedagem que rode Node.js **e** de um MySQL acessível por ela (um MySQL gerenciado do próprio provedor, ou um instalado no mesmo servidor virtual). Como o banco fica no MySQL, o disco da hospedagem não precisa ser permanente para os dados, só para o segredo do login (ou defina `JWT_SECRET`).

O que importa em qualquer uma:

- **Comando de início:** `npm start`. Instalação: `npm install --omit=dev`.
- **Variáveis `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` e `DB_NAME`** apontando para o MySQL (em vez do arquivo `configuracao.env`).
- **HTTPS ligado.** Fora da rede da empresa o PIN trafega pela internet; sem HTTPS ele pode ser lido por terceiros. Esses serviços entregam HTTPS pronto.
- Se o serviço usa um proxy na frente, defina `TRUST_PROXY=1` (isso faz o limite de tentativas funcionar por pessoa e não pelo proxy).

Este pacote ainda não foi testado numa dessas hospedagens. Siga o passo a passo do serviço escolhido e ajuste conforme ele pedir.

## Configurações opcionais (variáveis de ambiente)

| Variável | Para que serve | Padrão |
|---|---|---|
| `DB_HOST` | Endereço do MySQL | `localhost` |
| `DB_PORT` | Porta do MySQL | `3306` |
| `DB_USER` | Usuário do MySQL | `pcm_app` |
| `DB_PASSWORD` | Senha do usuário do MySQL | (vazio: precisa definir) |
| `DB_NAME` | Nome do banco | `pcm` |
| `PORT` | Porta do servidor | `3000` |
| `DATA_DIR` | Pasta do segredo do login e dos backups | `./data` |
| `JWT_SECRET` | Segredo dos logins (se não definir, é criado em `data/.segredo`) | automático |
| `TOKEN_DIAS` | Quantos dias o login fica válido no aparelho | `30` |
| `TRUST_PROXY` | Use `1` quando houver proxy na frente | desligado |

## Cópia de segurança (importante)

Todo o sistema está no banco `pcm` do MySQL. Para fazer backup com o sistema ligado:

```
npm run backup
```

Isso cria um arquivo `.sql` em `data/backups/`. Ele usa o programa `mysqldump`, que vem com o MySQL; se der "mysqldump não foi encontrado", adicione a pasta `bin` do MySQL (no Windows, algo como `C:\Program Files\MySQL\MySQL Server 8.0\bin`) à variável PATH do Windows. Copie os arquivos para outro lugar (pen drive, pasta de rede, nuvem) com frequência.

Para restaurar, com o sistema desligado:

```
mysql -u pcm_app -p pcm < data/backups/pcm-2026-11-07-18-00-00.sql
```

(troque pelo nome do arquivo que você quer restaurar; se o banco já tiver dados, apague-o e recrie antes, ou peça ajuda ao TI).

## Dia a dia

- **PIN esquecido:** Equipe > toque na pessoa > Novo PIN. O antigo para de funcionar na hora e o login aberto no celular dela é encerrado.
- **Troca do próprio PIN:** botão **Meu PIN** no topo.
- **Saída de funcionário:** Equipe > toque na pessoa > Desativar usuário. O login dele cai na hora e o histórico continua.
- **Trocar a função de alguém:** Equipe > toque na pessoa > Salvar nome e função.
- **Atualizar o sistema:** substitua as pastas `frontend` e `backend`, mantenha o `configuracao.env` e a pasta `data`, e ligue de novo. Os dados ficam no MySQL e não são afetados.

## Segurança: o que está protegido e o que não está

Protegido:

- PINs ficam guardados criptografados (bcrypt), nunca em texto.
- As regras de quem vê o quê rodam no servidor. Mexer na tela ou no navegador não dá acesso às atividades de outra pessoa.
- Depois de 8 erros seguidos de PIN numa matrícula, ela fica 10 minutos bloqueada. Há também um limite de tentativas por endereço.
- Desativar a pessoa ou trocar o PIN derruba os logins abertos dela imediatamente.
- Texto digitado (título, observação) é sempre tratado como texto, não como código.

Limites que você precisa conhecer:

- **PIN de 4 a 8 números é uma proteção simples.** Serve para controlar quem registra o quê dentro da empresa. Prefira PINs de 6 ou mais dígitos e evite datas e sequências.
- **Sem HTTPS, o PIN trafega sem criptografia.** Dentro da rede interna isso costuma ser aceitável; na internet, não.
- **O PCM vê todas as atividades e a equipe.** Quem tem a senha do PCM tem controle total. Se houver mais de um PCM, cadastre cada um com a própria matrícula.
- **Quem tem acesso ao computador onde o sistema roda** consegue ler o `configuracao.env` (com a senha do MySQL) e os backups. Proteja esse computador e use uma senha forte no MySQL.

## Testes

```
npm test
```

Roda 17 testes automáticos do servidor, usando o banco `pcm_teste` (criado pelo `banco/criar-banco.sql`). **Os testes apagam tudo desse banco**, e por segurança só rodam em banco cujo nome termina em `_teste`. Eles cobrem: primeiro acesso, login, quem pode ver e mexer em quê, troca e redefinição de PIN, desativação de usuário, bloqueio por tentativas e validação dos campos.

## Se algo der errado

- **A página não abre no celular:** confira se o celular está no mesmo Wi-Fi, se o endereço está certo e se o firewall liberou a porta 3000.
- **"Sua sessão terminou":** a pessoa foi desativada, trocou de PIN em outro aparelho ou o login passou de `TOKEN_DIAS`. Basta entrar de novo.
- **"NÃO FOI POSSÍVEL CONECTAR AO BANCO DE DADOS":** confira se o MySQL está ligado (no Windows, procure "Serviços" e veja se `MySQL80` está em execução), e se `DB_USER`, `DB_PASSWORD` e `DB_NAME` em `configuracao.env` batem com o que você usou em `banco/criar-banco.sql`.
- **Erro ao instalar ou mensagem sobre a versão do Node.js:** instale o Node.js 18 ou mais novo e rode o `iniciar.bat` de novo, com internet.
- **Porta 3000 em uso:** defina `PORT` com outro número (por exemplo, `set PORT=3100` antes de ligar, no Windows).

## Opcional: telas no Netlify, servidor em outro lugar

O Netlify só hospeda as **telas** (a pasta `frontend`). Ele não roda o servidor (Node.js) nem o MySQL, então o servidor precisa estar online em outro lugar (por exemplo, a Railway) antes. Depois:

1. Abra `frontend/_redirects` e troque `COLE-AQUI-O-ENDERECO-DO-SERVIDOR` pelo endereço do servidor (sem `https://` e sem `/` no final).
2. No servidor, defina `TRUST_PROXY=2` (há dois proxies na frente: o Netlify e o da hospedagem).
3. No Netlify, publique **somente a pasta `frontend`** (arrastando a pasta em `app.netlify.com/drop`, ou ligando o repositório do GitHub com *Publish directory* = `frontend` e sem comando de build).

Se você hospeda tudo na Railway, nada disso é necessário: o próprio servidor entrega as telas no mesmo link.
