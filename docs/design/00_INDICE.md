# Indice del design

## Decisioni concordate e specifiche

## Visione

Il giocatore gestisce una squadra di unità che combatte automaticamente contro ondate di nemici sempre più difficili. La progressione idle è la base del gioco: l'obiettivo principale è costruire combinazioni di unità, abilità e potenziamenti capaci di raggiungere ondate più alte. Collezionare unità amplia le possibilità strategiche, ma completare la collezione non è l'obiettivo finale.

Le future meccaniche dovranno contribuire al ciclo centrale di combattimento e crescita. Il valore di un'unità deriva dal ruolo che svolge e dalle interazioni con le altre. Sono previste anche unità che aumentano deliberatamente il rischio per ottenere benefici maggiori.

## Terminologia

Il gioco sarà interamente in **inglese**: testi mostrati al giocatore, nomi dei personaggi e nomi delle abilità vanno progettati in inglese. I documenti di lavoro possono continuare in italiano.

- **Unità:** personaggio alleato sul campo; un'unità evocata è distinta da un'unità schierata in uno slot.

- **Nemico:** personaggio o combattente del lato avversario, compresi quelli generati dalle evocazioni. Un esemplare posseduto dal giocatore e assegnato a uno slot nemico opera in battaglia come **nemico di supporto non attaccabile**.

## Ciclo di gioco concordato

1. Il giocatore schiera le unità e definisce una squadra con ruoli e sinergie.
2. La squadra affronta ondate automatiche di nemici. Le uccisioni generano valuta globale ed esperienza individuale, secondo le regole di eleggibilità dell'ondata.
3. Il giocatore investe valuta e punti ottenuti con i livelli per migliorare statistiche, abilità, passive e sinergie.
4. Il giocatore seleziona un'ondata accessibile. Di default la squadra ripete quell'ondata senza avanzare automaticamente. Può attivare l'avanzamento automatico: la squadra supera ondate successive finché perde, poi torna all'ondata selezionata manualmente.
5. Dopo una sconfitta l'esperienza resta bloccata finché la squadra non supera l'ondata che l'aveva fermata. Ripetere ondate già superate consente di ottenere valuta, ma non XP. Il giocatore sceglie se accumulare valuta per tentare una nuova soglia oppure fare Chrono break e ripartire dalle prime ondate per far crescere ulteriormente le unità.

Il blocco dell'esperienza dipende dal record/progresso della squadra, non dalla storia individuale di ciascun'unità. I bonus XP non aggirano questo blocco. Le nuove unità e le copie aggiuntive richiedono crescita effettiva; non è previsto un recupero automatico dei livelli.

## Criterio per le prossime decisioni

Ogni nuova meccanica deve contribuire al ciclo di combattimento, crescita e avanzamento. Deve offrire una scelta comprensibile al giocatore e lasciare spazio a nuove unità o abilità senza richiedere eccezioni arbitrarie per ogni contenuto.

## Come usare questi documenti

Questa cartella è la fonte operativa del design dal 26 settembre 2026. [CORE_DESIGN.md](../../CORE_DESIGN.md) resta intatto come fotografia storica precedente alla suddivisione: non deve essere aggiornato insieme a questi documenti. Il progetto Godot esistente può ancora rappresentare una versione precedente del gioco.

Leggere prima questo indice e poi soltanto i documenti pertinenti al lavoro. Consultare le dipendenze prima di proporre modifiche; aggiornare la sede principale della regola e i rimandi interessati. Nessuna nuova decisione di gameplay è introdotta dalla suddivisione.

