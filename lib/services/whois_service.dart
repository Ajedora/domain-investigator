import 'package:whois/whois.dart';

class WhoisService {
  Future<String> lookup(String domain) async {
    try {
      if (domain.trim().isEmpty) {
        return 'Por favor ingresa un dominio';
      }
      final result = await Whois.lookup(domain.trim());
      return result;
    } catch (e) {
      return 'Lo siento, hubo un error al buscar la información.\n\nDetalle: $e';
    }
  }
}
