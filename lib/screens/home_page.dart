import 'package:flutter/material.dart';
import 'package:domain_investigator/services/whois_service.dart';
import 'package:domain_investigator/services/db_service.dart';
import 'package:domain_investigator/models/whois_history.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const HomePage({super.key, required this.onThemeToggle});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final WhoisService _whoisService = WhoisService();

  bool _isLoading = false;
  String _data = '';
  List<WhoisHistory> _historyList = [];

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await DatabaseService.instance.getAllHistory();
    setState(() {
      _historyList = history;
    });
  }

  Future<void> _deleteCurrentResult() async {
    final domain = _searchController.text.trim();
    if (domain.isNotEmpty) {
      await DatabaseService.instance.deleteHistory(domain);
      _clearData();
      _loadHistory();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onSearch() async {
    final domain = _searchController.text.trim();
    if (domain.isEmpty) return;

    setState(() {
      _isLoading = true;
      _data = '';
      _animController.reset();
    });

    FocusScope.of(context).unfocus(); // dismiss keyboard

    final result = await _whoisService.lookup(domain);

    if (!result.startsWith('Lo siento')) {
       await DatabaseService.instance.insertHistory(
          WhoisHistory(domain: domain, data: result, timestamp: DateTime.now())
       );
       await _loadHistory();
    }

    setState(() {
      _data = result;
      _isLoading = false;
      _animController.forward();
    });
  }

  void _clearData() {
    setState(() {
      _searchController.clear();
      _data = '';
      _animController.reset();
      _animController.forward();
    });
  }

  void _clearInput() {
    setState(() {
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_data.isNotEmpty) {
          _clearData();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _data.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _clearData,
                  tooltip: 'Volver al Inicio',
                )
              : null,
        title: const Text(
          'WHOIS',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Ayuda y Legal',
          ),
          if (_data.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteCurrentResult,
              tooltip: 'Borrar este Resultado',
            ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onThemeToggle,
            tooltip: 'Cambiar Tema',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(minHeight: 3),

          // Results Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_data.isEmpty && !_isLoading && _historyList.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.travel_explore_rounded,
                                size: 80,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Esta app usa el protocolo WHOIS para obtener la información del dominio. Guarda tus búsquedas aquí.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_data.isEmpty && !_isLoading && _historyList.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _historyList.length,
                        itemBuilder: (context, index) {
                          final item = _historyList[index];
                          return Card(
                            elevation: 2,
                            color: Theme.of(context).colorScheme.surface,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(item.domain, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year} ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
                              onTap: () {
                                _searchController.text = item.domain;
                                setState(() {
                                  _data = item.data;
                                  _animController.reset();
                                  _animController.forward();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    if (_data.isNotEmpty)
                      Card(
                        elevation: 8,
                        shadowColor: Colors.black45,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.feed_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Resultado',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              _buildParsedWhois(_data),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar Section (Moved to bottom)
          Container(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 12.0,
              bottom: 12.0 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, -2), // Slight upward shadow
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'dominio.com',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors
                                  .grey
                                  .shade700 // Lighter grey in dark mode
                            : Colors.grey.shade400, // Light grey in light mode
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: _clearInput,
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                    onChanged: (text) {
                      setState(() {}); // to trigger suffix icon visibility
                    },
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _isLoading ? null : _onSearch,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildParsedWhois(String data) {
    if (data.trim().isEmpty) return const SizedBox.shrink();

    final lines = data.split('\n');
    List<Widget> children = [];

    // Título de sección (en reemplazo del Divider superior)
    children.add(const Divider(height: 30, color: Colors.white12));

    for (String line in lines) {
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 8));
        continue;
      }

      int colonIdx = line.indexOf(':');
      if (colonIdx != -1 && colonIdx < 50) {
        String key = line.substring(0, colonIdx).trim();
        String value = line.substring(colonIdx + 1).trim();

        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SelectableText.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                ),
                children: [
                  TextSpan(
                    text: '$key:\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Plain text (disclaimers, comments, ASCII lines)
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: SelectableText(
              line.trim(),
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade500
                    : Colors.grey.shade500,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Ayuda e Info Legal', style: TextStyle(fontSize: 18)),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Funcionamiento:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Domain Investigator realiza consultas recursivas nativas (Sockets TCP) a los servidores IANA y registradores globales para obtener datos del dominio sin depender de APIs de terceros.', style: TextStyle(fontSize: 14, height: 1.3)),
                const SizedBox(height: 16),
                const Text('Dependencias Utilizadas:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('• flutter / dart:io (Core frameworks)\n• sqflite & sqflite_common_ffi (Almacenamiento)\n• path (Manejo de rutas locales)', style: TextStyle(fontSize: 14, height: 1.3)),
                const SizedBox(height: 16),
                const Text('Términos Legales y Privacidad:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('La información resultante recae bajo las normas y responsabilidades de ICANN y los registradores administradores ("AS-IS"). Esta aplicación:\n\n1. NO rastrea tus consultas ni vende tu información.\n2. Almacena tu historial de manera 100% aislada de forma local en tu dispositivo mediante SQLite.\n3. Provee la red directamente hacia los servidores oficiales para evadir rastreo comercial de web tools.', style: TextStyle(fontSize: 14, height: 1.3)),
              ]
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ENTENDIDO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
