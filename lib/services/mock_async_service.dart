import 'dart:async';
import 'dart:math';

/// Modelo para los datos simulados obtenidos mediante Future
class ServiceData {
  final String title;
  final String description;
  final DateTime timestamp;
  final int recordsCount;

  ServiceData({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.recordsCount,
  });
}

/// Estado de la consulta asíncrona
enum AsyncStatus { initial, loading, success, error }

/// Servicio simulado que demuestra el uso de Future, async y await
class MockAsyncService {
  /// Simula la consulta de datos desde un servidor con retardo de 2 a 3 segundos.
  /// [shouldFail] permite forzar un error para demostrar el manejo de excepciones.
  static Future<ServiceData> fetchUserData({bool shouldFail = false}) async {
    print('[CONSOLA] [1. ANTES] Iniciando llamada a fetchUserData()...');

    final randomDelay = 2000 + Random().nextInt(1001); // Entre 2000ms y 3000ms
    print('[CONSOLA] [2. DURANTE] Esperando $randomDelay ms con Future.delayed...');

    await Future.delayed(Duration(milliseconds: randomDelay));

    if (shouldFail) {
      print('[CONSOLA] [3. DESPUÉS (ERROR)] Error simulado al consultar los datos.');
      throw Exception('Error 500: Fallo en la conexión con el servidor remoto.');
    }

    print('[CONSOLA] [3. DESPUÉS (ÉXITO)] Datos obtenidos con éxito.');
    return ServiceData(
      title: 'Reporte de Usuarios Activos',
      description: 'Consulta asíncrona completada satisfactoriamente sin bloquear la UI.',
      timestamp: DateTime.now(),
      recordsCount: 1250,
    );
  }
}