| Documento | Sede principale di | Vecchi punti |
| --- | --- | --- |
| [Unità](01_UNITA.md) | Copie, livelli, evoluzioni, rosa e schede delle specie | 18, 27.2–27.3 |
| [Nemici](02_NEMICI.md) | Statistiche base, crescita, comportamento nemico | 20, 26.3, 27.4 |
| [Campo](03_CAMPO_E_SCHIERAMENTO.md) | Arena, slot, composizione, spawn e riposizionamento | 26.1 |
| [Movimento alleato](04_MOVIMENTO_ALLEATO.md) | Posture, zona, velocità, inseguimento e rientri | Integrazione al punto 26 |
| [Combattimento](05_COMBATTIMENTO_E_ABILITA.md) | Statistiche condivise, azioni, formule, cure ed evocazioni | 25, 26.2, 26.4–26.8 |
| [Ondate ed esiti](06_ONDATE_ED_ESITI.md) | Sequenze, avanzamento, pause, vittoria e sconfitta | 20, 26.9 |
| [Economia](07_ECONOMIA_E_POTENZIAMENTI.md) | Ricompense, pool, Dust, shop Gold e punti livello | 21–23 |
| [Collezione](08_COLLEZIONE_E_GACHA.md) | Acquisizione copie, rarità, duplicati e sblocchi | 24 |
| [Chrono break](09_CHRONO_BREAK_E_SHOP.md) | Reset, preparazione, Shards e shop | 19 |
| [Visuale e UI](10_DIREZIONE_VISIVA_E_UI.md) | Riferimenti, scala, leggibilità e indicatori | 27.1, 27.5 |
| [Bilanciamento e offline](11_BILANCIAMENTO_E_OFFLINE.md) | Configurabilità, ritmo e progressione offline | 21, 28 |

I punti 22, 23, 25 e 26 hanno regole generali chiarite; alcuni dati concreti restano aperti. Il punto 27.1 e le regole del movimento sono concordati per la demo. **Riprendere dal 27.2: rosa iniziale di sei specie.** [John the Meatball](unita/SPAGHETTI_GOLEM.md) è stato confermato come specie iniziale; la prima tappa si concentra sulla sua scheda. Le altre specie e le schede complete restano da concordare.

## Metodo di lavoro

Prima di una proposta, riassumere le decisioni pertinenti e controllare anche gli argomenti collegati. Distinguere sempre decisioni, proposte non confermate e questioni aperte. Attendere la conferma del giocatore prima di modificare una regola. Si può presentare insieme un gruppo di questioni correlate, come richiesto per ridurre il contesto. Il 26 settembre 2026 il giocatore ha autorizzato l'implementazione per tappe. Per il perimetro effettivamente realizzato e i limiti correnti vedere [Prima tappa giocabile](../implementation/PRIMA_TAPPA.md).

Quando saranno progettati i contenuti, creare una scheda per specie in unita/ e una per tipo nemico in nemici/, collegate dai rispettivi documenti. Non creare schede inventando valori o abilità.

## Confini fra documenti

Le schede di unità e nemici contengono i propri valori e le eccezioni; le formule comuni appartengono a Combattimento. Il Gold base appartiene al nemico; il calcolo della ricompensa appartiene a Economia. Gli slot appartengono a Campo; le transizioni fra tentativi a Ondate ed esiti; il reset della run a Chrono break. Movimento descrive il comportamento durante la simulazione. I richiami contestuali non costituiscono una seconda definizione della stessa regola.

I riferimenti numerici 18–28 sono mantenuti dalla tabella e dalle questioni aperte dei documenti; i vecchi riepiloghi ripetitivi non sono ricopiati integralmente. Le indicazioni obsolete “da definire” relative a regole successivamente chiarite sono sostituite da rimandi, senza scegliere nuovi valori.

## Integrità della migrazione

Originale preservato byte per byte. SHA-256 al momento della suddivisione:
1FBDD2D33B9DFC073B596BEAE5F21764936C0BB71D8F993AE1924EA902D46C06

Sono stati trasferiti tutti i 122 blocchi delle sezioni tematiche. Il riepilogo finale originale è stato consolidato nella mappa 18–28 e nelle questioni aperte; la dichiarazione iniziale sullo stato del progetto è riportata sopra. Le immagini non sono state spostate o copiate.

## Proposte non confermate

Nessuna nuova proposta di gameplay introdotta da questa migrazione.

## Collocazione nel progetto principale

Questa cartella è stata copiata dal worktree 6d82 nel progetto principale il 26 settembre 2026. I nuovi documenti sono la fonte operativa condivisa per le chat che usano questo progetto. Il CORE_DESIGN.md del progetto principale è stato lasciato intatto e differisce dalla fotografia del worktree usata per la migrazione: il checksum nella sezione Integrità si riferisce a quella fotografia, non al file locale collegato. Non usare il vecchio documento locale per annullare decisioni già consolidate qui.
