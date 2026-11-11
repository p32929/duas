import 'package:duas/models/states.dart';
import 'package:duas/utils/toast.dart';
import 'package:duas/utils/translator.dart';
import 'package:flutter/material.dart';

/// Translate one dua's meaning: pick a language (or type one), see the English
/// and the AI translation side by side, then keep it or not.
class TranslateSheet extends StatefulWidget {
  final String text;
  const TranslateSheet({super.key, required this.text});

  static Future<void> show(BuildContext context, String text) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => TranslateSheet(text: text),
    );
  }

  @override
  State<TranslateSheet> createState() => _TranslateSheetState();
}

class _TranslateSheetState extends State<TranslateSheet> {
  final TextEditingController _filter = TextEditingController();
  String _query = '';

  String? _language; // chosen language; null while picking
  String? _result;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  Future<void> _translate(String language) async {
    setState(() {
      _language = language;
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final r = await Translator.translate(language, widget.text);
      if (mounted) setState(() => _result = r);
    } on TranslateException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _keep() {
    Translator.save(_language!, widget.text, _result!);
    states.notify(); // the dua card shows it right away
    Navigator.of(context).pop();
    showToast(context, '$_language translation kept');
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;
    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 680, maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 0, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
          child: _language == null ? _picker(context) : _check(context),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- the picker

  Widget _picker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final q = _query.trim();
    final last = Translator.lastLanguage;
    final all = [
      if (last.isNotEmpty) last,
      ...Translator.languages.where((l) => l != last),
    ];
    final shown = q.isEmpty
        ? all
        : all.where((l) => l.toLowerCase().contains(q.toLowerCase())).toList();
    // a typed language that is not in the list can still be used
    final typedIsNew =
        q.isNotEmpty && !all.any((l) => l.toLowerCase() == q.toLowerCase());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Translate the meaning',
            style: TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface)),
        const SizedBox(height: 2),
        Text('Pick a language, or type any other.',
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        TextField(
          controller: _filter,
          autofocus: false,
          onChanged: (v) => setState(() => _query = v),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) _translate(_titleCase(v.trim()));
          },
          decoration: InputDecoration(
            hintText: 'Search or type a language',
            prefixIcon: const Icon(Icons.search_rounded),
            isDense: true,
            filled: true,
            fillColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (typedIsNew)
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: Text('Translate to “${_titleCase(q)}”'),
                  subtitle: const Text('Not in the list. The AI will try.'),
                  onTap: () => _translate(_titleCase(q)),
                ),
              for (final l in shown)
                ListTile(
                  dense: true,
                  title: Text(l),
                  subtitle: l == last && q.isEmpty
                      ? const Text('Used last time')
                      : null,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _translate(l),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _titleCase(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ---------------------------------------------- English next to the result

  Widget _check(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget box(String label, Widget child, {bool highlight = false}) =>
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: highlight
                ? colorScheme.primaryContainer.withValues(alpha: 0.45)
                : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              child,
            ],
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Check the translation',
            style: TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface)),
        const SizedBox(height: 2),
        Text('Compare it with the English. Keep it only if it is right.',
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                box(
                    'English',
                    Text(widget.text,
                        style: textTheme.bodyLarge?.copyWith(height: 1.55))),
                const SizedBox(height: 10),
                box(
                  '$_language · translated by AI (Qwen)',
                  _busy
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5)),
                              SizedBox(width: 12),
                              Text('Translating… this can take 1 to 2 minutes'),
                            ],
                          ),
                        )
                      : _error != null
                          ? Text(_error!,
                              style: TextStyle(color: colorScheme.error))
                          : Text(_result ?? '',
                              style: textTheme.bodyLarge
                                  ?.copyWith(fontSize: 18, height: 1.6)),
                  highlight: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            TextButton(
              onPressed: _busy ? null : () => setState(() => _language = null),
              child: const Text('Other language'),
            ),
            const Spacer(),
            if (!_busy && (_error != null || _result != null))
              TextButton(
                onPressed: () => _translate(_language!),
                child: const Text('Try again'),
              ),
            const SizedBox(width: 4),
            if (_result != null && !_busy) ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Discard'),
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: _keep,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Keep'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
