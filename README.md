# ZITR_PLANNINGV2 – iTrainee Planning

Een SAP RAP-applicatie (ABAP RESTful Application Programming Model) voor het beheren van
de stamgegevens van de iTrainee-planning: **docenten**, **lokalen** en **feestdagen**.
Elke entiteit is te onderhouden via een eigen SAP Fiori elements-app op basis van OData V4.

## Functionaliteit

| Entiteit   | Gegevens                                                              | Fiori-service         |
|------------|-----------------------------------------------------------------------|-----------------------|
| Docent     | Afkorting, volledige naam, vakgebied, e-mail, extern ja/nee, actief   | `ZPL2UI_TEACHER_O4`   |
| Lokaal     | Naam, capaciteit, e-mailadres van het lokaal, actief                  | `ZPL2UI_ROOM_O4`      |
| Feestdag   | Datum en omschrijving                                                 | `ZPL2UI_HOLIDAY_O4`   |

Alle entiteiten ondersteunen aanmaken, wijzigen en verwijderen, met **draft-afhandeling**
(tussentijds opslaan), optimistic locking via ETags en automatische administratieve velden
(aangemaakt/gewijzigd door en op).

## Architectuur

Per entiteit (`TEACHER`, `ROOM`, `HOLIDAY`) volgt het project de standaard RAP-opbouw:

| Laag                 | Objecten                                          | Omschrijving                              |
|----------------------|---------------------------------------------------|-------------------------------------------|
| Database             | `ZPL2<ENTITEIT>`, `ZPL2<ENTITEIT>_D`              | Persistente tabel en drafttabel           |
| Basis-CDS (root)     | `ZPL2R_<ENTITEIT>`                                 | Root view entity op de tabel              |
| Gedrag (managed)     | `ZPL2R_<ENTITEIT>` (BDEF), `ZPL2BP_R_<ENTITEIT>`   | Managed behavior met draft                |
| Projectie            | `ZPL2C_<ENTITEIT>` (+ BDEF, `ZPL2BP_C_<ENTITEIT>`) | Consumptie-/projectieview                 |
| UI-annotaties        | `ZPL2C_<ENTITEIT>` (DDLX)                          | Metadata-extensie voor Fiori elements     |
| Toegangscontrole     | DCLS per view                                     | Autorisatiechecks                         |
| Service              | `ZPL2UI_<ENTITEIT>_O4` (SRVD/SRVB)                 | Service-definitie en OData V4 UI-binding  |

## Installatie

Dit project wordt beheerd met [abapGit](https://abapgit.org/).

1. Zorg dat abapGit in het doelsysteem beschikbaar is (bijv. `ZABAPGIT`).
2. Kies **New Online** en vul in:
   - URL: `https://github.com/mathit/zitr_planningv2.git`
   - Pakket: `ZITR_PLANNING_V2` (of een eigen Z-pakket)
   - Folder logic: **Prefix**
3. Voer een **Pull** uit en activeer alle objecten.
4. Publiceer de service bindings `ZPL2UI_*_O4` in ADT.
5. Open de Fiori-preview vanuit de service binding.

## Vereisten

- SAP S/4HANA Cloud Private Edition (of een ander ABAP-systeem met ondersteuning voor RAP en draft)
- abapGit
