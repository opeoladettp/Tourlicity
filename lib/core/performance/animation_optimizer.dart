import 'package:flutter/material.dart';

/// Animation optimization utilities
class AnimationOptimizer {
  /// Creates an optimized fade transition
  static Widget buildOptimizedFadeTransition({
    required Animation<double> animation,
    required Widget child,
    bool alwaysIncludeSemantics = false,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          alwaysIncludeSemantics: alwaysIncludeSemantics,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates an optimized slide transition
  static Widget buildOptimizedSlideTransition({
    required Animation<Offset> position,
    required Widget child,
    bool transformHitTests = true,
  }) {
    return AnimatedBuilder(
      animation: position,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            position.value.dx * MediaQuery.of(context).size.width,
            position.value.dy * MediaQuery.of(context).size.height,
          ),
          transformHitTests: transformHitTests,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates an optimized scale transition
  static Widget buildOptimizedScaleTransition({
    required Animation<double> scale,
    required Widget child,
    Alignment alignment = Alignment.center,
  }) {
    return AnimatedBuilder(
      animation: scale,
      builder: (context, child) {
        return Transform.scale(
          scale: scale.value,
          alignment: alignment,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a performance-optimized list animation
  static Widget buildOptimizedListAnimation({
    required Animation<double> animation,
    required Widget child,
    int index = 0,
    Duration delay = Duration.zero,
  }) {
    final delayedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          (index * 0.1).clamp(0.0, 0.8),
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - delayedAnimation.value)),
          child: Opacity(
            opacity: delayedAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Optimizes animation controller settings
  static AnimationController createOptimizedController({
    required Duration duration,
    required TickerProvider vsync,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
  }) {
    return AnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      lowerBound: lowerBound,
      upperBound: upperBound,
      vsync: vsync,
    );
  }

  /// Creates a staggered animation for multiple items
  static List<Animation<double>> createStaggeredAnimations({
    required AnimationController controller,
    required int itemCount,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Curve curve = Curves.easeOutCubic,
  }) {
    final animations = <Animation<double>>[];
    
    for (int i = 0; i < itemCount; i++) {
      final start = (i * staggerDelay.inMilliseconds) / 
                   (controller.duration!.inMilliseconds);
      final end = ((i * staggerDelay.inMilliseconds) + 
                  controller.duration!.inMilliseconds) / 
                 (controller.duration!.inMilliseconds + 
                  (itemCount * staggerDelay.inMilliseconds));
      
      animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: curve),
          ),
        ),
      );
    }
    
    return animations;
  }
}

/// Optimized animated widget base class
abstract class OptimizedAnimatedWidget extends StatefulWidget {
  const OptimizedAnimatedWidget({super.key});
}

/// Mixin for optimizing animations
mixin AnimationOptimizationMixin<T extends StatefulWidget> on TickerProviderStateMixin<T> {
  final List<AnimationController> _controllers = [];
  
  /// Creates and tracks an animation controller
  AnimationController createController({
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    final controller = AnimationOptimizer.createOptimizedController(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      vsync: this,
    );
    
    _controllers.add(controller);
    return controller;
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// Optimized hero animation
class OptimizedHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final CreateRectTween? createRectTween;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  const OptimizedHero({
    super.key,
    required this.tag,
    required this.child,
    this.createRectTween,
    this.flightShuttleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: createRectTween ?? _createOptimizedRectTween,
      flightShuttleBuilder: flightShuttleBuilder ?? _optimizedFlightShuttleBuilder,
      child: child,
    );
  }

  static RectTween _createOptimizedRectTween(Rect? begin, Rect? end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  static Widget _optimizedFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Material(
          type: MaterialType.transparency,
          child: toHeroContext.widget,
        );
      },
    );
  }
}

/// Performance-aware animated list
class OptimizedAnimatedList extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;

  const OptimizedAnimatedList({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 600),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<OptimizedAnimatedList> createState() => _OptimizedAnimatedListState();
}

class _OptimizedAnimatedListState extends State<OptimizedAnimatedList>
    with TickerProviderStateMixin, AnimationOptimizationMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = createController(
      duration: widget.duration + 
                (widget.staggerDelay * widget.children.length),
    );
    
    _animations = AnimationOptimizer.createStaggeredAnimations(
      controller: _controller,
      itemCount: widget.children.length,
      staggerDelay: widget.staggerDelay,
      curve: widget.curve,
    );
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) => AnimationOptimizer.buildOptimizedListAnimation(
          animation: _animations[index],
          index: index,
          child: widget.children[index],
        ),
      ),
    );
  }
}

/// Memory-efficient animated switcher
class OptimizedAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  const OptimizedAnimatedSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.switchInCurve = Curves.easeIn,
    this.switchOutCurve = Curves.easeOut,
    this.transitionBuilder = _defaultTransitionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: reverseDuration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder,
      child: RepaintBoundary(
        key: ValueKey(child.key),
        child: child,
      ),
    );
  }

  static Widget _defaultTransitionBuilder(
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

/// Animation performance metrics
class AnimationMetrics {
  static void trackAnimationPerformance(
    AnimationController controller,
    String name,
  ) {
    controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          debugPrint('Animation $name started forward');
          break;
        case AnimationStatus.completed:
          debugPrint('Animation $name completed');
          break;
        case AnimationStatus.reverse:
          debugPrint('Animation $name started reverse');
          break;
        case AnimationStatus.dismissed:
          debugPrint('Animation $name dismissed');
          break;
      }
    });
  }
}
