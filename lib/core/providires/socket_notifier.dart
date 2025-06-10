// lib/notifiers/socket_notifier.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:telemetry/core/models/socket_io_state.dart';
import 'package:telemetry/core/socket_io_client.dart';

class SocketNotifier extends StateNotifier<SocketState> {
  final SocketService _service;
  IO.Socket? _socket;
  final String serverUrl;

  SocketNotifier({required this.serverUrl})
    : _service = SocketService(),
      super(SocketState.initial());

  Future<void> init(String roomId) async {
    debugPrint('[SocketNotifier] init(roomId=$roomId)');
    if (_socket != null) {
      debugPrint('[SocketNotifier] есть старый сокет, отключаем его');
      _service.disconnect(_socket);
      _socket = null;
      state = SocketState.initial();
    }

    state = state.copyWith(
      status: SocketStatus.connecting,
      roomId: roomId,
      errorMessage: null,
    );

    final socket = _service.createSocket(serverUrl);
    _socket = socket;

    _service.connect(
      socket: socket!,
      roomId: roomId,
      onConnected: () {
        debugPrint('[SocketNotifier] onConnected()');
        state = state.copyWith(status: SocketStatus.connected);
      },
      onError: (error) {
        debugPrint('[SocketNotifier] onError($error)');
        state = state.copyWith(status: SocketStatus.error, errorMessage: error);
      },
      onDisconnected: () {
        debugPrint('[SocketNotifier] onDisconnected()');
        state = state.copyWith(status: SocketStatus.disconnected);
      },
      onNewData: (data, timestamp) {
        debugPrint(
          '[SocketNotifier] onNewData(data=$data, timestamp=$timestamp)',
        );
        state = state.copyWith(
          lastData: data,
          lastTimestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        );
      },
    );
  }

  void send(Map<String, dynamic> data) {
    final currentRoom = state.roomId;
    debugPrint('[SocketNotifier] send(data=$data) при roomId=$currentRoom');
    if (_socket == null || currentRoom == null) {
      debugPrint(
        '[SocketNotifier] Нельзя отправить, тк _socket==null или roomId==null',
      );
      return;
    }
    _service.sendData(socket: _socket!, roomId: currentRoom, data: data);
  }

  void disposeSocket() {
    debugPrint('[SocketNotifier] disposeSocket()');
    if (_socket != null) {
      _service.disconnect(_socket);
      _socket = null;
    }
    state = SocketState.initial();
  }

  @override
  void dispose() {
    debugPrint('[SocketNotifier] dispose()');
    disposeSocket();
    super.dispose();
  }
}
