import 'package:whois/whois.dart';

void main() async {
  try {
    var result = await Whois.lookup('google.com');
    print(result.substring(0, 100)); // just print first 100
  } catch (e) {
    print('Error: $e');
  }
}
