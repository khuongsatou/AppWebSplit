import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:my_app/constraints/keyGlobal.dart';
import 'package:my_app/models/bookMart.dart';
import 'package:path_provider/path_provider.dart';

class DraweEndPage extends StatefulWidget {
  DraweEndPage({Key? key, required this.onLink}) : super(key: key);

  late Function onLink;
  @override
  State<DraweEndPage> createState() => _DraweEndPageState();
}

class _DraweEndPageState extends State<DraweEndPage> {
  final List<BookMart> entries = <BookMart>[];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onRead();
      });
    } catch (err) {
      print("Không load được danh sách");
    }
  }

  // split (start,end)
  String subStringStartEnd(start, end, element) {
    final startIndex = element.indexOf(start);
    final endIndex = element.indexOf(end, startIndex + start.length);

    String content = element.substring(startIndex + start.length, endIndex);
    return content;
  }

  Future<void> onRead() async {
    String text = "";
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/bookmart.txt');
      text = await file.readAsString();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không mở được file")),
      );
    }
    List<String> listTextRaw = text.split("\n");

    const endID = "-->";
    const endContent = "<->";
    const endUrl = "<-->";
    const endInput = ">>";
    List<BookMart> newList = [];
    for (var element in listTextRaw) {
      if (element.isNotEmpty) {
        // split id
        final endIDIndex = element.indexOf(endID);
        final endUrlIndex = element.indexOf(endUrl);
        String id = element.substring(0, endIDIndex);
        // split content
        String content = subStringStartEnd(endID, endContent, element);

        // split url
        String url = subStringStartEnd(endContent, endUrl, element);
        // split input
        String input = subStringStartEnd(endUrl, endInput, element);
        // split isDelete
        String isDelete = element.substring(endUrlIndex);

        newList.add(BookMart(
          int.parse(id),
          content,
          url,
          isDelete == 'true',
          input,
        ));
      }
    }

    entries.clear();
    setState(
      () => {
        entries.addAll(newList),
      },
    );
  }

  void onConfirmDelete(int index) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/bookmart.txt');

    file.readAsLines().then((List<String> lines) async {
      lines.removeAt(index);
      final newTextData = lines.join('\n');
      await file
          .writeAsString(newTextData); // update the file with the new data
      await onRead();
    });
  }

  Future<void> showDialogDelete(int index) async {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: Text(
              'Xác nhận xóa!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Center(
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(seconds: 1), () {
                        onConfirmDelete(index);
                      });
                    },
                    child: const Center(
                      child: Text(
                        'Xóa',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void navLink(BookMart bookMart) {
    Navigator.pop(context);
  }

  Future<void> showModalOption(int index) async {
    // turn off drawable
    Navigator.of(context).pop();

    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              child: const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Trên',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(seconds: 1), () {
                  widget.onLink(entries[index], KEYGLOBAL.top);
                });
              },
            ),
            const Divider(color: Colors.black12),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(seconds: 1), () {
                  widget.onLink(entries[index], KEYGLOBAL.bottom);
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Dưới',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: SafeArea(
        child: entries.isEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Center(
                    child: Text('Không có dữ liệu'),
                  ),
                ],
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: entries.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onLongPress: () => showDialogDelete(index),
                    onTap: () => showModalOption(index),
                    child: Container(
                      color: (index + 1) % 2 != 0
                          ? const Color.fromRGBO(220, 230, 241, 0.5)
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entries[index].content.toString(),
                              style: const TextStyle(
                                  fontSize: 15.0,
                                  // height: 2,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
