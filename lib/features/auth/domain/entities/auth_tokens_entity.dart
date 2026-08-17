class AuthTokensEntity {
  final String accessToken;
  final String tokenType;

  const AuthTokensEntity({
    required this.accessToken,
    this.tokenType = 'Bearer',
  });
}
