import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../../domain/models.dart';

class NearbySyncService {
  NearbySyncService() : _nearby = Nearby();

  final Nearby _nearby;
  final Map<String, String> _discovered = <String, String>{};

  Future<void> startDiscovery({
    required String localUserName,
    required void Function(String endpointId, String endpointName) onFound,
  }) async {
    await _nearby.startDiscovery(
      localUserName,
      Strategy.P2P_CLUSTER,
      onEndpointFound: (id, name, _) {
        _discovered[id] = name;
        onFound(id, name);
      },
      onEndpointLost: (id) {
        _discovered.remove(id);
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
  }) async {
    await _nearby.startAdvertising(
      localUserName,
      Strategy.P2P_CLUSTER,
      onConnectionInitiated: (id, info) {
        onConnectionInitiated(id, info.endpointName);
        _nearby.acceptConnection(
          id,
          onPayLoadRecieved: (_, _) {},
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
  }) async {
    await _nearby.requestConnection(
      localUserName,
      endpointId,
      onConnectionInitiated: (id, _) {
        _nearby.acceptConnection(
          id,
          onPayLoadRecieved: (_, _) {},
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

  Future<void> disconnect(String endpointId) =>
      _nearby.disconnectFromEndpoint(endpointId);

  Future<void> dispose() async {
    await _nearby.stopAllEndpoints();
    await _nearby.stopDiscovery();
    await _nearby.stopAdvertising();
  }
}
