# Core design — gioco idle a ondate

Stato: documento di lavoro. Riassume le decisioni prese nella discussione e distingue le questioni ancora aperte. Il progetto Godot attuale rappresenta una versione precedente: questo documento descrive la direzione della futura riprogettazione, non necessariamente il comportamento del gioco già implementato.

## Visione

Il giocatore gestisce una squadra di unità che combatte automaticamente contro ondate di nemici sempre più difficili. La progressione idle è la base del gioco: l'obiettivo principale è costruire combinazioni di unità, abilità e potenziamenti capaci di raggiungere ondate più alte. Collezionare unità amplia le possibilità strategiche, ma completare la collezione non è l'obiettivo finale.

Le future meccaniche dovranno contribuire al ciclo centrale di combattimento e crescita. Il valore di un'unità deriva dal ruolo che svolge e dalle interazioni con le altre. Sono previste anche unità che aumentano deliberatamente il rischio per ottenere benefici maggiori.

## Terminologia

- **Unità:** personaggio alleato sul campo; un'unità evocata è distinta da un'unità schierata in uno slot.
- **Nemico:** personaggio o combattente del lato avversario, compresi quelli generati dalle evocazioni. Un esemplare posseduto dal giocatore e assegnato a uno slot nemico opera in battaglia come **nemico di supporto non attaccabile**.

## Ciclo di gioco concordato

1. Il giocatore schiera le unità e definisce una squadra con ruoli e sinergie.
2. La squadra affronta ondate automatiche di nemici. Le uccisioni generano valuta globale ed esperienza individuale, secondo le regole di eleggibilità dell'ondata.
3. Il giocatore investe valuta e punti ottenuti con i livelli per migliorare statistiche, abilità, passive e sinergie.
4. Il giocatore seleziona un'ondata accessibile. Di default la squadra ripete quell'ondata senza avanzare automaticamente. Può attivare l'avanzamento automatico: la squadra supera ondate successive finché perde, poi torna all'ondata selezionata manualmente.
5. Dopo una sconfitta l'esperienza resta bloccata finché la squadra non supera l'ondata che l'aveva fermata. Ripetere ondate già superate consente di ottenere valuta, ma non XP. Il giocatore sceglie se accumulare valuta per tentare una nuova soglia oppure fare prestigio e ripartire dalle prime ondate per far crescere ulteriormente le unità.

Il blocco dell'esperienza dipende dal record/progresso della squadra, non dalla storia individuale di ciascun'unità. I bonus XP non aggirano questo blocco. Le nuove unità e le copie aggiuntive richiedono crescita effettiva; non è previsto un recupero automatico dei livelli.

## Combattimento, campo e fine dell'ondata

### Riferimento per il campo

Lo schizzo `campo.png` fornito dal giocatore mostra un'area di combattimento condivisa, divisa visivamente in campo alleato a sinistra e campo nemico a destra. Le posizioni di schieramento possono essere distribuite all'interno dei rispettivi campi; i colori e il numero di caselle disegnate servono da esempio, non fissano da soli il numero finale di slot. La fascia grigia sotto l'arena ospiterà i pulsanti per accedere alle altre meccaniche. L'assenza di corsie nello schizzo suggerisce un campo condiviso; percorsi e regole di movimento dei nemici restano da precisare.

### Scelta dell'ondata, sconfitta e ripristino

Il giocatore sceglie manualmente l'ondata da ripetere. L'opzione **avanzamento automatico** è disattivata per impostazione iniziale: dopo una vittoria la squadra affronta di nuovo l'ondata scelta. Se l'opzione è attiva, ogni vittoria porta all'ondata successiva e ogni sconfitta riporta all'ondata scelta manualmente; poi il ciclo riprende da lì. L'avanzamento oltre l'ondata scelta dipende quindi da questa opzione.

La squadra conserva vita residua e morti dopo una vittoria. All'inizio di **ogni tentativo** si registra lo stato delle unità schierate; in caso di sconfitta si ripristina lo stato registrato all'inizio dell'ultimo tentativo rilevante, non quello della prima volta in cui l'ondata era stata raggiunta. Per le ripetizioni dell'ondata scelta, un nuovo tentativo dopo una vittoria parte dallo stato lasciato dalla vittoria precedente e registra un nuovo punto di ripristino. Il contenuto esatto del punto di ripristino oltre a vita e stato vivo/morto (per esempio cooldown ed effetti temporanei) resta da definire.

Il giocatore può ritirarsi volontariamente verso un'ondata precedente già sbloccata, senza riattivare l'XP. Il limite inferiore del ritiro è l'ondata **subito dopo l'ultimo multiplo di 10 superato**: dopo aver completato la 10 si può tornare al massimo alla 11; dopo aver completato la 20, alla 21, e così via. Prima del completamento della 10 il limite è la 1. Il prestigio resetta la progressione delle ondate e quindi anche questo limite.

