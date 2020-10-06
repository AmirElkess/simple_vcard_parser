import 'dart:convert';

class VCard {
  String _vCardString;
  List<String> lines;
  String version;

  VCard(vCardString) {
    this._vCardString = vCardString;
    lines = LineSplitter().convert(this._vCardString);
    for (var i = lines.length - 1; i >= 0; i--) {
      if (lines[i].startsWith("BEGIN:VCARD") ||
          lines[i].startsWith("END:VCARD") ||
          lines[i].trim().isEmpty) {
        lines.removeAt(i);
      }
    }
    version = getWordOfPrefix("VERSION:");
  }

  String get fullString {
    return this._vCardString;
  }

  String getWordOfPrefix(String prefix) {
    //returns a word of a particular prefix from the tokens minus the prefix
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith(prefix)) {
        String word = lines[i];
        word = word.substring(prefix.length, word.length);
        return word;
      }
    }
    return "";
  }

  List<String> getWordsOfPrefix(String prefix) {
    //returns a list of words of a particular prefix from the tokens minus the prefix
    List<String> result = List<String>();

    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith(prefix)) {
        String word = lines[i];
        word = word.substring(prefix.length, word.length);
        result.add(word);
      }
    }
    return result;
  }

  String get email {
    String email = getWordOfPrefix("EMAIL");
    if (email.isNotEmpty) {
      RegExp emailm = RegExp(r'(?<=:).+');
      email = emailm.firstMatch(email).group(0);
      return email;
    }
    return "";
  }

  List<String> get name {
    return getWordOfPrefix("N:").split(';');
  }

  String get formattedName {
    return getWordOfPrefix("FN:");
  }

  String get organisation {
    return getWordOfPrefix("ORG:");
  }

  String get title {
    return getWordOfPrefix("TITLE:");
  }

  String get telephone {
    return getWordOfPrefix("TEL:");
  }

  List<dynamic> get typedTelephone {
    List<String> telephoneTypes = [
      'CELL',
      'PAGER',
      'HOME',
      'VOICE',
      'WORK',
      'FAX'
    ];
    List<String> telephones;
    List<String> types = List<String>();
    List<dynamic> result = List<dynamic>();
    String _tel = '';

    telephones = getWordsOfPrefix("TEL");

    for (String tel in telephones) {
      if (version == "2.1" || version == "3.0") {
        _tel = RegExp(r'(?<=:).+$').firstMatch(tel).group(0);
      } else if (version == "4.0") {
        _tel = RegExp(r'(?<=tel:).+$').firstMatch(tel).group(0);
      }
      for (String type in telephoneTypes) {
        if (tel.toUpperCase().contains(type)) {
          types.add(type);
        }
      }

      result.add([_tel, types]);
      _tel = '';
      types = [];
    }

    return result;
  }
}
