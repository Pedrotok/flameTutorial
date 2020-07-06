import 'dart:ui';

import 'package:langaw/langawGame.dart';

class Fly {
  Rect flyRect;
  final LangawGame game;
  Paint flyPaint;
  bool isDead;
  bool isOffScreen;

  Fly(this.game, double x, double y)
      : isDead = false,
        isOffScreen = false {
    flyRect = Rect.fromLTWH(x, y, game.tileSize, game.tileSize);
    flyPaint = Paint();
    flyPaint.color = Color(0xff6ab04c);
  }

  void render(Canvas c) {
    c.drawRect(flyRect, flyPaint);
  }

  void update(double t) {
    if (isDead) {
      flyRect = flyRect.translate(0, game.tileSize * 12 * t);

      if (flyRect.top > game.screenSize.height) {
        isOffScreen = true;
      }
    }
  }

  void onTapDown() {
    flyPaint.color = Color(0xffff4757);
    isDead = true;
    game.spawnFly();
  }
}
