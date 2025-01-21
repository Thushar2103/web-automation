import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';

// Future<void> runPythonScriptWithJson(String automationJson, String filename,
//     Function(List<Map<String, dynamic>>) onComplete) async {
//   try {
//     final directory = await getApplicationDocumentsDirectory();
//     final folderPath = '${directory.path}/AutoWeb';

//     final folder = Directory(folderPath);
//     if (!await folder.exists()) {
//       await folder.create(recursive: true);
//     }

//     final file = File('$folderPath/$filename');
//     await file.writeAsString(automationJson);

//     final shell = Shell();
//     final command =
//         'call assets/env/Scripts/activate && python assets/automate.py ${file.path}';

//     final result = await shell.run(command);

//     List<Map<String, dynamic>> results = [];
//     for (var res in result) {
//       print('STDOUT: ${res.stdout}');
//       print('STDERR: ${res.stderr}');
//       results.add({
//         'stdout': res.stdout,
//         'stderr': res.stderr,
//         'status': res.exitCode == 0 ? 'Success' : 'Failure',
//       });
//     }

//     onComplete(results); // Pass back the results
//   } catch (e) {
//     print('Error running Python script: $e');
//     onComplete([
//       {
//         'stdout': 'Error running script',
//         'stderr': e.toString(),
//         'status': 'Failure',
//       }
//     ]);
//   }
// }

// import 'dart:io';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:process_run/process_run.dart';

Future<void> runPythonScriptWithJson(String automationJson, String filename,
    Function(List<Map<String, dynamic>>) onComplete) async {
  try {
    // Get the application documents directory and the path from Hive
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = '${directory.path}/AutoWeb';

    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    // Write the automation JSON to a temporary file
    final file = File('$folderPath/$filename');
    await file.writeAsString(automationJson);

    // Retrieve the environment folder path from Hive (assuming 'envFolderPath' is saved in Hive)
    Box settingsBox = await Hive.openBox('settings');
    String? envFolderPath =
        settingsBox.get('envFolderPath'); // Get the saved env folder path
    String? pyFilePath = settingsBox.get('pythonFilePath');

    if (envFolderPath == null) {
      // If the environment path is not found, return an error
      throw Exception('Environment folder path not found in Hive');
    }

    // Escape the file paths with spaces by enclosing them in double quotes
    final envFolderPathQuoted = '"$envFolderPath"';
    final pyFilePathQuoted =
        '"$pyFilePath"'; // Ensure python file path is quoted

    // Build the Python command using the retrieved env folder path
    final command =
        'call $envFolderPathQuoted/Scripts/activate && python $pyFilePathQuoted "${file.path}"';

    // Run the Python script using the command
    final shell = Shell();
    final result = await shell.run(command);

    // Process the results
    List<Map<String, dynamic>> results = [];
    for (var res in result) {
      print('STDOUT: ${res.stdout}');
      print('STDERR: ${res.stderr}');
      results.add({
        'stdout': res.stdout,
        'stderr': res.stderr,
        'status': res.exitCode == 0 ? 'Success' : 'Failure',
      });
    }

    onComplete(results); // Pass back the results
  } catch (e) {
    print('Error running Python script: $e');
    onComplete([
      {
        'stdout': 'Error running script',
        'stderr': e.toString(),
        'status': 'Failure',
      }
    ]);
  }
}
