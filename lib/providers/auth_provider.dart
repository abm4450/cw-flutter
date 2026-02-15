import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/api_error.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/api_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

// Singletons
final secureStorageProvider = Provider((_) => SecureStorageService());
final apiClientProvider = Provider((ref) => ApiClient(ref.read(secureStorageProvider)));
final authServiceProvider = Provider((ref) => AuthService(ref.read(apiClientProvider)));
final userServiceProvider = Provider((ref) => UserService(ref.read(apiClientProvider)));

// Auth state
enum AuthStatus { loading, unauthenticated, customer, admin }

class AuthState {
  final AuthStatus status;
  final ApiUser? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, ApiUser? user, String? error}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.getToken();
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _ref.read(userServiceProvider).getMe();
      state = AuthState(
        status: user.isAdmin ? AuthStatus.admin : AuthStatus.customer,
        user: user,
      );
    } on ApiError catch (e) {
      if (e.statusCode == 401) {
        await storage.clearToken();
      }
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String token, ApiUser user) async {
    final storage = _ref.read(secureStorageProvider);
    await storage.setToken(token);
    state = AuthState(
      status: user.isAdmin ? AuthStatus.admin : AuthStatus.customer,
      user: user,
    );
  }

  Future<void> logout() async {
    try {
      await _ref.read(authServiceProvider).logout();
    } catch (_) {}
    final storage = _ref.read(secureStorageProvider);
    await storage.clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshMe() async {
    try {
      final user = await _ref.read(userServiceProvider).getMe();
      state = AuthState(
        status: user.isAdmin ? AuthStatus.admin : AuthStatus.customer,
        user: user,
      );
    } catch (_) {}
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
