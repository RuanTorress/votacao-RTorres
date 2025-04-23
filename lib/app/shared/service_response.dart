class ServiceResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ServiceResponse({
    required this.success,
    this.message,
    this.data,
  });
}