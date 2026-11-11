import 'package:duas/models/states.dart';
import 'package:duas/theme/app_fonts.dart';
import 'package:duas/utils/hisn_muslim.dart';
import 'package:duas/utils/library.dart';
import 'package:duas/utils/toast.dart';
import 'package:flutter/material.dart';

/// A group of duas shown together, for example "Hisn al-Muslim · Invocations
/// for anguish" or "Dua & Dhikr".
class _Section {
  final String title;
  final List<DuaSuggestion> duas;
  const _Section(this.title, this.duas);
}

/// One entry of the topic list: a topic of one collection.
class _Topic {
  final String group;
  final String label;
  final Future<List<DuaSuggestion>> Function() load;
  const _Topic(this.group, this.label, this.load);
}

/// "Find a dua": shows a loading box, then a sheet with the duas from
/// Hisn al-Muslim that match, so the person can tick the ones they want and
/// add them in one go. With an empty search it opens the list of all topics.
class DuaFindFlow {
  /// [context] must stay alive after the add form closes (use the page's).
  /// [onManual] is called when the person chooses to type the dua themselves.
  static Future<void> start(
    BuildContext context,
    String query, {
    required VoidCallback onManual,
  }) async {
    final q = query.trim();
    var cancelled = false;
    final nav = Navigator.of(context, rootNavigator: true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LoadingDialog(
        query: q,
        onCancel: () {
          cancelled = true;
          nav.pop();
        },
      ),
    );

    final sections = <_Section>[];
    final topics = <_Topic>[];
    String? error;

    // 1. Hisn al-Muslim (online)
    try {
      final all = await HisnMuslim.chapters();
      for (final c in all) {
        topics.add(
            _Topic(HisnMuslim.bookName, c.title, () => HisnMuslim.duas(c)));
      }
      if (q.isNotEmpty) {
        for (final c in HisnMuslim.match(all, q).take(3)) {
          sections.add(_Section(
              '${HisnMuslim.bookName} · ${c.title}', await HisnMuslim.duas(c)));
        }
      }
    } catch (_) {
      // carry on with the other collections
    }

    // 2. The other collections
    for (final col in Library.all) {
      if (cancelled) return;
      try {
        final duas = await col.duas();
        for (final t in await col.topics()) {
          topics.add(_Topic(
              col.name,
              t,
              () async => [
                    for (final d in duas)
                      if (d.topic == t) d.toSuggestion()
                  ]));
        }
        if (q.isNotEmpty) {
          final found = Library.search(duas, q);
          if (found.isNotEmpty) {
            sections.add(
                _Section(col.name, [for (final d in found) d.toSuggestion()]));
          }
        }
      } catch (_) {
        // one collection being unavailable must not stop the others
      }
    }

    if (topics.isEmpty) {
      error = 'Could not open the dua collections. Check your internet '
          'connection and try again.';
    }

    if (cancelled || !context.mounted) return;
    nav.pop(); // close the loading box

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => _ResultsSheet(
        query: q,
        topics: topics,
        sections: sections,
        error: error,
        onTryAgain: () {
          Navigator.of(sheetContext).pop();
          start(context, q, onManual: onManual);
        },
        onManual: () {
          Navigator.of(sheetContext).pop();
          onManual();
        },
        onAdded: (message) => showToast(context, message),
      ),
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  final String query;
  final VoidCallback onCancel;
  const _LoadingDialog({required this.query, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                    strokeWidth: 4, color: colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text(query.isEmpty ? 'Opening the book…' : 'Looking for duas…',
                  style: TextStyle(
                      fontFamily: 'Newsreader',
                      fontSize: 24,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(
                query.isEmpty
                    ? 'Hisn al-Muslim and 3 more collections'
                    : '“$query” in 4 collections',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsSheet extends StatefulWidget {
  final String query;
  final List<_Topic> topics;
  final List<_Section> sections;
  final String? error;
  final VoidCallback onTryAgain;
  final VoidCallback onManual;
  final ValueChanged<String> onAdded;

  const _ResultsSheet({
    required this.query,
    required this.topics,
    required this.sections,
    required this.error,
    required this.onTryAgain,
    required this.onManual,
    required this.onAdded,
  });

  @override
  State<_ResultsSheet> createState() => _ResultsSheetState();
}

class _ResultsSheetState extends State<_ResultsSheet> {
  late List<_Section> _sections = widget.sections;

  /// true: the list of all topics is shown instead of duas
  late bool _browsing = widget.error == null && widget.sections.isEmpty;

  /// the topic list filter
  final TextEditingController _topicFilter = TextEditingController();
  String _filter = '';

  bool _opening = false;
  final Set<DuaSuggestion> _picked = {};

  @override
  void dispose() {
    _topicFilter.dispose();
    super.dispose();
  }

  List<DuaSuggestion> get _allShown => [for (final s in _sections) ...s.duas];

  static String _norm(String s) => s.replaceAll(RegExp(r'[ً-ٰٟ\s]'), '');

  Future<void> _openTopic(_Topic t) async {
    setState(() => _opening = true);
    try {
      final duas = await t.load();
      if (!mounted) return;
      setState(() {
        _sections = [_Section('${t.group} · ${t.label}', duas)];
        _browsing = false;
        _picked.clear();
      });
    } catch (_) {
      if (mounted) {
        showToast(context, 'Could not open that topic. Try again.');
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _addPicked() {
    final s = states.state;
    final have = s.myDuas.map((d) => _norm(d.arabic)).toSet();
    var added = 0;
    var skipped = 0;
    // keep the order shown: add from the last to the first, so the first
    // ends up on top
    final ordered = _allShown.where(_picked.contains).toList().reversed;
    for (final d in ordered) {
      if (!have.add(_norm(d.arabic))) {
        skipped++;
        continue;
      }
      s.addDua(arabic: d.arabic, meaning: d.meaning, source: d.source);
      added++;
    }
    Navigator.of(context).pop();
    var msg = added == 1 ? '1 dua added' : '$added duas added';
    if (skipped > 0) msg += ' ($skipped already in your list)';
    widget.onAdded(msg);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    final String title;
    final String subtitle;
    if (widget.error != null) {
      title = 'Could not open the collections';
      subtitle = 'Hisn al-Muslim and others';
    } else if (_browsing) {
      title = 'Pick a topic';
      subtitle = widget.query.isEmpty || widget.sections.isNotEmpty
          ? '${widget.topics.length} topics in 4 collections'
          : 'Nothing matched “${widget.query}”. Pick a topic instead.';
    } else {
      final n = _allShown.length;
      title = n == 1 ? '1 dua' : '$n duas';
      subtitle = _sections.length == 1
          ? _sections.first.title
          : 'From ${_sections.length} places, best matches first';
    }

    // shrink to the content (heightFactor) so there is no empty gap on top
    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 680, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Newsreader',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface)),
              const SizedBox(height: 2),
              Text(subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              if (widget.error != null)
                ..._errorView(context)
              else if (_browsing)
                ..._topicsView(context)
              else
                ..._duasView(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _errorView(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(widget.error!,
            style: textTheme.bodyMedium?.copyWith(height: 1.5)),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
              onPressed: widget.onManual, child: const Text('Type it myself')),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: widget.onTryAgain,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _topicsView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final f = _filter.trim().toLowerCase();
    final topics = f.isEmpty
        ? widget.topics
        : widget.topics
            .where((t) =>
                t.label.toLowerCase().contains(f) ||
                t.group.toLowerCase().contains(f))
            .toList();
    // a header row before each collection
    final rows = <Object>[];
    String? group;
    for (final t in topics) {
      if (t.group != group) {
        group = t.group;
        rows.add(group);
      }
      rows.add(t);
    }
    return [
      TextField(
        controller: _topicFilter,
        onChanged: (v) => setState(() => _filter = v),
        decoration: InputDecoration(
          hintText: 'Filter topics',
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
      const SizedBox(height: 10),
      if (_opening) const LinearProgressIndicator(minHeight: 3),
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final r = rows[i];
            if (r is String) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
                child: Text(r,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: colorScheme.primary)),
              );
            }
            final t = r as _Topic;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              title: Text(t.label),
              trailing: const Icon(Icons.chevron_right_rounded),
              enabled: !_opening,
              onTap: () => _openTopic(t),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          if (_sections.isNotEmpty)
            TextButton.icon(
              onPressed: () => setState(() => _browsing = false),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to results'),
            ),
          const Spacer(),
          TextButton(
            onPressed: widget.onManual,
            child: const Text('Type it myself'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _duasView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shown = _allShown;
    final children = <Widget>[];
    for (final s in _sections) {
      if (_sections.length > 1) {
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text(s.title,
              style:
                  textTheme.titleSmall?.copyWith(color: colorScheme.primary)),
        ));
      }
      for (final d in s.duas) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ResultTile(
            dua: d,
            picked: _picked.contains(d),
            onTap: () => setState(
                () => _picked.contains(d) ? _picked.remove(d) : _picked.add(d)),
          ),
        ));
      }
    }
    return [
      Flexible(child: ListView(shrinkWrap: true, children: children)),
      const SizedBox(height: 10),
      Row(
        children: [
          TextButton(
            onPressed: () => setState(() {
              if (_picked.length == shown.length) {
                _picked.clear();
              } else {
                _picked
                  ..clear()
                  ..addAll(shown);
              }
            }),
            child:
                Text(_picked.length == shown.length ? 'Clear' : 'Select all'),
          ),
          TextButton(
            onPressed: () => setState(() {
              _browsing = true;
              _picked.clear();
            }),
            child: const Text('Other topics'),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _picked.isEmpty ? null : _addPicked,
            icon: const Icon(Icons.add_rounded),
            label: Text(_picked.isEmpty ? 'Add' : 'Add ${_picked.length}'),
          ),
        ],
      ),
    ];
  }
}

class _ResultTile extends StatelessWidget {
  final DuaSuggestion dua;
  final bool picked;
  final VoidCallback onTap;
  const _ResultTile(
      {required this.dua, required this.picked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = states.state;
    final size = s.arabicFontSize.clamp(22.0, 28.0);
    return Material(
      color: picked
          ? colorScheme.primaryContainer.withValues(alpha: 0.55)
          : colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: picked
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.8),
              width: picked ? 1.6 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: picked, onChanged: (_) => onTap()),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (dua.arabic.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          dua.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: AppFonts.arabicStyle(
                            fontIndex: s.arabicFontIndex,
                            fontSize: size,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    if (dua.meaning.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        dua.meaning,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant, height: 1.5),
                      ),
                    ],
                    if (dua.source.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer
                                .withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book_outlined,
                                  size: 14,
                                  color: colorScheme.onSecondaryContainer),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  dua.source,
                                  textAlign: TextAlign.center,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
