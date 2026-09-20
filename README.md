# Fantasy Sandbox — V0.0.18

## Personagem principal — qualidade e animação corrigidas

A V0.0.18 corrige os dois problemas observados na V0.0.17:

- a caminhada podia parecer uma imagem parada deslizando pelo mapa;
- a redução para frames de 44 x 44 px removeu detalhes e cores demais da arte.

Nenhuma regra de gameplay foi alterada.

## Qualidade visual

Os frames do personagem agora usam **64 x 64 px**, em vez de 44 x 44 px.

O novo processamento preserva melhor:

- cabelo;
- rosto;
- cachecol vermelho;
- roupas e couro;
- contornos;
- diferenças de iluminação entre os frames.

A textura continua usando filtro **Nearest**, sem borramento durante a escala.

A escala do AnimatedSprite2D foi ajustada para **1,2x**, preservando aproximadamente o mesmo tamanho do personagem no mundo apesar da resolução maior.

## Idle e caminhada

As folhas completas de Idle e Walk foram refeitas em maior qualidade:

- `assets/player/idle.png`
- `assets/player/walk.png`

### Idle

- 4 frames por direção;
- 4 FPS;
- loop.

### Walk

- 6 frames por direção;
- 10 FPS;
- loop.

## Correção do personagem deslizando

O controle de animação agora mantém explicitamente:

- `current_state`;
- `current_direction`.

O jogo só chama `play()` quando o estado visual ou a direção realmente mudam.

Enquanto o jogador continua andando na mesma direção, o AnimatedSprite2D permanece na animação atual e avança naturalmente pelos seis frames, em vez de correr o risco de reiniciá-la.

Nas diagonais, a direção anterior é preservada quando ainda corresponde ao movimento atual. Isso reduz alternância visual entre duas direções quando duas teclas permanecem pressionadas.

## Ataque e coleta

Para manter a resolução de 64 x 64 px sem voltar ao problema de arquivos PNG grandes, ataque e coleta foram separados por direção.

### Ataque

- `assets/player/attack_down.png`
- `assets/player/attack_left.png`
- `assets/player/attack_up.png`
- `assets/player/attack_right.png`

Cada direção tem:

- 6 frames;
- 26 FPS;
- sem loop;
- duração de aproximadamente 0,23 s.

### Coleta

- `assets/player/gather_down.png`
- `assets/player/gather_left.png`
- `assets/player/gather_up.png`
- `assets/player/gather_right.png`

Cada direção tem:

- 5 frames;
- 15 FPS;
- sem loop;
- duração de aproximadamente 0,33 s.

Esses tempos permanecem sincronizados com os timers atuais de ataque e coleta em `player.gd`.

## Arquivos antigos removidos

As folhas antigas de baixa resolução:

- `assets/player/attack.png`
- `assets/player/gather.png`

foram removidas.

## Gameplay preservado

Continuam iguais:

- movimentação;
- corrida;
- ataque;
- coleta;
- crafting;
- lobos;
- XP;
- fome;
- fogueira;
- armadura;
- construção.

## Teste principal desta versão

Ao manter uma direção pressionada, o personagem deve apresentar passos visíveis e contínuos em vez de uma pose congelada deslizando.

Também deve haver uma melhora perceptível na separação das cores e nos detalhes do personagem em relação à V0.0.17.
