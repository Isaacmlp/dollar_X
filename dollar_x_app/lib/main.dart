import 'package:dollar_x_app/Controller/MainPageController.dart';
import 'package:dollar_x_app/Utils/scrapperUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Future<void> _copyToClipboardBs(BuildContext context) async {
    final textToCopy = _controller.bsController.text;
    if (textToCopy.isEmpty) return;
    
    try {
      await Clipboard.setData(ClipboardData(text: textToCopy));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Copiado al portapapeles"),
          backgroundColor: Colors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al copiar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyToClipboardUSD(BuildContext context) async {
    final textToCopy = _controller.dollarController.text;
    if (textToCopy.isEmpty) return;
    
    try {
      await Clipboard.setData(ClipboardData(text: textToCopy));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Copiado al portapapeles"),
          backgroundColor: Colors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al copiar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              Builder(
                builder: (context) =>
                  TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Dolar',
                      errorText: _controller.dollarError,
                      suffixIcon: IconButton(onPressed: () => _copyToClipboardUSD(context), icon: const Icon(Icons.copy)),
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
                
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) => TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Bs',
                    errorText: _controller.bsError,
                    suffixIcon: IconButton(onPressed: () => _copyToClipboardBs(context), icon: const Icon(Icons.copy)),
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
