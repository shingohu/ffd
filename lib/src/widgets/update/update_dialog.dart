import 'package:dio/dio.dart';
import 'package:ffd/ffd.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'progress_btn.dart';

class UpdateWidget extends StatefulWidget {
  final String versionName;
  final String updateContent;
  final String downloadUrl;

  UpdateWidget({required this.versionName, required this.updateContent, required this.downloadUrl});

  @override
  _UpdateWidgetState createState() => _UpdateWidgetState();
}

class _UpdateWidgetState extends State<UpdateWidget> {
  late String versionName;
  late String updateContent;
  late String downloadUrl;
  bool isUpdate = false;

  @override
  void initState() {
    versionName = widget.versionName;
    updateContent = widget.updateContent;
    downloadUrl = widget.downloadUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Image.asset(
                  "images/update_bg_app_top.png",
                  fit: BoxFit.fitWidth,
                  package: "ffd",
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("新版本:", style: TextStyle(color: Colors.black)),
                        SizedBox(width: 10),
                        Expanded(child: Text(versionName, style: TextStyle(color: Colors.black)))
                      ],
                    ),
                    SizedBox(height: 15),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: size.height < 400 ? 200 : 400),
                      child: SingleChildScrollView(
                        child: Text(
                          updateContent +"\r",
                          maxLines: 100,
                          style: TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    !isUpdate ? updateBtn() : _DownloadWidget(downloadUrl),
                  ],
                ),
              ),
              SizedBox(height: 25),
              CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget updateBtn() {
    return CupertinoButton(
      onPressed: () {
        isUpdate = true;
        setState(() {});
      },
      padding: EdgeInsets.zero,
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
        child: Center(
            child: Text(
          "升级",
          style: TextStyle(color: Colors.white, fontSize: 17),
        )),
      ),
    );
  }
}

class _DownloadWidget extends StatefulWidget {
  final String downloadUrl;

  _DownloadWidget(this.downloadUrl);

  @override
  __DownloadWidgetState createState() => __DownloadWidgetState();
}

class __DownloadWidgetState extends State<_DownloadWidget> {
  late String downloadUrl;
  CancelToken? cancelToken;
  bool isDownloadSuccess = false;
  bool isDownloadFail = false;
  String? apkFilePath;

  ValueNotifier<double> progressVN = ValueNotifier<double>(0);

  @override
  void initState() {
    downloadUrl = widget.downloadUrl;
    download(downloadUrl);
    super.initState();
  }

  @override
  void dispose() {
    if (!isDownloadSuccess) {
      cancelToken?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isDownloadSuccess ? installWidget() : (isDownloadFail ? retryBtn() : progressBtn());
  }

  Widget retryBtn() {
    return CupertinoButton(
      onPressed: () {
        isDownloadFail = false;
        download(downloadUrl);
      },
      padding: EdgeInsets.zero,
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
        child: Center(
            child: Text(
          "升级失败,重试？",
          style: TextStyle(color: Colors.white, fontSize: 17),
        )),
      ),
    );
  }

  Widget progressBtn() {
    return CupertinoButton(
      onPressed: null,
      padding: EdgeInsets.zero,
      child: Container(
        height: 40,
        child: ValueListenableBuilder<double>(
          valueListenable: progressVN,
          builder: (ctx, value, child) {
            return LiquidLinearProgressIndicator(
              value: value,
              // Defaults to 0.5.
              valueColor: AlwaysStoppedAnimation(Colors.red),
              // Defaults to the current Theme's accentColor.
              backgroundColor: Colors.white,
              // Defaults to the current Theme's backgroundColor.
              borderColor: Colors.red,
              borderWidth: 1.5,
              borderRadius: 5,
              direction: Axis.horizontal,
              // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
              center: Text(
                (value * 100).toStringAsFixed(0) + "%",
                style: TextStyle(color: value > 0.55 ? Colors.white : Colors.black),
              ),
            );
          },
        ),
      ),
    );
  }

  void download(String url) async {
    if (cancelToken != null) {
      cancelToken!.cancel();
    }
    cancelToken = CancelToken();
    String dic = (await getExternalStorageDirectory())!.path + "/apk/";
    String filePath = dic + DateTime.now().millisecondsSinceEpoch.toString() + ".apk";
    try {
      Response response = await Dio().download(url, filePath, cancelToken: cancelToken, onReceiveProgress: (count, total) {
        if (total != -1) {
          progressVN.value = count / total;
        }
      });
      if (response.statusCode == 200) {
        isDownloadSuccess = true;
        apkFilePath = filePath;
        setState(() {});

        OpenFile.open(filePath);
      } else {
        isDownloadFail = true;
        setState(() {});
      }
    } catch (e) {
      isDownloadFail = true;
      setState(() {});
    }
  }

  Widget installWidget() {
    return CupertinoButton(
      onPressed: () {
        OpenFile.open(apkFilePath);
      },
      padding: EdgeInsets.zero,
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
        child: Center(
            child: Text(
          "安装",
          style: TextStyle(color: Colors.white, fontSize: 17),
        )),
      ),
    );
  }
}
