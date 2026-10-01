# Campo e schieramento

[Indice e stato del design](00_INDICE.md). Documento operativo; originale conservato intatto.

## Riferimento per il campo

Aggiornamento del 27 settembre: il campo geometrico della prima tappa è stato sostituito dal fondale fieldconcept.jpeg nuovamente fornito e da sprite laterali con profondità sul terreno. Le coordinate di simulazione e le regole di schieramento restano quelle implementate; la trasformazione è visiva. Vedere [campo e navigazione](../implementation/CAMPO_E_NAVIGAZIONE.md). I riferimenti a campo.png sotto sono storici.

**Aggiornamento del 26 settembre 2026:** il giocatore ha richiesto di scartare tutti i vecchi asset. La prima tappa usa un nuovo campo geometrico provvisorio; il precedente uso diretto di `campo.png` descritto sotto è superato. Restano valide le regole geometriche e di schieramento. La configurazione iniziale è descritta in [Prima tappa](../implementation/PRIMA_TAPPA.md).

Per la prima demo si usa direttamente l'immagine `campo.png` fornita dal giocatore come sfondo provvisorio del campo, da sostituire in futuro con una realizzazione grafica migliore. Mostra un'arena bidimensionale continua, senza corsie obbligate, divisa visivamente in campo alleato a sinistra e campo nemico a destra. Gli slot di schieramento sono posizioni fisse distribuite nei rispettivi campi; le unità alleate possono muoversi attorno al proprio slot secondo le regole di [Movimento](04_MOVIMENTO_ALLEATO.md). Nell'immagine sono disegnate nove posizioni sul lato alleato e tre sul lato nemico: per la demo sono tutte posizioni fisiche utilizzabili, mentre il limite iniziale di copie contemporaneamente schierate resta tre alleate e una sul lato nemico. I colori delle caselle illustrano possibili occupazioni, non vincoli permanenti. L'area gialla è la superficie percorribile della prima arena. La fascia rossa sul bordo sinistro è soltanto un elemento visivo: raggiungerla non aggiunge una condizione di sconfitta, che resta la morte di tutte le unità alleate schierate. La fascia grigia sotto l'arena ospiterà i pulsanti per accedere alle altre meccaniche. In futuro potranno esistere altri tipi di terreno con bonus e strategie differenti; i loro effetti saranno progettati successivamente.

## Scelta dell'ondata, sconfitta e ripristino

La **composizione** delle copie assegnate agli slot può cambiare soltanto durante il Chrono break, salvo future meccaniche esplicite. Al Chrono break si scelgono anche le posizioni iniziali, ma queste non diventano vincolanti. Durante la pausa tra due tentativi, le copie già schierate possono essere spostate in **qualsiasi slot compatibile libero**, purché non si superino i limiti numerici e rimanga almeno un'unità alleata. Una copia dotata di entrambi i ruoli può passare da un campo all'altro senza Chrono break. Sul campo alleato è un'unità; sul campo nemico opera come nemico di supporto non attaccabile.

## Comparsa dei nemici nella prima demo

I nemici naturali compaiono sul lato destro dell'arena, nello spazio fra i due slot superiori mostrati sul lato nemico di `campo.png`. I nemici generati da una copia evocatrice schierata sul lato nemico compaiono vicino a quella copia. Dopo la comparsa, entrambi seguono le normali regole di movimento verso le unità del lato alleato. L'evocatrice schierata sul lato nemico resta ferma e non è attaccabile. Le distanze esatte di comparsa, l'eventuale dispersione quando più nemici nascono insieme e le collisioni saranno definite nei sottopunti su geometria e movimento.

## Movimento — azioni, geometria e transizioni

- **Cambio manuale di slot:** durante la pausa ricolloca subito la copia sul nuovo slot e vi centra la zona, azzerando destinazione e attesa del movimento. È distinto dal solo cambio alla postura ferma, che richiede il rientro fisico. Gli attacchi normali in corso perdono il progresso; sullo stesso lato le abilità già avviate proseguono secondo le regole concordate. Cambiare lato cancella le azioni del vecchio ruolo, consumando l'eventuale abilità e avviandone il normale cooldown; restano valide le regole già concordate sulla rimozione degli evocati.

## Limiti numerici degli slot

**Prima configurazione del 30 settembre 2026:** quarto posto alleato acquistabile per 50 Shards nel Chrono shop. Rimangono nove posizioni alleate. Il sistema per supporti nemici compatibili dispone di tre posizioni configurabili a destra (`BattleConfig.support_slots`) e di un solo posto; nessuna specie disponibile dichiara ancora quel ruolo. La geometria scelta è un dato iniziale della demo, non una nuova mappa. [Implementazione](../implementation/MECCANICHE_BASE.md).

- Gli slot schierabili sono una risorsa importante: sbloccarne altri deve essere impegnativo. All'inizio possono essere schierate contemporaneamente fino a **tre unità** sul lato alleato e fino a **un nemico di supporto** del giocatore sul lato nemico. Il limite numerico non fissa tre specifiche posizioni: ogni unità può usare qualunque slot compatibile libero. I posti non devono essere tutti occupati. **Decisione del 1 ottobre 2026:** nella preparazione del Chrono break si può rimuovere anche l’ultima unità alleata; con zero alleati il combattimento non può essere avviato. Il vincolo riguarda Start, non la rimozione durante la preparazione. Una sola copia per specie può essere schierata, indipendentemente da forma/ramo. Fuori preparazione la composizione resta bloccata secondo le regole sopra. Selezionare una copia in riserva e cliccare uno slot libero la schiera in quel punto. Un secondo ed eventualmente un terzo posto sul lato nemico possono essere sbloccati con potenziamenti avanzati. La disposizione geometrica esatta degli slot sarà affrontata nel design della mappa e delle unità.

## Collegamenti

Coordinate logiche, distanze, portata e area: [Combattimento](05_COMBATTIMENTO_E_ABILITA.md). Percorsi e zona alleata: [Movimento](04_MOVIMENTO_ALLEATO.md). Comportamento nemico: [Nemici](02_NEMICI.md). Vittoria e sconfitta: [Ondate ed esiti](06_ONDATE_ED_ESITI.md).

## Questioni aperte — 26.1 e 27.5

Geometria esatta degli slot, distanze e dispersione degli spawn, futuri terreni e bonus restano da progettare. Le collisioni fra combattenti sono già chiarite: il vecchio rinvio non riapre quella decisione. La realizzazione finale appartiene a [Visuale e UI](10_DIREZIONE_VISIVA_E_UI.md).

## Proposte non confermate

Nessuna nuova proposta introdotta dalla migrazione.
