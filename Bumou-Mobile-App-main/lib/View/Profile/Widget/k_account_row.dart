import 'package:flutter/material.dart';

class KAccountRow extends StatelessWidget {
  const KAccountRow({super.key, required this.title, required this.body});
  final String title, body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
        ]),
        const SizedBox(height: 8),
      ],
    );
  }
}
