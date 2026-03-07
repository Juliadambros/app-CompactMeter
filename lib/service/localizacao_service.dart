import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocalizacaoService {
  StreamSubscription<Position>? _subscription;

  Future<bool> garantirPermissao() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> obterPosicaoAtual() async {
    final ok = await garantirPermissao();
    if (!ok) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Stream<Position> ouvirPosicao() async* {
    final ok = await garantirPermissao();
    if (!ok) return;

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  double calcularDistanciaMetros({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  double calcularDistanciaAcumulada(List<Position> pontos) {
    if (pontos.length < 2) return 0;

    double total = 0;
    for (int i = 1; i < pontos.length; i++) {
      total += Geolocator.distanceBetween(
        pontos[i - 1].latitude,
        pontos[i - 1].longitude,
        pontos[i].latitude,
        pontos[i].longitude,
      );
    }
    return total;
  }

  Future<void> cancelarStream() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void setSubscription(StreamSubscription<Position> sub) {
    _subscription = sub;
  }
}