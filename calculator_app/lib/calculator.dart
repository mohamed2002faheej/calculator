import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class Calculator extends StatefulWidget {
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String statement = "";
  String result = "0";
  final List<String> buttons = [
    '%',
    '(',
    ')',
    '/',
    '7',
    '8',
    '9',
    '*',
    '4',
    '5',
    '6',
    '+',
    '1',
    '2',
    '3',
    '-',
    'AC',
    '0',
    '.',
    '=',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Flexible(flex: 2, child: resultWidget()),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.backspace),
                  onPressed: () {
                    setState(() {
                      handleButtonTap("C"); // Backspace logic
                    });
                  },
                ),
              ],
            ),
            Expanded(flex: 4, child: _buttons()),
          ],
        ),
      ),
    );
  }

  Widget resultWidget() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerRight,
          child: Text(
            statement,
            style: TextStyle(fontSize: 32, color: Colors.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(15),
          alignment: Alignment.centerRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              result,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttons() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (BuildContext context, int index) {
        return _myButton(buttons[index]);
      },
      itemCount: buttons.length,
    );
  }

 _myButton(String text) {
  return Container(
    margin: const EdgeInsets.all(8),
    child: MaterialButton(
      onPressed: () {
        setState(() {
          handleButtonTap(text);
        });
      },
      color: _getColor(text),
      textColor: Colors.white,
      child: Text(
        text,
        style: const TextStyle(fontSize: 36),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Adjust the radius for your preference
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), // Adjust for button size
    ),
  );
}


  handleButtonTap(String text) {
    const operators = ['+', '-', '*', '/', '%'];

    if (text == "AC") {
      statement = "";
      result = "0";
      return;
    }
    if (text == "=") {
      result = calculate();
      if (result.endsWith(".0")) {
        result = result.replaceAll(".0", "");
      }
      if (result == "Error") {
        statement = "";
      }
      return;
    }

    if (text == "%") {
      if (statement.isNotEmpty) {
        statement = statement + "%";
      }
      return;
    }

    if (text == "C") {
      if (statement.isNotEmpty) {
        statement = statement.substring(0, statement.length - 1);
      }
      return;
    }

    if (operators.contains(text)) {
      if (statement.isEmpty || operators.contains(statement[statement.length - 1])) {
        return;
      }
    }

    if (text == ".") {
      if (statement.isNotEmpty && statement[statement.length - 1] == '.') {
        return;
      }
      for (int i = statement.length - 1; i >= 0; i--) {
        if (operators.contains(statement[i])) break;
        if (statement[i] == '.') return;
      }
    }

    statement = statement + text;
  }

  calculate() {
    try {
      if (!areParenthesesBalanced(statement)) {
        return "Error";
      }

      String statementForCalc = statement.replaceAllMapped(RegExp(r'(\d+)%'), (match) {
        return "${match.group(1)}/100";
      });

      var exp = Parser().parse(statementForCalc);
      var evaluation = exp.evaluate(EvaluationType.REAL, ContextModel());

      if (evaluation.isInfinite || evaluation.isNaN) {
        return "Error";
      }

      String resultStr = evaluation.toString();
      double resultDouble = double.parse(resultStr);
      resultStr = resultDouble.toStringAsFixed(8);

      if (resultStr.contains('.')) {
        resultStr = resultStr.replaceAll(RegExp(r'0*$'), '');
        if (resultStr.endsWith('.')) {
          resultStr = resultStr.substring(0, resultStr.length - 1);
        }
      }

      return resultStr;
    } catch (e) {
      return "Error";
    }
  }

  bool areParenthesesBalanced(String input) {
    int balance = 0;
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '(') balance++;
      if (input[i] == ')') balance--;
      if (balance < 0) return false;
    }
    return balance == 0;
  }

  _getColor(String text) {
    if (text == "/" || text == "*" || text == "+" || text == "-") {
      return const Color.fromARGB(255, 251, 181, 4);
    }
    if (text == "C" || text == "AC") {
      return const Color.fromARGB(255, 255, 217, 0);
    }
    if (text == "(" || text == ")") {
      return const Color.fromARGB(255, 74, 63, 3);
    }
    return const Color.fromARGB(255, 100, 95, 63);
  }
}
