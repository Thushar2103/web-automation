import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/default.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      final win = appWindow;

      win.size = Size(900, 600);
      win.alignment = Alignment.center;
      win.show();
    });
  }

  final directory = await getApplicationDocumentsDirectory();
  final customHivePath =
      Directory('${directory.path}/AutoWeb'); // specify your folder name

  // Create the directory if it doesn't exist
  if (!await customHivePath.exists()) {
    await customHivePath.create(recursive: true);
  }

  // Initialize Hive with the custom path
  await Hive.initFlutter(customHivePath.path);

  // Open a box
  await Hive.openBox('settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WebAuto',
      theme: ThemeData(
        fontFamily: 'lexend',
        scaffoldBackgroundColor: Color(0xffffffff),
        dialogTheme: DialogTheme(
          shape:
              ContinuousRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
          elevation: WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(Color(0xff5b8dff)),
          foregroundColor: WidgetStatePropertyAll(Colors.white),
        )),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
          foregroundColor: WidgetStatePropertyAll(Colors.black),
        )),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              elevation: WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(Color(0xff5b8dff)),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
              textStyle: WidgetStatePropertyAll(
                  TextStyle(fontWeight: FontWeight.w600)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
              iconColor: WidgetStatePropertyAll(Colors.white)),
        ),
      ),
      home: Default(),
    );
  }
}
