// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get characterNameDefault => 'Player name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get firstValue => 'First value';

  @override
  String get firstValuePlaceholder => 'The first value';

  @override
  String get currentValue => 'Current value';

  @override
  String get currentValuePlaceholder => 'The current value for this property';

  @override
  String get maxValue => 'Max value';

  @override
  String get maxValuePlaceholder => 'The max value for this property';

  @override
  String get secondValue => 'Second value';

  @override
  String get secondValuePlaceholder => 'The second value';

  @override
  String get otherValue => 'Other value';

  @override
  String get otherValuePlaceholder => 'The other value';

  @override
  String get calculatedValue => 'Calculated value';

  @override
  String get calculatedValuePlaceholder => 'The calculated value';

  @override
  String get configureProperties => 'Configure properties';

  @override
  String configurePropertiesForCharacterNameSuffix(String username) {
    return ' (for $username)';
  }

  @override
  String valueOfPropertyWithName(String property) {
    return 'The value of $property';
  }

  @override
  String get newPetBtnLabel => 'New pet';

  @override
  String get petDefaultNamePrefix => 'Pet';

  @override
  String get preview => 'Preview';

  @override
  String get previewTestHint =>
      'Try the controls — changes here aren\'t saved.';

  @override
  String get previewTestReset => 'Reset';

  @override
  String get newImageBtnLabel => 'New image';

  @override
  String get uploadImageBtnLabel => 'Upload image';

  @override
  String get invalidImageFileSelected => 'The selected file is not an image.';

  @override
  String get additionalSettings => 'Additional settings';

  @override
  String get hidePropertyForCharacter => 'Hide property for my character';

  @override
  String get hideHeading => 'Hide heading';

  @override
  String get addCharacterToCampagneModalTitle => 'Join a campaign';

  @override
  String get assignCharacterToCampagneModalContent =>
      'Your character is not part of a campaign yet. Enter the join code you got from your game master. They will then confirm your request.';

  @override
  String get joinCode => 'Join code';

  @override
  String get genericErrorModalHeader => 'That didn\'t work';

  @override
  String get genericErrorModalTechnicalDetailsHeader => 'Technical details';

  @override
  String get genericErrorModalTechnicalDetailsErrorCodeRowLabel =>
      'Error code:';

  @override
  String get genericErrorModalTechnicalDetailsExceptionRowLabel =>
      'Error text:';

  @override
  String get nameOfPropertyLabel => 'Name of property';

  @override
  String get descriptionOfProperty => 'Help text for the property';

  @override
  String get propertyEditTypeOneTap =>
      'Frequently changed (e.g. every session)';

  @override
  String get propertyEditTypeStatic => 'Rarely changed (e.g. per level-up)';

  @override
  String get propertyEditTypeLabel => 'Change frequency';

  @override
  String get generatedImage => 'Generated image';

  @override
  String get multilineText => 'Multiline text';

  @override
  String get singleLineText => 'Single line text';

  @override
  String get integerValue => 'Number value';

  @override
  String get listOfIntegersWithIcons => 'List of number values with icons';

  @override
  String get integerValueWithMaxValue => 'Number value with max value';

  @override
  String get listOfInterValuesWithCalculatedIntegerValues =>
      'Group of number values with additional number';

  @override
  String get integerValueWithCalculatedValue =>
      'Number value with additional number';

  @override
  String get characterNameWithLevelAndConfigurableDetails =>
      'Character name with level and configurable details';

  @override
  String get multiselectOption => 'Multiselect';

  @override
  String get companionOverview => 'Companion overview';

  @override
  String get companionSelectorIconHeadline => 'Icon';

  @override
  String get companionSelectorIconHint =>
      'Shown above these companions on the character sheet, e.g. a ship for vehicles.';

  @override
  String get forCompanionSelector => 'for companions';

  @override
  String get kindOfProperty => 'Kind of property';

  @override
  String get multiselectOptionsAreSelectableMultipleTimes =>
      'Multiselect options are selectable multiple times';

  @override
  String get optionalPropertyForCompanions =>
      'Optional property for companions';

  @override
  String get optionalPropertyForAlternateForms =>
      'Optional property for alternate forms';

  @override
  String get optionsForMultiselect => 'Options for multiselect';

  @override
  String get multiselectOptionName => 'Name:';

  @override
  String get multiselectOptionDescription => 'Description:';

  @override
  String get multiselectOptionSummary => 'Summary:';

  @override
  String get multiselectOptionSummaryHelper =>
      'Optional, ~90 characters; shown on the sheet. Full text stays in Description.';

  @override
  String get additionalElement => 'Add element';

  @override
  String get moreValues => 'More values';

  @override
  String get forIntegerValueWithName => 'for number value';

  @override
  String get propertyNameLabel => 'Name:';

  @override
  String get completeRegistration => 'Complete registration';

  @override
  String get selectIconModalTitle => 'Select icon';

  @override
  String get selectAColor => 'Select a color:';

  @override
  String get selectAnIcon => 'Select an icon:';

  @override
  String get item => 'Item';

  @override
  String get itemExampleDescription => 'Some item description';

  @override
  String get select => 'Select';

  @override
  String get campaignManagement => 'Campaign management';

  @override
  String get characterOverview => 'Character overview';

  @override
  String get fightingOrdering => 'Fight order';

  @override
  String get grantItems => 'Grant items';

  @override
  String get lore => 'Notes';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get allPlayers => 'All players:';

  @override
  String get openJoinRequests => 'Join requests';

  @override
  String joinCodeForNewPlayers(String code) {
    return 'Join code: $code';
  }

  @override
  String get noOpenJoinRequests => 'No open requests';

  @override
  String get user => 'User:';

  @override
  String get character => 'Character:';

  @override
  String get lastGrantedItems => 'Last granted items';

  @override
  String get noItemsGranted => 'No items granted yet...';

  @override
  String get placeOfFinding => 'Place of finding';

  @override
  String get playerRolls => 'Player rolls';

  @override
  String get diceRoll => 'Dice roll';

  @override
  String get player => 'Player';

  @override
  String get sendItems => 'Send items';

  @override
  String get itemsToBeFoundInPlaceMarkdown => '## Items at this place';

  @override
  String get noPlaceOfFindingSelected => 'No place of finding selected.';

  @override
  String get followingItemsArePossibleAtPlaceOfFinding =>
      'These items can be found here:';

  @override
  String get diceChallengeAbbr => 'DC';

  @override
  String get lastGrantedItemsMarkdownPrefix => 'Last granted items:';

  @override
  String get noItemsGrantedToPlayerThisRound => 'No items granted this round';

  @override
  String grantItemsFailedForPlayers(String characterNames) {
    return 'Could not grant the items to $characterNames. Please try again.';
  }

  @override
  String get login => 'Sign in';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get createNewAccount => 'Create new account';

  @override
  String get email => 'Email';

  @override
  String get register => 'Register';

  @override
  String get itemDetailsForPrefix => 'Item details for';

  @override
  String get itemDetailsDescriptionHeader => 'Description:';

  @override
  String get itemDetailsPriceHeader => 'Price:';

  @override
  String get amount => 'Amount';

  @override
  String get receivedItemsModalHeader => 'Received items';

  @override
  String get newItemsMarkdownPlural => '# New items';

  @override
  String get newItemsMarkdownSingular => '# New item';

  @override
  String get receivedOneNewItemText => 'You received one new item:';

  @override
  String receivedXNewItems(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'You received $amount new items:',
      one: 'You received one new item:',
    );
    return '$_temp0';
  }

  @override
  String get ok => 'OK';

  @override
  String get rpgConfigurationDmWizardStep2Tutorial =>
      'Now we come to the character sheets.\n\nEvery role-playing game has different attributes that characterize the players (e.g., how many hit points a player has).\n\nFor each attribute, as the game master, you need to define how the players can interact with this attribute. We need three pieces of information from you for each attribute:\n\n1. Name of the attribute: What should this value be called on the character sheet? (e.g., “HP”, “SP”, “Name”, etc.)\n2. Type of the attribute: Is it, for example, a text that the player can modify (e.g., the backstory of the character) or a numerical value (e.g., the hit points)?\n3. Change type: Some of these attributes are regularly adjusted (e.g., the current hit points), while others are rarely changed (e.g., the maximum hit points). To consider this when creating the character sheets, you need to provide us with this information.\n\nYou arrange attributes in tabs and groups. Press and hold an attribute to move it.';

  @override
  String get levelAbbr => 'LVL';

  @override
  String get addAdditionalEnemy => 'Add additional enemy';

  @override
  String get enemyName => 'Enemy name';

  @override
  String get rollOfInititive => 'Initiative roll';

  @override
  String get addAnAdditionalEnemyBtnLabel => 'Add more';

  @override
  String get enemy => 'Enemy';

  @override
  String get add => 'Add';

  @override
  String get initiativeRollForCharacterPrefix => 'Initiative roll';

  @override
  String get initiativeRollText => 'A fight is starting. Roll for initiative!';

  @override
  String get initiativeRollTextFieldLabel => 'Your roll';

  @override
  String initiativeBonusHelperSentence(Object formattedBonus, Object label) {
    return 'Add $label $formattedBonus to your roll';
  }

  @override
  String get fightInitiativeStepTitle => 'Fight / Initiative';

  @override
  String get fightInitiativeStepTutorial =>
      'Mark which stat counts as the initiative bonus.\n\nWhen a player is asked to roll for initiative, they will see a hint with this bonus so they don\'t have to remember it while the roll popup covers their character sheet.\n\nChoose **None** if your system doesn\'t use a bonus. Otherwise pick a stat below. If it is a group of values (e.g. abilities), also pick the entry that applies. If the value has two numbers (e.g. score and modifier, or current and max), pick which one counts as the bonus.';

  @override
  String get initiativeBonusNoneOption => 'None';

  @override
  String get initiativeBonusStatPickerLabel => 'Stat';

  @override
  String get initiativeBonusListEntryPickerLabel => 'List entry';

  @override
  String get initiativeBonusFieldPickerLabel => 'Field';

  @override
  String get initiativeBonusIncompleteWarningTitle => 'Incomplete selection';

  @override
  String get initiativeBonusIncompleteWarningBody =>
      'Your initiative bonus selection is incomplete and will be cleared if you leave.';

  @override
  String get initiativeBonusIncompleteStay => 'Stay';

  @override
  String get initiativeBonusIncompleteLeave => 'Leave anyway';

  @override
  String get send => 'Send';

  @override
  String get editPageTitle => 'Edit document';

  @override
  String get editPageModalText =>
      'You can edit both the title and the grouping of your document here.';

  @override
  String get documentTitleLabel => 'Title';

  @override
  String get documentGroupLabel => 'Grouping';

  @override
  String get recipeForTitlePrefix => 'Recipe for';

  @override
  String get recipeRequirements => 'Prerequisites:';

  @override
  String get recipeIngredients => 'Ingredients:';

  @override
  String get requiredIngredientCountPrefix => 'Required:';

  @override
  String get ownedIngredientCountPrefix => 'owned:';

  @override
  String get amountToCraftFieldLabel => 'Amount';

  @override
  String get craft => 'Craft';

  @override
  String get newItem => 'New';

  @override
  String get defaultGroupNameForDocuments => 'Other';

  @override
  String get documentDefaultNamePrefix => 'Document';

  @override
  String get authorLabel => 'Author:';

  @override
  String get you => 'You';

  @override
  String get dm => 'Game master';

  @override
  String get hourMinutesDayMonthYearFormatString => '%H:%M %m-%d-%Y';

  @override
  String get addParagraphBtnLabel => 'Paragraph';

  @override
  String get addImageBtnLabel => 'Image';

  @override
  String get newGroup => 'New grouping:';

  @override
  String get newGroupBtnLabel => 'New grouping';

  @override
  String get newPropertyBtnLabel => 'New property';

  @override
  String get newTabBtnLabel => 'New tab';

  @override
  String get itemCardDescRequires => 'Requires:';

  @override
  String get defaultTab => 'Default tab';

  @override
  String get amountHeaderLabel => 'Amount:';

  @override
  String get noItemsInCategoryErrorText => 'No items in this category';

  @override
  String get searchLabel => 'Search';

  @override
  String get itemSortByName => 'Sort by name (A–Z)';

  @override
  String get itemSortByValueAscending => 'Sort by value (low to high)';

  @override
  String get itemSortByValueDescending => 'Sort by value (high to low)';

  @override
  String get itemCategoryFilterAll => 'All';

  @override
  String get craftableRecipeFilter => 'Craftable';

  @override
  String get notCraftableRecipeFilter => 'Not craftable';

  @override
  String get noItemsInCategoryCraftable =>
      'No craftable items in this category';

  @override
  String get noItemsInCategoryNotCraftable =>
      'All items in this category are craftable';

  @override
  String get noItemsInCategory => 'No items in this category';

  @override
  String get craftableAmountText => 'Craftable:';

  @override
  String get navBarHeaderCrafting => 'Crafting';

  @override
  String get navBarHeaderLore => 'Notes';

  @override
  String get navBarHeaderInventory => 'Inventory';

  @override
  String get navBarHeaderMoney => 'Currency';

  @override
  String get noMoneyDefaultText => '0 Gold';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get addBalance => 'Add balance';

  @override
  String get reduceBalance => 'Reduce balance';

  @override
  String get newBalance => 'New balance';

  @override
  String get notEnoughBalance => 'Not enough balance for this transaction';

  @override
  String get noteblockVisibleFor => 'Visible for:';

  @override
  String get nothingSelected => '- Nothing selected -';

  @override
  String get characterNameLabel => 'Name:';

  @override
  String get level => 'Level';

  @override
  String get count => 'Count';

  @override
  String get addItems => 'Add items';

  @override
  String get selectGameMode => 'Choose your role';

  @override
  String get chooseACampagne => 'Choose a campaign';

  @override
  String get startAsDm => 'As game master';

  @override
  String youOwnXCampaigns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You run $count campaigns.',
      one: 'You run 1 campaign.',
      zero: 'You don\'t run a campaign yet.',
    );
    return '$_temp0';
  }

  @override
  String get joinAsPlayer => 'As player';

  @override
  String get chooseACharacter => 'Choose a character';

  @override
  String youOwnXCharacters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count characters.',
      one: 'You have 1 character.',
      zero: 'You don\'t have a character yet.',
    );
    return '$_temp0';
  }

  @override
  String get campaigneName => 'Name';

  @override
  String get helperTextForNameOfCampaign => 'The name of the campaign';

  @override
  String get newCampaign => 'New campaign';

  @override
  String get noPlayersOnline => 'Currently no players are online';

  @override
  String get currentFightOrdering => 'Current fight ordering';

  @override
  String get noFIghtStarted => 'No fight is running';

  @override
  String get newFightOrdering => 'New fight ordering';

  @override
  String get additionalFightParticipants => 'Additional fight participants';

  @override
  String get rollForInitiativeBtnLabel => 'Roll for initiative';

  @override
  String get rollForInitiative => 'Roll for initiative';

  @override
  String get characterName => 'Name';

  @override
  String get nameOfCharacterHelperText => 'The name of the character';

  @override
  String get campaignName => 'Campaign name';

  @override
  String get tranformToAlternateForm => 'Transform';

  @override
  String get transformIntoAlternateForm => 'Transform into alternate form';

  @override
  String get addNewTransformationComponent => 'Add transformation';

  @override
  String get createNewTransformationTitle => 'Create new transformation';

  @override
  String get transformationName => 'Transformation name';

  @override
  String get transformationDescription => 'Transformation description';

  @override
  String get createTransformationHelperText =>
      'Choose the properties this transformation changes. All others stay as they are.';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get warning => 'Warning';

  @override
  String get youAreEditingAnAlternateFormWarningText =>
      'You are editing a transformation. Changes only apply to this transformation and are lost when you change back. For lasting changes, change back and edit your base form.';

  @override
  String get transformationIsEditedWarningTitle => 'Transformation is edited';

  @override
  String get propertyIsCopied => 'Property is copied';

  @override
  String get youAreEditingACopiedPropertyChangesWillNotAffect =>
      'You are editing a copied property. Changes will not affect the original property.';

  @override
  String get previousTransformationSelectionBtn => 'Previous transformation';

  @override
  String get newTransformationSelectionBtn => 'New transformation';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get yourAreDisconnectedBody =>
      'You are disconnected. Either you or your game master is offline.';

  @override
  String get characterNameStatTitle => 'Character name';

  @override
  String get characterNameStatHelperText =>
      'What is the name of your character?';

  @override
  String get generateImageBtnLabel => 'Generate image';

  @override
  String get generateLoreImageTitle => 'Generate an image';

  @override
  String get characterPortraitImagePrompt => 'Portrait description';

  @override
  String get characterPortraitImagePromptPlaceholder =>
      'Describe your character for image generation';

  @override
  String get generatedImagesTabTitle => 'Generated images';

  @override
  String get noImagesInCampagne =>
      'You haven\'t generated any images in this campaign yet.';

  @override
  String get enterANameDefaultLabel => 'Enter a name';

  @override
  String get enterSomeDescriptionOnTheLeft =>
      'Enter a description on the left.';

  @override
  String get tabIconsConfigurationTitle => 'Tab icons';

  @override
  String get realtimeSessionIosHint =>
      'On iPad or iPhone, live updates work best while this app is open in the foreground.';

  @override
  String get pendingHubSyncBanner =>
      'Some changes are still syncing to the session…';

  @override
  String get characterConfigSaveFailedTitle => 'Character not saved';

  @override
  String get characterConfigSaveFailedBody =>
      'Your character changes could not be saved. Check your connection and try again.';

  @override
  String get logout => 'Sign out';

  @override
  String get sessionExpiredMessage =>
      'Your session has expired. Please sign in again.';

  @override
  String get characterSheetSkinClassicLight => 'Classic Light';

  @override
  String get characterSheetSkinClassicDark => 'Classic Dark';

  @override
  String get characterSheetSkinArcaneLedger => 'Arcane Ledger';

  @override
  String get characterSheetSkinNightCartographer => 'Night Cartographer';

  @override
  String get characterSheetSkinUseCampaignDefault => 'Use campaign default';

  @override
  String get characterSheetSkinCampaignDefaultLabel => 'Campaign default';

  @override
  String get characterSheetAppearanceTitle => 'Appearance';

  @override
  String get apiKeysTitle => 'API Keys';

  @override
  String get apiKeysDocsTitle => 'API documentation';

  @override
  String get apiKeysDocsDescription =>
      'API keys let another app, such as a companion app someone in your group built, act for you as a player. Each key can only do what you allow it.';

  @override
  String get apiKeysViewDocs => 'View API documentation';

  @override
  String get apiKeysGenerate => 'Generate new API key';

  @override
  String get apiKeysEmpty => 'No API keys yet.';

  @override
  String get apiKeysLoadFailed => 'Could not load your API keys.';

  @override
  String get apiKeyUnnamed => 'Unnamed key';

  @override
  String get apiKeyRevoked => 'Revoked';

  @override
  String get apiKeyExpired => 'Expired';

  @override
  String apiKeyPrefix(String prefix) {
    return 'Prefix: $prefix';
  }

  @override
  String apiKeyRevokedAt(String date) {
    return 'Revoked: $date';
  }

  @override
  String apiKeyLastUsedAt(String date) {
    return 'Last used: $date';
  }

  @override
  String get apiKeyNeverUsed => 'Never used';

  @override
  String apiKeyExpiresAt(String date) {
    return 'Expires: $date';
  }

  @override
  String get apiKeyNeverExpires => 'Never expires';

  @override
  String get apiKeyRevokeTitle => 'Revoke API key?';

  @override
  String get apiKeyRevokeBody =>
      'This cannot be undone. Any app using this key loses access immediately.';

  @override
  String get apiKeyRevokeConfirm => 'Revoke';

  @override
  String get apiKeyRevokeFailed => 'Could not revoke the API key.';

  @override
  String get apiKeyCreateTitle => 'New API key';

  @override
  String get apiKeyCreateHint =>
      'Only give a key to apps you trust. They act as you.';

  @override
  String get apiKeyNameLabel => 'Name, e.g. the app that uses it';

  @override
  String get apiKeyPermissionsLabel => 'Permissions';

  @override
  String get apiKeyPresetReadOnly => 'Read only';

  @override
  String get apiKeyPresetCompanion => 'Player companion app';

  @override
  String get apiKeyPresetCustom => 'Custom';

  @override
  String get apiKeyScopeCampaignsRead =>
      'See your campaigns and fellow players';

  @override
  String get apiKeyScopeCharactersRead => 'Read your character sheets';

  @override
  String get apiKeyScopeCharactersWrite =>
      'Change your character sheets, e.g. hit points';

  @override
  String get apiKeyScopeNotesRead => 'Read the notes you can see';

  @override
  String get apiKeyScopeNotesWrite =>
      'Write your own notes and choose who sees them';

  @override
  String get apiKeyScopeFightsPlay =>
      'Roll initiative when the game master starts a fight';

  @override
  String get apiKeyScopeEvents => 'Receive live updates';

  @override
  String get apiKeyExpiryLabel => 'Valid for';

  @override
  String get apiKeyPermissionsNeedServerUpdate =>
      'This server gives every key read access to your campaigns, characters and notes. You can choose permissions and a lifetime once the server is updated.';

  @override
  String get apiKeyExpiryNever => 'Unlimited';

  @override
  String get apiKeyExpiry30Days => '30 days';

  @override
  String get apiKeyExpiry90Days => '90 days';

  @override
  String get apiKeyExpiry1Year => '1 year';

  @override
  String get apiKeyCreateConfirm => 'Generate';

  @override
  String get apiKeyNameRequired => 'Enter a name.';

  @override
  String get apiKeyNoScopeSelected => 'Choose at least one permission.';

  @override
  String get apiKeyCreateFailed => 'Could not create the API key.';

  @override
  String get apiKeyCreatedTitle => 'API key created';

  @override
  String get apiKeyCreatedBody =>
      'Copy your new key now. You won\'t see it again.';

  @override
  String get apiKeyCopy => 'Copy';

  @override
  String get apiKeyCopied => 'Copied to clipboard';

  @override
  String get apiKeyDone => 'Done';

  @override
  String get endFight => 'End fight';

  @override
  String get endFightConfirmation =>
      'End the fight? Whoever has not rolled yet will not be asked any more.';

  @override
  String get waitingForInitiative => 'Waiting for initiative';

  @override
  String get notAtTheTable => 'not at the table';

  @override
  String get noCharactersInCampagne => 'No characters in this campaign yet';

  @override
  String get customizeCards => 'Customize cards';

  @override
  String get hiddenCards => 'Hidden';

  @override
  String get allCardsHidden => 'All cards are hidden';

  @override
  String get visibleCards => 'Visible cards';

  @override
  String get visibleCardsHint =>
      'Hidden cards stay hidden on this device, even if a player was offline in between.';

  @override
  String get cardStatsSection => 'Properties on the cards';

  @override
  String get chooseCardStatsYourself => 'Choose properties yourself';

  @override
  String get automaticCardStatsHint =>
      'Automatic: the first value with a maximum as bar and the first numbers of the default tab.';

  @override
  String get cardBar => 'Bar';

  @override
  String get noBar => 'No bar';

  @override
  String get cardNumbers => 'Numbers';

  @override
  String get companion => 'Companion';

  @override
  String get calculatedValueShort => 'calc.';

  @override
  String get noCardStatsAvailable =>
      'This campaign has no properties with numbers yet.';

  @override
  String get maxValueShort => 'max.';

  @override
  String get computedValue => 'Compute the value';

  @override
  String get computedValueHint =>
      'Players don\'t enter this value: it is computed from other properties, e.g. passive Perception = 10 + Mod(Wisdom) + proficiency bonus (if proficient). Modifiers round down.';

  @override
  String get computedBase => 'Start value';

  @override
  String get computedTerms => 'Building blocks';

  @override
  String get addComputedTerm => 'Add building block';

  @override
  String get computedSource => 'Value';

  @override
  String get computedMode => 'Conversion';

  @override
  String get computedModeValue => 'as is';

  @override
  String get computedModeModifier => 'Modifier (x−10)/2';

  @override
  String get computedFactor => 'Factor';

  @override
  String get computedCondition => 'Counts only if picked';

  @override
  String get computedAlways => 'Always';

  @override
  String get computedPreview => 'Formula';

  @override
  String get computedValueNoSources => 'Add properties with numbers first.';

  @override
  String computedModifierOf(String label) {
    return 'Mod($label)';
  }

  @override
  String computedIfPicked(String condition) {
    return '(if $condition)';
  }

  @override
  String get computedValueBadge => 'computed';

  @override
  String get computedPreset => 'Template (Fantasy 5E)';

  @override
  String get computedPresetPassivePerception => 'Passive Perception';

  @override
  String get computedPresetPassiveInsight => 'Passive Insight';

  @override
  String get computedPresetPassiveInvestigation => 'Passive Investigation';

  @override
  String get computedPresetPassiveStealth => 'Passive Stealth';

  @override
  String get computedPresetInitiative => 'Initiative';

  @override
  String get computedPresetUnarmoredArmorClass => 'AC without armor';

  @override
  String get computedPresetIncomplete =>
      'Not every value of the template exists in this campaign. Add the missing building blocks yourself.';

  @override
  String get attachImageBtnLabel => 'Add image';

  @override
  String get replaceImageBtnLabel => 'Replace image';

  @override
  String get removeImageBtnLabel => 'Remove image';

  @override
  String get uploadImageMenuLabel => 'Upload image';

  @override
  String get insertParagraphMenuLabel => 'Insert paragraph here';

  @override
  String get connectionLostReconnecting => 'Connection lost – reconnecting…';

  @override
  String get appName => 'QuestKeeper';

  @override
  String get welcomeTagline =>
      'Your companion for pen & paper sessions at the table.';

  @override
  String get welcomeDescription =>
      'The game master runs the campaign. Players keep their character sheet, their notes and the live stats on their phone.';

  @override
  String get welcomeLeadButton => 'I run a game';

  @override
  String get welcomeLeadHint => 'You create a campaign and invite your group.';

  @override
  String get welcomeJoinButton => 'I\'m joining a game';

  @override
  String get welcomeJoinHint =>
      'After signing in, you enter the code from your game master.';

  @override
  String get loginIntroLead =>
      'Sign in or create an account. Then you set up your campaign.';

  @override
  String get loginIntroJoin =>
      'Sign in or create an account. Then you enter the code from your game master.';

  @override
  String get loginMissingInput => 'Please enter your username and password.';

  @override
  String get loginWrongCredentials => 'Username or password is incorrect.';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get usernameRuleHint => '3 to 13 characters, letters and digits only';

  @override
  String get passwordRulesTitle => 'Your password needs';

  @override
  String passwordRuleMinLength(int count) {
    return 'at least $count characters';
  }

  @override
  String passwordRuleMaxLength(int count) {
    return 'at most $count characters';
  }

  @override
  String get passwordRuleMet => 'met';

  @override
  String get passwordRuleNotMet => 'not met yet';

  @override
  String get registerUsernameInvalid =>
      'The username needs 3 to 13 characters, letters and digits only.';

  @override
  String get registerEmailInvalid => 'Please enter a valid email address.';

  @override
  String get registerPasswordInvalid =>
      'The password doesn\'t meet all the rules yet.';

  @override
  String get registerUsernameTaken =>
      'This username is already taken. Please pick another one.';

  @override
  String registerPrivacyNotice(String privacyPolicyLink) {
    return 'You can read how we handle your data in our $privacyPolicyLink.';
  }

  @override
  String get privacyPolicyLinkLabel => 'privacy policy';

  @override
  String get registerPrivacyNoticeWithoutLink =>
      'We only use your email address for your account, for example to reset your password.';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordRequestIntro =>
      'Enter your username and the email address of your account. We\'ll send you a code.';

  @override
  String get forgotPasswordRequestButton => 'Send code';

  @override
  String get forgotPasswordRequestFailed =>
      'We couldn\'t send a code. Check your username and email address. If you sign in with Apple, you don\'t need a password.';

  @override
  String forgotPasswordCodeSent(String email) {
    return 'We sent a code to $email. It\'s valid for two hours.';
  }

  @override
  String get resetCodeLabel => 'Code from the email';

  @override
  String get resetCodeHint => 'e.g. 123-456';

  @override
  String get resetCodeInvalid => 'The code has six digits, e.g. 123-456.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get forgotPasswordSaveButton => 'Save password';

  @override
  String get forgotPasswordResetFailed =>
      'That didn\'t work: the code is wrong or has expired. Request a new one if needed.';

  @override
  String get forgotPasswordRequestNewCode => 'Request a new code';

  @override
  String get forgotPasswordSuccess =>
      'Your password has been changed. Sign in with your new password now.';

  @override
  String get forgotPasswordBackToLogin => 'Back to sign in';

  @override
  String get authNoConnection =>
      'The server can\'t be reached right now. Please try again in a moment.';

  @override
  String get wizardFinishBtnLabel => 'Done';

  @override
  String get wizardSkipBtnLabel => 'Skip';

  @override
  String get wizardOptionalStepLabel => 'Optional step';

  @override
  String get wizardShowExplanation => 'Show explanation';

  @override
  String get wizardHideExplanation => 'Hide explanation';

  @override
  String get wizardSavedSnackbar => 'Setup saved';

  @override
  String get confirmDeleteBtnLabel => 'Delete';

  @override
  String get wizardUndo => 'Undo';

  @override
  String get wizardSkinStepHelper =>
      '## Welcome to QuestKeeper!\n\nIn the next steps you set up your campaign: appearance, name, character sheet, initiative and currency. Optional steps for items and crafting follow, which you can skip.\n\nEverything is saved automatically. Close the wizard at any time with the X in the top left; the gear icon in the top right brings you back here later.\n\n## Appearance\n\nPick the default look for character sheets in this campaign. Players can change it later for their own characters.';

  @override
  String get wizardCampaignNameStepHelper =>
      '## Campaign name\n\nWhat is your campaign called? You can change the name any time later.\n\nThe name needs at least four characters.';

  @override
  String get wizardCharacterSheetStepTitle => 'Character sheet';

  @override
  String get wizardTabNameLabel => 'Tab name';

  @override
  String get wizardUnnamedTab => 'Unnamed tab';

  @override
  String get wizardUnnamedProperty => 'Unnamed property';

  @override
  String wizardGroupLabel(int number) {
    return 'Group $number';
  }

  @override
  String get wizardDeleteTabTitle => 'Delete tab?';

  @override
  String wizardDeleteTabMessage(int count, String tabName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Delete tab “$tabName” with $count properties? Character values will be lost.',
      one:
          'Delete tab “$tabName” with one property? Character values will be lost.',
      zero: 'Delete the empty tab “$tabName”?',
    );
    return '$_temp0';
  }

  @override
  String get wizardDeletePropertyTitle => 'Delete property?';

  @override
  String wizardDeletePropertyMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Delete property “$name”? $count characters already have values for it, which will be lost.',
      one:
          'Delete property “$name”? One character already has a value for it, which will be lost.',
    );
    return '$_temp0';
  }

  @override
  String wizardPropertyDeletedSnackbar(String name) {
    return 'Property “$name” deleted';
  }

  @override
  String get wizardCurrencyStepTitle => 'Currency';

  @override
  String get wizardCurrencyStepHelper =>
      '## Currency\n\nSet up which currencies exist in your world and how they convert.\n\nStart with the smallest unit (e.g. copper) and work your way up to the largest. For each further currency, enter how many of the previous one it is worth (in many fantasy RPGs: 10 copper = 1 silver).';

  @override
  String get wizardSmallestCurrencyLabel => 'Name of the smallest currency:';

  @override
  String get wizardNextCurrencyLabel => 'Name of the next larger currency:';

  @override
  String get wizardCurrencyMultipleLabel =>
      'Worth how many of the previous currency:';

  @override
  String get wizardNewEntryDefaultName => 'New';

  @override
  String get wizardLocationsStepTitle => 'Places of finding';

  @override
  String get wizardLocationsStepHelper =>
      '## Places of finding (optional)\n\nFrom here on it is about items and crafting. You only need this and the following steps (places of finding, item categories, items, recipes) if you play with them. **Skip** takes you straight to the summary; data you already entered stays.\n\nSome items can be found in certain places: on the beach, in caves, in grottos and so on. Add those places here so you can link them to items in the next steps.';

  @override
  String wizardLocationLabel(int number) {
    return 'Place #$number';
  }

  @override
  String wizardLocationItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items can be found here.',
      one: 'One item can be found here.',
      zero: 'No items can be found here yet.',
    );
    return '$_temp0';
  }

  @override
  String get wizardItemCategoriesStepTitle => 'Item categories';

  @override
  String get wizardItemCategoriesStepHelper =>
      '## Item categories (optional)\n\nSo players can filter their items, we sort them into categories. We have prepared a set of categories and subcategories for you.\n\nFeel free to adjust them if they do not fit your game.';

  @override
  String get wizardCategoryNameLabel => 'Category name:';

  @override
  String get wizardSubCategoryNameLabel => 'Subcategory name:';

  @override
  String wizardCategoryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in this category.',
      one: 'One item in this category.',
      zero: 'No items in this category yet.',
    );
    return '$_temp0';
  }

  @override
  String get wizardNewSubCategoryBtnLabel => 'New subcategory';

  @override
  String wizardIconForCategorySuffix(String name) {
    return ' (for category $name)';
  }

  @override
  String get wizardItemsStepTitle => 'Items';

  @override
  String get wizardItemsStepHelper =>
      '## Items (optional)\n\nAdd the items of your world here: healing potions, weapons, quest items or ingredients for poisons, anything that can end up in the bags of your players.\n\nYou can also note what a potion does.\n\nTip: put effects, damage and the like at the start of the description. Then your players see the most important facts at a glance.';

  @override
  String get wizardEditItemTitle => 'Edit item';

  @override
  String get wizardItemNameLabel => 'Item name:';

  @override
  String get wizardItemCategoryLabel => 'Category';

  @override
  String get wizardItemPatchSizeLabel => 'Patch size (optional):';

  @override
  String get wizardItemImageDescriptionLabel => 'Image description:';

  @override
  String get wizardItemPlacesOfFindingHeader => 'Places of finding:';

  @override
  String get wizardNewLocationBtnLabel => 'New place';

  @override
  String get wizardNewImageBtnLabel => 'New image';

  @override
  String get wizardPickImageBtnLabel => 'Choose image';

  @override
  String get wizardInvalidImageFile => 'This file is not a valid image.';

  @override
  String get wizardRecipesStepTitle => 'Recipes';

  @override
  String get wizardRecipesStepHelper =>
      '## Recipes (optional)\n\nRecipes let your players craft things themselves, for example healing potions.\n\nSome recipes require a tool, such as a herbalism kit. You can note that in the recipe too; players then need the tool to use the recipe.\n\nTap a recipe to edit it. Press and hold it for more actions.';

  @override
  String get wizardRecipeOpenDetails => 'Open details';

  @override
  String get wizardRecipeDuplicateAndOpen => 'Duplicate and open';

  @override
  String get wizardRecipeDeletePermanently => 'Delete permanently';

  @override
  String get wizardEditRecipeTitle => 'Edit recipe';

  @override
  String get wizardRecipeCreatedItemLabel => 'Item to craft';

  @override
  String wizardRecipeRequirementLabel(int number) {
    return 'Prerequisite #$number';
  }

  @override
  String get wizardRecipeAddRequirement => 'Add prerequisite';

  @override
  String wizardRecipeIngredientLabel(int number) {
    return 'Ingredient #$number';
  }

  @override
  String get wizardRecipeAddIngredient => 'Add ingredient';

  @override
  String get wizardSummaryStepTitle => 'Summary';

  @override
  String get wizardSummaryStepHelper =>
      '## All set!\n\nYour campaign is set up and everything is saved. The overview shows what is set up.\n\nYou can change everything later via the gear icon in the top right.\n\n**Done** closes the wizard.';

  @override
  String get wizardSummaryCampaignLabel => 'Campaign';

  @override
  String get wizardSummaryNotSet => 'Not set yet';

  @override
  String wizardSummaryTabCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabs',
      one: '1 tab',
    );
    return '$_temp0';
  }

  @override
  String wizardSummaryPropertyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count properties',
      one: '1 property',
    );
    return '$_temp0';
  }

  @override
  String wizardSummaryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String wizardSummaryRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
      zero: 'No recipes',
    );
    return '$_temp0';
  }

  @override
  String get welcomeToQuestKeeper => 'Welcome to QuestKeeper';

  @override
  String get questKeeperIntro =>
      'QuestKeeper supports your tabletop group at the table. The game master sets up the campaign, everyone else keeps their character sheet in the app. Hit points, items and shared notes stay up to date for everyone, live.';

  @override
  String get pathRunAGameTitle => 'I run a game';

  @override
  String get pathRunAGameSubtitle => 'Create a campaign and invite players';

  @override
  String get pathJoinAGameTitle => 'I join a game';

  @override
  String get pathJoinAGameSubtitle => 'With the code from your game master';

  @override
  String get joinCampagneAction => 'Join a campaign';

  @override
  String get createCampagneAction => 'Create campaign';

  @override
  String get noCampagnesYetHint =>
      'Create a campaign, set up the character sheet and invite your group with a code.';

  @override
  String get noCharactersYetHint =>
      'Join a campaign with the code from your game master. You create your character along the way.';

  @override
  String campagneSettingsChangedAt(String date) {
    return 'Settings changed: $date';
  }

  @override
  String openJoinRequestsBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open requests',
      one: '1 open request',
    );
    return '$_temp0';
  }

  @override
  String characterLastEditedAt(String date) {
    return 'Last edited: $date';
  }

  @override
  String get waitingForDmApproval => 'Waiting for the game master to approve';

  @override
  String get characterNotInCampagneHint =>
      'Not in a campaign yet. Tap to join with a code.';

  @override
  String get joinCampagneNewCharacterIntro =>
      'Enter the join code you got from your game master and the name of your character. You fill in the rest of the character sheet once the game master has let you in.';

  @override
  String get joinCodeEmptyError => 'Please enter the join code.';

  @override
  String get joinCodeIncompleteError =>
      'The code has six digits, for example 123-456.';

  @override
  String get joinCodeUnknownError =>
      'This code does not exist. Check it with your game master.';

  @override
  String get characterNameFieldLabel => 'Name of your character';

  @override
  String get nameRequiredError => 'Please enter a name';

  @override
  String get joinAction => 'Join';

  @override
  String get joinRequestSentConfirmation =>
      'Request sent. As soon as your game master approves, you can play.';

  @override
  String get joinRequestAcceptedMessage =>
      'Your join request was accepted. You can play now.';

  @override
  String get joinRequestDeniedMessage => 'Your join request was declined.';

  @override
  String joinRequestCreatedForDm(String playerName, String username) {
    return '$playerName ($username) wants to join your campaign.';
  }

  @override
  String get waitingForApprovalTitle => 'Waiting for approval';

  @override
  String waitingForApprovalText(String characterName) {
    return 'Your request for “$characterName” is with your game master. As soon as they approve, you can play here.';
  }

  @override
  String get enterCodeAgainAction => 'Enter code again';

  @override
  String get newCampagneIntro =>
      'What should your campaign be called? Next you pick a template, and the assistant guides you through character sheet, currency and items.';

  @override
  String get createAction => 'Create';

  @override
  String get invitePlayersAction => 'Invite players';

  @override
  String get noPlayersYetHint =>
      'No players yet. Invite your group with “Invite players”.';

  @override
  String get invitePlayersInstruction =>
      'In QuestKeeper, tap “Join a campaign” and enter this code.';

  @override
  String get invitePlayersApprovalHint =>
      'Requests then show up under “Join requests”. Tap ✓ to let someone in.';

  @override
  String get copyCodeAction => 'Copy code';

  @override
  String get copiedConfirmation => 'Copied';

  @override
  String get shareInviteAction => 'Share invitation';

  @override
  String inviteShareText(String campagneName, String code) {
    return 'Play in my campaign “$campagneName”! Open QuestKeeper, tap “Join a campaign” and enter this code: $code';
  }

  @override
  String inviteShareSubject(String campagneName) {
    return 'Invitation to “$campagneName”';
  }

  @override
  String get qrCodeHint => 'The QR code only contains the code.';

  @override
  String get closeAction => 'Close';

  @override
  String get errorDetailsStatusLabel => 'HTTP status:';

  @override
  String get errorDetailsServerLabel => 'Server response:';

  @override
  String get errorDetailsDescriptionLabel => 'Description:';

  @override
  String get errorMessageNoConnection =>
      'Could not reach the server. Check your internet connection and try again.';

  @override
  String get errorMessageBadRequest =>
      'The server could not process the input. Check your entries and try again.';

  @override
  String get errorMessageUnauthorized =>
      'You are not allowed to do this. Sign in again if needed.';

  @override
  String get errorMessageNotFound => 'This item does not exist (anymore).';

  @override
  String get errorMessageConflict =>
      'This was just changed somewhere else. Reload and try again.';

  @override
  String get errorMessageServer =>
      'Something went wrong on the server. Please try again later.';

  @override
  String get errorMessageUnknown => 'Something went wrong. Please try again.';

  @override
  String get myNotesGroupName => 'My notes';

  @override
  String get pageTabShortCampaign => 'Campaign';

  @override
  String get pageTabShortCharacters => 'Characters';

  @override
  String get pageTabShortFight => 'Combat';

  @override
  String get pageTabShortItems => 'Items';

  @override
  String get pageTabShortNotes => 'Notes';

  @override
  String get pageTabShortImages => 'Images';

  @override
  String get ledgerManuscriptDateFormat => 'MMMM d, y, h:mm a';

  @override
  String get invalidWholeNumberInput =>
      'Please enter a whole number, e.g. -1 or 3.';

  @override
  String get invalidLevelInput =>
      'The level must be a whole number of 0 or more, e.g. 3.';

  @override
  String get previewAndVariantTileTitle => 'Preview and layout';

  @override
  String get characterSetupTitle => 'Set up character';

  @override
  String characterSetupProgress(int current, int total, String tabName) {
    return 'Section $current of $total: $tabName';
  }

  @override
  String get characterSetupHint =>
      'Anything you leave empty now can be filled in later right on the character sheet.';

  @override
  String get characterSetupFinish => 'Done';

  @override
  String get fillInLater => 'Fill in later';

  @override
  String get characterNameRequired => 'Please enter a name.';

  @override
  String get fixMarkedFieldsHint => 'Please fix the marked fields.';

  @override
  String get moneyModeDeposit => '+ Add';

  @override
  String get moneyModeSpend => '− Spend';

  @override
  String get activeAlternateFormBannerTitle => 'Alternate form';

  @override
  String get missingStatTapToFill => 'Still empty – tap to fill in';

  @override
  String get missingStatUnnamed => 'Unnamed property';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get apiKeysSettingsSubtitle => 'Manage your personal API keys';

  @override
  String get noteBlockTextLabel => 'Text';

  @override
  String get generateImageDescriptionHint =>
      'Describe the image you want to generate. The more detail you give, the better the image fits.';

  @override
  String get generateImagePromptLabel => 'Image description';

  @override
  String get generateImagePromptExample =>
      'e.g. “A mystical forest with elves”';

  @override
  String get reactivateTransformationTitle =>
      'Reactivate previous transformation';

  @override
  String get reactivateTransformationQuestion =>
      'Do you want to resume your last transformation or take on a new form?';

  @override
  String get newTransformationDeletesOldTitle =>
      'Old transformations will be deleted';

  @override
  String get newTransformationDeletesOldText =>
      'Creating a new transformation deletes all old ones.';

  @override
  String get selectTransformationTitle => 'Choose transformation';

  @override
  String get selectTransformationComponentsHint =>
      'Choose the transformations your new form should be made of.';

  @override
  String get noTransformationComponentsHint =>
      'There are no transformations yet. Set them up in your character settings first.';

  @override
  String transformationStatSettingsFor(String statName) {
    return 'Settings for $statName';
  }

  @override
  String get invalidWholeNumberShort => 'Enter a whole number';

  @override
  String get invalidNonNegativeNumberShort => 'Enter 0 or more';

  @override
  String get invalidPositiveNumberShort => 'Enter 1 or more';

  @override
  String get invalidCurrencyMultiple =>
      'Enter a whole number greater than 1, e.g. 10.';

  @override
  String get aboutLicensesTitle => 'About & licenses';

  @override
  String get aboutLicensesSrdTitle => 'Rules material: SRD 5.2.1';

  @override
  String get aboutLicensesSrdIntro =>
      'The “Fantasy 5E (SRD)” template contains material from the System Reference Document 5.2.1. It is licensed under the Creative Commons Attribution 4.0 International License (CC BY 4.0).';

  @override
  String get aboutLicensesAttributionEnglish =>
      'Attribution (English original)';

  @override
  String get aboutLicensesAttributionGerman => 'Attribution (German edition)';

  @override
  String get aboutLicensesAuthoritativeHint =>
      'The German text is for information only. The English version is authoritative.';

  @override
  String get aboutLicensesChanges =>
      'Changes: material from the SRD 5.2.1 was selected, translated or taken from the German edition, abridged and adapted for QuestKeeper. Summaries and other template texts are our own.';

  @override
  String get aboutLicensesOpenLicense => 'Open license CC BY 4.0';

  @override
  String get aboutLicensesNotAffiliated =>
      'QuestKeeper is an independent product. It is not published or endorsed by any roleplaying game publisher.';

  @override
  String get aboutLicensesOpenSourceTitle => 'Open source licenses';

  @override
  String get aboutLicensesShowOpenSource => 'Show all licenses';

  @override
  String get aboutLicensesSettingsSubtitle =>
      'Rules material, licenses and open source notices';

  @override
  String get statTypeCheckboxTrack => 'Checkbox track';

  @override
  String get statTypeCheckboxTrackHelp =>
      'A row of boxes players tick with one tap on the sheet, e.g. stress.';

  @override
  String get statTypeTextList => 'Text list';

  @override
  String get statTypeTextListHelp =>
      'Several text entries, optionally with fixed, labelled slots, e.g. aspects or consequences.';

  @override
  String get statTypeSingleSelect => 'Choice (one)';

  @override
  String get statTypeSingleSelectHelp =>
      'Players pick exactly one of the options, e.g. background or alignment.';

  @override
  String get statTypeUnsupported => 'Unknown type';

  @override
  String get statTypeUnsupportedHint =>
      'Not supported by this version. Please update the app.';

  @override
  String get checkboxTrackBoxesHeadline => 'Boxes';

  @override
  String get checkboxTrackBoxCountLabel => 'Count';

  @override
  String get checkboxTrackLabelsHint =>
      'Labels are optional, e.g. “1”, “2”, “3” or “Mild”.';

  @override
  String checkboxTrackBoxLabel(int number) {
    return 'Box $number';
  }

  @override
  String get checkboxTrackTapHint => 'Tap a box to tick or clear it.';

  @override
  String get textListSlotsHeadline => 'Fixed slots';

  @override
  String get textListSlotsHint =>
      'Optional, e.g. “High concept”, “Trouble” or “Mild (2)”.';

  @override
  String get textListSlotLabel => 'Label:';

  @override
  String get textListAllowCustomEntries =>
      'Players may add and delete their own entries';

  @override
  String get textListAddEntry => 'Add entry';

  @override
  String get textListOwnEntryLabel => 'Own entry';

  @override
  String get textListEmpty => 'No entries yet';

  @override
  String get textListEditEntryTitle => 'Edit entry';

  @override
  String get textListDeleteEntry => 'Delete';

  @override
  String get singleSelectOptionsHeadline => 'Options';

  @override
  String get singleSelectNothingChosen => 'Nothing chosen yet';

  @override
  String get showLevelToggle => 'Show level';

  @override
  String get showLevelHint =>
      'Off: the character form does not ask for a level and the sheet shows none.';

  @override
  String get playerPreviewButton => 'Player\'s view';

  @override
  String get playerPreviewTitle => 'Player\'s view';

  @override
  String get playerPreviewPhone => 'Phone';

  @override
  String get playerPreviewTablet => 'Tablet';

  @override
  String get playerPreviewHint =>
      'A sample character with default values. Nothing here is saved.';

  @override
  String get playerPreviewSampleCharacterName => 'Sample character';

  @override
  String get othersNotesGroupName => 'Players\' notes';

  @override
  String get wizardTemplateStepTitle => 'Template';

  @override
  String get wizardTemplateStepHelper =>
      '## Welcome to QuestKeeper!\n\nIn the next steps you set up your campaign: template, appearance, name, character sheet, initiative and currency. Optional steps for items and crafting follow, which you can skip.\n\nEverything is saved automatically. Close the wizard at any time with the X in the top left; the gear icon in the top right brings you back here later.\n\n## Template\n\nPick what you start with. The template fills in the character sheet and the currency. You can change everything in the next steps.\n\nYou only pick a template when you create the campaign. Later, the gear icon lets you change each part on its own.';

  @override
  String get wizardTemplateContentsLabel => 'Includes';

  @override
  String get wizardTemplateEmptyName => 'Blank';

  @override
  String get wizardTemplateEmptyDescription =>
      'A plain sheet with name, level and a description. You add everything else yourself.';

  @override
  String get wizardTemplateEmptyContents => 'Name, level, one currency';

  @override
  String get wizardTemplateFantasyName => 'Fantasy 5E (SRD)';

  @override
  String get wizardTemplateFantasyDescription =>
      'Classic fantasy with abilities, hit points and spells.';

  @override
  String get wizardTemplateFantasyContents =>
      'Abilities, skills, spells, copper to platinum';

  @override
  String get wizardTemplateNarrativeName => 'Narrative (aspects & stress)';

  @override
  String get wizardTemplateNarrativeDescription =>
      'For tables where the story comes first: aspects describe the characters, stress takes the hits.';

  @override
  String get wizardTemplateNarrativeContents =>
      'Aspects, skills, stunts, stress, consequences, story points';

  @override
  String get wizardTemplateReplaceTitle => 'Switch template?';

  @override
  String get wizardTemplateReplaceMessage =>
      'You changed things since picking the template. These changes will be lost. The campaign name and appearance stay.';

  @override
  String get wizardTemplateReplaceConfirm => 'Switch template';

  @override
  String get wizardSkinStepHelperAfterTemplate =>
      '## Appearance\n\nPick the default look for character sheets in this campaign. Players can change it later for their own characters.';

  @override
  String get statStyleNumberAndMax => 'Number and maximum';

  @override
  String get statStyleRing => 'Ring';

  @override
  String get statStylePentagon => 'Pentagon';

  @override
  String get statStyleRingHealthColors => 'Ring in health colours';

  @override
  String get statStylePips => 'Pips';

  @override
  String get statStyleHearts => 'Hearts';

  @override
  String get statStyleCrystals => 'Crystals';

  @override
  String get statStyleSegmentedBar => 'Segmented bar';

  @override
  String get statStyleCombatChip => 'Compact';

  @override
  String get statStyleStacked => 'Stacked';

  @override
  String get statStyleModifierFirst => 'Modifier first';

  @override
  String get statStyleClassicBlock => 'Classic block';

  @override
  String get statStylePentagons => 'Pentagons';

  @override
  String get statStyleModifierTiles => 'Tiles, modifier first';

  @override
  String get statStyleShields => 'Shields';

  @override
  String get statStyleClassicBlocks => 'Classic blocks';

  @override
  String get statStyleIconAndValue => 'Icon and value';

  @override
  String get statStyleValueOverLabel => 'Value over name';

  @override
  String get statStyleMedallions => 'Medallions';

  @override
  String get statStyleRibbon => 'Ribbon';

  @override
  String get statStyleMainValueLarge => 'First value large';

  @override
  String get statStyleSelectedOnly => 'Selected only';

  @override
  String get statStyleAllOptions => 'All options';

  @override
  String get statStyleChips => 'Chips';

  @override
  String get statStyleTiles => 'Tiles';

  @override
  String get statStyleSummary => 'Summary';

  @override
  String get statStyleLevelCircle => 'Level circle';

  @override
  String get statStyleBanner => 'Banner';

  @override
  String get statStylePortraitCard => 'Portrait card';

  @override
  String get statStyleSingleLine => 'Single line';

  @override
  String get statStyleText => 'Text';

  @override
  String get statStyleCollapsible => 'Collapsible';

  @override
  String get statStyleParchment => 'Parchment';

  @override
  String get statStyleImage => 'Image';

  @override
  String get statStylePawAndButtons => 'Paw and buttons';

  @override
  String get statStyleSmallCards => 'Small cards';

  @override
  String get statStyleWand => 'Wand';

  @override
  String get statStyleActiveFormBanner => 'Active form banner';

  @override
  String get statStyleNumberOverName => 'Number over name';

  @override
  String get statStyleLargeNumber => 'Large number';

  @override
  String get statStyleBoxes => 'Boxes';

  @override
  String get statStyleList => 'List';

  @override
  String get statStyleChosenOption => 'Chosen option';

  @override
  String statStylePosition(int index, int count) {
    return '$index of $count';
  }

  @override
  String get statStylePrevious => 'Previous style';

  @override
  String get statStyleNext => 'Next style';

  @override
  String get propertyPurposePickerQuestion => 'What do you want to track?';

  @override
  String get propertyPurposePickerHint =>
      'Pick what the property is for. You can still change its field type and look afterwards.';

  @override
  String get propertyPurposeAdvancedTitle => 'All field types';

  @override
  String get propertyPurposeAdvancedDescription =>
      'Choose the field type yourself from the full list.';

  @override
  String get propertyPurposeChangeType => 'Field type and how often it changes';

  @override
  String get propertyPreviewHint =>
      'This is how the property looks on the sheet, with sample values.';

  @override
  String get propertyPreviewNeedsEntries =>
      'Add entries above to see the preview here.';

  @override
  String get propertyPurposeResourceTitle => 'Health & resources';

  @override
  String get propertyPurposeResourceDescription =>
      'A value with a maximum that players change with + and − during play. E.g. hit points, mana, ammunition.';

  @override
  String get propertyPurposeAbilitiesTitle => 'Abilities';

  @override
  String get propertyPurposeAbilitiesDescription =>
      'Several values with a bonus that rarely change. E.g. strength, dexterity, wisdom.';

  @override
  String get propertyPurposeKeyNumbersTitle => 'Key numbers';

  @override
  String get propertyPurposeKeyNumbersDescription =>
      'Several numbers with an icon. E.g. armour class, speed, initiative.';

  @override
  String get propertyPurposeCounterTitle => 'Counter';

  @override
  String get propertyPurposeCounterDescription =>
      'A single number that changes during play. E.g. story points, inspiration, luck.';

  @override
  String get propertyPurposeValueWithBonusTitle => 'Value with bonus';

  @override
  String get propertyPurposeValueWithBonusDescription =>
      'A number with a second number next to it. E.g. an ability with its modifier.';

  @override
  String get propertyPurposeTickBoxesTitle => 'Tick boxes';

  @override
  String get propertyPurposeTickBoxesDescription =>
      'Boxes players tick with one tap. E.g. stress, exhaustion, death saves.';

  @override
  String get propertyPurposeChecklistTitle => 'Checklist';

  @override
  String get propertyPurposeChecklistDescription =>
      'Tick several options from a list. E.g. skills, saving throws, languages.';

  @override
  String get propertyPurposePickOneTitle => 'Pick one';

  @override
  String get propertyPurposePickOneDescription =>
      'Exactly one option from a list. E.g. class, alignment, origin.';

  @override
  String get propertyPurposeEntriesTitle => 'List of entries';

  @override
  String get propertyPurposeEntriesDescription =>
      'Short entries, fixed or added by players. E.g. aspects, goals, contacts.';

  @override
  String get propertyPurposeShortTextTitle => 'Short text';

  @override
  String get propertyPurposeShortTextDescription =>
      'One line. E.g. deity, title, home town.';

  @override
  String get propertyPurposeLongTextTitle => 'Long text';

  @override
  String get propertyPurposeLongTextDescription =>
      'Several paragraphs. E.g. background, personality, equipment.';

  @override
  String get propertyPurposeImageTitle => 'Image';

  @override
  String get propertyPurposeImageDescription =>
      'An image with a description. E.g. portrait, crest.';

  @override
  String get propertyPurposeCompanionsTitle => 'Companions';

  @override
  String get propertyPurposeCompanionsDescription =>
      'Companions with their own sheet. E.g. pet, familiar, mount.';

  @override
  String get propertyPurposeTransformationTitle => 'Transformation';

  @override
  String get propertyPurposeTransformationDescription =>
      'A button that turns the character into another form. E.g. an animal shape.';

  @override
  String get buildingBlocksTitle => 'Ready-made blocks';

  @override
  String get buildingBlocksCardDescription =>
      'Take properties from the templates, e.g. ability scores, saving throws, spell slots, aspects or stress.';

  @override
  String get buildingBlocksHint =>
      'Tick what you want to take over. The properties go into this tab, and you can change them afterwards.';

  @override
  String buildingBlocksTabLabel(String tabName) {
    return 'Tab “$tabName”';
  }

  @override
  String get buildingBlocksAlreadyOnSheet => 'Already on the sheet';

  @override
  String get buildingBlocksAdd => 'Add';

  @override
  String buildingBlocksAddCount(int count) {
    return 'Add $count';
  }

  @override
  String get wizardTemplateFromCampagneHeader => 'From one of your campaigns';

  @override
  String get wizardTemplateFromCampagneHint =>
      'Takes over the character sheet, currency, items and recipes. Characters, notes and players stay in the other campaign.';

  @override
  String wizardTemplateFromCampagneProperties(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count properties',
      one: '1 property',
    );
    return '$_temp0';
  }

  @override
  String wizardTemplateFromCampagneItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String wizardTemplateFromCampagneRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
    );
    return '$_temp0';
  }

  @override
  String wizardTemplateFromCampagneDescription(String tabs) {
    return 'Sheet with the tabs $tabs';
  }

  @override
  String templateUpdateBannerTitle(String template) {
    return 'New in the template “$template”';
  }

  @override
  String templateUpdateBannerText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count properties',
      one: 'one property',
    );
    return 'The template has added or revised $_temp0 since. You decide what to take over.';
  }

  @override
  String get templateUpdateReview => 'Review';

  @override
  String get templateUpdateDismiss => 'Hide';

  @override
  String get templateUpdateTitle => 'Update from template';

  @override
  String get templateUpdateHint =>
      'Tick what you want to take over. The characters\' values stay, and so do your own properties and your own list entries.';

  @override
  String templateUpdateAdded(String tabName) {
    return 'New, goes into the tab “$tabName”';
  }

  @override
  String templateUpdateNewName(String name) {
    return 'New name: $name';
  }

  @override
  String get templateUpdateNewHelperText => 'New help text';

  @override
  String templateUpdateNewEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new entries',
      one: '1 new entry',
    );
    return '$_temp0';
  }

  @override
  String get templateUpdateEntriesRevised => 'Entries revised';

  @override
  String get templateUpdateOtherSettings => 'Other settings';

  @override
  String get templateUpdateApply => 'Apply';

  @override
  String templateUpdateApplyCount(int count) {
    return 'Apply $count';
  }

  @override
  String get optionCardMore => 'More';

  @override
  String get optionCardLess => 'Less';

  @override
  String statExampleHint(String example) {
    return 'e.g. $example';
  }

  @override
  String get propertyExampleLabel => 'Example answer (optional)';

  @override
  String get propertyExampleHelp =>
      'Shown in grey in the empty field so players see what is meant.';

  @override
  String get templateUpdateNewExample => 'New example answer';

  @override
  String get quickStartTitle => 'Quick start';

  @override
  String quickStartText(String fields) {
    return 'Just $fields. You fill in the rest on the character sheet later, when it is needed.';
  }

  @override
  String get quickStartAnd => 'and';

  @override
  String get quickStartAllSections => 'All sections';

  @override
  String get quickStartPageHint =>
      'Everything else stays open and can be filled in on the character sheet at any time.';

  @override
  String get levelUpTitle => 'Level up';

  @override
  String levelUpIntro(int from, int to) {
    return 'From level $from to $to. Enter what changes with the new level – leave what stays the same as it is.';
  }

  @override
  String get levelUpOnlyLevelHint =>
      'The game master can choose in the sheet setup which properties are asked for here as well.';

  @override
  String get levelUpMenuEntry => 'Level up';

  @override
  String get propertyAskOnLevelUp => 'Ask for it on level-up';

  @override
  String get templateUpdateLevelUpChanged => 'Asked for on level-up';
}
