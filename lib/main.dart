import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

const kBg = Color(0xFF0E2E2B);
const kTeal = Color(0xFF7ED8C0);

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashPage(),
  ));
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IraqMapPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('دّليني',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.bold)),
            Text('للعراق كله',
                style: TextStyle(color: kTeal, fontSize: 16)),
            SizedBox(height: 70),
            Icon(Icons.directions_car, size: 120, color: kTeal),
          ],
        ),
      ),
    );
  }
}

class Hazard {
  final LatLng p;
  final String type;
  final String city;
  Hazard(this.p, this.type, this.city);
}

final List<Hazard> iraqHazards = [
  Hazard(const LatLng(33.3152, 44.3661), 'camera', 'بغداد'),
  Hazard(const LatLng(33.30, 44.38), 'traffic', 'بغداد التحرير'),
  Hazard(const LatLng(33.43, 43.29), 'camera', 'الفلوجة'),
  Hazard(const LatLng(33.42, 43.30), 'police', 'الرمادي'),
  Hazard(const LatLng(30.50, 47.81), 'camera', 'البصرة'),
  Hazard(const LatLng(36.34, 43.13), 'camera', 'الموصل'),
  Hazard(const LatLng(36.19, 44.00), 'camera', 'اربيل'),
  Hazard(const LatLng(35.46, 44.39), 'traffic', 'كركوك'),
];

final Map<String, LatLng> iraqCities = {
  'بغداد': const LatLng(33.3152, 44.3661),
  'البصرة': const LatLng(30.50, 47.81),
  'الموصل': const LatLng(36.34, 43.13),
  'اربيل': const LatLng(36.19, 44.00),
  'الفلوجة': const LatLng(33.35, 43.78),
  'الرمادي': const LatLng(33.42, 43.30),
  'كركوك': const LatLng(35.46, 44.39),
  'سليمانية': const LatLng(35.56, 45.43),
  'دهوك': const LatLng(36.86, 42.99),
  'زاخو': const LatLng(37.14, 42.68),
};

class IraqMapPage extends StatefulWidget {
  const IraqMapPage({super.key});
  @override
  State<IraqMapPage> createState() => _IraqMapState();
}

class _IraqMapState extends State<IraqMapPage> {
  final MapController mapCtrl = MapController();
  LatLng current = const LatLng(33.3152, 44.3661);
  LatLng dest = const LatLng(33.35, 43.78);
  List<LatLng> route = [];
  String timeText = "اختر مدينة";
  String distText = "العراق كله";
  String selectedCity = "الفلوجة";

  @override
  void initState() {
    super.initState();
    getLoc();
  }

  Future<void> getLoc() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      var pos = await Geolocator.getCurrentPosition();
      setState(() {
        current = LatLng(pos.latitude, pos.longitude);
      });
      mapCtrl.move(current, 10);
    } catch (_) {}
    getRoute();
  }

  Future<void> getRoute() async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${current.longitude},${current.latitude};${dest.longitude},${dest.latitude}?overview=full&geometries=geojson';
    try {
      var res = await http.get(Uri.parse(url));
      var data = json.decode(res.body);
      var coords = data['routes'][0]['geometry']['coordinates'] as List;
      var dist = data['routes'][0]['distance'] as num;
      var dur = data['routes'][0]['duration'] as num;
      setState(() {
        route = coords
            .map((c) =>
                LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList();
        timeText =
            "${(dur / 3600).toInt()} س ${(dur % 3600 / 60).toInt()} د";
        distText = "${(dist / 1000).toInt()} كلم";
      });
    } catch (_) {
      setState(() {
        route = [current, dest];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBg,
        title: const Text('دّليني - العراق كله',
            style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapCtrl,
            options: MapOptions(
              initialCenter: const LatLng(33.0, 44.0),
              initialZoom: 6,
              onLongPress: (a, b) {
                setState(() => dest = b);
                getRoute();
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.dallini.iraq',
              ),
              if (route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                        points: route,
                        color: const Color(0xFF7C1CD1),
                        strokeWidth: 6),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                      point: current,
                      width: 50,
                      height: 50,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: kTeal, width: 3)),
                          child: const Icon(Icons.circle,
                              color: Colors.blue, size: 16))),
                  ...iraqHazards.map((h) => Marker(
                      point: h.p,
                      width: 36,
                      height: 36,
                      child: Container(
                          decoration: BoxDecoration(
                              color: h.type == 'camera'
                                  ? Colors.red
                                  : h.type == 'traffic'
                                      ? Colors.orange
                                      : Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2)),
                          child: Icon(
                              h.type == 'camera'
                                  ? Icons.videocam
                                  : h.type == 'traffic'
                                      ? Icons.traffic
                                      : Icons.local_police,
                              color: Colors.white,
                              size: 14)))),
                  Marker(
                      point: dest,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 44)),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCity,
                  isExpanded: true,
                  items: iraqCities.keys
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        selectedCity = v;
                        dest = iraqCities[v]!;
                      });
                      mapCtrl.move(dest, 10);
                      getRoute();
                    }
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(22))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("الى $selectedCity - $timeText",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(distText),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => NavIraqPage(
                                    start: current,
                                    end: dest,
                                    route: route)));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kBg,
                          foregroundColor: kTeal,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text('انطلق الى $selectedCity - GO'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavIraqPage extends StatefulWidget {
  final LatLng start;
  final LatLng end;
  final List<LatLng> route;
  const NavIraqPage(
      {super.key, required this.start, required this.end, required this.route});
  @override
  State<NavIraqPage> createState() => _NavIraqState();
}

class _NavIraqState extends State<NavIraqPage> {
  final MapController mapCtrl = MapController();
  final FlutterTts tts = FlutterTts();
  late LatLng pos;
  double bearing = 0;
  double speed = 0;
  StreamSubscription<Position>? sub;
  String alertText = "";
  bool showAlert = false;

  @override
  void initState() {
    super.initState();
    pos = widget.start;
    initTts();
    startNav();
  }

  Future<void> initTts() async {
    await tts.setLanguage("ar");
    await tts.setSpeechRate(0.5);
  }

  void startNav() {
    sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 5),
    ).listen((p) {
      setState(() {
        pos = LatLng(p.latitude, p.longitude);
        bearing = p.heading;
        speed = p.speed * 3.6;
      });
      mapCtrl.move(pos, 17);
      checkHazards();
    });
  }

  void checkHazards() {
    for (var h in iraqHazards) {
      double d = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, h.p.latitude, h.p.longitude);
      if (d < 600) {
        setState(() {
          showAlert = true;
          alertText = "${h.city} بعد ${d.toInt()} م";
        });
        tts.speak(alertText);
        Future.delayed(const Duration(seconds: 6), () {
          if (mounted) setState(() => showAlert = false);
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapCtrl,
            options: MapOptions(initialCenter: pos, initialZoom: 17),
            children: [
              TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.dallini.iraq'),
              PolylineLayer(polylines: [
                Polyline(
                    points: widget.route,
                    color: const Color(0xFF7C1CD1),
                    strokeWidth: 7)
              ]),
              MarkerLayer(markers: [
                Marker(
                    point: pos,
                    width: 50,
                    height: 50,
                    child: Transform.rotate(
                        angle: bearing * math.pi / 180,
                        child: const Icon(Icons.navigation,
                            color: kTeal, size: 44)))
              ]),
            ],
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.turn_left,
                          color: Colors.white, size: 30),
                      const SizedBox(width: 10),
                      Text("${speed.toInt()} كم/س",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white)),
                    ],
                  ),
                ),
                if (showAlert)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(14)),
                    child: Text(alertText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
