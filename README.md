# Fantasy Sandbox — V0.0.9

## Sistema desta versão: primeiro inimigo — Lobo

O mundo agora possui lobos vivos e hostis.

### Comportamento

- Existem 3 lobos espalhados pelo mapa.
- Quando estão tranquilos, vagam pela região onde nasceram.
- Detectam o jogador a aproximadamente 300 unidades.
- Ao detectar, perseguem o jogador.
- Se o jogador fugir para longe, desistem da perseguição.
- Quando alcançam o jogador, mordem.
- Cada mordida causa 8 de dano.
- O ataque do lobo possui intervalo de aproximadamente 1,1 segundo.

### Vida do lobo

- Vida máxima: 24 HP.
- A barra de vida aparece acima do lobo.
- O lobo pisca quando recebe dano.
- Todos os ataques implementados anteriormente podem causar dano nele.
- Espada continua causando 7 de dano e é a melhor arma atual.

### Morte

Quando a vida chega a zero:

- o lobo morre;
- deixa de perseguir e atacar;
- deixa de bloquear fisicamente o jogador;
- o corpo permanece no chão.

O cadáver permanecer no chão é intencional: a próxima etapa utilizará esse corpo para carne e pele.

### Direção visual

O desenho do lobo gira conforme a direção em que ele se move, inclusive durante perseguição.

## Morte do jogador

O jogador agora pode morrer.

- Vida máxima: 100.
- Ao chegar a 0 HP, fica morto por aproximadamente 2 segundos.
- Depois reaparece no ponto inicial com a vida cheia.
- O inventário e as ferramentas não são apagados no respawn nesta fase do protótipo.

## Sistemas preservados

- coleta primitiva;
- ferramentas improvisadas;
- crafting em duas etapas;
- Machado/Picareta;
- Espada;
- inventário dinâmico;
- hotbar;
- combate direcional.

## Próxima etapa do loop

Depois de validar o Lobo, a próxima versão adicionará a recompensa da caça:

**XP + cadáver aproveitável + Carne Crua + retirada de Pele com a Faca Improvisada.**
