import 'dart:io';
import 'dart:convert';

class WhoisService {
  Future<String> lookup(String domain) async {
    try {
      if (domain.trim().isEmpty) {
        return 'Por favor ingresa un dominio';
      }
      
      final cleanDomain = domain.trim().toLowerCase();
      
      // Step 1: Query the Root IANA Server
      String? referServer = await _queryServer('whois.iana.org', cleanDomain, extractRefer: true);
      
      // Step 2: Query the Referral Server (TLD specific)
      if (referServer != null && referServer.isNotEmpty) {
        return await _queryServer(referServer, cleanDomain) ?? 'Sin respuesta del servidor referenciado.';
      } else {
        // Fallback: If no refer server found, try guessing based on domain extension or return IANA result
        final tld = cleanDomain.split('.').last;
        final guessServer = 'whois.nic.$tld';
        try {
           final fallbackResponse = await _queryServer(guessServer, cleanDomain);
           if (fallbackResponse != null && fallbackResponse.isNotEmpty) {
             return fallbackResponse;
           }
        } catch (_) {}
        
        return await _queryServer('whois.iana.org', cleanDomain) ?? 'No se encontró información WHOIS para este dominio.';
      }
    } catch (e) {
      return 'Lo siento, hubo un error al buscar la información.\n\nDetalle: $e';
    }
  }

  Future<String?> _queryServer(String server, String domain, {bool extractRefer = false}) async {
    try {
      final socket = await Socket.connect(server, 43, timeout: const Duration(seconds: 10));
      socket.write('$domain\r\n');
      
      String response = '';
      await for (var data in socket) {
        response += utf8.decode(data, allowMalformed: true);
      }
      socket.destroy();
      
      if (extractRefer) {
        // Extract refer string
        for (var line in response.split('\n')) {
          if (line.trim().toLowerCase().startsWith('refer:')) {
            return line.split(':')[1].trim();
          } else if (line.trim().toLowerCase().startsWith('whois:')) {
             return line.split(':')[1].trim();
          }
        }
        return null;
      }
      
      return response;
    } catch (e) {
      if (extractRefer) return null;
      throw Exception('Fallo la conexión al servidor WHOIS ($server).');
    }
  }
}

