// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// The empty classroom query.
// Thanks xidian-script and libxdauth!

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:watermeter/model/xidian_ids/empty_classroom.dart';
import 'package:watermeter/repository/xidian_ids/ehall/ehall_session.dart';

/// 空闲教室查询 4768402106681759
class EmptyClassroomSession extends EhallSession {
  String baseUrl = "https://ehall.xidian.edu.cn/jwapp/sys/kxjas/modules/kxjas";

  /// jxldm => 教学楼代码
  Map<String, String> buildingSetting(String jxldm) => {
        "name": "JXLDM",
        "caption": "教学楼代码",
        "builder": "equal",
        "linkOpt": "AND",
        "value": jxldm,
      };

  List<Map<String, String>> classroomSetting(String mcOrdm) => [
        {
          "name": "JASDM",
          "caption": "教室代码",
          "builder": "include",
          "linkOpt": "AND",
          "value": mcOrdm,
        },
        {
          "name": "JASMC",
          "caption": "教室名称",
          "builder": "include",
          "linkOpt": "OR",
          "value": mcOrdm,
        },
      ];

  /// This is the first function we need to execute
  Future<List<EmptyClassroomPlace>> getBuildingList() async {
    List<EmptyClassroomPlace> toReturn = [];
    developer.log("Ready to login the system.", name: "Ehall emptyClassroom");
    var firstPost = await useApp("4768402106681759");
    await dioEhall.get(firstPost);
    var data = await dioEhall.post("$baseUrl/jxlcx.do", data: {
      "*order": "+XXXQDM,+PX,+JXLDM",
    }).then((value) => value.data["datas"]["jxlcx"]["rows"]);
    for (var i in data) {
      toReturn.add(EmptyClassroomPlace(code: i["JXLDM"], name: i["JXLJC"]));
    }
    return toReturn;
  }

  /*
  Future<Map<String, String>> getType() async {
    Map<String, String> toReturn = {};
    var data = await dioEhall.post(
      "$baseUrl/ggzdpx.do",
      data: {"dicCode": '9955766', "order": '+DM'},
    ).then(
      (value) => value.data["datas"]["ggzdpx"]["rows"],
    );
    for (var i in data) {
      toReturn[i["DM"]] = i["MC"];
    }
    return toReturn;
  }
  */

  /// The function of search the buildings inside buildingCode.
  /// params:
  ///   [buildingCode]: the code defined in [getBuildingList].
  ///   [date]: A date string with [yyyy-mm-dd] pattern.
  ///   [semesterRange]: A year range in string. e.g. [2022-2023]
  ///   [semesterPart]: The part in the semester. Only allow 1 and 2
  Future<List<EmptyClassroomData>> searchData({
    required String buildingCode,
    required String date,
    required String semesterRange,
    required String semesterPart,
    required String searchParameter,
  }) async {
    (String, String) dateData = await dioEhall.post(
      "$baseUrl/rqzhzcjc.do",
      data: {
        "RQ": date,
        "XN": semesterRange,
        "XQ": semesterPart,
      },
    ).then(
      (value) => (
        value.data["datas"]["rqzhzcjc"]["ZC"].toString(),
        value.data["datas"]["rqzhzcjc"]["XQJ"].toString()
      ),
    );

    List<EmptyClassroomData> toReturn = [];

    await dioEhall.post("$baseUrl/cxjsqk.do", data: {
      "XNXQDM": "$semesterRange-$semesterPart",
      "ZC": dateData.$1,
      "XQ": dateData.$2,
      "querySetting": jsonEncode([
        buildingSetting(buildingCode),
        if (searchParameter.isNotEmpty) classroomSetting(searchParameter),
      ]),
      '*order': "+LC,+JASMC",
      'pageSize': 999,
      'pageNumber': 1,
    }).then((value) {
      for (var i in value.data["datas"]["cxjsqk"]["rows"]) {
        toReturn.add(
          EmptyClassroomData(
            name:
                i["JASMC"].toString().replaceAll('(', "\n").replaceAll(')', ""),
            isEmpty1To2: !i["JC1"].toString().contains("1_"),
            isEmpty3To4: !i["JC3"].toString().contains("1_"),
            isEmpty5To6: !i["JC5"].toString().contains("1_"),
            isEmpty7To8: !i["JC7"].toString().contains("1_"),
            isEmpty9To10: !i["JC9"].toString().contains("1_"),
          ),
        );
      }
    });
    return toReturn;
  }
}
