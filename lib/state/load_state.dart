import '../core/network/app_exception.dart';

enum LoadStatus { idle, loading, ready, error }

/// Provider'larda yuklash holatini bir xil ko'rinishda saqlash uchun mixin.
mixin LoadStateMixin {
  LoadStatus status = LoadStatus.idle;
  String? errorCode;

  bool get isLoading => status == LoadStatus.loading;
  bool get hasError => status == LoadStatus.error;

  static String codeOf(Object error) =>
      error is AppException ? error.code : 'err_unknown';
}
