# Economia e potenziamenti

[Indice e stato del design](00_INDICE.md). Documento operativo derivato dal CORE_DESIGN originale, conservato intatto.

## Decisioni concordate e specifiche

## Risorse, livelli e potenziamenti

La valuta principale si chiama **Gold** ed è globale. L'esperienza appartiene invece a ciascun'unità. La quantità di XP ottenuta non cresce automaticamente con il numero dell'ondata: deriva dalle uccisioni e dalle meccaniche della squadra. Senza bonus o potenziamenti acquistati, ogni nemico fornisce **1 XP base**; i nemici con ricompense speciali possono applicare il proprio moltiplicatore. Per esempio, un potenziamento può aumentare l'XP concessa da ogni nemico, mentre un marchio può aumentare l'XP del bersaglio sconfitto. I valori di questi esempi non sono ancora fissati.

## Gold ottenuti dalle uccisioni

Ogni nemico naturale o evocato fornisce Gold quando viene sconfitto. Ogni nemico possiede una statistica di **Gold base**; ogni copia del giocatore schierata, sia sul lato alleato sia sul lato nemico, possiede una statistica **Gold** che contribuisce alla ricompensa di ogni nemico ucciso dalla squadra, indipendentemente da chi dà il colpo finale. Il Gold globale di base e gli effetti additivi applicati al nemico, come marchi o aree d'effetto, si sommano nella stessa fase. Per ogni uccisione si calcola prima:

`Gold additivo = Gold base del nemico + Gold base globale + somma della statistica Gold di tutte le copie del giocatore schierate + bonus additivi delle abilità applicabili`

Al risultato si applicano poi bonus moltiplicativi in pool distinti: il moltiplicatore globale, i moltiplicatori delle abilità che marchiano il nemico o lo coinvolgono in un'area d'effetto e gli eventuali moltiplicatori propri dei nemici evocati. L'ordine additivi-prima, moltiplicatori-poi segue la regola generale. Più bonus percentuali nello stesso pool si sommano prima di formare un unico moltiplicatore: +20% e +30% nello stesso pool producono ×1,50. I moltiplicatori risultanti dai pool distinti si applicano in sequenza. Il numero esatto di pool delle abilità sarà precisato nel design degli effetti.

Il Gold calcolato per ciascun nemico ucciso, comprese le eventuali frazioni, si accumula nel totale del tentativo senza arrotondare ogni uccisione. Alla fine del tentativo il gioco mostra quanto Gold è stato ottenuto e lo aggiunge al saldo globale in caso di vittoria o sconfitta. Se il giocatore attiva il Chrono break durante l'ondata, il Gold accumulato in quel tentativo viene scartato, anche per i nemici già uccisi. I nemici ancora vivi non concedono Gold. Il contributo delle unità schierate non dipende dall'identità di chi infligge il colpo finale. Anche le copie del giocatore collocate sul lato nemico contribuiscono a questa somma.

## Esperienza delle ondate e livelli

Ogni copia del giocatore schierata, sul lato alleato o sul lato nemico, aggiunge la propria statistica **XP** al pool additivo usato per calcolare l'esperienza concessa da ciascun nemico ucciso. Il pool comprende anche l'XP base del nemico, pari inizialmente a **1 XP per nemico**, l'eventuale base globale e gli effetti additivi applicabili; successivamente si applicano i moltiplicatori nei rispettivi pool, secondo lo stesso principio del Gold. L'identità dell'unità che dà il colpo finale non determina il contributo delle statistiche XP. Ogni copia del giocatore schierata, su entrambi i lati, riceve l'intero valore di XP calcolato per il nemico quando l'ondata concede XP, senza dividerlo fra le copie. Anche un'unità alleata morta durante un'ondata vinta resta idonea, come già stabilito.

L'XP delle uccisioni di un'ondata, comprese le eventuali frazioni, resta provvisoria fino all'esito e si somma senza arrotondare ogni uccisione. Se la squadra viene sconfitta, quell'ondata non concede XP, anche se alcuni nemici sono già morti. La sconfitta blocca inoltre l'XP della progressione finché la squadra non supera l'ondata che l'ha fermata; quando la supera, le uccisioni del tentativo vittorioso possono concedere XP. Il Gold delle uccisioni resta invece acquisibile anche in caso di sconfitta. Se il giocatore attiva il Chrono break durante l'ondata, tutta l'XP provvisoria di quel tentativo viene scartata insieme al Gold del tentativo.

## Potenziamenti acquistati con Gold

