import 'package:flutter/widgets.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/login_service.dart';

class LoginScreen extends StatelessWidget {
  static const String route = "login";

  const LoginScreen({super.key});

  static Future<bool> checkIfAppVersionFits(BuildContext context) async {
    var loginService =
        DependencyProvider.of(context).getService<ILoginService>();

    // check if version matches
    var isAppVersionAllowedToTalkToApi =
        await loginService.isAppVersionAllowedToTalkToApi();
    if (!context.mounted) return false;

    await isAppVersionAllowedToTalkToApi.possiblyHandleError(context);

    if (!isAppVersionAllowedToTalkToApi.isSuccessful) {
      return false;
    }

    if (isAppVersionAllowedToTalkToApi.result == false) {
      // show user screen to please update their app!
      if (!context.mounted) return false;

      // TODO add me
      // await showOldVersionUpdateRequired(context);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
