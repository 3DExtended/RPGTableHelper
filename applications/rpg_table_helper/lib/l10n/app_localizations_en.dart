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
  String get newImageBtnLabel => 'New image';

  @override
  String get additionalSettings => 'Additional settings';

  @override
  String get hidePropertyForCharacter => 'Hide property for my character';

  @override
  String get hideHeading => 'Hide heading';

  @override
  String get addCharacterToCampagneModalTitle => 'Add character to campaign';

  @override
  String get assignCharacterToCampagneModalContent =>
      'You have created a character, but it is not yet assigned to a season or campaign. Enter the join code you received from your DM here to send a request to your DM.';

  @override
  String get joinCode => 'Join Code:';

  @override
  String get genericErrorModalHeader => 'Error';

  @override
  String get genericErrorModalTechnicalDetailsHeader => 'Technical details: ';

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
  String get characterOverview => 'Charakter overview';

  @override
  String get fightingOrdering => 'Fight order';

  @override
  String get grantItems => 'Grant items';

  @override
  String get lore => 'Lore';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get allPlayers => 'All players:';

  @override
  String get openJoinRequests => 'Join requests:';

  @override
  String get joinCodeForNewPlayers => 'Join code (for new players):';

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
  String get itemsToBeFoundInPlaceMarkdown => '## Items to be found in place:';

  @override
  String get noPlaceOfFindingSelected => 'No place of finding selected.';

  @override
  String get followingItemsArePossibleAtPlaceOfFinding =>
      'The following items are possible at the place of finding:';

  @override
  String get diceChallengeAbbr => 'DC';

  @override
  String get lastGrantedItemsMarkdownPrefix => 'Last granted items:';

  @override
  String get noItemsGrantedToPlayerThisRound => 'No items granted this round';

  @override
  String get login => 'Login';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get createNewAccount => 'Create new account';

  @override
  String get email => 'E-Mail';

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
    return 'You received $amount new items:';
  }

  @override
  String get ok => 'Ok';

  @override
  String get rpgConfigurationDmWizardStep2Tutorial =>
      'Now we come to the character sheets.\n\nEvery role-playing game has different attributes that characterize the players (e.g., how many hit points a player has).\n\nFor each attribute, as the game master, you need to define how the players can interact with this attribute. We need three pieces of information from you for each attribute:\n\n1. Name of the attribute: What should this value be called on the character sheet? (e.g., “HP”, “SP”, “Name”, etc.)\n2. Type of the attribute: Is it, for example, a text that the player can modify (e.g., the character\'s backstory) or a numerical value (e.g., the hit points)?\n3. Change type: Some of these attributes are regularly adjusted (e.g., the current hit points), while others are rarely changed (e.g., the maximum hit points). To consider this when creating the character sheets, you need to provide us with this information.\n\nIf you need more explanations, you can find an example page here with all configurations and the corresponding appearance on the character sheets:';

  @override
  String get levelAbbr => 'LVL';

  @override
  String get addAdditionalEnemy => 'Add additional enemy';

  @override
  String get enemyName => 'Enemy name';

  @override
  String get rollOfInititive => 'Roll of initiative';

  @override
  String get addAnAdditionalEnemyBtnLabel => 'Add more';

  @override
  String get enemy => 'Enemy';

  @override
  String get add => 'Add';

  @override
  String get initiativeRollForCharacterPrefix => 'Initiative roll';

  @override
  String get initiativeRollText =>
      'A fight has started. Please roll for initiative.';

  @override
  String get initiativeRollTextFieldLabel => 'Initiative roll';

  @override
  String get send => 'Absenden';

  @override
  String get editPageTitle => 'Edit document';

  @override
  String get editPageModalText =>
      'You can edit both the title and the grouping of your document here.';

  @override
  String get documentTitleLabel => 'Titel';

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
  String get dm => 'DM';

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
  String get itemCategoryFilterAll => 'All';

  @override
  String get craftableRecipeFilter => 'Craftable';

  @override
  String get noItemsInCategoryCraftable =>
      'No craftable items in this category';

  @override
  String get noItemsInCategory => 'No items in this category';

  @override
  String get craftableAmountText => 'Craftable:';

  @override
  String get navBarHeaderCrafting => 'Crafting';

  @override
  String get navBarHeaderLore => 'Lore';

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
  String get nothingSelected => '- Nothinge selected -';

  @override
  String get characterNameLabel => 'Name:';

  @override
  String get level => 'Level';

  @override
  String get count => 'Count';

  @override
  String get addItems => 'Add items';

  @override
  String get selectGameMode => 'Select Game Mode';

  @override
  String get chooseACampagne => 'Choose a campaign';

  @override
  String get startAsDm => 'Play as DM';

  @override
  String youOwnXCampaigns(int count) {
    return 'You own $count campaigns';
  }

  @override
  String get joinAsPlayer => 'Join as Player';

  @override
  String get chooseACharacter => 'Choose a character';

  @override
  String youOwnXCharacters(int count) {
    return 'You own $count characters';
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
  String get noFIghtStarted => 'No fight started yet';

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
  String get addNewTransformationComponent => 'Add new transformations';

  @override
  String get createNewTransformationTitle => 'Create new transformation';

  @override
  String get transformationName => 'Transformation name';

  @override
  String get transformationDescription => 'Transformation description';

  @override
  String get createTransformationHelperText =>
      'In order to create a new transformation, you have to select the properties which are modified by this transformation. (If this transformation doesn\'t change this property, you don\'t have to select it.)';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get warning => 'Warning';

  @override
  String get youAreEditingAnAlternateFormWarningText =>
      'You are editing an alternate form of the character. Changes made here will not affect the main character. If you want to change the main character, go back to the main character screen. Any changes made here will be saved to the alternate form, which will be reset after reverting your transformation.';

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
      'Your are disconnected... Either you or the DM has lost the connection.';

  @override
  String get characterNameStatTitle => 'Character Name';

  @override
  String get characterNameStatHelperText =>
      'What is the name of your character?';

  @override
  String get generateImageBtnLabel => 'Generate image';

  @override
  String get generateLoreImageTitle => 'Generate an image';

  @override
  String get generatedImagesTabTitle => 'Generierte Bilder';

  @override
  String get noImagesInCampagne =>
      'You did not generate any images in this campaign.';

  @override
  String get enterANameDefaultLabel => 'Enter a name';

  @override
  String get enterSomeDescriptionOnTheLeft =>
      'Enter some description on the left';

  @override
  String get tabIconsConfigurationTitle => 'Tab Icons';
}
