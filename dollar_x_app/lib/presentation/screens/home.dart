import 'dart:math';
import 'dart:ui' as ui;
import 'package:dollar_x_app/Controller/MainPageController.dart';
import 'package:dollar_x_app/Widgets/currency_textfield.dart';
import 'package:dollar_x_app/Widgets/simple_calculator.dart';
import 'package:dollar_x_app/presentation/Constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final MainPageController _controller;
  late Future<String?> _tasaFuture;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    _tasaFuture = _controller.fetchTasa().then((rate) {
      if (mounted) {
        _convertFrom();
        _animController.forward();
      }
      return rate;
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _refreshRate() {
    setState(() {
      _tasaFuture = _controller.fetchTasa().then((rate) {
        if (mounted) {
          _convertFrom();
        }
        return rate;
      });
    });
  }

  void _openCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CalcButton(),
    );
  }

  void _swapFields() {
    final fromText = _controller.dollarController.text;
    final bsText = _controller.bsController.text;
    _controller.dollarController.text = bsText;
    _controller.bsController.text = fromText;

    final fromVal = double.tryParse(bsText);
    final bsVal = double.tryParse(fromText);
    if (fromVal != null) {
      _controller.setBsValue(fromVal * _controller.currentRate);
    }
    if (bsVal != null) {
      _controller.setDollarValue(bsVal / _controller.currentRate);
    }
    setState(() {});
  }

  void _convertFrom() {
    final value = _controller.dollarController.text;
    if (value.isNotEmpty) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        _controller.setBsValue(parsed * _controller.currentRate);
      }
    }
  }

  void _convertTo() {
    final value = _controller.bsController.text;
    if (value.isNotEmpty) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        _controller.setDollarValue(parsed / _controller.currentRate);
      }
    }
  }

  void _selectCurrency(CurrencyType type) {
    if (_controller.selectedCurrency == type) return;
    setState(() {
      _controller.selectedCurrency = type;
      _convertFrom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100,
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Dollar X',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          _buildRateChip(),
        ],
      ),
    );
  }

  Widget _buildRateChip() {
    return FutureBuilder<String?>(
      future: _tasaFuture,
      builder: (context, snapshot) {
        final isWaiting = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError || snapshot.data == null;

        Color chipColor;
        String label;
        IconData icon;

        if (isWaiting) {
          chipColor = Colors.white.withValues(alpha: 0.15);
          label = 'Cargando...';
          icon = Icons.hourglass_top_rounded;
        } else if (hasError) {
          chipColor = AppColors.error.withValues(alpha: 0.2);
          label = 'Error al cargar';
          icon = Icons.error_outline_rounded;
        } else {
          chipColor = AppColors.success.withValues(alpha: 0.15);
          label =
              'Bs ${_controller.currentRate.toStringAsFixed(2)} / ${_controller.selectedCurrency.code}';
          icon = Icons.trending_up_rounded;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 0.3,
                ),
              ),
              if (!isWaiting && !hasError) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _refreshRate,
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundGradient,
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            Expanded(
              flex: 7,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildConversionCard(),
                ),
              ),
            ),
            const Spacer(flex: 1),
            _buildBottomActions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionCard() {
    final currency = _controller.selectedCurrency;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.cardGradient,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: CurrencyTextField(
                      key: ValueKey(currency),
                      label: currency.label,
                      currencyCode: currency.code,
                      leadingIcon: currency.icon,
                      getErrorText: () => _controller.dollarError,
                      textController: _controller.dollarController,
                      onChanged: (value) {
                        setState(() {
                          _controller.validatorsUSD(value);
                          _convertFrom();
                        });
                      },
                      onCopy: (ctx) => _controller.copyToClipboardUSD(ctx),
                    ),
                  ),
                  _buildDivider(),
                  CurrencyTextField(
                    label: 'Bolívares',
                    currencyCode: 'Bs',
                    leadingIcon: Icons.monetization_on_outlined,
                    getErrorText: () => _controller.bsError,
                    textController: _controller.bsController,
                    onChanged: (value) {
                      setState(() {
                        _controller.validatorsBS(value);
                        _convertTo();
                      });
                    },
                    onCopy: (ctx) => _controller.copyToClipboardBs(ctx),
                  ),
                  const SizedBox(height: 16),
                  _buildCurrencySelector(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Moneda de origen',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Row(
          children: CurrencyType.values.map((type) {
            final isSelected = _controller.selectedCurrency == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: type == CurrencyType.usd ? 0 : 6,
                  right: type == CurrencyType.usdt ? 0 : 6,
                ),
                child: _buildCurrencyChip(type, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCurrencyChip(CurrencyType type, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectCurrency(type),
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.primary.withValues(alpha: 0.15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.06),
              width: isSelected ? 1.2 : 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type.icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 4),
              Text(
                type.code,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: Colors.white12,
              thickness: 0.5,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _swapFields,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Icon(
                      Icons.swap_vert_rounded,
                      size: 20,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              color: Colors.white12,
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.calculate_rounded,
              label: 'Calculadora',
              onTap: _openCalculator,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              icon: Icons.refresh_rounded,
              label: 'Actualizar',
              onTap: _refreshRate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
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
