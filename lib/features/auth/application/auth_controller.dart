import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  const AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) =>
      AuthState(isLoading: isLoading ?? this.isLoading, error: error);
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState());

  Future<bool> signIn({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        error: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.login(email, password);
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;

        if (statusCode == 401) {
          errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        } else if (statusCode == 400) {
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'];
          } else if (data is String && data.isNotEmpty) {
            errorMessage = data;
          } else {
            errorMessage = 'البيانات المدخلة غير صحيحة';
          }
        } else if (statusCode == 404) {
          errorMessage = 'المستخدم غير موجود';
        } else if (statusCode == 429) {
          errorMessage = 'محاولات كثيرة. يرجى المحاولة لاحقاً';
        } else if (statusCode == 500) {
          errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
        } else if (data is Map && data['message'] != null) {
          errorMessage = data['message'];
        } else if (data is String && data.isNotEmpty) {
          errorMessage = data;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'لا يمكن الاتصال بالخادم، يرجى التحقق من الاتصال بالإنترنت';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
      return false;
    }
  }

  Future<String?> getUserPersonType() async {
    try {
      final userData = await _repository.getMe();
      print('getUserPersonType - full response: $userData');

      // Try different possible response structures
      String? personType;

      // Check data.person_type
      if (userData['data']?['person_type'] != null) {
        personType = userData['data']['person_type'].toString();
      }
      // Check user.person_type
      else if (userData['user']?['person_type'] != null) {
        personType = userData['user']['person_type'].toString();
      }
      // Check direct person_type
      else if (userData['person_type'] != null) {
        personType = userData['person_type'].toString();
      }

      print('getUserPersonType - extracted person_type: $personType');
      return personType;
    } catch (e) {
      print('getUserPersonType - error: $e');
      return null;
    }
  }

  Future<void> updateUserDataInStorage() async {
    try {
      final userData = await _repository.getMe();
      print('updateUserDataInStorage - userData: $userData');

      if (userData['data'] != null && userData['data'] is Map) {
        final user = userData['data'] as Map<String, dynamic>;
        print('updateUserDataInStorage - user: $user');

        await _repository.updateUserDataInStorage(
          name: user['name']?.toString(),
          email: user['email']?.toString(),
          identificationType: user['identification_type']?.toString(),
          identificationNumber: user['identification_number']?.toString(),
        );
        print('Updated user data in storage');
      }
    } catch (e, stackTrace) {
      print('Error updating user data in storage: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

final passwordVisibleProvider = StateProvider.autoDispose<bool>((ref) => false);
