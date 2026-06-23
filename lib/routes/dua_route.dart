import 'package:duas/models/dua_model.dart';
import 'package:duas/models/states.dart';
import 'package:duas/utils/apis.dart';
import 'package:duas/widgets/dua_item.dart';
import 'package:duas/widgets/theme_settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:prefs/prefs.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class DuaRoute extends StatefulWidget {
  const DuaRoute({super.key});

  @override
  State<DuaRoute> createState() => _DuaRouteState();
}

class _DuaRouteState extends State<DuaRoute> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    getDuas();
  }

  void showLoading() {
    OneContext().showDialog(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loading',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('Please wait…',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideLoading() {
    OneContext().popAllDialogs();
  }

  Future<void> getDuas({bool force = false}) async {
    String data = Prefs.getString("data");
    if (data == "" || force) {
      setState(() => _loading = true);
      if (force) showLoading();
      List<DuaModel>? duas = await Apis.getDuas();
      if (duas != null) states.state.setDuas(duas);
      if (force) hideLoading();
      if (mounted) setState(() => _loading = false);
    } else {
      List<DuaModel>? duas = getDuaListFromJson(data);
      states.state.setDuas(duas!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => states,
      builder: (context, model) {
        final duas = states.state.duas;
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Duas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => getDuas(force: true),
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                tooltip: 'Appearance',
                onPressed: () => ThemeSettingsSheet.show(context),
                icon: const Icon(Icons.palette_outlined),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: _buildBody(context, duas),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, List<DuaModel> duas) {
    if (duas.isEmpty) {
      if (_loading) {
        return const Center(child: CircularProgressIndicator());
      }
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 56, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No duas yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => getDuas(force: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reload'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => getDuas(force: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: duas.length,
        itemBuilder: (context, index) => DuaItem(duaModel: duas[index]),
      ),
    );
  }
}
