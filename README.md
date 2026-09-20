# Fantasy Sandbox — V0.0.18.1

## Hotfix definitivo do playback do personagem

Esta versão mantém os sprites de alta qualidade da V0.0.18 e corrige especificamente os dois problemas restantes:

- caminhada visualmente congelada;
- pequenos vazamentos/falhas nas bordas dos recortes.

## Caminhada

O estado de caminhada agora é decidido diretamente pelo vetor de input do jogador (WASD/setas), e não pela velocidade suavizada do CharacterBody2D.

Além disso, o AnimatedSprite2D não depende mais de seu playback automático para avançar a animação. O script visual mantém um relógio próprio e avança os frames manualmente em `_process(delta)`.

Com isso, enquanto o jogador mantém uma direção pressionada, a sequência percorre explicitamente:

`0 → 1 → 2 → 3 → 4 → 5 → 0`

a 10 FPS.

Idle também é avançado manualmente, enquanto ataque e coleta avançam até o último frame e aguardam a troca do estado do jogador.

## Recorte

Cada quadro continua sendo uma textura independente dentro do SpriteFrames, mas agora o AtlasTexture usa `filter_clip = true`.

Isso impede que pixels do quadro vizinho vazem para a borda do frame durante a renderização.

Também foram ajustados:

- filtro Nearest;
- escala para 1,25x, produzindo 80 x 80 pixels em tela a partir do frame de 64 x 64;
- centralização explícita do sprite.

## Arte

Nenhum dos PNGs de alta qualidade da V0.0.18 foi reduzido ou recomprimido nesta correção.

Os mesmos sprites de 64 x 64 continuam sendo usados para preservar os detalhes e as cores que ficaram boas na versão anterior.

## Gameplay

Nenhuma regra de gameplay foi alterada.
