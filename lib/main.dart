import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'additional.dart';

void main() {
  runApp(const Calculator());
}

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  String output = '';
  bool hasDecimal = false;
  String last = '';
  List<String> history = [];
  bool isAdvancedVisible = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadHistory();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _saveToHistory(String calculation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    history.add(calculation);

    if (history.length > 10) {
      history.removeAt(0);
    }

    prefs.setStringList('history', history);
  }

  void buttonPressed(String value) {
    setState(() {
      if (_isOperator(last) && _isOperator(value)) {
        return;
      }

      if (_isOperator(value)) {
        if (output.isEmpty) return;
        if (last == '.') hasDecimal = false;
      }

      if (last.isNotEmpty && last != '(' && value == '(') {
        output += '*';
      }

      switch (value) {
        case 'AC':
          output = '';
          hasDecimal = false;
          break;
        case 'backspace':
          if (output.isNotEmpty) {
            output = output.substring(0, output.length - 1);
            if (last == '.' || output.endsWith('.')) {
              hasDecimal = false;
            }
          }
          break;
        case '=':
          evaluate();
          break;
        case 'F':
          if (output.isNotEmpty) {
            int number = int.tryParse(output) ?? 0;
            output = factorial(number).toString();
          }
          break;
        case '.':
          if (!hasDecimal) {
            output += value;
            hasDecimal = true;
          }
          break;
        default:
          output += value;
      }

      last = value;
    });
  }

  bool _isOperator(String value) {
    return value == '+' ||
        value == '-' ||
        value == 'X' ||
        value == '/' ||
        value == '%';
  }

  int factorial(int n) {
    if (n < 0) return 0;
    if (n == 0) return 1;
    return n * factorial(n - 1);
  }

  void evaluate() {
    try {
      String formattedOutput = output.replaceAll('X', '*');
      print('Evaluating expression: $formattedOutput'); // Debugging line
      if (formattedOutput.isEmpty || _isOperator(last)) {
        print('Invalid expression: $formattedOutput');
        return;
      }

      Expression expression = Expression.parse(formattedOutput);
      const evaluator = ExpressionEvaluator();
      var result = evaluator.eval(expression, {});

      setState(() {
        output = result.toString();
        hasDecimal = output.contains('.');
      });

      _saveToHistory('$formattedOutput = $output');
    } catch (e) {
      print('Error during evaluation: $e'); // Debugging line
      setState(() {
        output = 'Error';
        hasDecimal = false;
      });
    }
  }

  void _toggleAdvanced() {
    setState(() {
      isAdvancedVisible = !isAdvancedVisible;
      if (isAdvancedVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calculation History'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(history[index],
                      style: const TextStyle(color: Colors.white)),
                );
              },
            ),
          ),
          backgroundColor: Colors.black,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Close', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
          ),
        ],
        title: const Text('Calculator'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.black,
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                children: [
                  const Text(
                    'By: Marwan Ahmed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('to contact Developer:'),
                      TextButton(
                        onPressed: () async {
                          try {
                            final Uri updateUrl = Uri(
                                scheme: 'https',
                                host: 'guns.lol',
                                path: '/kaiowa');
                            await launchUrl(updateUrl);
                          } catch (e) {
                            print(e.toString());
                          }
                        },
                        child: const Text(
                          'Click Here',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 153, 0, 255),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calculate, color: Colors.orange),
              title:
                  const Text('Advanced', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Additional()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.orange),
              title:
                  const Text('History', style: TextStyle(color: Colors.white)),
              onTap: () {
                _showHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.orange),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Additional()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerRight,
            child: Text(
              output,
              style: const TextStyle(fontSize: 48, color: Colors.white),
            ),
          ),
          _buildButtonRow(['AC', 'backspace', '%', '/']),
          _buildButtonRow(['7', '8', '9', 'X']),
          _buildButtonRow(['4', '5', '6', '-']),
          _buildButtonRow(['1', '2', '3', '+']),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: _toggleAdvanced,
                  child: const Icon(Icons.expand_more,
                      color: Colors.orange, size: 30),
                ),
              ),
              button('0'),
              button('.'),
              button('='),
            ],
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => buttonPressed('('),
                  style: _buttonStyle(),
                  child: const Text('(',
                      style: TextStyle(fontSize: 24, color: Colors.orange)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => buttonPressed(')'),
                  style: _buttonStyle(),
                  child: const Text(')',
                      style: TextStyle(fontSize: 24, color: Colors.orange)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => buttonPressed('F'),
                  style: _buttonStyle(),
                  child: const Text('F!',
                      style: TextStyle(fontSize: 24, color: Colors.orange)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: values.map((value) => button(value)).toList(),
    );
  }

  Widget button(String value) {
    return ElevatedButton(
      onPressed: value == 'backspace'
          ? () => buttonPressed(value)
          : () => buttonPressed(value),
      style: _buttonStyle(),
      child: value == 'backspace'
          ? const Icon(Icons.backspace, size: 24, color: Colors.orange)
          : Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.orange,
              ),
            ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      padding: const EdgeInsets.all(20.0),
      minimumSize: const Size(80, 80),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    );
  }
}
