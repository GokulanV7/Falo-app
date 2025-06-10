import 'dart:convert';
import 'dart:async'; // For TimeoutException
import 'dart:io';    // For SocketException
import 'package:http/http.dart' as http;

class MisinformationService {
  // --- IMPORTANT: Replace with your actual backend URL ---
  // Example: If your backend runs locally on port 8000
  // For Android Emulator: final String _baseUrl = 'http://10.0.2.2:8000';
  // For iOS Simulator/Physical Device on same network: Find your machine's local IP (e.g., 192.168.1.10)
  // final String _baseUrl = 'http://YOUR_MACHINE_IP:8000';
  // For a deployed backend: final String _baseUrl = 'https://your-api.com';
  final String _baseUrl ='http://127.0.0.1:8000'; // <-- CHANGE THIS
  // -----------------------------------------------------

  final String _analyzeEndpoint = '/analyze'; // Your specific endpoint

  // Fetches analysis from the backend API
  Future<Map<String, dynamic>> analyzeText(String query) async {
    final Uri url = Uri.parse('$_baseUrl$_analyzeEndpoint');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    // Assume backend expects JSON like: {"text": "user query"}
    final body = jsonEncode({'text': query});

    print('Sending request to: $url');
    print('Request body: $body');

    try {
      final response = await http
          .post(
        url,
        headers: headers,
        body: body,
      )
          .timeout(const Duration(seconds: 30)); // Add timeout

      print('Response status code: ${response.statusCode}');
      // print('Response body: ${response.body}'); // Be careful logging potentially large/sensitive data

      if (response.statusCode == 200) {
        // Successfully received response
        final decodedBody = jsonDecode(utf8.decode(response.bodyBytes)); // Handle UTF-8 properly
        if (decodedBody is Map<String, dynamic>) {
          print('Decoded Response: $decodedBody');
          return decodedBody;
        } else {
          throw const FormatException('Backend response was not a valid JSON object.');
        }
      } else {
        // Handle server-side errors (4xx, 5xx)
        String errorMessage = 'Analysis failed (Status code: ${response.statusCode}).';
        try {
          // Try to include error detail from backend if available
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map && errorJson.containsKey('detail')) {
            errorMessage += ' Detail: ${errorJson['detail']}';
          } else {
            errorMessage += ' Response: ${response.body}'; // Fallback
          }
        } catch (_) {
          // Ignore if response body isn't valid JSON
          errorMessage += ' Could not parse error response body.';
        }
        throw HttpException(errorMessage);
      }
    } on TimeoutException catch (_) {
      print('Error: Request timed out.');
      throw TimeoutException('The request timed out. Please try again.');
    } on SocketException catch (e) {
      print('Error: SocketException - ${e.message}');
      throw SocketException('Could not connect to the server. Check your network connection and the server address ($_baseUrl).');
    } on FormatException catch (e) {
      print('Error: Invalid JSON format received from backend - ${e.message}');
      throw FormatException('Received an invalid response format from the server.');
    } on HttpException catch(e) {
      print('Error: HTTP Error - ${e.message}');
      rethrow; // Re-throw the custom HTTP exception
    }
    catch (e) {
      // Catch any other unexpected errors
      print('Error during analysis request: $e');
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}