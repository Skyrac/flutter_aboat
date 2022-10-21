import 'package:flutter/material.dart';

void showAlert(BuildContext context, TextEditingController controller, String title, String? label, String? hint,
    Function submitFunction) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            title: Text(title),
            elevation: 8,
            content: TextField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: hint,
                    labelText: label,
                    labelStyle: Theme.of(context).textTheme.labelLarge,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ))),
            actions: [
              TextButton(
                  onPressed: (() async {
                    submitFunction();
                  }),
                  child: const Text("Submit")),
              TextButton(
                  onPressed: (() {
                    Navigator.pop(context);
                  }),
                  child: const Text("Cancel"))
            ],
          ));
}
