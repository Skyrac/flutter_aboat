import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/rewards/reward.model.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/rewards/reward-detail.model.dart';
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
            body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppBar(
            title: Text(AppLocalizations.of(context)!.earnings),
          ),
          FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                List<RewardDetail> listData = List.empty();
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Extracting data from snapshot object
                  listData = snapshot.data as List<RewardDetail>;
                }
                return Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text(AppLocalizations.of(context)!.date)),
                        DataColumn(label: Text(AppLocalizations.of(context)!.earned)),
                        DataColumn(label: Text(AppLocalizations.of(context)!.claimable)),
                        DataColumn(label: Text(AppLocalizations.of(context)!.description)),
                      ],
                      rows: generateDataRows(listData),
                    ),
                  ),
                ));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                  child: Text(
                "You don't have any bookmarked podcasts.\n\nYou can bookmark podcasts when searching by clicking the vertical aligned ... at the right side of each podcast.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ));
            },
            future: userService.getUserRewardDetails(),
          ),
        ])),
      ),
    );
  }

  generateDataRows(List<RewardDetail> entries) {
    return List<DataRow>.generate(
        entries.length,
        (index) => DataRow(
              color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
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
                DataCell(Text("${entries[index].getEarnDate()}")),
                DataCell(Text("${entries[index].amount?.round()}")),
                DataCell(Text("${entries[index].getUnlockDate()}")),
                DataCell(Text("${entries[index].description}")),
              ],
            ));
  }
}
