class AuthResponseModel {
  final String accessToken;
  final String tokenType;

  const AuthResponseModel({
    required this.accessToken,
    this.tokenType = 'Bearer',
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '',
      tokenType: json['tokenType'] ?? json['token_type'] ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
    };
  }
}
