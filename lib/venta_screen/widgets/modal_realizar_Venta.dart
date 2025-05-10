import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:flutter/material.dart';

class ModalRealizarVenta extends StatelessWidget {
  final List<ProductoCarrito> productosCarrito;
  final double total;
  final double descuento;

  ModalRealizarVenta({super.key, required this.productosCarrito, required this.total, required this.descuento});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      actions: [
        ElevatedButton(
          onPressed: () {
            // Acción para confirmar la venta
            Navigator.of(context).pop(true);
          },
          child: const Text('Confirmar compra'),
        ),
        ElevatedButton(
          onPressed: () {
            // Acción para cancelar la venta
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancelar venta'),
        ),
      ],
      content: Container(
        width: 400,
        height: 300,
        child: Column(
          children: [
            const Text(
              'Realizar Venta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('¿Está seguro de que desea realizar la venta?'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
