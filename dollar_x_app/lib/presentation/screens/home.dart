import 'package:dollar_x_app/Controller/MainPageController.dart';
import 'package:dollar_x_app/Widgets/currency_textfield.dart';
import 'package:dollar_x_app/presentation/Constants/colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MainPageController _controller;
  late Future<String?> _tasaFuture;

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
      appBar: AppBar(
        title: FutureBuilder<String?>(
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
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.neutral,
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
                            _controller.setBsValue(parsed * _controller.dollar);
                          }
                        }
                      });
                    },
                    onCopy: (ctx) => _controller.copyToClipboardUSD(ctx),
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
                                parsed / _controller.dollar);
                          }
                        }
                      });
                    },
                    onCopy: (ctx) => _controller.copyToClipboardBs(ctx),
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
