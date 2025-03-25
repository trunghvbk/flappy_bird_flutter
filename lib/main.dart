import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; // Add audioplayers package

void main() {
  runApp(FlappyBirdApp());
}

class FlappyBirdApp extends StatelessWidget {
  const FlappyBirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlappyBirdGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({super.key});

  @override
  FlappyBirdGameState createState() => FlappyBirdGameState();
}

class FlappyBirdGameState extends State<FlappyBirdGame> {
  double birdY = 0;
  double birdVelocity = 0;
  double gravity = 0.004;
  double jumpStrength = -0.03;
  bool isGameOver = false;
  bool hasGameStarted = false;
  List<double> pipeX = [1.5, 2.5];
  List<double> pipeHeight = [0.4, 0.6];
  double pipeWidth = 0.2;
  double pipeGap = 0.3;
  Timer? gameTimer;
  int score = 0; // Add score counter
  final AudioPlayer pointPlayer = AudioPlayer(); // Player for point sound
  final AudioPlayer gameOverPlayer = AudioPlayer(); // Player for game over sound

  @override
  void initState() {
    super.initState();
    pointPlayer.setVolume(0.5); // Set volume for point sound
    gameOverPlayer.setVolume(0.5); // Set volume for game over sound
    pointPlayer.setSource(AssetSource('point.mp3')); // Load point sound
    gameOverPlayer.setSource(AssetSource('chuong-chua.mp3')); // Load game over sound
  }

  void startGame() {
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        birdVelocity += gravity;
        birdY += birdVelocity;

        for (int i = 0; i < pipeX.length; i++) {
          pipeX[i] -= 0.01;
          if (pipeX[i] < -1) {
            pipeX[i] += 2;
            pipeHeight[i] = 0.2 + Random().nextDouble() * (0.6 - pipeGap - 0.2);
          }

          // Check if the bird has passed a pipe to increase the score
          if (pipeX[i] < 0 && pipeX[i] > -0.01) {
            score++;
            pointPlayer.resume(); // Play point sound
          }
        }

        if (birdY > 1 || birdY < -1 || checkCollision()) {
          isGameOver = true;
          gameOverPlayer.resume(); // Play game over sound
          gameTimer?.cancel();
        }
      });
    });
  }

  bool checkCollision() {
    for (int i = 0; i < pipeX.length; i++) {
      if (pipeX[i] > -pipeWidth / 2 && pipeX[i] < pipeWidth / 2) {
        double upperPipeBottom = -1 + 2 * pipeHeight[i];
        double lowerPipeTop = -1 + 2 * (pipeHeight[i] + pipeGap);
        if (birdY < upperPipeBottom || birdY > lowerPipeTop) {
          return true;
        }
      }
    }
    return false;
  }

  void jump() {
    if (!hasGameStarted) {
      hasGameStarted = true;
      startGame();
    }

    if (!isGameOver) {
      setState(() {
        birdVelocity = jumpStrength;
      });
    } else {
      setState(() {
        birdY = 0;
        birdVelocity = 0;
        isGameOver = false;
        hasGameStarted = false;
        pipeX = [1.5, 2.5];
        pipeHeight = [0.4, 0.6];
        score = 0; // Reset score
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Container(color: Colors.blue),
      Positioned(
        top: 20,
        right: 20,
        child: Text(
          'Score: $score', // Display the score
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      AnimatedContainer(
        alignment: Alignment(0, birdY),
        duration: Duration(milliseconds: 0),
        child: SizedBox(
          width: 100,
          height: 50,
          child: Image.asset('resources/flappy_bird.png', fit: BoxFit.contain),
        ),
      ),
    ];

    // Add pipes
    for (int i = 0; i < pipeX.length; i++) {
      double pipeLeft =
          (pipeX[i] + 1) / 2 * MediaQuery.of(context).size.width -
          (pipeWidth * MediaQuery.of(context).size.width / 2);
      double upperPipeHeight =
          MediaQuery.of(context).size.height * pipeHeight[i];
      double lowerPipeTop =
          MediaQuery.of(context).size.height * (pipeHeight[i] + pipeGap);
      double lowerPipeHeight =
          MediaQuery.of(context).size.height - lowerPipeTop;

      children.add(
        Positioned(
          left: pipeLeft,
          top: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * pipeWidth,
            height: upperPipeHeight,
            color: Colors.green,
          ),
        ),
      );
      children.add(
        Positioned(
          left: pipeLeft,
          top: lowerPipeTop,
          child: Container(
            width: MediaQuery.of(context).size.width * pipeWidth,
            height: lowerPipeHeight,
            color: Colors.green,
          ),
        ),
      );
    }

    if (isGameOver) {
      children.add(
        Center(
          child: Text(
            'Game Over',
            style: TextStyle(fontSize: 32, color: Colors.red),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: jump,
      child: Scaffold(body: Stack(children: children)),
    );
  }
}
