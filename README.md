# Fantasy Sandbox — V0.0.19.1

## Protótipo do novo personagem modular

A V0.0.19 inicia uma nova abordagem para o personagem principal.

Depois dos problemas recorrentes de spritesheet — recortes, deslocamento entre frames e animação parecendo uma imagem congelada — o novo sistema deixa de depender de sequências de imagens para a caminhada.

O personagem oficial atual continua intacto.

## Como testar

1. Abra o jogo normalmente.
2. Pressione **P**.
3. Será aberta a cena de demonstração do novo personagem.
4. Use **WASD** ou as setas para mover.
5. Pressione **ESC** para voltar ao jogo normal.

## Estrutura modular

O protótipo é formado por peças independentes:

- cabeça e cabelo;
- tronco;
- braço esquerdo;
- braço direito;
- perna esquerda;
- perna direita;
- duas partes do cachecol;
- sombra.

As peças são desenhadas diretamente pelo Godot em pixel art.

Não existe PNG, spritesheet ou recorte de atlas nessa demonstração.

## Animação

A caminhada é feita transformando as mesmas peças do personagem.

Durante o movimento:

- pernas se alternam em sentidos opostos;
- braços acompanham o passo de forma inversa;
- tronco e cabeça sobem 1 pixel;
- cachecol reage ao ciclo;
- sombra acompanha discretamente o movimento.

Todas as posições são arredondadas para pixels inteiros antes de serem aplicadas.

A arte é exibida em escala inteira de **3x**, preservando pixels uniformes.

## Idle

Quando parado, o personagem mantém a mesma anatomia e realiza apenas uma respiração discreta de 1 pixel.

## Objetivo deste protótipo

Nesta etapa existe apenas uma aparência frontal.

Antes de produzir esquerda, direita, costas, ataque, coleta e equipamentos, precisamos validar três pontos:

1. a anatomia permanece consistente enquanto anda;
2. não existem falhas de recorte;
3. a animação transmite caminhada de forma clara e agradável.

Se essa técnica for aprovada, ela substituirá gradualmente o sistema antigo sem precisar redesenhar uma imagem completa para cada frame.

## Arquivos novos

- `scenes/player_v2_demo.tscn`
- `scripts/player_v2_demo.gd`
- `scripts/player_v2_visual.gd`
- `scripts/player_v2_part.gd`

## Gameplay

O gameplay principal da V0.0.18.2 não foi alterado. O protótipo é uma cena separada acessível pela tecla **P**.


## Hotfix V0.0.19.1

O atalho F8 foi removido porque pode ser interceptado pelo próprio editor do Godot. O protótipo agora é aberto com **P**, capturado em `_input()` antes da interface do jogo. A HUD também mostra esse atalho.
