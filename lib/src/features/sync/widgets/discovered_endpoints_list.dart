import 'package:flutter/material.dart';

import '../../../widgets/pressable_scale.dart';

class DiscoveredEndpointsList extends StatelessWidget {
  const DiscoveredEndpointsList({
    super.key,
    required this.endpoints,
    required this.selectedEndpointId,
    required this.onSelect,
  });

  final List<String> endpoints;
  final String? selectedEndpointId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (endpoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Row(
          children: [
            Icon(Icons.devices_rounded, size: 16),
            SizedBox(width: 6),
            Text('发现设备:'),
          ],
        ),
        ...endpoints.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: PressableScale(
              onTap: () => onSelect(endpointIdFromDisplay(item)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      selectedEndpointId != null &&
                          item.contains(selectedEndpointId!)
                      ? const Color(0xFFEAF3FB)
                      : const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD8E6F3)),
                ),
                child: Text(
                  '• $item${selectedEndpointId != null && item.contains(selectedEndpointId!) ? '（已选择）' : ''}',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String endpointIdFromDisplay(String displayText) {
    final start = displayText.lastIndexOf('(');
    final end = displayText.lastIndexOf(')');
    if (start < 0 || end <= start) {
      return displayText;
    }
    return displayText.substring(start + 1, end);
  }
}