Se la squadra non riesce più a ottenere uccisioni o ad avanzare in nessuna ondata accessibile, il giocatore deve effettuare un prestigio. Non è prevista una meccanica di riposo fuori dal combattimento come via d'uscita. Il prestigio è sempre attivabile, anche quando assegna zero punti, e cura e riporta in vita tutte le unità schierate.

La **composizione** delle copie assegnate agli slot può cambiare soltanto durante il prestigio, salvo future meccaniche esplicite. Al prestigio si scelgono anche le posizioni iniziali, ma queste non diventano vincolanti. Durante la pausa tra due tentativi, le copie già schierate possono essere spostate in **qualsiasi slot compatibile libero**, purché non si superino i limiti numerici e rimanga almeno un'unità alleata. Una copia dotata di entrambi i ruoli può passare da un campo all'altro senza prestigio. Sul campo alleato è un'unità; sul campo nemico opera come nemico di supporto non attaccabile.

- Il campo è diviso in un lato alleato e un lato nemico. Le unità schierate occupano posizioni fisse durante il combattimento; i nemici combattenti si muovono secondo la propria statistica di velocità verso l'unità viva più vicina. Quando raggiungono la portata del proprio attacco, si fermano e colpiscono il bersaglio. Se il bersaglio muore, scelgono la nuova unità viva più vicina e riprendono a muoversi. Abilità come provocazione o confusione possono modificare questa scelta.
- Gli slot schierabili sono una risorsa importante: sbloccarne altri deve essere impegnativo. All'inizio possono essere schierate contemporaneamente fino a **tre unità** sul lato alleato e fino a **un nemico di supporto** del giocatore sul lato nemico. Il limite numerico non fissa tre specifiche posizioni: ogni unità può usare qualunque slot compatibile libero. I posti non devono essere tutti occupati, ma deve essere sempre schierata almeno un'unità alleata. Un secondo ed eventualmente un terzo posto sul lato nemico possono essere sbloccati con potenziamenti avanzati. La disposizione geometrica esatta degli slot sarà affrontata nel design della mappa e delle unità.
- La squadra perde quando muoiono tutte le unità schierate negli slot alleati. Le unità alleate evocate non impediscono la sconfitta.
- Superare un'ondata non resuscita le unità morte. La vita residua delle unità sopravvissute passa all'ondata successiva. La resurrezione può avvenire tramite abilità o con il prestigio; dopo una sconfitta si ripristina lo stato registrato per il tentativo, che può ancora contenere unità morte.
- Un'unità schierata che muore durante un'ondata vinta dalle compagne riceve comunque l'esperienza spettante per quell'ondata, quando l'XP è disponibile.
- L'ondata termina quando muore l'ultimo nemico generato naturalmente. I nemici evocati non ne prolungano la durata.

### Pausa tra i tentativi

Il gioco può entrare in pausa **solo al termine di un tentativo**, per vittoria o sconfitta; non si arresta nel mezzo di un'ondata. Durante il combattimento il giocatore può **prenotare manualmente** una pausa: la richiesta viene consumata al prossimo esito. Può inoltre attivare **pausa alla sconfitta**, un interruttore persistente e inizialmente spento: ogni sconfitta futura mette il gioco in pausa finché il giocatore non lo disattiva. In pausa può spostare le copie già schierate tra slot disponibili, anche da un campo all'altro se hanno entrambi i ruoli, e dopo una sconfitta può selezionare un'ondata precedente entro il limite consentito.

Durante la pausa tutto il combattimento è fermo: il tempo, i cooldown e gli effetti non avanzano e non si attivano cure. La pausa si colloca dopo l'applicazione dell'esito e prima dell'avvio del tentativo seguente. Durante la pausa l'intera simulazione è ferma: non avanzano tempo, cooldown o effetti e non si attivano cure. Quando il giocatore la disattiva, il gioco riprende e non rientra in pausa per il medesimo esito. Prenotazione manuale e pausa alla sconfitta non si accumulano: un esito produce al massimo una pausa. Il prestigio è indipendente da questa meccanica e può essere attivato in qualsiasi momento, anche durante un'ondata.

### Bersagliamento delle unità

Ogni unità può scegliere una delle seguenti priorità per il proprio bersaglio, con **nemico più vicino** come impostazione iniziale:

1. Nemico attaccabile più vicino all'unità e nel suo range.
2. Nemico attaccabile con più **salute massima** nel range dell'unità.
3. Nemico attaccabile con meno **salute massima** nel range dell'unità.
4. Nemico attaccabile più lontano dall'unità, ma ancora nel suo range.

