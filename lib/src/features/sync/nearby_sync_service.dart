import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../domain/models.dart';
import 'sync_models.dart';

typedef OnBytesMessage =
    Future<void> Function(String endpointId, Map<String, dynamic> message);
typedef OnFileReceived =
    Future<void> Function(String endpointId, InboundFileTransfer transfer);

class NearbySyncService {
  NearbySyncService() : _nearby = Nearby();

  final Nearby _nearby;
  final Map<String, String> _discovered = <String, String>{};
  OnBytesMessage? _onBytesMessage;
  OnFileReceived? _onFileReceived;

  Future<void> startDiscovery({
    required String localUserName,
    required void Function(String endpointId, String endpointName) onFound,
    void Function(String endpointId)? onLost,
  }) async {
    await _nearby.startDiscovery(
      localUserName,
      Strategy.P2P_CLUSTER,
      onEndpointFound: (id, name, _) {
        _discovered[id] = name;
        onFound(id, name);
      },
      onEndpointLost: (id) {
        if (id == null) {
          return;
        }
        _discovered.remove(id);
        onLost?.call(id);
      },
      serviceId: 'com.pairnest.app.nearby',
    );
  }

  Future<void> stopDiscovery() => _nearby.stopDiscovery();

  Future<void> startAdvertising({
    required String localUserName,
    required void Function(String endpointId, String endpointName)
    onConnectionInitiated,
    required void Function(String endpointId) onConnected,
    required void Function(String endpointId) onDisconnected,
    required OnBytesMessage onBytesMessage,
    required OnFileReceived onFileReceived,
  }) async {
    _onBytesMessage = onBytesMessage;
    _onFileReceived = onFileReceived;
    await _nearby.startAdvertising(
      localUserName,
      Strategy.P2P_CLUSTER,
      onConnectionInitiated: (id, info) {
        onConnectionInitiated(id, info.endpointName);
        _nearby.acceptConnection(
          id,
          onPayLoadRecieved: _onPayloadReceived,
          onPayloadTransferUpdate: (_, _) {},
        );
      },
      onConnectionResult: (id, status) {
        if (status == Status.CONNECTED) {
          onConnected(id);
        }
      },
      onDisconnected: onDisconnected,
      serviceId: 'com.pairnest.app.nearby',
    );
  }

  Future<void> stopAdvertising() => _nearby.stopAdvertising();

  Future<void> requestConnection({
    required String localUserName,
    required String endpointId,
    required void Function(String endpointId) onConnected,
    required OnBytesMessage onBytesMessage,
    required OnFileReceived onFileReceived,
  }) async {
    _onBytesMessage = onBytesMessage;
    _onFileReceived = onFileReceived;
    await _nearby.requestConnection(
      localUserName,
      endpointId,
      onConnectionInitiated: (id, _) {
        _nearby.acceptConnection(
          id,
          onPayLoadRecieved: _onPayloadReceived,
          onPayloadTransferUpdate: (_, _) {},
        );
      },
      onConnectionResult: (id, status) {
        if (status == Status.CONNECTED) {
          onConnected(id);
        }
      },
      onDisconnected: (_) {},
    );
  }

  Future<void> sendEvents(String endpointId, List<PairEvent> events) async {
    final data = events
        .map(
          (e) => {
            'eventId': e.eventId,
            'pairId': e.pairId,
            'deviceId': e.deviceId,
            'type': e.type.value,
            'payload': e.payload,
            'createdAt': e.createdAt.toIso8601String(),
          },
        )
        .toList();

    await _nearby.sendBytesPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(jsonEncode(data))),
    );
  }

  Future<void> sendJson(String endpointId, Map<String, dynamic> payload) async {
    await _nearby.sendBytesPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(jsonEncode(payload))),
    );
  }

  Future<void> sendFile(
    String endpointId,
    OutboundFileTransfer transfer,
  ) async {
    final payloadId = await _nearby.sendFilePayload(
      endpointId,
      transfer.sourcePath,
    );
    await sendJson(endpointId, {
      'kind': 'file_meta',
      'payloadId': payloadId,
      'filename': transfer.filename,
      'imageEventId': transfer.imageEventId,
    });
  }

  Future<String?> moveInboundFile({
    required String sourceUri,
    required String filename,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(docs.path, 'timeline_media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    final target = p.join(mediaDir.path, filename);
    final ok = await _nearby.copyFileAndDeleteOriginal(sourceUri, target);
    return ok ? target : null;
  }

  Future<void> _onPayloadReceived(String endpointId, Payload payload) async {
    if (payload.type == PayloadType.FILE && payload.uri != null) {
      await _onFileReceived?.call(
        endpointId,
        InboundFileTransfer(payloadId: payload.id, uri: payload.uri!),
      );
      return;
    }

    if (payload.type != PayloadType.BYTES || payload.bytes == null) {
      return;
    }
    try {
      final text = utf8.decode(payload.bytes!);
      final map = jsonDecode(text) as Map<String, dynamic>;
      await _onBytesMessage?.call(endpointId, map);
    } catch (_) {
      // ignore invalid payload
    }
  }

  Future<void> disconnect(String endpointId) =>
      _nearby.disconnectFromEndpoint(endpointId);

  Future<void> dispose() async {
    await _nearby.stopAllEndpoints();
    await _nearby.stopDiscovery();
    await _nearby.stopAdvertising();
  }
}
