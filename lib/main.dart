import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const DalliniApp());
}

class DalliniApp extends StatelessWidget {
  const DalliniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dallini',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const CameraPosition _ramadi = CameraPosition(
    target: LatLng(33.425, 43.300),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dallini - خريطة الرمادي')),
      body: const GoogleMap(
        initialCameraPosition: _ramadi,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
