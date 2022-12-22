import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<List<String>> onWrite(
      String text, String urlData, String input) async {
    // Lấy path folder bookmart
    String fileName = "bookmart.txt";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    final File file = File(savePath);
    if (!(await File(savePath).exists())) {
      await file.create();
    }
    String textFileRead = await file.readAsString();
    List<String> listTextRaw = textFileRead.split("\n");
    // remove element rỗng
    List<String> newList = [];
    for (var element in listTextRaw) {
      if (element.isNotEmpty) {
        newList.add(element);
      }
    }

    // Write data ra file format ID(numberic)-->content<->url<-->input>>isDelete
    await file.writeAsString(
        (newList.length).toString() +
            "-->" +
            text +
            "<->" +
            urlData +
            "<-->" +
            input +
            ">>" +
            "false" +
            "\n",
        mode: FileMode.append);

    return newList;
  }
}
