import 'package:duas/models/dua_model.dart';
import 'package:duas/models/states.dart';
import 'package:duas/utils/apis.dart';
import 'package:duas/widgets/dua_editor.dart';
import 'package:duas/widgets/dua_item.dart';
import 'package:duas/widgets/theme_settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class DuaRoute extends StatefulWidget {
  const DuaRoute({super.key});

  @override
  State<DuaRoute> createState() => _DuaRouteState();
}

class _DuaRouteState extends State<DuaRoute> {
  bool _loading = false;
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (states.state.showReadyMade) getDuas();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------- actions

  void _confirmDelete(DuaModel dua) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this dua?'),
        content: Text(dua.isMine
            ? 'It will be removed from this device.'
            : 'It will be hidden. You can bring it back from Settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              states.state.deleteDua(dua);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> getDuas({bool force = false}) async {
    String data = Prefs.getString("data");
    if (data == "" || force) {
      setState(() => _loading = true);
      try {
        List<DuaModel>? duas = await Apis.getDuas();
        if (duas != null) states.state.setDuas(duas);
      } catch (_) {
        // no connection: keep what is already on screen
      }
      if (mounted) setState(() => _loading = false);
    } else {
      List<DuaModel>? duas = getDuaListFromJson(data);
      states.state.setDuas(duas!);
    }
  }

  List<DuaModel> _visible(List<DuaModel> all) {
    Iterable<DuaModel> r = all;
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      r = r.where((d) =>
          d.arabic.toLowerCase().contains(q) ||
          d.meaning.toLowerCase().contains(q) ||
          d.source.toLowerCase().contains(q));
    }
    return r.toList();
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => states,
      builder: (context, model) {
        final s = states.state;
        final all = s.allDuas;
        final colorScheme = Theme.of(context).colorScheme;
        final width = MediaQuery.of(context).size.width;
        // full width: only a small margin on each side
        final side = width >= 900 ? 32.0 : 16.0;

        final showSearch = all.length > 3;
        final visible = _visible(all);

        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          // the empty state already has its own "Add my first dua" button
          floatingActionButton:
              all.isEmpty && !(s.showReadyMade && s.duas.isEmpty)
                  ? null
                  : FloatingActionButton.extended(
                      onPressed: () => DuaEditor.show(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add dua'),
                    ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (s.showReadyMade) await getDuas(force: true);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  centerTitle: false,
                  toolbarHeight: 68,
                  titleSpacing: side + 4,
                  title: Text(
                    'Duas',
                    style: TextStyle(
                      fontFamily: 'Newsreader',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  actions: [
                    if (s.showReadyMade)
                      IconButton(
                        tooltip: 'Refresh ready-made duas',
                        onPressed: () => getDuas(force: true),
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    IconButton(
                      tooltip: 'Settings',
                      onPressed: () => ThemeSettingsSheet.show(
                        context,
                        onReload: () => getDuas(force: true),
                      ),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                    SizedBox(width: side - 4),
                  ],
                  bottom: _loading && all.isNotEmpty
                      ? const PreferredSize(
                          preferredSize: Size.fromHeight(3),
                          child: LinearProgressIndicator(minHeight: 3),
                        )
                      : null,
                ),
                if (all.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, 0, side, 12),
                    sliver: SliverToBoxAdapter(
                      child: _Header(
                        total: all.length,
                        mine: s.myDuas.length,
                        showSearch: showSearch,
                        search: _search,
                        onQuery: (v) => setState(() => _query = v),
                      ),
                    ),
                  ),
                if (all.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      loading: _loading,
                      // the ready-made duas are on but none came: a loading problem
                      failed: s.showReadyMade && s.duas.isEmpty,
                      deletedCount: s.hidden.length,
                      showReadyMade: s.showReadyMade,
                      onRestore: s.restoreDeleted,
                      onAdd: () => DuaEditor.show(context),
                      onLoadReadyMade: () {
                        s.setShowReadyMade(true);
                        getDuas();
                      },
                      onReload: () => getDuas(force: true),
                    ),
                  )
                else if (visible.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NoMatches(
                      query: _query,
                      onClear: () => setState(() {
                        _search.clear();
                        _query = '';
                      }),
                    ),
                  )
                else
                  SliverPadding(
                    // bottom room so the + button never covers the last card
                    padding: EdgeInsets.fromLTRB(side, 4, side, 110),
                    sliver: SliverList.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final dua = visible[index];
                        return DuaItem(
                          key: ValueKey(
                              dua.id ?? 'r$index${dua.arabic.hashCode}'),
                          duaModel: dua,
                          onEdit: dua.isMine
                              ? () => DuaEditor.show(context, existing: dua)
                              : null,
                          onDelete: () => _confirmDelete(dua),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------------ pieces

class _Header extends StatelessWidget {
  final int total;
  final int mine;
  final bool showSearch;
  final TextEditingController search;
  final ValueChanged<String> onQuery;

  const _Header({
    required this.total,
    required this.mine,
    required this.showSearch,
    required this.search,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subtitle = mine > 0 && mine < total
        ? '$total duas · $mine added by you'
        : '$total ${total == 1 ? 'dua' : 'duas'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text(
            subtitle,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        if (showSearch)
          TextField(
            controller: search,
            onChanged: onQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search duas',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        search.clear();
                        onQuery('');
                      },
                    ),
              filled: true,
              fillColor:
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool loading;
  final bool failed;
  final int deletedCount;
  final bool showReadyMade;
  final VoidCallback onRestore;
  final VoidCallback onAdd;
  final VoidCallback onLoadReadyMade;
  final VoidCallback onReload;

  const _EmptyState({
    required this.loading,
    required this.failed,
    required this.deletedCount,
    required this.showReadyMade,
    required this.onRestore,
    required this.onAdd,
    required this.onLoadReadyMade,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 96),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_stories_rounded,
                    size: 38, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(height: 22),
              Text(
                failed ? 'Could not load the duas' : 'Your duas live here',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Newsreader',
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                failed
                    ? 'Check your internet connection and try again.'
                    : 'Add the duas you recite with the button below.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant, height: 1.5),
              ),
              const SizedBox(height: 24),
              if (failed)
                FilledButton.icon(
                  onPressed: onReload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                )
              else ...[
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add my first dua'),
                ),
                const SizedBox(height: 10),
                if (deletedCount > 0)
                  TextButton.icon(
                    onPressed: onRestore,
                    icon: const Icon(Icons.restore_rounded),
                    label: Text('Restore deleted duas ($deletedCount)'),
                  )
                else if (!showReadyMade)
                  TextButton.icon(
                    onPressed: onLoadReadyMade,
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('Load ready-made duas'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  final String query;
  final VoidCallback onClear;
  const _NoMatches({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(
              query.trim().isEmpty
                  ? 'Nothing here yet'
                  : 'No duas match “${query.trim()}”',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            TextButton(onPressed: onClear, child: const Text('Show all duas')),
          ],
        ),
      ),
    );
  }
}
