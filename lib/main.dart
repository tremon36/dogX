import 'package:dogx_ui/json_file_handler.dart';
import 'package:dogx_ui/reg_provider.dart';
import 'package:dogx_ui/register.dart';
import 'package:dogx_ui/register_list.dart';
import 'package:dogx_ui/ui_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {

  RegisterList.regList = await JsonFileHandler.readListFromJsonFile() as List<Register>;
  RegisterList.getSendData();

  runApp(ChangeNotifierProvider(
      create: (context) => RegProvider(),
      lazy: false,
      builder: ((context, child) => const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      // Use the default dark theme
      themeMode: ThemeMode.dark,
      // Use dark mode
      home: const UIpage(),
    );
  }
}
