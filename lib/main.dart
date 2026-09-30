import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
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
  LatLng? _pontoClicado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // Instrução
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: Colors.blue.shade50,
            child: const Row(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 20,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Text(
                  'Toque no mapa para selecionar um ponto',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Mapa
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  -22.7130000,
                  -46.8180000,
                ),
                initialZoom: 17.0,

                onTap: (tapPosition, latLng) {
                  setState(() {
                    _pontoClicado = latLng;
                  });
                },
              ),

              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.flutter_obter_posicao_map',
                ),

                if (_pontoClicado != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pontoClicado!,
                        width: 45,
                        height: 45,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Informações do ponto
          if (_pontoClicado != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ponto selecionado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Latitude: ${_pontoClicado!.latitude.toStringAsFixed(6)}',
                  ),

                  Text(
                    'Longitude: ${_pontoClicado!.longitude.toStringAsFixed(6)}',
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _pontoClicado = null;
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpar ponto'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}