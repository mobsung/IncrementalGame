# Core design — gioco idle a ondate

Stato: documento di lavoro. Riassume le decisioni prese nella discussione e distingue le questioni ancora aperte. Il progetto Godot attuale rappresenta una versione precedente: questo documento descrive la direzione della futura riprogettazione, non necessariamente il comportamento del gioco già implementato.

## Visione

Il giocatore gestisce una squadra di creature che combatte automaticamente contro ondate di nemici sempre più difficili. La progressione idle è la base del gioco: l'obiettivo principale è costruire combinazioni di creature, abilità e potenziamenti capaci di raggiungere ondate più alte. Collezionare creature amplia le possibilità strategiche, ma completare la collezione non è l'obiettivo finale.

Le future meccaniche dovranno contribuire al ciclo centrale di combattimento e crescita. Il valore di una creatura deriva dal ruolo che svolge e dalle interazioni con le altre. Sono previste anche creature che aumentano deliberatamente il rischio per ottenere benefici maggiori.

## Ciclo di gioco concordato

1. Il giocatore schiera le creature e definisce una squadra con ruoli e sinergie.
2. La squadra affronta ondate automatiche di nemici. Le uccisioni generano valuta globale ed esperienza individuale, secondo le regole di eleggibilità dell'ondata.
3. Il giocatore investe valuta e punti ottenuti con i livelli per migliorare statistiche, abilità, passive e sinergie.
4. La squadra avanza finché non riesce più a vincere. Dopo una sconfitta torna all'ondata precedente: può continuare a ottenere valuta, mentre l'esperienza resta bloccata finché non supera l'ondata che l'aveva fermata.
5. Il giocatore sceglie se accumulare valuta per superare il limite attuale e raggiungere nuove soglie di sblocco, oppure fare prestigio e ripartire dalle prime ondate per far crescere ulteriormente le creature.

Il blocco dell'esperienza dipende dal record/progresso della squadra, non dalla storia individuale di ciascuna creatura. I bonus XP non aggirano questo blocco. Le creature nuove e le copie aggiuntive richiedono crescita effettiva; non è previsto un recupero automatico dei livelli.

## Combattimento, campo e fine dell'ondata

- Il campo è diviso in un lato alleato e un lato nemico. Le creature occupano posizioni fisse; i nemici combattenti si muovono verso il lato alleato.
- Gli slot schierabili sono una risorsa importante: sbloccarne altri deve essere impegnativo. Sul lato nemico si parte con uno slot; un secondo ed eventualmente un terzo possono essere sbloccati con potenziamenti avanzati. Il numero iniziale di slot alleati è ancora da definire.
- La squadra perde quando muoiono tutte le creature schierate negli slot alleati. Le unità alleate evocate non impediscono la sconfitta.
- Superare un'ondata non resuscita le creature morte. La vita residua delle creature sopravvissute passa all'ondata successiva. La resurrezione può avvenire tramite abilità oppure dopo la sconfitta e il ritorno all'ondata precedente.
- Una creatura schierata che muore durante un'ondata vinta dalle compagne riceve comunque l'esperienza spettante per quell'ondata, quando l'XP è disponibile.
- L'ondata termina quando muore l'ultimo nemico generato naturalmente. I nemici evocati non ne prolungano la durata.

Alcune creature evocatrici potranno essere schierate su entrambi i lati. Sul lato alleato evocano unità che aiutano la squadra. Sul lato nemico sono considerate entità nemiche di supporto **non attaccabili**: occupano uno slot e applicano gli effetti delle proprie abilità, per esempio generando avversari con ricompense aggiuntive. Le modalità precise dipenderanno dal design della singola creatura. L'eventuale potenziamento dei nemici naturali è una possibilità da esplorare più avanti.

## Risorse, livelli e potenziamenti

