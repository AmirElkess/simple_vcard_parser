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
    return getWordOfPrefix("EMAIL:");
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

  List<List> get typedTelephone {
    List<String> telephones;
    String type;
    List<List> result = List<List>();

    if (version == "3.0" || version == "4.0") {
      telephones = getWordsOfPrefix("TEL;");
      for (String tel in telephones) {
        type = tel.substring(tel.indexOf("TYPE="));
        type = type.substring(5, type.indexOf(","));
        tel = tel.substring(tel.lastIndexOf(":") + 1);
        result.add([tel, type]);
      }
    } else if (version == "2.1") {
      telephones = getWordsOfPrefix("TEL;");
      for (String tel in telephones) {
        type = tel.substring(0, tel.indexOf(";"));
        tel = tel.substring(tel.lastIndexOf(":") + 1);
        result.add([tel, type]);
      }
    }
    return result;
  }
}
