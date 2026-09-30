# Unità, copie e crescita

[Indice e stato del design](00_INDICE.md). Documento operativo derivato dal CORE_DESIGN originale, conservato intatto.

## Decisioni concordate e specifiche

## Livelli e punti individuali

Ogni nuovo livello conferisce **un punto livello** spendibile. Nella prima demo l'XP richiesta per passare dal livello `L` al successivo è `arrotonda_per_eccesso(30 × 1,30^(L-1))`. Il primo passaggio richiede quindi 30 XP, il secondo 39 XP e il terzo 51 XP. Il coefficiente e la base restano parametri configurabili per eventuali correzioni di bilanciamento.

## Classi e ruolo consigliato

Nella demo sono introdotte sei classi: **mage, healer, tank, warrior, summoner, ranged**. La classe indica al giocatore il ruolo consigliato dell'unità e permette di organizzare e cercare le specie nel futuro bestiario. Non impone vincoli alle statistiche, alle azioni, alle abilità o alle combinazioni possibili. Per esempio, ranged suggerisce una predisposizione al danno, mentre warrior suggerisce un equilibrio fra danno e resistenza.

Statistiche, attacco, abilità, passive, potenziamenti ed eventuali evoluzioni sono definiti per la singola unità, non da un pacchetto obbligatorio della classe. Le sei classi non impongono una specie per classe nella rosa iniziale. Resta da definire l'assegnazione concreta delle classi alle specie.

## Copie

Si abbandona la struttura attuale in cui tutte le unità derivano da un'unica unità iniziale. Un sistema di evocazioni in stile gacha assegna il primo stadio di un'unità; si possono ottenere più copie della stessa specie. Ogni copia ha la propria esperienza, i propri livelli, i propri punti investiti e i propri acquisti Gold individuali.

## Evoluzioni facoltative

**Stato tecnico del 30 settembre 2026:** sono implementati anche i rami opzionali con ID stabili, soglie configurabili, scelta/confirm nella UI, permanenza per copia e rimborso dei punti. Nessun ramo del Golem o nuova specie è stato introdotto. I contenuti concreti rimangono da approvare. [Tappa dei sistemi di base](../implementation/MECCANICHE_BASE.md).

Le evoluzioni sono **facoltative**: ogni unità viene evocata nello stadio base, ma non tutte le specie devono avere evoluzioni. Il sistema deve consentire di aggiungerle in seguito, sia lineari sia ramificate, anche a specie inizialmente prive di un percorso evolutivo. Non è obbligatorio definire tutte le evoluzioni quando viene introdotta un'unità.

Evolvere cambia l'aspetto ma **non aumenta direttamente le statistiche base**. Influenza le abilità attive e passive: può aggiungerne di nuove, introdurre nuove meccaniche in quelle esistenti, aumentarne l'efficacia oppure alzare i limiti dei loro potenziamenti. Le abilità e passive esistenti restano disponibili.

Ogni volta che una copia evolve, tutti i suoi **punti livello investiti vengono restituiti** e i potenziamenti acquistati con quei punti tornano al grado iniziale. Il giocatore può così ricostruire la copia alla luce delle abilità evolute. Livello, XP e potenziamenti acquistati con Gold rimangono. Non è previsto un reset libero dei punti livello fuori dalle evoluzioni nella prima demo.

## Requisiti e presentazione delle evoluzioni

Nella **prima demo**, l'unico requisito per evolvere è raggiungere una **soglia di livello configurabile per ciascuna evoluzione**. Livelli richiesti, numero di stadi e struttura dei rami vengono definiti nel design della singola unità. L'evoluzione viene attivata manualmente dal giocatore: raggiungere il livello richiesto la rende disponibile, ma non la esegue automaticamente. Una copia fuori dal campo può evolvere quando il giocatore lo decide; una copia già schierata può evolvere soltanto mentre il gioco è in pausa tra i tentativi. Durante la preparazione successiva al Chrono break tutte le copie sono considerate fuori dal combattimento ai fini dell'evoluzione, comprese quelle schierate nella run appena terminata: possono evolvere prima della conferma della nuova squadra. Per le versioni successive potranno essere introdotti requisiti aggiuntivi, ancora da progettare.

Se l'evoluzione presenta più rami, la scelta vale per la singola copia ed è **permanente**: non può essere annullata o cambiata. Copie diverse della stessa specie possono seguire rami diversi. In futuro un **bestiario** mostrerà tutte le unità e le rispettive evoluzioni. Quando il giocatore decide di evolvere una copia, deve poter vedere e valutare dalla schermata di quella unità le opzioni disponibili, comprese le alternative ramificate. Le soglie, gli stadi e i contenuti concreti dei rami saranno definiti unità per unità.

## Statistiche, potenziamenti e comportamento della copia

Per il significato delle statistiche e le formule usare [Combattimento](05_COMBATTIMENTO_E_ABILITA.md); per il catalogo statistico individuale e i punti livello usare [Economia](07_ECONOMIA_E_POTENZIAMENTI.md). La postura e la velocità della singola copia sono definite in [Movimento](04_MOVIMENTO_ALLEATO.md), il raggio della zona resta per specie. L'ottenimento delle copie è in [Collezione](08_COLLEZIONE_E_GACHA.md).

Ogni scheda di specie raccoglie statistiche base, attacco, abilità e passive, potenziamenti con punti livello, evoluzioni facoltative, eventuali ruoli sui due lati e riferimenti visivi. Nessun valore concreto viene assegnato senza accordo.

## Schede delle specie

- [Spaghetti Golem](../../content/units/warriors/spaghetti_golem/concepts/SPAGHETTI_GOLEM_CONCEPT.md): Rare Warrior, sostituisce John su richiesta del 27 settembre. Tre forme implementate: Noodle Squire, Saucebound Knight (livello 10), Spaghetti Golem (livello 25). Evoluzioni con rimborso/reset dei punti secondo la regola generale sopra. [Dettagli implementazione](../implementation/SPAGHETTI_GOLEM.md). La [vecchia scheda John](../../content/units/warriors/spaghetti_golem/design/JOHN_IMPLEMENTED.md) è solo storica.

## Questioni aperte — 18, 27.2 e 27.3

Obiettivo concordato: sei specie base per coprire versatilità, difesa, area, cure/resurrezione, evocazione sui due lati e marchi/ricompense. Questa copertura non costituisce una suddivisione in classi obbligatorie. John the Meatball (nome provvisorio dello Spaghetti Golem) è il personaggio iniziale confermato. Restano da scegliere le altre specie, distribuzione effettiva dei ruoli, assegnazione delle classi, assegnazione delle rarità e traguardi di sblocco con Collezione. Le quattro rarità della demo sono definite in Collezione. Per le altre specie restano statistiche, attacco, abilità, passive, potenziamenti e contenuti evolutivi; John dispone della prima configurazione nella sua scheda. Il bestiario è previsto in futuro; l'accessibilità delle opzioni evolutive è già concordata.

## Proposte non confermate

Nessuna proposta nuova introdotta dalla suddivisione. Le possibilità future citate nel testo restano tali e non diventano contenuti obbligatori della demo.
