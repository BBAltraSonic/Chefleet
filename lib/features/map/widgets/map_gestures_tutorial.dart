import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/glass_container.dart';

/// Tutorial overlay for first-time map users
class MapGesturesTutorial extends StatefulWidget {
  const MapGesturesTutorial({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  /// Check if tutorial should be shown
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('map_tutorial_completed') ?? false);
  }

  @override
  State<MapGesturesTutorial> createState() => _MapGesturesTutorialState();
}

class _MapGesturesTutorialState extends State<MapGesturesTutorial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentStep = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      icon: Icons.zoom_in_map_rounded,
      title: 'Pinch to Zoom',
      description: 'Use two fingers to zoom in and out of the map',
      position: TutorialPosition.center,
    ),
    TutorialStep(
      icon: Icons.pan_tool_rounded,
      title: 'Drag to Move',
      description: 'Swipe anywhere on the map to explore different areas',
      position: TutorialPosition.center,
    ),
    TutorialStep(
      icon: Icons.location_on_rounded,
      title: 'Tap Pins',
      description: 'Tap on a vendor pin to view their details and dishes',
      position: TutorialPosition.center,
    ),
    TutorialStep(
      icon: Icons.groups_rounded,
      title: 'Expand Clusters',
      description: 'Tap on a cluster to zoom in and see individual vendors',
      position: TutorialPosition.center,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _controller.reset();
      _controller.forward();
    } else {
      _complete();
    }
  }

  void _skip() {
    _complete();
  }

  Future<void> _complete() async {
    await _controller.reverse();
    // Mark tutorial as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('map_tutorial_completed', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _steps[_currentStep];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Stack(
          children: [
            // Main content centered
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with glow effect
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      step.icon,
                      size: 64,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tutorial content card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GlassContainer(
                      blur: 20,
                      opacity: 0.95,
                      borderRadius: 24,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              step.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              step.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Progress indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _steps.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: index == _currentStep ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: index == _currentStep
                                        ? theme.primaryColor
                                        : theme.primaryColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _skip,
                                  child: Text(
                                    'Skip',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                FilledButton(
                                  onPressed: _nextStep,
                                  child: Text(
                                    _currentStep == _steps.length - 1
                                        ? 'Got it!'
                                        : 'Next',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Skip button in top-right
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                onPressed: _skip,
                icon: const Icon(Icons.close_rounded),
                color: Colors.white,
                iconSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialStep {
  final IconData icon;
  final String title;
  final String description;
  final TutorialPosition position;

  TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.position,
  });
}

enum TutorialPosition {
  top,
  center,
  bottom,
}
