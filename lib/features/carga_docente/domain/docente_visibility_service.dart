import '../../../core/models/user_role.dart';

abstract final class DocenteVisibilityService {
  static bool canProfessorSeeDocente({
    required String? currentUserId,
    required String? currentUserEmail,
    required String? docenteUserId,
    required String? docenteUserEmail,
  }) {
    final normalizedCurrentId = currentUserId?.trim();
    final normalizedDocenteId = docenteUserId?.trim();

    if (normalizedCurrentId != null &&
        normalizedCurrentId.isNotEmpty &&
        normalizedDocenteId != null &&
        normalizedDocenteId.isNotEmpty) {
      return normalizedCurrentId == normalizedDocenteId;
    }

    final normalizedCurrentEmail = currentUserEmail?.trim().toLowerCase() ?? '';
    final normalizedDocenteEmail = docenteUserEmail?.trim().toLowerCase() ?? '';
    if (normalizedCurrentEmail.isEmpty || normalizedDocenteEmail.isEmpty) {
      return false;
    }

    return normalizedCurrentEmail == normalizedDocenteEmail;
  }

  static List<T> filterDocentesForRole<T>({
    required UserRole role,
    required List<T> docentes,
    required String? currentUserId,
    required String? currentUserEmail,
    required String? Function(T docente) getUserId,
    required String? Function(T docente) getUserEmail,
  }) {
    if (role != UserRole.professor) {
      return docentes;
    }

    return docentes
        .where(
          (docente) => canProfessorSeeDocente(
            currentUserId: currentUserId,
            currentUserEmail: currentUserEmail,
            docenteUserId: getUserId(docente),
            docenteUserEmail: getUserEmail(docente),
          ),
        )
        .toList(growable: false);
  }
}
