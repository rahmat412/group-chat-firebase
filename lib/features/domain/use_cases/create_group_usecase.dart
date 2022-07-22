import 'package:group_chat/features/domain/entities/group_entity.dart';
import 'package:group_chat/features/domain/entities/my_chat_entity.dart';
import 'package:group_chat/features/domain/repositories/firebase_repository.dart';

class GetCreateGroupUseCase {
  final FirebaseRepository repository;

  GetCreateGroupUseCase({required this.repository});

  Future<void> call(GroupEntity groupEntity) async {
    return await repository.getCreateGroup(groupEntity);
  }
}
