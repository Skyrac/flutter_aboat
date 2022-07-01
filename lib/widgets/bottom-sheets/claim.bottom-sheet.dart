import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class ClaimBottomSheet extends StatefulWidget {
  const ClaimBottomSheet({Key? key}) : super(key: key);

  @override
  State<ClaimBottomSheet> createState() => _ClaimBottomSheetState();
}

class _ClaimBottomSheetState extends State<ClaimBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.8,
        snap: true,
        expand: false,
        builder: (context, controller) => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 0, color: Colors.transparent),
                    gradient: LinearGradient(colors: [
                      DefaultColors.primaryColor.shade900,
                      DefaultColors.secondaryColor.shade900,
                      DefaultColors.secondaryColor.shade900
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                padding: EdgeInsets.all(16))));
  }
}
