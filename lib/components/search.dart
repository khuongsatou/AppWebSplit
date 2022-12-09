import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/models/bookMart.dart';
import 'package:my_app/utils/fileUtils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SearchPage extends StatefulWidget {
  SearchPage(
      {Key? key,
      required this.onSubmit,
      required this.onReload,
      required this.onList,
      required this.onBookMart,
      required this.controllerTextEditing})
      : super(key: key);

  late Function onSubmit, onReload, onList, onBookMart;
  late TextEditingController controllerTextEditing;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final regex = RegExp(
      r'[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');

  late bool isVisibleCancel;
  late final FocusNode _focus;
  @override
  void initState() {
    // TODO: implement initState
    isVisibleCancel = false;
    _focus = FocusNode()..addListener(_onFocusChange);
    super.initState();
  }

  void onWrite() async {
    String textInput = widget.controllerTextEditing.text.trim();
    if (textInput.isNotEmpty) {
      BookMart bookMart = await widget.onBookMart();
      bookMart.input = textInput;
      if (bookMart.content.isNotEmpty) {
        FileUtils.onWrite(bookMart.content, bookMart.url, bookMart.input ?? "");
        print("DONE");
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không có dữ liệu')),
    );
  }

  void _onFocusChange() {
    setState(() {
      isVisibleCancel = _focus.hasFocus;
    });
  }

  @override
  void dispose() {
    widget.controllerTextEditing.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: widget.controllerTextEditing,
                onChanged: (text) {},
                focusNode: _focus,
                style: const TextStyle(
                  fontSize: 15.0,
                  height: 1.3,
                  color: Colors.black,
                ),
                maxLines: 1,
                maxLength: 50,
                cursorColor: const Color.fromARGB(126, 150, 148, 148),
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    splashColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 25.0),
                    onPressed: () {
                      onWrite();
                    },
                    icon: const Icon(
                      Icons.star_border_rounded,
                      color: Color.fromARGB(126, 150, 148, 148),
                      size: 28.0,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(237, 237, 237, 1),
                      width: 0,
                      style: BorderStyle.none,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(237, 237, 237, 1),
                      width: 0,
                      style: BorderStyle.none,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: const Color.fromRGBO(237, 237, 237, 1),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(0.0),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(237, 237, 237, 1),
                      width: 0,
                      style: BorderStyle.none,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  labelText: 'Search or type a URL',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 149, 145, 145),
                  ),
                  counterText: "",
                  suffixIcon: Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        IconButton(
                          splashColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 25.0),
                          onPressed: () {
                            widget.controllerTextEditing.clear();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color.fromRGBO(50, 50, 45, 1),
                            size: 20.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: IconButton(
                            splashColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 25),
                            onPressed: () => widget.onReload(),
                            icon: const Icon(
                              Icons.restart_alt_sharp,
                              color: Color.fromRGBO(50, 50, 45, 1),
                              size: 22.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: IconButton(
                            splashColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28),
                            onPressed: () => widget.onList(),
                            icon: const Icon(
                              Icons.list_rounded,
                              color: Color.fromRGBO(50, 50, 45, 1),
                              size: 24.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onSubmitted: (String value) async {
                  String valueCheck = value.toString().trim();
                  if (regex.hasMatch(valueCheck)) {
                    widget.onSubmit('https://${valueCheck.toString().trim()}');
                  } else {
                    widget.onSubmit(
                        'https://www.google.com/search?q=${valueCheck.toString().trim().replaceAll(" ", "+")}');
                  }
                },
              ),
            ),
          ),
          isVisibleCancel
              ? GestureDetector(
                  onTap: () {
                    widget.controllerTextEditing.clear();
                    setState(() {
                      isVisibleCancel = false;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue),
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}
