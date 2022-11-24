import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final int index;

  const ImageWidget({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 150,
        width: double.infinity,
        child: Card(
          child: Image.network(
            'https://picsum.photos/200',
            fit: BoxFit.cover,
          ),
        ),
      );
}
