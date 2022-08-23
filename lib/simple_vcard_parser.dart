import 'dart:convert';

class VCard {
  String vCardString;
  late List<String> lines;
  late String version;

  VCard(this.vCardString) {
    lines = LineSplitter().convert(vCardString);
    for (var i = lines.length - 1; i >= 0; i--) {
      if (lines[i].startsWith("BEGIN:VCARD") ||
          lines[i].startsWith("END:VCARD") ||
          lines[i].trim().isEmpty) {
        lines.removeAt(i);
      }
    }

    for (var i = lines.length - 1; i >= 0; i--) {
      if (!lines[i].startsWith(new RegExp(r'^\S+(:|;)'))) {
        String tmpLine = lines[i];
        String prevLine = lines[i - 1];
        lines[i - 1] = prevLine + ', ' + tmpLine;
        lines.removeAt(i);
      }
    }

    version = getWordOfPrefix("VERSION:") ?? "3.0";
  }

  String get fullString => vCardString;

  void print_lines() {
    String s;
    print('lines #${lines.length}');
    for (var i = 0; i < lines.length; i++) {
      s = i.toString().padLeft(2, '0');
      print('$s | ${lines[i]}');
    }
  }

  String? getWordOfPrefix(String prefix) {
    //returns a word of a particular prefix from the tokens minus the prefix [case insensitive]
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().startsWith(prefix.toUpperCase())) {
        String word = lines[i];
        word = word.substring(prefix.length, word.length);
        return word;
      }
    }
    return null;
  }

  List<String> getWordsOfPrefix(String prefix) {
    //returns a list of words of a particular prefix from the tokens minus the prefix [case insensitive]
    List<String> result = [];

    for (var i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().startsWith(prefix.toUpperCase())) {
        String word = lines[i];
        word = word.substring(prefix.length, word.length);
        result.add(word);
      }
    }
    return result;
  }

  String? _strip(String? baseString) {
    if (baseString == null) {
      return null;
    }
    try {
      return RegExp(r'(?<=:).+').firstMatch(baseString)?.group(0);
    } catch (e) {
      return null;
    }
  }

  List<String>? get name => _strip(getWordOfPrefix("N"))?.split(";");
  String? get formattedName => _strip(getWordOfPrefix("FN"));
  String? get nickname => _strip(getWordOfPrefix("NICKNAME"));
  String? get birthday => _strip(getWordOfPrefix("BDAY"));
  String? get organisation => _strip(getWordOfPrefix("ORG"));
  String? get title => _strip(getWordOfPrefix("TITLE"));
  String? get position => _strip(getWordOfPrefix("ROLE"));
  String? get categories => _strip(getWordOfPrefix("CATEGORIES"));
  String? get gender => _strip(getWordOfPrefix('GENDER'));
  String? get note => _strip(getWordOfPrefix('NOTE'));

  List<dynamic> get typedTelephone {
    List<String> telephoneTypes = [
      'TEXT',
      'TEXTPHONE',
      'VOICE',
      'VIDEO',
      'CELL',
      'PAGER',
      'FAX',
      'HOME',
      'WORK',
      'OTHER'
    ];
    List<String> telephones;
    List<String> types = [];
    List<dynamic> result = [];
    String _tel = '';

    telephones = getWordsOfPrefix("TEL");

    for (String tel in telephones) {
      try {
        if (version == "2.1" || version == "3.0") {
          _tel = RegExp(r'(?<=:).+$').firstMatch(tel)?.group(0) ?? '';
        } else if (version == "4.0") {
          _tel = RegExp(r'(?<=tel:).+$').firstMatch(tel)?.group(0) ?? '';
        }
      } catch (e) {
        _tel = '';
      }

      for (String type in telephoneTypes) {
        if (tel.toUpperCase().contains(type)) {
          types.add(type);
        }
      }

      if (_tel.isNotEmpty) {
        result.add([
          _tel,
          types,
        ]);
      }
      _tel = '';
      types = [];
    }

    return result;
  }

  List<dynamic> get typedEmail => _typedProperty('EMAIL');
  List<dynamic> get typedURL => _typedProperty('URL');

  List<dynamic> _typedProperty(String property) {
    // base function for getting typed EMAIL+URL
    List<String> propertyTypes = [
      'HOME',
      'INTERNET',
      'WORK',
      'OTHER',
    ];
    List<String> matches;
    List<String> types = [];
    List<dynamic> result = [];
    String _res = '';

    matches = getWordsOfPrefix(property);

    for (String match in matches) {
      try {
        _res = RegExp(r'(?<=:).+$').firstMatch(match)?.group(0) ?? '';
      } catch (e) {
        _res = '';
      }

      for (String type in propertyTypes) {
        if (match.toUpperCase().contains(type)) {
          types.add(type);
        }
      }

      if (_res.isNotEmpty) {
        if (property == 'ADR') {
          List<String> adress = _res.split(';');
          result.add([
            adress,
            types,
          ]);
        } else {
          result.add([
            _res,
            types,
          ]);
        }
      }
      _res = '';
      types = [];
    }

    return result;
  }

  List<dynamic> get typedAddress {
    List<String> addressTypes = [
      'HOME',
      'WORK',
      'POSTAL',
      'DOM',
    ];
    List<String> addresses;
    List<String> types = [];
    List<dynamic> result = [];
    String _adr = '';

    addresses = getWordsOfPrefix("ADR");

    for (String adr in addresses) {
      try {
        if (version == "2.1" || version == "3.0") {
          _adr = RegExp(r'(?<=(;|:);).+$').firstMatch(adr)?.group(0) ?? '';
        } else if (version == "4.0") {
          _adr = RegExp(r'(?<=LABEL=").+(?=":;)').firstMatch(adr)?.group(0) ?? '';
        }
      } catch (e) {
        _adr = '';
      }

      if (_adr.startsWith(r';')) {
        //remove leading semicolon
        _adr = _adr.substring(1);
      }

      for (String type in addressTypes) {
        if (adr.toUpperCase().contains(type)) {
          types.add(type);
        }
      }

      result.add([
        _adr.split(';'),
        types
      ]); //Add splitted adress ( home;street;city -> [home, street, city]) along with its type
      _adr = '';
      types = [];
    }

    return result; // in this format: [[[adr_1_params], [adr_1_types]], [[adr_2_params], [adr_2_types]]]
  }
}
