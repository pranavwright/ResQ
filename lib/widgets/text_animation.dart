import 'package:flutter/material.dart';


class LoadingResqAnimation extends StatefulWidget {
  final String text;
  const LoadingResqAnimation({super.key, required this.text});

  @override
  State<LoadingResqAnimation> createState() => _LoadingResqAnimationState();
}

class _LoadingResqAnimationState extends State<LoadingResqAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _textAnimation;
  late final String _resqText;
  int _currentTextLength = 0;
  @override
  void initState() {
    super.initState();
    _resqText = widget.text;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Adjust the speed of typing
    );

    _textAnimation = IntTween(begin: 0, end: _resqText.length).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {
        _currentTextLength = _textAnimation.value;
      });
    });

    _animationController.repeat(reverse: false); // Repeat the animation
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Text(
            _resqText.substring(0, _currentTextLength),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          );
  }
}
