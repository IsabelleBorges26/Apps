import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(
    MaterialApp(
      title: "Pontos no Mapa",
      home: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _pontoInicial = LatLng(
    -22.7130000,
    -46.8180000,
  );

  LatLng? _pontoClicado;
  String mensagem = "Clique em algum lugar no mapa";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obter Coordenadas no Mapa'),
      ),
      body: Column(
        children: [
          Text(
            "Origem @${_pontoInicial.latitude},${_pontoInicial.longitude}",
          ),
          Text(mensagem),

          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _pontoInicial,
                zoom: 14.0,
              ),

              onTap: (LatLng latLng) {
                setState(() {
                  _pontoClicado = latLng;
                  mensagem =
                      'Destino: @${latLng.latitude},${latLng.longitude}';
                });
              },

              markers: _pontoClicado == null
                  ? {
                      Marker(
                        markerId: const MarkerId('origem'),
                        position: _pontoInicial,
                      ),
                    }
                  : {
                      Marker(
                        markerId: const MarkerId('origem'),
                        position: _pontoInicial,
                      ),
                      Marker(
                        markerId: const MarkerId('destino'),
                        position: _pontoClicado!,
                      ),
                    },
            ),
          ),
        ],
      ),
    );
  }
}