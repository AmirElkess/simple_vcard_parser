# simple_vcard_parser

A simple and easy to use parser to extract information from a standard vCard string. Major vCard properties from versions 2.1, 3.0, 4.0 are supported.

# Getting started

In the `pubspec.yaml` of your flutter project, add the following
dependency:

```yaml
dependencies:
  ...
  simple_vcard_parser: ^0.1.6
```

In your library add the following import:

```dart
import 'package:simple_vcard_parser/simple_vcard_parser.dart';
```

# Example

```dart
import 'package:simple_vcard_parser/simple_vcard_parser.dart';

String vCardExample40 = '''BEGIN:VCARD
VERSION:4.0
N:Gump;Forrest;;Mr.;
FN:Forrest Gump
ORG:Bubba Gump Shrimp Co.
TITLE:Shrimp Man
PHOTO;MEDIATYPE=image/gif:http://www.example.com/dir_photos/my_photo.gif
TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212
TEL;TYPE=home,voice;VALUE=uri:tel:+1-404-555-1212
ADR;TYPE=WORK;PREF=1;LABEL="100 Waters Edge\nBaytown\, LA 30314\nUnited States of America":;;100 Waters Edge;Baytown;LA;30314;United States of America
ADR;TYPE=HOME;LABEL="42 Plantation St.\nBaytown\, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America
EMAIL;TYPE=INTERNET:forrestgump@example.com
GENDER:M
REV:20080424T195243Z
x-qq:21588891
END:VCARD''';

void main() {
  VCard vc = VCard(vCardExample40);
  print(vc.version); // 4.0
  print(vc.formattedName); // Forrest Gump
  print(vc.organisation); // Bubba Gump Shrimp Co.
  print(vc.title); //Shrimp Man
  print(vc.typedEmail); // [[forrestgump@example.com, [INTERNET]]]
  print(vc
      .typedTelephone); // [[+1-111-555-1212, [VOICE, WORK]], [+1-404-555-1212, [HOME, VOICE]]]
  print(vc.name); //[Gump, Forrest, , Mr.,]
  print(vc.gender); //M
  print(vc
      .typedAddress); // [[[100 Waters Edge, Baytown, LA 30314, United States of America], [WORK]], [[42 Plantation St., Baytown, LA 30314, United States of America], [HOME]]]
  vc.print_lines(); // Will print all vcard lines without start and end tags

  // getWordOfPrefix() can be used to retrieve values from currently unsupported properties
  print(vc.getWordOfPrefix(
      "PHOTO;MEDIATYPE=image/gif:")); //http://www.example.com/dir_photos/my_photo.gif
}

```

# Methods and Properties
### Methods
* getWordOfPrefix (String prefix): returns the value of the provided property prefix without the prefix (first occurence only).
* getWordsOfPrefix (String prefix): similar to getWordOfPrefix, but returns all possible occurences.
* print_lines (): prints formatted vCard lines without start and end tags.

### Properties
* fullString: A vCard representation without START and END tags or any empty lines.
* version: the vCard version.
* name: returns an array containing the components of the name.
* formattedName
* email (Deprecated: refer to typedEmail)
* typedEmail: returns emails along with their types
* organisation
* title
* gender
* typedTelephone: returns an array of telephone numbers along with their type ([[+1-111..., [VOICE, WORK]], [1-404..., [HOME, VOICE]]])
* telephone: returns telephone value if type is not specified in the vCard. (Deprecated: refer to typedTelephone)

## To be supported next:
* Adresses (Done)
* Photos
* Meta-Data

## LICENSE
MIT