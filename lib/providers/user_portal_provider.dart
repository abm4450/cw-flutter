import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty.dart';
import '../models/wash_record.dart';
import '../providers/auth_provider.dart';

class UserPortalState {
  final Loyalty? loyalty;
  final WashRecord? lastWash;
  final bool loading;

  const UserPortalState({this.loyalty, this.lastWash, this.loading = true});

  UserPortalState copyWith({
    Loyalty? loyalty,
    WashRecord? lastWash,
    bool? loading,
  }) =>
      UserPortalState(
        loyalty: loyalty ?? this.loyalty,
        lastWash: lastWash ?? this.lastWash,
        loading: loading ?? this.loading,
      );
}

class UserPortalNotifier extends StateNotifier<UserPortalState> {
  final Ref _ref;
  Timer? _pollTimer;

  UserPortalNotifier(this._ref) : super(const UserPortalState()) {
    _loadData();
    _startPolling();
  }

  Future<void> _loadData() async {
    try {
      final userService = _ref.read(userServiceProvider);
      final results = await Future.wait([
        userService.getLoyalty(),
        userService.getWashes(),
      ]);
      final loyalty = results[0] as Loyalty;
      final washes = results[1] as List<WashRecord>;
      state = UserPortalState(
        loyalty: loyalty,
        lastWash: washes.isNotEmpty ? washes.first : null,
        loading: false,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final userPortalProvider =
    StateNotifierProvider.autoDispose<UserPortalNotifier, UserPortalState>(
  (ref) => UserPortalNotifier(ref),
);
