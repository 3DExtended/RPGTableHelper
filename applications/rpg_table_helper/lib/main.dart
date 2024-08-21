import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/main_two_block_layout.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DependencyProvider(
      isMocked: false,
      child: MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Roboto',
          useMaterial3: true,
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 24,
          ),
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainTwoBlockLayout(
        navbarButtons: [
          NavbarButton(
            onPressed: () {},
            icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
          ),
          NavbarButton(
            onPressed: () {},
            icon: const FaIcon(FontAwesomeIcons.user),
          ),
          NavbarButton(
            onPressed: () {},
            icon: const FaIcon(FontAwesomeIcons.basketShopping),
          ),
          NavbarButton(
            onPressed: () {},
            icon: const FaIcon(FontAwesomeIcons.trowel),
          ),
          NavbarButton(
            onPressed: () {},
            icon: const FaIcon(FontAwesomeIcons.bookJournalWhills),
          ),
        ],
        content: Container(
          color: const Color.fromARGB(35, 29, 22, 22),
        ));
  }
}
