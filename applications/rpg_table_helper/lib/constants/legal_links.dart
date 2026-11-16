/// Link to the privacy policy shown before registering.
///
/// There is no published privacy policy yet. While this is null (or empty),
/// the register screen shows a neutral sentence without a link.
const String? privacyPolicyUrl = null;

/// Whether [url] is set to something that can be linked to.
bool hasLegalLink(String? url) => url != null && url.trim().isNotEmpty;
