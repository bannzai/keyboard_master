import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const words = [
  "Dogs come when they're called; cats take a message and get back to you later",
  "Books. Cats. Life is Good",
  "Women and cats will do as they please, and men and dogs should relax and get used to the idea",
  "In ancient times cats were worshipped as gods; they have not forgotten this",
  "There are two means of refuge from the misery of life — music and cats",
  "Cats are connoisseurs of comfort",
  "If animals could speak, the dog would be a blundering outspoken fellow; but the cat would have the rare grace of never saying a word too much",
  "What greater gift than the love of a cat"
];

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

  String latestInputText = "";
  late Player player = Player(text: latestInputText, subject: subject);
  late MyTextBox textBox = MyTextBox(text: subject);
  int index = 0;

  String get subject => words[index];

  @override
  Future<void> onLoad() async {
    subscription = stream.listen((event) {
      latestInputText += event;
    });
    add(
      player
        ..position = size / 2
        ..width = size[0]
        ..height = size[1]
        ..anchor = Anchor.center,
    );
    add(textBox
      ..position = Vector2(size[0] / 2, 100)
      ..width = size[0] - 40
      ..height = 200
      ..anchor = Anchor.topCenter);

    add(TimerComponent(
      period: 10,
      repeat: true,
      onTick: () {
        latestInputText = "";
        if (index < words.length - 1) {
          index += 1;
        } else {
          index = 0;
        }
      },
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.text = latestInputText;
    if (textBox.text != subject) {
      textBox.text = subject;
      textBox.latestInputText = "";
    }
    textBox.latestInputText = latestInputText;
  }
}

class MyTextBox extends TextBoxComponent {
  MyTextBox({required String text})
      : super(
            text: text,
            textRenderer:
                TextPaint(style: TextStyle(color: BasicPalette.white.color)),
            boxConfig: TextBoxConfig(timePerChar: 0.05),
            align: Anchor.topLeft);

  String latestInputText = "";
  late String latestSubject = text;

  late MyTextBox2 overlayBox = MyTextBox2(text: latestInputText);
  final borderPaint = Paint()..color = Colors.orange;

  @override
  Future<void> onLoad() {
    add(overlayBox
      ..position = Vector2(0, 0)
      ..width = width
      ..height = height
      ..anchor = Anchor.topLeft);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), borderPaint);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (latestSubject != text) {
      overlayBox.text = "";
      latestSubject = text;
    }
    if (text.contains(latestInputText)) {
      overlayBox.text = latestInputText;
    }
    super.update(dt);
  }
}

class MyTextBox2 extends TextBoxComponent {
  MyTextBox2({required String text})
      : super(
          text: text,
          textRenderer:
              TextPaint(style: TextStyle(color: BasicPalette.black.color)),
          align: Anchor.topLeft,
        );

  final borderPaint = Paint()..color = Colors.transparent;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), borderPaint);
    super.render(canvas);
  }
}

class Player extends PositionComponent {
  static final _paint = Paint()..color = Colors.white;
  final textPaint = TextPaint(style: const TextStyle(color: Colors.red));

  String text;
  String subject;
  Player({required this.text, required this.subject});

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
    super.render(canvas);
  }
}
