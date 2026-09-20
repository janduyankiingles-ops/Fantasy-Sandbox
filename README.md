# Fantasy Sandbox — V0.0.11

## Sistema desta versão: fome

O personagem agora possui uma necessidade básica de alimentação.

### Fome

- Fome máxima: **100**.
- O HUD mostra o valor atual.
- A fome cai continuamente.
- No balanceamento atual de teste, 100 pontos duram aproximadamente **100 segundos**.
- Ao chegar a 0, o HUD mostra **FAMINTO**.

Esse ritmo é propositalmente rápido nesta fase para permitir testar o sistema sem esperar muitos minutos. O balanceamento será revisto depois que o primeiro loop estiver completo.

### Fome zerada

Enquanto a fome estiver em 0:

- o personagem sofre **5 de dano**;
- o dano acontece aproximadamente a cada **2 segundos**;
- esse dano pode matar o jogador normalmente.

Ao morrer e reaparecer nesta fase do protótipo, Vida e Fome voltam ao máximo.

### Carne Crua

A Carne Crua obtida dos lobos agora pode ser consumida.

Pressione **F** quando possuir Carne Crua e a fome não estiver cheia.

Cada unidade:

- consome **1 Carne Crua**;
- recupera **20 pontos de fome**;
- causa **5 de dano** ao jogador.

Isso torna a Carne Crua uma comida emergencial, mas ruim. O objetivo é criar uma vantagem real para cozinhar a carne na próxima etapa.

Se a quantidade chegar a zero, Carne Crua desaparece do inventário normalmente.

## Fluxo atual

Coletar recursos primitivos → fabricar ferramentas improvisadas → obter Madeira/Pedra → fabricar Espada → caçar Lobo → ganhar XP → obter Carne Crua/Pele → administrar Fome.

## Próxima etapa

A próxima versão adicionará a **Fogueira e o cozimento**:

- construir/fabricar uma fogueira;
- usar Carne Crua;
- transformar em Carne Assada;
- comer Carne Assada sem a penalidade da carne crua e com recuperação de fome melhor.
