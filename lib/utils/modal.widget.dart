import 'package:flutter/material.dart';

void showAlert(BuildContext context, TextEditingController controller,
    String title, String? label, String? hint, Function submitFunction) {
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
                  child: Text("Submit")),
              TextButton(
                  onPressed: (() {
                    Navigator.pop(context);
                  }),
                  child: Text("Cancel"))
            ],
          ));
}

void showAlertUserName(BuildContext context, TextEditingController controller,
    Function submitFunction) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Builder(builder: (context) {
        return Container(
          width: 150,
          height: 150,
          color: Colors.black12,
          child: Stack(alignment: Alignment.center, children: [
            Positioned(
              top: 200,
              child: Container(
                width: 300,
                height: 260,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromRGBO(48, 73, 123, 1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 5),
                      child: Center(
                          child: Text(
                        "Choose an username",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      )),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 23.5),
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text:
                              'Your username will be shown for in social media features as well as comments and ratings you might leave for podcasts and episodes.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ])),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      alignment: Alignment.center,
                      child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromRGBO(29, 40, 58, 1),
                              // ignore: prefer_const_literals_to_create_immutables
                              boxShadow: [
                                const BoxShadow(
                                  color: Color.fromRGBO(188, 140, 75, 1),
                                  spreadRadius: 0,
                                  blurRadius: 0,
                                  offset: Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: TextField(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Color.fromRGBO(164, 202, 255, 1),
                                    ),
                                controller: controller,
                                onSubmitted: (_) async {
                                  submitFunction();
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  alignLabelWithHint: true,
                                  hintText: "Username...",
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: const Color.fromRGBO(
                                              135, 135, 135, 1),
                                          fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RawMaterialButton(
                                  onPressed: () async {
                                    submitFunction();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        const BoxShadow(
                                          color: Colors.black45,
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                      color:
                                          const Color.fromRGBO(99, 163, 253, 1),
                                      border: Border.all(
                                          color: const Color.fromRGBO(
                                              188, 140, 75, 0.25),
                                          width: 1.0), //
                                    ),
                                    height: 40,
                                    width: 150,
                                    child: Center(
                                      child: Text(
                                        "Select",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                color: const Color.fromRGBO(
                                                    15, 23, 41, 1),
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                RawMaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        const BoxShadow(
                                          color: Colors.black45,
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                      color: const Color.fromRGBO(154, 0, 0, 1),
                                      border: Border.all(
                                          color: const Color.fromRGBO(
                                              188, 140, 75, 0.25),
                                          width: 1.0), //
                                    ),
                                    height: 40,
                                    width: 80,
                                    child: Center(
                                      child: Text(
                                        "Cancel",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                color: const Color.fromRGBO(
                                                    164, 202, 255, 1),
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                        ))
                  ],
                ),
              ),
            ),
          ]),
        );
      });
    },
  );
}
