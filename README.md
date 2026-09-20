# Fantasy Sandbox — V0.0.23

## Personagem redesenhado e integrado

Esta versão abandona as folhas antigas que estavam causando deslocamentos, recortes inconsistentes e animações que pareciam congeladas.

O personagem foi redesenhado mantendo a identidade visual aprovada:

- cabelo castanho;
- cachecol vermelho;
- roupa de aventureiro em fantasia sombria;
- pixel art detalhada;
- frente, costas, esquerda e direita.

## Estrutura dos novos sprites

As animações não entram no Godot como uma folha grande irregular.

Antes de serem publicadas, elas foram processadas em tiras pequenas e regulares com células exatas de **64 x 64 pixels**.

Diretório:

`assets/player_v023/`

Existem quatro tiras para cada estado:

- `idle_down/left/up/right.png`
- `walk_down/left/up/right.png`
- `attack_down/left/up/right.png`
- `gather_down/left/up/right.png`

### Quantidade de frames

- Idle: 4 frames por direção
- Walk: 6 frames por direção
- Attack: 4 frames por direção
- Gather: 4 frames por direção

Todas as tiras possuem somente uma linha. Não existe cálculo de linha, detecção de silhueta ou reposicionamento da arte durante o jogo.

## Novo controlador visual

O personagem oficial usa:

`scripts/player_v023_visual.gd`

Ele é um `Sprite2D` simples.

No carregamento, cada tira é dividida somente em retângulos fixos de 64 x 64. Como os arquivos já foram preparados e alinhados antes da publicação, o Godot não precisa corrigir os sprites em tempo de execução.

O avanço de frames também é controlado manualmente pelo script.

Velocidades:

- Idle: 4 FPS
- Walk: 10 FPS
- Attack: 17 FPS
- Gather: 12 FPS

## O que foi removido do personagem oficial

O personagem oficial não usa mais:

- o alinhamento automático da V0.0.22;
- análise de alpha em tempo de execução;
- personagem modular desenhado com retângulos;
- ferramenta modular separada;
- folhas grandes antigas para as animações atuais.

Os arquivos antigos permanecem no repositório apenas como segurança de rollback.

## Gameplay

Nenhuma regra de gameplay foi alterada.

Continuam funcionando normalmente:

- movimento e corrida;
- combate;
- coleta;
- crafting;
- fome;
- vida;
- XP;
- lobos;
- fogueira;
- armadura;
- construção.

O `player.gd` continua enviando ao visual os estados `idle`, `walk`, `attack` e `gather`.

## Teste

Após atualizar, abra o jogo normalmente e teste:

1. Idle nas quatro direções.
2. Caminhada contínua usando W, A, S e D.
3. Corrida com Shift.
4. Mudanças rápidas de direção.
5. Ataque com Espaço.
6. Coleta com E.

O corpo deve permanecer no mesmo ponto dentro de todos os frames, sem pedaços de células vizinhas e sem deslizar como uma imagem congelada.
