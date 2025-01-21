import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:web_automation/components/color.dart';

class WindowsButton extends StatelessWidget {
  const WindowsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          // border: Border.all(),
          borderRadius: BorderRadius.circular(5),
          color: secondarycolor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _CustomButton(
            onPressed: appWindow.minimize,
            icon: Icons.remove, // Custom minimize icon
            // color: Colors.blue,
            hoverColor: Colors.lightBlue,
          ),
          _CustomButton(
            onPressed: () {
              if (appWindow.isMaximized) {
                appWindow.restore();
              } else {
                appWindow.maximize();
              }
            },
            icon: Icons.crop_square, // Custom maximize icon
            // color: Colors.green,
            hoverColor: Colors.lightGreen,
          ),
          _CustomButton(
            onPressed: appWindow.close,
            icon: Icons.close, // Custom close icon
            // color: Colors.red,
            hoverColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  // final Color color;
  final Color hoverColor;

  const _CustomButton({
    required this.onPressed,
    required this.icon,
    // required this.color,
    required this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 1.0),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.black,
          size: 16,
        ),
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.transparent)),
      ),
    );
  }
}


// Use iconbutton