Il Gold si spende inizialmente in due modi. Ogni copia possiede un catalogo di potenziamenti individuali con le stesse voci disponibili per tutte le copie: acquisti, gradi e limiti sono registrati separatamente per ciascuna copia, anche quando più copie appartengono alla stessa specie. Un acquisto migliora soltanto la copia per cui è stato effettuato. Uno shop separato contiene potenziamenti **globali**, i cui effetti si applicano alle unità pertinenti. I potenziamenti acquistati con Gold persistono attraverso il Chrono break. Gli acquisti possono essere effettuati in qualsiasi momento, anche durante un'ondata, e modificano immediatamente le statistiche interessate. Le regole di aggiornamento della vita corrente e dei cooldown già in corso sono definite in [Combattimento](05_COMBATTIMENTO_E_ABILITA.md).

## Primo catalogo Gold individuale

Ogni copia dispone dello stesso catalogo di potenziamenti Gold individuali, ma conserva separatamente i gradi acquistati. Nella prima demo il catalogo comprende: vita, attacco fisico, attacco magico, armatura, resistenza magica, velocità d'attacco, range, riduzione cooldown, area d'effetto, potenza abilità, Gold ottenuto, XP ottenuta, punti anima forniti e probabilità e danno dei tre stadi critici (normale, super e ultra). Gli effetti su area e abilità si applicano soltanto alle abilità compatibili. **Multi hit** e **multi cast** non appartengono a questo catalogo: restano potenziamenti rari del Chrono shop.

## Primo catalogo dello shop Gold globale

Nella prima demo lo shop globale acquistabile con Gold contiene questi potenziamenti **additivi**: Gold ottenuto, XP ottenuta, area d'effetto, potenza abilità, punti anima forniti dai nemici, probabilità e danno del critico normale, del supercritico e dell'ultracritico, velocità d'attacco, armatura, resistenza magica e riduzione cooldown. I bonus ad area e potenza abilità incidono soltanto sulle abilità compatibili.

Lo stesso shop contiene potenziamenti **moltiplicativi** per Gold ottenuto, XP ottenuta, potenza abilità e punti anima forniti. Gli effetti additivi entrano nella fase additiva della statistica pertinente; i moltiplicatori seguono la regola dei pool concordata. Le statistiche supercritiche e ultracritiche sono quindi disponibili anche nello shop Gold globale della demo; il Chrono shop potrà offrire ulteriori miglioramenti globali e permanenti delle stesse statistiche in un pool distinto.

Questi potenziamenti Gold non richiedono prerequisiti di livello o sblocchi: bastano Gold sufficienti e un grado ancora disponibile sotto il limite configurato. Le soglie di livello già concordate per i potenziamenti acquistati con punti livello restano valide. Prezzi, incrementi, coefficienti di crescita e limiti saranno impostati inizialmente con valori configurabili durante l'implementazione e poi modificati nel bilanciamento.

Ogni potenziamento, individuale o globale, ha un proprio limite massimo di acquisti e un prezzo che cresce geometricamente: `costo del prossimo acquisto = arrotonda_per_eccesso(C₀ × q^n)`, dove `C₀` è il prezzo iniziale, `q > 1` il tasso di crescita di quel potenziamento e `n` il numero di acquisti già effettuati. Ogni grado acquistato con Gold concede di norma un incremento di statistica costante, mentre il prezzo aumenta; i punti livello della copia possono amplificare soltanto gli incrementi dei suoi acquisti individuali, non quelli dello shop globale. Abilità specifiche potranno dichiarare eccezioni esplicite. I valori numerici degli incrementi, i limiti e i prezzi sono ancora da fissare. Il `q` dei prezzi è indipendente dal coefficiente iniziale concordato 1,30 della curva dei livelli.

## Potenziamenti acquistati con punti livello

I punti livello appartengono alla singola copia. Possono aumentare l'efficacia **solo dei potenziamenti Gold individuali acquistati per la stessa copia** e comprare miglioramenti esclusivi di abilità o passive. Non amplificano i bonus acquistati nello shop Gold globale. Ogni potenziamento definisce nella propria risorsa i parametri configurabili: **costo iniziale**, **incremento del costo dopo ogni acquisto**, **numero massimo di gradi**, **livello minimo richiesto per sbloccare il potenziamento** ed eventuali **soglie di livello aggiuntive per singoli gradi**.

