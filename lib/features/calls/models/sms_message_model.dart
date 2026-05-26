class SmsMessageModel {
  final String id;
  final String phoneNumber;
  final String sender;
  final String body;
  final String? providerMessageId;
  final DateTime receivedAt;

  const SmsMessageModel({
    required this.id,
    required this.phoneNumber,
    required this.sender,
    required this.body,
    required this.receivedAt,
    this.providerMessageId,
  });

  factory SmsMessageModel.fromJson(Map<String, dynamic> json) {
    return SmsMessageModel(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      providerMessageId: json['providerMessageId']?.toString(),
      receivedAt:
          DateTime.tryParse(json['receivedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
