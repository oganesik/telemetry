// lib/services/socket_service.dart

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;

  IO.Socket? createSocket(String serverUrl) {
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(3000)
          .build(),
    );
    return _socket;
  }

  void connect({
    required IO.Socket socket,
    required String roomId,
    required void Function() onConnected,
    required void Function(String error) onError,
    required void Function() onDisconnected,
    required void Function(Map<String, dynamic> data, int timestamp) onNewData,
  }) {
    socket.onConnect((_) {
      debugPrint('[SocketService] onConnect() вызван');
      onConnected();
      debugPrint('[SocketService] шлём joinRoom → {"roomId": "$roomId"}');
      socket.emit('joinRoom', {'roomId': roomId});
    });

    socket.onConnectError((err) {
      debugPrint('[SocketService] onConnectError(): $err');
      onError(err.toString());
    });

    socket.onError((err) {
      debugPrint('[SocketService] onError(): $err');
      onError(err.toString());
    });

    socket.onDisconnect((_) {
      debugPrint('[SocketService] onDisconnect()');
      onDisconnected();
    });

    socket.on('joined', (payload) {
      debugPrint('[SocketService] сервер вернул joined: $payload');
    });

    socket.on('newData', (payload) {
      debugPrint('[SocketService] сервер выдал newData: $payload');
      try {
        final data = Map<String, dynamic>.from(payload['data'] as Map);
        final timestamp = payload['timestamp'] as int;
        onNewData(data, timestamp);
      } catch (e) {
        debugPrint('[SocketService] ошибка парсинга newData: $e');
      }
    });

    debugPrint('[SocketService] вызываем socket.connect()');
    socket.connect();
  }

  void sendData({
    required IO.Socket socket,
    required String roomId,
    required Map<String, dynamic> data,
  }) {
    debugPrint(
      '[SocketService] emit sendData → { roomId: $roomId, data: $data }',
    );
    socket.emit('sendData', {'roomId': roomId, 'data': data});
  }

  void disconnect(IO.Socket? socket) {
    if (socket != null) {
      debugPrint('[SocketService] socket.disconnect()');
      socket.disconnect();
    }
  }
}
