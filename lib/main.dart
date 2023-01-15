import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/components/drawerEnd.dart';
import 'package:my_app/components/linerProgress.dart';
import 'package:my_app/components/search.dart';
import 'package:my_app/components/webviewModal.dart';
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
  bool isVisible = false;
  bool isVisibleModal = false;
  bool isVisibleKeyBoard = false;
  late String? tempDrawer = KEYGLOBAL.top;
  double _dy = 0.0;

  late StreamSubscription<bool> keyboardSubscription;
  late bool isInitMain = false;

  @override
  void initState() {
    super.initState();
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Size sizeScreen = MediaQuery.of(context).size;
        if (!mounted) {
          return;
        }
        setState(() {
          _dy = sizeScreen.height * 0.5;
        });
      });
      // ignore: empty_catches
    } catch (err) {}

    _controllerTextEditing = TextEditingController();
    _controllerTextEditingModal = TextEditingController();

    _controllerAnimProgress = AnimationController(
      value: 0,
      vsync: this,
    )..addListener(() {
        if (_controllerAnimProgress.isCompleted) {
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) {
              return;
            }
            setState(() {
              isVisible = false;
            });
          });
        }
        if (!mounted) {
          return;
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
            if (!mounted) {
              return;
            }
            setState(() {
              isVisibleModal = false;
            });
          });
        }
        if (!mounted) {
          return;
        }
        setState(() {
          isVisibleModal = true;
        });
      });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        isInitMain = true;
      });
    });

    var keyboardVisibilityController = KeyboardVisibilityController();

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      Future.delayed(const Duration(microseconds: 500), () {
        if (!mounted) {
          return;
        }
        setState(() {
          isVisibleKeyBoard = visible;
        });
      });
    });
  }

  double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  void onSubmit(text, [String? key]) {
    Completer<WebViewController> control =
        KEYGLOBAL.checkAreaWeb(key) ? _controller : _controllerModal;

    control.future.then((value) {
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        value.reload();
      });
    }).onError((error, stackTrace) {
      print("error:" + error.toString());
    });
  }

  void onList([String? key]) async {
    try {
      if (!mounted) return;
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

    Completer<WebViewController> control =
        KEYGLOBAL.checkAreaWeb(key) ? _controller : _controllerModal;

    control.future.then((value) {
      if (!mounted) return;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    EdgeInsets sizeSafe = MediaQuery.of(context).padding;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Container(
            width: size.width,
            height: size.height,
            color: Colors.white,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  width: size.width,
                  height: size.width,
                  color: Colors.white,
                  child: const SizedBox.shrink(),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          height: sizeSafe.top,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SearchPage(
                            onSubmit: (t) => onSubmit(t, KEYGLOBAL.top),
                            onReload: () => onReload(KEYGLOBAL.top),
                            onList: () => onList(KEYGLOBAL.top),
                            onBookMart: () => onBookMart(KEYGLOBAL.top),
                            controllerTextEditing: _controllerTextEditing,
                          ),
                        ),
                        isInitMain
                            ? LineProgress(
                                controller: _controllerAnimProgress,
                                isVisible: isVisible)
                            : SizedBox.shrink(),
                        Expanded(
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
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                    child: Container(
                      height: _dy < size.height * 0.5 && isVisibleKeyBoard
                          ? getKeyboardHeight(context) +
                              73 // keyboard height + height container show
                          : _dy,
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: const [
                          // BoxShadow(blurRadius: 4.0),
                          BoxShadow(color: Colors.white, offset: Offset(0, -2)),
                          BoxShadow(color: Colors.white, offset: Offset(0, 2)),
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, -2),
                              blurRadius: 4.0),
                          BoxShadow(color: Colors.white, offset: Offset(-2, 2)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          GestureDetector(
                            onTap: () => print("hihi"),
                            onPanUpdate: (details) {
                              // value old + value y new. lên là - xuống là dương
                              double pixelOffset = _dy - details.delta.dy;
                              // nếu keyboard tắt thì ko cần về vị trí cũ

                              // if (pixelOffset >= 0 && pixelOffset < 750) {
                              if (pixelOffset >= 80 &&
                                  pixelOffset <= size.height * 0.95) {
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _dy = pixelOffset;
                                });
                                return;
                              }
                              if (pixelOffset <= 73) {
                                setState(() {
                                  _dy = 73.0;
                                });
                                return;
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    // color: Colors.red,
                                  ),
                                  height: 15,
                                  width: size.width,
                                  child: Center(
                                    child: Container(
                                      height: 4,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            width: size.width,
                            // color: Colors.green,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SearchPage(
                              onSubmit: (t) => onSubmit(t, KEYGLOBAL.bottom),
                              onReload: () => onReload(KEYGLOBAL.bottom),
                              onList: () => onList(KEYGLOBAL.bottom),
                              onBookMart: () => onBookMart(KEYGLOBAL.bottom),
                              controllerTextEditing:
                                  _controllerTextEditingModal,
                            ),
                          ),
                          isInitMain
                              ? LineProgress(
                                  controller: _controllerAnimProgressModal,
                                  isVisible: isVisibleModal)
                              : const SizedBox.shrink(),
                          Expanded(
                            child: WebViewAppModalPage(
                              url: url,
                              title: '',
                              controller: _controllerModal,
                              onUpdateProgress: (v) =>
                                  onUpdateProgress(v, KEYGLOBAL.bottom),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
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
