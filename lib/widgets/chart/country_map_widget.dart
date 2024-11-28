import 'dart:convert';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
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
  Map<String, MapLatLng>? _coordinates;
  List<MapMarker> _markers = [];

  final MapZoomPanBehavior _zoomPanBehavior = MapZoomPanBehavior(
    enableMouseWheelZooming: true,
    zoomLevel: 3,
    minZoomLevel: 1,
    maxZoomLevel: 10,
    focalLatLng: const MapLatLng(0, 0),
  );

  double _getFlagSize(double zoomLevel) {
    return 15 + (zoomLevel * 5);
  }

  @override
  void didUpdateWidget(CountryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryCodes != widget.countryCodes) {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    if (_coordinates == null) return;

    setState(() {
      _markers = widget.countryCodes.map((code) {
        final replacedCode = CommonUtils.instance.replaceCountryCode(code);
        final coordinates = _getCountryCoordinates(replacedCode);
        if (coordinates == null) {
          return const MapMarker(
            latitude: 0,
            longitude: 0,
            child: SizedBox.shrink(),
          );
        }
        return MapMarker(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          child: CountryFlag.fromCountryCode(
            replacedCode,
            height: _getFlagSize(_zoomPanBehavior.zoomLevel),
            width: _getFlagSize(_zoomPanBehavior.zoomLevel),
          ),
        );
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCoordinates().then((_) {
      _updateMarkers();
    });
  }

  Future<void> _loadCoordinates() async {
    final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/country_coordinates.json');
    final data = json.decode(jsonString);

    setState(() {
      _coordinates = Map.fromEntries(
        (data['countries'] as List).map((country) => MapEntry(
              country['country_code'] as String,
              MapLatLng(
                country['coordinates']['latitude'] as double,
                country['coordinates']['longitude'] as double,
              ),
            )),
      );
    });
  }

  MapLatLng? _getCountryCoordinates(String countryCode) {
    return _coordinates?[CommonUtils.instance.replaceCountryCode(countryCode)];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 300,
      width: widget.width ?? double.infinity,
      child: SfMaps(
        layers: [
          MapShapeLayer(
            source: MapShapeSource.asset(
              'assets/world_map_iso.json',
              shapeDataField: 'name',
              dataCount: widget.countryCodes.length,
              primaryValueMapper: (int index) => CommonUtils.instance.replaceCountryCode(widget.countryCodes[index]),
              shapeColorValueMapper: (int index) => CommonUtils.instance.replaceCountryCode(widget.countryCodes[index]),
              shapeColorMappers: widget.countryCodes
                  .map((code) => MapColorMapper(
                        value: CommonUtils.instance.replaceCountryCode(code),
                        color: Colors.blue.withOpacity(0.3),
                      ))
                  .toList(),
            ),
            showDataLabels: false,
            zoomPanBehavior: _zoomPanBehavior,
            strokeColor: Colors.grey[300],
            color: Colors.grey[100],
            initialMarkersCount: 10,
            markerBuilder: (BuildContext context, int index) {
              final coordinates = _getCountryCoordinates(widget.countryCodes[index]);
              if (coordinates == null) {
                return const MapMarker(
                  latitude: 0,
                  longitude: 0,
                  child: SizedBox.shrink(),
                );
              }
              return MapMarker(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude,
                child: CountryFlag.fromCountryCode(
                  CommonUtils.instance.replaceCountryCode(widget.countryCodes[index]),
                  height: _getFlagSize(_zoomPanBehavior.zoomLevel),
                  width: _getFlagSize(_zoomPanBehavior.zoomLevel),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
