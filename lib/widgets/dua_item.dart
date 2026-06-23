import 'package:duas/models/dua_model.dart';
import 'package:duas/models/states.dart';
import 'package:duas/theme/app_fonts.dart';
import 'package:flutter/material.dart';

class DuaItem extends StatelessWidget {
  final DuaModel duaModel;
  const DuaItem({super.key, required this.duaModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = states.state;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Arabic
            Text(
              duaModel.arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppFonts.arabicStyle(
                fontIndex: s.arabicFontIndex,
                fontSize: s.arabicFontSize,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 16),
            // Meaning
            Text(
              duaModel.meaning,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: s.translationFontSize,
                height: 1.5,
              ),
            ),
            if (duaModel.source.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              // Source pill
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    duaModel.source,
                    textAlign: TextAlign.center,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
