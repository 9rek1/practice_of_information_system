import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:health/health.dart';

import '../top_view.dart';
import '../../models/user_model.dart';

class CameraButton extends StatelessWidget {
  CameraButton({Key? key}) : super(key: key);

  final _picker = ImagePicker();

  Future _getBase64Image() async {
    String? base64Image;
    File? pickedImage;
    // ignore: deprecated_member_use
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImage = File(pickedFile.path);
      Uint8List imageBytes = pickedImage.readAsBytesSync();
      List<int> compressedImage = await _compressImageBytes(imageBytes);
      base64Image = base64Encode(compressedImage);
      String datetime = await _getDateTimeFromImageBytes(imageBytes);
      print(datetime);
    }
    return base64Image;
  }

  Future _compressImageBytes(Uint8List imageBytes) async {
    List? result = await FlutterImageCompress.compressWithList(
      imageBytes,
      minHeight: 600,
      minWidth: 600,
    );
    return result;
  }

  Future<String> _getDateTimeFromImageBytes(List<int> imageBytes) async {
    final tags = await readExifFromBytes(imageBytes);
    return tags["Image DateTime"].toString();
  }

  Future _postImage(int id) async {
    final base64Image = await _getBase64Image();
    if (base64Image == null) {
      print("err");
      return null;
    }
    String url = "http://localhost:8000/image";
    final steps = await _fetchStepData();
    Map<String, String> headers = {"content-type": "application/json"};
    final obj = {"userId": id, "imageBase64": base64Image, "step": steps};
    String body = json.encode(obj);

    http.Response res =
        await http.post(Uri.parse(url), headers: headers, body: body);
    return res;
  }

  Future _updateStatus(int id) async {
    // resのステータスチェック
    //   if (res.statusCode != 200) {
    final res = await _postImage(id);
    if (res == null) return null;
    final user = User.fromJson(json.decode(res.body));
    print(user);
    return user;
  }

  final HealthFactory health = HealthFactory();

  Future _fetchStepData() async {
    int? steps = 0;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health.getTotalStepsInInterval(yesterday, now);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');
      return steps ?? 0;
    } else {
      print("Authorization not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final notifier = ref.read(topPageProvider.notifier);
      return Center(
        child: FloatingActionButton(
            onPressed: (() {
              notifier.startLoading();
              _updateStatus(notifier.state.id)
                  .then((user) => notifier.updateStatus(user.status,
                      user.stapleValue, user.mainValue, user.sideValue))
                  .whenComplete(() => notifier.stopLoading());
              // 例外処理
            }),
            child: Icon(Icons.camera)),
      );
    });
  }
}
