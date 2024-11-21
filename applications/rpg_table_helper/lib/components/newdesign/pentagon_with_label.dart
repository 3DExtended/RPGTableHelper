import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:shadow_widget/shadow_widget.dart';

class PentagonWithLabel extends StatelessWidget {
  const PentagonWithLabel({
    super.key,
    required this.value,
    required this.otherValue,
    required this.label,
  });

  final int value;
  final int otherValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          ShadowWidget(
            offset: Offset(-4, 4),
            blurRadius: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pentagon Shape
                ClipPath(
                  clipper: _PentagonClipper(),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: darkColor,
                  ),
                ),
                // Text inside the pentagon
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      otherValue.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          AutoSizeText(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(fontSize: 14, color: darkTextColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            maxFontSize: 14,
            minFontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    path.moveTo(width * 0.5, 0); // Top point
    path.lineTo(width, height * 0.4); // Top-right corner
    path.lineTo(width * 0.8, height); // Bottom-right corner
    path.lineTo(width * 0.2, height); // Bottom-left corner
    path.lineTo(0, height * 0.4); // Top-left corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
