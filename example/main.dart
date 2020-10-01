//import 'package:simple_vcard_parser/simple_vcard_parser.dart';
import '../lib/simple_vcard_parser.dart';

String vCardExample40 = '''BEGIN:VCARD
VERSION:4.0
N:Gump;Forrest;;Mr.;
FN:Forrest Gump
ORG:Bubba Gump Shrimp Co.
TITLE:Shrimp Man
PHOTO;MEDIATYPE=image/gif:http://www.example.com/dir_photos/my_photo.gif
TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212
TEL;TYPE=home,voice;VALUE=uri:tel:+1-404-555-1212
EMAIL;HOME;INTERNET:forrestgump@example.com
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