import 'utility.dart';

/// Pinyinizer Adds proper (Mandarin) Chinese tone diacritics to a string.
///
/// The four tones of Chinese are commonly represented by the numbers 1-4.
/// This package enables one to take a string with numerical tone representation
/// and transforming it into a string with proper tone diacritics.
///
class PinyinUtil {
  static final RegExp _tonePtn = RegExp(r"([aeiouvü]{1,2}(n|ng|r|\'er|N|NG|R|\'ER){0,1}[1234])",
      caseSensitive: false, multiLine: false);
  static final RegExp _suffixPtn =
      RegExp(r"(n|ng|r|\'er|N|NG|R|\'ER)$", caseSensitive: false, multiLine: false);

  static const _toneMap = {
    'a': ['ā', 'á', 'ǎ', 'à'],
    'ai': ['āi', 'ái', 'ǎi', 'ài'],
    'ao': ['āo', 'áo', 'ǎo', 'ào'],
    'e': ['ē', 'é', 'ě', 'è'],
    'ei': ['ēi', 'éi', 'ěi', 'èi'],
    'i': ['ī', 'í', 'ǐ', 'ì'],
    'ia': ['iā', 'iá', 'iǎ', 'ià'],
    'ie': ['iē', 'ié', 'iě', 'iè'],
    'io': ['iō', 'ió', 'iǒ', 'iò'],
    'iu': ['iū', 'iú', 'iǔ', 'iù'],
    'o': ['ō', 'ó', 'ǒ', 'ò'],
    'ou': ['ōu', 'óu', 'ǒu', 'òu'],
    'u': ['ū', 'ú', 'ǔ', 'ù'],
    'ua': ['uā', 'uá', 'uǎ', 'uà'],
    'ue': ['uē', 'ué', 'uě', 'uè'],
    'ui': ['uī', 'uí', 'uǐ', 'uì'],
    'uo': ['uō', 'uó', 'uǒ', 'uò'],
    'v': ['ǖ', 'ǘ', 'ǚ', 'ǜ'],
    've': ['üē', 'üé', 'üě', 'üè'],
    'ü': ['ǖ', 'ǘ', 'ǚ', 'ǜ'],
    'üe': ['üē', 'üé', 'üě', 'üè']
  };

  /// [wo3,ai4,ni3] -> [wǒ,ài,nǐ]
  static List<String> transformPinyin(List<String> pinyins) {
    return _transform(pinyins.join('-')).split('-');
  }

  /// ['我','，','爱','你']+['wǒ','ài','nǐ'] => [wǒ,'，',ài,nǐ]
  static List<String> appendPunctuation(
      {required List<String> origin, required List<String> ref}) {
    var copy = origin.map((e) => e).toList();
    for(var i=0;i<ref.length;i++){
      if(!ref[i].isSingleHanzi){
        copy.insert(i, ref[i]);
      }
    }
    return copy;
  }

  static String _transform(String text) {
    var tones = _tonePtn.allMatches(text);

    tones.forEach((tone) {
      var coda = tone.group(0);
      text = text.replaceAll(coda!, _transformCoda(coda));
    });

    return text;
  }

  static String _transformCoda(String coda) {
    var tone = coda.substring(coda.length - 1);
    var vowel = coda.substring(0, coda.length - 1);

    var suffixes = _suffixPtn.allMatches(vowel);
    var suffix;

    if (suffixes.isNotEmpty) {
      suffix = suffixes.first.group(0);
      vowel = vowel.replaceAll(suffix, '');
    }

    var replaced = _toneMap[vowel.toLowerCase()]![int.parse(tone) - 1];

    if (suffix != null) {
      replaced = replaced + suffix.toLowerCase();
    }
    return replaced;
  }
}
