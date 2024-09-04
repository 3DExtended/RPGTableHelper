import 'package:flutter/material.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

import '../../../helpers/modal_helpers.dart';

Future<RpgItem?> showCreateOrEditItemModal(
  BuildContext context,
  RpgItem itemToEdit,
) async {
  // show error to user
  await customShowCupertinoModalBottomSheet<RpgItem>(
    isDismissible: false,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: true,
    backgroundColor: const Color.fromARGB(137, 49, 49, 49),
    context: context,
    // barrierColor: const Color.fromARGB(20, 201, 201, 201),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(80.0),
      child: Container(
        color: Colors.red,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(21.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 7,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "S.of(context).newVersionModalHeader",
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontFamily: 'Pangram',
                              color: Colors.white,
                              fontSize: 32,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 42,
                ),
                Text(
                  "S.of(context).newVersionModalText",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(
                  height: 28 * 2,
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: YourshelfButton(
                //         isAccentColor: true,
                //         text: S.of(context).newVersionModalOpenAppStoreBtnLabel,
                //         onPressed: () {
                //           Future<void> openStore() async {
                //             String packageName = 'YourShelf';
                //             String appStoreUrl =
                //                 'https://apps.apple.com/us/app/yourshelf/id1658328816';
                //             String playStoreUrl =
                //                 'https://play.google.com/store/apps/details?id=$packageName';
                //             if (await canLaunch(appStoreUrl) &&
                //                 !Platform.isAndroid) {
                //               await launch(appStoreUrl);
                //             } else if (await canLaunch(playStoreUrl) &&
                //                 Platform.isAndroid) {
                //               await launch(playStoreUrl);
                //             } else {
                //               throw 'Could not launch store';
                //             }
                //           }
                //           openStore();
                //         },
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  return null;
}
