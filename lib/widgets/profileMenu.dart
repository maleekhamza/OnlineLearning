import 'package:flutter/material.dart';


class ProfileMenuWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color textColor;
  final IconData endIcon;
  final Function onPress;

  ProfileMenuWidget({
    required this.title,
    required this.icon,
    required this.textColor,
    required this.endIcon,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress();
      },
      child: Card(
        color: Color.fromARGB(255, 235, 237, 240),
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: textColor),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
              Icon(endIcon, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}