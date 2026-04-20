import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shimmerValue = _controller.value;
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + shimmerValue * 3, 0),
              end: Alignment(shimmerValue * 3, 0),
              colors: const [
                Color(0x22FFFFFF),
                Color(0x55FFFFFF),
                Color(0x22FFFFFF),
              ],
            ).createShader(bounds);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                _shimmerBox(height: 24, width: 140),
                const SizedBox(height: 32),
                _shimmerBox(height: 96, width: 160),
                const SizedBox(height: 8),
                _shimmerBox(height: 48, width: 80),
                const SizedBox(height: 8),
                _shimmerBox(height: 18, width: 120),
                const SizedBox(height: 32),
                _shimmerBox(height: 80, width: double.infinity),
                const SizedBox(height: 20),
                _shimmerHourly(),
                const SizedBox(height: 20),
                _shimmerBox(height: 240, width: double.infinity),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width == double.infinity ? null : width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _shimmerHourly() {
    return SizedBox(
      height: 110,
      child: Row(
        children: List.generate(
          5,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Маленький shimmer-блок для inline использования
class ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + _controller.value * 3, 0),
              end: Alignment(_controller.value * 3, 0),
              colors: const [
                Color(0x22FFFFFF),
                Color(0x55FFFFFF),
                Color(0x22FFFFFF),
              ],
            ).createShader(bounds);
          },
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

