import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../themes/colors.dart';

class ClaimBottomSheet extends StatefulWidget {
  const ClaimBottomSheet({Key? key, required this.podcastId}) : super(key: key);
  final int podcastId;
  @override
  State<ClaimBottomSheet> createState() => _ClaimBottomSheetState();
}

class _ClaimBottomSheetState extends State<ClaimBottomSheet> {
  final podcastService = getIt<PodcastService>();
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
                padding: EdgeInsets.all(16),
              child: ListView(
                controller: controller,
                children: [
                  FutureBuilder<PodcastOwnershipMethods>(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return SizedBox();
                        } else if (snapshot.hasData &&
                            snapshot.data != null) {
                          var validMethods = snapshot.data!;
                          return progressWithMethod(validMethods);
                        }
                      }
                      return const Center(
                          child: CircularProgressIndicator());
                    },
                    future: podcastService.getPodcastOwnershipMethods(widget.podcastId),
                  ),
                ],

              ))));
  }

  Widget progressWithMethod(PodcastOwnershipMethods validMethods) {
    switch(validMethods) {
      case PodcastOwnershipMethods.KYC: return OnlyKYC();
      case PodcastOwnershipMethods.FULL: return Full();
      case PodcastOwnershipMethods.OWNED: return Owned();
      case PodcastOwnershipMethods.ERROR: return ShowError();
    }
  }

  Widget ShowError() {
    return Text("Unable to fetch podcast ownership data!");
  }

  Widget Owned() {
    return SizedBox();
  }

  Widget Full() {
    return SizedBox();
  }

  Widget OnlyKYC() {
    return SizedBox();
  }


}
