import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../components/color.dart';
import '../services/scriptlaunch.dart';
import '../utils/actionicon.dart'; // Adjust the import path for scriptlaunch.dart

class Home extends StatefulWidget {
  final String fileContents;
  final String fileName;
  const Home({
    super.key,
    required this.fileContents,
    required this.fileName,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, dynamic>> _actions = [];
  String selectedAction = '';
  String selectedLocatorType = 'id'; // Default locator type
  String selectedValue = '';
  String sendKeysValue = ''; // For `sendKeys` action
  int repeatCount = 1;
  bool isRunning = false;
  bool? isSuccessful;
  List<Map<String, dynamic>> _results = [];

  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Parse the passed JSON string into a list of actions
    _parseJson(widget.fileContents);
    _fileNameController.text = p.basenameWithoutExtension(widget.fileName);
    // Optionally, parse the passed file contents (if needed for other logic)
  }

  void _parseJson(String jsonString) {
    try {
      final parsedJson = jsonDecode(jsonString);

      if (parsedJson['steps'] != null) {
        List<dynamic> steps = parsedJson['steps'];

        for (var step in steps) {
          if (step['action'] == 'loop') {
            List<dynamic> nestedSteps = step['steps'] ?? [];
            _actions.add({
              'action': 'loop',
              'repeatCount': step['repeatCount'] ?? 1,
              'steps': nestedSteps
                  .map((nestedStep) => {
                        'action': nestedStep['action'],
                        'locatorType': nestedStep['locatorType'] ?? 'id',
                        'value': nestedStep['value'] ?? '',
                      })
                  .toList(),
            });
          } else {
            _addAction(step['action'], step['locatorType'] ?? 'id',
                step['value'] ?? '', step['keys']);
          }
        }
        print(_actions);
      }
    } catch (e) {
      print("Error parsing JSON: $e");
    }
  }

  void _addAction(String action, String locatorType, String value,
      [String? keys, bool isLoop = false]) {
    setState(() {
      if (isLoop) {
        // If it's a loop, add a loop container
        _actions.add({
          'action': 'loop',
          'repeatCount': repeatCount,
          'steps': [],
        });
      } else {
        // Otherwise, add a normal action
        if (action == 'sendKeys') {
          _actions.add({
            'action': action,
            'locatorType': locatorType,
            'value': value,
            'keys': keys,
          });
        } else {
          _actions.add({'action': action, 'value': value});
        }
      }
    });
  }

  void _removeAction(int index) {
    setState(() {
      _actions.removeAt(index);
    });
  }

  void _editAction(int index) {
    final action = _actions[index];
    setState(() {
      selectedAction = action['action'];
      selectedLocatorType =
          action['locatorType'] ?? 'id'; // Default to 'id' if no locatorType
      selectedValue = action['value'] ?? '';
      sendKeysValue = action['keys'] ?? ''; // Handle keys for `sendKeys`
      if (action['action'] == 'loop') {
        // Edit loop properties if action is a loop
        repeatCount = action['repeatCount'] ?? 1;
      }
    });
  }

  void _runAutomation() async {
    List<Map<String, dynamic>> formattedActions = [];

    for (var action in _actions) {
      if (action['action'] == 'loop') {
        formattedActions.add({
          'action': 'loop',
          'repeatCount': action['repeatCount'],
          'steps': action['steps']
                  ?.map((step) => {
                        'action': step['action'],
                        'locatorType': step['locatorType'],
                        'value': step['value'],
                        if (step.containsKey('keys')) 'keys': step['keys'],
                      })
                  .toList() ??
              [],
        });
      } else {
        formattedActions.add({
          'action': action['action'],
          'locatorType': action['locatorType'],
          'value': action['value'],
          if (action.containsKey('keys')) 'keys': action['keys'],
        });
      }
    }

    setState(() {
      isRunning = true;
      isSuccessful = null;
    });

    String automationJson = jsonEncode({'steps': formattedActions});

    // await runPythonScriptWithJson(automationJson, (results) {
    //   setState(() {
    //     isRunning = false;
    //     _results = results;
    //   });
    // });
    await runPythonScriptWithJson(automationJson, widget.fileName, (results) {
      setState(() {
        isRunning = false;
        if (results.isNotEmpty) {
          final stdout = results[0]['stdout'];
          if (stdout != null && stdout.isNotEmpty) {
            // Assuming the stdout is JSON, parse it
            try {
              final jsonResponse = jsonDecode(stdout);
              _results =
                  List<Map<String, dynamic>>.from(jsonResponse['results']);
            } catch (e) {
              _results = []; // Handle parsing error
              print("Error parsing stdout: $e");
            }
          } else {
            _results = [];
          }
        } else {
          _results = [];
        }
      });
    });

    print(_results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Panel for Actions List
          Container(
            color: Color(0xffffffff),
            width: 220,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: ReorderableListView(
                    onReorder: _onReorder,
                    children: [
                      for (int i = 0; i < _actions.length; i++)
                        if (_actions[i]['action'] == 'loop')
                          // Add a unique key for loop container
                          _buildLoopContainer(_actions[i], i)
                        else
                          // Normal action list item
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 2),
                            key: ValueKey(
                                'action_$i'), // Ensure ListTile has a unique key,
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(5)),
                            child: ListTile(
                              leading: Icon(
                                getActionIcon(_actions[i]['action']),
                                color: Colors.blue,
                              ),
                              title: Text('${_actions[i]['value']}'),
                              subtitle: _actions[i]['keys'] != null
                                  ? Text('Keys: ${_actions[i]['keys']}')
                                  : null,
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _removeAction(i),
                              ),
                              onTap: () => _editAction(i),
                            ),
                          ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showAddActionDialog(context);
                      },
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _addAction(
                          'loop',
                          selectedLocatorType,
                          selectedValue,
                          null,
                          true,
                        );
                      },
                      child: Text('Add Loop'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right Panel for Editing Selected Action
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: secondarycolor,
                    // border: Border.all(width: 0.5),
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isRunning) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      const Text('Running automation, please wait...'),
                    ] else if (_results.isNotEmpty) ...[
                      Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FixedColumnWidth(50.0), // Step column width
                          1: FixedColumnWidth(100.0), // Action column width
                          2: FixedColumnWidth(300.0), // Message column width
                          3: FixedColumnWidth(200.0), // Status column width
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(237, 239, 245, 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(width: 0.2)),
                            children: [
                              TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Step',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))),
                              TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Action',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))),
                              TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Message',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))),
                              TableCell(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Status',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Table(
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                columnWidths: const {
                                  0: FixedColumnWidth(
                                      50.0), // Step column width
                                  1: FixedColumnWidth(
                                      100.0), // Action column width
                                  2: FixedColumnWidth(
                                      300.0), // Message column width
                                  3: FixedColumnWidth(
                                      200.0), // Status column width
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(
                                          child: SizedBox(
                                        height: 10,
                                      )), // Empty cell for spacing
                                      TableCell(
                                          child: SizedBox(
                                        height: 10,
                                      )),
                                      TableCell(
                                          child: SizedBox(
                                        height: 10,
                                      )),
                                      TableCell(
                                          child: SizedBox(
                                        height: 10,
                                      )),
                                    ],
                                  ),
                                  // Table Rows based on the _results data
                                  for (var result in _results) ...[
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child:
                                                Text(result['step'].toString()),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                                result['action'] ?? 'Unknown'),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(result['message'] ??
                                                'No message'),
                                          ),
                                        ),
                                        // TableCell(
                                        //   child: Padding(
                                        //     padding: EdgeInsets.all(8.0),
                                        //     child: Text(
                                        //         result['status'] ?? 'Unknown'),
                                        //   ),
                                        // ),
                                        TableCell(
                                            child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 30.0),
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: result['status'] ==
                                                        'success'
                                                    ? Colors.green
                                                    : Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Center(
                                                child: Text(result['status'] ==
                                                        'success'
                                                    ? 'Success'
                                                    : 'Failed')),
                                          ),
                                        ))
                                      ],
                                    ),
                                    // Empty TableRow for spacing between rows
                                    TableRow(
                                      children: [
                                        TableCell(
                                            child: SizedBox(
                                                height:
                                                    10)), // Empty cell for spacing
                                        TableCell(child: SizedBox(height: 10)),
                                        TableCell(child: SizedBox(height: 10)),
                                        TableCell(child: SizedBox(height: 10)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(
                                height: 100,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            width: 150,
            child: TextField(
              controller: _fileNameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: InputBorder.none, // Removes the border
                enabledBorder: InputBorder.none, // Removes the enabled border
                focusedBorder: InputBorder.none, // Removes the focused border
                errorBorder: InputBorder.none, // Removes the error border
                disabledBorder: InputBorder.none, // Removes the disabled border
              ),
              readOnly: true,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
            onPressed: _runAutomation,
            child: Text('Run Automation'),
          ),
        ],
      ),
    );
  }

  void _showAddActionDialog(BuildContext context) {
    final TextEditingController valueController = TextEditingController();
    final TextEditingController keysController = TextEditingController();
    String tempAction = 'screenshot';
    String tempLocatorType = 'id';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add Action'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<String>(
                    value: tempAction,
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        tempAction = newValue!;
                      });
                    },
                    items: <String>[
                      'navigate',
                      'click',
                      'wait',
                      'screenshot',
                      'sendKeys',
                      'loop'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  if (tempAction == 'click' ||
                      tempAction == 'navigate' ||
                      tempAction == 'sendKeys')
                    DropdownButton<String>(
                      value: tempLocatorType,
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          tempLocatorType = newValue!;
                        });
                      },
                      items: <String>['id', 'xpath', 'css selector']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  TextField(
                    controller: valueController,
                    decoration: InputDecoration(
                        hintText: 'Enter value (e.g., URL, element)'),
                  ),
                  if (tempAction == 'sendKeys')
                    TextField(
                      controller: keysController,
                      decoration:
                          InputDecoration(hintText: 'Enter keys to send'),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addAction(
                      tempAction,
                      tempLocatorType,
                      valueController.text,
                      keysController.text,
                      tempAction == 'loop',
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _actions.removeAt(oldIndex);
      _actions.insert(newIndex, item);
    });
  }

  // Method to add a step to the loop
  void _addStepToLoop(int loopIndex, int stepIndex) {
    setState(() {
      Map<String, dynamic> loop = _actions[loopIndex];
      var step = _actions[stepIndex];
      loop['steps'].add(step); // Add step to the loop steps
    });
  }

  void deleteLoop(int index) {
    setState(() {
      _actions.removeAt(index);
    });
  }

  // Method to build loop container
  Widget _buildLoopContainer(Map<String, dynamic> loop, int index) {
    return GestureDetector(
      key: ValueKey('loop_$index'), // Unique key for the loop container
      onTap: () => _showAddStepDialog(index),
      child: Container(
        key: ValueKey('loop_container_$index'),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and repeat count input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Repeat ${loop['repeatCount']} times',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteLoop(index),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Wrap(
              runSpacing: 5,
              children: [
                for (var step in loop['steps'])
                  Chip(
                    label: Text(step['value'] ?? 'Unknown Action'),
                  ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            // Button to add a step to the loop
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddStepDialog(index),
                  child: Text('Add Step'),
                ),
                IconButton(
                  icon: Icon(Icons.loop),
                  onPressed: () => _showEditLoopDialog(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Method to edit loop number of repetitions
  void _showEditLoopDialog(int loopIndex) {
    final TextEditingController repeatController = TextEditingController(
        text: _actions[loopIndex]['repeatCount'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Loop Repetitions'),
          content: TextField(
            controller: repeatController,
            keyboardType: TextInputType.number,
            decoration:
                InputDecoration(hintText: 'Enter number of repetitions'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _actions[loopIndex]['repeatCount'] =
                      int.tryParse(repeatController.text) ?? 1;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

// Method to show add step dialog
  void _showAddStepDialog(int loopIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Step to Loop'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (int i = 0; i < _actions.length; i++)
                  if (_actions[i]['action'] != 'loop') // Skip loops
                    ListTile(
                      title: Text(_actions[i]['value']),
                      onTap: () {
                        _addStepToLoop(loopIndex, i);
                        Navigator.of(context).pop();
                      },
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
