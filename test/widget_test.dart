import 'package:duas/models/dua_model.dart';
import 'package:duas/theme/font_files.dart';
import 'package:duas/theme/app_fonts.dart';
import 'package:duas/utils/hisn_muslim.dart';
import 'package:duas/utils/library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a ready-made dua has no id and is not "mine"', () {
    final d = DuaModel.fromJson({'arabic': 'a', 'meaning': 'm', 'source': 's'});
    expect(d.isMine, isFalse);
    expect(d.toJson().containsKey('id'), isFalse);
  });

  test('a dua the user added keeps its id through save and load', () {
    final d = DuaModel(arabic: 'a', meaning: 'm', source: '', id: '42');
    final back = DuaModel.fromRawJson(d.toRawJson());
    expect(back.isMine, isTrue);
    expect(back.id, '42');
    expect(back.arabic, 'a');
  });

  test('missing fields do not crash', () {
    final d = DuaModel.fromJson({'meaning': 'only a meaning'});
    expect(d.arabic, '');
    expect(d.source, '');
    expect(d.meaning, 'only a meaning');
  });

  // a few real topic titles from Hisn al-Muslim
  const topics = [
    HisnChapter(28, 'What to say before sleeping'),
    HisnChapter(13, 'Invocation for entering the mosque'),
    HisnChapter(34, 'Invocations in times of worry and grief'),
    HisnChapter(35, 'Invocations for anguish'),
    HisnChapter(96, 'Invocation for traveling'),
    HisnChapter(8, 'What to say before performing ablution'),
    HisnChapter(69, 'Invocations before eating'),
  ];

  test('search finds topics by everyday words', () {
    expect(HisnMuslim.match(topics, 'dua for anxiety').first.id, 34);
    expect(HisnMuslim.match(topics, 'before sleeping').first.id, 28);
    expect(HisnMuslim.match(topics, 'sleep').first.id, 28);
    expect(HisnMuslim.match(topics, 'travelling').first.id, 96);
    expect(HisnMuslim.match(topics, 'masjid').first.id, 13);
    expect(HisnMuslim.match(topics, 'wudu').first.id, 8);
    expect(HisnMuslim.match(topics, 'food').first.id, 69);
  });

  test('search ignores filler words and nonsense', () {
    expect(HisnMuslim.match(topics, 'dua for'), isEmpty);
    expect(HisnMuslim.match(topics, 'hello world'), isEmpty);
  });

  test('a Hisn al-Muslim chapter is read with the book as the source', () {
    const body = '﻿{"Invocation for entering the mosque":['
        '{"ID":"1","ARABIC_TEXT":"اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",'
        '"LANGUAGE_ARABIC_TRANSLATED_TEXT":"(allahumma iftah lee abwaba rahmatik.)",'
        '"TRANSLATED_TEXT":" O Allah, open the gates of Your mercy for me.",'
        '"REPEAT":"1","AUDIO":""},'
        '{"ID":"2","ARABIC_TEXT":"x","LANGUAGE_ARABIC_TRANSLATED_TEXT":'
        '"Recite Ayat-Al-Kursiy (Al-Baqarah :255)","TRANSLATED_TEXT":"y",'
        '"REPEAT":"3","AUDIO":""}]}';
    final d =
        HisnMuslim.parseChapter(body, 'Invocation for entering the mosque');
    expect(d.length, 2);
    expect(d.first.meaning, 'O Allah, open the gates of Your mercy for me.');
    // the transliteration is not a source and is left out
    expect(
        d.first.source, 'Hisn al-Muslim: Invocation for entering the mosque');
    // a Quran reference is kept, and so is the repeat count
    expect(d.last.source, contains('Al-Baqarah :255'));
    expect(d.last.source, contains('say 3 times'));
  });

  test('the other collections are searched by topic and meaning', () {
    const entries = [
      LibDua(
          'Daily duas', 'a', 'In Your name, O Allah, I die and I live.', 's'),
      LibDua('Travel & Journey', 'b', 'Glory to Him who subjected this to us.',
          's'),
      LibDua('Morning dhikr', 'c', 'We have reached the morning.', 's'),
    ];
    expect(Library.search(entries, 'travelling').first.arabic, 'b');
    expect(Library.search(entries, 'morning').first.arabic, 'c');
    expect(Library.search(entries, 'dua for'), isEmpty);
  });

  test('DeenOne entries with a reference in the English box are dropped', () {
    const body = '{"duas":['
        '{"arabic":"x","english":"O Allah, forgive me.","reference":"","category_name_en":"Gratitude & Repentance"},'
        '{"arabic":"y","english":"Reference: At-Tirmidhi 5/291","reference":"","category_name_en":"Morning & Evening"},'
        '{"arabic":"","english":"no arabic","reference":"","category_name_en":"x"}]}';
    final d = Library.parseDeenOne(body);
    expect(d.length, 1);
    expect(d.first.source, 'DeenOne · Gratitude & Repentance');
  });

  test('every font the app uses has a file to download', () {
    expect(kFontFiles.containsKey('Inter'), isTrue);
    expect(kFontFiles.containsKey('Newsreader'), isTrue);
    for (final f in kArabicFonts) {
      expect(kFontFiles[f.family], isNotNull, reason: f.family);
    }
  });
}
