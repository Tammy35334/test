import 'package:flutter/material.dart';
import '../models/emoji_reaction.dart';

class SelectedEmojiNotifier extends ValueNotifier<EmojiType> {
  SelectedEmojiNotifier() : super(EmojiType.heart); // Default to heart emoji

  static SelectedEmojiNotifier of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_SelectedEmojiInherited>();
    if (inherited == null) {
      throw FlutterError(
        'SelectedEmojiNotifier.of() called with a context that does not contain a SelectedEmojiProvider.\n'
        'No SelectedEmojiProvider ancestor could be found starting from the context that was passed '
        'to SelectedEmojiNotifier.of().'
      );
    }
    return inherited.notifier;
  }
}

class SelectedEmojiProvider extends StatefulWidget {
  final Widget child;

  const SelectedEmojiProvider({
    super.key,
    required this.child,
  });

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

  @override
  bool updateShouldNotify(_SelectedEmojiInherited old) => notifier != old.notifier;
}