La valuta principale è globale. L'esperienza appartiene invece a ciascuna creatura. La quantità di XP ottenuta non cresce automaticamente con il numero dell'ondata: deriva dalle uccisioni e dalle meccaniche della squadra. Per esempio, un potenziamento può aumentare l'XP concessa da ogni nemico, mentre un marchio può aumentare l'XP del bersaglio sconfitto. I valori di questi esempi non sono ancora fissati.

Ogni livello assegna alla creatura punti spendibili per statistiche, abilità e passive. I potenziamenti possono avere costi diversi, costi crescenti, limiti di grado e requisiti di livello. Le statistiche standard devono essere investimenti utili anche quando restano punti da spendere. Le scelte acquistate con punti livello hanno un peso maggiore perché questi punti sono più difficili da ottenere.

Esistono miglioramenti globali e individuali per statistiche e altre meccaniche. Una direzione concordata per distinguere le due economie è questa: la valuta globale compra i potenziamenti di base; i punti livello possono aumentare l'efficacia di quei potenziamenti e acquistare miglioramenti esclusivi di abilità o passive. La struttura precisa dei negozi, delle categorie e dei costi è ancora da definire.

I punti livello spesi **non sono redistribuibili nella versione iniziale**. Un sistema di reset potrà essere valutato in futuro. Non ci sono esclusioni permanenti fra rami di potenziamento: una creatura può teoricamente completarli tutti, ma crescita dell'XP richiesta e costi devono rendere l'obiettivo impegnativo e dare peso all'ordine delle scelte.

Per le formule che combinano bonus dello stesso valore, si applicano prima tutti gli incrementi lineari/additivi, poi i moltiplicatori. Esempio: `(1 XP base + 2 XP dal marchio) × 1,5 = 4,5 XP`. Restano da definire regole di arrotondamento e combinazione fra più moltiplicatori.

## Creature, copie ed evoluzioni

Si abbandona la struttura attuale in cui tutte le creature derivano da un'unica creatura iniziale. Un sistema di evocazioni in stile gacha assegna il primo stadio di una creatura; si possono ottenere più copie della stessa specie. Ogni copia ha la propria esperienza, i propri livelli e i propri punti investiti.

Ogni specie può avere un'evoluzione lineare o ramificata. Evolvere cambia l'aspetto e conserva abilità, passive e investimenti precedenti. Un'evoluzione può aggiungere abilità o passive, introdurre nuove meccaniche in quelle esistenti, aumentarne l'efficacia oppure alzare i limiti dei loro potenziamenti. Le differenze fra singole specie e rami evolutivi saranno definite nel design delle creature.

## Statistiche e significato concordato

| Statistica | Significato di design |
| --- | --- |
| Attacco fisico | Potenza usata dagli attacchi o dalle abilità che dichiarano una scala fisica. |
| Attacco magico | Potenza usata dagli attacchi o dalle abilità che dichiarano una scala magica. |
| Vita | Danni sopportabili prima della morte. |
| Difesa | Riduce i danni ricevuti, con rendimenti decrescenti da specificare. Per ora una sola difesa copre fisico e magico. |
| Velocità d'attacco | Frequenza degli attacchi base; non modifica automaticamente le abilità. |
| Range | Portata dell'attacco base. Le abilità possono avere una propria portata. |
| Cooldown | Tempo tra gli utilizzi di un'abilità; può essere modificato entro limiti da definire. |
| Multi hit | Possibilità di aggiungere colpi all'attacco base, normalmente contro lo stesso bersaglio. |
| Multi cast | Possibilità di ripetere un'abilità compatibile senza attendere un nuovo cooldown. |
| Area d'effetto | Superficie interessata da un'abilità. Un bonus del 20% aumenta la **superficie** del 20%, non il raggio. |
| Potenza abilità | Modifica solo i parametri dichiarati dalla singola abilità: danno, cura, caratteristiche delle unità evocate, ricompense dei nemici evocati o altri effetti specifici. |

