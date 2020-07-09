import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:langaw/components/callout.dart';
import 'package:langaw/langawGame.dart';
import 'package:langaw/view.dart';

class Fly {
  Rect flyRect;
  final LangawGame game;
  bool isDead = false;
  bool isOffScreen = false;
  List<Sprite> flyingSprite;
  Sprite deadSprite;
  double flyingSpriteIndex = 0;
  double get speed => game.tileSize * 3;
  Offset targetLocation;
  Callout callout;

  Fly(this.game) {
    setTargetLocation();
    callout = Callout(this);
  }

  void setTargetLocation() {
    double x = game.rnd.nextDouble() *
        (game.screenSize.width - (game.tileSize * 1.35));
    double y = (game.rnd.nextDouble() *
            (game.screenSize.height - (game.tileSize * 2.85))) +
        (game.tileSize * 1.5);
    targetLocation = Offset(x, y);
  }

  void render(Canvas c) {
    if (isDead) {
      deadSprite.renderRect(c, flyRect.inflate(flyRect.width / 2));
    } else {
      flyingSprite[flyingSpriteIndex.toInt()]
          .renderRect(c, flyRect.inflate(flyRect.width / 2));
      if (game.activeView == View.playing) callout.render(c);
    }
  }

  void update(double t) {
    if (isDead) {
      flyRect = flyRect.translate(0, game.tileSize * 12 * t);

      if (flyRect.top > game.screenSize.height) {
        isOffScreen = true;
      }
    } else {
      callout.update(t);

      flyingSpriteIndex += t * 30;
      if (flyingSpriteIndex.toInt() >= 2) flyingSpriteIndex %= 2;

      double stepDistance = speed * t;
      Offset toTarget = targetLocation - Offset(flyRect.left, flyRect.top);
      if (stepDistance < toTarget.distance) {
        Offset stepToTarget =
            Offset.fromDirection(toTarget.direction, stepDistance);
        flyRect = flyRect.shift(stepToTarget);
      } else {
        flyRect = flyRect.shift(toTarget);
        setTargetLocation();
      }
    }
  }

  void onTapDown() {
    if (!isDead) {
      if (game.soundButton.isEnabled)
        Flame.audio
            .play('sfx/ouch' + (game.rnd.nextInt(11) + 1).toString() + '.ogg');
      isDead = true;
      if (game.activeView == View.playing) {
        game.score += 1;
      }
      if (game.score > (game.storage.getInt('highscore') ?? 0)) {
        game.storage.setInt('highscore', game.score);
        game.highscoreDisplay.updateHighscore();
      }
    }
  }
}
