import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'leaderboard_writer.dart';

class GameScreen extends StatefulWidget {
  final String username;

  const GameScreen({super.key, required this.username});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  int gridSize = 2;
  int timerDuration = 10;
  int score = 0;
  late Color baseColor;
  late Color differentColor;
  int differentSquareIndex = 0;
  Timer? gameTimer;
  int remainingTime = 0;
  int colorDifferential = 34;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    setState(() {
      remainingTime = timerDuration;
      generateColors();
      startTimer();
    });
  }

  void generateColors() {
    final random = Random();
    // Generates a color from 0 to 256
    // This is to prevent 256 being randomly chosen
    // Bounds are [0, 256 - colorDifferential]
    baseColor = Color.fromRGBO(
      random.nextInt(256 - colorDifferential),
      random.nextInt(256 - colorDifferential),
      random.nextInt(256 - colorDifferential),
      1,
    );

    // Keep the random color to a bound of 0 to 256
    differentColor = Color.fromRGBO(
      (baseColor.red + colorDifferential).clamp(0, 256),
      (baseColor.green + colorDifferential).clamp(0, 256),
      (baseColor.blue + colorDifferential).clamp(0, 256),
      1,
    );

    differentSquareIndex = random.nextInt(gridSize * gridSize);
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime <= 0) {
        print("You lost final score ${score} colordif is ${colorDifferential}");
        timer.cancel();
        endOfGame();
      } else {
        setState(() {
          remainingTime--;
        });
        if (remainingTime <= 3) {
          // TODO - Add some beeping noise
          print("Beeepppppp!!!");
        }
      }
    });
  }

  void onSquareClick(int index) {
    if (index == differentSquareIndex) {
      setState(() {
        score++;
        if(score % 6 == 0){ // After 20 make the colors less differentiable every 6
          gridSize = (gridSize + 1).clamp(2, 8);
          timerDuration = (timerDuration - 1).clamp(2, 10);
          colorDifferential = (colorDifferential - 2).clamp(6, 34);
        }
        initializeGame();
      });
    } else {
      print("You lost final score ${score} colordif is ${colorDifferential}");
      endOfGame();
    }
  }

  void endOfGame() {
    gameTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false, // user cant tap outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over!'),
          content: Text('Final Score: $score \nPlay again!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                LeaderboardManager.saveEntry(widget.username, score).then((_) {
                  Navigator.pushReplacementNamed(context, '/');
                });
              },
              child: Text('Main Menu'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                LeaderboardManager.saveEntry(widget.username, score);
                setState(() { // Reset the game
                  score = 0;
                  gridSize = 2;
                  timerDuration = 10;
                  colorDifferential = 34;
                });
                initializeGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 224, 158, 1.0),
        title: Text(
          'Spot the Different Color!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text('Time: $remainingTime', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gridWidth = constraints.maxWidth * 0.9;
                final gridHeight = constraints.maxHeight;
                final squareSize = min(gridWidth, gridHeight) / gridSize;

                return Padding(padding: EdgeInsets.only(top: constraints.maxHeight / 6),
                child: Center(
                  child: SizedBox(
                    width: gridWidth,
                    height: gridHeight,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                      ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => onSquareClick(index),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              width: squareSize,
                              height: squareSize,
                              decoration: BoxDecoration(
                                color: index == differentSquareIndex ? differentColor : baseColor,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}