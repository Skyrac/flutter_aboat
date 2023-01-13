import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../themes/colors.dart';

class ClaimBottomSheet extends StatefulWidget {
  const ClaimBottomSheet({Key? key, required this.podcastId}) : super(key: key);
  final int podcastId;
  @override
  State<ClaimBottomSheet> createState() => _ClaimBottomSheetState();
}

class _ClaimBottomSheetState extends State<ClaimBottomSheet> {
  final podcastService = getIt<PodcastService>();
  var ownershipMethods = PodcastOwnershipMethods.UNDEFINED;
  var userService = getIt<UserService>();

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
                padding: const EdgeInsets.all(16),
                child: ListView(
                  controller: controller,
                  children: [
                    userService.isConnected
                        ? ownershipMethods == PodcastOwnershipMethods.UNDEFINED
                            ? FutureBuilder<PodcastOwnershipMethods>(
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    if (snapshot.hasError) {
                                      return const SizedBox();
                                    } else if (snapshot.hasData && snapshot.data != null) {
                                      var validMethods = snapshot.data!;
                                      return progressWithMethod(validMethods);
                                    }
                                  }
                                  return const Center(child: CircularProgressIndicator());
                                },
                                future: getPodcastOwnershipMethods(),
                              )
                            : progressWithMethod(ownershipMethods)
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                            child: Center(child: Text(AppLocalizations.of(context)!.ownership)),
                          ),
                  ],
                ))));
  }

  Future<PodcastOwnershipMethods> getPodcastOwnershipMethods() async {
    if (ownershipMethods == PodcastOwnershipMethods.UNDEFINED) {
      ownershipMethods = await podcastService.getPodcastOwnershipMethods(widget.podcastId);
    }
    return ownershipMethods;
  }

  Widget progressWithMethod(PodcastOwnershipMethods validMethods) {
    switch (validMethods) {
      case PodcastOwnershipMethods.KYC:
        return Padding(padding: const EdgeInsets.all(8.0), child: OnlyKYC());
      case PodcastOwnershipMethods.FULL:
        return Full();
      case PodcastOwnershipMethods.OWNED:
        return Owned();
      case PodcastOwnershipMethods.ERROR:
        return ShowError();
      case PodcastOwnershipMethods.UNDEFINED:
        return const SizedBox();
    }
  }

  Widget ShowError() {
    return Text(AppLocalizations.of(context)!.unableToFetchPodcast);
  }

  Widget Owned() {
    return Text(AppLocalizations.of(context)!.podcastIsVerified);
  }

  final emailInputController = TextEditingController();

  Widget Full() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(AppLocalizations.of(context)!.verifyByEMail, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(
            height: 10,
          ),
          Text(AppLocalizations.of(context)!.verifyYourPodcastOwnership, style: Theme.of(context).textTheme.bodyMedium),
          TextField(
              controller: emailInputController,
              decoration: InputDecoration(
                  hintText: "E-Mail",
                  labelText: "Podcast-Email in Feed",
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
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Card(
                      color: DefaultColors.primaryColor,
                      child: InkWell(
                        onTap: (() {
                          if (emailInputController.text.isEmpty) {
                            return;
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.email,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                AppLocalizations.of(context)!.requestVerification,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Card(
                      color: DefaultColors.primaryColor,
                      child: InkWell(
                        onTap: (() {}),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.pin,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                AppLocalizations.of(context)!.enterPIN,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          OnlyKYC()
        ],
      ),
    );
  }

  Widget OnlyKYC() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(AppLocalizations.of(context)!.verifyByKnowYourCustomer, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(
          height: 10,
        ),
        Text(AppLocalizations.of(context)!.methodKYC, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: DefaultColors.primaryColor,
                    child: InkWell(
                      onTap: (() async {
                        if (userService.userInfo != null &&
                            userService.userInfo!.userName != null &&
                            userService.userInfo!.userName!.isNotEmpty) {
                          await launchUrlString(
                              'https://verify-with.blockpass.org/?clientId=aboat_entertainment_ps_kyc&serviceName=Aboat+Entertainment+Private+Sale+KYC&env=prod&refId=${userService.userInfo!.userName!}',
                              mode: LaunchMode.externalApplication);
                        } else {
                          debugPrint("No Username given!");
                        }
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context)!.requestVerification,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: DefaultColors.primaryColor,
                    child: InkWell(
                      onTap: (() {
                        //1. Send Request Info to backend
                        //2. Backend checks if username is verified and hasn't requested verification before
                        //3. Backend sends notification to support team to verify ownership
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Colors.black,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context)!.verify,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
