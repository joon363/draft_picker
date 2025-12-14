import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'model.dart';

class ApiService {
  static const String _baseUrl = 'https://csepub.shop';
  static const String _socketUrl = 'ws://csepub.shop/ws';

  late WebSocketChannel _channel;

  Future<List<Candidate>> fetchInitialCandidates() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/candidates'));
      if (response.statusCode == 200) {
        return candidateListFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load candidates');
      }
    } catch (e) {
      print("HTTP Error: $e");
      return [];
    }
  }

  void connectSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_socketUrl));
    } catch (e) {
      print("Socket connection error: $e");
    }
  }

  Stream<List<AssignmentStatus>> get assignmentStream {
    return _channel.stream.map((data) {
      return assignmentStatusListFromJson(data);
    });
  }

  // status: "confirmed" (확정) 또는 "candidate" (후보)
  void toggleAssignment(String name, String department, String status) {
    final payload = json.encode({
      "name": name,
      "department": department,
      "status": status
    });
    _channel.sink.add(payload);
  }

  void dispose() {
    _channel.sink.close();
  }
}