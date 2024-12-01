import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CraftingScreen extends ConsumerStatefulWidget {
  static String route = "crafting";

  const CraftingScreen({super.key});

  @override
  ConsumerState<CraftingScreen> createState() => _CraftingScreenState();
}

class _CraftingScreenState extends ConsumerState<CraftingScreen> {
  String? selectedCategory;
  String? selectedParentCategory;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