Il costo cresce in modo lineare, non esponenziale: `costo del prossimo grado = costo iniziale + incremento × gradi già acquistati`. Per esempio, con costo iniziale 1 e incremento 1, i gradi successivi costano 1, 2, 3 punti. Valori e requisiti possono differire fra potenziamenti. Le soglie per i singoli gradi sono facoltative: un potenziamento può essere disponibile dal livello 5 ma richiedere, per esempio, il livello 15 per il terzo grado. I costi e i limiti precisi e l'effetto dei gradi sulle singole abilità sono ancora da progettare.

Le statistiche standard devono restare investimenti utili anche quando restano punti da spendere. Le scelte acquistate con punti livello hanno un peso maggiore perché questi punti sono più difficili da ottenere.

I punti livello spesi **non sono redistribuibili liberamente nella prima demo**: vengono restituiti soltanto quando la copia evolve. Altre forme di reset potranno essere valutate in futuro. Non ci sono esclusioni permanenti fra rami di potenziamento: un'unità può teoricamente completarli tutti, ma crescita dell'XP richiesta e costi devono rendere l'obiettivo impegnativo e dare peso all'ordine delle scelte.

Per le formule che combinano bonus dello stesso valore, si applicano prima tutti gli incrementi lineari/additivi, poi i moltiplicatori. Esempio: `(1 XP base + 2 XP dal marchio) × 1,5 = 4,5 XP`. Più bonus percentuali nello stesso pool si sommano (per esempio +20% e +30% danno ×1,50); i pool distinti si moltiplicano tra loro. I risultati frazionari restano conservati durante i calcoli e si sommano senza arrotondamento per singola uccisione. Anche i totali assegnati e i saldi conservano le frazioni senza arrotondamenti che alterino il valore effettivo. L'interfaccia può mostrare valori abbreviati o arrotondati per leggibilità, mantenendo il valore esatto per la progressione.

## Punti anima e produzione di Dust

Ogni nemico ucciso, naturale o evocato, fornisce inizialmente **1 punto anima base**. Per calcolare i punti anima dell'uccisione si sommano la base del nemico, i bonus additivi globali, le statistiche anime individuali di tutte le copie del giocatore schierate su entrambi i lati e i bonus additivi applicabili delle abilità; si applicano poi i moltiplicatori nei rispettivi pool, con le stesse regole concordate per Gold e XP. L'identità di chi dà il colpo finale non cambia il contributo delle copie. I valori concreti dei potenziamenti e degli effetti saranno definiti quando verranno aggiunti. I punti anima riempiono un pool comune; ogni volta che si raggiunge la soglia corrente, il giocatore riceve **1 Dust** e il progresso verso il Dust successivo riparte. Il costo in punti anima di ogni nuovo Dust cresce **linearmente**: il Dust numero `k` della run richiede `k × S` punti anima aggiuntivi rispetto al precedente, dove `S` è la soglia iniziale da bilanciare. Per la prima demo `S = 20`: il primo Dust richiede 20 punti anima, il secondo altri 40 (60 totali nella run), il terzo altri 60 (120 totali), il quarto altri 80 (200 totali) e il quinto altri 100 (300 totali). Quando una singola uccisione supera la soglia corrente, i punti anima eccedenti non si perdono: diventano progresso verso il Dust successivo. Se bastano a superare più soglie, si assegnano i Dust corrispondenti in sequenza. Al Chrono break il Dust già ottenuto rimane posseduto, mentre il pool si resetta completamente: i punti anima accumulati vengono azzerati e la soglia per guadagnare altro Dust torna a quella iniziale. I punti anima delle uccisioni durante un'ondata interrotta dal Chrono break vengono scartati insieme a tutti quelli rimasti nel pool. Il Dust già assegnato da tentativi precedenti rimane posseduto.

## Collegamenti

Livelli e restituzione dei punti alle evoluzioni sono in [Unità](01_UNITA.md). Il Dust viene speso secondo [Collezione](08_COLLEZIONE_E_GACHA.md). [Chrono break](09_CHRONO_BREAK_E_SHOP.md) possiede le regole del reset e il proprio shop. Gli aggiornamenti immediati a vita, range e cooldown sono già definiti in [Combattimento](05_COMBATTIMENTO_E_ABILITA.md).

## Questioni aperte — 21–23

Restano prezzi, incrementi, limiti e bilanciamento dei singoli potenziamenti e il Gold base per tipo nemico. I cataloghi e le formule generali sono concordati. Misurare il ritmo con [Bilanciamento](11_BILANCIAMENTO_E_OFFLINE.md). Il numero e l'identità dei pool delle singole abilità si definiscono con quelle abilità.

## Proposte non confermate

Nessuna proposta nuova introdotta dalla suddivisione. Le possibilità future citate nel testo restano tali e non diventano contenuti obbligatori della demo.
