import 'package:duas/models/states.dart';
import 'package:duas/theme/app_fonts.dart';
import 'package:duas/theme/app_theme.dart';
import 'package:duas/utils/apis.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class ThemeSettingsSheet extends StatelessWidget {
  /// Called when the data-source URL changes, so the caller can re-fetch.
  final VoidCallback? onReload;

  const ThemeSettingsSheet({super.key, this.onReload});

  static const String _previewArabic = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  static Future<void> show(BuildContext context, {VoidCallback? onReload}) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => ThemeSettingsSheet(onReload: onReload),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return StateBuilder(
      observe: () => states,
      builder: (context, model) {
        final s = states.state;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: textTheme.headlineSmall),
                  const SizedBox(height: 24),

                  // ===== Appearance =====
                  _SectionLabel('Theme'),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {s.themeMode},
                    onSelectionChanged: (sel) =>
                        s.setThemeMode(sel.first),
                  ),
                  const SizedBox(height: 28),

                  _SectionLabel('Accent color'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (int i = 0; i < kAppAccents.length; i++)
                        _ColorDot(
                          accent: kAppAccents[i],
                          selected: s.accentIndex == i,
                          onTap: () => s.setAccentIndex(i),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 40),

                  // ===== Reading =====
                  _SectionLabel('Reading'),
                  const SizedBox(height: 16),

                  // Live preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 22),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _previewArabic,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: AppFonts.arabicStyle(
                            fontIndex: s.arabicFontIndex,
                            fontSize: s.arabicFontSize,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'In the name of Allah, the Most Gracious, the Most Merciful.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: s.translationFontSize,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Arabic font picker
                  Text('Arabic font', style: textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < kArabicFonts.length; i++)
                        ChoiceChip(
                          label: Text(kArabicFonts[i].label),
                          selected: s.arabicFontIndex == i,
                          onSelected: (_) => s.setArabicFontIndex(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Arabic size
                  _SizeSlider(
                    label: 'Arabic size',
                    value: s.arabicFontSize,
                    min: AppFonts.minArabicSize,
                    max: AppFonts.maxArabicSize,
                    onChanged: s.setArabicFontSize,
                  ),
                  const SizedBox(height: 12),

                  // Translation size
                  _SizeSlider(
                    label: 'Translation size',
                    value: s.translationFontSize,
                    min: AppFonts.minTranslationSize,
                    max: AppFonts.maxTranslationSize,
                    onChanged: s.setTranslationFontSize,
                  ),

                  const Divider(height: 40),

                  // ===== Data source =====
                  _SectionLabel('Data source'),
                  const SizedBox(height: 8),
                  Text(
                    'The URL your duas are loaded from. Paste your own JSON '
                    'endpoint to use a different list.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DataSourceField(
                    currentUrl: s.dataUrl,
                    onReload: onReload,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DataSourceField extends StatefulWidget {
  final String currentUrl;
  final VoidCallback? onReload;

  const _DataSourceField({required this.currentUrl, this.onReload});

  @override
  State<_DataSourceField> createState() => _DataSourceFieldState();
}

class _DataSourceFieldState extends State<_DataSourceField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.currentUrl);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final changed = states.state.setDataUrl(_controller.text);
    _controller.text = states.state.dataUrl;
    final messenger = ScaffoldMessenger.of(context);
    if (changed) {
      widget.onReload?.call();
      messenger.showSnackBar(
        const SnackBar(content: Text('Data source updated — reloading…')),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Data source unchanged')),
      );
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    final changed = states.state.setDataUrl(Apis.defaultDataUrl);
    _controller.text = states.state.dataUrl;
    if (changed) widget.onReload?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restored the default data source')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDefault = _controller.text.trim() == Apis.defaultDataUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          keyboardType: TextInputType.url,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _save(),
          decoration: InputDecoration(
            hintText: 'https://…',
            prefixIcon: const Icon(Icons.link_rounded),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton.icon(
              onPressed: isDefault ? null : _reset,
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Default'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}

class _SizeSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SizeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.titleSmall),
            Text('${value.round()} pt',
                style: textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          label: '${value.round()}',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final AppAccent accent;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: accent.name,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent.seed,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colorScheme.onSurface : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 22)
              : null,
        ),
      ),
    );
  }
}
