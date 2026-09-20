# Fantasy Sandbox — V0.0.16

## Nova identidade visual: personagem principal em pixel art

A primeira etapa da renovação gráfica foi aplicada ao personagem principal.

O antigo personagem desenhado diretamente por código foi substituído por um sprite em pixel art seguindo a estética definida para Fantasy Sandbox: fantasia sombria, rusticidade, cores terrosas e silhueta expressiva.

## Atlas

O personagem utiliza um atlas otimizado e com transparência:

- `assets/player/player_atlas.png`

O atlas foi preparado especificamente para o jogo e usa células regulares de **72 x 81 px**.

A filtragem da textura é **Nearest**, preservando o aspecto pixel art sem borramento.

## Direções

O personagem possui arte própria para:

- frente;
- direita;
- costas;
- esquerda.

Ao mover-se na diagonal, a direção visual dominante é escolhida automaticamente.

## Animações

Cada direção possui quatro estados.

### Idle

- 3 frames;
- animação lenta;
- reproduz continuamente enquanto o jogador está parado.

### Walk

- 4 frames;
- reproduz enquanto o jogador se movimenta;
- funciona tanto andando quanto correndo.

### Attack

- 4 frames;
- reproduz ao pressionar **Espaço**;
- sincronizada com o ataque corpo a corpo atual.

A animação-base de ataque mostra uma espada. Nesta etapa ela é utilizada para qualquer ataque, independentemente da ferramenta selecionada. Animações específicas para Machado, Picareta e Faca podem ser adicionadas em uma etapa gráfica posterior.

### Gather

- 4 frames;
- reproduz quando uma coleta com **E** é concluída com sucesso;
- cobre recursos do chão, corte de árvores, mineração e aproveitamento de cadáveres.

## Gameplay preservado

A atualização é principalmente visual.

Continuam funcionando normalmente:

- movimentação;
- corrida;
- combate;
- coleta;
- crafting;
- lobos;
- XP;
- fome;
- fogueira;
- armadura;
- construção.

A colisão do jogador continua independente do tamanho visual do sprite.

## Armadura

O efeito mecânico da Armadura de Pele continua funcionando normalmente.

Enquanto a arte específica da armadura não for criada, o jogador equipado recebe um pequeno indicador visual marrom sob os pés e o HUD continua mostrando o estado da armadura.

## Próximos passos gráficos

Depois de validar o personagem dentro do jogo, podemos aplicar a mesma direção artística aos demais elementos:

1. árvores, pedras, gravetos, cipós e recursos;
2. lobo e suas animações;
3. chão e vegetação do mundo;
4. fogueira;
5. construções;
6. HUD e menus;
7. efeitos de luz, partículas e atmosfera.

A ideia é trocar os gráficos gradualmente sem alterar os sistemas que já estão funcionando.
