import 'dart:convert';
import 'package:Talkaboat/configuration/dio.config.dart';
import 'package:flutter/material.dart';
import '../../models/smart/chain.model.dart';

class SmartContract {
  SmartContract._();
  static Future<List<Chain>> getChain() async {
    try {
      var response = await dio.get<String>('/v1/smart/chains');
      var l = jsonDecode(response.data!);
      List<Chain> chains = List<Chain>.from(l.map((model) => Chain.fromJson(model)));
      return chains;
    } catch (e) {
      debugPrint("$e");
    }
    return List.empty();
  }
}
