import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/services/audio_service.dart';

class LuckyWheelScreen extends StatefulWidget {
  const LuckyWheelScreen({super.key});

  @override
  State<LuckyWheelScreen> createState() => _LuckyWheelScreenState();
}

class _LuckyWheelScreenState extends State<LuckyWheelScreen>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late Animation<double> _wheelAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isSpinning = false;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _prizes = [
    {'label': '1', 'color': Color(0xFF1A237E), 'icon': '💰', 'type': 'itc', 'value': 1.0},
    {'label': '2', 'color': Color(0xFF7C4DFF), 'icon': '💰', 'type': 'itc', 'value': 2.0},
    {'label': '🔄', 'color': Color(0xFFFF6B6B), 'icon': '🔄', 'type': 'freeroll', 'value': 0},
    {'label': '3', 'color': Color(0xFF00E5FF), 'icon': '💰', 'type': 'itc', 'value': 3.0},
    {'label': '4', 'color': Color(0xFFFFD700), 'icon': '💰', 'type': 'itc', 'value': 4.0},
    {'label': '5', 'color': Color(0xFF00E676), 'icon': '🏆', 'type': 'topprize', 'value': 5.0},
  ];

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );
    _wheelAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _wheelController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    final provider = context.read<DemoProvider>();
    if (!provider.isWheelAvailable) {
      return;
    }

    AudioService.playWheelSpin();
    setState(() {
      _isSpinning = true;
    });

    final random = Random();
    _selectedIndex = random.nextInt(_prizes.length);

    final segmentAngle = 360.0 / _prizes.length;
    final targetAngle = 360 * 8 + (360 - _selectedIndex * segmentAngle - segmentAngle / 2);

    _wheelController.reset();
    _wheelController.duration = Duration(seconds: 4 + random.nextInt(2));
    _wheelAnimation = Tween<double>(begin: 0, end: targetAngle * pi / 180).animate(
      CurvedAnimation(parent: _wheelController, curve: Curves.easeOutCubic),
    );

    _wheelController.forward().then((_) {
      if (!mounted) return;
      AudioService.playWheelStop();
      setState(() => _isSpinning = false);
      _claimPrize();
    });
  }

  void _paidSpinWheel() async {
    if (_isSpinning) return;
    final provider = context.read<DemoProvider>();
    final loc = AppLocalizations.of(context);

    if (!provider.canBuySpin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.insufficientBalanceForSpin), backgroundColor: Colors.red),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.buySpinAgain),
        content: Text(loc.confirmBuySpin),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.buy),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    AudioService.playWheelSpin();
    setState(() => _isSpinning = true);

    final result = await provider.buySpinWheel();
    if (result == null || !mounted) {
      setState(() => _isSpinning = false);
      return;
    }

    int prizeIndex = -1;
    if (result['type'] == 'freeroll') {
      prizeIndex = _prizes.indexWhere((p) => p['type'] == 'freeroll');
    } else if (result['type'] == 'topprize') {
      prizeIndex = _prizes.indexWhere((p) => p['type'] == 'topprize');
    } else {
      final itcIndices = [0, 1, 3, 4];
      prizeIndex = itcIndices[Random().nextInt(itcIndices.length)];
    }
    _selectedIndex = prizeIndex >= 0 ? prizeIndex : 0;

    final random = Random();
    final segmentAngle = 360.0 / _prizes.length;
    final targetAngle = 360 * 8 + (360 - _selectedIndex * segmentAngle - segmentAngle / 2);

    _wheelController.reset();
    _wheelController.duration = Duration(seconds: 4 + random.nextInt(2));
    _wheelAnimation = Tween<double>(begin: 0, end: targetAngle * pi / 180).animate(
      CurvedAnimation(parent: _wheelController, curve: Curves.easeOutCubic),
    );

    _wheelController.forward().then((_) {
      if (!mounted) return;
      AudioService.playWheelStop();
      setState(() => _isSpinning = false);
      _claimPaidPrize(result);
    });
  }

  void _claimPrize() async {
    if (!mounted) return;
    final prize = _prizes[_selectedIndex];
    final provider = context.read<DemoProvider>();
    final loc = AppLocalizations.of(context);

    try {
      await provider.spinWheel(prize['type'], prize['value']);
    } catch (e) {
      if (!mounted) return;
      return;
    }
    if (!mounted) return;

    AudioService.playSuccess();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surfaceLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.3),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text(
                loc.congratulations,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  prize['type'] == 'itc' || prize['type'] == 'topprize'
                      ? '+${prize['value']} ITC'
                      : loc.freeSpin,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              GradientButton(
                onTap: () {
                  AudioService.playButtonTap();
                  Navigator.pop(ctx);
                },
                gradient: AppColors.goldGradient,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Text(loc.close, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _claimPaidPrize(Map<String, dynamic> prize) async {
    if (!mounted) return;
    final loc = AppLocalizations.of(context);

    AudioService.playSuccess();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surfaceLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.3),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text(
                loc.congratulations,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  prize['type'] == 'itc' || prize['type'] == 'topprize'
                      ? '+${prize['value']} ITC'
                      : loc.freeSpin,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              GradientButton(
                onTap: () {
                  AudioService.playButtonTap();
                  Navigator.pop(ctx);
                },
                gradient: AppColors.primaryGradient,
                child: Center(child: Text(loc.ok, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.wheelTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer<DemoProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
                children: [
                  // Timer
                  GlassContainer(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, color: AppColors.gold, size: 20),
                        SizedBox(width: 8),
                        Text(
                          provider.isWheelAvailable
                              ? loc.wheelAvailableNow
                              : '${loc.wheelAvailableInHours} ${_formatDuration(provider.timeUntilNextWheel, loc)}',
                          style: TextStyle(
                            color: provider.isWheelAvailable ? AppColors.success : AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Wheel
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, _) {
                              return Container(
                                width: 280 * _pulseAnimation.value,
                                height: 280 * _pulseAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withOpacity(0.15 * _pulseAnimation.value),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Wheel
                          AnimatedBuilder(
                            animation: _wheelAnimation,
                            builder: (context, _) {
                              return Transform.rotate(
                                angle: _wheelAnimation.value,
                                child: CustomPaint(
                                  size: Size(260, 260),
                                  painter: WheelPainter(prizes: _prizes),
                                ),
                              );
                            },
                          ),

                          // Pointer
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 0,
                              height: 0,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(width: 14, color: Colors.transparent),
                                  right: BorderSide(width: 14, color: Colors.transparent),
                                  top: BorderSide(width: 28, color: AppColors.gold),
                                ),
                              ),
                            ),
                          ),

                          // Center circle
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.goldGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '🎡',
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Spin button
                  if (provider.isWheelAvailable)
                    ScaleTransition(
                      scale: _isSpinning
                          ? AlwaysStoppedAnimation(1.0)
                          : _pulseAnimation,
                      child: GradientButton(
                        onTap: _isSpinning ? null : _spinWheel,
                        gradient: _isSpinning
                            ? LinearGradient(colors: [AppColors.grey600, AppColors.grey500])
                            : AppColors.goldGradient,
                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                        child: Text(
                          _isSpinning ? loc.spinning : loc.spin,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _isSpinning ? Colors.white54 : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          '${loc.wheelAvailableInHours} ${_formatDuration(provider.timeUntilNextWheel, loc)}',
                          style: TextStyle(color: AppColors.gold, fontSize: 14),
                        ),
                        SizedBox(height: 12),
                        GradientButton(
                          onTap: _isSpinning ? null : _paidSpinWheel,
                          gradient: _isSpinning
                              ? LinearGradient(colors: [AppColors.grey600, AppColors.grey500])
                              : AppColors.purpleGradient,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          child: Text(
                            _isSpinning ? loc.spinning : loc.buySpinAgain,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isSpinning ? Colors.white54 : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d, AppLocalizations loc) {
    if (d.inHours > 0) return '${d.inHours} ${loc.hours}';
    return '${d.inMinutes} ${loc.minutes}';
  }
}

class WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> prizes;

  WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final paint = Paint()
        ..color = prizes[i]['color']
        ..style = PaintingStyle.fill;

      // Draw segment
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            segmentAngle,
            false,
          )
          ..close(),
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawLine(center, Offset(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      ), borderPaint);

      // Draw text
      final textPainter = TextPainter(
        text: TextSpan(
          text: prizes[i]['icon'],
          style: TextStyle(fontSize: 28),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.65;
      final textCenter = Offset(
        center.dx + textRadius * cos(textAngle) - textPainter.width / 2,
        center.dy + textRadius * sin(textAngle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textCenter);

      // Draw label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: prizes[i]['label'],
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();

      final labelRadius = radius * 0.42;
      final labelCenter = Offset(
        center.dx + labelRadius * cos(textAngle) - labelPainter.width / 2,
        center.dy + labelRadius * sin(textAngle) - labelPainter.height / 2,
      );

      labelPainter.paint(canvas, labelCenter);
    }

    // Draw outer ring
    final ringPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, ringPaint);

    // Draw dots on ring
    final dotPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 24; i++) {
      final angle = (2 * pi * i) / 24;
      final dotCenter = Offset(
        center.dx + (radius - 3) * cos(angle),
        center.dy + (radius - 3) * sin(angle),
      );
      canvas.drawCircle(dotCenter, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
