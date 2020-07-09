import 'dart:math';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game/game.dart';
import 'package:flutter/gestures.dart';
import 'package:langaw/BGM.dart';
import 'package:langaw/components/credits.dart';
import 'package:langaw/components/creditsView.dart';
import 'package:langaw/components/fly.dart';
import 'package:langaw/components/helpButton.dart';
import 'package:langaw/components/helpView.dart';
import 'package:langaw/components/highscoreDisplay.dart';
import 'package:langaw/components/homeView.dart';
import 'package:langaw/components/houseFly.dart';
import 'package:langaw/components/lostView.dart';
import 'package:langaw/components/musicButton.dart';
import 'package:langaw/components/scoreDisplay.dart';
import 'package:langaw/components/soundButton.dart';
import 'package:langaw/components/startButton.dart';
import 'package:langaw/controllers/spawner.dart';
import 'package:langaw/view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import 'components/agileFly.dart';
import 'components/backyard.dart';
import 'components/droolerFly.dart';
import 'components/hungryFly.dart';
import 'components/machoFly.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;
  Backyard background;
  List<Fly> flies;
  Random rnd;
  View activeView = View.home;
  HomeView homeView;
  LostView lostView;
  StartButton startButton;
  FlySpawner spawner;
  HelpButton helpButton;
  CreditsButton creditsButton;
  HelpView helpView;
  CreditsView creditsView;
  ScoreDisplay scoreDisplay;
  final SharedPreferences storage;
  HighscoreDisplay highscoreDisplay;
  AudioPlayer homeBGM;
  AudioPlayer playingBGM;
  MusicButton musicButton;
  SoundButton soundButton;
  int score;

  LangawGame(this.storage) {
    initialize();
  }

  void initialize() async {
    rnd = Random();
    flies = List<Fly>();
    resize(await Flame.util.initialDimensions());

    background = Backyard(this);
    homeView = HomeView(this);
    startButton = StartButton(this);
    lostView = LostView(this);
    spawner = FlySpawner(this);
    helpButton = HelpButton(this);
    creditsButton = CreditsButton(this);
    helpView = HelpView(this);
    creditsView = CreditsView(this);
    scoreDisplay = ScoreDisplay(this);
    highscoreDisplay = HighscoreDisplay(this);
    musicButton = MusicButton(this);
    soundButton = SoundButton(this);
    score = 0;

    await BGM.add('bgm/home.mp3');
    await BGM.add('bgm/playing.mp3');

    playHomeBGM();
  }

  void render(Canvas canvas) {
    background.render(canvas);
    highscoreDisplay.render(canvas);

    flies.forEach((Fly fly) => fly.render(canvas));
    if (activeView == View.home)
      homeView.render(canvas);
    else if (activeView == View.lost) lostView.render(canvas);
    if (activeView == View.home || activeView == View.lost) {
      helpButton.render(canvas);
      creditsButton.render(canvas);
      startButton.render(canvas);
    }

    musicButton.render(canvas);
    soundButton.render(canvas);

    if (activeView == View.help) helpView.render(canvas);
    if (activeView == View.credits) creditsView.render(canvas);
    if (activeView == View.playing) scoreDisplay.render(canvas);
  }

  void update(double t) {
    spawner.update(t);
    flies.forEach((Fly fly) => fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);
    if (activeView == View.playing) scoreDisplay.update(t);
  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
  }

  void spawnFly() {
    double x = rnd.nextDouble() * (screenSize.width - (tileSize * 1.35));
    double y = (rnd.nextDouble() * (screenSize.height - (tileSize * 2.85))) +
        (tileSize * 1.5);
    switch (rnd.nextInt(5)) {
      case 0:
        flies.add(HouseFly(this, x, y));
        break;
      case 1:
        flies.add(DroolerFly(this, x, y));
        break;
      case 2:
        flies.add(AgileFly(this, x, y));
        break;
      case 3:
        flies.add(MachoFly(this, x, y));
        break;
      case 4:
        flies.add(HungryFly(this, x, y));
        break;
    }
  }

  void onTapDown(TapDownDetails d) {
    bool isHandled = false;

    if (!isHandled) {
      if (activeView == View.help || activeView == View.credits) {
        activeView = View.home;
        isHandled = true;
      }
    }

    // help button
    if (!isHandled && helpButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        helpButton.onTapDown();
        isHandled = true;
      }
    }

    // credits button
    if (!isHandled && creditsButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        creditsButton.onTapDown();
        isHandled = true;
      }
    }

    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        startButton.onTapDown();
        isHandled = true;
      }
    }

    bool didHitAFly = false;
    if (!isHandled) {
      flies.forEach((Fly fly) {
        if (fly.flyRect.contains(d.globalPosition)) {
          fly.onTapDown();
          isHandled = true;
          didHitAFly = true;
        }
      });

      if (activeView == View.playing && !didHitAFly) {
        if (soundButton.isEnabled)
          Flame.audio
              .play('sfx/haha' + (rnd.nextInt(5) + 1).toString() + '.ogg');
        activeView = View.lost;
        playHomeBGM();
      }
    }

    // music button
    if (!isHandled && musicButton.rect.contains(d.globalPosition)) {
      musicButton.onTapDown();
      isHandled = true;
    }

    // sound button
    if (!isHandled && soundButton.rect.contains(d.globalPosition)) {
      soundButton.onTapDown();
      isHandled = true;
    }
  }

  void playHomeBGM() {
    BGM.play(0);
  }

  void playPlayingBGM() {
    BGM.play(1);
  }
}
