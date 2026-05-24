class RecentCallModel {
  final String name;
  final String number;
  final String time;
  final bool isLocal;

  const RecentCallModel({
    required this.name,
    required this.number,
    required this.time,
    required this.isLocal,
  });

  String get typeLabel {
    return isLocal ? 'Local' : 'International';
  }
}
