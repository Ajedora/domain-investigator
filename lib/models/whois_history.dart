class WhoisHistory {
  final int? id;
  final String domain;
  final String data;
  final DateTime timestamp;

  WhoisHistory({
    this.id,
    required this.domain,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'domain': domain,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory WhoisHistory.fromMap(Map<String, dynamic> map) {
    return WhoisHistory(
      id: map['id'],
      domain: map['domain'],
      data: map['data'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
