import 'package:flutter/material.dart';

ShowSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium,
    ),
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 1, milliseconds: 500),
    dismissDirection: DismissDirection.vertical,
    backgroundColor: Theme.of(context).dialogBackgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 150, right: 20, left: 20),
  ));
}
