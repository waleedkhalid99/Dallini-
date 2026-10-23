import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DalliniApp());
}

class DalliniApp extends StatelessWidget {
  const DalliniApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dallini - العراق',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const IraqMapScreen(),
    );
  }
}

class IraqCity {
  final String name;
  final LatLng latLng;
  IraqCity(this.name, this.latLng);
}

class IraqMapScreen extends StatefulWidget {
  const IraqMapScreen({super.key});
  @override
  State<IraqMapScreen> createState() => _IraqMapScreenState();
}

class _IraqMapScreenState extends State<IraqMapScreen> {
  final MapController _mapController = MapController();

  // مركز العراق
  static const LatLng iraqCenter = LatLng(33.2232, 43.6793);

  final List<IraqCity> cities = [
    IraqCity('بغداد', LatLng(33.3152, 44.3661)),
    IraqCity('الرمادي', LatLng(33.425, 43.300)),
    IraqCity('الفلوجة', LatLng(33.3500, 43.7800)),
    IraqCity('البصرة', LatLng(30.5085, 47.7804)),
    IraqCity('الموصل', LatLng(36.3400, 43.1300)),
    IraqCity('أربيل', LatLng(36.1900, 44.0100)),
    IraqCity('كركوك', LatLng(35.4687, 44.3922)),
    IraqCity('النجف', LatLng(32.0000, 44.3300)),
    IraqCity('كربلاء', LatLng(32.6160, 44.0240)),
    IraqCity('الناصرية', LatLng(31.0579, 46.2570)),
    IraqCity('العمارة', LatLng(31.8348, 47.1417)),
    IraqCity('السماوة', LatLng(31.3120, 45.2800)),
    IraqCity('الكوت', LatLng(32.5120, 45.8210)),
    IraqCity('بعقوبة', LatLng(33.7500, 44.6500)),
    IraqCity('الحلة', LatLng(32.4900, 44.4200)),
    IraqCity('تكريت', LatLng(34.6000, 43.6800)),
    IraqCity('الديوانية', LatLng(31.9923, 44.9333)),
    IraqCity('زاخو', LatLng(37.1455, 42.6861)),
    IraqCity('الفاو', LatLng(29.9770, 48.4726)),
  ];

  void _goToCity(IraqCity city) {
    _mapController.move(city.latLng, 12);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dallini - خريطة العراق'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade700),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.map, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text('مدن العراق', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('اختار مدينة للانتقال', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ...cities.map((city) => ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(city.name),
                  onTap: () {
                    Navigator.pop(context);
                    _goToCity(city);
                  },
                )),
          ],
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: iraqCenter,
          initialZoom: 6.2,
          minZoom: 5,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.dallini.app',
          ),
          MarkerLayer(
            markers: cities.map((city) {
              return Marker(
                point: city.latLng,
                width: 100,
                height: 60,
                child: Column(
                  children: [
                    const Icon(Icons.location_pin, color: Colors.red, size: 35),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                      ),
                      child: Text(city.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mapController.move(iraqCenter, 6.2),
        label: const Text('العراق كله'),
        icon: const Icon(Icons.home),
      ),
    );
  }
}
