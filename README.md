# Fantasy Sandbox — V0.0.21

## Personagem modular agora é o personagem oficial

A V0.0.21 substitui o personagem antigo baseado em spritesheet pelo novo rig modular dentro do gameplay principal.

Não é mais necessário pressionar **P**. O personagem que aparece normalmente no mundo já usa o sistema modular.

## O que foi preservado

Toda a lógica do jogo continua em `player.gd`:

- movimento;
- corrida;
- combate;
- coleta;
- crafting;
- fome;
- vida;
- XP;
- armadura;
- fogueira;
- construção;
- interação com recursos e lobos.

A alteração foi concentrada na camada visual.

## Novo rig oficial

O nó `Visual` do jogador agora é um `Node2D` composto por:

- sombra;
- perna esquerda;
- perna direita;
- tronco;
- braço esquerdo;
- braço direito;
- cabeça;
- duas partes do cachecol;
- ferramenta.

Cada parte é desenhada diretamente pelo Godot e permanece consistente entre os estados.

Não existe spritesheet no personagem oficial desta versão.

## Estados visuais

O rig entende os mesmos estados que o gameplay já utilizava:

### Idle

- respiração discreta;
- direção preservada após parar.

### Walk

- pernas alternadas;
- braços em contramovimento;
- bob discreto do corpo e cabeça;
- cachecol acompanha o passo;
- quatro direções.

### Attack

Ao pressionar **Espaço**, o gameplay continua aplicando dano normalmente e o rig executa uma sequência modular curta de preparação, golpe e recuperação.

A ferramenta visual depende do item selecionado:

- espada;
- machado;
- picareta;
- faca;
- sem ferramenta quando o personagem está desarmado.

### Gather

Quando uma coleta é realizada com sucesso usando **E**, o rig executa a animação modular de coleta no mesmo intervalo usado pelo gameplay.

Machado, picareta ou faca são mostrados conforme o item selecionado.

## Quatro direções

O visual continua distinguindo:

- baixo;
- cima;
- esquerda;
- direita.

Frente mostra o rosto, costas usa cabelo e roupa traseiros e as vistas laterais usam perfil.

## Escala e colisão

O protótipo usava escala 3x, mas para integração no mapa o rig oficial usa **2x**.

Os pés foram alinhados com a base da colisão original do personagem, evitando que o desenho pareça flutuar ou fique muito abaixo do ponto real do jogador.

A colisão e as velocidades não foram alteradas.

## Sombra e armadura

A sombra antiga desenhada por `player.gd` foi removida porque o rig modular já possui sombra própria.

O indicador da armadura de pele permanece separado e continua aparecendo quando a armadura está equipada.

## Arquivos do sistema oficial

- `scripts/player_modular_part.gd`
- `scripts/player_modular_visual.gd`
- `scenes/player.tscn`
- `scripts/player.gd`

Os arquivos antigos de sprite foram mantidos por enquanto apenas como segurança para rollback. Eles não são usados pelo personagem oficial da V0.0.21.

## Teste desta versão

Teste no jogo normal, sem abrir nenhuma cena especial:

1. caminhe em todas as quatro direções;
2. pare e confirme que a direção é preservada;
3. corra com Shift;
4. pressione Espaço com e sem uma ferramenta selecionada;
5. corte árvores com machado;
6. minere rochas com picareta;
7. use a faca onde aplicável;
8. lute contra um lobo;
9. confirme que colisão, coleta e combate continuam funcionando.

Esta versão é a primeira integração do sistema modular no gameplay principal.
