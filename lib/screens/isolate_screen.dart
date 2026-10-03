import 'package:flutter/material.dart';
import '../services/heavy_compute_service.dart';

class IsolateScreen extends StatefulWidget {
  const IsolateScreen({super.key});

  @override
  State<IsolateScreen> createState() => _IsolateScreenState();
}

class _IsolateScreenState extends State<IsolateScreen> with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  HeavyComputationResult? _result;
  int _selectedCount = 2000000; // 2 millones de iteraciones
  final List<String> _isolateLogs = [];
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    // Animación continua para demostrar que la UI NO se congela durante el cálculo pesado
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _addLog(String msg) {
    setState(() {
      _isolateLogs.insert(0, '[${DateTime.now().toIso8601String().substring(11, 19)}] $msg');
    });
  }

  Future<void> _startComputation() async {
    setState(() {
      _isProcessing = true;
      _result = null;
    });

    _addLog('MAIN: Solicitando ejecución pesada ($_selectedCount iteraciones)...');
    _addLog('MAIN: Lanzando Isolate.spawn para aislar la carga de CPU...');

    try {
      final res = await HeavyComputeService.runHeavyTask(_selectedCount);

      if (!mounted) return;
      setState(() {
        _result = res;
        _isProcessing = false;
      });

      _addLog('MAIN: Resultado recibido en ${res.executionTimeMs} ms.');
      _addLog('MAIN: Suma: ${res.sum.toStringAsFixed(2)} | Primos encontrados: ${res.primeCount}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      _addLog('MAIN ERROR: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('3. Isolate (Tarea Pesada)'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner informativo
            Card(
              color: Colors.deepPurple.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.deepPurple.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uso de Isolate.spawn & SendPort/ReceivePort',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ejecuta operaciones CPU-bound en un hilo independiente con su propia memoria, manteniendo la fluidez total de la interfaz gráfica a 60/120 FPS.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Widget de demostración de fluidez de la UI
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        RotationTransition(
                          turns: _animController,
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.deepPurple,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prueba de fluidez de la UI',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'Observa cómo este icono sigue girando sin tirones mientras el Isolate procesa millones de cálculos.',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Configuración de Carga de Trabajo
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seleccionar carga de trabajo (CPU):',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 500000, label: Text('500K')),
                        ButtonSegment(value: 2000000, label: Text('2M')),
                        ButtonSegment(value: 5000000, label: Text('5M')),
                      ],
                      selected: {_selectedCount},
                      onSelectionChanged: _isProcessing
                          ? null
                          : (newSet) {
                              setState(() {
                                _selectedCount = newSet.first;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _startComputation,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.memory),
                        label: Text(_isProcessing
                            ? 'Procesando en Isolate...'
                            : 'Ejecutar Tarea en Isolate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tarjeta de Resultados
            if (_result != null) ...[
              Card(
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.speed, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '¡Cálculo Finalizado con Éxito!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text('• Tiempo empleado: ${_result!.executionTimeMs} ms',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('• Números primos calculados: ${_result!.primeCount}'),
                      Text('• Suma acumulada: ${_result!.sum.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Mensajes y Logs del Isolate
            Text(
              'Consola y Comunicación de Mensajes:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isolateLogs.isEmpty
                  ? const Center(
                      child: Text(
                        'Presiona el botón para iniciar la comunicación por Isolate...',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _isolateLogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            _isolateLogs[index],
                            style: const TextStyle(
                              color: Colors.purpleAccent,
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
}
