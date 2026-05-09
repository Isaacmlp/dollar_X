import 'package:dollar_x_app/Controller/MainPageController.dart';
import 'package:dollar_x_app/Widgets/currency_textfield.dart';
import 'package:dollar_x_app/presentation/Constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MainPageController _controller;
  late Future<String?> _tasaFuture;

  Future<void> _handleRefresh() async {
    setState(() {
      _tasaFuture = _controller.fetchTasa();
    });
    await _tasaFuture;
  }

  @override
  void initState() {
    super.initState();
    _controller = MainPageController(
      dollarController: TextEditingController(text: "1"),
      bsController: TextEditingController(),
    );
    _tasaFuture = _controller.fetchTasa();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: tasaAppBar(), backgroundColor: AppColors.secondary),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            CurrencyTextField(
                              controller: _controller,
                              label: 'Dolar',
                              getErrorText: () => _controller.dollarError,
                              textController: _controller.dollarController,
                              onChanged: (value) {
                                setState(() {
                                  _controller.validatorsUSD(value);
                                  value = _controller.dollarController.text;
                                  if (value.isNotEmpty) {
                                    final parsed = double.tryParse(value);
                                    if (parsed != null) {
                                      _controller.setBsValue(
                                        parsed * _controller.dollar,
                                      );
                                    }
                                  }
                                });
                              },
                              onCopy: (ctx) =>
                                  _controller.copyToClipboardUSD(ctx),
                            ),
                            const SizedBox(height: 16),
                            CurrencyTextField(
                              controller: _controller,
                              label: 'Bs',
                              getErrorText: () => _controller.bsError,
                              textController: _controller.bsController,
                              onChanged: (value) {
                                setState(() {
                                  _controller.validatorsBS(value);
                                  value = _controller.bsController.text;
                                  if (value.isNotEmpty) {
                                    final parsed = double.tryParse(value);
                                    if (parsed != null) {
                                      _controller.setDollarValue(
                                        parsed / _controller.dollar,
                                      );
                                    }
                                  }
                                });
                              },
                              onCopy: (ctx) =>
                                  _controller.copyToClipboardBs(ctx),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    CalcButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  FutureBuilder<String?> tasaAppBar() {
    return FutureBuilder<String?>(
      future: _tasaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Cargando...");
        } else if (snapshot.hasError) {
          return const Text("Error al cargar");
        } else {
          return Text(
            "Dollar X  Tasa: ${snapshot.data ?? 'N/A'}",
            style: const TextStyle(color: Colors.white),
          );
        }
      },
    );
  }
}

class CalcButton extends StatefulWidget {
  const CalcButton({super.key});

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  double? _currentValue = 0;
  @override
  Widget build(BuildContext context) {
    var calc = SimpleCalculator(
      value: _currentValue!,
      hideExpression: false,
      hideSurroundingBorder: true,
      autofocus: true,
      onChanged: (key, value, expression) {
        setState(() {
          _currentValue = value ?? 0;
        });
        if (kDebugMode) {
          print('$key\t$value\t$expression');
        }
      },
      onTappedDisplay: (value, details) {
        if (kDebugMode) {
          print('$value\t${details.globalPosition}');
        }
      },
      theme: const CalculatorThemeData(
        borderColor: Colors.black,
        borderWidth: 2,
        displayColor: Colors.black,
        displayStyle: TextStyle(fontSize: 80, color: AppColors.primary),
        expressionColor: Colors.indigo,
        expressionStyle: TextStyle(fontSize: 20, color: Colors.white),
        operatorColor: Colors.cyan,
        operatorStyle: TextStyle(fontSize: 30, color: Colors.white),
        commandColor: AppColors.secondary,
        commandStyle: TextStyle(fontSize: 30, color: Colors.white),
        numColor: AppColors.background,
        numStyle: TextStyle(fontSize: 50, color: Colors.white),
        equalColor: Colors.blueGrey,
        equalStyle: TextStyle(fontSize: 50, color: Colors.black),
      ),
    );
    return OutlinedButton(
      child: Text("Calculadora: ${_currentValue.toString()}"),
      onPressed: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: calc,
            );
          },
        );
      },
    );
  }
}
