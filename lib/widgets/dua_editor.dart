import 'package:duas/models/dua_model.dart';
import 'package:duas/models/states.dart';
import 'package:duas/widgets/dua_find_flow.dart';
import 'package:duas/utils/toast.dart';
import 'package:flutter/material.dart';

/// A bottom sheet to add a new dua, or edit one the user added before.
/// Everything is plain text: people just paste what they have.
class DuaEditor extends StatefulWidget {
  final DuaModel? existing;

  /// The page that opened this sheet. It outlives the sheet, so the "find with
  /// AI" steps can carry on after this sheet closes.
  final BuildContext rootContext;
  const DuaEditor({super.key, this.existing, required this.rootContext});

  static Future<void> show(BuildContext context, {DuaModel? existing}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => DuaEditor(existing: existing, rootContext: context),
    );
  }

  @override
  State<DuaEditor> createState() => _DuaEditorState();
}

class _DuaEditorState extends State<DuaEditor> {
  late final TextEditingController _arabic;
  late final TextEditingController _meaning;
  late final TextEditingController _source;
  String? _error;

  // "Find with AI"
  final TextEditingController _ask = TextEditingController();
  String? _findError;

  @override
  void initState() {
    super.initState();
    _arabic = TextEditingController(text: widget.existing?.arabic ?? '');
    _meaning = TextEditingController(text: widget.existing?.meaning ?? '');
    _source = TextEditingController(text: widget.existing?.source ?? '');
  }

  @override
  void dispose() {
    _arabic.dispose();
    _meaning.dispose();
    _source.dispose();
    _ask.dispose();
    super.dispose();
  }

  /// Closes this sheet, shows a loading box, then a sheet with the duas found
  /// in the book. With nothing typed it opens the list of all topics.
  void _find({bool browse = false}) {
    final query = browse ? '' : _ask.text.trim();
    final root = widget.rootContext;
    Navigator.of(context).pop();
    DuaFindFlow.start(
      root,
      query,
      onManual: () => DuaEditor.show(root),
    );
  }

  void _save() {
    if (_arabic.text.trim().isEmpty && _meaning.text.trim().isEmpty) {
      setState(() => _error = 'Paste or type the dua first.');
      return;
    }
    final s = states.state;
    final existing = widget.existing;
    if (existing?.id != null) {
      s.updateDua(existing!.id!,
          arabic: _arabic.text, meaning: _meaning.text, source: _source.text);
    } else {
      s.addDua(
          arabic: _arabic.text, meaning: _meaning.text, source: _source.text);
    }
    Navigator.of(context).pop();
    showToast(context, existing == null ? 'Dua added' : 'Dua updated');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final editing = widget.existing != null;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(editing ? 'Edit dua' : 'Add a dua',
                    style: TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(
                  'Paste or type it. Only one of the first two boxes is needed.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                if (!editing) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.menu_book_rounded,
                                size: 18, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text('Find a dua in 4 collections',
                                  style: textTheme.titleSmall),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ask,
                                textInputAction: TextInputAction.search,
                                onSubmitted: (_) => _find(),
                                decoration: InputDecoration(
                                  hintText:
                                      'For example: anxiety, travelling, sleeping',
                                  isDense: true,
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _find,
                              style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 44)),
                              child: const Text('Find'),
                            ),
                          ],
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: () => _find(browse: true),
                            icon: const Icon(Icons.list_rounded, size: 18),
                            label: const Text('Browse all topics'),
                          ),
                        ),
                        if (_findError != null) ...[
                          const SizedBox(height: 8),
                          Text(_findError!,
                              style: textTheme.bodySmall
                                  ?.copyWith(color: colorScheme.error)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _arabic,
                  autofocus: !editing,
                  minLines: 3,
                  maxLines: 8,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 22, height: 1.8),
                  decoration: const InputDecoration(
                    labelText: 'Arabic',
                    hintText: 'Paste the Arabic text here',
                    alignLabelWithHint: true,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _meaning,
                  minLines: 2,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Meaning (translation)',
                    hintText: 'What it means, in your language',
                    alignLabelWithHint: true,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _source,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  decoration: const InputDecoration(
                    labelText: 'Source (optional)',
                    hintText: 'For example: Surah Al-Baqarah 2:201',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: TextStyle(color: colorScheme.error)),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(editing ? 'Save' : 'Add dua'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
