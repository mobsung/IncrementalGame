# Nemici

[Indice e stato del design](00_INDICE.md). Documento operativo derivato dal CORE_DESIGN originale, conservato intatto.

## Decisioni concordate e specifiche

## Movimento e bersagliamento nemico

- Il campo è diviso in un lato alleato e un lato nemico. Gli slot restano fissi, ma le unità alleate schierate possono muoversi entro la zona circolare legata al proprio slot, secondo le regole definite sotto; i nemici combattenti si muovono nell'arena continua secondo la propria statistica di velocità verso l'unità viva più vicina. Nella prima demo seguono un percorso diretto verso il bersaglio senza bloccarsi fra loro; una lieve separazione solo visiva evita la sovrapposizione completa dei gruppi, senza modificare le distanze usate dalle regole di combattimento. Le unità schierate e le copie evocatrici sul lato nemico non sono ostacoli fisici: un nemico può attraversare una posizione occupata quando insegue un altro bersaglio. Quando raggiungono la portata del proprio attacco, si fermano e colpiscono il bersaglio. Durante il movimento rivalutano il bersaglio se un'altra unità alleata schierata o evocata diventa più vicina. Se le distanze sono pari, mantengono il bersaglio attuale; alla prima acquisizione di un bersaglio in parità la scelta è casuale. Un attacco già iniziato si completa prima della rivalutazione, salvo un effetto che dichiari esplicitamente di interromperlo. Se il bersaglio muore, scelgono la nuova unità viva più vicina e riprendono a muoversi. Abilità come provocazione o confusione possono modificare questa scelta.

## Statistiche e crescita dei nemici

Ogni tipo di nemico definisce statistiche base che valgono nella prima ondata: **vita, attacco fisico e/o magico, velocità di movimento, range, Gold fornito, XP fornita, punti anima forniti, velocità d'attacco, armatura e resistenza magica**. Il tipo di attacco e tutti i valori base numerici saranno stabiliti quando si progetteranno e aggiungeranno i singoli nemici. Nella prima demo, a ogni nuova ondata aumentano soltanto vita e attacco fisico/magico; le altre statistiche conservano i valori base, salvo modificatori espliciti delle abilità.

**Formula iniziale concordata per la demo:** `vita(W) = vita_base × 1,08^(W−1)` e `attacco(W) = attacco_base × 1,05^(W−1)`, applicando il secondo fattore alle componenti fisica e magica effettivamente possedute dal nemico. I coefficienti devono rimanere configurabili per il bilanciamento. La crescita distinta fa salire la resistenza dei nemici più velocemente del loro danno.

## Tipi e dipendenze

I tre tipi della demo sono bilanciato, offensivo e speciale. Quantità, gruppi, ordine e comparizione speciale con ricompense ×5 sono definiti in [Ondate](06_ONDATE_ED_ESITI.md). Le posizioni di comparsa sono in [Campo](03_CAMPO_E_SCHIERAMENTO.md). Per nemici evocati e supporti non attaccabili consultare [Evocazioni in battaglia](05_COMBATTIMENTO_E_ABILITA.md); per i pool delle ricompense consultare [Economia](07_ECONOMIA_E_POTENZIAMENTI.md).

## Questioni aperte — 20 e 27.4

Definire valori base e tipo di attacco di ciascun nemico, ricompense Gold, bilanciamento e interazioni specifiche con evocatrici. La crescita di vita e attacco è già concordata. Le future schede saranno una per tipo in nemici/.

### Configurazione iniziale della prima tappa — 26 settembre 2026

Su delega esplicita del giocatore sono stati scelti e implementati i valori iniziali di [Stone Drifter](nemici/BILANCIATO.md), [Ember Mite](nemici/OFFENSIVO.md) e [Stone Warden](nemici/SPECIALE.md). Queste schede chiudono i valori di partenza per la prova; bilanciamento definitivo e interazioni con evocatrici restano aperti.

## Proposte non confermate

Nessuna proposta nuova introdotta dalla suddivisione. Le possibilità future citate nel testo restano tali e non diventano contenuti obbligatori della demo.
