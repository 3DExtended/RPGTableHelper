import 'dart:math';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rpg_configuration_model.g.dart';

@JsonSerializable()
@CopyWith()
class RpgConfigurationModel {
  final String rpgName;
  final List<RpgItem> allItems;
  final List<PlaceOfFinding> placesOfFindings;
  final List<ItemCategory> itemCategories;
  final List<CharacterStatsTabDefinition>? characterStatTabsDefinition;
  final List<CraftingRecipe> craftingRecipes;
  final CurrencyDefinition currencyDefinition;

  factory RpgConfigurationModel.fromJson(Map<String, dynamic> json) =>
      _$RpgConfigurationModelFromJson(json);

  RpgConfigurationModel({
    required this.rpgName,
    required this.allItems,
    required this.placesOfFindings,
    required this.currencyDefinition,
    required this.itemCategories,
    required this.characterStatTabsDefinition,
    required this.craftingRecipes,
  });

  Map<String, dynamic> toJson() => _$RpgConfigurationModelToJson(this);

  static RpgConfigurationModel getBaseConfiguration() => RpgConfigurationModel(
        rpgName: "Maries Kampagne",
        currencyDefinition: CurrencyDefinition(
          currencyTypes: [
            CurrencyType(name: "Kupfer", multipleOfPreviousValue: null),
            CurrencyType(name: "Silber", multipleOfPreviousValue: 100),
            CurrencyType(name: "Gold", multipleOfPreviousValue: 100),
            CurrencyType(name: "Platin", multipleOfPreviousValue: 100),
          ],
        ),
        placesOfFindings: [
          PlaceOfFinding(
            uuid: "5b9690c1-afc9-436d-8912-d223c440eb6a",
            name: "Berge",
          ),
          PlaceOfFinding(
            uuid: "4a9abc76-df97-4790-9abe-cee5f6bec8a7",
            name: "Höhlen",
          ),
          PlaceOfFinding(
            uuid: "f4e2605a-1d22-45e8-92d6-44534eafdc44",
            name: "Wiesen",
          ),
          PlaceOfFinding(
            uuid: "2ed1f4ca-8ae0-4945-8771-5f74cf7ac546",
            name: "Wüste",
          ),
          PlaceOfFinding(
            uuid: "8ea924d4-7160-48dd-9d7f-5afa04c27048",
            name: "Wälder",
          ),
        ],
        itemCategories: [
          ItemCategory(
            uuid: "d0a0168f-02d0-4205-b0af-689b52f24186",
            name: "Kleidung",
            subCategories: [
              ItemCategory(
                uuid: "263dc67f-bfae-4559-a909-1479e24354a6",
                name: "Rüstung",
                subCategories: [],
              ),
              ItemCategory(
                uuid: "544cdaac-a8d2-4ee6-8a8f-4772bfb95a93",
                name: "Accessoire",
                subCategories: [],
              ),
            ],
          ),
          ItemCategory(
            uuid: "b895a30a-2c0a-4aba-8629-9a363e405281",
            name: "Zutat",
            subCategories: [],
          ),
          ItemCategory(
            uuid: "4bba577f-c4c0-43a4-bc70-cbb39cbb7bee",
            name: "Trank",
            subCategories: [
              ItemCategory(
                uuid: "79773521-2fd6-4aff-942e-87b9e4bb6599",
                name: "Heilung",
                subCategories: [],
              ),
              ItemCategory(
                uuid: "64031e58-a816-4c84-9ca8-d80cd514a908",
                name: "Gift",
                subCategories: [],
              ),
              ItemCategory(
                uuid: "b0b0b636-6637-48c2-a899-4bd62435dba0",
                name: "Gegengift",
                subCategories: [],
              ),
              ItemCategory(
                uuid: "04b75751-0a85-4d82-8b66-361f47743797",
                name: "Buff",
                subCategories: [],
              ),
            ],
          ),
          ItemCategory(
            uuid: "f9cc6513-36b4-4e4e-b3ba-dd9f40fca078",
            name: "Waffe",
            subCategories: [
              ItemCategory(
                uuid: "1666d606-b839-4664-930d-2f51b552111c",
                name: "Finesse",
                subCategories: [],
              ),
              ItemCategory(
                uuid: "4ab9bded-a516-4a1b-a66d-fd5d972957cf",
                name: "Fernkampf",
                subCategories: [],
              ),
              ItemCategory(
                uuid: "8d86c1df-fe26-420d-8ccf-f5ef0af535a3",
                name: "Magie",
                subCategories: [],
              ),
              ItemCategory(
                uuid: "1d21556e-8993-4883-a9a5-f9853697f21e",
                name: "Wurfwaffe",
                subCategories: [],
              ),
            ],
          ),
          ItemCategory(
            uuid: "c7690cb0-39b4-45d2-b7c5-75b6e8eeb88f",
            name: "Schatz",
            subCategories: [],
          ),
          ItemCategory(
            uuid: "f9f4ba0d-9314-4f70-b7ba-fa6375490c70",
            name: "Tool",
            subCategories: [],
          ),
        ],
        allItems: [
          RpgItem(
            patchSize: DiceRoll(numDice: 1, diceSides: 6, modifier: 1),
            uuid: "a7537746-260d-4aed-b182-26768a9c2d51",
            name: "Kl. Heiltrank",
            categoryId: "79773521-2fd6-4aff-942e-87b9e4bb6599",
            baseCurrencyPrice: 10000,
            placeOfFindings: [],
            description:
                "1D4 Heilung bei Konsum\n\nEin kleiner Heiltrank der auf natürliche (und nicht magische) Weise Lebenspunkte wiederherstellt.\nDieser Gegenstand ist fast unerlässlich für Kämpfe!",
          ),
          RpgItem(
              uuid: "8abe00a8-fa94-4e5d-9c99-2a68b9de60e7",
              name: "Rote Vitus Blüte",
              categoryId: "b895a30a-2c0a-4aba-8629-9a363e405281",
              baseCurrencyPrice: 100,
              patchSize: DiceRoll(numDice: 2, diceSides: 4, modifier: 0),
              placeOfFindings: [
                RpgItemRarity(
                  placeOfFindingId: "2ed1f4ca-8ae0-4945-8771-5f74cf7ac546",
                  diceChallenge: 15,
                ),
                RpgItemRarity(
                  placeOfFindingId: "8ea924d4-7160-48dd-9d7f-5afa04c27048",
                  diceChallenge: 15,
                ),
                RpgItemRarity(
                  placeOfFindingId: "f4e2605a-1d22-45e8-92d6-44534eafdc44",
                  diceChallenge: 15,
                ),
                RpgItemRarity(
                  placeOfFindingId: "5b9690c1-afc9-436d-8912-d223c440eb6a",
                  diceChallenge: 15,
                ),
                RpgItemRarity(
                  placeOfFindingId: "4a9abc76-df97-4790-9abe-cee5f6bec8a7",
                  diceChallenge: 22,
                ),
              ],
              description:
                  "Ein Blütenblatt der Roten Vitus Blüte\n\nSehr fragil und muss mit Vorsicht geerntet werden!"),
          RpgItem(
            uuid: "73b51a58-8a07-4de2-828c-d0952d42af34",
            name: "Fuchsschwanz",
            categoryId: "b895a30a-2c0a-4aba-8629-9a363e405281",
            baseCurrencyPrice: 777777,
            placeOfFindings: [],
            description: "Der Schwanz eines Fuchses",
            patchSize: DiceRoll(numDice: 1, diceSides: 6, modifier: 1),
          ),
          RpgItem(
            uuid: "dc497952-1989-40d1-9d50-a5b4e53dd1be",
            name: "Kräuterkunde-Set",
            categoryId: "f9f4ba0d-9314-4f70-b7ba-fa6375490c70",
            baseCurrencyPrice: 777777,
            placeOfFindings: [],
            description: "Ein Tool zum erstellen von Tränken",
            patchSize: DiceRoll(numDice: 0, diceSides: 6, modifier: 0),
          ),
        ],
        craftingRecipes: [
          CraftingRecipe(
            recipeUuid: "1e660b2d-cc7b-4e4d-9acf-b1bc4b41eb14",
            ingredients: [
              CraftingRecipeIngredientPair(
                  itemUuid: "73b51a58-8a07-4de2-828c-d0952d42af34",
                  amountOfUsedItem: 2),
              CraftingRecipeIngredientPair(
                  itemUuid: "8abe00a8-fa94-4e5d-9c99-2a68b9de60e7",
                  amountOfUsedItem: 1),
            ],
            requiredItemIds: [
              "dc497952-1989-40d1-9d50-a5b4e53dd1be",
            ],
            createdItem: CraftingRecipeIngredientPair(
              itemUuid: "73b51a58-8a07-4de2-828c-d0952d42af34",
              amountOfUsedItem: 1,
            ),
          ),
          CraftingRecipe(
            recipeUuid: "7790055d-7421-4608-a824-59d3b1a12d0f",
            ingredients: [
              CraftingRecipeIngredientPair(
                  itemUuid: "73b51a58-8a07-4de2-828c-d0952d42af34",
                  amountOfUsedItem: 4),
              CraftingRecipeIngredientPair(
                  itemUuid: "8abe00a8-fa94-4e5d-9c99-2a68b9de60e7",
                  amountOfUsedItem: 2),
            ],
            requiredItemIds: [
              "dc497952-1989-40d1-9d50-a5b4e53dd1be",
            ],
            createdItem: CraftingRecipeIngredientPair(
              itemUuid: "73b51a58-8a07-4de2-828c-d0952d42af34",
              amountOfUsedItem: 2,
            ),
          ),
          CraftingRecipe(
            recipeUuid: "b8a86775-8680-47a5-b55c-cd2287d3584e",
            ingredients: [
              CraftingRecipeIngredientPair(
                  itemUuid: "8abe00a8-fa94-4e5d-9c99-2a68b9de60e7",
                  amountOfUsedItem: 65),
            ],
            requiredItemIds: [],
            createdItem: CraftingRecipeIngredientPair(
              itemUuid: "73b51a58-8a07-4de2-828c-d0952d42af34",
              amountOfUsedItem: 2,
            ),
          )
        ],
        characterStatTabsDefinition: [
          CharacterStatsTabDefinition(
              isDefaultTab: false,
              uuid: "8e725f17-ce7c-41d9-a9fd-b83566075096",
              tabName: "Background",
              isOptional: false,
              statsInTab: [
                CharacterStatDefinition(
                  statUuid: "30e18433-748d-458c-bd5e-373c38e762bf",
                  name: "Herkunft",
                  helperText: "Wo kommt dein Charakter her?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  statUuid: "cb2ee5ff-73d9-43e7-9e45-eca3a585bf11",
                  name: "Klasse",
                  helperText:
                      "Welche Klasse (bspw. Zauberer) hat dein Charakter?",
                  valueType: CharacterStatValueType.singleLineText,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  statUuid: "64be408b-ebbb-49fb-97af-da69c6c91fe3",
                  name: "Volk",
                  helperText:
                      "Aus welchem Volk (bspw. Zwerg) kommt dein Charakter?",
                  valueType: CharacterStatValueType.singleLineText,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  statUuid: "0070b224-95ac-4f0f-ab07-1ddb0d3d2ac8",
                  name: "Hintergrund",
                  helperText: "Welchen Hintergrund hat dein Charakter?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  statUuid: "37862834-261a-47b5-bd5c-9e315b8d26aa",
                  name: "Antrieb",
                  helperText: "Was treibt deinen Charakter an?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  statUuid: "a464bfe4-d99f-475d-a4af-0f1e5f73290e",
                  name: "Aussehen",
                  helperText: "Wie sieht dein Charakter aus?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  statUuid: "5accd34c-eade-4754-b955-21e1d902c4d9",
                  name: "Weitere Übungen und Sprachen",
                  helperText: "Was kann dein Charakter noch?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
              ]),
          CharacterStatsTabDefinition(
              isDefaultTab: true,
              uuid: "ebf46bc6-1e1e-4ea2-b580-caa992480e80",
              tabName: "Stats",
              isOptional: false,
              statsInTab: [
                CharacterStatDefinition(
                    statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
                    name: "HP",
                    helperText: "Lebenspunkte",
                    valueType: CharacterStatValueType.intWithMaxValue,
                    editType: CharacterStatEditType.oneTap),
                CharacterStatDefinition(
                    statUuid: "bb3b77c1-cbdb-49b4-b2b5-6b24d20f4383",
                    name: "Temp HP",
                    helperText: "Temporäre Lebenspunkte",
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.oneTap),
                CharacterStatDefinition(
                    statUuid: "886df3c2-a93f-47ae-931f-86153997860d",
                    name: "AC",
                    helperText: "Rüstungsklasse",
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static),
                CharacterStatDefinition(
                    statUuid: "082e62cb-7c17-4702-8529-172fb8e74c04",
                    name: "SP",
                    helperText: "Geschwindigkeit (in Feldern)",
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static),
                CharacterStatDefinition(
                    statUuid: "97a52844-977b-445f-9df1-e542ab3b49fe",
                    name: "ÜB",
                    helperText: "Übungsbonus",
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static),
                CharacterStatDefinition(
                    statUuid: "1ce2f567-d540-498a-a677-9776d518622d",
                    name: "Rettungswürfe",
                    helperText: "Übungsbonus auf Rettungswürfen",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '[{"uuid": "a632fa33-faab-4247-9152-8ee5ba52cfeb", "label": "Stärke", "description": ""}, {"uuid": "3dbb5cb6-f256-4dfd-acae-ead1baedb27f", "label": "Geschicklichkeit", "description": ""},{"uuid": "86f66619-857a-47d5-8447-b3016da2a6a4", "label": "Konstitution", "description": ""},{"uuid": "a3c9cd51-bd58-4d01-b7bb-fe9dcd27f349", "label": "Intelligenz", "description": ""},{"uuid": "af398b67-d335-499b-b74e-39aeaff4dccd", "label": "Weisheit", "description": ""},{"uuid": "c723e604-ddec-4bb4-b329-6c1478b7bd60", "label": "Charisma", "description": ""}]'),
                CharacterStatDefinition(
                    statUuid: "c5ef782a-8d8b-4a88-98b2-be277f741e4c",
                    name: "Fertigkeiten",
                    helperText: "In diesen Fertigkeiten bist du geübt.",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '[{"uuid": "de1fb5bc-3e3e-42e1-8b11-9dfafebfdfbc", "label": "Aktrobatik (Ges)", "description": ""}, {"uuid": "4da1f35a-0ee9-44b0-84de-3341ee7eaad6", "label": "Arkane Kunst (Int)", "description": ""},{"uuid": "89f12e22-178a-4d87-8517-4fe4787335f3", "label": "Athletik (Str)", "description": ""},{"uuid": "3196199d-f023-4289-a8ce-e5659d54deae", "label": "Auftreten (Cha)", "description": ""},{"uuid": "1d477c82-7289-4524-b807-3734f9e1e297", "label": "Einschüchtern (Cha)", "description": ""},{"uuid": "9ab19470-306b-4be0-a23d-ab8bc9c79e0d", "label": "Fingerfertigkeit (Ges)", "description": ""},{"uuid": "3f952394-664f-44e1-8b36-116106266c0f", "label": "Geschichte (Int)", "description": ""},{"uuid": "f5c38dde-e288-473b-9113-0ae7a960af23", "label": "Heilkunde (Int)", "description": ""},{"uuid": "9a187aa5-71bb-40c3-b749-d12ace0471b9", "label": "Mit Tieren umgehen (Wei)", "description": ""},{"uuid": "a3040091-cf15-4e63-87b7-3c449a9b3dd4", "label": "Motiv erkennen (Wei)", "description": ""},{"uuid": "d6833b01-0f6e-4bc3-9590-60a6bc3cdc01", "label": "Nachforschungen (Int)", "description": ""},{"uuid": "c6e1f42a-44ef-406e-b009-245ceb9637f8", "label": "Naturkunde (Int)", "description": ""},{"uuid": "21468550-7899-4188-a3cf-fdec85deb1ca", "label": "Religion (Int)", "description": ""},{"uuid": "072ea46a-043c-4548-bb2d-9d340691d940", "label": "Täuschen (Cha)", "description": ""},{"uuid": "bc922713-6614-4bd7-8d62-0607bcf03146", "label": "Überlebenskunst (Wei)", "description": ""},{"uuid": "8957fe9f-9142-44fd-8354-d50c06c9b1a5", "label": "Überzeugen (Cha)", "description": ""},{"uuid": "827f2550-9683-45cf-b8fb-cad229c47fe8", "label": "Wahrnehmung (Wei)", "description": ""}]'),
                CharacterStatDefinition(
                    statUuid: "44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3",
                    name: "Charisma",
                    helperText: "",
                    valueType: CharacterStatValueType.intWithCalculatedValue,
                    editType: CharacterStatEditType.static),
                CharacterStatDefinition(
                    statUuid: "c3ec0ea2-72bc-469d-9097-6d78140551e2",
                    name: "Geschicklichkeit",
                    helperText: "",
                    valueType: CharacterStatValueType.intWithCalculatedValue,
                    editType: CharacterStatEditType.static),
                CharacterStatDefinition(
                    statUuid: "88019d23-45fc-4fc1-bf70-48afc42091e9",
                    name: "Intelligenz",
                    helperText: "",
                    valueType: CharacterStatValueType.intWithCalculatedValue,
                    editType: CharacterStatEditType.static),
                CharacterStatDefinition(
                    statUuid: "d6ee70c2-bc0b-40d8-ad6b-b1d82351fbc2",
                    name: "Konstitution",
                    helperText: "",
                    valueType: CharacterStatValueType.intWithCalculatedValue,
                    editType: CharacterStatEditType.static),
                CharacterStatDefinition(
                    statUuid: "ee43d1c2-e6ef-4974-be0d-a0afa43df213",
                    name: "Stärke",
                    helperText: "",
                    valueType: CharacterStatValueType.intWithCalculatedValue,
                    editType: CharacterStatEditType.static),
                CharacterStatDefinition(
                    statUuid: "35badd72-fdfb-4077-b566-89c273f72ae9",
                    name: "Weisheit",
                    helperText: "",
                    valueType: CharacterStatValueType.intWithCalculatedValue,
                    editType: CharacterStatEditType.static),
              ]),
          CharacterStatsTabDefinition(
              isDefaultTab: false,
              uuid: "11cc5da3-624b-40d4-9477-468a0a6b4670",
              tabName: "Features",
              isOptional: false,
              statsInTab: [
                CharacterStatDefinition(
                  statUuid: "893bab17-6c13-4ed5-a287-8eaa135a54ef",
                  name: "Features",
                  helperText: "Charakter Eigenschaften",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
              ]),
          CharacterStatsTabDefinition(
              isDefaultTab: false,
              uuid: "f0c39bb7-1d95-4d7a-aaf2-80bf31f2662a",
              tabName: "Attacks",
              isOptional: false,
              statsInTab: [
                CharacterStatDefinition(
                    statUuid: "3219934b-09fc-409b-8413-9e56b864c664",
                    name: "Attacken",
                    helperText: "Physische Attacken",
                    valueType: CharacterStatValueType.multiLineText,
                    editType: CharacterStatEditType.static),
              ]),
          CharacterStatsTabDefinition(
              uuid: "9421920d-99c2-4882-8a39-53564e7b2920",
              isDefaultTab: false,
              tabName: "Spells",
              isOptional: true,
              statsInTab: [
                CharacterStatDefinition(
                  statUuid: "2438aac8-4a67-41ca-aad9-3c838b7c5cf3",
                  name: "Zauberpunkte",
                  helperText: "Wieviele Zauberpunkte hast du?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    statUuid: "c1b7a131-c239-4d56-8008-b3d4b654189d",
                    name: "Zaubertricks",
                    helperText: "Welche Zaubertricks kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '[{"uuid": "1e720492-1520-4bf3-86a3-98c4f61be329", "label": "Botschaft","description": "Zaubertrick der Verwandlung\\nZeitaufwand: 1 Aktion\\nReichweite: 36 m\\nKomponenten: V, G, M (ein kurzes Stück Kupferdraht)\\nWirkungsdauer: 1 Runde\\nDu deutest mit dem Finger auf eine Kreatur in Reichweite und flüsterst eine Botschaft. Das Ziel (und nur dieses) hört die Botschaft und kann in einem Flüstern antworten, das nur du zu hören vermagst.\\nDu darfst diesen Zauber durch feste Gegenstände wirken, wenn du mit dem Ziel vertraut bist und weißt, dass es sich hinter der Barriere befindet. Magische Stille, 30 cm Stein, 2,5 cm gewöhnliches Metall, eine dünne Schicht Blei oder 90 cm Holz blockieren den Zauber. Der Effekt muss keiner geraden Linie folgen und kann sich frei um Ecken oder durch Öffnungen bewegen."    },    {        "uuid": "bc6ddcc2-ccf5-4a70-9b0f-afbf17c7be47", "label": "Magierhand",        "description": "Zaubertrick der Beschwörung\\nZeitaufwand: 1 Aktion\\nReichweite: 9 m\\nKomponenten: V, G\\nWirkungsdauer: 1 Minute\\nEine geisterhafte, schwebende Hand erscheint an einem Punkt deiner Wahl in Reichweite. Die Hand bleibt für die Wirkungsdauer bestehen oder bis du sie mit einer Aktion fortschickst. Sie verschwindet auch, wenn sie sich weiter als 9 m von dir entfernt oder du den Zauber erneut wirkst.\\nAls Aktion kannst du die Hand kontrollieren und sie verwenden, um mit Gegenständen zu interagieren, geschlossene Türen oder Behälter zu öffnen, einen Gegenstand aus einem geöffneten Behälter zu holen oder ihn darin zu verstauen oder den Inhalt einer Phiole auszugießen. Immer wenn du die Hand kontrollierst, darfst du sie bis zu 9 m bewegen.\\nDie Hand kann nicht angreifen, keine magischen Gegenstände aktivieren oder mehr als 10 Pfund tragen."    },    {        "uuid": "5b9c7345-8cda-469b-8e00-4ff47f50ce9c", "label": "Gift versprühen",        "description": "Zaubertrick der Beschwörung\\nZeitaufwand: 1 Aktion\\nReichweite: 3 m\\nKomponenten: V, G\\nWirkungsdauer: unmittelbar\\nDu streckst deine Hand in Richtung einer Kreatur aus, die sich in Reichweite befindet und die du sehen kannst, und erzeugst eine Wolke ekelhaften Gases aus deiner Handfläche.\\nDie Kreatur muss einen erfolgreichen Konstitutionsrettungswurf ablegen, sonst erleidet sie 1W12 Giftschaden.\\nDer Schaden dieses Zaubers steigt jeweils um 1W12 bei Erreichen der 5. (2W12), 11. (3W12) und 17. Stufe (4W12)."    },    {        "uuid": "4ee11bf7-1f97-4209-b2e4-d05346b04ed9", "label": "Flammen erzeugen",        "description": "Zaubertrick der Beschwörung\\nZeitaufwand: 1 Aktion\\nReichweite: selbst Komponenten: V, G\\nWirkungsdauer: 10 Minuten\\nEine flackernde Flamme erscheint in deiner Hand. Diese bleibt für die Wirkungsdauer bestehen und beschädigt weder dich noch deine Ausrüstung. Sie strahlt innerhalb von 3 m helles Licht und in einem Radius von weiteren 3 m dämmriges Licht aus. Der Zauber endet, wenn du ihn als Aktion aufhebst oder noch einmal wirkst.\\nDu kannst mit der Flamme auch angreifen, dies beendet jedoch den Zauber. Beim Wirken des Zaubers oder als Aktion in einem späteren Zug kannst du die Flamme auf eine Kreatur innerhalb von 9 m werfen. Führe einen Fernkampf-Zauberangriff aus. Bei einem Treffer erleidet das Ziel 1W8 Feuerschaden.\\nDer Schaden dieses Zaubers steigt jeweils um 1W8 bei Erreichen der 5. (2W8), 11. (3W8) und 17. Stufe (4W8)."    },    {        "uuid": "c247bc4f-f04b-4301-a401-fe0908eb3ca9", "label": "Kalte Hand",        "description": "Zaubertrick der Nekromantie\\nZeitaufwand: 1 Aktion\\nReichweite: 36 m Komponenten: V, G\\nWirkungsdauer: 1 Runde\\nDu erschaffst eine geisterhafte, skelettierte Hand im Bereich einer Kreatur in Reichweite. Führe einen Fernkampf-Zauberangriff gegen die Kreatur aus, um sie die Kälte des Grabes spüren zu lassen. Bei einem Treffer erleidet das Ziel 1W8 nekrotischen Schaden und kann bis zum Beginn deines nächsten Zuges keine Trefferpunkte zurückerlangen. Bis dahin hält sich die Hand an dem Ziel fest.\\nWenn du eine untote Kreatur triffst, ist sie außerdem im Nachteil bei Angriffswürfen gegen dich bis zum Ende deines nächsten Zuges.\\nDer Schaden dieses Zaubers steigt jeweils um 1W8 bei Erreichen der 5. (2W8), 11. (3W8) und 17. Stufe (4W8)."    },    {        "uuid": "c3fa6593-ac9c-44d0-b158-09555d0f3f5e", "label": "Druidenkunst",        "description": "Zaubertrick der Verwandlung\\nZeitaufwand: 1 Aktion\\nReichweite: 9 m Komponenten: V, G\\nWirkungsdauer: unmittelbar\\nDu sprichst flüsternd mit den Geistern der Natur und erzeugst innerhalb der Reichweite einen der folgenden Effekte:\\nDu erschaffst einen harmlosen sensorischen Effekt, der das Wetter an deinem Aufenthaltsort für die nächsten 24 Stunden vorhersagt. Der Effekt hält 1 Runde lang an und könnte sich als goldene Kugel für einen klaren Himmel, als Wolke für Regen, als fallende Schneeflocken für Schnee oder Ähnliches manifestieren.﻿\\nDu bewirkst, dass augenblicklich eine Blume erblüht, eine Samenkapsel sich öffnet oder eine Blattknospe aufblüht.\\nDu erschaffst einen harmlosen sensorischen Effekt, wie fallende Blätter, einen Windhauch, die Geräusche eines kleinen Tieres oder den leichten Geruch eines Stinktiers. Der Effekt muss in einen Würfel mit 1,50 m Kantenlänge passen.\\nDu kannst augenblicklich eine Kerze, eine Fackel oder ein kleines Lagerfeuer entzünden oder löschen."    },    {        "uuid": "1e7c68b0-c76b-421c-98ca-d41e7a4fdaa4", "label": "Dornenpeitsche",        "description": "Zaubertrick der Verwandlung\\nZeitaufwand: 1 Aktion\\nReichweite: 9 m\\nKomponenten: V, G, M (der Stiel einer Pflanze mit Dornen)\\nWirkungsdauer: unmittelbar\\nDu erschaffst eine lange, rankenartige Peitsche, die mit Dornen bedeckt ist und die auf deinen Befehl hin nach einer Kreatur in Reichweite schlägt. Führe einen Nahkampf-Zauberangriff gegen das Ziel durch. Wenn der Angriff trifft, erleidet die Kreatur 1W6 Stichschaden. Handelt es sich um eine Kreatur der Größenkategorie groß oder kleiner, wird sie zusätzlich 3 m in deine\\nRichtung gezogen.\\nDer Schaden dieses Zaubers steigt jeweils um 1W6 bei Erreichen der 5. (2W6), 11. (3W6) und 17. Stufe (4W6)."    },    {        "uuid": "30928f34-7632-469a-bd3d-6f76ee660f98", "label": "Shillelagh",        "description": "Zaubertrick der Verwandlung\\nZeitaufwand: 1 Bonusaktion\\nReichweite: Berührung\\nKomponenten: V, G, M (Mistelzweig, vierblättriges Kleeblatt und eine Keule oder ein Kampfstab)\\nWirkungsdauer: 1 Minute\\nDas Holz einer Keule oder eines Kampfstabs, den du in der Hand hältst, wird von der Macht der Natur erfüllt. Für die Wirkungsdauer kannst du dein Attribut zum Zauberwirken anstelle von Stärke verwenden, wenn du Angriffs- und Schadenswürfe für Nahkampfangriffe mit dieser Waffe durchführst. Außerdem wird der Schadenswürfel der Waffe zu einem W8 und die Waffe magisch, falls sie es nicht bereits ist. Der Zauber endet, wenn du ihn erneut wirkst oder die Waffe loslässt."}]'),
                CharacterStatDefinition(
                  statUuid: "18877c24-515a-4788-a657-d50915a5c0cc",
                  name: "Zauber 1. Stufe",
                  helperText:
                      "Wieviele Zauber der Stufe 1 hast du heute gewirkt?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    statUuid: "31a52ed2-3e7b-42ac-8f3e-490b3a04027a",
                    name: "Zauber 1. Stufe",
                    helperText: "Welche Zauber der Stufe 1 kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '[{"uuid": "e79adcb9-4d57-45e6-9d05-29aeb2bbfe1a", "label": "Brennende Hände", "description": "Hervorrufung des 1. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: selbst (Kegel von 4,50 m)\\nKomponenten: V, G\\nWirkungsdauer: unmittelbar\\nDu streckst die Hände aus, mit sich berührenden Daumen und ausgebreiteten Fingern, und eine dünne Fläche aus Feuer schießt aus deinen ausgestreckten Fingerspitzen. Jede Kreatur in einem Kegel von 4,50 m muss einen Geschicklichkeitsrettungswurf ablegen. Bei einem Misserfolg erleidet das Ziel 3W6 Feuerschaden oder halb so viel Schaden bei einem erfolgreichen Rettungswurf.\\nDas Feuer entzündet alle brennbaren Gegenstände im Wirkungsbereich, die nicht getragen oder in der Hand gehalten werden.\\nAuf höheren Graden: Wenn du diesen Spruch mit einem Zauberplatz des 2. oder eines höheren Grades wirkst, steigt der Schaden für jeden Grad über den 1. hinaus um 1W6."    },    {        "uuid": "f28e6faa-1cce-4f99-8f4f-30e9b89defd7", "label": "Magisches Geschoss",        "description": "Hervorrufung des 1. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: 36 m Komponenten: V, G\\nWirkungsdauer: unmittelbar\\nDu erschaffst drei leuchtende Pfeile aus magischer Energie.\\nJeder Pfeil trifft eine Kreatur deiner Wahl in Reichweite, die du sehen kannst, und fügt dem Ziel 1W4 +1 Energieschaden zu.\\nDie Pfeile schlagen alle gleichzeitig ein und können auf eine oder mehrere Kreaturen losgeschickt werden.\\nAuf höheren Graden: Wenn du diesen Spruch mit einem Zauberplatz des 2. oder eines höheren Grades wirkst, erschaffst du für jeden Grad über den 1. hinaus einen weiteren Pfeil."    },    {        "uuid": "94a4169b-80c3-4819-bb9f-4e4fc40fb294", "label": "Höllischer Tadel",        "description": "Hervorrufung des 1. Grades\\nZeitaufwand: 1 Reaktion, die du ausführst, wenn du von einer Kreatur verletzt wirst, die sich innerhalb von 18 m befindet und die du sehen kannst\\nReichweite: 18 m Komponenten: V, G\\nWirkungsdauer: unmittelbar\\nDu deutest mit einem Finger und die Kreatur, die dich verletzt hat, wird für einen kurzen Moment von höllischen Flammen eingehüllt.\\nDie Kreatur muss einen Geschicklichkeitsrettungswurf ablegen.\\nBei einem Misserfolg erleidet das Ziel 2W10 Feuerschaden oder halb so viel Schaden bei einem erfolgreichen Rettungswurf.\\nAuf höheren Graden: Wenn du diesen Spruch mit einem Zauberplatz des 2. oder eines höheren Grades wirkst, steigt der Schaden für jeden Grad über den 1. hinaus um 1W10."    },    {        "uuid": "6c0490b7-2da1-41d2-84e1-c0e4deb98ab3", "label": "Mit Tiere sprechen",        "description": "Erkenntnismagie des 1. Grades (Ritual)\\nZeitaufwand: 1 Aktion\\nReichweite: selbst Komponenten: V, G\\nWirkungsdauer: 10 Minuten\\nFür die Wirkungsdauer erhältst du die Fähigkeit, Tiere zu verstehen und verbal mit ihnen zu kommunizieren. Das Wissen und das Bewusstsein vieler Tiere wird durch ihren Intelligenzwert beschränkt, sie sind jedoch immer in der Lage, Informationen über nahe Orte und Monster zu übermitteln sowie über das, was sie wahrnehmen können oder innerhalb des letzten Tages wahrgenommen haben. Nach Maßgabe des SL könntest du ein Tier auch überzeugen, dir einen kleinen Gefallen zu erweisen."    },    {        "uuid": "be12d521-1a3c-440f-90bc-1ab262df56c9", "label": "Magie entdecken",        "description": "Erkenntnismagie des 1. Grades (Ritual)\\nZeitaufwand: 1 Aktion\\nReichweite: selbst Komponenten: V, G\\nWirkungsdauer: Konzentration, bis zu 10 Minuten\\nFür die Wirkungsdauer fühlst du die Anwesenheit von Magie im Umkreis von 9 m. Verwendest du deine Aktion, wenn du Magie auf diese Weise spürst, nimmst du eine schwache Aura um jede sichtbare Kreatur und jeden Gegenstand im Wirkungsbereich wahr, der von Magie erfüllt ist. Außerdem ist dir auch die Schule der Magie bekannt, sofern es eine gibt. Der Zauber kann die meisten Hindernisse durchdringen, wird aber blockiert von 30 cm Stein, 2,5 cm gewöhnlichem Metall, einer dünnen Schicht Blei oder 90 cm Holz oder Erde."    },    {        "uuid": "94746221-d26a-496a-bdc6-44a457db8eaf", "label": "Heilendes Wort",        "description": "Hervorrufung des 1. Grades\\nZeitaufwand: 1 Bonusaktion\\nReichweite: 18 m Komponenten: V\\nWirkungsdauer: unmittelbar\\nEine Kreatur deiner Wahl, die sich in Reichweite befindet und die du sehen kannst, erhält Trefferpunkte zurück in Höhe von 1W4 + den Modifikator deines zum Zaubern relevanten Attributs. Der Zauber hat keine Auswirkungen auf Untote oder Konstrukte.\\nAuf höheren Graden: Wenn du diesen Spruch mit einem Zauber-platz des 2. oder eines höheren Grades wirkst, steigt die Anzahl der geheilten Trefferpunkte für jeden Grad über den 1. hinaus um 1W4."}]'),
                CharacterStatDefinition(
                  statUuid: "cae3e22b-5674-4728-82d4-c8a28615fcdd",
                  name: "Zauber 2. Stufe",
                  helperText:
                      "Wieviele Zauber der Stufe 2 hast du heute gewirkt?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    statUuid: "212b9948-bc45-48f1-af39-bc84d6c5283f",
                    name: "Zauber 2. Stufe",
                    helperText: "Welche Zauber der Stufe 2 kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '[{"uuid": "10978c13-95c7-4179-bd91-e4270547ebe2", "label": "Flammenkugel","description": "Beschwörung des 2. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: 18 m\\nKomponenten: V, G, M (etwas Talg, eine Prise Schwefel und\\netwas Eisenpulver)\\nWirkungsdauer: Konzentration, bis zu 1 Minute\\nEine Sphäre aus Feuer mit einem Durchmesser von 1,50 m erscheint in einem nicht besetzten Bereich deiner Wahl in Reichweite und bleibt für die Wirkungsdauer bestehen. Jede Kreatur, die ihren Zug innerhalb von 1,50 m um die Sphäre beendet, muss einen Geschicklichkeitsrettungswurf ablegen. Bei einem Misserfolg erleidet eine Kreatur 2W6 Feuerschaden oder halb so viel Schaden bei einem erfolgreichen Rettungswurf.\\nAls Bonusaktion kannst du die Sphäre bis zu 9 m bewegen.\\nWenn du eine Kreatur mit der Sphäre rammst, muss das Ziel den oben beschriebenen Rettungswurf erfolgreich ablegen oder es erleidet den vollen Feuerschaden. Die Bewegung der Sphäre endet in diesem Zug. Wenn du die Sphäre bewegst, kannst du sie über Hindernisse lenken, die bis zu 1,50 m hoch sind, und sie über Gräben von bis zu 3 m Breite springen lassen."    },    {        "uuid": "7f182652-7da8-4b11-9e1c-de0393fd30b6", "label": "Sengender Strahl",        "description": "Hervorrufung des 2. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: 36 m Komponenten: V, G\\nWirkungsdauer: unmittelbar\\nDu erschaffst drei Strahlen aus Feuer und schleuderst sie auf ein oder mehrere Ziele in Reichweite. Führe einen Fernkampf-Zauberangriff für jeden Strahl aus. Bei einem Treffer erleidet das Ziel\\n2W6 Feuerschaden.\\nAuf höheren Graden: Wenn du diesen Spruch mit einem Zauberplatz des 3. oder eines höheren Grades wirkst, erschaffst du für jeden Grad über den 2. hinaus einen zusätzlichen Strahl."    },    {        "uuid": "774a0a67-ff6d-478e-ae6b-38158e1c5db0", "label": "Dornenwuchs",        "description": "Verwandlung des 2. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: 45 m\\nKomponenten: V, G, M (sieben scharfe Dornen oder sieben angespitze kleine Zweige)\\nWirkungsdauer: Konzentration, bis zu 10 Minuten\\nDer Boden in einem Radius von 6 m, zentriert um einen Punkt in Reichweite, wird von harten Stacheln und Dornen überwuchert. Für die Wirkungsdauer gilt der Bereich als schwieriges Gelände. Bewegt sich eine Kreatur in das Gebiet hinein oder innerhalb dessen, erleidet sie 2W4 Stichschaden für jeweils 1,50 m, die sie zurücklegt.\\nDie Verwandlung des Bodens ist so getarnt, dass dieser nicht gefährlich wirkt. Jede Kreatur, die den Bereich nicht sehen kann, wenn der Zauber gewirkt wird, muss bei dessen Betreten einen Wurf auf Weisheit (Wahrnehmung) gegen den SG zum Widerstehen deiner Zauber ablegen. Misslingt er, erkennt sie nicht, welche Gefahr von dem Gelände ausgeht."    },    {        "uuid": "b2aa3dc4-ac1d-4be4-bd81-db41e7501ae5", "label": "Spurloses Gehen",        "description": "Bannmagie des 2. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: selbst\\nKomponenten: V, G, M (Asche eines verbrannten Mistelblatts und ein Fichtenzweig)\\nWirkungsdauer: Konzentration, bis zu 1 Stunde\\nEin Schleier aus Schatten und Stille geht von dir aus und maskiert dich und deine Gefährten, sodass ihr nicht entdeckt werden könnt.\\nFür die Wirkungsdauer erhalten alle Kreaturen deiner Wahl innerhalb von 9 m (inklusive dir) einen Bonus von +10 auf Würfe auf Geschicklichkeit (Heimlichkeit). Außerdem können ihre Spuren nur auf magische Weise gelesen werden. Eine Kreatur, die vom Effekt des Zaubers betroffen ist, hinterlässt keine Fährten oder andere Spuren ihrer Anwesenheit."}]'),
                CharacterStatDefinition(
                  statUuid: "66f0e8dd-1fed-47d8-9e4d-88e0b8b2e2b0",
                  name: "Zauber 3. Stufe",
                  helperText:
                      "Wieviele Zauber der Stufe 3 hast du heute gewirkt?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    statUuid: "f8b49ed4-a24a-45fb-8077-369fde7ef37c",
                    name: "Zauber 3. Stufe",
                    helperText: "Welche Zauber der Stufe 3 kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '[{"uuid": "f663078d-730f-422c-8d8f-dacdc8896981", "label": "Feuerball","description": "Hervorrufung des 3. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: 45 m\\nKomponenten: V, G, M (eine winzige Kugel aus Fledermauskot und Schwefel)\\nWirkungsdauer: unmittelbar\\nEin gleißender Lichtblitz schießt aus einem deiner Finger zu einem Punkt deiner Wahl in Reichweite und erblüht mit einem dunklen Grollen zu einer feurigen Explosion aus Flammen. Alle Kreaturen in einem Radius von 6 m um diesen Punkt müssen einen Geschicklichkeitsrettungswurf ablegen. Bei einem Misserfolg erleidet ein Ziel 8W6 Feuerschaden oder halb so viel Schaden bei einem erfolgreichen Rettungswurf.\\nDas Feuer kann sich um Ecken ausbreiten. Es entzündet alle brennbaren Gegenstände im Bereich, die nicht getragen oder in der Hand gehalten werden.\\nAuf höheren Graden: Wenn du diesen Spruch mit einem Zauberplatz des 4. oder eines höheren Grades wirkst, steigt der Schaden für jeden Grad über den 3. hinaus um 1W6."    },    {        "uuid": "327f07de-4191-43db-9ac5-a8c65382cff7", "label": "Furcht",        "description": "Illusion des 3. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: selbst (Kegel von 9 m)\\nKomponenten: V, G, M (eine weiße Feder oder das Herz einer\\nHenne)\\nWirkungsdauer: Konzentration, bis zu 1 Minute\\nDu projizierst ein geisterhaftes Bild der schlimmsten Ängste einer Kreatur. Alle Kreaturen in einem Kegel von 9 m müssen einen erfolgreichen Weisheitsrettungswurf ablegen, um nicht alles fallenzulassen, was sie in Händen halten, und für die Wirkungsdauer von dir verängstigt zu werden.\\nSolange eine Kreatur durch diesen Zauber verängstigt ist, muss sie in jedem ihrer Züge die Spurtaktion verwenden und sich auf dem sichersten und kürzesten verfügbaren Weg von dir wegbewegen, bis dies nicht mehr möglich ist. Wenn die Kreatur ihren Zug an einem Ort beendet, an dem sie dich nicht mehr sehen kann, darf sie einen Weisheitsrettungswurf ablegen. Bei einem Erfolg endet der Zauber für die Kreatur."    }]'),
                CharacterStatDefinition(
                  statUuid: "f4268470-6c7c-4fc8-8412-cf2fea4e19b1",
                  name: "Zauber 4. Stufe",
                  helperText:
                      "Wieviele Zauber der Stufe 4 hast du heute gewirkt?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    statUuid: "612f5698-fdda-4485-b138-599ae3532520",
                    name: "Zauber 4. Stufe",
                    helperText: "Welche Zauber der Stufe 4 kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '[{"uuid": "ea4263df-f701-427a-a3fe-ff55288237a1", "label": "Feuerwand","description": "Hervorrufung des 4. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: 36 m\\nKomponenten: V, G, M (ein kleines Stück Phosphor) Wirkungsdauer: Konzentration, bis zu 1 Minute\\nDu erschaffst eine Barriere aus Feuer auf einem festen Untergrund in Reichweite. Sie kann gerade sein (bis zu 18 m lang, 6 m hoch und 30 cm dick) oder ringförmig (bis zu 6 m Durchmesser, 6 m Höhe und 30 cm Dicke). Die Barriere ist mit Blicken nicht zu durchdringen und hält für die Wirkungsdauer an.\\nErschaffst du die Feuerwand, müssen alle Kreaturen in ihrem\\nBereich einen Geschicklichkeitsrettungswurf ablegen. Bei einem Misserfolg erleidet eine Kreatur 5W8 Feuerschaden oder halb so viel Schaden bei einem gelungenen Rettungswurf.\\nEine Seite der Feuerwand, die du beim Wirken des Zaubers bestimmst, verursacht bei jeder Kreatur 5W8 Feuerschaden, die ihren Zug innerhalb von 3 m zu dieser Seite beendet. Eine Kreatur erleidet diesen Schaden ebenfalls, wenn sie die Barriere das erste Mal in einem Zug betritt oder ihren Zug dort beendet. Die andere Seite der Feuerwand verursacht keinen Schaden.\\nAuf höheren Graden: Wenn du diesen Spruch mit einem Zauberplatz des 5. oder eines höheren Grades wirkst, steigt der Schaden für jeden Grad über den 4. hinaus um 1W8."    },    {        "uuid": "2edae70c-e48f-45d4-b601-565f8ddbee83", "label": "Hüter des Glaubens",        "description": "Beschwörung des 4. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: 9 m Komponenten: V\\nWirkungsdauer: 8 Stunden\\nEin großer spektraler Hüter erscheint und schwebt für die Wirkungsdauer in einem nicht besetzten Bereich deiner Wahl, der sich in Reichweite befindet und den du sehen kannst. Der Hüter besetzt seinen Bereich und ist nicht klar zu erkennen, mit Ausnahme eines leuchtenden Schwertes und eines Schilds, welches das Symbol deiner Gottheit trägt.\\nJede dir feindlich gesonnene Kreatur, die sich zum ersten Mal in ihrem Zug dem Hüter auf weniger als 3 m nähert, muss einen Geschicklichkeitsrettungswurf ablegen. Bei einem Misserfolg erleidet die Kreatur 20 Punkte gleißenden Schaden oder halb so viel Schaden bei einem erfolgreichen Rettungswurf. Der Hüter verschwindet, wenn er insgesamt 60 Punkte Schaden verursacht hat."}]'),
                CharacterStatDefinition(
                  statUuid: "940ef581-e6a5-4dcd-bb9d-567a0294a76d",
                  name: "Zauber 5. Stufe",
                  helperText:
                      "Wieviele Zauber der Stufe 5 hast du heute gewirkt?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    statUuid: "347e51fa-caf0-4054-8eb9-dac3ba48c281",
                    name: "Zauber 5. Stufe",
                    helperText: "Welche Zauber der Stufe 5 kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '[{"uuid": "e4927331-9272-4685-94bb-b243507142f5", "label": "Flammenschlag","description": "Hervorrufung des 5. Grades\\nZeitaufwand: 1 Aktion\\nReichweite: 18 m\\nKomponenten: V, G, M (eine Prise Schwefel)\\nWirkungsdauer: unmittelbar\\nEine senkrechte Säule aus göttlichem Feuer fährt vom Himmel auf einen Ort herab, den du bestimmst. Alle Kreaturen innerhalb eines Zylinders mit 3 m Radius und 12 m Höhe, der um einen Punkt in Reichweite zentriert ist, müssen einen Geschicklichkeitsrettungs-wurf ablegen. Bei einem Misserfolg erleidet ein Ziel 4W6 Feuerschaden und 4W6 gleißenden Schaden oder jeweils halb so viel Schaden bei einem erfolgreichen Rettungswurf.\\nAuf höheren Graden: Wenn du diesen Spruch mit einem Zauberplatz des 6. oder eines höheren Grades wirkst, steigt der Feuerschaden oder der gleißende Schaden (deine Wahl) für jeden Grad über den 5. hinaus um 1W6."    },    {        "uuid": "cb5deac0-8f79-43dd-9358-3dc3179e43db", "label": "Elementar beschwören",        "description": "Beschwörung des 5. Grades\\nZeitaufwand: 1 Minute\\nReichweite: 27 m\\nKomponenten: V, G, M (brennender Weihrauch für Luft, weicher Lehm für Erde, Schwefel und Phosphor für Feuer oder Wasser und Sand für Wasser)\\nWirkungsdauer: Konzentration, bis zu 1 Stunde\\nDu rufst einen elementaren Diener herbei. Wähle einen Bereich von Luft, Erde, Feuer oder Wasser in Reichweite, der einen Würfel mit 3 m Kantenlänge füllt. Ein Elementar mit Heraus-forderungsgrad 5 oder niedriger, welcher der Art des gewählten Bereichs entspricht, erscheint an einer nicht besetzten Stelle im Umkreis von 3 m zu diesem Bereich. Beispielsweise könnte ein Feuerelementar aus einem Freudenfeuer hervortreten oder ein Erdelementar aus dem Boden aufsteigen. Der Elementar verschwindet, wenn seine Trefferpunkte auf 0 reduziert werden oder der Zauber endet.\\nDer Elementar ist für die Wirkungsdauer mit dir und deinen Gefährten verbündet. Würfle die Initiative für den Elementar, da er eigene Züge ausführt. Dein elementarer Diener folgt allen verbalen Befehlen, die du ihm erteilst (dazu musst du keine Aktion aufwenden). Ohne Befehl verteidigt er sich gegen feindliche Kreaturen, führt aber ansonsten keine Aktionen aus.\\nWenn deine Konzentration unterbrochen wird, verschwindet der Elementar nicht, sondern du verlierst die Kontrolle über ihn. Er wird dir und deinen Gefährten gegenüber feindlich und könnte angreifen. Ein unkontrollierter Elementar kann von dir nicht fortgeschickt werden und verschwindet 1 Stunde, nachdem du ihn beschworen hast. Der SL hat die Spielwerte des Elementars zur Verfügung.\\nAuf höheren Graden: Wenn du diesen Spruch mit einem Zauberplatz des 6. oder eines höheren Grades wirkst, steigt der Herausforderungsgrad des Elementars für jeden Grad über den 5. hinaus um 1."}]'),
              ]),
        ],
      );
}

@JsonSerializable()
@CopyWith()
class ItemCategory {
  final String uuid;
  final String name;
  final List<ItemCategory> subCategories;
  final bool hideInInventoryFilters;

  factory ItemCategory.fromJson(Map<String, dynamic> json) =>
      _$ItemCategoryFromJson(json);

  ItemCategory({
    required this.uuid,
    required this.name,
    required this.subCategories,
    this.hideInInventoryFilters = false,
  });

  Map<String, dynamic> toJson() => _$ItemCategoryToJson(this);

  static List<ItemCategory> flattenCategoriesRecursive({
    required List<ItemCategory> categories,
    bool combineCategoryNames = false,
  }) {
    List<ItemCategory> flattenCategorieList = [];

    void flatten(ItemCategory category, {String namePrefix = ""}) {
      flattenCategorieList
          .add(category.copyWith(name: namePrefix + category.name));

      // Recursively add all subcategories
      for (var subCategory in category.subCategories) {
        if (combineCategoryNames) {
          flatten(subCategory, namePrefix: "${namePrefix + category.name} > ");
        } else {
          flatten(subCategory, namePrefix: "");
        }
      }
    }

    // Start the recursion for each category in the list
    for (var category in categories) {
      flatten(category);
    }

    return flattenCategorieList;
  }
}

@JsonSerializable()
@CopyWith()
class CurrencyType {
  final String name;
  final int? multipleOfPreviousValue;
  CurrencyType({
    required this.name,
    required this.multipleOfPreviousValue,
  });

  factory CurrencyType.fromJson(Map<String, dynamic> json) =>
      _$CurrencyTypeFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyTypeToJson(this);
}

@JsonSerializable()
@CopyWith()
class CurrencyDefinition {
  final List<CurrencyType> currencyTypes;
  CurrencyDefinition({
    required this.currencyTypes,
  });

  factory CurrencyDefinition.fromJson(Map<String, dynamic> json) =>
      _$CurrencyDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyDefinitionToJson(this);

  static List<int> valueOfItemForDefinition(
      CurrencyDefinition def, int valueInBaseCurrencyPrice) {
    var currencySetting = def.currencyTypes;

    var moneyPricesAsMultipleOfBasePrice = [1];
    for (var i = 1; i < currencySetting.length; i++) {
      moneyPricesAsMultipleOfBasePrice.add(
          currencySetting[i].multipleOfPreviousValue! *
              moneyPricesAsMultipleOfBasePrice.last);
    }

    var reversedmoneyPricesAsMultipleOfBasePrice =
        moneyPricesAsMultipleOfBasePrice.reversed.toList();

    var valueLeft = valueInBaseCurrencyPrice;
    List<int> result = [];

    for (var i = 0; i < reversedmoneyPricesAsMultipleOfBasePrice.length; i++) {
      var divisionWithLeftOver =
          valueLeft ~/ reversedmoneyPricesAsMultipleOfBasePrice[i];
      if (divisionWithLeftOver > 0) {
        valueLeft -=
            divisionWithLeftOver * reversedmoneyPricesAsMultipleOfBasePrice[i];
        result.add(divisionWithLeftOver);
      } else {
        result.add(0);
      }
    }

    return result;
  }
}

@JsonSerializable()
@CopyWith()
class CraftingRecipeIngredientPair {
  final String itemUuid;
  final int amountOfUsedItem;
  CraftingRecipeIngredientPair({
    required this.itemUuid,
    required this.amountOfUsedItem,
  });

  factory CraftingRecipeIngredientPair.fromJson(Map<String, dynamic> json) =>
      _$CraftingRecipeIngredientPairFromJson(json);

  Map<String, dynamic> toJson() => _$CraftingRecipeIngredientPairToJson(this);
}

@JsonSerializable()
@CopyWith()
class CraftingRecipe {
  final String recipeUuid;
  final List<CraftingRecipeIngredientPair> ingredients;
  final CraftingRecipeIngredientPair createdItem;
  final List<String> requiredItemIds;

  CraftingRecipe({
    required this.recipeUuid,
    required this.ingredients,
    required this.requiredItemIds,
    required this.createdItem,
  });
  factory CraftingRecipe.fromJson(Map<String, dynamic> json) =>
      _$CraftingRecipeFromJson(json);

  Map<String, dynamic> toJson() => _$CraftingRecipeToJson(this);
}

@JsonEnum()
enum CharacterStatEditType {
  static,
  oneTap,
}

@JsonEnum()
enum CharacterStatValueType {
  multiLineText, // => RpgCharacterStatValue.serializedValue == {"value": "asdf"}
  singleLineText, // => RpgCharacterStatValue.serializedValue == {"value": "asdf"}
  int, // => RpgCharacterStatValue.serializedValue == {"value": 17}
  intWithMaxValue, // => RpgCharacterStatValue.serializedValue == {"value": 12, "maxValue": 17}
  multiselect, // jsonSerializedAdditionalData is filled with [{"uuid": "3a7fd649-2d76-4a93-8513-d5a8e8249b40", "label": "", "description": ""}], => RpgCharacterStatValue.serializedValue == {"values": ["3a7fd649-2d76-4a93-8513-d5a8e8249b40", "3a7fd649-2d76-4a93-8513-d5a8e8249b42"]}

  intWithCalculatedValue, // => RpgCharacterStatValue.serializedValue == {"value": 12, "otherValue": 2}
}

@JsonSerializable()
@CopyWith()
class CharacterStatDefinition {
  final String name;
  final String statUuid;
  final String helperText;
  final CharacterStatValueType valueType;
  final CharacterStatEditType editType;

  final String? jsonSerializedAdditionalData;

  CharacterStatDefinition({
    required this.statUuid,
    required this.name,
    required this.helperText,
    required this.valueType,
    required this.editType,
    this.jsonSerializedAdditionalData,
  });

  factory CharacterStatDefinition.fromJson(Map<String, dynamic> json) =>
      _$CharacterStatDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterStatDefinitionToJson(this);
}

@JsonSerializable()
@CopyWith()
class CharacterStatsTabDefinition {
  final String uuid;
  final String tabName;
  final bool isOptional;
  final bool isDefaultTab;
  final List<CharacterStatDefinition> statsInTab;

  CharacterStatsTabDefinition({
    required this.uuid,
    required this.tabName,
    required this.isOptional,
    required this.statsInTab,
    required this.isDefaultTab,
  });

  factory CharacterStatsTabDefinition.fromJson(Map<String, dynamic> json) =>
      _$CharacterStatsTabDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterStatsTabDefinitionToJson(this);
}

@JsonSerializable()
@CopyWith()
class PlaceOfFinding {
  final String uuid;
  final String name;

  factory PlaceOfFinding.fromJson(Map<String, dynamic> json) =>
      _$PlaceOfFindingFromJson(json);

  PlaceOfFinding({
    required this.uuid,
    required this.name,
  });

  Map<String, dynamic> toJson() => _$PlaceOfFindingToJson(this);
}

@JsonSerializable()
@CopyWith()
class RpgItemRarity {
  final String placeOfFindingId;
  final int diceChallenge;

  factory RpgItemRarity.fromJson(Map<String, dynamic> json) =>
      _$RpgItemRarityFromJson(json);

  RpgItemRarity({
    required this.placeOfFindingId,
    required this.diceChallenge,
  });

  Map<String, dynamic> toJson() => _$RpgItemRarityToJson(this);
}

@JsonSerializable()
@CopyWith()
class RpgItem {
  final String uuid;
  final String name;
  final String description;
  final String categoryId;

  final List<RpgItemRarity> placeOfFindings;
  final DiceRoll? patchSize;

  /// price without looking at the exchange rates. always a multiple of the smalles currency definition
  final int baseCurrencyPrice;

  factory RpgItem.fromJson(Map<String, dynamic> json) =>
      _$RpgItemFromJson(json);

  RpgItem({
    required this.uuid,
    required this.name,
    required this.patchSize,
    required this.categoryId,
    required this.description,
    required this.baseCurrencyPrice,
    required this.placeOfFindings,
  });

  Map<String, dynamic> toJson() => _$RpgItemToJson(this);
}

@JsonSerializable()
@CopyWith()
class DiceRoll {
  int numDice; // Number of dice
  int diceSides; // Type of dice (e.g., D10 -> 10 sides)
  int modifier; // Modifier added to the roll (can be positive or negative)

  DiceRoll({
    required this.numDice,
    required this.diceSides,
    required this.modifier,
  });
  Map<String, dynamic> toJson() => _$DiceRollToJson(this);

  factory DiceRoll.fromJson(Map<String, dynamic> json) =>
      _$DiceRollFromJson(json);

  // Parse a string like "1D10+5" or "2D6-1" or "2W6+1" into a DiceRoll object
  factory DiceRoll.parse(String input) {
    final cleanedInput =
        input.replaceAll(RegExp(r'[^0-9DW+-]', caseSensitive: false), '');

    final diceRegex =
        RegExp(r'(\d*)[DW](\d+)([+-]?\d+)?', caseSensitive: false);
    final match = diceRegex.firstMatch(cleanedInput);

    if (match == null) {
      throw const FormatException('Invalid dice roll format');
    }

    final numDiceStr = match.group(1);
    final numDice =
        numDiceStr == null || numDiceStr.isEmpty ? 1 : int.parse(numDiceStr);

    final diceSides = int.parse(match.group(2)!);

    final modifierStr = match.group(3);
    final modifier = modifierStr != null ? int.parse(modifierStr) : 0;

    return DiceRoll(
      numDice: numDice,
      diceSides: diceSides,
      modifier: modifier,
    );
  }

  @override
  String toString() {
    var modString = modifier == 0 ? "" : modifier;
    return '${numDice}D$diceSides${modifier > 0 ? '+' : ''}$modString';
  }

  // Roll the dice and calculate the total value
  int roll() {
    final random = Random();
    int total = 0;
    for (int i = 0; i < numDice; i++) {
      total += random.nextInt(diceSides) + 1;
    }
    return max(0, total + modifier);
  }
}

bool areTwoValueTypesSimilar(CharacterStatValueType valueType,
    CharacterStatValueType? lastStatTypeUsed) {
  if (lastStatTypeUsed == null) {
    false;
  }

  if (lastStatTypeUsed == valueType) return true;
  if (lastStatTypeUsed == CharacterStatValueType.multiLineText &&
      valueType == CharacterStatValueType.singleLineText) {
    return true;
  }
  if (valueType == CharacterStatValueType.multiLineText &&
      lastStatTypeUsed == CharacterStatValueType.singleLineText) {
    return true;
  }

  return false;
}
