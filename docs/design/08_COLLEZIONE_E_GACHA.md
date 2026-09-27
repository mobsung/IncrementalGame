# Collezione e gacha

[Indice e stato del design](00_INDICE.md). Documento operativo derivato dal CORE_DESIGN originale, conservato intatto.

## Decisioni concordate e specifiche

## Evocazioni gacha e Dust

Ogni giocatore inizia con **una unità iniziale** scelta dal design del gioco; la specie confermata è [John the Meatball](unita/SPAGHETTI_GOLEM.md). Le altre copie si ottengono con le evocazioni, pagando la valuta chiamata per ora **Dust**. Nella prima demo ogni evocazione costa **5 Dust**, un valore interamente configurabile per il bilanciamento. Ogni evocazione assegna lo stadio base di una specie.

Le unità hanno rarità diverse. **Le rarità si sbloccano raggiungendo specifiche ondate**, per dare un obiettivo ulteriore alla progressione; specie, rarità, soglie e probabilità esatte saranno stabilite durante il design delle unità. Il pool delle evocazioni include le specie delle rarità disponibili. Si possono ottenere più copie della stessa specie: ciascuna è una copia indipendente. Nella prima demo non sono previste protezioni dai duplicati, garanzie dopo un numero di evocazioni o altri sistemi di compensazione della casualità. Eventuali usi ulteriori delle copie duplicate potranno essere valutati in futuro. Lo sblocco di ogni rarità è **permanente**: le specie delle rarità già sbloccate restano disponibili nelle evocazioni anche dopo un Chrono break.

## Rarità della demo

Le rarità della demo sono **COMMON, UNCOMMON, RARE, EPIC**. L'elenco potrà essere ampliato in futuro. Assegnazione delle rarità alle specie, soglie di sblocco e probabilità restano da concordare.

## Collegamenti alle altre regole

La produzione di Dust dai punti anima è definita in [Economia](07_ECONOMIA_E_POTENZIAMENTI.md); identità e crescita delle copie in [Unità](01_UNITA.md). Le regole di permanenza dopo il reset sono in [Chrono break](09_CHRONO_BREAK_E_SHOP.md).

## Questioni aperte — 24

Definire specie, assegnazione delle quattro rarità, soglie di sblocco e probabilità con la rosa del punto 27.2. Verificare nel bilanciamento il costo iniziale configurabile di 5 Dust. Il bestiario è futuro; non sono previste protezioni dai duplicati o garanzie contro la sfortuna nella demo.

## Probabilità confermate — 26 settembre 2026

Il giocatore ha confermato nella chat di implementazione: con tutte le rarità sbloccate, COMMON 55%, UNCOMMON 30%, RARE 12%, EPIC 3%. Prima dello sblocco completo, normalizzare i pesi delle sole rarità disponibili. Le probabilità sono per rarità; la distribuzione fra specie della stessa rarità resta da definire. Il gacha non è ancora implementato nella prima tappa.
