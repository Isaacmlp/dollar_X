import 'package:dollar_x_app/Controller/MainPageController.dart';
import 'package:dollar_x_app/Utils/scrapperUtil.dart';
import 'package:flutter/material.dart';

double Dollar = 0.0;

Future<void> main() async {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final MainPageController _controller;
  late Future<String?> _tasaFuture;

  @override
  void initState() {
    super.initState();
    _controller = MainPageController(
      dollarController: TextEditingController(text: "1"),
      bsController: TextEditingController( ),
    );
    _tasaFuture = _mostrarTasa();
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _mostrarTasa() async {
    final precio = await ScrapperUtil.getDolarBcv();
    return precio?.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.greenAccent,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<String?>(
            future: _tasaFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Cargando...");
              } else if (snapshot.hasError) {
                return const Text("Error al cargar");
              } else {
                Dollar = double.parse(snapshot.data ?? '0.0');
                return Text("Dollar X  Tasa: ${snapshot.data ?? 'N/A'}", style: TextStyle(color: Colors.white),);
              }
            },
          ),
          backgroundColor: Colors.greenAccent,
        ),
        body: Center(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Dolar',
                  errorText: _controller.dollarError,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _controller.dollarController,
                onChanged: (value) {
                  setState(() {
                    value = _controller.dollarController.text;
                    if (value.isNotEmpty) {
                      double newValue;
                      newValue = Dollar * (double.parse(value));
                      _controller.bsController.text = newValue.toStringAsFixed(2);
                    }
                  }
                  );
                }
              ),
              const SizedBox(height: 16),
              TextField(
                
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Bs',
                  errorText: _controller.bsError,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _controller.bsController,
                onChanged: (value) {
                  setState(() {
                    value = _controller.bsController.text;
                    if (value.isNotEmpty) {
                      double newValue;
                      newValue = (double.parse(value)) / Dollar;
                      _controller.dollarController.text = newValue.toStringAsFixed(2);
                    }
                  }
                  );
                } ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
