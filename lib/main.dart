import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final totalLives = 3;
  int currentLives = 3;
  TextEditingController _controller = TextEditingController();
  final StreamController<int> _streamController = StreamController<int>();
  bool _isRunning = false;
  String randomQuestion = '';
  int points = 0;
  Timer questionTimer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    randomQuestion = randomMathQuestion();
    _startStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 300,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        //title: Text(widget.title),
        leading: Center(
          child: Stack(
            children: [
              Row(
                children: List.generate(
                    totalLives,
                    (index) => const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.favorite_border,
                            color: Colors.purpleAccent,
                          ),
                        )),
              ),
              Row(
                children: List.generate(
                    currentLives,
                    (index) => const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.purpleAccent,
                          ),
                        )),
              ),
            ],
          ),
        ),
        actions: [
          Text("Points: $points", style: TextStyle(color: Colors.white)),
          SizedBox(width: 16.0),
        ],
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                children: [
                  StreamBuilder<int>(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        debugPrint("Snapshot: ${snapshot.data}");
                        return Container(
                          color: Colors.grey[200],
                          height: (MediaQuery.of(context).size.height * 0.45) *
                              ((snapshot.data ?? 0) / 5),
                        );
                      }),
                  Center(
                    child: Text(randomQuestion,
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              )),
          TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
                isDense: true,
                hintText: "Enter Your Answer",
                alignLabelWithHint: true,
                border: InputBorder.none),
          ),
          GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2,
              childAspectRatio: 2.2,
              //padding: const EdgeInsets.all(4.0),
              children: List.generate(
                  12,
                  (index) => index == 11
                      ? InkWell(
                          onTap: () {
                            bool answer = checkAnswer(_controller.text);
                            if (answer == false && currentLives > 0) {
                              currentLives = currentLives - 1;
                            } else {
                              points = points + 1;
                            }
                            _restartStream(hasAnswered: true);
                          },
                          child: const Icon(Icons.send))
                      : InkWell(
                          onTap: () {
                            if (index == 9) {
                              _controller = TextEditingController();
                              setState(() {});
                              return;
                            }
                            _controller = TextEditingController(
                                text: _controller.text +
                                    (index == 10 ? "0" : "${index + 1}"));
                            setState(() {});
                          },
                          child: Center(
                              child: Text(index == 9
                                  ? 'CE'
                                  : index == 10
                                      ? "0"
                                      : "${index + 1}")),
                        ))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  String randomMathQuestion() {
    final random = math.Random();
    final a = random.nextInt(9);
    final b = random.nextInt(9);
    final operator = random.nextInt(3);

    if (operator == 3 && b == 0 || operator == 1 && a < b) {
      return randomMathQuestion();
    }

    switch (operator) {
      case 0:
        return "$a + $b";
      case 1:
        return "$a - $b";
      case 2:
        return "$a X $b";
      default:
        return "$a / $b";
    }
  }

  void _startStream() {
    _isRunning = true;

    questionTimer.cancel();
    _streamController.add(0);
    if (currentLives == 0) {
      //currentLives = totalLives;

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(child: Text("Game Over")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Score: $points"),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    primary: Colors.white,
                    backgroundColor: Colors.purpleAccent[100],
                  ),
                    onPressed: () {
                      points = 0;
                      currentLives = totalLives;
                      _restartStream(hasAnswered: true);
                      Navigator.pop(context);
                    },
                    child: const Text("Restart")),
                TextButton(
                    onPressed: () {
                      exit(0);
                      // close the app
                    },
                    child: Text("Close"))
              ],
            );
          });
      return;
    }
    questionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isRunning) {
        _streamController.add(timer.tick);
      }
      if (timer.tick == 6 && currentLives > 0) {
        randomQuestion = randomMathQuestion();
        _controller = TextEditingController();
        currentLives = currentLives - 1;
        setState(() {});
        timer.cancel();

        _restartStream();
      }
    });
  }

  void _restartStream({bool hasAnswered = false}) {
    _startStream();

    if (hasAnswered) {
      randomQuestion = randomMathQuestion();
      _controller = TextEditingController();
      setState(() {});
    }
    /*Future.delayed(Duration(milliseconds: 1000), () {
      randomQuestion = randomMathQuestion();
      setState(() {});
    });*/
  }

  bool checkAnswer(String answer) {
    final correctAnswer = Function.apply((int a, int b, [int? c]) {
      switch (randomQuestion.split(" ")[1]) {
        case "+":
          return a + b;
        case "-":
          return a - b;
        case "X":
          return a * b;
        case "/":
          return a ~/ b;
        default:
          return 0;
      }
    }, [
      int.parse(randomQuestion.split(" ")[0]),
      int.parse(randomQuestion.split(" ")[2])
    ]);
    return correctAnswer == int.parse(answer);
  }
}
