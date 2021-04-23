// 📦 Package imports:
// 🌎 Project imports:
import 'package:c_school_app/app/data/service/logger_service.dart';
import 'package:flamingo/flamingo.dart';
import 'package:logger/logger.dart';

import '../model/user/user.dart';

abstract class UserProvider {
  /// If id = null, a new instance of AppUser will be generated
  /// If id != null, but user is not in DB, return null
  Future<AppUser?> get(String? id);

  Future<void> register(AppUser appUser);

  Future<void> update(AppUser appUser);

  Future<void> delete(AppUser appUser);
}

class UserFirebaseProvider implements UserProvider {
  DocumentAccessor documentAccessor = DocumentAccessor();
  Logger logger = LoggerService.logger;

  @override
  Future<void> delete(AppUser appUser) async {
    await documentAccessor.delete(appUser);
  }

  @override
  Future<AppUser?> get(String? id) async {
    if (id == null) {
      logger.i('Id is null, generate new AppUser');
      return AppUser();
    }
    var user = await documentAccessor.load<AppUser>(AppUser(id: id));
    if (user == null) {
      return null;
    } else {
      return user;
    }
  }

  @override
  Future<void> register(AppUser appUser) async {
    await documentAccessor.save(appUser);
  }

  @override
  Future<void> update(AppUser appUser) async {
    await documentAccessor.update(appUser);
  }
}
