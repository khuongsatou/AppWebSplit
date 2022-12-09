import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<List<String>> onWrite(
      String text, String urlData, String input) async {
    // Lấy path folder bookmart
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/bookmart.txt');
    String textFileRead = await file.readAsString();
    List<String> listTextRaw = textFileRead.split("\n");
    // print('${directory.path}/bookmart.txt');
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
