import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'api_key.dart'; // Pastikan ini mengarah ke file API Key Anda

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(-6.200000, 106.816666); // Default: Jakarta
  bool _loadingLocation = true;

  // Mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
      });

      // Memindahkan kamera ke lokasi terkini
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    } catch (e) {
      setState(() {
        _loadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal mendapatkan lokasi: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 14.0,
          ),
          mapType: MapType.normal,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          myLocationEnabled: true, // Menampilkan lokasi pengguna
          myLocationButtonEnabled: true,
        ),
        if (_loadingLocation)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