L'unità sceglie un bersaglio valido quando deve acquisirne uno e lo mantiene finché il nemico muore, esce dal range o un'abilità impone un cambio. Se esce dal range, smette di attaccarlo e può cercarne un altro. L'arrivo di un nuovo nemico più prioritario non interrompe l'attacco già in corso. Le priorità 2 e 3 confrontano la salute massima: il danno subito non modifica la posizione del nemico nell'ordinamento. Quando più nemici hanno la stessa priorità al momento dell'acquisizione, l'unità ne sceglie uno casualmente e poi applica la normale regola di mantenimento del bersaglio.

### Struttura iniziale delle ondate

Ogni ondata prevede **12 comparizioni naturali nell'arco di 5 secondi**: sei del tipo bilanciato e sei del tipo offensivo. L'ordine è variabile e viene generata una nuova sequenza a ogni avvio di ondata, compresi i tentativi ripetuti dello stesso numero. Non può contenere più di tre comparizioni consecutive dello stesso tipo. Gli istanti esatti delle comparizioni sono ancora da definire:

1. **Bilanciato:** statistiche equilibrate; compare una sola unità.
2. **Offensivo:** più attacco e meno vita del bilanciato; compaiono **tre unità insieme**, che contano come **un'unica comparizione** delle 12. **Ognuna delle tre unità sconfitte concede la propria ricompensa** in valuta ed esperienza.

Ogni decima ondata (10, 20, 30, ecc.) prevede anche una **tredicesima comparizione finale**: un nemico più potente, con statistiche superiori, che concede **cinque volte l'esperienza e cinque volte la valuta** rispetto alla ricompensa di riferimento. Questo terzo tipo è generato naturalmente e deve essere sconfitto per terminare l'ondata.

Senza bonus o potenziamenti, le 12 comparizioni ordinarie contengono 24 nemici e forniscono quindi 24 XP base se l'ondata viene vinta e l'XP è disponibile. La comparizione speciale ogni dieci ondate aggiunge 5 XP base grazie al suo moltiplicatore ×5, per un totale di 29 XP base in quell'ondata. Gli istanti esatti delle 12 comparizioni, le ricompense di riferimento per il Gold e il momento esatto della tredicesima comparizione sono ancora da definire. Anche il valore numerico delle statistiche e la loro crescita con le ondate restano aperti.

Alcune unità evocatrici potranno essere schierate su entrambi i lati. Sul lato alleato evocano unità che aiutano la squadra. Sul lato nemico sono considerate entità nemiche di supporto **non attaccabili**: occupano uno slot e applicano gli effetti delle proprie abilità, per esempio generando avversari con ricompense aggiuntive. Le modalità precise dipenderanno dal design della singola unità. L'eventuale potenziamento dei nemici naturali è una possibilità da esplorare più avanti.

## Vita, cure e resurrezione

La vita è un valore numerico diretto: 100 HP sono 100 HP. Quando la vita di un'unità o di un nemico raggiunge **0**, il personaggio muore. La vita residua delle unità sopravvissute resta invariata tra le ondate, come stabilito nelle regole del combattimento.

Le cure possono essere espresse come quantità fisse (per esempio +10 HP) oppure come percentuale (per esempio 10% della vita massima). Possono avvenire durante le ondate, quando l'effetto che le produce è disponibile; il comportamento delle singole abilità curative sarà definito nel design delle unità. Una cura ordinaria non agisce su un'unità morta e non può aumentare la sua vita oltre il massimo. Abilità specifiche potranno introdurre eccezioni esplicite, come vita temporanea aggiuntiva.

La resurrezione riporta in vita un'unità morta con il **10% della sua vita massima**. Abilità e potenziamenti specifici potranno aumentare questa percentuale o aggiungere altri effetti. Cura e resurrezione sono meccaniche distinte: solo un effetto di resurrezione può riportare in vita un'unità morta.

## Risorse, livelli e potenziamenti

La valuta principale si chiama **Gold** ed è globale. L'esperienza appartiene invece a ciascun'unità. La quantità di XP ottenuta non cresce automaticamente con il numero dell'ondata: deriva dalle uccisioni e dalle meccaniche della squadra. Senza bonus o potenziamenti acquistati, ogni nemico fornisce **1 XP base**; i nemici con ricompense speciali possono applicare il proprio moltiplicatore. Per esempio, un potenziamento può aumentare l'XP concessa da ogni nemico, mentre un marchio può aumentare l'XP del bersaglio sconfitto. I valori di questi esempi non sono ancora fissati.

### Gold ottenuti dalle uccisioni

