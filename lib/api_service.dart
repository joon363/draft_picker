import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // ValueNotifier, debugPrint 사용
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'model.dart';

// 웹소켓 연결 상태를 나타내는 열거형
enum SocketStatus { connecting, connected, disconnected }

class ApiService {
  static const String _baseUrl = 'https://csepub.shop';
  static const String _socketUrl = 'wss://csepub.shop/ws';

  WebSocketChannel? _channel;
  final StreamController<List<AssignmentStatus>> _assignmentController =
  StreamController<List<AssignmentStatus>>.broadcast();

  // 웹소켓 상태를 외부에 노출하기 위한 Notifier
  final ValueNotifier<SocketStatus> socketStatus =
  ValueNotifier(SocketStatus.disconnected);

  // 재연결 타이머와 구독 관리
  Timer? _reconnectTimer;
  StreamSubscription? _socketSubscription;

  Future<List<Candidate>> fetchInitialCandidates() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/candidates'));
      if (response.statusCode == 200) {
        return candidateListFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load candidates');
      }
    } catch (e) {
      debugPrint("HTTP Error: $e");
      return [];
    }
  }

  void connectSocket({bool isInitial = true}) {
    // 이미 연결 중이면 재시도하지 않음
    if (socketStatus.value == SocketStatus.connecting && !isInitial) {
      return;
    }

    _reconnectTimer?.cancel();
    _socketSubscription?.cancel();

    // 연결 시도 상태로 변경
    socketStatus.value = SocketStatus.connecting;
    debugPrint("Attempting to connect to WebSocket...");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_socketUrl));

      // 연결 성공 시 상태 변경
      _channel!.ready.then((_) {
        socketStatus.value = SocketStatus.connected;
        debugPrint("WebSocket connected successfully.");
      }).catchError((error) {
        debugPrint("WebSocket ready error: $error");
        _handleDisconnect();
      });

      // 웹소켓 스트림 구독 및 상태 관리
      _socketSubscription = _channel!.stream.listen(
            (data) {
          // 데이터 수신 시, 연결 상태 유지
          if (socketStatus.value != SocketStatus.connected) {
            socketStatus.value = SocketStatus.connected;
          }
          try {
            _assignmentController.add(assignmentStatusListFromJson(data));
          } catch (e) {
            debugPrint("Data parsing error: $e");
          }
        },
        onError: (error) {
          debugPrint("WebSocket stream error: $error");
          _handleDisconnect();
        },
        onDone: () {
          debugPrint("WebSocket connection closed (onDone).");
          _handleDisconnect();
        },
      );
    } catch (e) {
      debugPrint("Socket connection attempt failed: $e");
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    // disconnected 상태가 아니면 상태를 변경
    if (socketStatus.value != SocketStatus.disconnected) {
      socketStatus.value = SocketStatus.disconnected;
    }

    // 연결 끊김 상태로 변경 후 재연결 타이머 시작 (5초 후)
    if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        connectSocket(isInitial: false);
      });
      debugPrint("Scheduled reconnection in 5 seconds.");
    }
  }

  // ViewModel에서 사용할 스트림
  Stream<List<AssignmentStatus>> get assignmentStream =>
      _assignmentController.stream;

  // status: "confirmed" (확정) 또는 "candidate" (후보)
  void toggleAssignment(String name, String department, String status) {
    if (socketStatus.value != SocketStatus.connected || _channel == null) {
      debugPrint("Socket not connected. Assignment not sent.");
      return;
    }
    final payload = json.encode({
      "name": name,
      "department": department,
      "status": status
    });
    _channel!.sink.add(payload);
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _socketSubscription?.cancel();
    _channel?.sink.close();
    _assignmentController.close();
    socketStatus.dispose(); // ValueNotifier 리소스 해제
  }
}