import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const double mapW = 1450;
const double mapH = 900;
const double anchorMarkerRadius = 15; // 30 pt diameter for UWB anchor circles.
const double patientDestinationMarkerRadius = 15; // Same 30 pt diameter as anchors.
const String apiBase = 'http://10.0.2.2:5000';

const Map<String, Rect> rooms = {
  'CAFETERIA': Rect.fromLTWH(0, 0, 313, 120),
  'STAFF ROOM': Rect.fromLTWH(313, 0, 291, 120),
  'OPD': Rect.fromLTWH(604, 0, 336, 120),
  'CARDIOLOGY': Rect.fromLTWH(940, 0, 260, 120),
  'ICU': Rect.fromLTWH(1200, 0, 250, 120),
  'LABORATORY': Rect.fromLTWH(0, 190, 220, 110),
  'MRI': Rect.fromLTWH(300, 190, 140, 130),
  'OPERATION THEATRE': Rect.fromLTWH(440, 190, 120, 130),
  'ORTHOPEDICS': Rect.fromLTWH(640, 190, 190, 270),
  'GENERAL WARD': Rect.fromLTWH(980, 190, 350, 140),
  'RADIOLOGY': Rect.fromLTWH(0, 300, 220, 120),
  'BLOOD BANK': Rect.fromLTWH(0, 420, 220, 120),
  'WAITING AREA': Rect.fromLTWH(300, 320, 260, 140),
  'NURSE STATION': Rect.fromLTWH(980, 330, 210, 130),
  'MEDICAL RECORDS': Rect.fromLTWH(1190, 330, 140, 130),
  'CONSULTATION': Rect.fromLTWH(0, 540, 220, 110),
  'ISOLATION': Rect.fromLTWH(300, 510, 160, 140),
  'STORE ROOM': Rect.fromLTWH(460, 510, 100, 140),
  'LIFT': Rect.fromLTWH(640, 510, 95, 140),
  'STAIRS': Rect.fromLTWH(735, 510, 95, 140),
  'ULTRASOUND ROOM': Rect.fromLTWH(979, 510, 210, 140),
  'BLOOD TEST': Rect.fromLTWH(1190, 510, 140, 140),
  'XRAY ROOM': Rect.fromLTWH(0, 780, 200, 120),
  'PHARMACY': Rect.fromLTWH(200, 780, 280, 120),
  'RECEPTION': Rect.fromLTWH(481, 780, 110, 120),
  'EMERGENCY': Rect.fromLTWH(920, 780, 280, 120),
  'CT SCAN': Rect.fromLTWH(1200, 780, 250, 120),
};

const Map<String, Offset> doors = {
  'E1': Offset(97, 94),
  'E2': Offset(357, 95),
  'E3': Offset(853, 94),
  'E4': Offset(1138, 94),
  'E5': Offset(1396, 94),
  'E6': Offset(195, 217),
  'E7': Offset(357, 190),
  'E8': Offset(487, 190),
  'E9': Offset(804, 351),
  'E10': Offset(1138, 190),
  'E11': Offset(195, 326),
  'E12': Offset(195, 473),
  'E13': Offset(405, 435),
  'E14': Offset(980, 351),
  'E15': Offset(1301, 382),
  'E16': Offset(196, 572),
  'E17': Offset(367, 622),
  'E18': Offset(496, 625),
  'E19': Offset(670, 622),
  'E20': Offset(776, 625),
  'E21': Offset(1057, 625),
  'E22': Offset(1265, 622),
  'E23': Offset(96, 781),
  'E24': Offset(367, 781),
  'E25': Offset(1057, 781),
  'E26': Offset(1265, 780),
  'E27': Offset(566, 802),
  'E28': Offset(776, 875),
};

