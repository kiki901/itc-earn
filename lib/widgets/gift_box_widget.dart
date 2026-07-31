import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/theme/app_theme.dart';

class GiftBoxWidget extends StatefulWidget {
  const GiftBoxWidget({Key? key}) : super(key: key);

  @override
  State<GiftBoxWidget> createState() => _GiftBoxWidgetState();
}

class _GiftBoxWidgetState extends State<GiftBoxWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromProvider();
    });
  }

  void _initFromProvider() {
    final provider = context.read<DemoProvider>();
    _timeRemaining = provider.timeUntilNextGiftBox;
    if (provider.isGiftBoxAvailable && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => _updateCountdown());
    setState(() {});
  }

  void _updateCountdown() {
    if (!mounted) return;
    final provider = context.read<DemoProvider>();
    setState(() {
      _timeRemaining = provider.timeUntilNextGiftBox;
    });
    if (provider.isGiftBoxAvailable && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!provider.isGiftBoxAvailable) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final loc = AppLocalizations.of(context);
    if (hours > 0) return '${hours} ${loc.giftBoxHours} ${minutes} ${loc.giftBoxMinutes}';
    if (minutes > 0) return '${minutes} ${loc.giftBoxMinutes} ${seconds} ${loc.giftBoxSeconds}';
    return '${seconds} ${loc.giftBoxSeconds}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<DemoProvider>(
      builder: (context, provider, _) {
        final isAvailable = provider.isGiftBoxAvailable;

        return GestureDetector(
          onTap: isAvailable ? () => _openGiftBox(provider) : null,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isAvailable ? _scaleAnimation.value : 1.0,
                child: child,
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAvailable
                      ? [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFCD56)]
                      : [AppColors.grey400, AppColors.grey500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isAvailable ? Color(0xFFFF6B6B) : Colors.grey).withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '🎁',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.giftBox,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          isAvailable ? loc.giftBoxAvailable : _formatDuration(_timeRemaining),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAvailable ? loc.giftBoxOpen : _formatDuration(_timeRemaining),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openGiftBox(DemoProvider provider) async {
    final reward = await provider.claimGiftBox();

    if (reward > 0 && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _GiftBoxDialog(reward: reward),
      );
    }
  }
}

class _GiftBoxDialog extends StatefulWidget {
  final double reward;
  const _GiftBoxDialog({required this.reward});

  @override
  State<_GiftBoxDialog> createState() => _GiftBoxDialogState();
}

class _GiftBoxDialogState extends State<_GiftBoxDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _rotateAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF6B6B).withOpacity(0.3),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _rotateAnim,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnim.value * 0.1,
                    child: child,
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF6B6B).withOpacity(0.4),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text('🎁', style: TextStyle(fontSize: 48)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                loc.giftBoxCongrats,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                loc.giftBoxGift,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey600,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '⭐',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '${widget.reward} ITC',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    loc.ok,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
