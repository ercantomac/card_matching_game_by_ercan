import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card-Matching Game by Ercan',
      themeMode: ThemeMode.dark,
      color: Colors.black,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      home: const HomePage(),
    );
  }
}

class MyRoute extends CupertinoPageRoute {
  MyRoute({dynamic builder}) : super(builder: builder);
  @override
  Duration get transitionDuration => const Duration(milliseconds: 700);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static String _theme = 'dark';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _difficulties = <String>['EASY', 'CASUAL', 'VETERAN'], _bestTime = <String>['-', '-', '-'];

  late Color _complementColor;

  late double _responsiveCoefficient;

  final List<Color> _color2 = <Color>[const Color(0xFF2979FF), const Color(0xFFFFD700), const Color(0xFFFF4500)];

  final List<ValueNotifier<double>> _scale = <ValueNotifier<double>>[ValueNotifier<double>(1.0), ValueNotifier<double>(1.0), ValueNotifier<double>(1.0)];

  void _getTimes() async {
    SharedPreferences _sp = await SharedPreferences.getInstance();
    if (_sp.getString('easyBestTime') != null) {
      _bestTime[0] = '${_sp.getString('easyBestTime')!} seconds.';
    }
    if (_sp.getString('casualBestTime') != null) {
      _bestTime[1] = '${_sp.getString('casualBestTime')!} seconds.';
    }
    if (_sp.getString('veteranBestTime') != null) {
      _bestTime[2] = '${_sp.getString('veteranBestTime')!} seconds.';
    }
    if (_sp.getString('Theme') == 'light' && HomePage._theme != 'light') {
      _changeTheme();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getTimes();
  }

  void _changeTheme() async {
    setState(() {
      HomePage._theme = (HomePage._theme == 'dark') ? 'light' : 'dark';
    });
    SharedPreferences _sp = await SharedPreferences.getInstance();
    _sp.setString('Theme', HomePage._theme);
  }

  @override
  Widget build(BuildContext context) {
    _responsiveCoefficient = sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height);
    _complementColor = (HomePage._theme == 'dark') ? const Color(0xFFBDBDBD) : const Color(0xFF212121);
    return Scaffold(
      backgroundColor: (HomePage._theme == 'dark') ? const Color(0xFF212121) : const Color(0xFFBDBDBD),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Text(
                  'SELECT DIFFICULTY',
                  style: TextStyle(
                    fontSize: _responsiveCoefficient / pow(4.5, 2),
                    color: (HomePage._theme == 'dark') ? Colors.white : const Color(0xFF212121),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <ValueListenableBuilder<double>>[
                    for (int index = 0; index < _difficulties.length; index++)
                      ValueListenableBuilder<double>(
                        valueListenable: _scale[index],
                        builder: (BuildContext context, double scale, Widget? child) {
                          return AnimatedContainer(
                            margin: EdgeInsets.only(bottom: (scale == 1.0) ? 0.0 : 32.0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutQuart,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                InkWell(
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                        MyRoute(builder: (_) => Game((index + 4), ((index == 2) ? 5 : 4), _color2[index], _difficulties[index])));
                                  },
                                  onHover: (bool value) {
                                    if (value == true) {
                                      _scale[index].value = 1.15;
                                    } else {
                                      _scale[index].value = 1.0;
                                    }
                                  },
                                  child: AnimatedContainer(
                                    padding:
                                        EdgeInsets.symmetric(vertical: _responsiveCoefficient / pow(6.5, 2), horizontal: _responsiveCoefficient / pow(5.5, 2)),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.elasticOut,
                                    transform: Matrix4.identity()..scale(scale),
                                    transformAlignment: Alignment.bottomCenter,
                                    decoration: BoxDecoration(
                                      color: (scale == 1.0) ? _complementColor : _color2[index],
                                      borderRadius: BorderRadius.all(Radius.circular((scale == 1.0) ? 36.0 : 10.0)),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          blurRadius: 12.0,
                                          spreadRadius: 3.0,
                                          color: (scale == 1.0) ? _complementColor.withOpacity(0.4) : _color2[index].withOpacity(0.4),
                                        )
                                      ],
                                    ),
                                    child: child,
                                  ),
                                ),
                                const SizedBox(height: 36.0),
                                AnimatedOpacity(
                                  opacity: (scale == 1.0) ? 0.0 : 1.0,
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeInOut,
                                  child: Text(
                                    'BEST: ${_bestTime[index]}',
                                    style: TextStyle(
                                      color: _color2[index],
                                      fontSize: _responsiveCoefficient / pow(6.5, 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            _difficulties[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _responsiveCoefficient / pow(5, 2),
                              color: (HomePage._theme == 'dark') ? const Color(0xFF212121) : Colors.white,
                              shadows: const <Shadow>[
                                Shadow(
                                  offset: Offset(0.0, 1.0),
                                  blurRadius: 1.5,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            top: 12.0,
            right: 0.0,
            child: FloatingActionButton.extended(
              backgroundColor: (HomePage._theme == 'dark') ? Colors.black : Colors.white,
              elevation: 3.0,
              hoverElevation: 8.0,
              onPressed: () {
                _changeTheme();
              },
              label: Text(
                HomePage._theme.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  letterSpacing: 0.0,
                  color: _complementColor,
                  fontSize: _responsiveCoefficient / pow(6.5, 2),
                ),
              ),
              icon: Icon(
                (HomePage._theme == 'dark') ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                color: _complementColor,
                size: _responsiveCoefficient / 25,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

class Game extends StatefulWidget {
  final int sizeX, sizeY;
  final Color _color1;
  final String _difficulty;
  const Game(this.sizeX, this.sizeY, this._color1, this._difficulty, {Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with TickerProviderStateMixin {
  void _changeTheme() async {
    setState(() {
      HomePage._theme = (HomePage._theme == 'dark') ? 'light' : 'dark';
    });
    SharedPreferences _sp = await SharedPreferences.getInstance();
    _sp.setString('Theme', HomePage._theme);
  }

  late Color _complementColor;
  final List<IconData> _iconLibrary = <IconData>[
        Icons.anchor,
        Icons.android,
        Icons.favorite,
        Icons.light,
        Icons.airplanemode_on,
        Icons.umbrella,
        Icons.alarm,
        Icons.directions_subway_rounded,
        Icons.person,
        Icons.light_mode_outlined,
        Icons.all_inclusive,
        Icons.wine_bar,
        Icons.star,
        Icons.headset_rounded,
        Icons.whatshot_outlined,
        Icons.delete,
        Icons.audiotrack_rounded,
        Icons.visibility,
        Icons.traffic_rounded,
        Icons.beach_access_rounded,
        Icons.downhill_skiing_rounded,
        Icons.directions_bike_rounded,
        Icons.directions_boat_rounded,
        Icons.lunch_dining_rounded,
        Icons.restaurant,
        Icons.shopping_cart_rounded,
        Icons.smoking_rooms_rounded,
        Icons.sports_esports_rounded,
      ],
      _icons = <IconData>[];
  final List<AnimationController> _startAnimations = <AnimationController>[], _controllers = <AnimationController>[];
  final List<Animation<double>> _animations = <Animation<double>>[];
  final List<ValueNotifier<Color>> _colors = <ValueNotifier<Color>>[];
  final List<ValueNotifier<double>> _scale = <ValueNotifier<double>>[];
  final List<bool> _isMatched = <bool>[];
  late int _first = -1, _second = -1, _matchedCnt = 0, _dimension;
  late AnimationController _timerAnimation;
  final List<Color> _randomColors = <Color>[], _bckgrndColors = <Color>[], _frgrndColors = <Color>[];
  late double _iconSize, _responsiveCoefficient;
  late String _finishTime = '', _completeMessage = '';

  @override
  void initState() {
    super.initState();
    _dimension = widget.sizeX * widget.sizeY;
    List<int> _indices = Iterable<int>.generate(_dimension).toList();
    for (int j = 0; j < _dimension / 2; j++) {
      Color _tmp;
      while (true) {
        _tmp = Colors.primaries[Random().nextInt(Colors.primaries.length)];
        int cnt = 0;
        for (int i = 0; i < _randomColors.length; i++) {
          if (_randomColors[i] == _tmp) {
            cnt++;
            break;
          }
        }
        if (cnt == 0) {
          break;
        }
      }
      _randomColors.add(_tmp);
      IconData _tmp2;
      while (true) {
        _tmp2 = _iconLibrary[Random().nextInt(_iconLibrary.length)];
        int cnt = 0;
        for (int i = 0; i < _icons.length; i++) {
          if (_icons[i] == _tmp2) {
            cnt++;
            break;
          }
        }
        if (cnt == 0) {
          break;
        }
      }
      _icons.add(_tmp2);
    }
    _randomColors.addAll(_randomColors.getRange(0, _randomColors.length));
    _icons.addAll(_icons.getRange(0, _icons.length));
    _indices.shuffle();
    List<Color> tmpColors = <Color>[];
    List<IconData> tmpIcons = <IconData>[];
    for (int i = 0; i < _dimension; i++) {
      tmpColors.add(_randomColors[i]);
      tmpIcons.add(_icons[i]);
    }
    _randomColors.clear();
    _icons.clear();
    for (int j = 0; j < _dimension; j++) {
      _randomColors.add(tmpColors[(_indices[j])]);
      _icons.add(tmpIcons[(_indices[j])]);
      _controllers.add(AnimationController(vsync: this, duration: const Duration(seconds: 1), value: 1.0));
      _animations.add(Tween<double>(begin: 0.0, end: pi)
          .animate(CurvedAnimation(parent: _controllers[j], reverseCurve: Curves.linearToEaseOut.flipped, curve: Curves.linearToEaseOut)));
      _startAnimations.add(AnimationController(vsync: this, duration: const Duration(milliseconds: 700), value: 1.0));
      _colors.add(ValueNotifier<Color>(Colors.transparent));
      _scale.add(ValueNotifier<double>(1.0));
      _isMatched.add(false);
      _frgrndColors.add(HSLColor.fromColor(_randomColors[j]).withLightness(HSLColor.fromColor(_randomColors[j]).lightness / 2).toColor());
      _bckgrndColors.add(HSLColor.fromColor(_randomColors[j]).withLightness(HSLColor.fromColor(_randomColors[j]).lightness * 1.5).toColor());
    }
    _timerAnimation = AnimationController(vsync: this, duration: Duration(seconds: (_dimension * 5).toInt()));
    _timerAnimation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        //RAN OUT OF TIME
        _first = -2;
        _second = -2;
        for (int i = 0; i < _dimension; i++) {
          _startAnimations[i].forward();
        }
        Timer(const Duration(milliseconds: 700), () {
          setState(() {});
        });
      }
    });
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      Timer(const Duration(milliseconds: 500), () {
        for (int i = 0; i < _dimension; i++) {
          _startAnimations[i].reverse();
        }
        _timerAnimation.forward();
      });
    });
  }

  @override
  void dispose() {
    for (int i = 0; i < _icons.length; i++) {
      _controllers[i].dispose();
      _startAnimations[i].dispose();
      _colors[i].dispose();
      _scale[i].dispose();
    }
    _timerAnimation.dispose();
    super.dispose();
  }

  void _check() async {
    if (_icons[_first] == _icons[_second]) {
      //CORRECT MATCH
      _matchedCnt += 2;
      _startAnimations[_first].forward();
      _startAnimations[_second].forward();
      _isMatched[_first] = true;
      _isMatched[_second] = true;
      if (_matchedCnt == _dimension) {
        //GAME FINISHED
        _finishTime = (_dimension * 5 * _timerAnimation.value).toStringAsPrecision(4);
        _completeMessage = 'Completed in $_finishTime seconds.';
        SharedPreferences _sp = await SharedPreferences.getInstance();
        if (_sp.getString('${widget._difficulty.toLowerCase()}BestTime') == null ||
            double.parse(_sp.getString('${widget._difficulty.toLowerCase()}BestTime')!) > double.parse(_finishTime)) {
          if (_sp.getString('${widget._difficulty.toLowerCase()}BestTime') != null) {
            _completeMessage = 'CONGRATULATIONS! NEW BEST!\n\nCompleted in $_finishTime seconds.';
          }
          _sp.setString('${widget._difficulty.toLowerCase()}BestTime', _finishTime);
        }
        _timerAnimation.reset();
      }
      Timer(const Duration(milliseconds: 100), () {
        _first = -1;
        _second = -1;
        Timer(const Duration(milliseconds: 600), () {
          setState(() {});
        });
      });
    } else {
      //FALSE MATCH
      _controllers[_first].reset();
      _controllers[_first].forward();
      _controllers[_second].reset();
      _controllers[_second].forward();
      Timer(const Duration(milliseconds: 210), () {
        _colors[_first].value = Colors.transparent;
        _colors[_second].value = Colors.transparent;
        _first = -1;
        _second = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _complementColor = (HomePage._theme == 'dark') ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    _responsiveCoefficient = sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height);
    _iconSize = _responsiveCoefficient / _dimension * 2;
    return SafeArea(
      child: Scaffold(
        backgroundColor: (HomePage._theme == 'dark') ? Colors.black : const Color(0xFFE0E0E0),
        appBar: null,
        body: Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(_timerAnimation),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 8.0,
                color: (HomePage._theme == 'dark') ? Colors.white : Colors.black,
              ),
            ),
            (_matchedCnt == _dimension)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (widget._difficulty == 'VETERAN')
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'You crazy son of a bitch, you did it.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: (HomePage._theme == 'dark') ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 36.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset('assets/veteran1.gif'),
                                  const SizedBox(width: 12.0),
                                  Image.asset('assets/veteran2.gif', width: 280.0),
                                ],
                              ),
                            ],
                          ),
                        if (widget._difficulty == 'CASUAL') Image.asset('assets/casual.gif'),
                        if (widget._difficulty == 'EASY') Image.asset('assets/easy.gif', width: 280.0),
                        const SizedBox(height: 36.0),
                        Text(
                          _completeMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            color: widget._color1,
                          ),
                        ),
                        const SizedBox(height: 36.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                Navigator.of(context).pushReplacement(MyRoute(builder: (_) => const HomePage()));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                                transformAlignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: widget._color1,
                                  borderRadius: const BorderRadius.all(Radius.circular(36.0)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      blurRadius: 12.0,
                                      spreadRadius: 3.0,
                                      color: widget._color1.withOpacity(0.4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'BACK',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                      shadows: <Shadow>[
                                        Shadow(
                                          offset: Offset(0.0, 1.0),
                                          blurRadius: 1.5,
                                          color: Colors.black26,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : (_timerAnimation.status == AnimationStatus.completed)
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Time is up.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.0,
                                color: widget._color1,
                              ),
                            ),
                            const SizedBox(height: 36.0),
                            Image.asset('assets/tyler1-rage.gif'),
                            const SizedBox(height: 36.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                InkWell(
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(MyRoute(builder: (_) => const HomePage()));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                                    transformAlignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: widget._color1,
                                      borderRadius: const BorderRadius.all(Radius.circular(36.0)),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          blurRadius: 12.0,
                                          spreadRadius: 3.0,
                                          color: widget._color1.withOpacity(0.4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'BACK',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(0.0, 1.0),
                                              blurRadius: 1.5,
                                              color: Colors.black26,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : GridView.count(
                        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                        crossAxisCount: widget.sizeX,
                        childAspectRatio: MediaQuery.of(context).size.aspectRatio,
                        mainAxisSpacing: _responsiveCoefficient / 81,
                        crossAxisSpacing: _responsiveCoefficient / 81,
                        children: <ScaleTransition>[
                          for (int index = 0; index < _icons.length; index++)
                            ScaleTransition(
                              scale: CurvedAnimation(parent: _startAnimations[index], curve: Curves.easeInOutQuart).drive(Tween<double>(begin: 1.0, end: 0.85)),
                              child: FadeTransition(
                                opacity: CurvedAnimation(parent: _startAnimations[index], curve: Curves.easeInCubic).drive(Tween<double>(begin: 1.0, end: 0.0)),
                                child: Visibility(
                                  visible: !_isMatched[index],
                                  child: InkWell(
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      if ((_first == -1 || _second == -1) && (_controllers[index].isAnimating == false)) {
                                        if (_controllers[index].isCompleted == true) {
                                          _controllers[index].reverse();
                                          if (_first == -1) {
                                            _first = index;
                                          } else {
                                            _second = index;
                                            Timer(const Duration(seconds: 1), () {
                                              _check();
                                            });
                                          }
                                        } else {
                                          _first = -1;
                                          _controllers[index].forward();
                                        }
                                        Timer(const Duration(milliseconds: 210), () {
                                          _colors[index].value = (_colors[index].value == Colors.transparent) ? _bckgrndColors[index] : Colors.transparent;
                                        });
                                      }
                                    },
                                    onHover: (bool value) {
                                      if (value == true) {
                                        _scale[index].value = 1.05;
                                      } else {
                                        _scale[index].value = 1.0;
                                      }
                                    },
                                    child: AnimatedBuilder(
                                      animation: _controllers[index],
                                      builder: (BuildContext context, Widget? child) {
                                        return Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.identity()
                                            ..setEntry(3, 2, 0.001)
                                            ..rotateY(_animations[index].value),
                                          child: ValueListenableBuilder<Color>(
                                            valueListenable: _colors[index],
                                            builder: (BuildContext context, Color color, Widget? child) {
                                              return ValueListenableBuilder<double>(
                                                valueListenable: _scale[index],
                                                builder: (BuildContext context, double scale, Widget? child) {
                                                  return AnimatedScale(
                                                    duration: const Duration(milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                    scale: scale,
                                                    child: AnimatedContainer(
                                                      duration: const Duration(milliseconds: 300),
                                                      curve: Curves.easeInOut,
                                                      transformAlignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: (scale == 1.0) ? widget._color1 : _complementColor,
                                                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                                        boxShadow: <BoxShadow>[
                                                          BoxShadow(
                                                            blurRadius: 10.0,
                                                            spreadRadius: 3.0,
                                                            color: (color == Colors.transparent)
                                                                ? ((scale == 1.0) ? widget._color1.withOpacity(0.4) : _complementColor.withOpacity(0.4))
                                                                : _randomColors[index].withOpacity(0.4),
                                                          )
                                                        ],
                                                      ),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      _icons[index],
                                                      size: _iconSize,
                                                      color: (color == Colors.transparent) ? color : _frgrndColors[index],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
            if (_timerAnimation.status != AnimationStatus.completed && _matchedCnt < _dimension)
              Positioned(
                top: 12.0,
                right: 12.0,
                child: IconButton(
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  icon: Icon(
                    Icons.pause_circle_outline,
                    color: (HomePage._theme == 'dark') ? Colors.white : Colors.black,
                    size: 40.0,
                  ),
                  onPressed: () {
                    _timerAnimation.stop();
                    showGeneralDialog(
                        context: context,
                        barrierDismissible: false,
                        barrierColor: Colors.transparent,
                        transitionDuration: const Duration(milliseconds: 500),
                        transitionBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget child) {
                          return BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: max(0.01, ((16.8) * CurvedAnimation(parent: anim1, curve: Curves.easeInCubic).value)),
                                sigmaY: max(0.01, ((16.8) * CurvedAnimation(parent: anim1, curve: Curves.easeInCubic).value))),
                            child: FadeTransition(
                              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: anim1, curve: Curves.easeInCubic)),
                              child: child,
                            ),
                          );
                        },
                        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16.8, sigmaY: 16.8),
                                child: Stack(
                                  children: <Widget>[
                                    Positioned(
                                      top: 12.0,
                                      right: 12.0,
                                      child: FloatingActionButton.extended(
                                        backgroundColor: (HomePage._theme == 'dark') ? Colors.black : Colors.white,
                                        elevation: 3.0,
                                        hoverElevation: 8.0,
                                        onPressed: () {
                                          _changeTheme();
                                          setState(() {});
                                        },
                                        label: Text(
                                          HomePage._theme.toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            letterSpacing: 0.0,
                                            color: (HomePage._theme == 'dark') ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
                                            fontSize: _responsiveCoefficient / pow(6.5, 2),
                                          ),
                                        ),
                                        icon: Icon(
                                          (HomePage._theme == 'dark') ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                                          color: (HomePage._theme == 'dark') ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
                                          size: _responsiveCoefficient / 25,
                                        ),
                                      ),
                                    ),
                                    AlertDialog(
                                      elevation: 0.0,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24.0))),
                                      backgroundColor: (HomePage._theme == 'dark') ? Colors.black26 : Colors.white24,
                                      actionsPadding: EdgeInsets.all(_responsiveCoefficient / 40),
                                      contentPadding: EdgeInsets.all(_responsiveCoefficient / 20),
                                      titlePadding: EdgeInsets.all(_responsiveCoefficient / 40),
                                      insetPadding: EdgeInsets.zero,
                                      content: Text(
                                        'GAME PAUSED\n',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: _responsiveCoefficient / pow(4.5, 2),
                                          color: (HomePage._theme == 'dark') ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      actions: <Row>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <InkWell>[
                                            InkWell(
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                Timer(const Duration(milliseconds: 400), () {
                                                  _timerAnimation.forward(from: _timerAnimation.value);
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(right: _responsiveCoefficient / 60),
                                                padding: EdgeInsets.symmetric(vertical: _responsiveCoefficient / 49),
                                                width: _responsiveCoefficient / 4,
                                                decoration: ShapeDecoration(
                                                  color: (HomePage._theme == 'dark') ? Colors.black26 : Colors.white24,
                                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'CONTINUE',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: _responsiveCoefficient / pow(5.5, 2),
                                                      color: (HomePage._theme == 'dark') ? Colors.white : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () {
                                                Navigator.of(context).pushReplacement(MyRoute(builder: (_) => const HomePage()));
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(left: _responsiveCoefficient / 60),
                                                padding: EdgeInsets.symmetric(vertical: _responsiveCoefficient / 49),
                                                width: _responsiveCoefficient / 4,
                                                decoration: ShapeDecoration(
                                                  color: (HomePage._theme == 'dark') ? Colors.black26 : Colors.white24,
                                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'QUIT',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: _responsiveCoefficient / pow(5.5, 2),
                                                      color: (HomePage._theme == 'dark') ? Colors.white : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
