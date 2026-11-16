import 'package:flutter/foundation.dart';

/// Name of the "package" under which the SRD attribution appears in
/// Flutter's license page.
const String srdLicensePackageName = 'System Reference Document 5.2.1';

/// Attribution statement required by the SRD 5.2.1, verbatim from the
/// English edition ("Legal Information", p. 1).
const String srdAttributionEnglish =
    'This work includes material from the System Reference Document 5.2.1 '
    '(“SRD 5.2.1”) by Wizards of the Coast LLC, available at '
    'https://www.dndbeyond.com/srd. The SRD 5.2.1 is licensed under the '
    'Creative Commons Attribution 4.0 International License, available at '
    'https://creativecommons.org/licenses/by/4.0/legalcode.';

/// The same statement, verbatim from the official German edition of the
/// SRD 5.2.1 ("Rechtliche Informationen", p. 1). The English one is
/// authoritative.
const String srdAttributionGerman =
    'Dieses Werk enthält Material aus dem Systemreferenzdokument 5.2.1 '
    '(„SRD 5.2.1“) von Wizards of the Coast LLC, verfügbar unter '
    'https://www.dndbeyond.com/srd. Das SRD 5.2.1 ist lizenziert gemäß '
    'Creative Commons Namensnennung 4.0 International Public License '
    '(verfügbar unter https://creativecommons.org/licenses/by/4.0/legalcode.de).';

/// CC BY 4.0 deed, linked from the about page.
const String ccByLicenseUrl = 'https://creativecommons.org/licenses/by/4.0/';

/// Notice of changes (CC BY 4.0, section 3(a)(1)(B)) for the license list,
/// which cannot be localized.
const String srdChangesNotice =
    'Changes: material from the SRD 5.2.1 was selected, translated or taken '
    'from the German edition, abridged and adapted for QuestKeeper. '
    'Summaries and other template texts are our own.\n\n'
    'Änderungen: Material aus dem SRD 5.2.1 wurde ausgewählt, übersetzt oder '
    'aus der deutschen Fassung übernommen, gekürzt und an QuestKeeper '
    'angepasst. Kurzbeschreibungen und weitere Texte der Vorlage sind eigene '
    'Texte.';

/// The SRD attribution as an entry for [LicenseRegistry.addLicense].
Stream<LicenseEntry> srdLicenseEntries() async* {
  yield const LicenseEntryWithLineBreaks(
    [srdLicensePackageName],
    '$srdAttributionEnglish\n\n'
    '$srdAttributionGerman\n\n'
    '$srdChangesNotice\n\n'
    'License / Lizenz: $ccByLicenseUrl',
  );
}
