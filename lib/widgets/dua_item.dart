import 'package:duas/models/dua_model.dart';
import 'package:duas/models/states.dart';
import 'package:duas/theme/app_fonts.dart';
import 'package:duas/utils/toast.dart';
import 'package:duas/utils/translator.dart';
import 'package:duas/widgets/translate_sheet.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// One dua: the Arabic is the hero, the meaning sits quietly under it, and the
/// footer holds the source and the actions.
class DuaItem extends StatelessWidget {
  final DuaModel duaModel;

  /// [onEdit] is given only for the person's own duas; [onDelete] for all.
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DuaItem({
    super.key,
    required this.duaModel,
    this.onEdit,
    this.onDelete,
  });

  String get _plainText => [
        duaModel.arabic.trim(),
        duaModel.meaning.trim(),
        duaModel.source.trim(),
      ].where((e) => e.isNotEmpty).join('\n\n');

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _plainText));
    if (!context.mounted) return;
    showToast(context, 'Copied');
  }

  /// Opens the phone's / browser's share sheet. Where sharing is not available
  /// (some desktop browsers) the text is copied instead, so the button always
  /// does something useful.
  Future<void> _share(BuildContext context) async {
    try {
      final result = await SharePlus.instance
          .share(ShareParams(text: _plainText, mailToFallbackEnabled: false));
      if (result.status == ShareResultStatus.unavailable && !kIsWeb) return;
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: _plainText));
      if (!context.mounted) return;
      showToast(context, 'Sharing is not available here. Copied instead.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = states.state;

    final hasArabic = duaModel.arabic.trim().isNotEmpty;
    final hasMeaning = duaModel.meaning.trim().isNotEmpty;
    final hasSource = duaModel.source.trim().isNotEmpty;
    final mine = duaModel.isMine;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: a small "Mine" tag and the edit menu (own duas only)
          if (mine)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'My dua',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined,
                        size: 20, color: colorScheme.onSurfaceVariant),
                  ),
              ],
            )
          else
            const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasArabic)
                  Padding(
                    padding: EdgeInsets.only(top: mine ? 6 : 0),
                    child: Text(
                      duaModel.arabic,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppFonts.arabicStyle(
                        fontIndex: s.arabicFontIndex,
                        fontSize: s.arabicFontSize,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                if (hasArabic && hasMeaning)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 18),
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                if (hasMeaning)
                  Padding(
                    padding:
                        EdgeInsets.only(top: hasArabic ? 0 : (mine ? 6 : 0)),
                    child: Text(
                      duaModel.meaning,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: s.translationFontSize,
                        height: 1.6,
                      ),
                    ),
                  ),
                // translations the person checked and kept
                if (hasMeaning)
                  for (final t in Translator.savedAll(duaModel.meaning).entries)
                    _KeptTranslation(
                      language: t.key,
                      text: t.value,
                      onRemove: () {
                        Translator.remove(t.key, duaModel.meaning);
                        states.notify();
                      },
                    ),
              ],
            ),
          ),

          // Footer: source on the left, copy on the right
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: hasSource
                    ? Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                                  duaModel.source,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (hasMeaning)
                IconButton(
                  tooltip: 'Translate',
                  onPressed: () =>
                      TranslateSheet.show(context, duaModel.meaning),
                  icon: Icon(Icons.translate_rounded,
                      size: 20, color: colorScheme.onSurfaceVariant),
                ),
              IconButton(
                tooltip: 'Copy',
                onPressed: () => _copy(context),
                icon: Icon(Icons.copy_rounded,
                    size: 20, color: colorScheme.onSurfaceVariant),
              ),
              IconButton(
                tooltip: 'Share',
                onPressed: () => _share(context),
                icon: Icon(Icons.ios_share_rounded,
                    size: 20, color: colorScheme.onSurfaceVariant),
              ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20, color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A translation the person kept, marked as made by AI, with a way to
/// remove it.
class _KeptTranslation extends StatelessWidget {
  final String language;
  final String text;
  final VoidCallback onRemove;
  const _KeptTranslation(
      {required this.language, required this.text, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = states.state;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontSize: s.translationFontSize + 1,
              height: 1.6,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$language · translated by AI',
                  style: textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              IconButton(
                tooltip: 'Remove this translation',
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                onPressed: onRemove,
                icon: Icon(Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