Ogni nemico naturale o evocato fornisce Gold quando viene sconfitto. Ogni nemico possiede una statistica di **Gold base**; ogni unità schierata possiede una statistica **Gold** che contribuisce alla ricompensa di ogni nemico ucciso dalla squadra, indipendentemente da chi dà il colpo finale. Il Gold globale di base e gli effetti additivi applicati al nemico, come marchi o aree d'effetto, si sommano nella stessa fase. Per ogni uccisione si calcola prima:

`Gold additivo = Gold base del nemico + Gold base globale + somma della statistica Gold di tutte le unità schierate + bonus additivi delle abilità applicabili`

Al risultato si applicano poi bonus moltiplicativi in pool distinti: il moltiplicatore globale, i moltiplicatori delle abilità che marchiano il nemico o lo coinvolgono in un'area d'effetto e gli eventuali moltiplicatori propri dei nemici evocati. L'ordine additivi-prima, moltiplicatori-poi segue la regola generale. Più bonus percentuali nello stesso pool si sommano prima di formare un unico moltiplicatore: +20% e +30% nello stesso pool producono ×1,50. I moltiplicatori risultanti dai pool distinti si applicano in sequenza. Il numero esatto di pool delle abilità sarà precisato nel design degli effetti.

Il Gold calcolato per ciascun nemico ucciso, comprese le eventuali frazioni, si accumula nel totale del tentativo senza arrotondare ogni uccisione. Alla fine del tentativo il gioco mostra quanto Gold è stato ottenuto e lo aggiunge al saldo globale in caso di vittoria o sconfitta. Se il giocatore attiva il prestigio durante l'ondata, il Gold accumulato in quel tentativo viene scartato, anche per i nemici già uccisi. I nemici ancora vivi non concedono Gold. Il contributo delle unità schierate non dipende dall'identità di chi infligge il colpo finale. Resta da precisare se le copie del giocatore collocate sul lato nemico contribuiscano a questa somma.

### Esperienza delle ondate e livelli

Ogni unità schierata aggiunge la propria statistica **XP** al pool additivo usato per calcolare l'esperienza concessa da ciascun nemico ucciso. Il pool comprende anche l'XP base del nemico, pari inizialmente a **1 XP per nemico**, l'eventuale base globale e gli effetti additivi applicabili; successivamente si applicano i moltiplicatori nei rispettivi pool, secondo lo stesso principio del Gold. L'identità dell'unità che dà il colpo finale non determina il contributo delle statistiche XP. Ogni unità schierata idonea riceve l'intero valore di XP calcolato per il nemico, senza dividerlo per il numero di unità. Anche un'unità morta durante un'ondata vinta resta idonea, come già stabilito. Il ruolo di eventuali copie schierate sul lato nemico e gli arrotondamenti sono ancora da precisare.

L'XP delle uccisioni di un'ondata, comprese le eventuali frazioni, resta provvisoria fino all'esito e si somma senza arrotondare ogni uccisione. Se la squadra viene sconfitta, quell'ondata non concede XP, anche se alcuni nemici sono già morti. La sconfitta blocca inoltre l'XP della progressione finché la squadra non supera l'ondata che l'ha fermata; quando la supera, le uccisioni del tentativo vittorioso possono concedere XP. Il Gold delle uccisioni resta invece acquisibile anche in caso di sconfitta. Se il giocatore attiva il prestigio durante l'ondata, tutta l'XP provvisoria di quel tentativo viene scartata insieme al Gold del tentativo.

Ogni nuovo livello conferisce **un punto livello** spendibile. L'XP necessaria per il livello successivo deve crescere in modo esponenziale; coefficiente e valore iniziale saranno scelti confrontando il ritmo di crescita effettivo delle nuove copie. La formula candidata è `XP(L→L+1) = arrotonda_per_eccesso(B × 1,30^(L-1))`, con `L` livello attuale e `B` requisito iniziale ancora da decidere. Il coefficiente 1,30 è una prima scelta di bilanciamento da verificare sul ritmo reale dell'XP.

### Potenziamenti acquistati con Gold

Il Gold si spende inizialmente in due modi. Ogni unità possiede un catalogo di potenziamenti individuali **uguale per tutte le unità**: un acquisto migliora soltanto la copia per cui è stato effettuato. Uno shop separato contiene potenziamenti **globali**, i cui effetti si applicano alle unità pertinenti. I potenziamenti acquistati con Gold persistono attraverso il prestigio.

Ogni potenziamento, individuale o globale, ha un proprio limite massimo di acquisti e un prezzo che cresce geometricamente: `costo del prossimo acquisto = arrotonda_per_eccesso(C₀ × q^n)`, dove `C₀` è il prezzo iniziale, `q > 1` il tasso di crescita di quel potenziamento e `n` il numero di acquisti già effettuati. Ogni grado acquistato con Gold concede di norma un incremento di statistica costante, mentre il prezzo aumenta; i punti livello possono amplificare l'efficacia di questi incrementi. Abilità specifiche potranno dichiarare eccezioni esplicite. I valori numerici degli incrementi, i limiti e i prezzi sono ancora da fissare. Il `q` dei prezzi è indipendente dal coefficiente 1,30 candidato per la curva dei livelli.

