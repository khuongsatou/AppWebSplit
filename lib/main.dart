import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/components/drawerEnd.dart';
import 'package:my_app/components/linerProgress.dart';
import 'package:my_app/components/search.dart';
import 'package:my_app/constraints/keyGlobal.dart';
import 'package:my_app/models/bookMart.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'components/webview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  final Completer<WebViewController> _controllerModal =
      Completer<WebViewController>();
  late TextEditingController _controllerTextEditing;
  late TextEditingController _controllerTextEditingModal;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controllerAnimProgress;
  late AnimationController _controllerAnimProgressModal;

  String textDefault = "";
  String url = "";
  late bool isVisible;
  late bool isVisibleModal;
  late bool isVisibleKeyBoard;
  late String? tempDrawer = KEYGLOBAL.top;
  late double _dy;
  late double _keyBoardPadding = 300;

  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();

    _controllerTextEditing = TextEditingController();
    _controllerTextEditingModal = TextEditingController();

    _controllerAnimProgress = AnimationController(
      value: 0,
      vsync: this,
    )..addListener(() {
        if (_controllerAnimProgress.isCompleted) {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              isVisible = false;
            });
          });
        }
        setState(() {
          isVisible = true;
        });
      });

    _controllerAnimProgressModal = AnimationController(
      value: 0,
      vsync: this,
    )..addListener(() {
        if (_controllerAnimProgressModal.isCompleted) {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              isVisibleModal = false;
            });
          });
        }
        setState(() {
          isVisibleModal = true;
        });
      });

    isVisible = false;
    isVisibleModal = false;
    isVisibleKeyBoard = false;

    _dy = 0.0;

    Future.delayed(Duration.zero, () {
      Size sizeScreen = MediaQuery.of(context).size;
      _dy = sizeScreen.height * 0.85;
    });

    var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    // print(
    //     'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      Future.delayed(const Duration(microseconds: 500), () {
        // print('Keyboard visibility update. Is visible: $visible ');
        setState(() {
          isVisibleKeyBoard = visible;
          _keyBoardPadding = 0;
        });
      });
    });
  }

  void onSubmit(text, [String? key]) {
    Completer<WebViewController> control =
        KEYGLOBAL.checkAreaWeb(key) ? _controller : _controllerModal;

    control.future.then((value) {
      setState(() {
        value
            .loadUrl(url = text.toString())
            .then((value) => print("Done"))
            .onError((error, stackTrace) => print("Error" + error.toString()));
      });
    }).onError((error, stackTrace) {
      print("error:" + error.toString());
    });
  }

  void onReload([String? key]) async {
    Completer<WebViewController> control =
        KEYGLOBAL.checkAreaWeb(key) ? _controller : _controllerModal;
    control.future.then((value) {
      setState(() {
        value.reload();
      });
    }).onError((error, stackTrace) {
      print("error:" + error.toString());
    });

    // print("Reload");
  }

  void onList([String? key]) async {
    try {
      setState(() {
        tempDrawer = key;
        _scaffoldKey.currentState?.openEndDrawer();
      });
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra vui lòng thử lại")),
      );
    }
  }

  Future<BookMart> onBookMart([String? key]) async {
    Completer<WebViewController> control =
        KEYGLOBAL.checkAreaWeb(key) ? _controller : _controllerModal;
    WebViewController webViewController = await control.future;
    final content =
        await webViewController.runJavascriptReturningResult("document.title");

    final url = await webViewController
        .runJavascriptReturningResult("window.location.href");

    return BookMart(0, content, url);
  }

  Future<void> onLink(BookMart bookMart, [String? key]) async {
    // cần làm thêm trả về giá trị
    // print(bookMart.url);
    Completer<WebViewController> control =
        KEYGLOBAL.checkAreaWeb(key) ? _controller : _controllerModal;

    control.future.then((value) {
      setState(() {
        value.loadUrl(url = bookMart.url.toString()).then((value) {
          if (KEYGLOBAL.checkAreaWeb(key)) {
            _controllerTextEditing.text = bookMart.input ?? "";
            return;
          }
          _controllerTextEditingModal.text = bookMart.input ?? "";
        });
      });
    }).onError((error, stackTrace) {
      print("error:" + error.toString());
    });
  }

  Future<void> onUpdateProgress(progress, [String? key]) async {
    if (KEYGLOBAL.checkAreaWeb(key)) {
      _controllerAnimProgress.value = progress / 100;
      return;
    }
    _controllerAnimProgressModal.value = progress / 100;
  }

  @override
  void dispose() {
    _controllerAnimProgress.dispose();
    _controllerAnimProgressModal.dispose();
    keyboardSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    EdgeInsets sizeSafe = MediaQuery.of(context).padding;
    double sizeKeyBoard = MediaQuery.of(context).viewInsets.bottom;
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: sizeSafe.top),
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SearchPage(
                          onSubmit: (t) => onSubmit(t, KEYGLOBAL.top),
                          onReload: () => onReload(KEYGLOBAL.top),
                          onList: () => onList(KEYGLOBAL.top),
                          onBookMart: () => onBookMart(KEYGLOBAL.top),
                          controllerTextEditing: _controllerTextEditing,
                        ),
                        LineProgress(
                            controller: _controllerAnimProgress,
                            isVisible: isVisible),
                        Expanded(
                          flex: 10,
                          child: WebViewAppPage(
                            url: url,
                            title: '',
                            controller: _controller,
                            onUpdateProgress: (v) =>
                                onUpdateProgress(v, KEYGLOBAL.top),
                          ),
                        ),
                      ],
                    ),
                    AnimatedPositioned(
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 100),
                      top: isVisibleKeyBoard
                          ? _keyBoardPadding + sizeSafe.top
                          : _dy,
                      child: Container(
                        height: size.height + sizeSafe.bottom + sizeSafe.top,
                        width: size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: const [
                            // BoxShadow(blurRadius: 4.0),
                            BoxShadow(
                                color: Colors.white, offset: Offset(0, -2)),
                            BoxShadow(
                                color: Colors.white, offset: Offset(0, 2)),
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, -2),
                                blurRadius: 4.0),
                            BoxShadow(
                                color: Colors.white, offset: Offset(-2, 2)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => print("hihi"),
                              onPanUpdate: (details) {
                                // value old + value y new. lên là - xuống là dương
                                double pixelOffset = _dy + details.delta.dy;
                                // nếu keyboard tắt thì ko cần về vị trí cũ

                                if (pixelOffset >= 0 && pixelOffset < 750) {
                                  setState(() {
                                    _dy = pixelOffset;
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                height: 14,
                                width: size.width,
                                child: Center(
                                  child: Container(
                                    height: 4,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              width: size.width,
                              child: SearchPage(
                                onSubmit: (t) => onSubmit(t, KEYGLOBAL.bottom),
                                onReload: () => onReload(KEYGLOBAL.bottom),
                                onList: () => onList(KEYGLOBAL.bottom),
                                onBookMart: () => onBookMart(KEYGLOBAL.bottom),
                                controllerTextEditing:
                                    _controllerTextEditingModal,
                              ),
                            ),
                            LineProgress(
                                controller: _controllerAnimProgressModal,
                                isVisible: isVisibleModal),
                            Container(
                              constraints: BoxConstraints.expand(
                                  width: size.width, height: size.height),
                              child: WebViewAppPage(
                                url: url,
                                title: '',
                                controller: _controllerModal,
                                onUpdateProgress: (v) =>
                                    onUpdateProgress(v, KEYGLOBAL.bottom),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
      endDrawer: DraweEndPage(
          onLink: (b, tempDrawerKey) => {
                onLink(b, tempDrawerKey),
              }),
      endDrawerEnableOpenDragGesture: false,
    );
  }
}
