import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthMapper {
  static UserEntity userModelToEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      role: model.role,
      shopName: model.shopName,
      phone: model.phone,
      subscription: model.subscription,
    );
  }

  static AuthTokensEntity tokensModelToEntity(AuthResponseModel model) {
    return AuthTokensEntity(
      accessToken: model.accessToken,
      tokenType: model.tokenType,
    );
  }
}
