import 'package:flutter/material.dart';

class KOverflowWidget extends StatelessWidget {
  const KOverflowWidget({
    super.key,
    this.height,
    required this.child,
  });
  final double? height;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height ?? 10,
      child: OverflowBox(
        maxWidth: MediaQuery.of(context).size.width,
        child: child,
      ),
    );
  }
}
