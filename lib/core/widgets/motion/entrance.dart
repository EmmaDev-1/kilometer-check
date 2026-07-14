import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../theme/app_motion.dart';

/// Entrada escalonada de contenido: fade + deslizamiento vertical sutil.
///
/// Usa [index] para escalonar la aparición de elementos consecutivos:
/// cada índice retrasa la animación `90ms` adicionales.
///
/// ```dart
/// Column(children: [
///   Entrance(index: 0, child: Header()),
///   Entrance(index: 1, child: Card()),
/// ]);
/// ```
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = AppMotion.slow,
    this.offsetY = 0.08,
  });

  final Widget child;
  final int index;
  final Duration duration;

  /// Desplazamiento vertical inicial, como fracción de la altura del child.
  final double offsetY;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(Duration(milliseconds: 90 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation animation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.easeOut,
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, widget.offsetY),
          end: Offset.zero,
        ).animate(animation),
        child: widget.child,
      ),
    );
  }
}
