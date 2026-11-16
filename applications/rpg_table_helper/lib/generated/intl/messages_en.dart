// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(date) => "Expires: ${date}";

  static String m1(date) => "Last used: ${date}";

  static String m2(prefix) => "Prefix: ${prefix}";

  static String m3(date) => "Revoked: ${date}";

  static String m4(date) => "Settings changed: ${date}";

  static String m5(date) => "Last edited: ${date}";

  static String m6(condition) => "(if ${condition})";

  static String m7(label) => "Mod(${label})";

  static String m8(username) => " (for ${username})";

  static String m9(email) =>
      "We sent a code to ${email}. It\'s valid for two hours.";

  static String m10(characterNames) =>
      "Could not grant the items to ${characterNames}. Please try again.";

  static String m11(label, formattedBonus) =>
      "Add ${label} ${formattedBonus} to your roll";

  static String m12(campagneName) => "Invitation to “${campagneName}”";

  static String m13(campagneName, code) =>
      "Play in my campaign “${campagneName}”! Open QuestKeeper, tap “Join a campaign” and enter this code: ${code}";

  static String m14(code) => "Join code: ${code}";

  static String m15(playerName, username) =>
      "${playerName} (${username}) wants to join your campaign.";

  static String m16(count) =>
      "${Intl.plural(count, one: '1 open request', other: '${count} open requests')}";

  static String m17(count) => "at most ${count} characters";

  static String m18(count) => "at least ${count} characters";

  static String m19(amount) => "You received ${amount} new items:";

  static String m20(privacyPolicyLink) =>
      "You can read how we handle your data in our ${privacyPolicyLink}.";

  static String m21(property) => "The value of ${property}";

  static String m22(characterName) =>
      "Your request for “${characterName}” is with your game master. As soon as they approve, you can play here.";

  static String m23(count) =>
      "${Intl.plural(count, zero: 'No items in this category yet.', one: 'One item in this category.', other: '${count} items in this category.')}";

  static String m24(count, name) =>
      "${Intl.plural(count, one: 'Delete property “${name}”? One character already has a value for it, which will be lost.', other: 'Delete property “${name}”? ${count} characters already have values for it, which will be lost.')}";

  static String m25(count, tabName) =>
      "${Intl.plural(count, zero: 'Delete the empty tab “${tabName}”?', one: 'Delete tab “${tabName}” with one property? Character values will be lost.', other: 'Delete tab “${tabName}” with ${count} properties? Character values will be lost.')}";

  static String m26(number) => "Group ${number}";

  static String m27(name) => " (for category ${name})";

  static String m28(count) =>
      "${Intl.plural(count, zero: 'No items can be found here yet.', one: 'One item can be found here.', other: '${count} items can be found here.')}";

  static String m29(number) => "Place #${number}";

  static String m30(name) => "Property “${name}” deleted";

  static String m31(number) => "Ingredient #${number}";

  static String m32(number) => "Prerequisite #${number}";

  static String m33(count) =>
      "${Intl.plural(count, zero: 'No items', one: '1 item', other: '${count} items')}";

  static String m34(count) =>
      "${Intl.plural(count, one: '1 property', other: '${count} properties')}";

  static String m35(count) =>
      "${Intl.plural(count, zero: 'No recipes', one: '1 recipe', other: '${count} recipes')}";

  static String m36(count) =>
      "${Intl.plural(count, one: '1 tab', other: '${count} tabs')}";

  static String m37(count) =>
      "${Intl.plural(count, zero: 'You don\'t run a campaign yet.', one: 'You run 1 campaign.', other: 'You run ${count} campaigns.')}";

  static String m38(count) =>
      "${Intl.plural(count, zero: 'You don\'t have a character yet.', one: 'You have 1 character.', other: 'You have ${count} characters.')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addAdditionalEnemy": MessageLookupByLibrary.simpleMessage(
      "Add additional enemy",
    ),
    "addAnAdditionalEnemyBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Add more",
    ),
    "addBalance": MessageLookupByLibrary.simpleMessage("Add balance"),
    "addCharacterToCampagneModalTitle": MessageLookupByLibrary.simpleMessage(
      "Join a campaign",
    ),
    "addComputedTerm": MessageLookupByLibrary.simpleMessage(
      "Add building block",
    ),
    "addImageBtnLabel": MessageLookupByLibrary.simpleMessage("Image"),
    "addItems": MessageLookupByLibrary.simpleMessage("Add items"),
    "addNewTransformationComponent": MessageLookupByLibrary.simpleMessage(
      "Add new transformations",
    ),
    "addParagraphBtnLabel": MessageLookupByLibrary.simpleMessage("Paragraph"),
    "additionalElement": MessageLookupByLibrary.simpleMessage("Add element"),
    "additionalFightParticipants": MessageLookupByLibrary.simpleMessage(
      "Additional fight participants",
    ),
    "additionalSettings": MessageLookupByLibrary.simpleMessage(
      "Additional settings",
    ),
    "allCardsHidden": MessageLookupByLibrary.simpleMessage(
      "All cards are hidden",
    ),
    "allPlayers": MessageLookupByLibrary.simpleMessage("All players:"),
    "amount": MessageLookupByLibrary.simpleMessage("Amount"),
    "amountHeaderLabel": MessageLookupByLibrary.simpleMessage("Amount:"),
    "amountToCraftFieldLabel": MessageLookupByLibrary.simpleMessage("Amount"),
    "apiKeyCopied": MessageLookupByLibrary.simpleMessage("Copied to clipboard"),
    "apiKeyCopy": MessageLookupByLibrary.simpleMessage("Copy"),
    "apiKeyCreateConfirm": MessageLookupByLibrary.simpleMessage("Generate"),
    "apiKeyCreateFailed": MessageLookupByLibrary.simpleMessage(
      "Could not create the API key.",
    ),
    "apiKeyCreateHint": MessageLookupByLibrary.simpleMessage(
      "Only give a key to apps you trust. They act as you.",
    ),
    "apiKeyCreateTitle": MessageLookupByLibrary.simpleMessage("New API key"),
    "apiKeyCreatedBody": MessageLookupByLibrary.simpleMessage(
      "Copy your new key now. You won\'t see it again.",
    ),
    "apiKeyCreatedTitle": MessageLookupByLibrary.simpleMessage(
      "API key created",
    ),
    "apiKeyDone": MessageLookupByLibrary.simpleMessage("Done"),
    "apiKeyExpired": MessageLookupByLibrary.simpleMessage("Expired"),
    "apiKeyExpiresAt": m0,
    "apiKeyExpiry1Year": MessageLookupByLibrary.simpleMessage("1 year"),
    "apiKeyExpiry30Days": MessageLookupByLibrary.simpleMessage("30 days"),
    "apiKeyExpiry90Days": MessageLookupByLibrary.simpleMessage("90 days"),
    "apiKeyExpiryLabel": MessageLookupByLibrary.simpleMessage("Valid for"),
    "apiKeyExpiryNever": MessageLookupByLibrary.simpleMessage("Unlimited"),
    "apiKeyLastUsedAt": m1,
    "apiKeyNameLabel": MessageLookupByLibrary.simpleMessage(
      "Name, e.g. the app that uses it",
    ),
    "apiKeyNameRequired": MessageLookupByLibrary.simpleMessage("Enter a name."),
    "apiKeyNeverExpires": MessageLookupByLibrary.simpleMessage("Never expires"),
    "apiKeyNeverUsed": MessageLookupByLibrary.simpleMessage("Never used"),
    "apiKeyNoScopeSelected": MessageLookupByLibrary.simpleMessage(
      "Choose at least one permission.",
    ),
    "apiKeyPermissionsLabel": MessageLookupByLibrary.simpleMessage(
      "Permissions",
    ),
    "apiKeyPermissionsNeedServerUpdate": MessageLookupByLibrary.simpleMessage(
      "This server gives every key read access to your campaigns, characters and notes. You can choose permissions and a lifetime once the server is updated.",
    ),
    "apiKeyPrefix": m2,
    "apiKeyPresetCompanion": MessageLookupByLibrary.simpleMessage(
      "Player companion app",
    ),
    "apiKeyPresetCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "apiKeyPresetReadOnly": MessageLookupByLibrary.simpleMessage("Read only"),
    "apiKeyRevokeBody": MessageLookupByLibrary.simpleMessage(
      "This cannot be undone. Any app using this key loses access immediately.",
    ),
    "apiKeyRevokeConfirm": MessageLookupByLibrary.simpleMessage("Revoke"),
    "apiKeyRevokeFailed": MessageLookupByLibrary.simpleMessage(
      "Could not revoke the API key.",
    ),
    "apiKeyRevokeTitle": MessageLookupByLibrary.simpleMessage(
      "Revoke API key?",
    ),
    "apiKeyRevoked": MessageLookupByLibrary.simpleMessage("Revoked"),
    "apiKeyRevokedAt": m3,
    "apiKeyScopeCampaignsRead": MessageLookupByLibrary.simpleMessage(
      "See your campaigns and fellow players",
    ),
    "apiKeyScopeCharactersRead": MessageLookupByLibrary.simpleMessage(
      "Read your character sheets",
    ),
    "apiKeyScopeCharactersWrite": MessageLookupByLibrary.simpleMessage(
      "Change your character sheets, e.g. hit points",
    ),
    "apiKeyScopeEvents": MessageLookupByLibrary.simpleMessage(
      "Receive live updates",
    ),
    "apiKeyScopeFightsPlay": MessageLookupByLibrary.simpleMessage(
      "Roll initiative when the DM starts a fight",
    ),
    "apiKeyScopeNotesRead": MessageLookupByLibrary.simpleMessage(
      "Read the notes you can see",
    ),
    "apiKeyScopeNotesWrite": MessageLookupByLibrary.simpleMessage(
      "Write your own notes and choose who sees them",
    ),
    "apiKeyUnnamed": MessageLookupByLibrary.simpleMessage("Unnamed key"),
    "apiKeysDocsDescription": MessageLookupByLibrary.simpleMessage(
      "API keys let another app, such as a companion app someone in your group built, act for you as a player. Each key can only do what you allow it.",
    ),
    "apiKeysDocsTitle": MessageLookupByLibrary.simpleMessage(
      "API documentation",
    ),
    "apiKeysEmpty": MessageLookupByLibrary.simpleMessage("No API keys yet."),
    "apiKeysGenerate": MessageLookupByLibrary.simpleMessage(
      "Generate new API key",
    ),
    "apiKeysLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not load your API keys.",
    ),
    "apiKeysTitle": MessageLookupByLibrary.simpleMessage("API Keys"),
    "apiKeysViewDocs": MessageLookupByLibrary.simpleMessage(
      "View API documentation",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("QuestKeeper"),
    "assignCharacterToCampagneModalContent":
        MessageLookupByLibrary.simpleMessage(
          "Your character is not part of a campaign yet. Enter the join code you got from your game master. They will then confirm your request.",
        ),
    "attachImageBtnLabel": MessageLookupByLibrary.simpleMessage("Add image"),
    "authNoConnection": MessageLookupByLibrary.simpleMessage(
      "The server can\'t be reached right now. Please try again in a moment.",
    ),
    "authorLabel": MessageLookupByLibrary.simpleMessage("Author:"),
    "automaticCardStatsHint": MessageLookupByLibrary.simpleMessage(
      "Automatic: the first value with a maximum as bar and the first numbers of the default tab.",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "calculatedValue": MessageLookupByLibrary.simpleMessage("Calculated value"),
    "calculatedValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "The calculated value",
    ),
    "calculatedValueShort": MessageLookupByLibrary.simpleMessage("calc."),
    "campagneSettingsChangedAt": m4,
    "campaignManagement": MessageLookupByLibrary.simpleMessage(
      "Campaign management",
    ),
    "campaignName": MessageLookupByLibrary.simpleMessage("Campaign name"),
    "campaigneName": MessageLookupByLibrary.simpleMessage("Name"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cardBar": MessageLookupByLibrary.simpleMessage("Bar"),
    "cardNumbers": MessageLookupByLibrary.simpleMessage("Numbers"),
    "cardStatsSection": MessageLookupByLibrary.simpleMessage(
      "Properties on the cards",
    ),
    "character": MessageLookupByLibrary.simpleMessage("Character:"),
    "characterConfigSaveFailedBody": MessageLookupByLibrary.simpleMessage(
      "Your character changes could not be saved to the server. Check your connection and try again — nothing was persisted.",
    ),
    "characterConfigSaveFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Character not saved",
    ),
    "characterLastEditedAt": m5,
    "characterName": MessageLookupByLibrary.simpleMessage("Name"),
    "characterNameDefault": MessageLookupByLibrary.simpleMessage("Player name"),
    "characterNameFieldLabel": MessageLookupByLibrary.simpleMessage(
      "Name of your character",
    ),
    "characterNameLabel": MessageLookupByLibrary.simpleMessage("Name:"),
    "characterNameStatHelperText": MessageLookupByLibrary.simpleMessage(
      "What is the name of your character?",
    ),
    "characterNameStatTitle": MessageLookupByLibrary.simpleMessage(
      "Character Name",
    ),
    "characterNameWithLevelAndConfigurableDetails":
        MessageLookupByLibrary.simpleMessage(
          "Character name with level and configurable details",
        ),
    "characterNotInCampagneHint": MessageLookupByLibrary.simpleMessage(
      "Not in a campaign yet. Tap to join with a code.",
    ),
    "characterOverview": MessageLookupByLibrary.simpleMessage(
      "Character overview",
    ),
    "characterPortraitImagePrompt": MessageLookupByLibrary.simpleMessage(
      "Portrait description",
    ),
    "characterPortraitImagePromptPlaceholder":
        MessageLookupByLibrary.simpleMessage(
          "Describe your character for image generation",
        ),
    "characterSheetAppearanceTitle": MessageLookupByLibrary.simpleMessage(
      "Appearance",
    ),
    "characterSheetSkinArcaneLedger": MessageLookupByLibrary.simpleMessage(
      "Arcane Ledger",
    ),
    "characterSheetSkinCampaignDefaultLabel":
        MessageLookupByLibrary.simpleMessage("Campaign default"),
    "characterSheetSkinClassicDark": MessageLookupByLibrary.simpleMessage(
      "Classic Dark",
    ),
    "characterSheetSkinClassicLight": MessageLookupByLibrary.simpleMessage(
      "Classic Light",
    ),
    "characterSheetSkinNightCartographer": MessageLookupByLibrary.simpleMessage(
      "Night Cartographer",
    ),
    "characterSheetSkinUseCampaignDefault":
        MessageLookupByLibrary.simpleMessage("Use campaign default"),
    "chooseACampagne": MessageLookupByLibrary.simpleMessage(
      "Choose a campaign",
    ),
    "chooseACharacter": MessageLookupByLibrary.simpleMessage(
      "Choose a character",
    ),
    "chooseCardStatsYourself": MessageLookupByLibrary.simpleMessage(
      "Choose properties yourself",
    ),
    "closeAction": MessageLookupByLibrary.simpleMessage("Close"),
    "companion": MessageLookupByLibrary.simpleMessage("Companion"),
    "companionOverview": MessageLookupByLibrary.simpleMessage(
      "Companion overview",
    ),
    "companionSelectorIconHeadline": MessageLookupByLibrary.simpleMessage(
      "Icon",
    ),
    "companionSelectorIconHint": MessageLookupByLibrary.simpleMessage(
      "Shown above these companions on the character sheet, e.g. a ship for vehicles.",
    ),
    "completeRegistration": MessageLookupByLibrary.simpleMessage(
      "Complete registration",
    ),
    "computedAlways": MessageLookupByLibrary.simpleMessage("Always"),
    "computedBase": MessageLookupByLibrary.simpleMessage("Start value"),
    "computedCondition": MessageLookupByLibrary.simpleMessage(
      "Counts only if picked",
    ),
    "computedFactor": MessageLookupByLibrary.simpleMessage("Factor"),
    "computedIfPicked": m6,
    "computedMode": MessageLookupByLibrary.simpleMessage("Conversion"),
    "computedModeModifier": MessageLookupByLibrary.simpleMessage(
      "Modifier (x−10)/2",
    ),
    "computedModeValue": MessageLookupByLibrary.simpleMessage("as is"),
    "computedModifierOf": m7,
    "computedPreset": MessageLookupByLibrary.simpleMessage("Template (D&D 5e)"),
    "computedPresetIncomplete": MessageLookupByLibrary.simpleMessage(
      "Not every value of the template exists in this campaign. Add the missing building blocks yourself.",
    ),
    "computedPresetInitiative": MessageLookupByLibrary.simpleMessage(
      "Initiative",
    ),
    "computedPresetPassiveInsight": MessageLookupByLibrary.simpleMessage(
      "Passive Insight",
    ),
    "computedPresetPassiveInvestigation": MessageLookupByLibrary.simpleMessage(
      "Passive Investigation",
    ),
    "computedPresetPassivePerception": MessageLookupByLibrary.simpleMessage(
      "Passive Perception",
    ),
    "computedPresetPassiveStealth": MessageLookupByLibrary.simpleMessage(
      "Passive Stealth",
    ),
    "computedPresetUnarmoredArmorClass": MessageLookupByLibrary.simpleMessage(
      "AC without armor",
    ),
    "computedPreview": MessageLookupByLibrary.simpleMessage("Formula"),
    "computedSource": MessageLookupByLibrary.simpleMessage("Value"),
    "computedTerms": MessageLookupByLibrary.simpleMessage("Building blocks"),
    "computedValue": MessageLookupByLibrary.simpleMessage("Compute the value"),
    "computedValueBadge": MessageLookupByLibrary.simpleMessage("computed"),
    "computedValueHint": MessageLookupByLibrary.simpleMessage(
      "Players don\'t enter this value: it is computed from other properties, e.g. passive Perception = 10 + Mod(Wisdom) + proficiency bonus (if proficient). Modifiers round down.",
    ),
    "computedValueNoSources": MessageLookupByLibrary.simpleMessage(
      "Add properties with numbers first.",
    ),
    "configureProperties": MessageLookupByLibrary.simpleMessage(
      "Configure properties",
    ),
    "configurePropertiesForCharacterNameSuffix": m8,
    "confirmDeleteBtnLabel": MessageLookupByLibrary.simpleMessage("Delete"),
    "connectionLostReconnecting": MessageLookupByLibrary.simpleMessage(
      "Connection lost – reconnecting…",
    ),
    "copiedConfirmation": MessageLookupByLibrary.simpleMessage("Copied"),
    "copyCodeAction": MessageLookupByLibrary.simpleMessage("Copy code"),
    "count": MessageLookupByLibrary.simpleMessage("Count"),
    "craft": MessageLookupByLibrary.simpleMessage("Craft"),
    "craftableAmountText": MessageLookupByLibrary.simpleMessage("Craftable:"),
    "craftableRecipeFilter": MessageLookupByLibrary.simpleMessage("Craftable"),
    "createAction": MessageLookupByLibrary.simpleMessage("Create"),
    "createCampagneAction": MessageLookupByLibrary.simpleMessage(
      "Create campaign",
    ),
    "createNewAccount": MessageLookupByLibrary.simpleMessage(
      "Create new account",
    ),
    "createNewTransformationTitle": MessageLookupByLibrary.simpleMessage(
      "Create new transformation",
    ),
    "createTransformationHelperText": MessageLookupByLibrary.simpleMessage(
      "In order to create a new transformation, you have to select the properties which are modified by this transformation. (If this transformation doesn\'t change this property, you don\'t have to select it.)",
    ),
    "currentBalance": MessageLookupByLibrary.simpleMessage("Current balance"),
    "currentFightOrdering": MessageLookupByLibrary.simpleMessage(
      "Current fight ordering",
    ),
    "currentValue": MessageLookupByLibrary.simpleMessage("Current value"),
    "currentValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "The current value for this property",
    ),
    "customizeCards": MessageLookupByLibrary.simpleMessage("Customize cards"),
    "defaultGroupNameForDocuments": MessageLookupByLibrary.simpleMessage(
      "Other",
    ),
    "defaultTab": MessageLookupByLibrary.simpleMessage("Default tab"),
    "descriptionOfProperty": MessageLookupByLibrary.simpleMessage(
      "Help text for the property",
    ),
    "diceChallengeAbbr": MessageLookupByLibrary.simpleMessage("DC"),
    "diceRoll": MessageLookupByLibrary.simpleMessage("Dice roll"),
    "dm": MessageLookupByLibrary.simpleMessage("DM"),
    "documentDefaultNamePrefix": MessageLookupByLibrary.simpleMessage(
      "Document",
    ),
    "documentGroupLabel": MessageLookupByLibrary.simpleMessage("Grouping"),
    "documentTitleLabel": MessageLookupByLibrary.simpleMessage("Titel"),
    "editPageModalText": MessageLookupByLibrary.simpleMessage(
      "You can edit both the title and the grouping of your document here.",
    ),
    "editPageTitle": MessageLookupByLibrary.simpleMessage("Edit document"),
    "email": MessageLookupByLibrary.simpleMessage("E-Mail"),
    "endFight": MessageLookupByLibrary.simpleMessage("End fight"),
    "endFightConfirmation": MessageLookupByLibrary.simpleMessage(
      "End the fight? Whoever has not rolled yet will not be asked any more.",
    ),
    "enemy": MessageLookupByLibrary.simpleMessage("Enemy"),
    "enemyName": MessageLookupByLibrary.simpleMessage("Enemy name"),
    "enterANameDefaultLabel": MessageLookupByLibrary.simpleMessage(
      "Enter a name",
    ),
    "enterCodeAgainAction": MessageLookupByLibrary.simpleMessage(
      "Enter code again",
    ),
    "enterSomeDescriptionOnTheLeft": MessageLookupByLibrary.simpleMessage(
      "Enter some description on the left",
    ),
    "errorDetailsDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Description:",
    ),
    "errorDetailsServerLabel": MessageLookupByLibrary.simpleMessage(
      "Server response:",
    ),
    "errorDetailsStatusLabel": MessageLookupByLibrary.simpleMessage(
      "HTTP status:",
    ),
    "errorMessageBadRequest": MessageLookupByLibrary.simpleMessage(
      "The server could not process the input. Check your entries and try again.",
    ),
    "errorMessageConflict": MessageLookupByLibrary.simpleMessage(
      "This was just changed somewhere else. Reload and try again.",
    ),
    "errorMessageNoConnection": MessageLookupByLibrary.simpleMessage(
      "Could not reach the server. Check your internet connection and try again.",
    ),
    "errorMessageNotFound": MessageLookupByLibrary.simpleMessage(
      "This item does not exist (anymore).",
    ),
    "errorMessageServer": MessageLookupByLibrary.simpleMessage(
      "Something went wrong on the server. Please try again later.",
    ),
    "errorMessageUnauthorized": MessageLookupByLibrary.simpleMessage(
      "You are not allowed to do this. Sign in again if needed.",
    ),
    "errorMessageUnknown": MessageLookupByLibrary.simpleMessage(
      "Something went wrong. Please try again.",
    ),
    "fightInitiativeStepTitle": MessageLookupByLibrary.simpleMessage(
      "Fight / Initiative",
    ),
    "fightInitiativeStepTutorial": MessageLookupByLibrary.simpleMessage(
      "Mark which stat counts as the initiative bonus.\n\nWhen a player is asked to roll for initiative, they will see a hint with this bonus so they don\'t have to remember it while the roll popup covers their character sheet.\n\nChoose **None** if your system doesn\'t use a bonus. Otherwise pick a stat below. If it is a group of values (e.g. abilities), also pick the entry that applies. If the value has two numbers (e.g. score and modifier, or current and max), pick which one counts as the bonus.",
    ),
    "fightingOrdering": MessageLookupByLibrary.simpleMessage("Fight order"),
    "firstValue": MessageLookupByLibrary.simpleMessage("First value"),
    "firstValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "The first value",
    ),
    "followingItemsArePossibleAtPlaceOfFinding":
        MessageLookupByLibrary.simpleMessage(
          "The following items are possible at the place of finding:",
        ),
    "forCompanionSelector": MessageLookupByLibrary.simpleMessage(
      "for companions",
    ),
    "forIntegerValueWithName": MessageLookupByLibrary.simpleMessage(
      "for number value",
    ),
    "forgotPasswordBackToLogin": MessageLookupByLibrary.simpleMessage(
      "Back to sign in",
    ),
    "forgotPasswordCodeSent": m9,
    "forgotPasswordLink": MessageLookupByLibrary.simpleMessage(
      "Forgot password?",
    ),
    "forgotPasswordRequestButton": MessageLookupByLibrary.simpleMessage(
      "Send code",
    ),
    "forgotPasswordRequestFailed": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t send a code. Check your username and email address. If you sign in with Apple, you don\'t need a password.",
    ),
    "forgotPasswordRequestIntro": MessageLookupByLibrary.simpleMessage(
      "Enter your username and the email address of your account. We\'ll send you a code.",
    ),
    "forgotPasswordRequestNewCode": MessageLookupByLibrary.simpleMessage(
      "Request a new code",
    ),
    "forgotPasswordResetFailed": MessageLookupByLibrary.simpleMessage(
      "That didn\'t work: the code is wrong or has expired. Request a new one if needed.",
    ),
    "forgotPasswordSaveButton": MessageLookupByLibrary.simpleMessage(
      "Save password",
    ),
    "forgotPasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "Your password has been changed. Sign in with your new password now.",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Reset password",
    ),
    "generateImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Generate image",
    ),
    "generateLoreImageTitle": MessageLookupByLibrary.simpleMessage(
      "Generate an image",
    ),
    "generatedImage": MessageLookupByLibrary.simpleMessage("Generated image"),
    "generatedImagesTabTitle": MessageLookupByLibrary.simpleMessage(
      "Generated images",
    ),
    "genericErrorModalHeader": MessageLookupByLibrary.simpleMessage(
      "That didn\'t work",
    ),
    "genericErrorModalTechnicalDetailsErrorCodeRowLabel":
        MessageLookupByLibrary.simpleMessage("Error code:"),
    "genericErrorModalTechnicalDetailsExceptionRowLabel":
        MessageLookupByLibrary.simpleMessage("Error text:"),
    "genericErrorModalTechnicalDetailsHeader":
        MessageLookupByLibrary.simpleMessage("Technical details"),
    "grantItems": MessageLookupByLibrary.simpleMessage("Grant items"),
    "grantItemsFailedForPlayers": m10,
    "helperTextForNameOfCampaign": MessageLookupByLibrary.simpleMessage(
      "The name of the campaign",
    ),
    "hiddenCards": MessageLookupByLibrary.simpleMessage("Hidden"),
    "hideHeading": MessageLookupByLibrary.simpleMessage("Hide heading"),
    "hidePropertyForCharacter": MessageLookupByLibrary.simpleMessage(
      "Hide property for my character",
    ),
    "hourMinutesDayMonthYearFormatString": MessageLookupByLibrary.simpleMessage(
      "%H:%M %m-%d-%Y",
    ),
    "initiativeBonusFieldPickerLabel": MessageLookupByLibrary.simpleMessage(
      "Field",
    ),
    "initiativeBonusHelperSentence": m11,
    "initiativeBonusIncompleteLeave": MessageLookupByLibrary.simpleMessage(
      "Leave anyway",
    ),
    "initiativeBonusIncompleteStay": MessageLookupByLibrary.simpleMessage(
      "Stay",
    ),
    "initiativeBonusIncompleteWarningBody":
        MessageLookupByLibrary.simpleMessage(
          "Your initiative bonus selection is incomplete and will be cleared if you leave.",
        ),
    "initiativeBonusIncompleteWarningTitle":
        MessageLookupByLibrary.simpleMessage("Incomplete selection"),
    "initiativeBonusListEntryPickerLabel": MessageLookupByLibrary.simpleMessage(
      "List entry",
    ),
    "initiativeBonusNoneOption": MessageLookupByLibrary.simpleMessage("None"),
    "initiativeBonusStatPickerLabel": MessageLookupByLibrary.simpleMessage(
      "Stat",
    ),
    "initiativeRollForCharacterPrefix": MessageLookupByLibrary.simpleMessage(
      "Initiative roll",
    ),
    "initiativeRollText": MessageLookupByLibrary.simpleMessage(
      "A fight has started. Please roll for initiative.",
    ),
    "initiativeRollTextFieldLabel": MessageLookupByLibrary.simpleMessage(
      "Initiative roll",
    ),
    "insertParagraphMenuLabel": MessageLookupByLibrary.simpleMessage(
      "Insert paragraph here",
    ),
    "integerValue": MessageLookupByLibrary.simpleMessage("Number value"),
    "integerValueWithCalculatedValue": MessageLookupByLibrary.simpleMessage(
      "Number value with additional number",
    ),
    "integerValueWithMaxValue": MessageLookupByLibrary.simpleMessage(
      "Number value with max value",
    ),
    "invalidImageFileSelected": MessageLookupByLibrary.simpleMessage(
      "The selected file is not an image.",
    ),
    "invitePlayersAction": MessageLookupByLibrary.simpleMessage(
      "Invite players",
    ),
    "invitePlayersApprovalHint": MessageLookupByLibrary.simpleMessage(
      "Requests then show up under “Join requests”. Tap ✓ to let someone in.",
    ),
    "invitePlayersInstruction": MessageLookupByLibrary.simpleMessage(
      "In QuestKeeper, tap “Join a campaign” and enter this code.",
    ),
    "inviteShareSubject": m12,
    "inviteShareText": m13,
    "item": MessageLookupByLibrary.simpleMessage("Item"),
    "itemCardDescRequires": MessageLookupByLibrary.simpleMessage("Requires:"),
    "itemCategoryFilterAll": MessageLookupByLibrary.simpleMessage("All"),
    "itemDetailsDescriptionHeader": MessageLookupByLibrary.simpleMessage(
      "Description:",
    ),
    "itemDetailsForPrefix": MessageLookupByLibrary.simpleMessage(
      "Item details for",
    ),
    "itemDetailsPriceHeader": MessageLookupByLibrary.simpleMessage("Price:"),
    "itemExampleDescription": MessageLookupByLibrary.simpleMessage(
      "Some item description",
    ),
    "itemSortByName": MessageLookupByLibrary.simpleMessage(
      "Sort by name (A–Z)",
    ),
    "itemSortByValueAscending": MessageLookupByLibrary.simpleMessage(
      "Sort by value (low to high)",
    ),
    "itemSortByValueDescending": MessageLookupByLibrary.simpleMessage(
      "Sort by value (high to low)",
    ),
    "itemsToBeFoundInPlaceMarkdown": MessageLookupByLibrary.simpleMessage(
      "## Items to be found in place:",
    ),
    "joinAction": MessageLookupByLibrary.simpleMessage("Join"),
    "joinAsPlayer": MessageLookupByLibrary.simpleMessage("As player"),
    "joinCampagneAction": MessageLookupByLibrary.simpleMessage(
      "Join a campaign",
    ),
    "joinCampagneNewCharacterIntro": MessageLookupByLibrary.simpleMessage(
      "Enter the join code you got from your game master and the name of your character. You fill in the rest of the character sheet once the game master has let you in.",
    ),
    "joinCode": MessageLookupByLibrary.simpleMessage("Join code"),
    "joinCodeEmptyError": MessageLookupByLibrary.simpleMessage(
      "Please enter the join code.",
    ),
    "joinCodeForNewPlayers": m14,
    "joinCodeIncompleteError": MessageLookupByLibrary.simpleMessage(
      "The code has six digits, for example 123-456.",
    ),
    "joinCodeUnknownError": MessageLookupByLibrary.simpleMessage(
      "This code does not exist. Check it with your game master.",
    ),
    "joinRequestAcceptedMessage": MessageLookupByLibrary.simpleMessage(
      "Your join request was accepted. You can play now.",
    ),
    "joinRequestCreatedForDm": m15,
    "joinRequestDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Your join request was declined.",
    ),
    "joinRequestSentConfirmation": MessageLookupByLibrary.simpleMessage(
      "Request sent. As soon as your game master approves, you can play.",
    ),
    "kindOfProperty": MessageLookupByLibrary.simpleMessage("Kind of property"),
    "lastGrantedItems": MessageLookupByLibrary.simpleMessage(
      "Last granted items",
    ),
    "lastGrantedItemsMarkdownPrefix": MessageLookupByLibrary.simpleMessage(
      "Last granted items:",
    ),
    "ledgerManuscriptDateFormat": MessageLookupByLibrary.simpleMessage(
      "MMMM d, y, h:mm a",
    ),
    "level": MessageLookupByLibrary.simpleMessage("Level"),
    "levelAbbr": MessageLookupByLibrary.simpleMessage("LVL"),
    "listOfIntegersWithIcons": MessageLookupByLibrary.simpleMessage(
      "List of number values with icons",
    ),
    "listOfInterValuesWithCalculatedIntegerValues":
        MessageLookupByLibrary.simpleMessage(
          "Group of number values with additional number",
        ),
    "login": MessageLookupByLibrary.simpleMessage("Sign in"),
    "loginIntroJoin": MessageLookupByLibrary.simpleMessage(
      "Sign in or create an account. Then you enter the code from your game master.",
    ),
    "loginIntroLead": MessageLookupByLibrary.simpleMessage(
      "Sign in or create an account. Then you set up your campaign.",
    ),
    "loginMissingInput": MessageLookupByLibrary.simpleMessage(
      "Please enter your username and password.",
    ),
    "loginWrongCredentials": MessageLookupByLibrary.simpleMessage(
      "Username or password is incorrect.",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "lore": MessageLookupByLibrary.simpleMessage("Notes"),
    "maxValue": MessageLookupByLibrary.simpleMessage("Max value"),
    "maxValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "The max value for this property",
    ),
    "maxValueShort": MessageLookupByLibrary.simpleMessage("max."),
    "moreValues": MessageLookupByLibrary.simpleMessage("More values"),
    "multilineText": MessageLookupByLibrary.simpleMessage("Multiline text"),
    "multiselectOption": MessageLookupByLibrary.simpleMessage("Multiselect"),
    "multiselectOptionDescription": MessageLookupByLibrary.simpleMessage(
      "Description:",
    ),
    "multiselectOptionName": MessageLookupByLibrary.simpleMessage("Name:"),
    "multiselectOptionSummary": MessageLookupByLibrary.simpleMessage(
      "Summary:",
    ),
    "multiselectOptionSummaryHelper": MessageLookupByLibrary.simpleMessage(
      "Optional, ~90 characters; shown on the sheet. Full text stays in Description.",
    ),
    "multiselectOptionsAreSelectableMultipleTimes":
        MessageLookupByLibrary.simpleMessage(
          "Multiselect options are selectable multiple times",
        ),
    "myNotesGroupName": MessageLookupByLibrary.simpleMessage("My notes"),
    "nameOfCharacterHelperText": MessageLookupByLibrary.simpleMessage(
      "The name of the character",
    ),
    "nameOfPropertyLabel": MessageLookupByLibrary.simpleMessage(
      "Name of property",
    ),
    "nameRequiredError": MessageLookupByLibrary.simpleMessage(
      "Please enter a name",
    ),
    "navBarHeaderCrafting": MessageLookupByLibrary.simpleMessage("Crafting"),
    "navBarHeaderInventory": MessageLookupByLibrary.simpleMessage("Inventory"),
    "navBarHeaderLore": MessageLookupByLibrary.simpleMessage("Notes"),
    "navBarHeaderMoney": MessageLookupByLibrary.simpleMessage("Currency"),
    "newBalance": MessageLookupByLibrary.simpleMessage("New balance"),
    "newCampagneIntro": MessageLookupByLibrary.simpleMessage(
      "What should your campaign be called? Afterwards the assistant guides you through character sheet, currency and items.",
    ),
    "newCampaign": MessageLookupByLibrary.simpleMessage("New campaign"),
    "newFightOrdering": MessageLookupByLibrary.simpleMessage(
      "New fight ordering",
    ),
    "newGroup": MessageLookupByLibrary.simpleMessage("New grouping:"),
    "newGroupBtnLabel": MessageLookupByLibrary.simpleMessage("New grouping"),
    "newImageBtnLabel": MessageLookupByLibrary.simpleMessage("New image"),
    "newItem": MessageLookupByLibrary.simpleMessage("New"),
    "newItemsMarkdownPlural": MessageLookupByLibrary.simpleMessage(
      "# New items",
    ),
    "newItemsMarkdownSingular": MessageLookupByLibrary.simpleMessage(
      "# New item",
    ),
    "newPasswordLabel": MessageLookupByLibrary.simpleMessage("New password"),
    "newPetBtnLabel": MessageLookupByLibrary.simpleMessage("New pet"),
    "newPropertyBtnLabel": MessageLookupByLibrary.simpleMessage("New property"),
    "newTabBtnLabel": MessageLookupByLibrary.simpleMessage("New tab"),
    "newTransformationSelectionBtn": MessageLookupByLibrary.simpleMessage(
      "New transformation",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noBar": MessageLookupByLibrary.simpleMessage("No bar"),
    "noCampagnesYetHint": MessageLookupByLibrary.simpleMessage(
      "Create a campaign, set up the character sheet and invite your group with a code.",
    ),
    "noCardStatsAvailable": MessageLookupByLibrary.simpleMessage(
      "This campaign has no properties with numbers yet.",
    ),
    "noCharactersInCampagne": MessageLookupByLibrary.simpleMessage(
      "No characters in this campaign yet",
    ),
    "noCharactersYetHint": MessageLookupByLibrary.simpleMessage(
      "Join a campaign with the code from your game master. You create your character along the way.",
    ),
    "noFIghtStarted": MessageLookupByLibrary.simpleMessage(
      "No fight started yet",
    ),
    "noImagesInCampagne": MessageLookupByLibrary.simpleMessage(
      "You did not generate any images in this campaign.",
    ),
    "noItemsGranted": MessageLookupByLibrary.simpleMessage(
      "No items granted yet...",
    ),
    "noItemsGrantedToPlayerThisRound": MessageLookupByLibrary.simpleMessage(
      "No items granted this round",
    ),
    "noItemsInCategory": MessageLookupByLibrary.simpleMessage(
      "No items in this category",
    ),
    "noItemsInCategoryCraftable": MessageLookupByLibrary.simpleMessage(
      "No craftable items in this category",
    ),
    "noItemsInCategoryErrorText": MessageLookupByLibrary.simpleMessage(
      "No items in this category",
    ),
    "noItemsInCategoryNotCraftable": MessageLookupByLibrary.simpleMessage(
      "All items in this category are craftable",
    ),
    "noMoneyDefaultText": MessageLookupByLibrary.simpleMessage("0 Gold"),
    "noOpenJoinRequests": MessageLookupByLibrary.simpleMessage(
      "No open requests",
    ),
    "noPlaceOfFindingSelected": MessageLookupByLibrary.simpleMessage(
      "No place of finding selected.",
    ),
    "noPlayersOnline": MessageLookupByLibrary.simpleMessage(
      "Currently no players are online",
    ),
    "noPlayersYetHint": MessageLookupByLibrary.simpleMessage(
      "No players yet. Invite your group with “Invite players”.",
    ),
    "notAtTheTable": MessageLookupByLibrary.simpleMessage("not at the table"),
    "notCraftableRecipeFilter": MessageLookupByLibrary.simpleMessage(
      "Not craftable",
    ),
    "notEnoughBalance": MessageLookupByLibrary.simpleMessage(
      "Not enough balance for this transaction",
    ),
    "noteblockVisibleFor": MessageLookupByLibrary.simpleMessage("Visible for:"),
    "nothingSelected": MessageLookupByLibrary.simpleMessage(
      "- Nothinge selected -",
    ),
    "offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "online": MessageLookupByLibrary.simpleMessage("Online"),
    "openJoinRequests": MessageLookupByLibrary.simpleMessage("Join requests"),
    "openJoinRequestsBadge": m16,
    "optionalPropertyForAlternateForms": MessageLookupByLibrary.simpleMessage(
      "Optional property for alternate forms",
    ),
    "optionalPropertyForCompanions": MessageLookupByLibrary.simpleMessage(
      "Optional property for companions",
    ),
    "optionsForMultiselect": MessageLookupByLibrary.simpleMessage(
      "Options for multiselect",
    ),
    "otherValue": MessageLookupByLibrary.simpleMessage("Other value"),
    "otherValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "The other value",
    ),
    "ownedIngredientCountPrefix": MessageLookupByLibrary.simpleMessage(
      "owned:",
    ),
    "pageTabShortCampaign": MessageLookupByLibrary.simpleMessage("Campaign"),
    "pageTabShortCharacters": MessageLookupByLibrary.simpleMessage(
      "Characters",
    ),
    "pageTabShortFight": MessageLookupByLibrary.simpleMessage("Combat"),
    "pageTabShortImages": MessageLookupByLibrary.simpleMessage("Images"),
    "pageTabShortItems": MessageLookupByLibrary.simpleMessage("Items"),
    "pageTabShortNotes": MessageLookupByLibrary.simpleMessage("Notes"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordRuleMaxLength": m17,
    "passwordRuleMet": MessageLookupByLibrary.simpleMessage("met"),
    "passwordRuleMinLength": m18,
    "passwordRuleNotMet": MessageLookupByLibrary.simpleMessage("not met yet"),
    "passwordRulesTitle": MessageLookupByLibrary.simpleMessage(
      "Your password needs",
    ),
    "pathJoinAGameSubtitle": MessageLookupByLibrary.simpleMessage(
      "With the code from your game master",
    ),
    "pathJoinAGameTitle": MessageLookupByLibrary.simpleMessage("I join a game"),
    "pathRunAGameSubtitle": MessageLookupByLibrary.simpleMessage(
      "Create a campaign and invite players",
    ),
    "pathRunAGameTitle": MessageLookupByLibrary.simpleMessage("I run a game"),
    "pendingHubSyncBanner": MessageLookupByLibrary.simpleMessage(
      "Some changes are still syncing to the session…",
    ),
    "petDefaultNamePrefix": MessageLookupByLibrary.simpleMessage("Pet"),
    "placeOfFinding": MessageLookupByLibrary.simpleMessage("Place of finding"),
    "player": MessageLookupByLibrary.simpleMessage("Player"),
    "playerRolls": MessageLookupByLibrary.simpleMessage("Player rolls"),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "previewTestHint": MessageLookupByLibrary.simpleMessage(
      "Try the controls — changes here aren\'t saved.",
    ),
    "previewTestReset": MessageLookupByLibrary.simpleMessage("Reset"),
    "previousTransformationSelectionBtn": MessageLookupByLibrary.simpleMessage(
      "Previous transformation",
    ),
    "privacyPolicyLinkLabel": MessageLookupByLibrary.simpleMessage(
      "privacy policy",
    ),
    "propertyEditTypeLabel": MessageLookupByLibrary.simpleMessage(
      "Change frequency",
    ),
    "propertyEditTypeOneTap": MessageLookupByLibrary.simpleMessage(
      "Frequently changed (e.g. every session)",
    ),
    "propertyEditTypeStatic": MessageLookupByLibrary.simpleMessage(
      "Rarely changed (e.g. per level-up)",
    ),
    "propertyIsCopied": MessageLookupByLibrary.simpleMessage(
      "Property is copied",
    ),
    "propertyNameLabel": MessageLookupByLibrary.simpleMessage("Name:"),
    "qrCodeHint": MessageLookupByLibrary.simpleMessage(
      "The QR code only contains the code.",
    ),
    "questKeeperIntro": MessageLookupByLibrary.simpleMessage(
      "QuestKeeper supports your tabletop group at the table. The game master sets up the campaign, everyone else keeps their character sheet in the app. Hit points, items and shared notes stay up to date for everyone, live.",
    ),
    "realtimeSessionIosHint": MessageLookupByLibrary.simpleMessage(
      "On iPad or iPhone, live updates work best while this app is open in the foreground.",
    ),
    "receivedItemsModalHeader": MessageLookupByLibrary.simpleMessage(
      "Received items",
    ),
    "receivedOneNewItemText": MessageLookupByLibrary.simpleMessage(
      "You received one new item:",
    ),
    "receivedXNewItems": m19,
    "recipeForTitlePrefix": MessageLookupByLibrary.simpleMessage("Recipe for"),
    "recipeIngredients": MessageLookupByLibrary.simpleMessage("Ingredients:"),
    "recipeRequirements": MessageLookupByLibrary.simpleMessage(
      "Prerequisites:",
    ),
    "reduceBalance": MessageLookupByLibrary.simpleMessage("Reduce balance"),
    "register": MessageLookupByLibrary.simpleMessage("Register"),
    "registerEmailInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address.",
    ),
    "registerPasswordInvalid": MessageLookupByLibrary.simpleMessage(
      "The password doesn\'t meet all the rules yet.",
    ),
    "registerPrivacyNotice": m20,
    "registerPrivacyNoticeWithoutLink": MessageLookupByLibrary.simpleMessage(
      "We only use your email address for your account, for example to reset your password.",
    ),
    "registerUsernameInvalid": MessageLookupByLibrary.simpleMessage(
      "The username needs 3 to 13 characters, letters and digits only.",
    ),
    "registerUsernameTaken": MessageLookupByLibrary.simpleMessage(
      "This username is already taken. Please pick another one.",
    ),
    "removeImageBtnLabel": MessageLookupByLibrary.simpleMessage("Remove image"),
    "replaceImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Replace image",
    ),
    "requiredIngredientCountPrefix": MessageLookupByLibrary.simpleMessage(
      "Required:",
    ),
    "resetCodeHint": MessageLookupByLibrary.simpleMessage("e.g. 123-456"),
    "resetCodeInvalid": MessageLookupByLibrary.simpleMessage(
      "The code has six digits, e.g. 123-456.",
    ),
    "resetCodeLabel": MessageLookupByLibrary.simpleMessage(
      "Code from the email",
    ),
    "rollForInitiative": MessageLookupByLibrary.simpleMessage(
      "Roll for initiative",
    ),
    "rollForInitiativeBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Roll for initiative",
    ),
    "rollOfInititive": MessageLookupByLibrary.simpleMessage(
      "Roll of initiative",
    ),
    "rpgConfigurationDmWizardStep2Tutorial":
        MessageLookupByLibrary.simpleMessage(
          "Now we come to the character sheets.\n\nEvery role-playing game has different attributes that characterize the players (e.g., how many hit points a player has).\n\nFor each attribute, as the game master, you need to define how the players can interact with this attribute. We need three pieces of information from you for each attribute:\n\n1. Name of the attribute: What should this value be called on the character sheet? (e.g., “HP”, “SP”, “Name”, etc.)\n2. Type of the attribute: Is it, for example, a text that the player can modify (e.g., the backstory of the character) or a numerical value (e.g., the hit points)?\n3. Change type: Some of these attributes are regularly adjusted (e.g., the current hit points), while others are rarely changed (e.g., the maximum hit points). To consider this when creating the character sheets, you need to provide us with this information.\n\nYou arrange attributes in tabs and groups. Press and hold an attribute to move it.",
        ),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "searchLabel": MessageLookupByLibrary.simpleMessage("Search"),
    "secondValue": MessageLookupByLibrary.simpleMessage("Second value"),
    "secondValuePlaceholder": MessageLookupByLibrary.simpleMessage(
      "The second value",
    ),
    "select": MessageLookupByLibrary.simpleMessage("Select"),
    "selectAColor": MessageLookupByLibrary.simpleMessage("Select a color:"),
    "selectAnIcon": MessageLookupByLibrary.simpleMessage("Select an icon:"),
    "selectGameMode": MessageLookupByLibrary.simpleMessage("Select Game Mode"),
    "selectIconModalTitle": MessageLookupByLibrary.simpleMessage("Select icon"),
    "send": MessageLookupByLibrary.simpleMessage("Absenden"),
    "sendItems": MessageLookupByLibrary.simpleMessage("Send items"),
    "sessionExpiredMessage": MessageLookupByLibrary.simpleMessage(
      "Your session has expired. Please sign in again.",
    ),
    "shareInviteAction": MessageLookupByLibrary.simpleMessage(
      "Share invitation",
    ),
    "signInWithApple": MessageLookupByLibrary.simpleMessage(
      "Sign in with Apple",
    ),
    "signInWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Sign in with Google",
    ),
    "singleLineText": MessageLookupByLibrary.simpleMessage("Single line text"),
    "startAsDm": MessageLookupByLibrary.simpleMessage("As game master"),
    "tabIconsConfigurationTitle": MessageLookupByLibrary.simpleMessage(
      "Tab Icons",
    ),
    "tranformToAlternateForm": MessageLookupByLibrary.simpleMessage(
      "Transform",
    ),
    "transformIntoAlternateForm": MessageLookupByLibrary.simpleMessage(
      "Transform into alternate form",
    ),
    "transformationDescription": MessageLookupByLibrary.simpleMessage(
      "Transformation description",
    ),
    "transformationIsEditedWarningTitle": MessageLookupByLibrary.simpleMessage(
      "Transformation is edited",
    ),
    "transformationName": MessageLookupByLibrary.simpleMessage(
      "Transformation name",
    ),
    "uploadImageBtnLabel": MessageLookupByLibrary.simpleMessage("Upload image"),
    "uploadImageMenuLabel": MessageLookupByLibrary.simpleMessage(
      "Upload image",
    ),
    "user": MessageLookupByLibrary.simpleMessage("User:"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "usernameRuleHint": MessageLookupByLibrary.simpleMessage(
      "3 to 13 characters, letters and digits only",
    ),
    "valueOfPropertyWithName": m21,
    "visibleCards": MessageLookupByLibrary.simpleMessage("Visible cards"),
    "visibleCardsHint": MessageLookupByLibrary.simpleMessage(
      "Hidden cards stay hidden on this device, even if a player was offline in between.",
    ),
    "waitingForApprovalText": m22,
    "waitingForApprovalTitle": MessageLookupByLibrary.simpleMessage(
      "Waiting for approval",
    ),
    "waitingForDmApproval": MessageLookupByLibrary.simpleMessage(
      "Waiting for the game master to approve",
    ),
    "waitingForInitiative": MessageLookupByLibrary.simpleMessage(
      "Waiting for initiative",
    ),
    "warning": MessageLookupByLibrary.simpleMessage("Warning"),
    "welcomeDescription": MessageLookupByLibrary.simpleMessage(
      "The game master runs the campaign. Players keep their character sheet, their notes and the live stats on their phone.",
    ),
    "welcomeJoinButton": MessageLookupByLibrary.simpleMessage(
      "I\'m joining a game",
    ),
    "welcomeJoinHint": MessageLookupByLibrary.simpleMessage(
      "After signing in, you enter the code from your game master.",
    ),
    "welcomeLeadButton": MessageLookupByLibrary.simpleMessage("I run a game"),
    "welcomeLeadHint": MessageLookupByLibrary.simpleMessage(
      "You create a campaign and invite your group.",
    ),
    "welcomeTagline": MessageLookupByLibrary.simpleMessage(
      "Your companion for pen & paper sessions at the table.",
    ),
    "welcomeToQuestKeeper": MessageLookupByLibrary.simpleMessage(
      "Welcome to QuestKeeper",
    ),
    "wizardCampaignNameStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Campaign name\n\nWe start with the hardest question of all: what is your campaign called?\n\nThe name needs at least four characters.",
    ),
    "wizardCategoryItemCount": m23,
    "wizardCategoryNameLabel": MessageLookupByLibrary.simpleMessage(
      "Category name:",
    ),
    "wizardCharacterSheetStepTitle": MessageLookupByLibrary.simpleMessage(
      "Character sheet",
    ),
    "wizardCurrencyMultipleLabel": MessageLookupByLibrary.simpleMessage(
      "Worth how many of the previous currency:",
    ),
    "wizardCurrencyStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Currency\n\nSet up which currencies exist in your world and how they convert.\n\nStart with the smallest unit (e.g. copper) and work your way up to the largest. For each further currency, enter how many of the previous one it is worth (in D&D: 10 copper = 1 silver).",
    ),
    "wizardCurrencyStepTitle": MessageLookupByLibrary.simpleMessage("Currency"),
    "wizardDeletePropertyMessage": m24,
    "wizardDeletePropertyTitle": MessageLookupByLibrary.simpleMessage(
      "Delete property?",
    ),
    "wizardDeleteTabMessage": m25,
    "wizardDeleteTabTitle": MessageLookupByLibrary.simpleMessage("Delete tab?"),
    "wizardEditItemTitle": MessageLookupByLibrary.simpleMessage("Edit item"),
    "wizardEditRecipeTitle": MessageLookupByLibrary.simpleMessage(
      "Edit recipe",
    ),
    "wizardFinishBtnLabel": MessageLookupByLibrary.simpleMessage("Done"),
    "wizardGroupLabel": m26,
    "wizardHideExplanation": MessageLookupByLibrary.simpleMessage(
      "Hide explanation",
    ),
    "wizardIconForCategorySuffix": m27,
    "wizardInvalidImageFile": MessageLookupByLibrary.simpleMessage(
      "This file is not a valid image.",
    ),
    "wizardItemCategoriesStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Item categories (optional)\n\nSo players can filter their items, we sort them into categories. We have prepared a set of categories and subcategories for you.\n\nFeel free to adjust them if they do not fit your game.",
    ),
    "wizardItemCategoriesStepTitle": MessageLookupByLibrary.simpleMessage(
      "Item categories",
    ),
    "wizardItemCategoryLabel": MessageLookupByLibrary.simpleMessage("Category"),
    "wizardItemImageDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Image description:",
    ),
    "wizardItemNameLabel": MessageLookupByLibrary.simpleMessage("Item name:"),
    "wizardItemPatchSizeLabel": MessageLookupByLibrary.simpleMessage(
      "Patch size (optional):",
    ),
    "wizardItemPlacesOfFindingHeader": MessageLookupByLibrary.simpleMessage(
      "Places of finding:",
    ),
    "wizardItemsStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Items (optional)\n\nAdd the items of your world here: healing potions, weapons, quest items or ingredients for poisons, anything that can end up in the bags of your players.\n\nYou can also note what a potion does.\n\nTip: put effects, damage and the like at the start of the description. Then your players see the most important facts at a glance.",
    ),
    "wizardItemsStepTitle": MessageLookupByLibrary.simpleMessage("Items"),
    "wizardLocationItemCount": m28,
    "wizardLocationLabel": m29,
    "wizardLocationsStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Places of finding (optional)\n\nFrom here on it is about items and crafting. You only need this and the following steps (places of finding, item categories, items, recipes) if you play with them. **Skip** takes you straight to the summary; data you already entered stays.\n\nSome items can be found in certain places: on the beach, in caves, in grottos and so on. Add those places here so you can link them to items in the next steps.",
    ),
    "wizardLocationsStepTitle": MessageLookupByLibrary.simpleMessage(
      "Places of finding",
    ),
    "wizardNewEntryDefaultName": MessageLookupByLibrary.simpleMessage("New"),
    "wizardNewImageBtnLabel": MessageLookupByLibrary.simpleMessage("New image"),
    "wizardNewLocationBtnLabel": MessageLookupByLibrary.simpleMessage(
      "New place",
    ),
    "wizardNewSubCategoryBtnLabel": MessageLookupByLibrary.simpleMessage(
      "New subcategory",
    ),
    "wizardNextCurrencyLabel": MessageLookupByLibrary.simpleMessage(
      "Name of the next larger currency:",
    ),
    "wizardOptionalStepLabel": MessageLookupByLibrary.simpleMessage(
      "Optional step",
    ),
    "wizardPickImageBtnLabel": MessageLookupByLibrary.simpleMessage(
      "Choose image",
    ),
    "wizardPropertyDeletedSnackbar": m30,
    "wizardRecipeAddIngredient": MessageLookupByLibrary.simpleMessage(
      "Add ingredient",
    ),
    "wizardRecipeAddRequirement": MessageLookupByLibrary.simpleMessage(
      "Add prerequisite",
    ),
    "wizardRecipeCreatedItemLabel": MessageLookupByLibrary.simpleMessage(
      "Item to craft",
    ),
    "wizardRecipeDeletePermanently": MessageLookupByLibrary.simpleMessage(
      "Delete permanently",
    ),
    "wizardRecipeDuplicateAndOpen": MessageLookupByLibrary.simpleMessage(
      "Duplicate and open",
    ),
    "wizardRecipeIngredientLabel": m31,
    "wizardRecipeOpenDetails": MessageLookupByLibrary.simpleMessage(
      "Open details",
    ),
    "wizardRecipeRequirementLabel": m32,
    "wizardRecipesStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Recipes (optional)\n\nRecipes let your players craft things themselves, for example healing potions.\n\nSome recipes require a tool, such as a herbalism kit. You can note that in the recipe too; players then need the tool to use the recipe.\n\nTap a recipe to edit it. Press and hold it for more actions.",
    ),
    "wizardRecipesStepTitle": MessageLookupByLibrary.simpleMessage("Recipes"),
    "wizardSavedSnackbar": MessageLookupByLibrary.simpleMessage("Setup saved"),
    "wizardShowExplanation": MessageLookupByLibrary.simpleMessage(
      "Show explanation",
    ),
    "wizardSkinStepHelper": MessageLookupByLibrary.simpleMessage(
      "## Welcome to QuestKeeper!\n\nIn the next steps you set up your campaign: appearance, name, character sheet, initiative and currency. Optional steps for items and crafting follow, which you can skip.\n\nEverything is saved automatically. Close the wizard at any time with the X in the top left; the gear icon in the top right brings you back here later.\n\n## Appearance\n\nPick the default look for character sheets in this campaign. Players can change it later for their own characters.",
    ),
    "wizardSkipBtnLabel": MessageLookupByLibrary.simpleMessage("Skip"),
    "wizardSmallestCurrencyLabel": MessageLookupByLibrary.simpleMessage(
      "Name of the smallest currency:",
    ),
    "wizardSubCategoryNameLabel": MessageLookupByLibrary.simpleMessage(
      "Subcategory name:",
    ),
    "wizardSummaryCampaignLabel": MessageLookupByLibrary.simpleMessage(
      "Campaign",
    ),
    "wizardSummaryItemCount": m33,
    "wizardSummaryNotSet": MessageLookupByLibrary.simpleMessage("Not set yet"),
    "wizardSummaryPropertyCount": m34,
    "wizardSummaryRecipeCount": m35,
    "wizardSummaryStepHelper": MessageLookupByLibrary.simpleMessage(
      "## All set!\n\nYour campaign is set up and everything is saved. The overview shows what is set up.\n\nYou can change everything later via the gear icon in the top right.\n\n**Done** closes the wizard.",
    ),
    "wizardSummaryStepTitle": MessageLookupByLibrary.simpleMessage("Summary"),
    "wizardSummaryTabCount": m36,
    "wizardTabNameLabel": MessageLookupByLibrary.simpleMessage("Tab name"),
    "wizardUndo": MessageLookupByLibrary.simpleMessage("Undo"),
    "wizardUnnamedProperty": MessageLookupByLibrary.simpleMessage(
      "Unnamed property",
    ),
    "wizardUnnamedTab": MessageLookupByLibrary.simpleMessage("Unnamed tab"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "you": MessageLookupByLibrary.simpleMessage("You"),
    "youAreEditingACopiedPropertyChangesWillNotAffect":
        MessageLookupByLibrary.simpleMessage(
          "You are editing a copied property. Changes will not affect the original property.",
        ),
    "youAreEditingAnAlternateFormWarningText":
        MessageLookupByLibrary.simpleMessage(
          "You are editing an alternate form of the character. Changes made here will not affect the main character. If you want to change the main character, go back to the main character screen. Any changes made here will be saved to the alternate form, which will be reset after reverting your transformation.",
        ),
    "youOwnXCampaigns": m37,
    "youOwnXCharacters": m38,
    "yourAreDisconnectedBody": MessageLookupByLibrary.simpleMessage(
      "Your are disconnected... Either you or the DM has lost the connection.",
    ),
  };
}
