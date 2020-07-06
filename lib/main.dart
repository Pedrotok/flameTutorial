import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:langaw/langawGame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setPortrait();

  LangawGame game = LangawGame();
  runApp(game.widget);

  var tapper = TapGestureRecognizer();
  tapper.onTapDown = game.onTapDown;
  flameUtil.addGestureRecognizer(tapper);
}
