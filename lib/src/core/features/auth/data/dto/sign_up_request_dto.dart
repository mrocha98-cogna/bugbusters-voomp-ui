class SignUpRequestDto {
  final String email;
  final String name;
  final String cpf;
  final String phoneNumber;
  final String password;
  final OnboardingDto onboarding;

  SignUpRequestDto({
    required this.email,
    required this.name,
    required this.cpf,
    required this.phoneNumber,
    required this.password,
    required this.onboarding,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "name": name,
      "cpf": cpf,
      "phoneNumber": phoneNumber,
      "password": password,
      "onboarding": onboarding.toJson(),
    };
  }
}

class OnboardingDto {
  final String? howKnew;
  final bool alreadySellOnline;
  final String? goal;

  OnboardingDto({
    required this.howKnew,
    required this.alreadySellOnline,
    required this.goal,
  });

  Map<String, dynamic> toJson() {
    return {
      "howKnew": howKnew,
      "alreadySellOnline": alreadySellOnline,
      "goal": goal,
    };
  }
}
