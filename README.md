# Fantasy Sandbox — V0.0.17

## Personagem principal — spritesheet limpa

A arte do personagem foi refeita para eliminar os problemas de recorte vistos na V0.0.16.x.

A versão anterior utilizava um único atlas que acabava capturando partes de frames vizinhos. A V0.0.17 passa a usar quatro folhas independentes, todas preparadas em uma grade real de **44 x 44 px por frame**.

## Arquivos

- `assets/player/idle.png`
- `assets/player/walk.png`
- `assets/player/attack.png`
- `assets/player/gather.png`

O antigo `assets/player/player_atlas.png` foi removido.

Todos os PNGs foram conferidos depois do upload no GitHub e tiveram a assinatura PNG e SHA-256 verificados sobre os bytes remotos.

## Direções

Cada folha possui quatro linhas:

1. frente;
2. esquerda;
3. costas;
4. direita.

O código agora respeita exatamente essa ordem.

## Animações

### Idle
- 4 frames por direção;
- 4 FPS;
- loop contínuo.

### Walk
- 6 frames por direção;
- 10 FPS;
- usado andando ou correndo.

### Attack
- 6 frames por direção;
- 26 FPS;
- sem loop;
- sincronizado com o tempo atual do ataque.

### Gather
- 5 frames por direção;
- 15 FPS;
- sem loop;
- usado em coleta, corte, mineração e aproveitamento de cadáveres.

## Renderização

- textura com filtro **Nearest**;
- células perfeitamente separadas;
- escala visual de **1,75x**;
- pivô consistente entre estados;
- colisão do jogador continua independente do sprite.

## Gameplay preservado

Nenhuma regra de gameplay foi alterada nesta versão. Continuam funcionando:

- movimentação e corrida;
- combate;
- coleta;
- crafting;
- lobos;
- XP;
- fome;
- fogueira;
- armadura;
- construção.

## Próximo passo gráfico

Depois de validar o personagem no jogo, a próxima etapa gráfica será padronizar o ambiente na mesma estética: árvores, rochas, gravetos, pedras pequenas, cipós e terreno.
