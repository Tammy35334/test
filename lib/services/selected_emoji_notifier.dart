import 'package:flutter/material.dart';
import '../models/emoji_reaction.dart';

class SelectedEmojiNotifier extends ValueNotifier<EmojiType> {
  SelectedEmojiNotifier() : super(EmojiType.heart); // Default to heart emoji
}

class SelectedEmojiProvider extends StatefulWidget {
  final Widget child;

  const SelectedEmojiProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SelectedEmojiProvider> createState() => _SelectedEmojiProviderState();
}

class _SelectedEmojiProviderState extends State<SelectedEmojiProvider> {
  final _notifier = SelectedEmojiNotifier();

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SelectedEmojiInherited(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class _SelectedEmojiInherited extends InheritedWidget {
  final SelectedEmojiNotifier notifier;

  const _SelectedEmojiInherited({
    required this.notifier,
    required super.child,
  });

  static SelectedEmojiNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SelectedEmojiInherited>()!.notifier;
  }

  @override
  bool updateShouldNotify(_SelectedEmojiInherited old) => notifier != old.notifier;
}
