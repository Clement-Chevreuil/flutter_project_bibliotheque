class myException implements Exception {

  final String message;
  myException(this.message);

  @override
  String toString() {
    return 'myException: $message';
  }
}