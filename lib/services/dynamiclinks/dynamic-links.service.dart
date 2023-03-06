import 'package:Talkaboat/services/user/user.service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../injection/injector.dart';

class DynamicLinkUtils {
  static final userService = getIt<UserService>();
  static const REFERENCE_BASE_URL = "https://talkaboat.online/";
  static const REFERAL_QUERY_PARAM = "invitedBy";

  static Future<ShortDynamicLink> createDynamicLink(String url) async {
    String link = REFERENCE_BASE_URL + url; // it can be any url, it does not have to be an existing one
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://talkaboat.page.link', // uri prefix used for Dynamic Links in Firebase Console
      link: Uri.parse(link),
      androidParameters: AndroidParameters(
        packageName: 'com.aboat.talkaboat',
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(bundleId: 'com.aboat-entertainment.talkaboat'), // bundle ID for your app
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "Join Talkaboat Crypto Podcast App",
        description: "",
        imageUrl: Uri.parse("https://example.com/image.png"),
      ),
    );
    return await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  }

  static Future<Uri> createInvite() async {
    String url = "${REFERAL_QUERY_PARAM}=${userService.userInfo?.userName}"; // it can be any url, it does not have to be an existing one
    final refLink = (await createDynamicLink(url)).previewLink!;
    debugPrint("$refLink");
    return refLink;
  }

  static handleDynamicLink(context, PendingDynamicLinkData dynamicLink) async {
    final link = dynamicLink.link;
    if(link.queryParameters.containsKey(REFERAL_QUERY_PARAM)) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(REFERAL_QUERY_PARAM, link.queryParameters[REFERAL_QUERY_PARAM]!);
    }
  }
}