const Map<String, Offset> nodes = {
  'N1': Offset(97, 142),
  'N2': Offset(248, 142),
  'N3': Offset(357, 142),
  'N4': Offset(487, 142),
  'N5': Offset(593, 142),
  'N6': Offset(853, 142),
  'N7': Offset(1138, 142),
  'N8': Offset(1396, 142),
  'N9': Offset(248, 217),
  'N10': Offset(248, 326),
  'N11': Offset(853, 351),
  'N12': Offset(1396, 382),
  'N13': Offset(248, 473),
  'N14': Offset(405, 473),
  'N15': Offset(593, 473),
  'N16': Offset(853, 473),
  'N17': Offset(1396, 473),
  'N18': Offset(248, 572),
  'N19': Offset(248, 703),
  'N20': Offset(367, 703),
  'N21': Offset(496, 703),
  'N22': Offset(593, 703),
  'N23': Offset(670, 703),
  'N24': Offset(776, 703),
  'N25': Offset(853, 703),
  'N26': Offset(1057, 703),
  'N27': Offset(1265, 703),
  'N28': Offset(1396, 703),
  'N29': Offset(776, 802),
};

const Map<String, Offset> anchors = {
  'A1': Offset(185, 140),
  'A2': Offset(640, 140),
  'A3': Offset(1220, 140),
  'A4': Offset(260, 383),
  'A5': Offset(930, 530),
  'A6': Offset(1340, 510),
  'A7': Offset(150, 673),
  'A8': Offset(610, 751),
  'A9': Offset(1159, 740),
};

const List<List<String>> edges = [
  ['N1', 'N2'],
  ['N2', 'N3'],
  ['N3', 'N4'],
  ['N4', 'N5'],
  ['N5', 'N6'],
  ['N6', 'N7'],
  ['N7', 'N8'],
  ['N2', 'N9'],
  ['N9', 'N10'],
  ['N10', 'N13'],
  ['N13', 'N18'],
  ['N18', 'N19'],
  ['N13', 'N14'],
  ['N14', 'N15'],
  ['N15', 'N16'],
  ['N16', 'N17'],
  ['N5', 'N15'],
  ['N6', 'N11'],
  ['N11', 'N16'],
  ['N8', 'N12'],
  ['N12', 'N17'],
  ['N17', 'N28'],
  ['N19', 'N20'],
  ['N20', 'N21'],
  ['N21', 'N22'],
  ['N22', 'N23'],
  ['N23', 'N24'],
  ['N24', 'N25'],
  ['N25', 'N26'],
  ['N26', 'N27'],
  ['N27', 'N28'],
  ['N15', 'N22'],
  ['N16', 'N25'],
  ['N24', 'N29'],
  ['E1', 'N1'],
  ['E2', 'N3'],
  ['E3', 'N6'],
  ['E4', 'N7'],
  ['E5', 'N8'],
  ['E6', 'N9'],
  ['E7', 'N3'],
  ['E8', 'N4'],
  ['E9', 'N11'],
  ['E10', 'N7'],
  ['E11', 'N10'],
  ['E12', 'N13'],
  ['E13', 'N14'],
  ['E14', 'N11'],
  ['E15', 'N12'],
  ['E16', 'N18'],
  ['E17', 'N20'],
  ['E18', 'N21'],
  ['E19', 'N23'],
  ['E20', 'N24'],
  ['E21', 'N26'],
  ['E22', 'N27'],
  ['E23', 'N19'],
  ['E24', 'N20'],
  ['E25', 'N26'],
  ['E26', 'N27'],
  ['E27', 'N29'],
  ['E28', 'N29'],
];

const Map<String, String> roomDoors = {
  'CAFETERIA': 'E1',
  'STAFF ROOM': 'E2',
  'OPD': 'E3',
  'CARDIOLOGY': 'E4',
  'ICU': 'E5',
  'LABORATORY': 'E6',
  'MRI': 'E7',
  'OPERATION THEATRE': 'E8',
  'ORTHOPEDICS': 'E9',
  'GENERAL WARD': 'E10',
  'RADIOLOGY': 'E11',
  'BLOOD BANK': 'E12',
  'WAITING AREA': 'E13',
  'NURSE STATION': 'E14',
  'MEDICAL RECORDS': 'E15',
  'CONSULTATION': 'E16',
  'ISOLATION': 'E17',
  'STORE ROOM': 'E18',
  'LIFT': 'E19',
  'STAIRS': 'E20',
  'ULTRASOUND ROOM': 'E21',
  'BLOOD TEST': 'E22',
  'XRAY ROOM': 'E23',
  'PHARMACY': 'E24',
  'EMERGENCY': 'E25',
  'CT SCAN': 'E26',
  'RECEPTION': 'E27',
};

