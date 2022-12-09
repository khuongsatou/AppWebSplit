import 'package:flutter/material.dart';

class LineProgress extends StatefulWidget {
  LineProgress({Key? key, required this.controller, required this.isVisible})
      : super(key: key);

  AnimationController controller;
  bool isVisible;

  @override
  State<LineProgress> createState() => _LineProgressState();
}

class _LineProgressState extends State<LineProgress> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 8,
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2.0),
        child: widget.isVisible
            ? LinearProgressIndicator(
                value: widget.controller.value,
                semanticsLabel: 'Linear progress indicator',
              )
            : const SizedBox(),
      ),
    );
  }
}
