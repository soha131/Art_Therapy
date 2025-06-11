import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/material.dart';
import 'models/Art_model.dart';

class ApiService {
  Future<ArtPrediction?> fetchDataFromApi(File file) async {
    if (!(await file.exists())) {
      Fluttertoast.showToast(msg: "Error: File does not exist");
      return null;
    }

    final box = Hive.box('settings');
    String langCode = box.get('language', defaultValue: 'en');

   final Uri url = Uri.parse(
        langCode == 'ar'
            ? "http://192.168.100.3:8000/predict_ar"
            : "http://192.168.100.3:8000/predict"
    );

  /*  final Uri url = Uri.parse(langCode == 'ar'
        ? "http://10.0.2.2:8000/predict_ar"
        : "http://10.0.2.2:8000/predict");*/

    try {
      var request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', file.path))
        ..headers.addAll({'Accept': 'application/json'});

      var streamedResponse = await request.send().timeout(Duration(seconds: 60));

      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 && responseBody.isNotEmpty) {
        final jsonData = json.decode(responseBody);
        return ArtPrediction.fromJson(jsonData);
      } else {
        Fluttertoast.showToast(msg: "API Error: ${streamedResponse.statusCode}");
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Request failed. Check connection.");
      return null;
    }
  }
}
