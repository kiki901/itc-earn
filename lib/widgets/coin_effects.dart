import 'dart:math';
import 'package:flutter/material.dart';

class CoinExplosion extends StatefulWidget {
  final Offset origin;
  final int coinCount;
  final VoidCallback? onComplete;

  const CoinExplosion({
    super.key,
    required this.origin,
    this.coinCount = 12,
    this.onComplete,
  });

  @override
  State<CoinExplosion> createState() => _CoinExplosionState();
}

class _CoinExplosionState extends State<CoinExplosion>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _controllers = [];
    _animations = [];
    _scaleAnimations = [];
    _opacityAnimations = [];

    for (int i = 0; i < widget.coinCount; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 800 + random.nextInt(400)),
        vsync: this,
      );

      final angle = (2 * pi * i) / widget.coinCount + random.nextDouble() * 0.5;
      final distance = 80.0 + random.nextDouble() * 60.0;

      final animation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(cos(angle) * distance, sin(angle) * distance - 40),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

      final scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );

      final opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(0.6, 1.0, curve: Curves.easeIn),
        ),
      );

      _controllers.add(controller);
      _animations.add(animation);
      _scaleAnimations.add(scaleAnim);
      _opacityAnimations.add(opacityAnim);

      Future.delayed(Duration(milliseconds: i * 30), () {
        if (mounted) controller.forward();
      });
    }

    Future.delayed(Duration(milliseconds: 1500), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.coinCount, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, child) {
            return Positioned(
              left: widget.origin.dx + _animations[i].value.dx,
              top: widget.origin.dy + _animations[i].value.dy,
              child: Transform.scale(
                scale: _scaleAnimations[i].value,
                child: Opacity(
                  opacity: _opacityAnimations[i].value,
                  child: Text(
                    '💰',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class FlyingCoins extends StatefulWidget {
  final Offset start;
  final Offset end;
  final int count;
  final Duration duration;
  final VoidCallback? onComplete;

  const FlyingCoins({
    super.key,
    required this.start,
    required this.end,
    this.count = 6,
    this.duration = const Duration(milliseconds: 1000),
    this.onComplete,
  });

  @override
  State<FlyingCoins> createState() => _FlyingCoinsState();
}

class _FlyingCoinsState extends State<FlyingCoins>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.count,
      (i) => AnimationController(vsync: this, duration: widget.duration),
    );

    for (int i = 0; i < widget.count; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          _controllers[i].forward().then((_) {
            if (i == widget.count - 1) {
              widget.onComplete?.call();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.count, (i) {
        final random = Random(i);
        final curve = CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut);

        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, child) {
            final dx = Tween<double>(
              begin: widget.start.dx,
              end: widget.end.dx + random.nextDouble() * 20 - 10,
            ).transform(curve.value);

            final dy = Tween<double>(
              begin: widget.start.dy,
              end: widget.end.dy,
            ).transform(curve.value);

            final arcHeight = -80.0 - random.nextDouble() * 40;
            final arcDy = dy + arcHeight * sin(pi * curve.value);

            final opacity = curve.value < 0.8 ? 1.0 : (1.0 - curve.value) * 5;
            final scale = 0.5 + curve.value * 0.5;

            return Positioned(
              left: dx,
              top: arcDy,
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Text('💰', style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class CoinCounter extends StatefulWidget {
  final double amount;
  final TextStyle? style;

  const CoinCounter({super.key, required this.amount, this.style});

  @override
  State<CoinCounter> createState() => _CoinCounterState();
}

class _CoinCounterState extends State<CoinCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: _displayValue, end: widget.amount).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _animation.addListener(() {
      setState(() {
        _displayValue = _animation.value;
      });
    });
  }

  @override
  void didUpdateWidget(CoinCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _animation = Tween<double>(begin: _displayValue, end: widget.amount).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('💰', style: TextStyle(fontSize: (widget.style?.fontSize ?? 18) * 1.1)),
        SizedBox(width: 4),
        Text(
          _displayValue.toStringAsFixed(_displayValue == _displayValue.roundToDouble() ? 0 : 1),
          style: widget.style ?? TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
        ),
      ],
    );
  }
}