### Potenziamenti acquistati con punti livello

I punti livello appartengono alla singola copia. Possono aumentare l'efficacia dei potenziamenti base acquistati con Gold e comprare miglioramenti esclusivi di abilità o passive. Ogni potenziamento definisce nella propria risorsa i parametri configurabili: **costo iniziale**, **incremento del costo dopo ogni acquisto**, **numero massimo di gradi**, **livello minimo richiesto per sbloccare il potenziamento** ed eventuali **soglie di livello aggiuntive per singoli gradi**.

Il costo cresce in modo lineare, non esponenziale: `costo del prossimo grado = costo iniziale + incremento × gradi già acquistati`. Per esempio, con costo iniziale 1 e incremento 1, i gradi successivi costano 1, 2, 3 punti. Valori e requisiti possono differire fra potenziamenti. Le soglie per i singoli gradi sono facoltative: un potenziamento può essere disponibile dal livello 5 ma richiedere, per esempio, il livello 15 per il terzo grado. I costi e i limiti precisi e l'effetto dei gradi sulle singole abilità sono ancora da progettare.

Le statistiche standard devono restare investimenti utili anche quando restano punti da spendere. Le scelte acquistate con punti livello hanno un peso maggiore perché questi punti sono più difficili da ottenere.

I punti livello spesi **non sono redistribuibili nella versione iniziale**. Un sistema di reset potrà essere valutato in futuro. Non ci sono esclusioni permanenti fra rami di potenziamento: un'unità può teoricamente completarli tutti, ma crescita dell'XP richiesta e costi devono rendere l'obiettivo impegnativo e dare peso all'ordine delle scelte.

Per le formule che combinano bonus dello stesso valore, si applicano prima tutti gli incrementi lineari/additivi, poi i moltiplicatori. Esempio: `(1 XP base + 2 XP dal marchio) × 1,5 = 4,5 XP`. Più bonus percentuali nello stesso pool si sommano (per esempio +20% e +30% danno ×1,50); i pool distinti si moltiplicano tra loro. I risultati frazionari restano conservati durante i calcoli e si sommano senza arrotondamento per singola uccisione. Il modo di mostrare o eventualmente arrotondare il totale al momento dell'assegnazione resta da definire.

## Unità, copie ed evoluzioni

Si abbandona la struttura attuale in cui tutte le unità derivano da un'unica unità iniziale. Un sistema di evocazioni in stile gacha assegna il primo stadio di un'unità; si possono ottenere più copie della stessa specie. Ogni copia ha la propria esperienza, i propri livelli e i propri punti investiti.

### Evocazioni gacha e Dust

Le unità hanno rarità diverse; le probabilità delle evocazioni dipenderanno dalla rarità. Rarità, probabilità esatte e disponibilità delle specie saranno definite durante il design delle unità. Per evocare si usa una nuova valuta, provvisoriamente chiamata **Dust**. Come valore iniziale di lavoro, una evocazione costa **5 Dust**; il costo definitivo sarà deciso più avanti. L'evocazione assegna il primo stadio di una specie e può produrre più copie della stessa specie. Per ora una copia duplicata è semplicemente un'altra copia indipendente: eventuali impieghi aggiuntivi saranno valutati in futuro.

Come prima bozza per ottenere Dust, ogni nemico ucciso fornisce un proprio numero di **punti anima**, una statistica del nemico. I punti anima riempiono un pool comune; ogni volta che si raggiunge la soglia corrente, il giocatore riceve **1 Dust** e il progresso verso il Dust successivo riparte. Il costo in punti anima di ogni nuovo Dust cresce **linearmente**: il Dust numero `k` della run richiede `k × S` punti anima aggiuntivi rispetto al precedente, dove `S` è la soglia iniziale da bilanciare. Con `S = 100` come esempio, il primo Dust richiede 100 punti anima, il secondo ne richiede altri 200 (300 totali nella run) e il terzo altri 300 (600 totali). Quando una singola uccisione supera la soglia corrente, i punti anima eccedenti non si perdono: diventano progresso verso il Dust successivo. Se bastano a superare più soglie, si assegnano i Dust corrispondenti in sequenza. Al prestigio il Dust già ottenuto rimane posseduto, mentre il pool si resetta completamente: i punti anima accumulati vengono azzerati e la soglia per guadagnare altro Dust torna a quella iniziale. Resta da precisare come trattare i punti anima delle uccisioni durante un'ondata interrotta dal prestigio.

