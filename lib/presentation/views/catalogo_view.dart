import 'package:flutter/material.dart';

class CatalogoView extends StatelessWidget {
  const CatalogoView({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = const [
      _Producto(nombre: 'Auriculares Bluetooth', categoria: 'Audio', precio: 799),
      _Producto(nombre: 'Smartwatch Deportivo', categoria: 'Wearables', precio: 1499),
      _Producto(nombre: 'Bocina Portátil', categoria: 'Audio', precio: 999),
      _Producto(nombre: 'Power Bank 10000mAh', categoria: 'Accesorios', precio: 549),
      _Producto(nombre: 'Teclado Mecánico', categoria: 'Periféricos', precio: 1299),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Monitor de sensores',
            icon: const Icon(Icons.sensors),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El monitor de sensores se habilitará en la siguiente fase.'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: productos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final producto = productos[index];
          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ListTile(
              leading: CircleAvatar(
                child: Text(producto.nombre.characters.first),
              ),
              title: Text(producto.nombre),
              subtitle: Text(producto.categoria),
              trailing: Text(
                '\$${producto.precio.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Producto {
  final String nombre;
  final String categoria;
  final double precio;

  const _Producto({
    required this.nombre,
    required this.categoria,
    required this.precio,
  });
}
