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
    return {
      'id': id,
      'domain': domain,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
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