Ogni specie può avere un'evoluzione lineare o ramificata. Evolvere cambia l'aspetto e conserva abilità, passive e investimenti precedenti. Un'evoluzione può aggiungere abilità o passive, introdurre nuove meccaniche in quelle esistenti, aumentarne l'efficacia oppure alzare i limiti dei loro potenziamenti. Le differenze fra singole specie e rami evolutivi saranno definite nel design delle unità.

## Statistiche e significato concordato

| Statistica | Significato di design |
| --- | --- |
| Attacco fisico | Potenza usata dagli attacchi o dalle abilità che dichiarano una scala fisica. |
| Attacco magico | Potenza usata dagli attacchi o dalle abilità che dichiarano una scala magica. |
| Vita | Danni sopportabili prima della morte. |
| Armatura | Riduce il danno fisico ricevuto; valori negativi lo amplificano. La curva numerica sarà definita sul modello di League of Legends. |
| Resistenza magica | Riduce il danno magico ricevuto; valori negativi lo amplificano. Usa la stessa curva dell'armatura. |
| Velocità d'attacco | Frequenza degli attacchi base; non modifica automaticamente le abilità. |
| Range | Distanza entro cui l'unità può vedere e acquisire un nemico o un alleato come bersaglio valido per l'azione. È distinta dalla superficie coperta dall'effetto dell'abilità. |
| Cooldown | Tempo tra gli utilizzi di un'abilità; può essere modificato entro limiti da definire. |
| Riduzione cooldown | Riduce il cooldown effettivo con una curva a rendimenti percentuali decrescenti; l'implementazione in punti di rapidità/haste, sul modello di League of Legends, resta da confermare. |
| Multi hit | Numero di colpi eseguiti nella stessa sequenza d'attacco; se un bersaglio muore, i colpi rimanenti possono colpirne altri. |
| Multi cast | Ripetizione di un'abilità compatibile; la forma della ripetizione dipende dalla specifica abilità. |
| Area d'effetto | Superficie coperta da una singola abilità compatibile, come l'esplosione di una palla di fuoco. Un bonus del 20% aumenta la **superficie** del 20%, non il raggio. |
| Potenza abilità | Modifica solo i parametri dichiarati dalla singola abilità: danno, cura, caratteristiche delle unità evocate, ricompense dei nemici evocati o altri effetti specifici. |

Multi hit e multi cast sono potenziamenti rari e molto limitati, perché possono modificare drasticamente l'efficacia di un'unità. I limiti numerici e i modi di ottenere i colpi o i lanci aggiuntivi restano da definire. La portata e l'area dovranno essere leggibili direttamente sul campo.

### Range e area d'effetto

Range e area d'effetto (AoE) sono due misure indipendenti. Il range indica fin dove l'unità vede e può acquisire come bersaglio un nemico o un alleato per attaccarlo, curarlo o potenziarlo. L'area appartiene invece a una specifica abilità e indica la superficie su cui il suo effetto si applica, per esempio l'esplosione di una palla di fuoco attorno al bersaglio. L'illustrazione `area.png` mostra questa distinzione: l'unità raggiunge un punto o bersaglio distante, mentre l'effetto occupa una zona attorno a quel punto. Non tutte le abilità hanno un'area o beneficiano della statistica AoE: va dichiarato per ciascuna abilità.

Un bonus all'area modifica la superficie, non direttamente il raggio. Le unità di misura, la geometria esatta e la visualizzazione di range e area sul campo saranno definite nel design della mappa e dell'interfaccia. Il centro dell'effetto deve essere scelto secondo le regole di bersagliamento dell'abilità e nel range dell'unità. Una volta applicata l'abilità, la sua area può coinvolgere anche altri bersagli situati oltre il range dell'unità.

### Attacchi, abilità e cooldown

Gli attacchi normali e le abilità di una stessa unità non si eseguono contemporaneamente. Quando un'abilità diventa pronta per l'uso, interrompe l'attacco normale in corso e viene utilizzata. L'attacco interrotto perde il progresso: dopo l'abilità, il prossimo attacco inizia da capo. Un'abilità già iniziata si completa prima che ne venga usata un'altra. Il giocatore può assegnare una priorità a ogni abilità di ciascuna unità: se più abilità sono pronte nello stesso momento, viene usata quella con priorità più alta. Il valore predefinito segue l'ordine di sblocco, dando precedenza all'abilità sbloccata prima. Quando termina un'abilità in corso, la scelta successiva considera tutte quelle allora pronte. Se due abilità hanno la stessa priorità, prevale quella sbloccata prima.

Il cooldown è il tempo di attesa necessario prima di riutilizzare un'abilità. La statistica di riduzione cooldown può abbreviare questo tempo; altre meccaniche o abilità potranno influenzarlo. Durante la pausa tra i tentativi il tempo e i cooldown non avanzano. Restano da definire l'istante in cui il cooldown inizia, le condizioni per l'uso delle abilità e il rapporto tra tempi di attacco, velocità d'attacco e durata delle abilità.

