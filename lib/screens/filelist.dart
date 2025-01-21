import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../components/color.dart';
import 'home.dart';
import 'settings.dart';

class Filelist extends StatefulWidget {
  const Filelist({super.key});

  @override
  State<Filelist> createState() => _FilelistState();
}

class _FilelistState extends State<Filelist> {
  late Future<List<FileSystemEntity>> _files;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    _files = _getFilesInDirectory();
  }

  Future<List<FileSystemEntity>> _getFilesInDirectory() async {
    // Get the directory where the files are stored
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = '${directory.path}/AutoWeb';

    // Create a Directory object from the folderPath
    final folder = Directory(folderPath);

    // Ensure the folder exists before listing files
    if (await folder.exists()) {
      // List all files in the directory and filter only .json files
      final allFiles = folder.listSync(); // Get all files in the directory
      final jsonFiles = allFiles
          .where((file) => file is File && file.path.endsWith('.json'))
          .toList(); // Filter for .json files

      return jsonFiles;
    } else {
      // If folder doesn't exist, return an empty list
      return [];
    }
  }

  Future<void> _openFile(FileSystemEntity file) async {
    try {
      final fileContents = await File(file.path).readAsString();

      String fileNameWithoutExtension = p.basename(file.path);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            fileContents: fileContents,
            fileName: fileNameWithoutExtension,
          ),
        ),
      );
    } catch (e) {
      print("Error reading file: $e");
    }
  }

  Future<void> _createFile(String fileName) async {
    if (fileName.isEmpty) {
      // Show an error message if no file name is entered
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a file name')),
      );
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final folderPath = '${directory.path}/AutoWeb';

    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final newFile = File('${folder.path}/$fileName.json');

    // Create the file
    try {
      await newFile.create();
      setState(() {
        _files = _getFilesInDirectory(); // Refresh the file list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File "$fileName.txt" created')),
      );
    } catch (e) {
      print("Error creating file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create file')),
      );
    }
  }

  void _showCreateFileDialog() {
    final TextEditingController _fileNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Project'),
          content: TextField(
            controller: _fileNameController,
            decoration: InputDecoration(
              hintText: 'Enter Project name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final fileName = _fileNameController.text.trim();
                _createFile(fileName);
                Navigator.pop(
                    context); // Close the dialog after creating the file
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: secondarycolor, borderRadius: BorderRadius.circular(5)),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<FileSystemEntity>>(
                future: _files,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No files found.'));
                  } else {
                    List<FileSystemEntity> files = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 2,
                        crossAxisCount: 3,
                      ),
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        FileSystemEntity file = files[index];
                        return MouseRegion(
                          // onEnter: (_) => setState(() => isHovered = true),
                          // onExit: (_) => setState(() => isHovered = false),
                          child: GestureDetector(
                            onTap: () {
                              _openFile(
                                  file); // Open and parse the selected file
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1), // Shadow color
                                    blurRadius: 6, // Softness of the shadow
                                    offset: Offset(
                                        2, 4), // Horizontal and vertical offset
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  p.basenameWithoutExtension(
                                      file.uri.pathSegments.last),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton.filled(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
                (route) => false, // Remove all previous routes
              );
            },
            icon: Icon(Icons.settings),
          ),
          SizedBox(
            width: 10,
          ),
          IconButton.filled(
            onPressed: _showCreateFileDialog, // Show the dialog when clicked
            icon: Icon(Icons.add),
          ),
          // ElevatedButton.icon(
          //   onPressed: _showCreateFileDialog, // Show the dialog when clicked
          //   icon: Icon(Icons.add),
          //   label: Text('Add File'),
          // ),
        ],
      ),
    );
  }
}
