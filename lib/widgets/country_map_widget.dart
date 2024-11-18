import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class CountryMapWidget extends StatefulWidget {
  final List<String> countryCodes;
  final double? height;
  final double? width;

  const CountryMapWidget({
    super.key,
    required this.countryCodes,
    this.height,
    this.width,
  });

  @override
  State<CountryMapWidget> createState() => _CountryMapWidgetState();
}

class _CountryMapWidgetState extends State<CountryMapWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 300,
      width: widget.width ?? double.infinity,
      child: SfMaps(
        layers: [
          MapShapeLayer(
            source: const MapShapeSource.asset(
              'assets/world_map.json',
              shapeDataField: 'name',
            ),
            showDataLabels: false,
            zoomPanBehavior: MapZoomPanBehavior(
              zoomLevel: 3,
              focalLatLng: const MapLatLng(0, 0),
            ),
            strokeColor: Colors.grey[300],
            color: Colors.grey[100],
          ),
        ],
      ),
    );
  }
}
