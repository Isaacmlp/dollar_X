import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class CalcButton extends StatefulWidget {
  const CalcButton({Key? key}) : super(key: key);

  @override
  CalcButtonState createState() => CalcButtonState();
}

class CalcButtonState extends State<CalcButton> {
  double? _currentValue = 0;

  @override
  Widget build(BuildContext context) {
    final calc = SimpleCalculator(
      value: _currentValue!,
      hideExpression: false,
      hideSurroundingBorder: true,
      autofocus: true,
      onChanged: (key, value, expression) {
        setState(() {
          _currentValue = value ?? 0;
        });
      },
      onTappedDisplay: (value, details) {},
      theme: const CalculatorThemeData(
        borderColor: Colors.transparent,
        borderWidth: 0,
        displayColor: Color(0xFF0F1923),
        displayStyle: TextStyle(
          fontSize: 64,
          color: Colors.white,
          fontWeight: FontWeight.w200,
        ),
        expressionColor: Color(0xFF0F1923),
        expressionStyle: TextStyle(
          fontSize: 20,
          color: Colors.white38,
        ),
        operatorColor: Color(0xFF00D4FF),
        operatorStyle: TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        commandColor: Color(0xFF00F5D4),
        commandStyle: TextStyle(
          fontSize: 28,
          color: Color(0xFF0F1923),
          fontWeight: FontWeight.w600,
        ),
        numColor: Color(0xFF1A2D42),
        numStyle: TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        equalColor: Color(0xFF00D4FF),
        equalStyle: TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1923),
              Color(0xFF0B0E14),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: calc,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
