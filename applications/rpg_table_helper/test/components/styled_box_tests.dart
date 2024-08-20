// import 'package:flutter/widgets.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:rpg_table_helper/components/styled_box.dart';
// import 'package:rpg_table_helper/services/dependency_provider.dart';

// import '../test_configuration.dart';

// void main() {
//   group('StyledBox rendering', () {
//     testConfigurations(
//       disableLocals: true,
//       widgetName: 'StyledBox solo',
//       useMaterialAppWrapper: true,
//       screenFactory: (Locale locale) => const StyledBox(
//         child: Text('This is a test'),
//       ),
//       getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
//         MapEntry(
//           'default',
//           DependencyProvider.getMockedDependecyProvider(
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   widgetToTest,
//                 ],
//               ),
//             ),
//           ),
//         ),
//         MapEntry(
//           'expanded',
//           DependencyProvider.getMockedDependecyProvider(
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(child: widgetToTest),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ]),
//     );
//   });
// }
