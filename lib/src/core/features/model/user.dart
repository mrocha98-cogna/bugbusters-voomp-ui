class User{
  String id;
  String name;
  String email;
  String password;
  String cpf;
  String phone;
  String userOnboardingId;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.cpf,
    required this.phone,
    required this.password,
    required this.userOnboardingId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      cpf: json['cpf'],
      phone: json['phone'],
      userOnboardingId: json['userOnboardingId'],
    );
  }
}