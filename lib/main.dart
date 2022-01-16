import 'dart:math';

import 'package:flutter/material.dart';

import 'package:loop_tap_tutorial/painter/ball_painter.dart';
import 'package:loop_tap_tutorial/painter/loop_painter.dart';

import 'widgets/loop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Loop Tap",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameManager(),
      ),
    );
  }
}

class GameManager extends StatefulWidget {
  const GameManager({Key? key}) : super(key: key);

  @override
  State<GameManager> createState() => _GameManagerState();
}

class _GameManagerState extends State<GameManager>
    with SingleTickerProviderStateMixin {
  final _pathWidth = 20.0;
  int score = 0;
  int bestScore = -1;
  double speed = 1.5;
  double ballAngle = 0;
  double loopLength = 0;
  double loopStartAngle = 0;
  bool isUnderCollision = false;
  bool isPlaying = false;
  bool isGameOvered = false;

  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.ease)
      ..addListener(gameLoop);

    controller.repeat();
    randomizeSegmentPosition();
  }

  gameLoop() {
    driveBall();
    checkIfBallIsColliding();
    setState(() {});
  }

  startGame() {
    isPlaying = true;
    isGameOvered = false;
    speed = 1.5;
    randomizeSegmentPosition();
  }

  driveBall() {
    ballAngle = (ballAngle + speed) % 360; // ( 0 to 360)
  }

  randomizeSegmentPosition() {
    loopStartAngle = Random().nextInt(270).toDouble();
    loopLength = Random().nextInt(60).clamp(20, 60).toDouble();
  }

  checkIfBallIsColliding() {
    final endAngle = loopStartAngle + loopLength + _pathWidth;

    if (ballAngle < endAngle && ballAngle > loopStartAngle) {
      isUnderCollision = true;
    } else {
      isUnderCollision = false;
    }
  }

  checkForRecordBreak() {
    if (bestScore < score) {
      bestScore = score;
    }
  }

  gameOver() {
    isGameOvered = true;
    isPlaying = false;
    checkForRecordBreak();
    score = 0;
  }

  handleTap() {
    if (isPlaying) {
      if (isUnderCollision) {
        score++;
        speed += score / 10000;
        randomizeSegmentPosition();
      } else {
        gameOver();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => isPlaying ? handleTap() : startGame(),
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SizedBox.square(
                  dimension: 300,
                  child: GameBoard(
                    ballAngle: ballAngle,
                    loopLength: loopLength,
                    loopStartAngle: loopStartAngle,
                    pathWidth: _pathWidth,
                    child: Center(
                      child: isPlaying
                          ? Text(
                              "$score",
                              style: theme.headline4,
                            )
                          : IconButton(
                              onPressed: startGame,
                              icon: const Icon(Icons.play_arrow_rounded),
                              iconSize: 60,
                            ),
                    ),
                  ),
                ),
              ),
              if (isGameOvered)
                Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Text(
                    "Game Over\nBest Score : $bestScore",
                    style: theme.headline5,
                    textAlign: TextAlign.center,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class GameBoard extends StatelessWidget {
  final Widget? child;
  final double loopStartAngle;
  final double loopLength;
  final double ballAngle;
  final double pathWidth;

  const GameBoard({
    Key? key,
    this.child,
    required this.loopStartAngle,
    required this.loopLength,
    required this.ballAngle,
    required this.pathWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Loop(
      duration: const Duration(milliseconds: 400),
      stroke: pathWidth,
      startAngle: loopStartAngle,
      angle: loopLength,
      color: Colors.amber,
      child: CustomPaint(
        painter: BallPainter(
          color: Colors.red,
          radius: pathWidth / 2,
          angle: ballAngle,
        ),
        child: child,
      ),
    );
  }
}
