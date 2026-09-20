# Fantasy Sandbox — V0.0.22

## Sprite original restaurado no personagem oficial

A V0.0.21 integrou corretamente a ideia do novo sistema de animação, mas manteve por engano o personagem simplificado desenhado por código.

A V0.0.22 corrige isso.

O personagem oficial volta a usar a arte original de alta qualidade:

- cabelo castanho detalhado;
- cachecol vermelho;
- rosto original;
- roupa escura em pixel art;
- proporções e acabamento da arte aprovada anteriormente.

O boneco simplificado não é mais usado como corpo do jogador.

## Nova forma de usar a arte original

Os arquivos originais continuam sendo:

- `assets/player/idle.png`
- `assets/player/walk.png`

Mas eles não são reproduzidos diretamente como uma spritesheet comum.

Ao iniciar o jogador:

1. cada quadro é extraído individualmente;
2. pixels de fundo quase transparentes são removidos;
3. a silhueta real do personagem é localizada;
4. o centro horizontal é recalculado;
5. os pés são colocados sempre na mesma linha;
6. cada quadro vira uma `ImageTexture` independente.

Isso elimina o problema principal detectado na spritesheet original: o personagem se deslocava vários pixels para a esquerda entre o primeiro e o último quadro da caminhada.

## Caminhada

A caminhada usa novamente os seis desenhos originais em cada direção.

- 6 frames;
- 10 FPS;
- quatro direções;
- troca manual das texturas;
- nenhuma dependência de `AnimatedSprite2D`;
- nenhum recorte de atlas durante a renderização.

Os quadros são recentralizados antes de serem exibidos.

## Idle

O idle também usa a arte original:

- 4 frames;
- 4 FPS;
- quatro direções;
- alinhamento automático.

## Ataque e coleta

Nesta versão, ataque e coleta preservam o corpo original do personagem.

Durante essas ações:

- o sprite original permanece como base;
- o corpo avança alguns pixels na direção da ação;
- espada, machado, picareta ou faca aparecem em uma camada separada;
- os tempos continuam sincronizados com o gameplay atual.

Essa solução evita voltar a usar quadros completos inconsistentes enquanto mantém a aparência original do personagem.

## Escala

O sprite original volta ao tamanho que já havia sido visualmente aprovado:

- frame base: 64 x 64;
- escala: 1,25x;
- filtro Nearest;
- posição visual equivalente ao sistema antigo.

## Gameplay

Nenhuma regra de gameplay foi alterada.

Continuam iguais:

- movimento;
- corrida;
- combate;
- coleta;
- lobos;
- XP;
- fome;
- crafting;
- fogueira;
- armadura;
- construção.

## Arquivos principais

- `scripts/player_original_visual.gd`
- `scenes/player.tscn`
- `scripts/player.gd`

O arquivo `player_modular_part.gd` permanece sendo usado apenas para sombra e ferramenta. Ele não desenha mais o corpo do personagem oficial.

## Teste

Ao abrir o jogo normalmente, o personagem deve ser novamente o aventureiro original detalhado.

Teste:

1. parado nas quatro direções;
2. caminhada em W/A/S/D;
3. corrida com Shift;
4. transição entre direções;
5. ataque;
6. coleta.

O ponto principal desta versão é confirmar que a arte original voltou e que a caminhada não desloca mais o corpo lateralmente entre os frames.
