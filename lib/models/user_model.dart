class UserModel {
  String email;
  String name;
  String relation;
  int age;
  String? gender;

  UserModel({
    required this.age,
    required this.relation,
    required this.email,
    required this.name,
    required this.gender,
  });
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "name": name,
      "age": age,
      "relation": relation,
      "gender": gender ,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        age: int.tryParse(json['age'].toString()) ?? 0,
        relation: json['relation'] ?? '',
        gender: json['gender'],
      );
    } catch (e) {
      throw Exception("Error parsing user data: $e");
    }
  }


}
