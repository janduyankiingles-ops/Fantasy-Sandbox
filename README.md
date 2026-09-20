# Fantasy Sandbox — V0.0.18.2

## Correção estrutural do personagem

Esta versão troca completamente a forma como o personagem é desenhado.

A análise dos pixels reais da folha de caminhada mostrou que os quadros estavam deslocados dentro das células de 64 x 64. O personagem mudava de posição interna entre um frame e outro, causando sensação de recorte incorreto, tremor e uma caminhada visualmente parecida com uma imagem deslizando.

## Sprite2D simples

O nó visual do jogador não é mais um AnimatedSprite2D.

Agora ele é um Sprite2D simples e o jogo troca diretamente a propriedade `texture`.

Isso remove da cadeia:

- playback automático do AnimatedSprite2D;
- SpriteFrames do Godot;
- AtlasTexture;
- recortes por região durante a renderização.

## Frames independentes

As folhas PNG de alta qualidade continuam sendo usadas apenas como fonte.

Ao iniciar o jogo, cada célula é extraída para uma nova imagem 64 x 64 e transformada em uma ImageTexture independente.

Portanto, na renderização, um frame não tem qualquer acesso aos pixels do frame vizinho.

## Limpeza de transparência

Os PNGs possuíam pixels de fundo com alpha extremamente baixo.

A V0.0.18.2 remove esses pixels antes de montar cada frame:

- alpha abaixo de 0,15 vira transparência total;
- pixels reais da arte são preservados.

Isso elimina halos e resíduos que podiam parecer falhas de recorte.

## Alinhamento dos frames

Cada quadro é realinhado usando a parte inferior do personagem como âncora.

O algoritmo:

1. encontra os pixels visíveis;
2. encontra a região dos pés;
3. calcula o centro dessa região;
4. move o quadro para manter os pés no mesmo ponto;
5. mantém uma linha de chão consistente.

Assim o personagem não percorre a própria célula enquanto a animação avança.

## Caminhada

A caminhada continua sendo decidida diretamente pelo input WASD/setas.

O script troca diretamente entre seis texturas independentes a 10 FPS.

Também existe um movimento vertical de apenas 1 pixel durante o ciclo para reforçar visualmente o passo sem deformar a arte.

## Qualidade

A arte de 64 x 64 da V0.0.18 foi mantida.

- filtro Nearest;
- escala 1,25x;
- nenhuma nova compressão dos PNGs;
- cores e detalhes preservados.

## Gameplay

Nenhuma regra de gameplay foi alterada.
