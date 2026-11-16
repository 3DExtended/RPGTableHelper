// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:quest_keeper/components/app_style_dialog.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Shows a failed [response] as a friendly dialog: a short German message,
/// an "OK" button and the technical details (error code, status, server
/// text) folded away.
Future<void> showGenericErrorModal<T>(
    HRResponseBase response, BuildContext context) async {
  await showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => GenericErrorDialog(response: response),
  );
}

/// Plain-language message for a failed [response], picked by HTTP status.
///
/// The services only carry English developer texts
/// ([HRResponseBase.humanReadableError]); those stay in the details.
String genericErrorMessageFor(HRResponseBase response, S s) {
  final status = response.statusCode;
  if (status == null) return s.errorMessageNoConnection;
  if (status == 401 || status == 403) return s.errorMessageUnauthorized;
  if (status == 404) return s.errorMessageNotFound;
  if (status == 409) return s.errorMessageConflict;
  if (status >= 500) return s.errorMessageServer;
  if (status >= 400) return s.errorMessageBadRequest;
  return s.errorMessageUnknown;
}

class GenericErrorDialog extends StatelessWidget {
  const GenericErrorDialog({super.key, required this.response});

  final HRResponseBase response;

  List<(String, String)> _detailRows(S s) {
    final rows = <(String, String?)>[
      (s.genericErrorModalTechnicalDetailsErrorCodeRowLabel, response.errorCode),
      (s.errorDetailsStatusLabel, response.statusCode?.toString()),
      (s.errorDetailsDescriptionLabel, response.humanReadableError),
      (s.errorDetailsServerLabel, response.errorFromServer),
      (
        s.genericErrorModalTechnicalDetailsExceptionRowLabel,
        response.caughtException?.toString()
      ),
    ]
        .where((row) => row.$2 != null && row.$2!.trim().isNotEmpty)
        .map((row) => (row.$1, row.$2!))
        .toList();
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final rows = _detailRows(s);
    final detailStyle = appModalBodyStyle(context, fontSize: 13);

    return AppStyleDialog(
      title: s.genericErrorModalHeader,
      onClose: () => Navigator.of(context).pop(),
      actions: [
        CustomButton(
          variant: CustomButtonVariant.AccentButton,
          label: s.ok,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            genericErrorMessageFor(response, s),
            style: appModalBodyStyle(context),
          ),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 10),
            Theme(
              // no divider lines around the expansion tile
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const ValueKey('genericErrorDetails'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 10),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                iconColor: theme.darkTextColor,
                collapsedIconColor: theme.darkTextColor,
                textColor: theme.darkTextColor,
                collapsedTextColor: theme.darkTextColor,
                title: Text(
                  s.genericErrorModalTechnicalDetailsHeader,
                  style: appModalBodyStyle(context, fontSize: 14)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: SingleChildScrollView(
                      child: SelectableText.rich(
                        TextSpan(
                          style: detailStyle,
                          children: [
                            for (final row in rows) ...[
                              TextSpan(
                                text: '${row.$1} ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: '${row.$2}\n'),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// ------------Cloned from the original package because the naviator is not exposed-----
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------

const double _kPreviousPageVisibleOffset = 10;

const Radius _kDefaultTopRadius = Radius.circular(12);
const BoxShadow _kDefaultBoxShadow =
    BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);

/// Cupertino Bottom Sheet Container
///
/// Clip the child widget to rectangle with top rounded corners and adds
/// top padding(+safe area padding). This padding [_kPreviousPageVisibleOffset]
/// is the height that will be displayed from previous route.
class _CupertinoBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Radius topRadius;
  final BoxShadow? shadow;

  const _CupertinoBottomSheetContainer({
    required this.child,
    this.backgroundColor,
    required this.topRadius,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    // final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    const topPadding = _kPreviousPageVisibleOffset; // + topSafeAreaPadding;

    final shadow = this.shadow ?? _kDefaultBoxShadow;
    const BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);
    final backgroundColor = this.backgroundColor ??
        CupertinoTheme.of(context).scaffoldBackgroundColor;
    return Padding(
      padding: const EdgeInsets.only(top: topPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: topRadius),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor, // backgroundColor
            boxShadow: [shadow],
          ),
          width: double.infinity,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true, //Remove top Safe Area
            child: CupertinoUserInterfaceLevel(
              data: CupertinoUserInterfaceLevelData.elevated,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> customShowCupertinoModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  Curve? previousRouteAnimationCurve,
  bool useRootNavigator = false,
  bool bounce = true,
  bool? isDismissible,
  bool enableDrag = true,
  Radius topRadius = _kDefaultTopRadius,
  Duration? duration,
  RouteSettings? settings,
  Color? transitionBackgroundColor,
  BoxShadow? shadow,
  SystemUiOverlayStyle? overlayStyle,
  double? closeProgressThreshold,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  assert(debugCheckHasMediaQuery(context));
  final hasMaterialLocalizations =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) !=
          null;
  final barrierLabel = hasMaterialLocalizations
      ? MaterialLocalizations.of(context).modalBarrierDismissLabel
      : '';

  var nav = overrideNavigatorKey?.currentState ?? navigatorKey.currentState!;

  final result = await nav.push(
    CupertinoModalBottomSheetRoute<T>(
        builder: builder,
        containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
              backgroundColor: backgroundColor,
              topRadius: topRadius,
              shadow: shadow,
              child: ThemeConfigurationForApp(child: child),
            ),
        secondAnimationController: secondAnimation,
        expanded: expand,
        closeProgressThreshold: closeProgressThreshold,
        barrierLabel: barrierLabel,
        elevation: elevation,
        bounce: bounce,
        shape: shape,
        clipBehavior: clipBehavior,
        isDismissible: isDismissible ?? expand == false ? true : false,
        modalBarrierColor: barrierColor ?? Colors.black12,
        enableDrag: enableDrag,
        topRadius: topRadius,
        animationCurve: animationCurve,
        previousRouteAnimationCurve: previousRouteAnimationCurve,
        duration: duration,
        settings: settings,
        transitionBackgroundColor: transitionBackgroundColor ?? Colors.black,
        overlayStyle: overlayStyle),
  );
  return result;
}
