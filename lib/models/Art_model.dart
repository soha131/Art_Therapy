class ArtPrediction {
  final String? prediction;
  final String? diagnosis;
  final String? support;

  ArtPrediction({
    required this.prediction,
    required this.diagnosis,
    required this.support

  });

  factory ArtPrediction.fromJson(Map<String, dynamic> json) {
    return ArtPrediction(
      prediction: json['label'] ?? json['التصنيف_العربي'] ?? 'Unknown',
      diagnosis: json['diagnosis'] ?? json['التشخيص'] ?? 'Unknown',
      support: json['support'] ?? json['الدعم_المقترح'] ?? 'Unknown',

    );
  }
}
