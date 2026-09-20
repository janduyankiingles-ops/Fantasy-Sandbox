# Fantasy Sandbox — V0.0.8

## Sistema desta versão: combate básico

O ataque com **Espaço** agora causa dano real em alvos próximos.

### Regras do ataque

- O ataque é corpo a corpo.
- O alvo precisa estar dentro do alcance.
- O alvo precisa estar à frente do personagem, considerando a última direção em que ele se moveu.
- Apenas o alvo válido mais próximo recebe o golpe.

### Dano por item

- Mãos vazias: 1.
- Machado Improvisado: 2.
- Picareta Improvisada: 2.
- Faca Improvisada: 3.
- Machado: 4.
- Picareta: 4.
- Espada: 7.

A Espada é atualmente a melhor arma de combate.

## Vida do jogador

O jogador agora possui:

- Vida máxima: 100.
- Vida atual exibida no HUD.

Nesta versão ainda não existe inimigo causando dano ao jogador. Essa base será utilizada pelos lobos.

## Boneco de treino

Foi colocado um boneco de treino próximo ao ponto inicial.

- Vida: 20.
- Possui barra de vida.
- Pisca ao receber dano.
- Ao chegar a 0 HP, fica destruído.
- Reaparece automaticamente após aproximadamente 1,5 segundo.

O boneco existe apenas para validar alcance, direção e dano antes da implementação dos lobos.

## Sistemas anteriores preservados

- Coleta de Graveto, Pedra Pequena e Cipó.
- Ferramentas improvisadas.
- Bloqueio de árvores/rochas sem ferramenta.
- Crafting em duas etapas.
- Inventário dinâmico.
- Hotbar com 6 ferramentas.
- Machado/Picareta melhorando coleta.

## Próximo passo do loop

Após validar o combate básico, a próxima versão adicionará o primeiro inimigo real: **Lobo**, com movimentação, perseguição, ataque e morte.
