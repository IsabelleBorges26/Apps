import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MapScreen());
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 2. Pontos de Origem e Destino
  final _pontoOrigem = LatLng(-23.55052, -46.633308); // São Paulo (Sé)
  final _pontoDestino = LatLng(-23.55552, -46.643308); // Destino próximo

  // 3. Controladores e coleções do mapa
  late GoogleMapController mapController;
  final Map<PolylineId, Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  // Adiciona os marcadores visuais de início e fim no mapa
  void _addMarkers() {
    _markers.add(
      Marker(
        markerId: MarkerId('origem'),
        position: _pontoOrigem,
        infoWindow: InfoWindow(title: 'Origem'),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('destino'),
        position: _pontoDestino,
        infoWindow: InfoWindow(title: 'Destino'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Traçando rota no Mapa')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _pontoOrigem, zoom: 14.5),
        markers: _markers,
        polylines: Set<Polyline>.of(_polylines.values),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          buscarRota(_pontoOrigem, _pontoDestino);
        },
      ),
    );
  }

  Future<void> buscarRota(LatLng origem, LatLng destino) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origem.longitude},${origem.latitude};'
      '${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['routes'] == null || (data['routes'] as List).isEmpty) {
          debugPrint('OSRM: nenhuma rota encontrada');
          return;
        }

        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final pontos = coords
            .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();

        final polyline = Polyline(
          polylineId: const PolylineId('trajeto_osrm'),
          color: Colors.blue,
          width: 5,
          points: pontos,
        );

        setState(() {
          _polylines[polyline.polylineId] = polyline;
        });

        final bounds = _boundsFromPoints(pontos);
        if (bounds != null) {
          mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
        }
      } else {
        debugPrint('OSRM erro: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro ao buscar rota OSRM: $e');
    }
  }

  LatLngBounds? _boundsFromPoints(List<LatLng> points) {
    if (points.isEmpty) return null;

    final latitudes = points.map((p) => p.latitude).toList();
    final longitudes = points.map((p) => p.longitude).toList();

    return LatLngBounds(
      southwest: LatLng(
        latitudes.reduce((a, b) => a < b ? a : b),
        longitudes.reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        latitudes.reduce((a, b) => a > b ? a : b),
        longitudes.reduce((a, b) => a > b ? a : b),
      ),
    );
  }
}
