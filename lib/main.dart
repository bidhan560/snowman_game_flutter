import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/gamelogo.png', // Replace with the path to your image asset
          width: 500,
          height: 500,
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              bool isAuthenticated = await authenticateUser(
                  _usernameController.text, _passwordController.text);
              if (isAuthenticated) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SnowmanGame()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid username or password')));
              }
            },
            child: Text('Login'),
          ),
          SizedBox(height: 10.0),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
            child: Text('Create an account'),
          ),
        ],
      ),
    );
  }
}

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SignupForm(),
    );
  }
}

class SignupForm extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              await saveUser(
                  _usernameController.text, _passwordController.text);
              Navigator.pop(context);
            },
            child: Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}

class SnowmanGame extends StatefulWidget {
  @override
  _SnowmanGameState createState() => _SnowmanGameState();
}

class _SnowmanGameState extends State<SnowmanGame> {
  final List<String> words = [
    'snow',
    'winter',
    'frost',
    'ice',
    'cold',
    'freeze',
    'chill',
    'white'
  ]; // Sample list of words
  final Map<String, String> hints = {
    'snow': 'what falls on winter',
    'winter': 'Coldest season of the year',
    'frost': 'group of trees',
    'ice': 'Frozen water',
    'cold': 'Opposite of hot',
    'freeze': 'i am ..... in cold' ,
    'chill': 'A feeling of coldness in the air',
    'white': 'Color of snow'
  };

  late String hiddenWord;
  late String hint;
  late int wrongGuesses;
  late int winScore;
  late int lossScore;
  late List<String> guessedLetters;

  @override
  void initState() {
    super.initState();
    startGame();
    // Load win and loss scores
    loadScores();
  }

  void startGame() {
    final Random random = Random();
    final int randomIndex = random.nextInt(words.length);
    hiddenWord = words[randomIndex];
    hint = hints[hiddenWord]!;
    wrongGuesses = 0;
    guessedLetters = [];
  }

  void loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      winScore = prefs.getInt('win_score') ?? 0;
      lossScore = prefs.getInt('loss_score') ?? 0;
    });
  }

  void saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('win_score', winScore);
    prefs.setInt('loss_score', lossScore);
  }

  bool isLetterGuessed(String letter) {
    return guessedLetters.contains(letter);
  }

  bool isGameWon() {
    return hiddenWord.split('').every((letter) => guessedLetters.contains(letter));
  }

  bool isGameLost() {
    return wrongGuesses >= 5;
  }

  void guessLetter(String letter) {
    if (!guessedLetters.contains(letter)) {
      setState(() {
        guessedLetters.add(letter);
        if (!hiddenWord.contains(letter)) {
          wrongGuesses++;
        }
      });
    }
  }

  void restartGame() {
    setState(() {
      startGame();
    });
  }

  void incrementWinScore() {
    setState(() {
      winScore++;
      saveScores();
    });
  }

  void incrementLossScore() {
    setState(() {
      lossScore++;
      saveScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bidhan Snowman Game'),
        actions: [
          IconButton(
            iconSize: 40,
            icon: Icon(Icons.emoji_events, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Scores'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wins: $winScore'),
                      Text('Losses: $lossScore'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green[200]!, Colors.yellow],
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedContainer(
              duration: Duration(seconds: 10),
              curve: Curves.linear,
              child: CustomPaint(
                painter: SnowflakesPainter(100),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/snowman_${wrongGuesses}.png',
                    width: 300,
                    height: 300,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Hint: $hint',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: hiddenWord.split('').map((letter) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          isLetterGuessed(letter) ? letter : '_',
                          style: TextStyle(fontSize: 24),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 25),
                  Wrap(
                    spacing: 15,
                    children: List.generate(26, (index) {
                      return ElevatedButton(
                        onPressed: isLetterGuessed(String.fromCharCode('a'.codeUnitAt(0) + index)) || isGameLost() || isGameWon() ? null : () => guessLetter(String.fromCharCode('a'.codeUnitAt(0) + index)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLetterGuessed(String.fromCharCode('a'.codeUnitAt(0) + index)) ? Colors.blueGrey : Colors.green, // Change the button color here

                        ),
                        child: Text(String.fromCharCode('a'.codeUnitAt(0) + index)),
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                  isGameWon()
                      ? Column(
                    children: [
                      Text(
                        'Congratulations! You won!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          incrementWinScore();
                          restartGame();
                        },
                        child: Text('Play Again'),
                      ),
                    ],
                  )
                      : isGameLost()
                      ? Column(
                    children: [
                      Text(
                        'Sorry, you lose!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          incrementLossScore();
                          restartGame();
                        },
                        child: Text('Play Again'),
                      ),
                    ],
                  )
                      : Text(
                    'Wrong guesses: $wrongGuesses',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SnowflakesPainter extends CustomPainter {
  final int count;

  SnowflakesPainter(this.count);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final random = Random();

    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


Future<Database> openDB() async {
  return databaseFactoryWeb.openDatabase('user_database.db');
}
Future<void> saveUser(String username, String password) async {
  final Database db = await openDB();
  final store = intMapStoreFactory.store('users');
  await store.add(db, {'username': username, 'password': password});
}
Future<bool> authenticateUser(String username, String password) async {
  final Database db = await openDB();
  final store = intMapStoreFactory.store('users');
  final finder = Finder(filter: Filter.and([
    Filter.equals('username', username),
    Filter.equals('password', password),
  ]));
  final recordSnapshots = await store.find(db, finder: finder);
  return recordSnapshots.isNotEmpty;
}
