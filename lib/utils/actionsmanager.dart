// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../services/scriptlaunch.dart';

// class AutomationManager extends ChangeNotifier {
//   // Action and result data
//   List<Map<String, dynamic>> _actions = [];
//   List<Map<String, dynamic>> _results = [];
//   bool isRunning = false;
//   bool? isSuccessful;
//   int repeatCount = 1;
//   String selectedAction = '';
//   String selectedLocatorType = 'id';
//   String selectedValue = '';
//   String sendKeysValue = '';

//   // Getter functions to access the private variables
//   List<Map<String, dynamic>> get actions => _actions;
//   List<Map<String, dynamic>> get results => _results;

//   // Function to add an action to the list
//   void addAction(String action, String locatorType, String value,
//       [String? keys, bool isLoop = false]) {
//     if (isLoop) {
//       _actions.add({
//         'action': 'loop',
//         'repeatCount': repeatCount,
//         'steps': [],
//       });
//     } else {
//       if (action == 'sendKeys') {
//         _actions.add({
//           'action': action,
//           'locatorType': locatorType,
//           'value': value,
//           'keys': keys,
//         });
//       } else {
//         _actions.add({'action': action, 'value': value});
//       }
//     }
//     notifyListeners(); // Notify listeners when data changes
//     print(_actions);
//   }

//   // Function to remove an action at a specific index
//   void removeAction(int index) {
//     _actions.removeAt(index);
//     notifyListeners(); // Notify listeners
//   }

//   // Function to edit an action at a specific index
//   void editAction(int index) {
//     final action = _actions[index];
//     selectedAction = action['action'];
//     selectedLocatorType = action['locatorType'] ?? 'id'; // Default to 'id'
//     selectedValue = action['value'] ?? '';
//     sendKeysValue = action['keys'] ?? ''; // Handle keys for `sendKeys`
//     if (action['action'] == 'loop') {
//       repeatCount = action['repeatCount'] ?? 1;
//     }
//     notifyListeners(); // Notify listeners
//   }

//   // Function to run the automation, execute the actions in the list
//   Future<void> runAutomation() async {
//     List<Map<String, dynamic>> formattedActions = [];

//     for (var action in _actions) {
//       if (action['action'] == 'loop') {
//         formattedActions.add({
//           'action': 'loop',
//           'repeatCount': action['repeatCount'],
//           'steps': action['steps']
//                   ?.map((step) => {
//                         'action': step['action'],
//                         'locatorType': step['locatorType'],
//                         'value': step['value'],
//                         if (step.containsKey('keys')) 'keys': step['keys'],
//                       })
//                   .toList() ??
//               [],
//         });
//       } else {
//         formattedActions.add({
//           'action': action['action'],
//           'locatorType': action['locatorType'],
//           'value': action['value'],
//           if (action.containsKey('keys')) 'keys': action['keys'],
//         });
//       }
//     }

//     isRunning = true;
//     isSuccessful = null;
//     notifyListeners(); // Notify listeners when state changes

//     String automationJson = jsonEncode({'steps': formattedActions});

//     // Example placeholder for running the Python script with JSON data
//     await runPythonScriptWithJson(automationJson, ,(results) {
//       if (results.isNotEmpty) {
//         final stdout = results[0]['stdout'];
//         if (stdout != null && stdout.isNotEmpty) {
//           try {
//             final jsonResponse = jsonDecode(stdout);
//             _results = List<Map<String, dynamic>>.from(jsonResponse['results']);
//           } catch (e) {
//             _results = []; // Handle parsing error
//             print("Error parsing stdout: $e");
//           }
//         } else {
//           _results = [];
//         }
//       } else {
//         _results = [];
//       }

//       isRunning = false;
//       notifyListeners(); // Notify listeners after results are processed
//     });
//   }
// }