### Multi hit e multi cast

Multi hit determina quanti colpi consecutivi compongono un singolo attacco normale. I colpi vengono eseguiti nello stesso momento di attacco, ma sono eventi di danno separati. I colpi mantengono lo stesso bersaglio finché resta vivo. Se muore prima che la sequenza finisca, i colpi rimanenti acquisiscono un nuovo nemico valido secondo la priorità di bersagliamento impostata per l'unità. Ogni colpo verifica indipendentemente la catena critica. Resta da definire cosa accade ai colpi residui se nessun nemico è valido.

Multi cast ripete un'abilità solo quando il design di quella specifica abilità lo prevede. Il significato concreto dipende dall'effetto: per esempio, una palla di fuoco può essere lanciata due volte, mentre altre abilità possono richiedere una forma diversa di ripetizione o non supportarla. Ogni lancio che può crittare verifica indipendentemente la catena critica. Quali effetti siano ripetuti, il numero massimo di lanci e l'interazione con bersagli e cooldown vanno definiti abilità per abilità.

Entrambe le meccaniche devono essere accessibili tramite potenziamenti rari, limitati e progettati con cura, dato il loro forte impatto sulle capacità delle unità.

### Danno, difese e amplificazioni

Il danno fisico e quello magico sottraggono entrambi vita al bersaglio. Il tipo di danno sceglie quale difesa applicare: armatura per il fisico, resistenza magica per il magico.

Ordine concordato: si parte dal danno base, si sommano tutti gli aumenti additivi, si applicano i moltiplicatori, quindi la difesa pertinente riduce il danno finale o lo aumenta se negativa. I moltiplicatori della catena dei critici si applicano solo agli eventi che raggiungono i rispettivi stadi. Le abilità possono introdurre un **ulteriore stadio di amplificazione** del danno, distinto dai bonus generali, per dare peso alle sinergie; più bonus percentuali nello stesso stadio si sommano, mentre gli stadi distinti si moltiplicano. Le singole abilità che aumentano il danno inflitto o ricevuto saranno progettate successivamente.

**Formula concordata per armatura e resistenza magica:** per la difesa pertinente `R ≥ 0`, `danno dopo difesa = danno prima difesa × 100 / (100 + R)`; per `R < 0`, `danno dopo difesa = danno prima difesa × (2 - 100 / (100 - R))`. La difesa agisce soltanto come moltiplicatore del danno finale, non aggiunge vita. Con valori positivi sempre più alti la riduzione si avvicina al 100% senza raggiungerlo; con valori negativi sempre più bassi il danno si avvicina a 2× senza raggiungerlo. La progressione del bonus percentuale rallenta in entrambi i casi.

Per la riduzione cooldown resta da confermare la rappresentazione in punti di rapidità abilità: `cooldown effettivo = cooldown base × 100 / (100 + rapidità abilità)`. Restano da definire eventuali limiti specifici delle abilità.

### Catena dei critici

Critico, supercritico e ultracritico sono stadi successivi. Le statistiche di supercritico e ultracritico esistono fin dall'inizio, ma i potenziamenti per aumentarle sono contenuto avanzato e non sono disponibili subito. Si verifica il supercritico solo dopo un critico riuscito; si verifica l'ultracritico solo dopo un supercritico riuscito. Le rispettive chance sono quindi **condizionate allo stadio precedente**.

Il danno si moltiplica in sequenza: `danno base × crit damage × super crit damage × ultra crit damage`, applicando solo i moltiplicatori degli stadi realmente raggiunti. Per esempio, con 100 danni e moltiplicatori ×2, ×3, ×4, un ultracritico infligge 2.400 danni. Le statistiche sono: crit chance, crit damage, super crit chance, super crit damage, ultra crit chance e ultra crit damage.

Le probabilità di critico normale, supercritico e ultracritico non possono superare il 100% ciascuna; super e ultra restano condizionati al successo dello stadio precedente. Un'abilità può effettuare critici soltanto se questa possibilità è dichiarata esplicitamente nel design della specifica unità e abilità. Ogni colpo aggiuntivo di multi hit e ogni lancio aggiuntivo di multi cast effettua una verifica indipendente della catena critica, quando può crittare. Restano da precisare il bilanciamento dei tre stadi e le condizioni di attivazione di multi hit e multi cast.

## Prestigio

