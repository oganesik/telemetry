// lib/models/socket_state.dart

enum SocketStatus { disconnected, connecting, connected, error }

class SocketState {
  final SocketStatus status;
  final String? roomId;
  final String? errorMessage;
  final Map<String, dynamic>? lastData; // последний принятый объект из newData
  final DateTime? lastTimestamp;

  const SocketState({
    required this.status,
    this.roomId,
    this.errorMessage,
    this.lastData,
    this.lastTimestamp,
  });

  // Удобный factory для “чистой” disconnected
  factory SocketState.initial() {
    return const SocketState(
      status: SocketStatus.disconnected,
      roomId: null,
      errorMessage: null,
      lastData: null,
      lastTimestamp: null,
    );
  }

  // Метод, возвращающий копию с изменёнными полями (copyWith)
  SocketState copyWith({
    SocketStatus? status,
    String? roomId,
    String? errorMessage,
    Map<String, dynamic>? lastData,
    DateTime? lastTimestamp,
  }) {
    return SocketState(
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      errorMessage: errorMessage,
      lastData: lastData,
      lastTimestamp: lastTimestamp,
    );
  }
}
