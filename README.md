# Fantasy Sandbox — V0.0.20

## Personagem Modular V2 — quatro direções

O protótipo modular foi aprovado como abordagem e agora recebeu a segunda etapa visual.

O personagem oficial do gameplay ainda não foi substituído. O teste continua acessível pela tecla **P**.

## Correção das pernas

As pernas foram redesenhadas para ficarem claramente visíveis abaixo da túnica.

Agora possuem:

- calça mais longa;
- contorno próprio;
- iluminação diferente entre as duas pernas;
- botas maiores e separadas visualmente da calça;
- sola aparente;
- movimento alternado durante a caminhada.

A profundidade também muda conforme a orientação.

## Quatro direções

O rig modular agora possui aparência própria para:

- baixo / frente;
- cima / costas;
- esquerda / perfil;
- direita / perfil.

Não são sprites completos diferentes. As mesmas partes continuam sendo usadas, mas cada parte sabe como deve ser desenhada para a orientação atual.

### Frente

Mostra rosto, olhos, nariz, boca, fivela e frente da roupa.

### Costas

O rosto desaparece, o cabelo cobre a parte posterior da cabeça e a roupa recebe detalhes de costas.

### Esquerda e direita

A cabeça ganha perfil com nariz e um olho visível. Tronco, braços, pernas e cachecol também mudam de disposição.

## Caminhada direcional

As quatro direções possuem caminhada modular.

- pernas alternam;
- braços fazem contramovimento;
- tronco e cabeça fazem bob de 1 pixel;
- cachecol reage ao passo;
- nas laterais braços e pernas também avançam/recuam horizontalmente;
- a ordem de desenho muda para indicar qual braço/perna está mais próximo da câmera.

Em diagonais, o personagem preserva uma direção coerente para evitar alternância visual rápida.

## Indicador de teste

A cena do protótipo mostra agora:

`Direção visual: BAIXO / CIMA / ESQUERDA / DIREITA`

Isso permite conferir se o rig está selecionando a vista correta.

## Como testar

1. Abra o jogo normalmente.
2. Pressione **P**.
3. Use **S** para olhar/caminhar para baixo.
4. Use **W** para olhar/caminhar para cima.
5. Use **A** para esquerda.
6. Use **D** para direita.
7. Solte a tecla e confirme que o personagem permanece olhando naquela direção.
8. Pressione **ESC** para voltar ao jogo.

## Escopo atual

O protótipo possui:

- idle em quatro direções;
- caminhada em quatro direções;
- pernas visíveis;
- animação modular sem spritesheet.

Ataque, coleta e equipamentos serão adicionados ao rig somente depois desta validação.

## Gameplay

Nenhuma regra do gameplay principal foi alterada.
