import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:web_automation/screens/settings.dart';

import '../components/windows_button.dart';
import 'filelist.dart';
import 'home.dart';

class Default extends StatelessWidget {
  const Default({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ? AppBar(
                backgroundColor: Colors.transparent,
                forceMaterialTransparency: true,
                title: Text(
                  'WebAuto',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                toolbarHeight: 30,
                elevation: 0,
                scrolledUnderElevation: 0,
              )
            : MoveWindow(
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  forceMaterialTransparency: true,
                  title: Text(
                    'WebAuto',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  toolbarHeight: 50,
                  elevation: 0,
                  actions: [
                    IconButton.filled(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Default()),
                          (route) => false, // Remove all previous routes
                        );
                      },
                      icon: Icon(Icons.home_filled),
                    ),
                    if (Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS)
                      const WindowsButton(),
                  ],
                ),
              ),
      ),
      body: Navigator(
        initialRoute: '/filelist',
        onGenerateRoute: (settings) {
          if (settings.name == '/filelist') {
            return MaterialPageRoute(
              builder: (_) {
                // _updateRoute('/filelist');
                return const Filelist();
              },
            );
          } else if (settings.name == '/home') {
            return MaterialPageRoute(
              builder: (_) {
                // _updateRoute('/home');
                return Home(
                  fileContents: '',
                  fileName: '',
                );
              },
            );
          } else if (settings.name == '/settings') {
            return MaterialPageRoute(
              builder: (_) {
                // _updateRoute('/home');
                return Settings();
              },
            );
          }
          return null;
        },
      ),
    );
  }
}
