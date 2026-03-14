import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C42),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: ThemeData.dark().textTheme,
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const List<String> _buttons = <String>[
    'C',
    'DEL',
    '%',
    '/',
    '7',
    '8',
    '9',
    '*',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '+/-',
    '0',
    '.',
    '=',
  ];

  String _expression = '0';
  String _result = '0';

  void _handleTap(String value) {
    setState(() {
      switch (value) {
        case 'C':
          _expression = '0';
          _result = '0';
          break;
        case 'DEL':
          _deleteLast();
          break;
        case '=':
          _calculate(commitResult: true);
          break;
        case '+/-':
          _toggleSign();
          break;
        case '%':
          _applyPercent();
          break;
        default:
          _appendValue(value);
      }
    });
  }

  void _appendValue(String value) {
    const operators = <String>{'+', '-', '*', '/'};
    if (_expression == '0' && !operators.contains(value) && value != '.') {
      _expression = value;
    } else if (operators.contains(value)) {
      final lastChar = _expression[_expression.length - 1];
      if (operators.contains(lastChar)) {
        _expression = _expression.substring(0, _expression.length - 1) + value;
      } else {
        _expression += value;
      }
    } else if (value == '.') {
      final currentNumber = _currentNumber();
      if (!currentNumber.contains('.')) {
        _expression += currentNumber.isEmpty ? '0.' : '.';
      }
    } else {
      _expression += value;
    }

    _calculate();
  }

  void _deleteLast() {
    if (_expression.length <= 1) {
      _expression = '0';
      _result = '0';
      return;
    }

    _expression = _expression.substring(0, _expression.length - 1);
    _calculate();
  }

  void _toggleSign() {
    final currentNumber = _currentNumber();
    if (currentNumber.isEmpty) {
      return;
    }

    final start = _expression.length - currentNumber.length;
    if (currentNumber.startsWith('-')) {
      _expression = _expression.replaceRange(start, _expression.length, currentNumber.substring(1));
    } else if (start == 0) {
      _expression = '-$currentNumber';
    } else {
      _expression = _expression.replaceRange(start, _expression.length, '-$currentNumber');
    }

    _calculate();
  }

  void _applyPercent() {
    final currentNumber = _currentNumber();
    if (currentNumber.isEmpty) {
      return;
    }

    final parsed = double.tryParse(currentNumber);
    if (parsed == null) {
      return;
    }

    final start = _expression.length - currentNumber.length;
    _expression = _expression.replaceRange(
      start,
      _expression.length,
      _formatNumber(parsed / 100),
    );
    _calculate();
  }

  void _calculate({bool commitResult = false}) {
    final evaluated = _evaluate(_expression);
    if (evaluated == null) {
      if (commitResult) {
        _result = 'Error';
      }
      return;
    }

    final formatted = _formatNumber(evaluated);
    _result = formatted;
    if (commitResult) {
      _expression = formatted;
    }
  }

  String _currentNumber() {
    final match = RegExp(r'(-?\d*\.?\d+)$').firstMatch(_expression);
    return match?.group(0) ?? '';
  }

  double? _evaluate(String input) {
    final sanitized = input.replaceAll(' ', '');
    if (sanitized.isEmpty) {
      return 0;
    }

    final tokens = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < sanitized.length; i++) {
      final char = sanitized[i];
      final isOperator = '+-*/'.contains(char);
      final isUnaryMinus = char == '-' &&
          (i == 0 || '+-*/'.contains(sanitized[i - 1]));

      if (isUnaryMinus) {
        buffer.write(char);
        continue;
      }

      if (isOperator) {
        if (buffer.length == 0) {
          return null;
        }
        tokens.add(buffer.toString());
        buffer.clear();
        tokens.add(char);
      } else {
        buffer.write(char);
      }
    }

    if (buffer.length > 0) {
      tokens.add(buffer.toString());
    }

    final numbers = <double>[];
    final ops = <String>[];

    int precedence(String operator) => operator == '+' || operator == '-' ? 1 : 2;

    double? apply(double left, double right, String operator) {
      switch (operator) {
        case '+':
          return left + right;
        case '-':
          return left - right;
        case '*':
          return left * right;
        case '/':
          if (right == 0) {
            return null;
          }
          return left / right;
      }
      return null;
    }

    for (final token in tokens) {
      final number = double.tryParse(token);
      if (number != null) {
        numbers.add(number);
        continue;
      }

      while (ops.isNotEmpty && precedence(ops.last) >= precedence(token)) {
        if (numbers.length < 2) {
          return null;
        }
        final right = numbers.removeLast();
        final left = numbers.removeLast();
        final result = apply(left, right, ops.removeLast());
        if (result == null) {
          return null;
        }
        numbers.add(result);
      }
      ops.add(token);
    }

    while (ops.isNotEmpty) {
      if (numbers.length < 2) {
        return null;
      }
      final right = numbers.removeLast();
      final left = numbers.removeLast();
      final result = apply(left, right, ops.removeLast());
      if (result == null) {
        return null;
      }
      numbers.add(result);
    }

    return numbers.length == 1 ? numbers.single : null;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(8).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  bool _isOperator(String label) => '+-*/='.contains(label);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFF1E1E1E), Color(0xFF2B2B2B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        _expression,
                        maxLines: 2,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _result,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 2,
                child: GridView.builder(
                  itemCount: _buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final label = _buttons[index];
                    final isPrimary = label == '=' || _isOperator(label);
                    final isUtility = label == 'C' || label == 'DEL' || label == '+/-' || label == '%';

                    return _CalculatorButton(
                      label: label,
                      onTap: () => _handleTap(label),
                      backgroundColor: isPrimary
                          ? const Color(0xFFFF8C42)
                          : isUtility
                              ? const Color(0xFF3A3A3A)
                              : const Color(0xFF252525),
                      foregroundColor: Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}
