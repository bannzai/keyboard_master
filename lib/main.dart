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
  late KeyboardGame game = KeyboardGame(stream.stream);
  final TextEditingController _textEditingController = TextEditingController();

  String latestString = "";

  @override
  void initState() {
    super.initState();
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
              game: game,
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

  KeyEventResult _handleKeyPress(FocusNode node, RawKeyEvent event) {
    debugPrint("_handleKeyPress");
    if (event is RawKeyDownEvent) {
      debugPrint(
          'Focus node ${node.debugLabel} got key event: ${event.logicalKey}');
      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        debugPrint('Changing color to red.');
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyG) {
        debugPrint('Changing color to green.');
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyB) {
        debugPrint('Changing color to blue.');
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}

class KeyboardGame extends FlameGame with KeyboardEvents {
  final Stream<String> stream;
  late StreamSubscription subscription;

  KeyboardGame(this.stream);

  @override
  Future<void> onLoad() async {
    subscription = stream.listen((event) {
      print(event);
    });
    add(
      Player()
        ..position = size / 2
        ..width = 50
        ..height = 400
        ..anchor = Anchor.center,
    );
  }

  // ...
  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    print("key pressed");
    final isKeyDown = event is RawKeyDownEvent;

    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

    if (isSpace && isKeyDown) {
      if (keysPressed.contains(LogicalKeyboardKey.altLeft) ||
          keysPressed.contains(LogicalKeyboardKey.altRight)) {
        print("left, right");
      } else {
        print("other");
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

class Player extends PositionComponent {
  static final _paint = Paint()..color = Colors.white;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
