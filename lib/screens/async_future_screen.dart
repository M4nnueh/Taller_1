import 'package:flutter/material.dart';
import '../services/mock_async_service.dart';

class AsyncFutureScreen extends StatefulWidget {
  const AsyncFutureScreen({super.key});

  @override
  State<AsyncFutureScreen> createState() => _AsyncFutureScreenState();
}

class _AsyncFutureScreenState extends State<AsyncFutureScreen> {
  AsyncStatus _status = AsyncStatus.initial;
  ServiceData? _data;
  String? _errorMessage;
  final List<String> _consoleLogs = [];

  void _addLog(String msg) {
    setState(() {
      _consoleLogs.insert(0, '[${DateTime.now().toIso8601String().substring(11, 19)}] $msg');
    });
  }

  Future<void> _fetchData({bool shouldFail = false}) async {
    setState(() {
      _status = AsyncStatus.loading;
      _errorMessage = null;
    });
    _addLog('ANTES: Iniciando petición asíncrona (shouldFail=$shouldFail)...');

    try {
      _addLog('DURANTE: Esperando resultado con await Future.delayed...');
      final result = await MockAsyncService.fetchUserData(shouldFail: shouldFail);

      if (!mounted) return;
      setState(() {
        _data = result;
        _status = AsyncStatus.success;
      });
      _addLog('DESPUÉS (Éxito): Datos recibidos "${result.title}".');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = AsyncStatus.error;
      });
      _addLog('DESPUÉS (Error): Falló la petición -> $_errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('1. Asincronía: Future & async/await'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner explicativo
            Card(
              color: Colors.indigo.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.indigo.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demostración de Future y async/await',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Permite realizar operaciones de E/S o retardos sin bloquear el hilo principal (UI). Se controlan los estados: Inicial, Cargando, Éxito y Error.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contenedor de Estado
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildStatusWidget(theme),
              ),
            ),
            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _status == AsyncStatus.loading
                        ? null
                        : () => _fetchData(shouldFail: false),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Consultar (Éxito)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _status == AsyncStatus.loading
                        ? null
                        : () => _fetchData(shouldFail: true),
                    icon: const Icon(Icons.error_outline),
                    label: const Text('Simular Error'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sección de Log de Consola en pantalla
            Text(
              'Consola de Eventos (Orden de ejecución):',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _consoleLogs.isEmpty
                  ? const Center(
                      child: Text(
                        'Presiona un botón para ver el orden de ejecución...',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _consoleLogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            _consoleLogs[index],
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(ThemeData theme) {
    switch (_status) {
      case AsyncStatus.initial:
        return const Column(
          children: [
            Icon(Icons.cloud_sync_outlined, size: 54, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Estado: En espera',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              'Haz clic en un botón para iniciar la simulación.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        );

      case AsyncStatus.loading:
        return const Column(
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'Cargando datos...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            SizedBox(height: 4),
            Text(
              'Simulando retardo con Future.delayed (2-3 s)...',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        );

      case AsyncStatus.success:
        return Column(
          children: [
            const Icon(Icons.check_circle_rounded, size: 54, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              'Estado: ¡Éxito!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file_outlined, color: Colors.indigo),
              title: Text(_data?.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_data?.description ?? ''),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registros: ${_data?.recordsCount}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                Text(
                  'Hora: ${_data?.timestamp.toLocal().toString().substring(11, 19)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ],
        );

      case AsyncStatus.error:
        return Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 54, color: Colors.red),
            const SizedBox(height: 10),
            Text(
              'Estado: Error en la consulta',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage ?? 'Ocurrió un error inesperado.',
                style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
    }
  }
}
