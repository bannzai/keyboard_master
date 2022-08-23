import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setPortrait();

  runApp(const Root());
}

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  late FocusNode _node;
  final stream = StreamController<String>();
  late KeyboardGame _game;
  final TextEditingController _textEditingController = TextEditingController();

  String latestString = "";

  @override
  void initState() {
    super.initState();
    _game = KeyboardGame(stream.stream);
    _node = FocusNode();
    _textEditingController.addListener(() {
      if (latestString != _textEditingController.text) {
        if (_textEditingController.text.length > latestString.length) {
          stream.sink
              .add(_textEditingController.text.substring(latestString.length));
        }
      }
      latestString = _textEditingController.value.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: _game,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                color: Colors.yellow,
                child: TextField(
                    controller: _textEditingController,
                    focusNode: _node,
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    onChanged: (text) {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeyboardGame extends FlameGame {
  final Stream<String> stream;
  late StreamSubscription subscription;

  KeyboardGame(this.stream);

  String text = "Hello, world";
  late Player player = Player(text);

  @override
  Future<void> onLoad() async {
    subscription = stream.listen((event) {
      text += event;
    });
    add(
      player
        ..position = size / 2
        ..width = size[0]
        ..height = size[1]
        ..anchor = Anchor.center,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.text = text;
  }
}

class Player extends PositionComponent {
  static final _paint = Paint()..color = Colors.white;
  final textPaint = TextPaint(style: const TextStyle(color: Colors.red));

  String text;
  Player(this.text);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
    textPaint.render(canvas, text, Vector2(20, 100));
  }
}
