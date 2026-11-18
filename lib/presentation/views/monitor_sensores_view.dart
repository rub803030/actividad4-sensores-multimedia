import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MonitorSensoresView extends StatefulWidget {
  const MonitorSensoresView({super.key});

  @override
  State<MonitorSensoresView> createState() => _MonitorSensoresViewState();
}

class _MonitorSensoresViewState extends State<MonitorSensoresView> {
  static const double _umbralSacudida = 15.0;
  static const Duration _cooldown = Duration(milliseconds: 1500);

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer();

  double _x = 0;
  double _y = 0;
  double _z = 0;
  bool _sacudidaDetectada = false;
  bool _sensorDisponible = true;
  String? _mensajeError;
  DateTime _ultimaReproduccion = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _indicadorTimer;

  @override
  void initState() {
    super.initState();
    _iniciarEscuchaAcelerometro();
  }

  void _iniciarEscuchaAcelerometro() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          final bool sacudida = event.x.abs() > _umbralSacudida ||
              event.y.abs() > _umbralSacudida ||
              event.z.abs() > _umbralSacudida;

          if (!mounted) return;
          setState(() {
            _x = event.x;
            _y = event.y;
            _z = event.z;
            _sensorDisponible = true;
            _mensajeError = null;
          });

          if (sacudida) {
            _activarAlertaSacudida();
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!mounted) return;
          setState(() {
            _sensorDisponible = false;
            _mensajeError =
                'Sensor de acelerómetro no disponible: $error';
          });
        },
        cancelOnError: false,
      );
    } catch (error) {
      _sensorDisponible = false;
      _mensajeError = 'No se pudo iniciar la lectura del sensor: $error';
    }
  }

  Future<void> _reproducirAlerta() async {
    final DateTime ahora = DateTime.now();
    if (ahora.difference(_ultimaReproduccion) < _cooldown) {
      return;
    }
    _ultimaReproduccion = ahora;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/alerta_sacudida.mp3'));
    } catch (_) {
      // Se ignoran errores de reproducción para no interrumpir la UI.
    }
  }

  void _activarAlertaSacudida() {
    _indicadorTimer?.cancel();
    if (mounted) {
      setState(() {
        _sacudidaDetectada = true;
      });
    }
    _reproducirAlerta();
    _indicadorTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _sacudidaDetectada = false;
      });
    });
  }

  Future<void> _probarAudioManual() async {
    _ultimaReproduccion = DateTime.fromMillisecondsSinceEpoch(0);
    await _reproducirAlerta();
  }

  @override
  void dispose() {
    _indicadorTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatear(double valor) => valor.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color estadoColor = _sacudidaDetectada ? Colors.red : Colors.green;
    final String estadoTexto = _sacudidaDetectada
        ? 'Sacudida fuerte detectada'
        : 'Lectura estable';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Sensores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: estadoColor.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _sacudidaDetectada ? Icons.warning_amber : Icons.check_circle,
                      color: estadoColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estadoTexto,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: estadoColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Umbral: > ${_umbralSacudida.toStringAsFixed(1)} m/s² en cualquier eje',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coordenadas del acelerómetro (m/s²)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _EjeTile(
                      etiqueta: 'Eje X',
                      valor: _formatear(_x),
                      color: scheme.primary,
                    ),
                    const Divider(),
                    _EjeTile(
                      etiqueta: 'Eje Y',
                      valor: _formatear(_y),
                      color: scheme.secondary,
                    ),
                    const Divider(),
                    _EjeTile(
                      etiqueta: 'Eje Z',
                      valor: _formatear(_z),
                      color: scheme.tertiary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!_sensorDisponible || _mensajeError != null)
              Card(
                color: scheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _mensajeError ??
                        'No se detectó un acelerómetro disponible en este dispositivo.',
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _probarAudioManual,
              icon: const Icon(Icons.volume_up),
              label: const Text('Probar audio manualmente'),
            ),
            const SizedBox(height: 8),
            Text(
              'Incluye enfriamiento de 1.5 s entre reproducciones para evitar saturación del audio.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EjeTile extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color color;

  const _EjeTile({
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(etiqueta, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        Text(
          valor,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