void main() => runApp(const HospitalNavigationApp());

class HospitalNavigationApp extends StatelessWidget {
  const HospitalNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UWB Hospital Navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF008F83),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
      ),
      home: const NavigationHome(),
    );
  }
}

class NavigationHome extends StatefulWidget {
  const NavigationHome({super.key});

  @override
  State<NavigationHome> createState() => _NavigationHomeState();
}

class _NavigationHomeState extends State<NavigationHome>
    with SingleTickerProviderStateMixin {
  String start = 'N1';
  String destination = 'OPD';

  List<String> route = [];
  double? distance;
  String status = 'Ready to navigate';

  bool loading = false;
  bool showMap = false;
  bool _isPatientPositionPage = false;
  bool _isDestinationPage = false;
  bool _mapWasInitialized = false;
  bool _viewOnlyMap = false;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController patientSearchController = TextEditingController();
  final TransformationController _mapController = TransformationController();
  Size? _mapViewportSize;

  late final AnimationController _patientAnimationController;

  @override
  void initState() {
    super.initState();

    // The patient takes approximately 15 seconds to reach the destination.
    _patientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addListener(_followPatientOnNavigationMap);
  }

  @override
  void dispose() {
    _patientAnimationController.dispose();
    searchController.dispose();
    patientSearchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String _doorForRoom(String room) => roomDoors[room] ?? 'N/A';

  // GPS-style camera tracking: keep the moving patient near the centre of
  // the Start Navigation viewport while preserving the user's current zoom.
  void _followPatientOnNavigationMap() {
    if (!mounted || !showMap || _viewOnlyMap || !_mapWasInitialized) return;
    final viewport = _mapViewportSize;
    if (viewport == null || viewport.isEmpty || route.isEmpty) return;

    final painter = HospitalMapPainter(
      route: route,
      patientProgress: _patientAnimationController.value,
      destinationDoor: _doorForRoom(destination),
      showNavigationMarkers: route.isNotEmpty,
    );
    final patient = painter.patientPosition();
    if (patient == Offset.zero) return;

    final matrix = _mapController.value.clone();
    final scale = matrix.getMaxScaleOnAxis().clamp(0.5, 5.0).toDouble();
    matrix.setEntry(0, 3, viewport.width / 2 - patient.dx * scale);
    matrix.setEntry(1, 3, viewport.height / 2 - patient.dy * scale);
    _mapController.value = matrix;
  }

  Future<void> testBackend() async {
    try {
      final response = await http
          .get(Uri.parse('$apiBase/api/health'))
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode < 500
                ? 'Backend connection successful'
                : 'Backend responded with an error',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot connect. Start Flask app.py on your computer.',
          ),
        ),
      );
    }
  }

  Future<void> findRoute() async {
    setState(() {
      loading = true;
      status = 'Calculating shortest route...';
    });

    // Stop any previous animation before requesting another route.
    _patientAnimationController.stop();
    _patientAnimationController.value = 0;

    try {
      final uri = Uri.parse('$apiBase/api/route').replace(
        queryParameters: {
          'start': start,
          'destination': destination,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final newRoute = List<String>.from(data['path'] ?? []);

        setState(() {
          route = newRoute;
          distance = (data['distance'] as num?)?.toDouble();

          status = route.isEmpty
              ? 'No route found. Please choose another destination.'
              : 'Shortest route: ${route.join(' → ')}';

          _mapWasInitialized = false;
          _viewOnlyMap = false;
          showMap = true;
        });

        if (newRoute.isNotEmpty) {
          _patientAnimationController.forward(from: 0);
        } else {
          _patientAnimationController.stop();
        }
      } else {
        setState(() {
          route = [];
          distance = null;
          status = data['error']?.toString() ?? 'Route request failed.';
        });
      }
    } catch (_) {
      setState(() {
        route = [];
        distance = null;
        status =
            'Cannot connect to Flask API. Start app.py and check the API address.';
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = rooms.keys
        .where(
          (s) => s.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UWB Hospital Navigation'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F8F6),
      ),
      body: SafeArea(
        child: showMap
            ? _mapPage()
            : _isDestinationPage
                ? _destinationPage(filtered)
                : _isPatientPositionPage
                    ? _patientPositionPage()
                    : _homePage(),
      ),
    );
  }

  Widget _homePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF009688),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 43,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Smart Hospital\nIndoor Navigation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Simulated UWB positioning • Trilateration • A* Pathfinding',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            _outlinedButton(
              Icons.cloud_done,
              'Test Backend Connection',
              testBackend,
              pale: true,
            ),
            const SizedBox(height: 14),
            _outlinedButton(
              Icons.place,
              'Destination: $destination',
              () {
                setState(() {
                  _isDestinationPage = true;
                  _isPatientPositionPage = false;
                });
              },
            ),
            const SizedBox(height: 14),
            _outlinedButton(
              Icons.person_pin_circle,
              'Patient Position: $start',
              () {
                setState(() {
                  _isPatientPositionPage = true;
                  _isDestinationPage = false;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  foregroundColor: Colors.white,
                ),
                onPressed: loading ? null : findRoute,
                icon: const Icon(Icons.alt_route),
                label: const Text(
                  'Start Navigation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _outlinedButton(
              Icons.map,
              'View Hospital Map',
              () {
                _patientAnimationController.stop();
                setState(() {
                  route = [];
                  distance = null;
                  status = 'Hospital map';
                  _mapWasInitialized = false;
                  _viewOnlyMap = true;
                  showMap = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlinedButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool pale = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF00796B),
          backgroundColor: pale ? const Color(0xFFEAF5F1) : Colors.transparent,
          side: BorderSide(color: Colors.blueGrey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 19),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _destinationPage(List<String> filtered) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _isDestinationPage = false);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(
                child: Text(
                  'Choose Destination',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search destination (e.g. OPD, ICU, MRI)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Hospital destinations',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${filtered.length} items',
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final item = filtered[i];
              final door = _doorForRoom(item);

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD9F2EC),
                  child: Icon(
                    Icons.meeting_room,
                    color: Color(0xFF00796B),
                  ),
                ),
                title: Text(
                  item,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Destination room • Door $door'),
                trailing: destination == item
                    ? const Icon(Icons.check_circle, color: Colors.teal)
                    : null,
                onTap: () {
                  setState(() {
                    destination = item;
                    _isDestinationPage = false;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _patientPositionPage() {
    final query = patientSearchController.text.trim().toLowerCase();
    final filteredNodes = nodes.keys
        .where((id) => id.toLowerCase().contains(query))
        .toList();
    final filteredDoors = doors.keys
        .where((id) => id.toLowerCase().contains(query))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _isPatientPositionPage = false);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(
                child: Text(
                  'Select Patient Position',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: TextField(
            controller: patientSearchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search node or door (e.g. N12, E5)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: patientSearchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        patientSearchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(
            'Search or select a walkable navigation node or door node. '
            'The selected ID will appear on the home page.',
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Walkable Nodes (N1–N29)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...filteredNodes.map(
                (id) => ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.circle,
                    color: Color(0xFF008F83),
                    size: 15,
                  ),
                  title: Text(id),
                  subtitle: Text(
                    'Map position (${nodes[id]!.dx.toInt()}, '
                    '${nodes[id]!.dy.toInt()})',
                  ),
                  trailing: start == id
                      ? const Icon(Icons.check_circle, color: Colors.teal)
                      : null,
                  onTap: () {
                    setState(() {
                      start = id;
                      _isPatientPositionPage = false;
                    });
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Door Nodes (E1–E28)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...filteredDoors.map(
                (id) => ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.door_front_door,
                    color: Color(0xFF1976D2),
                    size: 18,
                  ),
                  title: Text(id),
                  subtitle: Text(
                    'Map position (${doors[id]!.dx.toInt()}, '
                    '${doors[id]!.dy.toInt()})',
                  ),
                  trailing: start == id
                      ? const Icon(Icons.check_circle, color: Colors.teal)
                      : null,
                  onTap: () {
                    setState(() {
                      start = id;
                      _isPatientPositionPage = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _patientAnimationController.stop();
                  setState(() {
                    showMap = false;
                    _mapWasInitialized = false;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  status,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (distance != null)
                Text('${distance!.toStringAsFixed(1)} units'),
            ],
          ),
        ),

        // Keep the legend on Start Navigation only; hide it in View Hospital Map.
        if (!_viewOnlyMap)
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 18,
              runSpacing: 6,
              children: [
                _LegendItem(
                  color: Color(0xFFD32F2F),
                  label: 'Red circle: Patient',
                ),
                _LegendItem(
                  color: Color(0xFF2E7D32),
                  label: 'Green circle: Destination',
                ),
                _LegendItem(
                  color: Color(0xFF1565C0),
                  label: 'Blue line: Shortest navigation route',
                  isLine: true,
                ),
              ],
            ),
          ),

        if (_viewOnlyMap)
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Text(
              'Pinch to zoom • Drag to move around the map',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double fitScale = [
                constraints.maxWidth / mapW,
                constraints.maxHeight / mapH,
              ].reduce((a, b) => a < b ? a : b);

              _mapViewportSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );

              // View Hospital Map opens enlarged for manual inspection.
              // Start Navigation starts zoomed in like a GPS and follows the
              // moving patient, keeping the patient near the viewport centre.
              final double initialScale = _viewOnlyMap ? 1.0 : 1.4;
              final Offset initialPatient = route.isNotEmpty
                  ? HospitalMapPainter(
                      route: route,
                      patientProgress: _patientAnimationController.value,
                      destinationDoor: _doorForRoom(destination),
                      showNavigationMarkers: route.isNotEmpty,
                    ).patientPosition()
                  : Offset.zero;
              final double initialOffsetX = _viewOnlyMap
                  ? 16.0
                  : constraints.maxWidth / 2 - initialPatient.dx * initialScale;
              final double initialOffsetY = _viewOnlyMap
                  ? 16.0
                  : constraints.maxHeight / 2 - initialPatient.dy * initialScale;

              if (!_mapWasInitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted || !showMap || _mapWasInitialized) return;

                  _mapController.value = Matrix4.identity()
                    ..setEntry(0, 0, initialScale)
                    ..setEntry(1, 1, initialScale)
                    ..setEntry(2, 2, 1.0)
                    ..setEntry(0, 3, initialOffsetX)
                    ..setEntry(1, 3, initialOffsetY);

                  setState(() => _mapWasInitialized = true);
                  _followPatientOnNavigationMap();
                });
              }

              return ClipRect(
                child: InteractiveViewer(
                  transformationController: _mapController,
                  constrained: false,
                  alignment: Alignment.topLeft,
                  // Keep Start Navigation readable at GPS-style zoom. The
                  // full-map screen can still zoom out to its fit scale.
                  minScale: _viewOnlyMap ? fitScale : 1.0,
                  maxScale: 5.0,
                  boundaryMargin: const EdgeInsets.all(2000),
                  panEnabled: true,
                  scaleEnabled: true,
                  child: SizedBox(
                    width: mapW,
                    height: mapH,
                    child: AnimatedBuilder(
                      animation: _patientAnimationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(mapW, mapH),
                          painter: HospitalMapPainter(
                            route: route,
                            patientProgress: _patientAnimationController.value,
                            destinationDoor: _doorForRoom(destination),
                            showNavigationMarkers: route.isNotEmpty,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isLine;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLine)
          Container(
            width: 24,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          )
        else
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class HospitalMapPainter extends CustomPainter {
  final List<String> route;
  final double patientProgress;
  final String destinationDoor;
  final bool showNavigationMarkers;

  HospitalMapPainter({
    required this.route,
    required this.patientProgress,
    required this.destinationDoor,
    required this.showNavigationMarkers,
  });

  final Paint border = Paint()
    ..color = Colors.black87
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  final Paint corridor = Paint()..color = const Color(0xFFEAF5F5);

  // The blue route is drawn only in front of the patient.
  final Paint pathPaint = Paint()
    ..color = const Color(0xFF1565C0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final Paint edgePaint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 2;

  Offset centerOf(String id) {
    final Offset? p = nodes[id] ?? doors[id];
    if (p == null) return Offset.zero;
    return Offset(p.dx + 12.5, p.dy + 12.5);
  }

  // Append the destination door if the backend route ends at its
  // directly connected navigation node.
  List<String> get displayRoute {
    final result = List<String>.from(route);

    if (result.isEmpty || !doors.containsKey(destinationDoor)) {
      return result;
    }

    if (result.last == destinationDoor) return result;

    final isConnected = edges.any(
      (edge) =>
          (edge[0] == result.last && edge[1] == destinationDoor) ||
          (edge[1] == result.last && edge[0] == destinationDoor),
    );

    if (isConnected) {
      result.add(destinationDoor);
    }

    return result;
  }

  List<Offset> get routePoints {
    return displayRoute
        .where((id) => nodes.containsKey(id) || doors.containsKey(id))
        .map(centerOf)
        .toList();
  }

  double _routeLength(List<Offset> points) {
    double total = 0;

    for (int i = 0; i < points.length - 1; i++) {
      total += (points[i + 1] - points[i]).distance;
    }

    return total;
  }

  // Calculates the patient's exact position along the route.
  Offset patientPosition() {
    final points = routePoints;

    if (points.isEmpty) return Offset.zero;
    if (points.length == 1) return points.first;

    final totalLength = _routeLength(points);

    if (totalLength <= 0) return points.last;

    final progress = patientProgress.clamp(0.0, 1.0);
    final targetDistance = totalLength * progress;

    double travelled = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final segmentLength = (points[i + 1] - points[i]).distance;

      if (targetDistance <= travelled + segmentLength) {
        final t = segmentLength == 0
            ? 0.0
            : ((targetDistance - travelled) / segmentLength).clamp(0.0, 1.0);

        return Offset.lerp(points[i], points[i + 1], t)!;
      }

      travelled += segmentLength;
    }

    return points.last;
  }

  // Returns only the route ahead of the patient.
  // All route behind the patient is removed from the blue line.
  List<Offset> remainingRoutePoints() {
    final points = routePoints;

    if (points.isEmpty) return [];
    if (points.length == 1) return points;

    final totalLength = _routeLength(points);

    if (totalLength <= 0) return [points.last];

    final progress = patientProgress.clamp(0.0, 1.0);

    // At completion, no blue line remains.
    if (progress >= 1.0) {
      return [points.last];
    }

    final targetDistance = totalLength * progress;

    double travelled = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final segmentLength = (points[i + 1] - points[i]).distance;
      final segmentEndDistance = travelled + segmentLength;

      if (targetDistance <= segmentEndDistance) {
        final t = segmentLength == 0
            ? 0.0
            : ((targetDistance - travelled) / segmentLength).clamp(0.0, 1.0);

        final currentPosition = Offset.lerp(points[i], points[i + 1], t)!;

        final remaining = <Offset>[currentPosition];

        // Add the next route point only if there is still distance
        // remaining on this segment.
        if (t < 1.0) {
          remaining.add(points[i + 1]);
        }

        // Add all subsequent points on the path.
        for (int j = i + 2; j < points.length; j++) {
          remaining.add(points[j]);
        }

        return remaining;
      }

      travelled = segmentEndDistance;
    }

    return [points.last];
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Main corridor.
    canvas.drawRect(
      const Rect.fromLTWH(0, 120, mapW, 70),
      corridor,
    );

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, mapW, mapH),
      border,
    );

    // Draw rooms and their names.
    for (final entry in rooms.entries) {
      final r = entry.value;
      canvas.drawRect(r, border);

      final tp = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      tp.layout(maxWidth: r.width - 8);

      tp.paint(
        canvas,
        Offset(
          r.left + (r.width - tp.width) / 2,
          r.top + (r.height - tp.height) / 2,
        ),
      );
    }

    // Draw the complete hospital graph in grey.
    for (final edge in edges) {
      final a = nodes[edge[0]] ?? doors[edge[0]];
      final b = nodes[edge[1]] ?? doors[edge[1]];

      if (a != null && b != null) {
        canvas.drawLine(
          Offset(a.dx + 12.5, a.dy + 12.5),
          Offset(b.dx + 12.5, b.dy + 12.5),
          edgePaint,
        );
      }
    }

    // Draw only the remaining blue route ahead of the patient.
    if (showNavigationMarkers && routePoints.isNotEmpty) {
      final remaining = remainingRoutePoints();

      if (remaining.length > 1) {
        for (int i = 0; i < remaining.length - 1; i++) {
          canvas.drawLine(
            remaining[i],
            remaining[i + 1],
            pathPaint,
          );
        }
      }
    }

    // Draw UWB anchors.
    for (final entry in anchors.entries) {
      final p = entry.value;
      final c = Offset(p.dx + 15, p.dy + 15);

      canvas.drawCircle(
        c,
        anchorMarkerRadius,
        Paint()..color = Colors.amber.shade200,
      );
      canvas.drawCircle(c, anchorMarkerRadius, border);
      _label(canvas, entry.key, c, 10);
    }

    // Draw regular navigation nodes.
    for (final entry in nodes.entries) {
      final p = entry.value;
      final c = Offset(p.dx + 12.5, p.dy + 12.5);

      canvas.drawCircle(
        c,
        12,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(c, 12, border);
      _label(canvas, entry.key, c, 11);
    }

    // Draw regular door nodes.
    for (final entry in doors.entries) {
      final p = entry.value;
      final c = Offset(p.dx + 12.5, p.dy + 12.5);

      canvas.drawCircle(
        c,
        10,
        Paint()..color = Colors.lightBlue.shade100,
      );
      canvas.drawCircle(c, 10, border);
      _label(canvas, entry.key, c, 10);
    }

    // Draw destination and patient markers last so they remain visible.
    if (showNavigationMarkers && routePoints.isNotEmpty) {
      final points = routePoints;

      // Green destination marker.
      final destination = doors.containsKey(destinationDoor)
          ? centerOf(destinationDoor)
          : points.last;

      canvas.drawCircle(
        destination,
        patientDestinationMarkerRadius,
        Paint()..color = const Color(0xFF2E7D32),
      );

      canvas.drawCircle(
        destination,
        patientDestinationMarkerRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      _label(
        canvas,
        'D',
        destination,
        11,
        textColor: Colors.white,
      );

      // Red patient marker moves along the route and stops at the end.
      final patient = patientPosition();

      canvas.drawCircle(
        patient,
        patientDestinationMarkerRadius,
        Paint()..color = const Color(0xFFD32F2F),
      );

      canvas.drawCircle(
        patient,
        patientDestinationMarkerRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      _label(
        canvas,
        'P',
        patient,
        11,
        textColor: Colors.white,
      );
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize, {
    Color textColor = Colors.black,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    tp.layout();

    tp.paint(
      canvas,
      Offset(
        center.dx - tp.width / 2,
        center.dy - tp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant HospitalMapPainter oldDelegate) {
    return oldDelegate.route.join(',') != route.join(',') ||
        oldDelegate.patientProgress != patientProgress ||
        oldDelegate.destinationDoor != destinationDoor ||
        oldDelegate.showNavigationMarkers != showNavigationMarkers;
  }
}