Le probabilità, i limiti e le regole di attivazione di multi hit e multi cast richiedono ancora una specifica numerica. La portata e l'area dovranno essere leggibili direttamente sul campo.

### Catena dei critici

Critico, supercritico e ultracritico sono stadi successivi. Super e ultra sono inizialmente bloccati e richiedono uno sblocco. Si verifica il supercritico solo dopo un critico riuscito; si verifica l'ultracritico solo dopo un supercritico riuscito. Le rispettive chance sono quindi **condizionate allo stadio precedente**.

Il danno si moltiplica in sequenza: `danno base × crit damage × super crit damage × ultra crit damage`, applicando solo i moltiplicatori degli stadi realmente raggiunti. Per esempio, con 100 danni e moltiplicatori ×2, ×3, ×4, un ultracritico infligge 2.400 danni. Le statistiche sono: crit chance, crit damage, super crit chance, super crit damage, ultra crit chance e ultra crit damage.

Le abilità devono indicare se possono effettuare critici. Lo sblocco e il bilanciamento dei tre stadi, i limiti delle chance e l'interazione con multi hit e multi cast sono da precisare.

## Prestigio

Il prestigio resetta le ondate e riapre la possibilità di ottenere XP affrontandole nuovamente. **Non resetta** valuta globale, livelli delle creature o potenziamenti base; le creature e i loro investimenti rimangono. La quantità di punti prestigio guadagnati dipende dalle ondate raggiunte. Formula, costi, utilizzi dei punti e possibili soglie sono ancora da sviluppare.

Questo crea una scelta ricorrente: continuare a ottenere valuta senza XP per tentare di superare una soglia, oppure resettare le ondate e usare una nuova progressione per allenare la squadra e le copie aggiuntive.

## Questioni introdotte ma ancora da sviluppare

1. **Regole dell'XP:** valore base per uccisione, distribuzione tra creature schierate, arrotondamenti, interazione tra bonus globali e individuali, e trattamento dell'XP durante l'ondata che sblocca il record.
2. **Prestigio:** formula dei punti in funzione delle ondate, utilizzi, ritmo desiderato e modo in cui il prestigio interagisce con le nuove soglie di contenuto.
3. **Evocazioni gacha:** valuta e costo, probabilità, gestione dei duplicati e accesso a nuove specie.
4. **Potenziamenti:** struttura dei miglioramenti globali e individuali, prezzi in valuta, costi in punti livello, limiti, prerequisiti e relazione esatta tra potenziamenti base e bonus di efficacia.
5. **Combattimento:** formule di attacco e difesa, comportamento dei bersagli, posizioni e numero di slot alleati, movimento dei nemici, durata delle ondate, cure e resurrezioni.
6. **Evocazioni in battaglia:** numero e durata delle unità evocate, limiti, comportamento alla fine dell'ondata e ricompense degli evocati. È stata proposta, ma non ancora concordata, la scomparsa senza ricompense degli evocati ancora vivi quando muore l'ultimo nemico naturale.
7. **Design delle creature:** ruoli, abilità, passive, differenze tra lato alleato e lato nemico, evoluzioni e sinergie concrete. Sono possibili build che potenziano i nemici naturali, da definire per singola creatura.
8. **Ritmo ed economia:** bilanciamento tra spinta verso nuove ondate, farming di valuta, crescita delle copie e prestigî ripetuti; crescita delle statistiche dei nemici; rischio e ricompense degli evocatori nemici.
9. **Direzione visiva:** aspetto delle creature, leggibilità dei ruoli e delle evoluzioni, stile generale, presentazione del campo e dell'interfaccia.

## Criterio per le prossime decisioni

Ogni nuova meccanica deve contribuire al ciclo di combattimento, crescita e avanzamento. Deve offrire una scelta comprensibile al giocatore e lasciare spazio a nuove creature o abilità senza richiedere eccezioni arbitrarie per ogni contenuto.
