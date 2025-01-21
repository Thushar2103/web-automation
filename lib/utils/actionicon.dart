import 'package:flutter/material.dart';

IconData getActionIcon(String action) {
  switch (action) {
    case 'navigate':
      return Icons.directions;
    case 'click':
      return Icons.mouse;
    case 'sendKeys':
      return Icons.keyboard; // Icon for sendKeys actions
    case 'wait':
      return Icons.timer;
    case 'loop':
      return Icons.loop; // Icon for loops
    default:
      return Icons.help_outline;
  }
}
