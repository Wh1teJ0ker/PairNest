class OutboundFileTransfer {
  OutboundFileTransfer({
    required this.sourcePath,
    required this.filename,
    required this.imageEventId,
  });

  final String sourcePath;
  final String filename;
  final String imageEventId;
}

class InboundFileTransfer {
  InboundFileTransfer({required this.payloadId, required this.uri});

  final int payloadId;
  final String uri;
}

class SyncMergeReport {
  const SyncMergeReport({
    required this.insertedEvents,
    required this.duplicateEvents,
    required this.filteredPairMismatchEvents,
    required this.crossDeviceNoteDays,
  });

  final int insertedEvents;
  final int duplicateEvents;
  final int filteredPairMismatchEvents;
  final int crossDeviceNoteDays;
}
