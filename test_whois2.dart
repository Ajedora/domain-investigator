import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  String domain = 'google.dev';
  try {
    print('Querying IANA...');
    var socket = await Socket.connect('whois.iana.org', 43);
    socket.write('$domain\r\n');
    String response = '';
    await for (var data in socket.transform(utf8.decoder)) {
      response += data;
    }
    socket.destroy();
    
    print('IANA Response length: ${response.length}');
    
    // Find refer
    String? refer;
    for (var line in response.split('\n')) {
      if (line.toLowerCase().startsWith('refer:')) {
        refer = line.substring(6).trim();
        break;
      } else if (line.toLowerCase().startsWith('whois:')) {
        refer = line.substring(6).trim();
        break;
      }
    }
    
    if (refer != null) {
      print('Found refer: $refer. Querying...');
      var socket2 = await Socket.connect(refer, 43);
      socket2.write('$domain\r\n');
      String response2 = '';
      await for (var data in socket2.transform(utf8.decoder)) {
        response2 += data;
      }
      socket2.destroy();
      print('Refer Response length: ${response2.length}');
      print(response2.substring(0, 50));
    } else {
      print('No refer found.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
