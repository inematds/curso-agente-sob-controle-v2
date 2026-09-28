# FALHAS

| data | o que quebrou | menor correção | prompt \| infra |
|---|---|---|---|
| 2026-09-28 | Índices das trilhas 2 e 3 montados com trecho errado: agentes paralelos cortavam o `trilha1/index.html` por número de linha enquanto o agente da T1 ainda o editava (os próprios agentes refizeram cortando por marcador de texto) | Congelar o modelo (ou entregar uma cópia) antes de disparar agentes que copiam dele, e cortar por marcador, não por linha | prompt |
