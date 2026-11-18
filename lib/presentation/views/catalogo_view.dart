import 'package:flutter/material.dart';

import 'monitor_sensores_view.dart';

class CatalogoView extends StatelessWidget {
  const CatalogoView({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = const [
      _Producto(
        nombre: 'Auriculares Bluetooth',
        categoria: 'Audio',
        precio: 799,
        descripcion: 'Sonido envolvente, cancelación de ruido y batería de larga duración.',
        imagen: 'assets/images/prod_audio.jpg',
      ),
      _Producto(
        nombre: 'Smartwatch Deportivo',
        categoria: 'Wearables',
        precio: 1499,
        descripcion: 'Monitoreo de actividad, salud y notificaciones inteligentes.',
        imagen: 'assets/images/prod_watch.jpg',
      ),
      _Producto(
        nombre: 'Bocina Portátil',
        categoria: 'Audio',
        precio: 999,
        descripcion: 'Potencia portátil con conexión inalámbrica y diseño resistente.',
        imagen: 'assets/images/prod_speaker.jpg',
      ),
      _Producto(
        nombre: 'Power Bank 10000mAh',
        categoria: 'Accesorios',
        precio: 549,
        descripcion: 'Carga rápida y compacta para tus dispositivos móviles.',
        imagen: 'assets/images/prod_power.jpg',
      ),
      _Producto(
        nombre: 'Teclado Mecánico',
        categoria: 'Periféricos',
        precio: 1299,
        descripcion: 'Precisión, iluminación y comodidad para trabajo o juego.',
        imagen: 'assets/images/prod_keyboard.jpg',
      ),
    ];

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        actions: [
          IconButton(
            tooltip: 'Monitor de sensores',
            icon: const Icon(Icons.sensors),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MonitorSensoresView(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/banner_catalogo.jpg',
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: Text(
                    'Explora productos y accede al monitor de sensores desde el ícono superior.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'Productos destacados',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...productos.map(
            (producto) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            producto.imagen,
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                producto.descripcion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      producto.categoria,
                                      style: TextStyle(
                                        color: scheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${producto.precio.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Producto {
  final String nombre;
  final String categoria;
  final double precio;
  final String descripcion;
  final String imagen;

  const _Producto({
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.descripcion,
    required this.imagen,
  });
}
