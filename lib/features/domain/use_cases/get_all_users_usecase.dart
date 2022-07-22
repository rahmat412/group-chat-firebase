import 'package:group_chat/features/domain/entities/user_entity.dart';
import 'package:group_chat/features/domain/repositories/firebase_repository.dart';

class GetAllUsersUseCase {
  final FirebaseRepository repository;

  GetAllUsersUseCase({required this.repository});

  Stream<List<UserEntity>> call() {
    return repository.getAllUsers();
  }
}
