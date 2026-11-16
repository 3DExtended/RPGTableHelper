import 'dart:math';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quest_keeper/models/prepared_character.dart';

part 'rpg_configuration_model.g.dart';

@JsonEnum()
enum InitiativeBonusField {
  value,
  otherValue,
  maxValue,
}

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

  /// Campaign-marked stat used as the initiative bonus hint for players.
  final String? initiativeBonusStatUuid;
  final String? initiativeBonusListEntryUuid;
  final InitiativeBonusField? initiativeBonusField;

  /// Campaign default character-sheet skin id (`classic_light`, …).
  @JsonKey(includeIfNull: false)
  final String? defaultSkinId;

  /// Characters the game master prepared; a joining player can take one
  /// over. Older app versions ignore the key.
  @JsonKey(includeIfNull: false)
  final List<PreparedCharacter>? preparedCharacters;

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
    this.initiativeBonusStatUuid,
    this.initiativeBonusListEntryUuid,
    this.initiativeBonusField,
    this.defaultSkinId,
    this.preparedCharacters,
  });

  Map<String, dynamic> toJson() => _$RpgConfigurationModelToJson(this);

  RpgItem getItemForId(String id) {
    return allItems.singleWhere((it) => it.uuid == id);
  }

  static RpgConfigurationModel getBaseConfiguration() => RpgConfigurationModel(
        // Template "Fantasy 5E (SRD)". The spell texts are taken from the
        // German edition of the SRD 5.2.1 (CC-BY-4.0); the attribution is
        // shown on AboutAndLicensesScreen.
        rpgName: "Fantasy 5E (SRD)",
        initiativeBonusStatUuid: "44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3",
        initiativeBonusListEntryUuid: "a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4",
        initiativeBonusField: InitiativeBonusField.otherValue,
        currencyDefinition: CurrencyDefinition(
          currencyTypes: [
            // SRD 5.2.1 coin values: 10 KM = 1 SM, 10 SM = 1 GM,
            // 10 GM = 1 PM. Electrum (1 EM = 5 SM) is left out: the greedy
            // split would show most amounts with an EM, and the coin icons
            // only know these four names. Prices are stored in Kupfer.
            CurrencyType(name: "Kupfer", multipleOfPreviousValue: null),
            CurrencyType(name: "Silber", multipleOfPreviousValue: 10),
            CurrencyType(name: "Gold", multipleOfPreviousValue: 10),
            CurrencyType(name: "Platin", multipleOfPreviousValue: 10),
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
            colorCode: "#ffff00ff",
            iconName: "spellbook-svgrepo-com",
            uuid: "d0a0168f-02d0-4205-b0af-689b52f24186",
            name: "Kleidung",
            subCategories: [
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "263dc67f-bfae-4559-a909-1479e24354a6",
                name: "Rüstung",
                subCategories: [],
              ),
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "544cdaac-a8d2-4ee6-8a8f-4772bfb95a93",
                name: "Accessoire",
                subCategories: [],
              ),
            ],
          ),
          ItemCategory(
            colorCode: "#ff3df956",
            iconName: "leaf",
            uuid: "b895a30a-2c0a-4aba-8629-9a363e405281",
            name: "Zutat",
            subCategories: [],
          ),
          ItemCategory(
            colorCode: "#ff3df9bd",
            iconName: "flask-laboratory-svgrepo-com",
            uuid: "4bba577f-c4c0-43a4-bc70-cbb39cbb7bee",
            name: "Trank",
            subCategories: [
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "79773521-2fd6-4aff-942e-87b9e4bb6599",
                name: "Heilung",
                subCategories: [],
              ),
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "64031e58-a816-4c84-9ca8-d80cd514a908",
                name: "Gift",
                subCategories: [],
              ),
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "b0b0b636-6637-48c2-a899-4bd62435dba0",
                name: "Gegengift",
                subCategories: [],
              ),
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "04b75751-0a85-4d82-8b66-361f47743797",
                name: "Stärkung",
                subCategories: [],
              ),
            ],
          ),
          ItemCategory(
            colorCode: "#ffff00ff",
            iconName: "plant-left-svgrepo-com",
            uuid: "f9cc6513-36b4-4e4e-b3ba-dd9f40fca078",
            name: "Waffe",
            subCategories: [
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "1666d606-b839-4664-930d-2f51b552111c",
                name: "Finesse",
                subCategories: [],
              ),
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "4ab9bded-a516-4a1b-a66d-fd5d972957cf",
                name: "Fernkampf",
                subCategories: [],
              ),
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "8d86c1df-fe26-420d-8ccf-f5ef0af535a3",
                name: "Magie",
                subCategories: [],
              ),
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "1d21556e-8993-4883-a9a5-f9853697f21e",
                name: "Wurfwaffe",
                subCategories: [],
              ),
            ],
          ),
          ItemCategory(
            colorCode: "#ffff00ff",
            iconName: "bone",
            uuid: "c7690cb0-39b4-45d2-b7c5-75b6e8eeb88f",
            name: "Schatz",
            subCategories: [],
          ),
          ItemCategory(
            colorCode: "#ffff00ff",
            iconName: "spellbook-svgrepo-com",
            uuid: "f9f4ba0d-9314-4f70-b7ba-fa6375490c70",
            name: "Werkzeug",
            subCategories: [],
          ),
        ],
        allItems: [
          RpgItem(
            imageDescription: null,
            imageUrlWithoutBasePath: null,
            patchSize: DiceRoll(numDice: 1, diceSides: 6, modifier: 1),
            uuid: "a7537746-260d-4aed-b182-26768a9c2d51",
            name: "Kl. Heiltrank",
            categoryId: "79773521-2fd6-4aff-942e-87b9e4bb6599",
            baseCurrencyPrice: 100,
            placeOfFindings: [],
            description:
                "1W4 Heilung bei Konsum\n\nEin kleiner Heiltrank, der auf natürliche (und nicht magische) Weise Trefferpunkte wiederherstellt.\nDieser Gegenstand ist fast unerlässlich für Kämpfe!",
          ),
          RpgItem(
              imageDescription: null,
              imageUrlWithoutBasePath: null,
              uuid: "8abe00a8-fa94-4e5d-9c99-2a68b9de60e7",
              name: "Rote Vitus Blüte",
              categoryId: "b895a30a-2c0a-4aba-8629-9a363e405281",
              baseCurrencyPrice: 1,
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
            imageDescription: null,
            imageUrlWithoutBasePath: null,
            uuid: "73b51a58-8a07-4de2-828c-d0952d42af34",
            name: "Fuchsschwanz",
            categoryId: "b895a30a-2c0a-4aba-8629-9a363e405281",
            baseCurrencyPrice: 10,
            placeOfFindings: [],
            description: "Der Schwanz eines Fuchses",
            patchSize: DiceRoll(numDice: 1, diceSides: 6, modifier: 1),
          ),
          RpgItem(
            imageDescription: null,
            imageUrlWithoutBasePath: null,
            uuid: "dc497952-1989-40d1-9d50-a5b4e53dd1be",
            name: "Kräuterkundeausrüstung",
            categoryId: "f9f4ba0d-9314-4f70-b7ba-fa6375490c70",
            baseCurrencyPrice: 500,
            placeOfFindings: [],
            description:
                "Werkzeug, um Pflanzen zu bestimmen und Heiltränke herzustellen.",
            patchSize: DiceRoll(numDice: 0, diceSides: 6, modifier: 0),
          ),
          RpgItem(
            uuid: "01920bc1-5c79-74fd-b604-c7c825067186",
            name: "Gelber Morgentau",
            description:
                "Der Gelbe Morgentau wächst dicht am Boden und hat winzige runde Blätter, die vom Stiel weg leicht gelblich werden. Er ist leicht zu verwechseln mit dem Grünen Morgentau, ist im Gegensatz zu diesem allerdings hochgiftig.",
            categoryId: "b895a30a-2c0a-4aba-8629-9a363e405281",
            imageUrlWithoutBasePath: null,
            imageDescription:
                "Der Gelbe Morgentau wächst in großen Patches dicht am Boden, wie eine bodendeckende Pflanze. Die Pflanze hat winzige runde Blätter und Blüten, die vom Stiel weg leicht gelblich werden. Die Pflanze erinnert an Klee oder Moos und wächst in dicht bewachsenen Wäldern.\nNutze einen Stil der in ein düsteres animiertes 3D Computerspiel für Erwachsene passt. Setze die Pflanze in eine passende Szene.",
            placeOfFindings: [],
            patchSize: DiceRoll(numDice: 2, diceSides: 2, modifier: 2),
            baseCurrencyPrice: 1,
          ),
          RpgItem(
            uuid: "01920bc5-599a-783f-8d88-38257ecf78f5",
            name: "Gemeiner Farn",
            description:
                "Der Gemeine Farn wächst gerne zwischen anderen Pflanzen und stiehlt ihre Nährstoffe. Bei Berührung drehen sich die fedrigen Farnblätter seitlich ein.",
            categoryId: "b895a30a-2c0a-4aba-8629-9a363e405281",
            imageUrlWithoutBasePath: null,
            imageDescription:
                "Der Gemeine Farn hat fedrige hellgrüne Farnblätter die sich seitlich eindrehen.\nNutze einen Stil der in ein düsteres animiertes 3D Computerspiel für Erwachsene passt. Setze die Pflanze in eine passende Szene.",
            placeOfFindings: [],
            patchSize: DiceRoll(numDice: 2, diceSides: 4, modifier: 0),
            baseCurrencyPrice: 1,
          ),
          RpgItem(
            uuid: "01921424-0eca-74bb-bc3d-be2c82996103",
            name: "Glücksklee",
            description:
                "Heilt bei rohem Verzehr 3 verlorene TP.\n\nDiese Kleeart wächst nah am Boden und besteht nur aus vierblättrigen Pflanzen, deren Äderung leicht golden schimmert.",
            categoryId: "b895a30a-2c0a-4aba-8629-9a363e405281",
            imageUrlWithoutBasePath: null,
            imageDescription:
                "\n\nDiese Kleeart wächst nah am Boden und besteht nur knallgrünen Blättern, die wie bei Glücksklee aussehen und deren Äderung leicht golden schimmert.\nNutze einen Stil der in ein düsteres animiertes 3D Computerspiel für Erwachsene passt. Setze die Pflanze in eine passende Szene.",
            placeOfFindings: [],
            patchSize: DiceRoll(numDice: 1, diceSides: 6, modifier: 1),
            baseCurrencyPrice: 100,
          ),
          RpgItem(
            uuid: "01921428-f433-7519-880f-d012289b60da",
            name: "Glutflechte",
            description:
                "Verringert unbehandelt für 1h jeglichen erhaltenen Kälteschaden um 1.\n\nDie Glutflechte wächst schuppenartig an Steinen entlang. Sie ist leicht an ihrer gelb-orangen Farbe zu erkennen.",
            categoryId: "b895a30a-2c0a-4aba-8629-9a363e405281",
            imageUrlWithoutBasePath: null,
            imageDescription:
                "\n\nDie Glutflechte wächst in schuppenartig Verflechtungen auf Steinen, wie eine Moosflechte. Sie ist gelb-orange.\nNutze einen Stil der in ein düsteres animiertes 3D Computerspiel für Erwachsene passt. Setze die Pflanze in eine passende Szene.",
            placeOfFindings: [],
            patchSize: DiceRoll(numDice: 1, diceSides: 6, modifier: 1),
            baseCurrencyPrice: 20,
          )
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
              tabName: "Hintergrund",
              isOptional: false,
              statsInTab: [
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "30e18433-748d-458c-bd5e-373c38e762bf",
                  jsonSerializedAdditionalData:
                      '{"example": "Ein Fischerdorf an der Nordküste, aufgewachsen bei der Großmutter."}',
                  name: "Herkunft",
                  helperText: "Wo kommt dein Charakter her?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
                // Klasse and Volk are asked once, in the character summary on
                // the Stats tab (characterNameWithLevelAndAdditionalDetails).
                // Campaigns created before keep their own copy of this config.
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "0070b224-95ac-4f0f-ab07-1ddb0d3d2ac8",
                  jsonSerializedAdditionalData:
                      '{"example": "Ehemalige Stadtwache, die nach einem Skandal den Dienst quittiert hat."}',
                  name: "Hintergrund",
                  helperText: "Welchen Hintergrund hat dein Charakter?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "37862834-261a-47b5-bd5c-9e315b8d26aa",
                  jsonSerializedAdditionalData:
                      '{"example": "Will den Mörder des Bruders finden – und fürchtet, was dann kommt."}',
                  name: "Antrieb",
                  helperText: "Was treibt deinen Charakter an?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "a464bfe4-d99f-475d-a4af-0f1e5f73290e",
                  jsonSerializedAdditionalData:
                      '{"example": "Groß und hager, rote Zöpfe, eine Narbe über der linken Braue."}',
                  name: "Aussehen",
                  helperText: "Wie sieht dein Charakter aus?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "5accd34c-eade-4754-b955-21e1d902c4d9",
                  jsonSerializedAdditionalData:
                      '{"example": "Elfisch, Zwergisch; Diebeswerkzeug, Laute."}',
                  name: "Weitere Übungen und Sprachen",
                  helperText: "Was kann dein Charakter noch?",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
              ]),
          CharacterStatsTabDefinition(
              isDefaultTab: true,
              uuid: "ebf46bc6-1e1e-4ea2-b580-caa992480e80",
              tabName: "Werte",
              isOptional: false,
              statsInTab: [
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "8b92f020-58f4-41d8-9844-580de13e607d",
                  name: "Charakter-Zusammenfassung",
                  helperText: "",
                  jsonSerializedAdditionalData:
                      "{\"values\":[{\"uuid\":\"019317b8-49eb-7575-9f8e-c28c9c8eded2\",\"label\":\"Klasse\"},{\"uuid\":\"019317b8-4bb6-7881-a4db-2a8ec3c751f6\",\"label\":\"Spezies\"}]}",
                  valueType: CharacterStatValueType
                      .characterNameWithLevelAndAdditionalDetails,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "273f7ce3-59db-4c34-bc90-83c53f3ea553",
                  jsonSerializedAdditionalData:
                      '{"example": "Halbelfin mit kurzen silbernen Haaren, in dunklem Reisemantel."}',
                  name: "Porträt",
                  helperText: "Erstelle ein Bild von deinem Charakter.",
                  valueType: CharacterStatValueType.singleImage,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3",
                  name: "Attribute",
                  helperText: "",
                  jsonSerializedAdditionalData:
                      '{"askOnLevelUp":true,"values":[{"uuid":"76183b57-d6f3-4414-962c-837488ed0384", "label": "Charisma"}, {"uuid":"529d0912-e1ae-41e2-beea-55bd194bfb20", "label": "Stärke"}, {"uuid":"0f6557a8-c3b6-4832-a673-a8903f87ff24", "label": "Intelligenz"}, {"uuid":"a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4", "label": "Geschicklichkeit"}, {"uuid":"81ffc65e-156a-4042-8bd6-5ed4d400e4bc", "label": "Konstitution"}, {"uuid":"167b94e6-d674-43a4-a25b-fca1309a12b0", "label": "Weisheit"}]}',
                  valueType:
                      CharacterStatValueType.listOfIntWithCalculatedValues,
                  editType: CharacterStatEditType.static,
                ),
                CharacterStatDefinition(
                    name: "Kampfwerte",
                    statUuid: "01933514-7eef-7523-a4cc-974802dc96e7",
                    helperText: "",
                    groupId: 0,
                    valueType: CharacterStatValueType.listOfIntsWithIcons,
                    editType: CharacterStatEditType.static,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    jsonSerializedAdditionalData:
                        "{\"askOnLevelUp\":true,\"values\":[{\"uuid\":\"01933512-97e4-70fe-877d-0e1f64224a00\",\"label\":\"RK\",\"iconName\":\"shield-halved\"},{\"uuid\":\"01933512-997d-7628-9de3-72827cf4f419\",\"label\":\"Bewegung\",\"iconName\":\"person-running\"},{\"uuid\":\"01933512-9cb6-7466-9977-0768e0dda2a7\",\"label\":\"ÜB\",\"iconName\":\"trophy\"},{\"uuid\":\"01933512-a096-701e-875d-05ad93810ba2\",\"label\":\"Temp. TP\",\"iconName\":\"shield-heart\"}]}"),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
                  jsonSerializedAdditionalData: '{"askOnLevelUp": true}',
                  name: "TP",
                  helperText: "Trefferpunkte",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: "1ce2f567-d540-498a-a677-9776d518622d",
                    name: "Rettungswürfe",
                    helperText: "In diesen Rettungswürfen bist du geübt.",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '{"multiselectIsAllowedToBeSelectedMultipleTimes":false, "options":[{"uuid": "a632fa33-faab-4247-9152-8ee5ba52cfeb", "label": "Stärke", "description": ""}, {"uuid": "3dbb5cb6-f256-4dfd-acae-ead1baedb27f", "label": "Geschicklichkeit", "description": ""},{"uuid": "86f66619-857a-47d5-8447-b3016da2a6a4", "label": "Konstitution", "description": ""},{"uuid": "a3c9cd51-bd58-4d01-b7bb-fe9dcd27f349", "label": "Intelligenz", "description": ""},{"uuid": "af398b67-d335-499b-b74e-39aeaff4dccd", "label": "Weisheit", "description": ""},{"uuid": "c723e604-ddec-4bb4-b329-6c1478b7bd60", "label": "Charisma", "description": ""}]}'),
                CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: "c5ef782a-8d8b-4a88-98b2-be277f741e4c",
                    name: "Fertigkeiten",
                    helperText: "In diesen Fertigkeiten bist du geübt.",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '{"multiselectIsAllowedToBeSelectedMultipleTimes":false,"options":['
                        '{"uuid": "de1fb5bc-3e3e-42e1-8b11-9dfafebfdfbc", "label": "Akrobatik (Ges)", "description": ""},'
                        '{"uuid": "4da1f35a-0ee9-44b0-84de-3341ee7eaad6", "label": "Arkane Kunde (Int)", "description": ""},'
                        '{"uuid": "89f12e22-178a-4d87-8517-4fe4787335f3", "label": "Athletik (Stä)", "description": ""},'
                        '{"uuid": "3196199d-f023-4289-a8ce-e5659d54deae", "label": "Auftreten (Cha)", "description": ""},'
                        '{"uuid": "1d477c82-7289-4524-b807-3734f9e1e297", "label": "Einschüchtern (Cha)", "description": ""},'
                        '{"uuid": "9ab19470-306b-4be0-a23d-ab8bc9c79e0d", "label": "Fingerfertigkeit (Ges)", "description": ""},'
                        '{"uuid": "3f952394-664f-44e1-8b36-116106266c0f", "label": "Geschichte (Int)", "description": ""},'
                        '{"uuid": "f5c38dde-e288-473b-9113-0ae7a960af23", "label": "Heilkunde (Wei)", "description": ""},'
                        '{"uuid": "b62eeed4-fe7f-47ce-b14c-041b6b1467d6", "label": "Heimlichkeit (Ges)", "description": ""},'
                        '{"uuid": "9a187aa5-71bb-40c3-b749-d12ace0471b9", "label": "Mit Tieren umgehen (Wei)", "description": ""},'
                        '{"uuid": "a3040091-cf15-4e63-87b7-3c449a9b3dd4", "label": "Motiv erkennen (Wei)", "description": ""},'
                        '{"uuid": "d6833b01-0f6e-4bc3-9590-60a6bc3cdc01", "label": "Nachforschungen (Int)", "description": ""},'
                        '{"uuid": "c6e1f42a-44ef-406e-b009-245ceb9637f8", "label": "Naturkunde (Int)", "description": ""},'
                        '{"uuid": "21468550-7899-4188-a3cf-fdec85deb1ca", "label": "Religion (Int)", "description": ""},'
                        '{"uuid": "072ea46a-043c-4548-bb2d-9d340691d940", "label": "Täuschen (Cha)", "description": ""},'
                        '{"uuid": "bc922713-6614-4bd7-8d62-0607bcf03146", "label": "Überlebenskunst (Wei)", "description": ""},'
                        '{"uuid": "8957fe9f-9142-44fd-8354-d50c06c9b1a5", "label": "Überzeugen (Cha)", "description": ""},'
                        '{"uuid": "827f2550-9683-45cf-b8fb-cad229c47fe8", "label": "Wahrnehmung (Wei)", "description": ""}'
                        ']}'),
              ]),
          CharacterStatsTabDefinition(
              isDefaultTab: false,
              uuid: "11cc5da3-624b-40d4-9477-468a0a6b4670",
              tabName: "Merkmale",
              isOptional: false,
              statsInTab: [
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "893bab17-6c13-4ed5-a287-8eaa135a54ef",
                  jsonSerializedAdditionalData:
                      '{"askOnLevelUp":true,"example": "Dunkelsicht 18 m; Vorteil gegen Vergiftung."}',
                  name: "Merkmale",
                  helperText:
                      "Klassenmerkmale, Merkmale deiner Spezies und Talente",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
              ]),
          CharacterStatsTabDefinition(
              isDefaultTab: false,
              uuid: "f0c39bb7-1d95-4d7a-aaf2-80bf31f2662a",
              tabName: "Angriffe",
              isOptional: false,
              statsInTab: [
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "3219934b-09fc-409b-8413-9e56b864c664",
                  jsonSerializedAdditionalData:
                      '{"askOnLevelUp":true,"example": "Langschwert +5, 1W8+3 Hieb; Kurzbogen +4, 1W6+2 Stich."}',
                  name: "Angriffe",
                  helperText: "Angriffe mit Waffen und waffenlose Angriffe",
                  valueType: CharacterStatValueType.multiLineText,
                  editType: CharacterStatEditType.static,
                ),
              ]),
          CharacterStatsTabDefinition(
              uuid: "9421920d-99c2-4882-8a39-53564e7b2920",
              isDefaultTab: false,
              tabName: "Zauber",
              isOptional: true,
              statsInTab: [
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "2438aac8-4a67-41ca-aad9-3c838b7c5cf3",
                  jsonSerializedAdditionalData: '{"askOnLevelUp": true}',
                  name: "Zauberplätze gesamt",
                  helperText: "Wie viele Zauberplätze hast du insgesamt noch?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: "c1b7a131-c239-4d56-8008-b3d4b654189d",
                    name: "Zaubertricks",
                    helperText: "Welche Zaubertricks kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '{"askOnLevelUp":true,"multiselectIsAllowedToBeSelectedMultipleTimes":false,"options":['
                        '{"uuid": "1e720492-1520-4bf3-86a3-98c4f61be329", "label": "Botschaft", "summary": "Flüstere eine Botschaft zu einem Ziel; nur ihr beide hört sie.", "description": "Zaubertrick der Verwandlung (Barde, Druide, Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: 36 Meter\\nKomponenten: G, M (ein Stück Kupferdraht)\\nWirkungsdauer: 1 Runde\\nDu deutest auf eine Kreatur in Reichweite und flüsterst eine Botschaft. Das Ziel (und nur dieses) hört die Botschaft und kann mit einem Flüstern antworten, das nur du hörst.\\nDu kannst diesen Zauber durch massive Gegenstände hindurch wirken, wenn du mit dem Ziel vertraut bist und weißt, dass es sich hinter der Barriere befindet. Magische Stille, 30 Zentimeter Stein, Metall oder Holz sowie dünnes Bleiblech blockieren den Zauber."},'
                        '{"uuid": "bc6ddcc2-ccf5-4a70-9b0f-afbf17c7be47", "label": "Magierhand", "summary": "Geisterhafte Hand erscheint und manipuliert leichte Gegenstände.", "description": "Zaubertrick der Beschwörung (Barde, Hexenmeister, Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: 9 Meter\\nKomponenten: V, G\\nWirkungsdauer: 1 Minute\\nAn einem Punkt deiner Wahl in Reichweite erscheint eine geisterhafte schwebende Hand. Sie bleibt für die Wirkungsdauer bestehen. Die Hand verschwindet, wenn sie weiter als neun Meter von dir entfernt ist oder du den Zauber erneut wirkst.\\nWenn du den Zauber wirkst, kannst du mithilfe der Hand mit Gegenständen interagieren, unverschlossene Türen oder Behälter öffnen, Gegenstände in einem Behälter verstauen oder daraus hervorholen oder den Inhalt einer Phiole ausgießen.\\nIn deinen folgenden Zügen kannst du die Hand als magische Aktion erneut auf diese Art kontrollieren. Als Teil dieser Aktion kannst du die Hand bis zu neun Meter weit bewegen.\\nDie Hand kann nicht angreifen, keine magischen Gegenstände aktivieren und nicht mehr als fünf Kilogramm Gewicht tragen."},'
                        '{"uuid": "5b9c7345-8cda-469b-8e00-4ff47f50ce9c", "label": "Gift versprühen", "summary": "Giftnebel auf eine Kreatur; Fernkampf-Zauberangriff mit Giftschaden.", "description": "Zaubertrick der Nekromantie (Druide, Hexenmeister, Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: 9 Meter\\nKomponenten: V, G\\nWirkungsdauer: Unmittelbar\\nDu sprühst giftigen Nebel auf eine Kreatur in Reichweite. Führe einen Fernkampf-Zauberangriff gegen das Ziel aus. Bei einem Treffer erleidet das Ziel 1W12 Giftschaden.\\nZaubertrick-Aufwertung: Der Schaden wird um jeweils 1W12 erhöht, wenn du die 5. (2W12), die 11. (3W12) und die 17. (4W12) Stufe erreichst."},'
                        '{"uuid": "4ee11bf7-1f97-4209-b2e4-d05346b04ed9", "label": "Flammen erzeugen", "summary": "Flamme in der Hand spendet Licht; du kannst damit Feuer schleudern.", "description": "Zaubertrick der Beschwörung (Druide)\\nZeitaufwand: Bonusaktion\\nReichweite: Selbst\\nKomponenten: V, G\\nWirkungsdauer: 10 Minuten\\nIn deiner Hand erscheint für die Wirkungsdauer eine flackernde Flamme. Sie strahlt keine Wärme aus und kann nichts entzünden, spendet jedoch in einem Radius von sechs Metern helles Licht und in einem Radius von weiteren sechs Metern dämmriges Licht. Der Zauber endet vorzeitig, wenn du ihn erneut wirkst.\\nBis der Zauber endet, kannst du eine magische Aktion ausführen, um Feuer auf eine Kreatur oder einen Gegenstand im Abstand von bis zu 18 Metern von dir zu schleudern. Führe einen Fernkampf-Zauberangriff aus. Bei einem Treffer erleidet das Ziel 1W8 Feuerschaden.\\nZaubertrick-Aufwertung: Der Schaden wird um jeweils 1W8 erhöht, wenn du die 5. (2W8), die 11. (3W8) und die 17. (4W8) Stufe erreichst."},'
                        '{"uuid": "c247bc4f-f04b-4301-a401-fe0908eb3ca9", "label": "Kalte Hand", "summary": "Nahkampf-Zauberangriff mit Grabeskälte; das Ziel kann kurz nicht heilen.", "description": "Zaubertrick der Nekromantie (Hexenmeister, Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: Berührung\\nKomponenten: V, G\\nWirkungsdauer: Unmittelbar\\nDu kanalisierst Grabeskälte und führst einen Nahkampf-Zauberangriff auf ein Ziel in Reichweite aus. Bei einem Treffer erleidet das Ziel 1W10 nekrotischen Schaden und kann bis zum Ende deines nächsten Zugs keine Trefferpunkte zurückerhalten.\\nZaubertrick-Aufwertung: Der Schaden wird um jeweils 1W10 erhöht, wenn du die 5. (2W10), die 11. (3W10) und die 17. (4W10) Stufe erreichst."},'
                        '{"uuid": "c3fa6593-ac9c-44d0-b158-09555d0f3f5e", "label": "Druidenkunst", "summary": "Kleine Naturwunder: Wettervorhersage, Blüten, Sinneseindrücke, Feuerspiel.", "description": "Zaubertrick der Verwandlung (Druide)\\nZeitaufwand: Aktion\\nReichweite: 9 Meter\\nKomponenten: V, G\\nWirkungsdauer: Unmittelbar\\nDu flüsterst den Geistern der Natur zu und erzeugst in Reichweite einen der folgenden magischen Effekte.\\nWettersensor: Du erschaffst einen winzigen, harmlosen sensorischen Effekt, der das Wetter an deinem Aufenthaltsort in den nächsten 24 Stunden vorhersagt. Der Effekt kann sich als goldene Kugel für einen wolkenlosen Himmel, als Wolke für Regen, als Schneeflocken für Schnee oder dergleichen manifestieren. Dieser Effekt hält eine Runde lang an.\\nErblühen: Du bewirkst, dass sofort eine Blume erblüht, sich eine Samenkapsel oder eine Blattknospe öffnet.\\nSensorischer Effekt: Du erzeugst einen harmlosen sensorischen Effekt, beispielsweise fallende Blätter, geisterhafte tanzende Feenwesen, eine sanfte Brise, die Geräusche eines Tieres oder leichten Stinktiergeruch. Der Effekt muss in einen Würfel mit 1,5 Metern Kantenlänge passen.\\nFeuerspiel: Du entzündest oder löschst eine Kerze, eine Fackel oder ein Lagerfeuer."},'
                        '{"uuid": "30928f34-7632-469a-bd3d-6f76ee660f98", "label": "Shillelagh", "summary": "Knüppel oder Kampfstab nutzt dein Zauberattribut und trifft härter.", "description": "Zaubertrick der Verwandlung (Druide)\\nZeitaufwand: Bonusaktion\\nReichweite: Selbst\\nKomponenten: V, G, M (ein Mistelzweig)\\nWirkungsdauer: 1 Minute\\nDas Holz eines Knüppels oder Kampfstabs, den du in der Hand hältst, wird von der Macht der Natur erfüllt. Für die Wirkungsdauer kannst du bei Angriffs- und Schadenswürfen von Nahkampfangriffen mit dieser Waffe dein Attribut zum Zauberwirken anstatt Stärke verwenden, und der Schadenswürfel der Waffe wird zu einem W8. Wenn der Angriff Schaden bewirkt, kann dies Energieschaden oder die normale Schadensart der Waffe sein (nach deiner Wahl).\\nDer Zauber endet vorzeitig, wenn du ihn erneut wirkst oder die Waffe loslässt.\\nZaubertrick-Aufwertung: Der Schadenswürfel ändert sich, wenn du die 5. (W10), die 11. (W12) und die 17. (2W6) Stufe erreichst."}'
                        ']}'),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "18877c24-515a-4788-a657-d50915a5c0cc",
                  name: "Zauberplätze 1. Grades",
                  helperText:
                      "Wie viele Zauberplätze des 1. Grades hast du heute verbraucht?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: "31a52ed2-3e7b-42ac-8f3e-490b3a04027a",
                    name: "Zauber 1. Grades",
                    helperText: "Welche Zauber des 1. Grades kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '{"multiselectIsAllowedToBeSelectedMultipleTimes":false,"options":['
                        '{"uuid": "e79adcb9-4d57-45e6-9d05-29aeb2bbfe1a", "label": "Brennende Hände", "summary": "Flammenkegel; Geschicklichkeitsrettungswurf gegen Feuerschaden.", "description": "Hervorrufungszauber 1. Grades (Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: Selbst\\nKomponenten: V, G\\nWirkungsdauer: Unmittelbar\\nDu verschießt ein dünnes Flammenband. Jede Kreatur in einem Kegel von 4,5 Metern führt einen Geschicklichkeitsrettungswurf aus. Misslingt der Wurf, so erleidet sie 3W6 Feuerschaden, anderenfalls die Hälfte.\\nBrennbare Gegenstände im Kegel, die nicht getragen oder gehalten werden, beginnen zu brennen.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 1. wird der Schaden um 1W6 erhöht."},'
                        '{"uuid": "f28e6faa-1cce-4f99-8f4f-30e9b89defd7", "label": "Magisches Geschoss", "summary": "Drei magische Geschosse treffen automatisch.", "description": "Hervorrufungszauber 1. Grades (Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: 36 Meter\\nKomponenten: V, G\\nWirkungsdauer: Unmittelbar\\nDu erschaffst drei leuchtende Wurfpfeile aus magischer Energie. Jeder Wurfpfeil trifft eine Kreatur deiner Wahl in Reichweite, die du sehen kannst. Ein Wurfpfeil fügt seinem Ziel 1W4+1 Energieschaden zu. Die Wurfpfeile treffen alle gleichzeitig. Du kannst bestimmen, ob sie dieselbe oder verschiedene Kreaturen treffen.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 1. erzeugt der Zauber einen weiteren Wurfpfeil."},'
                        '{"uuid": "94a4169b-80c3-4819-bb9f-4e4fc40fb294", "label": "Höllischer Tadel", "summary": "Reaktion: Feuerschaden an den Angreifer, der dich verletzt.", "description": "Hervorrufungszauber 1. Grades (Hexenmeister)\\nZeitaufwand: Reaktion, die du ausführst, wenn du Schaden durch eine Kreatur im Abstand von bis zu 18 Metern von dir erlitten hast, die du sehen kannst\\nReichweite: 18 Meter\\nKomponenten: V, G\\nWirkungsdauer: Unmittelbar\\nDie Kreatur, die dir Schaden zugefügt hat, ist kurz von grünen Flammen umgeben. Sie führt einen Geschicklichkeitsrettungswurf aus. Misslingt der Wurf, so erleidet sie 2W10 Feuerschaden, anderenfalls die Hälfte.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 1. wird der Schaden um 1W10 erhöht."},'
                        '{"uuid": "6c0490b7-2da1-41d2-84e1-c0e4deb98ab3", "label": "Mit Tieren sprechen", "summary": "Verstehe und antworte Tieren für kurze Zeit.", "description": "Erkenntniszauber 1. Grades (Barde, Druide, Hexenmeister, Waldläufer)\\nZeitaufwand: Aktion oder Ritual\\nReichweite: Selbst\\nKomponenten: V, G\\nWirkungsdauer: 10 Minuten\\nFür die Wirkungsdauer kannst du Tiere verstehen und verbal mit ihnen kommunizieren, und du kannst beliebige Fertigkeitsoptionen der Beeinflussen-Aktion auf sie anwenden.\\nDie meisten Tiere haben zu Themen abseits von Überleben oder Gefährtenschaft nicht viel zu sagen. Sie sind jedoch zumindest in der Lage, Informationen über nahe Orte und Monster sowie über Ereignisse mitzuteilen, die sie innerhalb des letzten Tages erlebt haben."},'
                        '{"uuid": "be12d521-1a3c-440f-90bc-1ab262df56c9", "label": "Magie entdecken", "summary": "Spüre Magie in deiner Nähe und erkenne die Schule von Zaubern.", "description": "Erkenntniszauber 1. Grades (Barde, Druide, Hexenmeister, Kleriker, Magier, Paladin, Waldläufer, Zauberer)\\nZeitaufwand: Aktion oder Ritual\\nReichweite: Selbst\\nKomponenten: V, G\\nWirkungsdauer: Konzentration, bis zu 10 Minuten\\nWährend der Wirkungsdauer nimmst du magische Effekte im Abstand von bis zu neun Metern von dir wahr. Wenn du magische Effekte wahrnimmst, kannst du die magische Aktion ausführen, um rund um sichtbare Kreaturen und Gegenstände im Bereich, auf welche die Magie wirkt, eine schwache Aura zu sehen. Wurde der Effekt durch einen Zauber hervorgerufen, so erkennst du dessen Schule der Magie.\\nDer Zauber wird von 30 Zentimetern Stein, Erde oder Holz sowie von 2,5 Zentimetern Metall oder einer dünnen Bleischicht blockiert."},'
                        '{"uuid": "94746221-d26a-496a-bdc6-44a457db8eaf", "label": "Heilendes Wort", "summary": "Bonusaktion: heile eine Kreatur in Reichweite.", "description": "Bannzauber 1. Grades (Barde, Druide, Kleriker)\\nZeitaufwand: Bonusaktion\\nReichweite: 18 Meter\\nKomponenten: V\\nWirkungsdauer: Unmittelbar\\nEine Kreatur deiner Wahl in Reichweite, die du sehen kannst, erhält Trefferpunkte in Höhe von 2W4 plus deinem Zauberwirken-Attributsmodifikator zurück.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 1. wird die Heilung um 2W4 Trefferpunkte erhöht."}'
                        ']}'),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "cae3e22b-5674-4728-82d4-c8a28615fcdd",
                  name: "Zauberplätze 2. Grades",
                  helperText:
                      "Wie viele Zauberplätze des 2. Grades hast du heute verbraucht?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: "212b9948-bc45-48f1-af39-bc84d6c5283f",
                    name: "Zauber 2. Grades",
                    helperText: "Welche Zauber des 2. Grades kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '{"multiselectIsAllowedToBeSelectedMultipleTimes":false,"options":['
                        '{"uuid": "10978c13-95c7-4179-bd91-e4270547ebe2", "label": "Flammenkugel", "summary": "Bewegliche Feuerkugel, die Kreaturen in der Nähe versengt.", "description": "Beschwörungszauber 2. Grades (Druide, Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: 18 Meter\\nKomponenten: V, G, M (eine Kugel aus Wachs)\\nWirkungsdauer: Konzentration, bis zu 1 Minute\\nDu erzeugst in einem freien Bereich in Reichweite auf dem Boden eine flammende Kugel mit einem Durchmesser von 1,5 Metern. Die Kugel bleibt für die Wirkungsdauer bestehen. Jede Kreatur, die ihren Zug im Abstand von bis zu 1,5 Metern um die Kugel beendet, führt einen Geschicklichkeitsrettungswurf aus. Misslingt der Wurf, so erleidet sie 2W6 Feuerschaden, anderenfalls die Hälfte.\\nAls Bonusaktion kannst du die Kugel bis zu neun Meter weit über den Boden rollen lassen. Wenn du die Kugel in den Bereich einer Kreatur bewegst, muss diese den Rettungswurf gegen die Kugel ausführen, und die Kugel beendet ihre Bewegung für diesen Zug.\\nBewegst du die Kugel, so kannst du sie über bis zu 1,5 Meter hohe Hindernisse dirigieren und über bis zu drei Meter breite Gruben springen lassen. Brennbare Gegenstände, die nicht getragen oder gehalten werden, beginnen zu brennen, wenn sie von der Kugel berührt werden. Die Kugel spendet in einem Radius von sechs Metern helles Licht sowie in einem Radius von weiteren sechs Metern dämmriges Licht.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 2. wird der Schaden um 1W6 erhöht."},'
                        '{"uuid": "7f182652-7da8-4b11-9e1c-de0393fd30b6", "label": "Sengender Strahl", "summary": "Drei Feuerstrahlen auf ein oder mehrere Ziele.", "description": "Hervorrufungszauber 2. Grades (Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: 36 Meter\\nKomponenten: V, G\\nWirkungsdauer: Unmittelbar\\nDu schleuderst drei feurige Strahlen. Du kannst sie auf ein Ziel oder auf mehrere Ziele in Reichweite schleudern. Führe für jeden Strahl einen Fernkampf-Zauberangriff aus. Bei einem Treffer erleidet das Ziel 2W6 Feuerschaden pro Strahl.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 2. kannst du einen zusätzlichen Strahl erzeugen."},'
                        '{"uuid": "774a0a67-ff6d-478e-ae6b-38158e1c5db0", "label": "Dornenwuchs", "summary": "Boden wird zu schwierigem Gelände voller Dornen.", "description": "Verwandlungszauber 2. Grades (Druide, Waldläufer)\\nZeitaufwand: Aktion\\nReichweite: 45 Meter\\nKomponenten: V, G, M (sieben Dornen)\\nWirkungsdauer: Konzentration, bis zu 10 Minuten\\nIn einem Radius von sechs Metern um einen Punkt in Reichweite wird der Boden von harten Stacheln und Dornen überwuchert. Der Bereich wird für die Wirkungsdauer zu schwierigem Gelände. Bewegt sich eine Kreatur in oder durch den Bereich, so erleidet sie pro zurückgelegten 1,5 Metern 2W4 Stichschaden.\\nDie Verwandlung des Bodens ist als natürlich getarnt. Jede Kreatur, die den Bereich beim Wirken des Zaubers nicht sehen kann, muss die Suchen-Aktion ausführen und einen Weisheitswurf (Überlebenskunst oder Wahrnehmung) gegen deinen Zauberrettungswurf-SG ausführen. Bei einem Erfolg erkennt sie das Gelände vor dem Betreten als gefährlich."},'
                        '{"uuid": "b2aa3dc4-ac1d-4be4-bd81-db41e7501ae5", "label": "Spurloses Gehen", "summary": "+10 auf Heimlichkeit für deine Gruppe; ihr hinterlasst keine Spuren.", "description": "Bannzauber 2. Grades (Druide, Waldläufer)\\nZeitaufwand: Aktion\\nReichweite: Selbst\\nKomponenten: V, G, M (Asche eines Mistelzweigs)\\nWirkungsdauer: Konzentration, bis zu 1 Stunde\\nVon dir geht für die Wirkungsdauer eine verhüllende Aura in einer Ausströmung von neun Metern aus. Du und jede Kreatur deiner Wahl habt in der Aura einen Bonus von +10 auf Geschicklichkeitswürfe (Heimlichkeit), und ihr hinterlasst keine Spuren."}'
                        ']}'),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "66f0e8dd-1fed-47d8-9e4d-88e0b8b2e2b0",
                  name: "Zauberplätze 3. Grades",
                  helperText:
                      "Wie viele Zauberplätze des 3. Grades hast du heute verbraucht?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: "f8b49ed4-a24a-45fb-8077-369fde7ef37c",
                    name: "Zauber 3. Grades",
                    helperText: "Welche Zauber des 3. Grades kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '{"multiselectIsAllowedToBeSelectedMultipleTimes":false,"options":['
                        '{"uuid": "f663078d-730f-422c-8d8f-dacdc8896981", "label": "Feuerball", "summary": "Explosive Feuerkugel mit großem Radius und hohem Schaden.", "description": "Hervorrufungszauber 3. Grades (Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: 45 Meter\\nKomponenten: V, G, M (eine Kugel aus Fledermaus-Guano und Schwefel)\\nWirkungsdauer: Unmittelbar\\nDu verschießt einen hellen Lichtstrahl auf einen Punkt deiner Wahl in Reichweite, wo er unter dumpfem Grollen zu einer Flammenexplosion detoniert. Jede Kreatur in einer Kugel mit einem Radius von sechs Metern um diesen Punkt führt einen Geschicklichkeitsrettungswurf aus. Misslingt der Wurf, so erleidet sie 8W6 Feuerschaden, anderenfalls die Hälfte.\\nBrennbare Gegenstände im Bereich, die nicht getragen oder gehalten werden, beginnen zu brennen.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 3. wird der Schaden um 1W6 erhöht."},'
                        '{"uuid": "327f07de-4191-43db-9ac5-a8c65382cff7", "label": "Furcht", "summary": "Kegel der Furcht; Betroffene müssen fliehen.", "description": "Illusionszauber 3. Grades (Barde, Hexenmeister, Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: Selbst\\nKomponenten: V, G, M (eine weiße Feder)\\nWirkungsdauer: Konzentration, bis zu 1 Minute\\nJede Kreatur in einem Kegel von neun Metern muss einen Weisheitsrettungswurf bestehen, oder sie lässt fallen, was auch immer sie hält, und ist für die Wirkungsdauer verängstigt.\\nEine verängstigte Kreatur führt in jedem ihrer Züge die Spurt-Aktion aus und entfernt sich auf dem sichersten Weg von dir, sofern möglich. Beendet eine Kreatur ihren Zug in einem Bereich, in dem du nicht in ihrer Sichtlinie bist, führt sie einen Weisheitsrettungswurf aus. Bei einem erfolgreichen Rettungswurf endet der Zauber bei der Kreatur."}'
                        ']}'),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "f4268470-6c7c-4fc8-8412-cf2fea4e19b1",
                  name: "Zauberplätze 4. Grades",
                  helperText:
                      "Wie viele Zauberplätze des 4. Grades hast du heute verbraucht?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: "612f5698-fdda-4485-b138-599ae3532520",
                    name: "Zauber 4. Grades",
                    helperText: "Welche Zauber des 4. Grades kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '{"multiselectIsAllowedToBeSelectedMultipleTimes":false,"options":['
                        '{"uuid": "ea4263df-f701-427a-a3fe-ff55288237a1", "label": "Feuerwand", "summary": "Brennende Barriere, die Schaden verursacht und Sicht blockiert.", "description": "Hervorrufungszauber 4. Grades (Druide, Magier, Zauberer)\\nZeitaufwand: Aktion\\nReichweite: 36 Meter\\nKomponenten: V, G, M (ein Stück Kohle)\\nWirkungsdauer: Konzentration, bis zu 1 Minute\\nDu erschaffst auf einer festen Oberfläche in Reichweite eine Feuerwand. Du kannst eine gerade Wand mit bis zu 18 Metern Länge oder eine ringförmige Wand mit einem Radius von bis zu drei Metern erschaffen. In beiden Fällen ist die Wand sechs Meter hoch und 30 Zentimeter dick. Die Wand ist undurchsichtig und bleibt für die Wirkungsdauer bestehen.\\nWenn die Wand erscheint, führt jede Kreatur in ihrem Bereich einen Geschicklichkeitsrettungswurf aus. Misslingt der Wurf, so erleidet die Kreatur 5W8 Feuerschaden, anderenfalls die Hälfte.\\nEine Seite der Wand, die du beim Wirken des Zaubers bestimmst, fügt jeder Kreatur, die ihren Zug im Abstand von bis zu drei Metern von der Seite oder in der Wand beendet, 5W8 Feuerschaden zu. Eine Kreatur erleidet den Schaden ebenfalls, wenn sie die Wand in einem Zug erstmals betritt. Die andere Seite der Wand bewirkt keinen Schaden.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 4. wird der Schaden um 1W8 erhöht."},'
                        '{"uuid": "2edae70c-e48f-45d4-b601-565f8ddbee83", "label": "Hüter des Glaubens", "summary": "Geisterhafter Wächter, der Gegnern in seiner Nähe schadet.", "description": "Beschwörungszauber 4. Grades (Kleriker)\\nZeitaufwand: Aktion\\nReichweite: 9 Meter\\nKomponenten: V\\nWirkungsdauer: 8 Stunden\\nIn einem freien Bereich in Reichweite, den du sehen kannst, erscheint ein großer geisterhafter Wächter und schwebt dort für die Wirkungsdauer. Der Wächter besetzt diesen Bereich und ist unverwundbar. Er erscheint in einer Gestalt, die deiner Gottheit oder deinem Pantheon entspricht.\\nEin Gegner, der sich in einem Zug erstmals in einen Bereich im Abstand von bis zu drei Metern vom Wächter bewegt oder den Zug dort beginnt, führt einen Geschicklichkeitsrettungswurf aus. Misslingt der Wurf, so erleidet er 20 gleißenden Schaden, anderenfalls die Hälfte. Wenn der Wächter insgesamt 60 Schaden bewirkt hat, verschwindet er."}'
                        ']}'),
                CharacterStatDefinition(
                  groupId: null,
                  isOptionalForAlternateForms: false,
                  isOptionalForCompanionCharacters: false,
                  statUuid: "940ef581-e6a5-4dcd-bb9d-567a0294a76d",
                  name: "Zauberplätze 5. Grades",
                  helperText:
                      "Wie viele Zauberplätze des 5. Grades hast du heute verbraucht?",
                  valueType: CharacterStatValueType.intWithMaxValue,
                  editType: CharacterStatEditType.oneTap,
                ),
                CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: "347e51fa-caf0-4054-8eb9-dac3ba48c281",
                    name: "Zauber 5. Grades",
                    helperText: "Welche Zauber des 5. Grades kennst du?",
                    valueType: CharacterStatValueType.multiselect,
                    editType: CharacterStatEditType.static,
                    jsonSerializedAdditionalData:
                        '{"multiselectIsAllowedToBeSelectedMultipleTimes":false,"options":['
                        '{"uuid": "e4927331-9272-4685-94bb-b243507142f5", "label": "Flammenschlag", "summary": "Säule aus Feuer und gleißendem Schaden von oben.", "description": "Hervorrufungszauber 5. Grades (Kleriker)\\nZeitaufwand: Aktion\\nReichweite: 18 Meter\\nKomponenten: V, G, M (eine Prise Schwefel)\\nWirkungsdauer: Unmittelbar\\nEine vertikale Säule aus strahlendem Feuer fährt von oben herab. Jede Kreatur in einem zwölf Meter hohen Zylinder mit einem Radius von drei Metern um einen Punkt in Reichweite führt einen Geschicklichkeitsrettungswurf aus. Misslingt der Wurf, so erleidet die Kreatur 5W6 Feuerschaden und 5W6 gleißenden Schaden, anderenfalls die Hälfte.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 5. werden Feuerschaden und gleißender Schaden um 1W6 erhöht."},'
                        '{"uuid": "cb5deac0-8f79-43dd-9358-3dc3179e43db", "label": "Elementar beschwören", "summary": "Elementargeist hält Kreaturen fest und fügt ihnen Schaden zu.", "description": "Beschwörungszauber 5. Grades (Druide, Magier)\\nZeitaufwand: Aktion\\nReichweite: 18 Meter\\nKomponenten: V, G\\nWirkungsdauer: Konzentration, bis zu 10 Minuten\\nDu beschwörst einen großen immateriellen Geist von den Elementarebenen, der in einem freien Bereich in Reichweite erscheint. Wähle das Element des Geistes aus, durch das seine Schadensart bestimmt wird: Erde (Schall), Feuer (Feuer), Luft (Blitz) oder Wasser (Kälte). Der Geist bleibt für die Wirkungsdauer bestehen.\\nWann immer eine Kreatur, die du sehen kannst, den Bereich des Geistes betritt oder ihren Zug im Abstand von bis zu 1,5 Metern vom Geist beginnt, kannst du die Kreatur zu einem Geschicklichkeitsrettungswurf zwingen, sofern der Geist keine Kreatur festgesetzt hat. Misslingt der Wurf, so erleidet das Ziel 8W8 Schaden je nach Art des Geists und ist festgesetzt, bis der Zauber endet. Das festgesetzte Ziel wiederholt den Rettungswurf zu Beginn jedes seiner Züge. Misslingt der Wurf, so erleidet das Ziel 4W8 Schaden je nach Art des Geists. Bei einem erfolgreichen Rettungswurf ist das Ziel nicht mehr vom Geist festgesetzt.\\nVerwenden von Zauberplätzen höheren Grades: Für jeden Zauberplatzgrad über dem 5. wird der Schaden um 1W8 erhöht."}'
                        ']}'),
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

  final String? colorCode;
  final String? iconName;

  factory ItemCategory.fromJson(Map<String, dynamic> json) =>
      _$ItemCategoryFromJson(json);

  ItemCategory({
    required this.uuid,
    required this.name,
    required this.colorCode,
    required this.iconName,
    required this.subCategories,
    this.hideInInventoryFilters = false,
  });

  Map<String, dynamic> toJson() => _$ItemCategoryToJson(this);

  static ItemCategory? parentCategoryForCategoryIdRecursive({
    required String categoryId,
    required List<ItemCategory> categories,
  }) {
    var mainCategoryWithSameId =
        categories.firstWhereOrNull((e) => e.uuid == categoryId);

    if (mainCategoryWithSameId != null) return mainCategoryWithSameId;

    var parentCategoryForId = categories.firstWhereOrNull(
        (e) => e.subCategories.any((se) => se.uuid == categoryId));

    return parentCategoryForId;
  }

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

  // jsonSerializedAdditionalData: {"options:":[{"uuid": "3a7fd649-2d76-4a93-8513-d5a8e8249b40", "label": "", "description": ""}], "multiselectIsAllowedToBeSelectedMultipleTimes":false}
  // RpgCharacterStatValue.serializedValue == {"values": ["3a7fd649-2d76-4a93-8513-d5a8e8249b40", "3a7fd649-2d76-4a93-8513-d5a8e8249b42"]}
  multiselect,

  intWithCalculatedValue, // => RpgCharacterStatValue.serializedValue == {"value": 12, "otherValue": 2}

  singleImage, // => RpgCharacterStatValue.serializedValue == {"imageUrl": "someUrl", "value": "some text"}

  // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
  // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
  listOfIntWithCalculatedValues,

  // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "Volk"}]}
  //    optional "showLevel": false hides the level (form and sheet); absent means true
  // => RpgCharacterStatValue.serializedValue == {"level": 12, "values":[{"uuid":"5f515750-0456-41e7-a1ee-97acb30c25c0", "value": "Zwerg"}], "imageUrl": "optional", "imagePrompt": "optional"}
  //    "level" is still written while the level is hidden (last value, default 1)
  characterNameWithLevelAndAdditionalDetails,

  // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP", "iconName": "asdf"}]}
  // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12,}]}
  listOfIntsWithIcons,

  // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheCompanionCharacter"}]}
  companionSelector,

  transformIntoAlternateFormBtn,

  // A row of boxes the player ticks with one tap on the sheet (e.g. stress).
  // => statConfiguration.jsonSerializedAdditionalData! == {"boxCount": 3, "labels": ["1", "2", "3"]}
  //    boxCount 1-20; "labels" is optional, an empty or missing label leaves the box unlabelled
  // => RpgCharacterStatValue.serializedValue == {"checked": [0, 2]}  (0-based indices of the ticked boxes)
  checkboxTrack,

  // A list of text entries: optional fixed, labelled slots plus (if allowed) the player's own entries.
  // => statConfiguration.jsonSerializedAdditionalData! == {"slots": [{"uuid": "...", "label": "Hauptaspekt"}], "allowCustomEntries": true}
  // => RpgCharacterStatValue.serializedValue == {"values": [{"uuid": "<slot uuid or own entry uuid>", "value": "text"}]}
  //    an entry whose uuid is not a slot uuid is one of the player's own entries
  textList,

  // Exactly one option, configured like multiselect.
  // => statConfiguration.jsonSerializedAdditionalData! == {"options": [{"uuid": "...", "label": "", "description": "", "summary": "optional"}]}
  // => RpgCharacterStatValue.serializedValue == {"value": "<uuid of the selected option>"}  ({"value": null} while nothing is selected)
  singleSelect,

  // Placeholder for a type written by a newer app version. Never stored:
  // CharacterStatDefinition.toJson writes the original type name back.
  unsupported,
}

