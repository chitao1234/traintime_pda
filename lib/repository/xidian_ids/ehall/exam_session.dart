// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// The exam source.
// Thanks xidian-script and libxdauth!

import 'dart:developer' as developer;
import 'package:watermeter/repository/xidian_ids/ehall/ehall_session.dart';

/// 考试安排 4768687067472349
class ExamFile extends EhallSession {
  Future<Map<String, dynamic>> get({
    String? semester,
  }) async {
    Map<String, dynamic> qResult = {};

    var firstPost = await useApp("4768687067472349");
    await dioEhall.get(firstPost);

    /// Get semester information.
    /// Hard to use, I would rather do it by myself.
    /// Nope, I need to choose~
    developer.log("Seek for the semesters", name: "getExam");
    var whatever = await dioEhall.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/xnxqcx.do",
      data: {"*order": "-PX,-DM"},
    );
    qResult["semester"] = whatever.data["datas"]["xnxqcx"]['rows'];

    /// wdksap 我的考试安排
    /// cxyxkwapkwdkc 查询已选课未安排考务的课程(正在安排中，不抓)
    /// If failed, it is more likely that no exam has arranged.
    developer.log(
        "My exam arrangemet ${semester ?? qResult["semester"][0]["DM"]}",
        name: "getExam");
    var data = await dioEhall.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/wdksap.do",
      queryParameters: {
        "XNXQDM": semester ?? qResult["semester"][0]["DM"],
        "*order": "-KSRQ,-KSSJMS"
      },
    ).then((value) => value.data["datas"]["wdksap"]);
    qResult["subjects"] = data["rows"];

    /// cxwapdksrw 查询未安排的考试任务
    /// cxyxkwapkwdkc 查询已选课未安排考务的课程(正在安排中，不抓)
    /// If failed, it is more likely that no exam has arranged.
    developer.log("Seek for the not arranged.", name: "getExam");
    data = await dioEhall.post(
      "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/cxyxkwapkwdkc.do",
      queryParameters: {"XNXQDM": semester ?? qResult["semester"][0]["DM"]},
    ).then((value) => value.data["datas"]["cxyxkwapkwdkc"]);
    qResult["tobearranged"] = data["rows"];

    return qResult;
  }
}
