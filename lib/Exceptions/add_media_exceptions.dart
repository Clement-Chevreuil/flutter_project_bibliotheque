class AddMediaException implements Exception {

  final String message;
  AddMediaException(this.message);

  @override
  String toString() {
    return 'AddMediaException: $message';
  }
}