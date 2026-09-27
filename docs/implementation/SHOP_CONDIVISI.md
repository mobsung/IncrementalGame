# Primi shop condivisi

Implementati e verificati il 27 settembre 2026. Questa tappa copre le statistiche già supportate dalla demo. Non completa tutti i cataloghi previsti dal design.

## Valori iniziali configurabili

I valori seguenti sono parametri iniziali di bilanciamento, modificabili nelle Resource di `resources/shops/`. Costo del prossimo grado: `ceil(costo iniziale × crescita^gradi acquistati)`.

| Global shop (Gold) | Effetto per grado | Primo costo | Crescita | Gradi massimi |
| --- | --- | ---: | ---: | ---: |
| Squad Armor | +2 armatura | 50 | 1,20 | 100 |
| Gold per Defeat | +0,25 Gold per nemico | 60 | 1,20 | 100 |
| Experience per Defeat | +0,10 XP per nemico | 80 | 1,20 | 100 |
| Souls per Defeat | +0,10 anime per nemico | 80 | 1,20 | 100 |
| Gold Yield | +5% Gold | 100 | 1,25 | 50 |
| Shared Wisdom | +5% XP | 120 | 1,25 | 50 |
| Soul Yield | +5% anime | 120 | 1,25 | 50 |

| Chrono shop (Shards) | Effetto per grado | Primo costo |
| --- | --- | ---: |
| Enduring Vitality | +20% vita massima | 1 |
| Lasting Strength | +10% attacco fisico | 2 |
| Timeless Armor | +3 armatura | 1 |
| Golden Memory | +10% Gold | 2 |
| Learned Memory | +10% XP | 2 |
| Soul Memory | +10% anime | 2 |

Tutti i sei acquisti Chrono hanno crescita 1,60 e massimo 20 gradi. Nessuna soglia di livello aggiunta. Le regole di assegnazione dell'XP restano quelle del combattimento: il bonus non abilita XP su sconfitte o ondate non idonee.

## Calcolo e transazioni

`ShopModifiers` applica `(base + incrementi additivi) × (1 + percentuali globali) × (1 + percentuali Chrono)`. Le percentuali nello stesso gruppo si sommano. Gli amplificatori di John continuano ad agire soltanto sugli incrementi Gold individuali.

I bonus ricompensa sono calcolati alla morte del nemico. Un acquisto non modifica quanto già accumulato nel tentativo. Frazioni conservate in calcoli e saldi. Aumentare la vita massima non cura; il Chrono break cura al nuovo massimo. Acquisti durante lo scontro conservano azioni, timer e generatore casuale.

`BattleSimulation.shop_offer` determina prezzo e disponibilità; `purchase_shop_upgrade` ricontrolla e addebita la valuta corretta. Lo stesso `SharedShopPanel` genera i due pannelli dalle Resource, mostrando grado, effetto, prossimo prezzo e descrizione al passaggio del mouse. Ranks e saldi sono permanenti, anche dopo sconfitta e Chrono break.

## Salvataggio e verifiche

Formato v3: `PlayerProfile` aggiunge `global_ranks` e `chrono_ranks`, con identificativi stabili. La migrazione v2 inizializza questi dizionari vuoti preservando gli altri dati; v1 passa prima dalla migrazione degli acquisti individuali. Caricamenti ricostruiscono i bonus senza accumularli. Identificativi sconosciuti, gradi negativi, frazionari o oltre il limite sono rifiutati.

Suite completa: **282 controlli, zero fallimenti**, Godot 4.7 installato. Comprende transazioni, formule, ricompense frazionarie tramite uccisione reale nella simulazione, stato durante acquisti, sconfitta/Chrono, ripresa deterministica, migrazione v2, roundtrip v3, dati invalidi e pulsanti istanziati con profilo isolato.

Avvio tramite Godot AI e log correnti senza errori. Pannelli ispezionati visivamente a 1920×1080. Profilo reale preservato in pausa, ondata 7, record 9, Gold 155, HP 309.591452257017/630; nessun acquisto di prova addebitato.

Restano cataloghi completi, slot aggiuntivi e schieramento di più copie, multi hit/cast e bilanciamento prolungato. La progressione offline resta predisposta ma inattiva.
