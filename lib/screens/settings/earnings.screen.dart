import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/rewards/reward.model.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final userService = getIt<UserService>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              DefaultColors.primaryColor.shade900,
              DefaultColors.secondaryColor.shade900,
              DefaultColors.secondaryColor.shade900
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Scaffold(
            body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(title: const Text("Earnings"),),
              Expanded(child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text("Amount"))
                  ],
                  rows: generateDataRows(List.empty()),
                ),
              ))
            ])),
      ),
    );
  }

  generateDataRows(List<Reward> entries) {
    return List<DataRow>.generate(entries.length, (index) =>
      DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              // All rows will have the same selected color.
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.08);
              }
              // Even rows will have a grey color.
              if (index.isEven) {
                return Colors.grey.withOpacity(0.3);
              }
              return null; // Use default value for other states and odd rows.
            }),
            cells: <DataCell>[
              DataCell(Text("${entries[index].total}"))
            ],
      )
    );
  }
}