Il prestigio resetta le ondate e riapre la possibilità di ottenere XP affrontandole nuovamente. **Non resetta** valuta globale, livelli delle unità o potenziamenti base; le unità e i loro investimenti rimangono. È sempre attivabile, anche durante un'ondata e con zero punti ottenibili, senza attendere una pausa; riporta in vita e cura completamente le unità schierate. È il momento ordinario in cui si può cambiare quali unità occupano gli slot; fra prestigî è consentito riposizionare quelle già in campo. I punti prestigio dipendono dalla **più alta ondata completata nella run**; iniziare un'ondata senza completarla non aumenta il premio. Se il prestigio viene attivato durante un'ondata, il combattimento termina immediatamente: il Gold e l'XP generati in quell'ondata vengono scartati anche per i nemici già uccisi, mentre i nemici ancora vivi scompaiono senza concedere ricompense. Le ricompense delle ondate e dei tentativi conclusi in precedenza restano possedute. Formula dei punti, costi, utilizzi e possibili soglie sono ancora da sviluppare.

Questo crea una scelta ricorrente: continuare a ottenere valuta senza XP per tentare di superare una soglia, oppure resettare le ondate e usare una nuova progressione per allenare la squadra e le copie aggiuntive.

## Questioni introdotte ma ancora da sviluppare

1. **Regole dell'XP e livelli:** contributo delle copie schierate sul lato nemico, arrotondamenti, eventuali regole di arrotondamento, scelta del requisito iniziale della curva esponenziale e verifica del coefficiente 1,30 nel bilanciamento.
2. **Prestigio:** formula dei punti in funzione delle ondate, utilizzi, ritmo desiderato e modo in cui il prestigio interagisce con le nuove soglie di contenuto.
3. **Evocazioni gacha e Dust:** rarità, probabilità, disponibilità delle specie, costo definitivo, valore iniziale della soglia dei punti anima e ricompense anima delle ondate interrotte. Eventuali usi ulteriori delle copie duplicate sono rinviati.
4. **Potenziamenti:** catalogo concreto dei miglioramenti individuali e globali, valori degli incrementi costanti per grado, prezzi iniziali, coefficienti di crescita e limiti per ciascuno; valori configurati dei costi lineari, limiti e soglie di sblocco dei potenziamenti con punti livello, oltre alla relazione esatta tra potenziamenti base e bonus di efficacia.
5. **Gold:** valori base dei nemici, rendimenti delle ondate ripetute, arrotondamenti e contributo delle copie schierate sul lato nemico.
6. **Vita e cure:** design delle singole abilità curative e di resurrezione, eventuali eccezioni esplicite al limite della vita massima e criteri di scelta dei bersagli.
7. **Multi hit e multi cast:** limiti numerici e accesso ai potenziamenti, comportamento dei colpi residui senza bersaglio; per ogni abilità compatibile, forma della ripetizione e interazione con effetti, bersagli e cooldown.
8. **Range e area:** unità di misura sul campo, geometria e visualizzazione; eventuali regole particolari di portata e AoE delle singole abilità.
9. **Combattimento:** inizio del cooldown e condizioni d'uso; rappresentazione e limiti della riduzione cooldown; definizione degli stadi di amplificazione del danno. Le curve numeriche di armatura e resistenza magica sono concordate. Per le ondate restano aperti gli istanti delle 12 comparizioni nei 5 secondi, i valori e la crescita delle statistiche, il valore delle ricompense per nemico e il tempismo della comparizione speciale. La disposizione geometrica degli slot sarà definita insieme alla mappa e alle unità.
10. **Evocazioni in battaglia:** numero e durata delle unità e dei nemici evocati, limiti, comportamento alla fine dell'ondata e ricompense dei nemici evocati. È stata proposta, ma non ancora concordata, la scomparsa senza ricompense degli evocati ancora vivi quando muore l'ultimo nemico naturale.
11. **Design delle unità:** ruoli, abilità, passive, differenze tra lato alleato e lato nemico, evoluzioni e sinergie concrete. Sono possibili build che potenziano i nemici naturali, da definire per singola unità.
12. **Ritmo ed economia:** bilanciamento tra spinta verso nuove ondate, farming di valuta, crescita delle copie e prestigî ripetuti; crescita delle statistiche dei nemici; rischio e ricompense degli evocatori nemici.
13. **Ripristino e transizioni:** quali stati oltre a vita e stato vivo/morto entrano nel punto di ripristino e come riprendono le ondate dopo la scelta della nuova formazione al prestigio.
14. **Direzione visiva:** aspetto delle unità, leggibilità dei ruoli e delle evoluzioni, stile generale, presentazione del campo e dell'interfaccia.

## Criterio per le prossime decisioni

Ogni nuova meccanica deve contribuire al ciclo di combattimento, crescita e avanzamento. Deve offrire una scelta comprensibile al giocatore e lasciare spazio a nuove unità o abilità senza richiedere eccezioni arbitrarie per ogni contenuto.
