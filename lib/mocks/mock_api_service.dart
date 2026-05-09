class MockApiService {
  static final Map<String, dynamic> _mockData = {};
  static bool _shouldThrowError = false;
  static String _errorMessage = 'Mock API error';

  static void setMockData(String endpoint, dynamic data) {
    _mockData[endpoint] = data;
  }

  static void clearMockData() {
    _mockData.clear();
  }

  static Future<Response> get(String path) {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    final data = _mockData[path] ?? {};
    return Future.value(Response(200, data));
  }

  static Future<Response> put(String path, {required Map<String, dynamic> body}) {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    _mockData[path] = body;
    return Future.value(Response(200, body));
  }

  static Future<Response> delete(String path) {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    _mockData.remove(path);
    return Future.value(Response(200, {}));
  }

  static dynamic handleResponse(Response response) {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    return response.data;
  }

  static void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  static void setErrorMessage(String message) {
    _errorMessage = message;
  }
}

// Simple mock Response class
class Response {
  final int statusCode;
  final dynamic data;

  Response(this.statusCode, this.data);
}
