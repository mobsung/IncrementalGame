# Potenziamenti individuali — seconda tappa

Implementata il 27 settembre 2026. Regole: [economia](../design/07_ECONOMIA_E_POTENZIAMENTI.md) e [scheda John](../../content/units/warriors/spaghetti_golem/design/JOHN_IMPLEMENTED.md). Estende la [prima tappa](PRIMA_TAPPA.md).

## Contenuto disponibile

Aprire **Units**, selezionare **John the Meatball** e scegliere **Upgrades**. I pulsanti mostrano grado, costo e requisito di livello; il tooltip descrive l'effetto. Gli acquisti richiedono saldo sufficiente e un grado disponibile. Sono immediati, anche durante un tentativo, e persistono dopo sconfitta e Chrono break. La nuova navigazione è descritta nella [tappa del campo illustrato](CAMPO_E_NAVIGAZIONE.md).

Primo sottoinsieme Gold individuale, con parametri iniziali configurabili scelti durante l'implementazione:

| Voce | Incremento per grado | Costo iniziale | Crescita prezzo | Limite |
| --- | ---: | ---: | ---: | ---: |
| Maximum Health | +30 | 10 Gold | ×1,18 | 100 |
| Physical Attack | +3 | 15 Gold | ×1,18 | 100 |
| Armor | +2 | 12 Gold | ×1,18 | 100 |

Costo successivo: ceil(C0 × q^n). Valori da bilanciare; non costituiscono il catalogo completo della demo.

I sei acquisti a punti livello usano costi, soglie e limiti già definiti per John. Heavy Meatballs e Crushing Sweep modificano i coefficienti delle azioni. Wide Sweep aumenta la superficie, quindi il raggio cresce con la radice quadrata. Quick Stir riduce il cooldown dei lanci successivi. Reinforced Glass e Strong Noodles amplificano soltanto gli incrementi Gold individuali della copia, anche retroattivamente. Nessun reset libero dei punti.

## Implementazione

- LevelUpgradeDefinition contiene effetti per chiave, descrizione, costo lineare e soglie per grado; GoldUpgradeDefinition contiene statistica, incremento, prezzo geometrico e limite.
- BattleConfig contiene i cataloghi tipizzati e li valida. UpgradePanel li legge e richiede transazioni al modello; non modifica direttamente i saldi.
- UnitProgress conserva due dizionari di gradi per copia. BattleSimulation gestisce gli acquisti senza ricreare i combattenti.
- UnitStats ricostruisce le statistiche dalle Resource e dai progressi. Non moltiplica statistiche già modificate e non muta le definizioni condivise.
- Bonus delle abilità derivati al caricamento e al ripristino: nessuna dipendenza da metadati nascosti.
- Un aumento della vita massima conserva la vita corrente assoluta; non cura né resuscita. Una riduzione limita la vita corrente al nuovo massimo. Un nuovo inizio run tramite Chrono break ripristina la vita piena.
- Un acquisto conserva bersaglio, posizione, azione, tempo residuo, cooldown catturato, contatore passivo e RNG. Alla sconfitta si recupera lo stato temporaneo d'inizio tentativo, mantenendo gli acquisti permanenti.

## Salvataggi e verifiche

Formato versione 2. Migrazione v1: aggiunge i dizionari mancanti senza alterare il tentativo. Validazione di ID, tipi, gradi e soglie di livello; una versione futura sconosciuta blocca il caricamento senza ripiegare su un backup più vecchio.

225 controlli complessivi superati su Godot 4.7: acquisti rifiutati senza effetti collaterali, limiti/prezzi, modificatori retroattivi, danni e settore effettivi, cooldown durante un lancio, sconfitta/Chrono, caricamenti ripetuti, prosecuzione deterministica con potenziamenti, migrazione e pulsanti UI su un profilo isolato.

Avvio e schermate controllati tramite Godot AI. Verificata anche la chiusura/riapertura del profilo esistente senza variazione di vita e Gold nella pausa. Nessun acquisto di test sul profilo reale.

Restano shop globale, Chrono shop, le altre statistiche Gold, collezione e contenuti aggiuntivi. L'offline rimane predisposto ma inattivo.
