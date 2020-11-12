import 'dart:convert';

class VCardParser {
  String _vCardString;
  List<String> lines;
  String version;

  VCardParser(vCardString) {
    this._vCardString = vCardString;
    lines = LineSplitter().convert(this._vCardString);
    for (var i = lines.length - 1; i >= 0; i--) {
      if (lines[i].startsWith("BEGIN:VCARD") ||
          //lines[i].startsWith("END:VCARD") ||
          lines[i].trim().isEmpty) {
        lines.removeAt(i);
      }
    }
    version = getWordOfPrefix("VERSION:");
  }

  String get fullString {
    return this._vCardString;
  }

  void print_lines(){
    String s;
    print('lines #${lines.length}');
    for(var i = 0; i<lines.length; i++){
      s = i.toString().padLeft(2, '0');
      print('$s | ${lines[i]}');
    }
  }

  String concatenateLines(int index){
    /*
    ADR;GEO="geo:12.3457,78.910";LABEL="Mr. John Q. Public, Esq.\n
      Mail Drop: TNE QB\n123 Main Street\nAny Town, CA  91921-1234\n
      U.S.A.":;;123 Main Street;Any Town;CA;91921-1234;U.S.A.
    ADR;TYPE=HOME:post_office_box;ext_address;address;city;state_or_province;pl
     z;country
    ADR;TYPE=HOME:post office box;extended address;address;city;state;postal co
     de;country
   */
    String line='';
    for(var i = index; i<lines.length; i++){
      if (index == i){
        line = line + lines[i];
      } else {
        line = line + lines[i].substring(1);
      }

      if(lines[i+1][0] != ' ') {
        for(var k = index; k<i+1; k++) {
          lines.removeAt(index);
        }
        return line;
      }
    }
  }

  String getWordOfPrefix(String prefix) {
    //returns a word of a particular prefix from the tokens minus the prefix
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().startsWith(prefix)) {
        String word = lines[i];
        if (lines[i+1][0] == ' ') {
          word = concatenateLines(i);
        } else {
          lines.removeAt(i);
        }
        word = word.substring(prefix.length, word.length);
        return word;
      }
    }
    return "";
  }

  List<String> getWordsOfPrefix(String prefix) {
    //returns a list of words of a particular prefix from the tokens minus the prefix
    List<String> result = List<String>();

    String word;
    word = getWordOfPrefix(prefix);
    while(word.isNotEmpty){
      result.add(word);
      word = getWordOfPrefix(prefix);
    }

    return result;
  }

  String _strip(String baseString) {
    try {
      return RegExp(r'(?<=:).+').firstMatch(baseString).group(0);
    } catch (e) {
      return '';
    }
  }


  List<String> get name {
    String _name = getWordOfPrefix("N");
    return _strip(_name).split(';');
  }

  String get formattedName {
    String _fName = getWordOfPrefix("FN");
    return _strip(_fName);
  }

  String get nickName {
    String _nName = getWordOfPrefix("NICKNAME");
    return _strip(_nName);
  }

  String get birthDay {
    String _bDay = getWordOfPrefix("BDAY");
    return _strip(_bDay);
  }

  String get organisation {
    String _org = getWordOfPrefix("ORG");
    return _strip(_org);
  }

  String get title {
    String _title = getWordOfPrefix("TITLE");
    return _strip(_title);
  }

  String get position {
    String _position = getWordOfPrefix("ROLE");
    return _strip(_position);
  }

  String get categories {
    String _categories = getWordOfPrefix("CATEGORIES");
    return _strip(_categories);
  }

  String get gender {
    String _gender = getWordOfPrefix('GENDER');
    return _strip(_gender);
  }

  String get note {
    String _note = getWordOfPrefix('NOTE');
    return _strip(_note);
  }

  // GEO:50.858,7.0885          <-- 2.1, 3.0
  // GEO:geo: 50.858\,7.0885    <-- 4.0
  String get geo {
    String _geo;
    if (version == "2.1" || version == "3.0") {
      _geo = getWordOfPrefix('GEO');
    } else if (version == "4.0") {
      _geo = getWordOfPrefix('GEO:GEO');
    }
    return _strip(_geo);
  }

  @Deprecated("typedTelephone should be used instead")
  String get telephone {
    return getWordOfPrefix("TEL:");
  }

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
    List<String> types = List<String>();
    List<dynamic> result = List<dynamic>();
    String _tel = '';

    telephones = getWordsOfPrefix("TEL");

    for (String tel in telephones) {
      try {
        if (version == "2.1" || version == "3.0") {
          _tel = RegExp(r'(?<=:).+$').firstMatch(tel).group(0);
        } else if (version == "4.0") {
          _tel = RegExp(r'(?<=tel:).+$').firstMatch(tel).group(0);
        }
      } catch (e) {
        _tel = '';
      }

      for (String type in telephoneTypes) {
        if (tel.toUpperCase().contains(type)) {
          types.add(type);
        }
      }

      if ( _tel.isNotEmpty) {result.add([_tel, types, ]); }
      _tel = '';
      types = [];
    }

    return result;
  }

  @Deprecated("typedEmail should be used instead")
  String get email {
    String _email = getWordOfPrefix("EMAIL");
    return _strip(_email);
  }

  List<dynamic> get typedEmail =>  typedEmailURL('EMAIL');
  List<dynamic> get typedURL =>  typedEmailURL('URL');
  List<dynamic> get typedAdress =>  typedEmailURL('ADR');

  List<dynamic> typedEmailURL(String property) {
    List<String> emailTypes = [
      'HOME',
      'WORK',
      'OTHER',
      'PREF'
    ];
    List<String> emails;
    List<String> types = List<String>();
    List<dynamic> result = List<dynamic>();
    String _email = '';

    emails = getWordsOfPrefix(property);

    for (String email in emails) {
      try {
        _email = RegExp(r'(?<=:).+$').firstMatch(email).group(0);

      } catch (e) {
        _email = '';
      }

      for (String type in emailTypes) {
        if (email.toUpperCase().contains(type)) {
          types.add(type);
        }
      }

      if ( _email.isNotEmpty) {
        if(property == 'ADR'){
          List<String> adress = _email.split(';');
          result.add([adress, types, ]);
        } else {
          result.add([_email, types, ]);
        }
      }
      _email = '';
      types = [];
    }

    return result;
  }
}
