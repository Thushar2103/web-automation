import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late Box settingsBox;
  String? envFolderPath;
  String? pythonFilePath;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    final directory = await getApplicationDocumentsDirectory();
    final customFolderPath = Directory('${directory.path}/AutoWeb');

    if (!await customFolderPath.exists()) {
      await customFolderPath.create(recursive: true);
    }

    await Hive.initFlutter(customFolderPath.path);
    settingsBox = await Hive.openBox('settings');
    envFolderPath = settingsBox.get('envFolderPath');
    pythonFilePath = settingsBox.get('pythonFilePath');
    setState(() {});
  }

  Future<void> _pickEnvFolder() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      if (directoryPath.endsWith('env')) {
        settingsBox.put('envFolderPath', directoryPath);

        setState(() {
          envFolderPath = directoryPath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected folder: $directoryPath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the "env" folder')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No directory selected')),
      );
    }
  }

  Future<void> _pickPythonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['py'],
    );

    if (result != null && result.files.isNotEmpty) {
      String selectedFilePath = result.files.single.path!;

      settingsBox.put('pythonFilePath', selectedFilePath);

      setState(() {
        pythonFilePath = selectedFilePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Python file selected at: $selectedFilePath')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Python file selected')),
      );
    }
  }

  void _deleteEnvFolder() {
    settingsBox.delete('envFolderPath');
    setState(() {
      envFolderPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('"env" folder selection deleted')),
    );
  }

  void _deletePythonFile() {
    settingsBox.delete('pythonFilePath');
    setState(() {
      pythonFilePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Python file selection deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 40),
          ),
          Card(
            elevation: 0,
            color: Color(0xFFf4f5f9),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Added Path',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (envFolderPath == null)
                        ElevatedButton(
                          onPressed: _pickEnvFolder,
                          child: const Text('Pick "env" Folder'),
                        ),
                      if (pythonFilePath == null) ...[
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _pickPythonFile,
                          child: const Text('Pick Python File'),
                        ),
                      ]
                    ],
                  ),
                  if (envFolderPath != null)
                    ListTile(
                      title: Text(
                        'Selected env folder:',
                      ),
                      subtitle: Text(
                        envFolderPath!,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _deleteEnvFolder,
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.red)),
                      ),
                    ),
                  if (pythonFilePath != null)
                    ListTile(
                      title: Text(
                        'Selected Py file:',
                      ),
                      subtitle: Text(
                        pythonFilePath!,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _deletePythonFile,
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.red)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
