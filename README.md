# Fantasy Sandbox — V0.0.14

## Sistema desta versão: construção básica

A última grande etapa do primeiro loop agora existe: o jogador pode usar Madeira e Pedra para construir uma pequena base diretamente no mundo.

## Modo de construção

Pressione **B** para entrar ou sair do modo construção.

Enquanto estiver ativo:

- **Q** troca a peça selecionada;
- **R** gira Parede ou Porta;
- **Enter** coloca a peça;
- **Esc** sai do modo construção.

Abrir o Inventário (**I**) ou Crafting (**C**) também encerra automaticamente o modo construção.

## Grade e preview

A construção usa uma grade de **64 px**.

A peça aparece à frente do personagem antes de ser colocada.

- preview verde = posição válida;
- preview vermelho = posição bloqueada.

O HUD também informa:

- peça selecionada;
- custo;
- VÁLIDO ou BLOQUEADO.

## Peças

### Chão de Madeira

Custo:

- **1 Madeira**.

Características:

- peça de 1 célula;
- não possui colisão;
- o personagem pode caminhar sobre ela.

### Parede

Custo:

- **2 Madeira + 1 Pedra**.

Características:

- possui colisão;
- pode ser girada com **R**;
- bloqueia o jogador e os lobos.

### Porta

Custo:

- **2 Madeira + 1 Pedra**.

Características:

- pode ser girada com **R**;
- possui estrutura lateral;
- o vão central é atravessável.

Nesta primeira versão a Porta funciona como uma entrada permanentemente aberta. Abrir/fechar portas poderá ser aprofundado depois.

## Bloqueios de construção

O jogo não permite colocar uma nova peça:

- em cima do jogador;
- em cima de árvore;
- em cima de rocha;
- em cima de lobo vivo ou cadáver;
- em cima de uma fogueira;
- em cima de outra peça construída;
- quando os recursos necessários não estão disponíveis.

Gravetos, Pedras Pequenas e Cipós no chão não bloqueiam construção.

Os recursos são descontados **somente quando a peça é efetivamente colocada**.

## Primeiro loop jogável

O protótipo agora permite completar o ciclo planejado:

Coletar Graveto/Pedra Pequena/Cipó
→ fabricar ferramentas improvisadas
→ obter Madeira e Pedra
→ fabricar Machado, Picareta e Espada
→ caçar Lobos
→ ganhar XP
→ obter Carne e Pele
→ controlar Fome
→ fabricar Fogueira
→ cozinhar Carne
→ fabricar Armadura de Pele
→ construir uma pequena base.

## Próximo passo

Depois de validar a V0.0.14, o primeiro loop pode ser considerado funcional.

A próxima etapa deve ser uma revisão do loop completo para identificar:

- bugs;
- problemas de balanceamento;
- partes pouco intuitivas;
- melhorias de interface;
- sistemas que precisam ser aprofundados antes de expandir o jogo.
