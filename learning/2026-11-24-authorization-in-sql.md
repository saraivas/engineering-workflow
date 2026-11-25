# Authorization in SQL (study pause before orbitdesk-api#8)

*Notes are kept in Portuguese, the language I study in. My answers are
published exactly as I wrote them, typos included (rule 11). The review below
each answer was written by Claude and is marked as such.*

- **Before:** [orbitdesk-api#8](https://github.com/saraivas/orbitdesk-api/pull/8),
  `GET /tasks` and `GET /tasks/{id}` with visibility enforced in SQL.
- **Topics:** object-level authorization (BOLA/IDOR), filtering in SQL vs in
  Python, `EXISTS` vs `JOIN`, `404` vs `403`, a total that does not leak,
  stable pagination, Row Level Security.
- **Result:** 5 correct, 3 partial.

---

### 1. Qual a diferença entre autorização por ação e por objeto?

**Minha resposta:**
> a primeira é se voce pode fazer a acao, e a seguna é se vc pode ver o resuktado da acao ou seja o objeto

**Revisão (Claude): certa.** Detalhe: a autorização por objeto vale para
qualquer operação sobre um objeto específico (ver, editar, apagar), não só
para ver.

### 2. Por que filtrar a lista em Python depois da consulta é um problema?

**Minha resposta:**
> pq sobrecarrega a busca no banco e descarta muita coisa, alem que dados como totais counts podem ficar erados sem cuidados extras

**Revisão (Claude): parcial.** Faltaram dois motivos: a paginação quebra (o
`LIMIT` corta antes do filtro e a página volta curta) e passam a existir duas
regras para lembrar (basta um endpoint novo esquecer o filtro).

### 3. O que aconteceria se os parênteses em volta dos `OR` fossem esquecidos?

**Minha resposta:**
> iria vazar dados entre os interesses da consulta

**Revisão (Claude): parcial, vaga.** O mecanismo é a precedência: `AND` é
avaliado antes de `OR`. `type = 'standard' OR created_by = :me AND
organization_id = :org` vira `type = 'standard' OR (created_by = :me AND
organization_id = :org)`, e todas as tarefas padrão de todas as organizações
aparecem.

### 4. Por que `EXISTS` e não `JOIN` para checar a atribuição?

**Minha resposta:**
> exist é mais clean , o join repete na lista e infla o total

**Revisão (Claude): certa.** O motivo técnico do "mais clean": `EXISTS` só
pergunta se existe pelo menos uma linha, não multiplica resultados e pode
parar na primeira.

### 5. Por que `404` e não `403` para uma confidencial alheia? E por que o `POST` pode continuar `403`?

**Minha resposta:**
> pq com 404 ele nao entrega que existe a taks mas ele que nao tem acesso, o user fica sem saber se existe nao da para investigar assim, nao sei o respo to post

**Revisão (Claude): certa no `404`.** No `POST` não há objeto escondido: a
pergunta é sobre uma ação ("meu papel pode criar confidencial?"), e o `403` só
revela o que o usuário já sabe, o próprio papel. O `404` esconde objetos, não
regras.

### 6. Por que o total não vaza nada? Quando vazaria?

**Minha resposta:**
> nao vaza nada pq o user só vai ser suas proprias coisas com permisoes, vazaria algo se trouxessemos tudo calculassemos o total mas mostrar so qoe lee pode ver, ou sej ao total seriam mais taks do que ele tem acesso

**Revisão (Claude): certa.** É o vazamento que derivar o total da mesma
consulta evita. Foi essa linha de raciocínio que mudou a decisão do PR: a
recomendação inicial era não devolver total.

### 7. Por que a ordenação usa `created_at` **e** `id`?

**Minha resposta:**
> tarefas mais atuais na frente e o id pq pode ocorrer de ambas serem feitas ao mesmo tempo?

**Revisão (Claude): certa.** As mais recentes na frente é escolha de produto
(`DESC`). O `id` dá estabilidade: sem desempate, duas tarefas com o mesmo
`created_at` podem trocar de lugar entre consultas, e uma aparece em duas
páginas ou em nenhuma.

### 8. O que o RLS resolveria, e por que não usamos agora?

**Minha resposta:**
> RLS sao regras de acesso direto no banco, n sei pq n vamos usar agora?

**Revisão (Claude): parcial.** A definição está certa. Por que não agora: a
regra depende do papel, e essa lógica já está em Python e testada com pytest;
com RLS cada requisição precisa informar o usuário ao banco (`SET
app.user_id`), com cuidado com o pool de conexões; e uma linha filtrada pelo
RLS some sem erro, o que dificulta depurar. Ficou como defesa em profundidade
em "Future improvements" do ADR 0004.
