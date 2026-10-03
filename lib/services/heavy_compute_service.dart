import 'dart:isolate';

/// Parámetros enviados al Isolate
class HeavyComputationParams {
  final int count;
  final SendPort sendPort;

  HeavyComputationParams({
    required this.count,
    required this.sendPort,
  });
}

/// Mensaje que envía el Isolate de regreso al hilo principal
class HeavyComputationResult {
  final double sum;
  final int primeCount;
  final int executionTimeMs;

  HeavyComputationResult({
    required this.sum,
    required this.primeCount,
    required this.executionTimeMs,
  });
}

/// Servicio que gestiona la ejecución en un Isolate separado usando Isolate.spawn
class HeavyComputeService {
  /// Función estática de alto nivel o top-level que ejecutará el Isolate (CPU-bound)
  static void _isolateEntryPoint(HeavyComputationParams params) {
    final stopwatch = Stopwatch()..start();
    print('[ISOLATE] [Entrada] Isolate iniciado para procesar ${params.count} elementos...');

    double totalSum = 0;
    int primesFound = 0;

    // Tarea intensiva en CPU: suma grande y cálculo de números primos
    for (int i = 1; i <= params.count; i++) {
      totalSum += (i * 0.5);

      // Verificación de primalidad para carga extra de CPU
      if (_isPrime(i)) {
        primesFound++;
      }

      // Log periódico en consola del Isolate
      if (i % (params.count ~/ 4 == 0 ? 1 : params.count ~/ 4) == 0) {
        print('[ISOLATE] [Progreso] Procesado: ${(i / params.count * 100).toStringAsFixed(0)}%');
      }
    }

    stopwatch.stop();
    print('[ISOLATE] [Salida] Tarea completada en ${stopwatch.elapsedMilliseconds} ms. Enviando resultado por SendPort...');

    // Enviar el resultado al hilo principal por el SendPort
    params.sendPort.send(
      HeavyComputationResult(
        sum: totalSum,
        primeCount: primesFound,
        executionTimeMs: stopwatch.elapsedMilliseconds,
      ),
    );
  }

  /// Método auxiliar simple para verificar si un número es primo
  static bool _isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6) {
      if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
  }

  /// Inicia el Isolate mediante Isolate.spawn y devuelve un Future con el resultado
  static Future<HeavyComputationResult> runHeavyTask(int count) async {
    print('[MAIN HILO] Creando ReceivePort para comunicación con Isolate...');
    final receivePort = ReceivePort();

    final params = HeavyComputationParams(
      count: count,
      sendPort: receivePort.sendPort,
    );

    print('[MAIN HILO] Lanzando Isolate.spawn...');
    final isolate = await Isolate.spawn<HeavyComputationParams>(
      _isolateEntryPoint,
      params,
    );

    // Esperar el mensaje emitido por el Isolate
    final dynamic message = await receivePort.first;
    print('[MAIN HILO] Mensaje recibido del Isolate por ReceivePort.');

    // Limpieza de recursos
    receivePort.close();
    isolate.kill(priority: Isolate.immediate);
    print('[MAIN HILO] Isolate terminado y ReceivePort cerrado.');

    return message as HeavyComputationResult;
  }
}
