import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SkeddadleScreen extends StatefulWidget {
  final String username;

  static const double ballRadius = 25.0;
  static const double boxPadding = 20.0;

  const SkeddadleScreen({super.key, required this.username});

  @override
  SkeddadleScreenState createState() => SkeddadleScreenState();
}

class SkeddadleScreenState extends State<SkeddadleScreen> {
  int level = 1;
  int ballCount = 10;

  late Color baseColor;
  late Color differentColor;
  int colorDifferential = 30;
  int differentBallIndex = 0;
  List<Ball> balls = [];
  Timer? gameTimer;

  double boxWidth = 0; // box dimensions
  double boxHeight = 0;

  @override
  void initState() {
    super.initState();
    initializeGame();

    startGameLoop();
  }

  void initializeGame(){
    final random = Random();
    int baseRed = random.nextInt(256);
    int baseBlue = random.nextInt(256);
    int baseGreen = random.nextInt(256);

    baseColor = Color.fromRGBO(baseRed, baseBlue, baseGreen, 1);

    baseRed += (baseRed >= 225) ? -colorDifferential : colorDifferential;
    baseGreen += (baseGreen >= 225) ? -colorDifferential : colorDifferential;
    baseBlue += (baseBlue >= 225) ? -colorDifferential : colorDifferential;
    
    differentColor = Color.fromRGBO(baseRed, baseBlue, baseGreen, 1);
    balls = List.generate(ballCount, (index) {
      return Ball(
        random: random,
        initialX: random.nextDouble() * (boxWidth - 2 * SkeddadleScreen.ballRadius),
        initialY: random.nextDouble() * (boxHeight - 2 * SkeddadleScreen.ballRadius),
      );
    });
  }
  
  void startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer){
      setState(() {
        for(var ball in balls){
          ball.update();
        }
      });
    });
  }
  
  void onBallClick(int index) {
    if(index == differentBallIndex) {
      setState(() {
        level++;
        ballCount += 2;
        
        // TODO : Implement 10th level feature were all balls are random color
        // if level / 10 == 0
        // initializeSpecialGame();
        // else 
        
        initializeGame();
      });
    } else {
      endGame();
    }
  }

  void endGame() {
    gameTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over!'),
          content: Text('Level Reached: $level\nPlay again!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Main Menu'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  level = 1;
                  ballCount = 10;
                  initializeGame();
                  startGameLoop();
                });
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
        title: Text('Skeddadle Mode'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Level: $level',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(SkeddadleScreen.boxPadding),
              child: Center( // Center the smaller box horizontally
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5, // Half the screen width (slightly less for padding)
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 4.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        boxWidth = constraints.maxWidth;
                        boxHeight = constraints.maxHeight;
                        for (var ball in balls) {
                          ball.setBoundaries(constraints.maxWidth, constraints.maxHeight);
                        }
                        return GestureDetector(
                          onTapUp: (details) {
                            for (int i = 0; i < balls.length; i++) {
                              if (balls[i].contains(details.localPosition)) {
                                onBallClick(i);
                                break;
                              }
                            }
                          },
                          child: CustomPaint(
                            painter: BallPainter(balls, baseColor, differentColor, differentBallIndex),
                            child: SizedBox.expand(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Ball {
  double x, y;
  double dx, dy;
  double maxWidth = 0;
  double maxHeight = 0;

  Ball({required Random random, required double initialX, required double initialY})
      : x = initialX,
        y = initialY,
        dx = (random.nextBool() ? 1 : -1) * random.nextDouble() * 3,
        dy = (random.nextBool() ? 1 : -1) * random.nextDouble() * 3;

  void setBoundaries(double width, double height) {
    maxWidth = width - SkeddadleScreen.ballRadius * 2;
    maxHeight = height - SkeddadleScreen.ballRadius * 2;
  }

  void update() {
    x += dx;
    y += dy;

    if (x < 0) {
      x = 0;
      dx = -dx;
    } else if (x > maxWidth) {
      x = maxWidth;
      dx = -dx;
    }
    if (y < 0) {
      y = 0;
      dy = -dy;
    } else if (y > maxHeight) {
      y = maxHeight;
      dy = -dy;
    }
  }

  bool contains(Offset point) {
    final distance = sqrt(pow(point.dx - (x + SkeddadleScreen.ballRadius), 2) +
        pow(point.dy - (y + SkeddadleScreen.ballRadius), 2));
    return distance <= SkeddadleScreen.ballRadius;
  }
}

class BallPainter extends CustomPainter {
  final List<Ball> balls;
  final Color baseColor;
  final Color differentColor;
  final int differentBallIndex;

  BallPainter(this.balls, this.baseColor, this.differentColor, this.differentBallIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill; // For the ball's color
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2.0; // For the black outline

    for (int i = 0; i < balls.length; i++) {
      // Set the fill color based on whether it's the different ball
      fillPaint.color = i == differentBallIndex ? differentColor : baseColor;

      // Draw the filled circle
      canvas.drawCircle(
        Offset(balls[i].x + SkeddadleScreen.ballRadius, balls[i].y + SkeddadleScreen.ballRadius),
        SkeddadleScreen.ballRadius,
        fillPaint,
      );

      // Draw the black outline
      canvas.drawCircle(
        Offset(balls[i].x + SkeddadleScreen.ballRadius, balls[i].y + SkeddadleScreen.ballRadius),
        SkeddadleScreen.ballRadius,
        outlinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}