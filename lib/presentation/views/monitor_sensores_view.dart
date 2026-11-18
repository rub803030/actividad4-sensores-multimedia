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
            _mensajeError = 'Sensor de acelerómetro no disponible: $error';
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
    final String estadoTexto =
        _sacudidaDetectada ? 'Sacudida fuerte detectada' : 'Lectura estable';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Sensores'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/sensor_header.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: estadoColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: estadoColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: estadoColor,
                  child: Icon(
                    _sacudidaDetectada
                        ? Icons.warning_amber_rounded
                        : Icons.sensors,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
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
                        'Umbral de sacudida: > ${_umbralSacudida.toStringAsFixed(1)} m/s² en cualquier eje',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Coordenadas del acelerómetro (m/s²)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _EjeTile(
                    etiqueta: 'Eje X',
                    valor: _formatear(_x),
                    color: scheme.primary,
                    icono: Icons.swap_horiz,
                  ),
                  const Divider(height: 20),
                  _EjeTile(
                    etiqueta: 'Eje Y',
                    valor: _formatear(_y),
                    color: scheme.secondary,
                    icono: Icons.swap_vert,
                  ),
                  const Divider(height: 20),
                  _EjeTile(
                    etiqueta: 'Eje Z',
                    valor: _formatear(_z),
                    color: scheme.tertiary,
                    icono: Icons.unfold_more,
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
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: scheme.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _mensajeError ??
                            'No se detectó un acelerómetro disponible en este dispositivo.',
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _probarAudioManual,
            icon: const Icon(Icons.volume_up),
            label: const Text('Probar audio manualmente'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Incluye enfriamiento de 1.5 s entre reproducciones para evitar saturación del audio. La suscripción y el reproductor se liberan en dispose().',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EjeTile extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color color;
  final IconData icono;

  const _EjeTile({
    required this.etiqueta,
    required this.valor,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            etiqueta,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            valor,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
