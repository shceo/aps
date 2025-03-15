import 'package:aps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MainContent extends StatelessWidget {
  final AppLocalizations loc;

  const MainContent({Key? key, required this.loc}) : super(key: key);

  Widget _buildFlightInfoBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _infoChip(loc.flights),
          _infoChip("EDDF → LSGG"),
          _infoChip(loc.flight_plan),
          _infoChip("Airbus A330-600"),
        ],
      ),
    );
  }

  Widget _infoChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blueGrey[50],
    );
  }

  Widget _buildPlaneLayout() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        loc.plane_layout,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPayloadInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.payload_info,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _payloadItem("FLB-001", "2500 kg"),
          _payloadItem("FLB-002", "3200 kg"),
          _payloadItem("FLB-003", "1800 kg"),
          _payloadItem("FLB-004", "4000 kg"),
        ],
      ),
    );
  }

  Widget _payloadItem(String id, String weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(id)),
          Text(weight),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFlightInfoBar(),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPlaneLayout()),
                    const SizedBox(width: 16),
                    SizedBox(width: 300, child: _buildPayloadInfo()),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPlaneLayout(),
                    const SizedBox(height: 16),
                    _buildPayloadInfo(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
