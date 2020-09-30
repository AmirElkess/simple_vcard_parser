# simple_vcard_parser

A simple and easy to use parser to extract information from a standard vCard string. Major vCard properties from versions 2.1, 3.0, 4.0 are supported.

# Getting started

In the `pubspec.yaml` of your flutter project, add the following
dependency:

```yaml
dependencies:
  ...
  simple_vcard_parser: "^0.1.0"
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
EMAIL:forrestgump@example.com
END:VCARD''';

void main() {
    VCard vc = VCard(vCardExample40);
    print(vc.version); // 4.0
    print(vc.formattedName); // Forrest Gump
    print(vc.email); //forrestgump@example.com
    print(vc.typedTelephone); // [[+1-111-555-1212, work], [1-404-555-1212, home]]
    print(vc.name); //[Gump, Forrest, , Mr.,]

    //getWordOfPrefix() can be used to retrieve values from currently unsupported properties
    print(vc.getWordOfPrefix("PHOTO;MEDIATYPE=image/gif:")); //http://www.example.com/dir_photos/my_photo.gif
}

```

# Methods and Properties
### Methods
* getWordOfPrefix (String prefix): returns the value of the provided property prefix without the prefix (first occurence only).
* getWordsOfPrefix (String prefix): similar to getWordOfPrefix, but returns all possible occurences.

### Properties
* fullString: A vCard representation without START and END tags or any empty lines.
* version: the vCard version.
* name: returns an array containing the components of the name.
* formattedName.
* email.
* organisation.
* title.
* typedTelephone: returns an array of telephone numbers along with their type ([[+1-111..., work], [1-404..., home]])
* telephone: returns telephone value if type is not specified in the vCard.


## LICENSE
MIT