# Fantasy Sandbox — V0.0.15

## Revisão e balanceamento do primeiro loop

A V0.0.15 não adiciona um sistema grande novo. Ela revisa o primeiro ciclo completo do jogo depois da implementação de coleta, crafting, combate, caça, fome, cozinha, armadura e construção.

## Fome

O ritmo anterior era rápido demais para jogar o loop completo.

Antes:

- 100 de Fome duravam aproximadamente 100 segundos.

Agora:

- a perda é de **0,20 por segundo**;
- 100 de Fome duram aproximadamente **8 minutos e 20 segundos** até chegar a zero.

Continuam iguais:

- Carne Crua: +20 de Fome e -5 de Vida;
- Carne Assada: +45 de Fome e sem dano;
- Fome em zero: 5 de dano a cada aproximadamente 2 segundos.

## XP

Cada Lobo agora concede **35 XP**.

Com os três lobos iniciais:

- Lobo 1: 35 XP;
- Lobo 2: 70 XP acumulados;
- Lobo 3: 105 XP acumulados.

Assim, completar a caça dos três lobos permite chegar ao **Nível 2** e ainda ficar com 5 XP no novo nível.

Isso torna possível testar a progressão dentro do primeiro mapa.

## Recursos do mundo

Foi criada uma margem maior para o jogador não ficar apertado depois de fabricar ferramentas, fogueira e começar a construir.

O mapa agora possui:

- **8 árvores**;
- **7 rochas grandes**;
- **10 cipós**;
- os mesmos 8 gravetos iniciais;
- as mesmas 8 pedras pequenas iniciais.

As novas árvores, rochas e cipós ficam um pouco mais afastados do ponto inicial para incentivar exploração curta.

## Construção

O sistema de construção agora explica melhor por que o preview está vermelho.

O HUD pode mostrar:

- **SEM RECURSOS**;
- **ESPAÇO OCUPADO**;
- **MUITO PERTO**;
- ou **VÁLIDO**.

Os custos permanecem:

- Chão de Madeira: 1 Madeira;
- Parede: 2 Madeira + 1 Pedra;
- Porta: 2 Madeira + 1 Pedra.

## Fogueira

A fogueira agora respeita os obstáculos do mundo.

Ela não pode mais ser colocada:

- em cima de árvore;
- em cima de rocha;
- em cima de lobo/cadáver;
- em cima de outra fogueira;
- em cima de peça construída.

Se a posição estiver bloqueada, o kit não é consumido.

## HUD

Os indicadores de depuração:

- Posição;
- Estado.

foram ocultados do HUD principal.

O jogador continua vendo apenas informações úteis para o gameplay:

- Vida;
- Fome;
- Armadura;
- Construção;
- Nível/XP;
- recursos;
- controles.

## Estado do primeiro loop

O primeiro loop jogável está funcional:

Coletar recursos primitivos
→ fabricar ferramentas improvisadas
→ obter Madeira/Pedra
→ fabricar ferramentas e Espada
→ caçar Lobos
→ ganhar XP
→ obter Carne e Pele
→ controlar Fome
→ fabricar Fogueira
→ cozinhar Carne
→ fabricar Armadura
→ construir uma base.

## Próxima fase

Com a V0.0.15 validada, o próximo desenvolvimento já pode aprofundar o jogo.

Prioridades recomendadas para a segunda camada:

- sistema de salvar/carregar;
- respawn de recursos;
- respawn/ecologia de animais;
- baús e armazenamento;
- porta que abre e fecha;
- equipamentos melhores;
- expansão do mundo e biomas.
