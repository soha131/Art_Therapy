class ResultModel {
  final String? diseaseName;
  final String imageUrl;
  final String createdAt;

  ResultModel({
    required this.diseaseName,
    required this.imageUrl,
    required this.createdAt
  });

  Map<String, dynamic> toJson() {
    return {
      "disease_name": diseaseName,
      "image": imageUrl,
      "createdAt":createdAt
    };
  }

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      diseaseName: json['disease_name'],
      imageUrl: json['image']?['secure_url'] ?? '',
        createdAt:json['createdAt']
    );
  }
}
