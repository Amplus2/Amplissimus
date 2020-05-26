import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart';

const String DSB_BUNDLE_ID = "de.heinekingmedia.dsbmobile";
const String DSB_DEVICE = "SM-G935F";
const String DSB_VERSION = "2.5.9";
const String DSB_OS_VERSION = "28 8.0";
const String DSB_LANGUAGE = "de";
const String DSB_WEBSERVICE = 'https://www.dsbmobile.de/JsonHandlerWeb.ashx/GetData';

enum DsbRequesttype {
  unknown,
  data,
  mail,
  feedback,
  subjects,
}

String removeLastChars(String s, int n) {
  return s.substring(0, s.length - n);
}

class DsbAccount {
  String username;
  String password;

  DsbAccount(this.username, this.password);

  Future<String> getData() async {
    String datetime = removeLastChars(DateTime.now().toIso8601String(), 3) + 'Z';
    String uuid = new Uuid().v4();
    String json = '{"UserId":"$username","UserPw":"$password","AppVersion":"$DSB_VERSION","Language":"$DSB_LANGUAGE","OsVersion":"$DSB_OS_VERSION","AppId":"$uuid","Device":"$DSB_DEVICE","BundleId":"$DSB_BUNDLE_ID","Date":"$datetime","LastUpdate":"$datetime"}';
    base64.encode(gzip.encode(utf8.encode(json)));
    Response res = await post(DSB_WEBSERVICE, body: '{"req": {"Data": "${base64.encode(gzip.encode(utf8.encode(json)))}", "DataType": 1}}');
    return res.body;
  }
}


