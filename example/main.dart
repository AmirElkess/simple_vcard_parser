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
ADR;TYPE=WORK;PREF=1;LABEL="100 Waters Edge\nBaytown\, LA 30314\nUnited States of America":;;100 Waters Edge;Baytown;LA;30314;United States of America
ADR;TYPE=HOME;LABEL="42 Plantation St.\nBaytown\, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America
EMAIL:forrestgump@example.com
REV:20080424T195243Z
x-qq:21588891
END:VCARD''';

void main() {
    VCard vc = VCard(vCardExample40);
    print(vc.version); // 4.0
    print(vc.formattedName); // Forrest Gump
    print(vc.organisation); // Bubba Gump Shrimp Co.
    print(vc.title); //Shrimp Man
    print(vc.email); //forrestgump@example.com
    print(vc.typedTelephone); // [[+1-111-555-1212, [VOICE, WORK]], [+1-404-555-1212, [HOME, VOICE]]]
    print(vc.name); //[Gump, Forrest, , Mr.,]

    //getWordOfPrefix() can be used to retrieve values from currently unsupported properties
    print(vc.getWordOfPrefix("PHOTO;MEDIATYPE=image/gif:")); //http://www.example.com/dir_photos/my_photo.gif
}