@JsonSerializable()
@CopyWith()
class CharacterStatDefinition {
  final String name;
  final String statUuid;
  final String helperText;
  final int? groupId;

  /// Unknown types (from a newer app version) load as
  /// [CharacterStatValueType.unsupported] instead of failing the whole
  /// configuration; [unsupportedValueTypeName] keeps the original name.
  @JsonKey(unknownEnumValue: CharacterStatValueType.unsupported)
  final CharacterStatValueType valueType;
  final CharacterStatEditType editType;

  final bool? isOptionalForAlternateForms;
  final bool? isOptionalForCompanionCharacters;

  final String? jsonSerializedAdditionalData;

  /// The stored type name when [valueType] is
  /// [CharacterStatValueType.unsupported], so saving the configuration does
  /// not destroy a stat a newer app version created.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? unsupportedValueTypeName;

  CharacterStatDefinition({
    required this.statUuid,
    required this.name,
    required this.groupId,
    required this.helperText,
    required this.valueType,
    required this.editType,
    required this.isOptionalForAlternateForms,
    required this.isOptionalForCompanionCharacters,
    this.jsonSerializedAdditionalData,
    this.unsupportedValueTypeName,
  });

  factory CharacterStatDefinition.fromJson(Map<String, dynamic> json) {
    final parsed = _$CharacterStatDefinitionFromJson(json);
    if (parsed.valueType != CharacterStatValueType.unsupported) return parsed;
    return parsed.copyWith(
        unsupportedValueTypeName: json['valueType']?.toString());
  }

  Map<String, dynamic> toJson() {
    final json = _$CharacterStatDefinitionToJson(this);
    if (valueType == CharacterStatValueType.unsupported &&
        unsupportedValueTypeName != null) {
      json['valueType'] = unsupportedValueTypeName;
    }
    return json;
  }
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

  final String? imageUrlWithoutBasePath;
  final String? imageDescription;

  final List<RpgItemRarity> placeOfFindings;
  final DiceRoll? patchSize;

  /// price without looking at the exchange rates. always a multiple of the smalles currency definition
  final int baseCurrencyPrice;

  factory RpgItem.fromJson(Map<String, dynamic> json) =>
      _$RpgItemFromJson(json);

  RpgItem({
    required this.uuid,
    required this.name,
    required this.imageUrlWithoutBasePath,
    required this.patchSize,
    required this.categoryId,
    required this.description,
    required this.imageDescription,
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
