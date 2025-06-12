import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Agregar esta importación

class ProductoSeleccionadoFilaWidget extends StatefulWidget {
  final ProductoCarrito productoCarrito;
  final ValueChanged<double> onCantidadChanged;
  final VoidCallback onRemove;
  final FocusNode? focusNode; // <-- Agrega esto

  const ProductoSeleccionadoFilaWidget({
    super.key,
    required this.productoCarrito,
    required this.onCantidadChanged,
    required this.onRemove,
    this.focusNode, // <-- Agrega esto
  });

  @override
  State<ProductoSeleccionadoFilaWidget> createState() =>
      _ProductoSeleccionadoFilaWidgetState();
}

class _ProductoSeleccionadoFilaWidgetState
    extends State<ProductoSeleccionadoFilaWidget> {
  late TextEditingController _cantidadController;

  @override
  void initState() {
    super.initState();
    _cantidadController =
        TextEditingController(text: widget.productoCarrito.cantidad.toString());
  }

  @override
  void didUpdateWidget(covariant ProductoSeleccionadoFilaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualiza el controller si la cantidad cambia desde fuera
    if (widget.productoCarrito.cantidad.toString() !=
        _cantidadController.text) {
      _cantidadController.text = widget.productoCarrito.cantidad.toString();
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.productoCarrito.producto;
    final cantidad = widget.productoCarrito.cantidad;
    final precio = producto.precio ?? 0;
    final descuento = producto.descuento ?? 0;
    final total = (precio - descuento) * cantidad;

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1E7),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              producto.nombre,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${precio.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${descuento.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              width: double.infinity,
              height: 22,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      // Cambiar el decremento para valores decimales
                      if (cantidad > 0.1) { // Mínimo de 0.1 en lugar de 1
                        final nuevaCantidad = cantidad - 0.1;
                        widget.onCantidadChanged(nuevaCantidad);
                        _cantidadController.text = nuevaCantidad.toStringAsFixed(1);
                      }
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Icon(Icons.remove, size: 14),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: 22,
                      child: TextFormField(
                        controller: _cantidadController,
                        focusNode: widget.focusNode,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 2),
                        ),
                        style: const TextStyle(fontSize: 14),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true), // Permitir decimales
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')), // Permitir hasta 3 decimales
                        ],
                        onChanged: (value) {
                          final nuevaCantidad = double.tryParse(value) ?? 0.1;
                          if (nuevaCantidad > 0 &&
                              nuevaCantidad <= (producto.cantidad ?? 0)) {
                            widget.onCantidadChanged(nuevaCantidad);
                          } else if (nuevaCantidad > (producto.cantidad ?? 0)) {
                            // Si el usuario escribe un número mayor al stock, lo limitas al máximo
                            _cantidadController.text =
                                (producto.cantidad ?? 0).toString();
                            widget.onCantidadChanged(
                                (producto.cantidad ?? 0).toDouble());
                          } else if (nuevaCantidad <= 0) {
                            // Si el valor es 0 o negativo, establecer mínimo
                            _cantidadController.text = "0.1";
                            widget.onCantidadChanged(0.1);
                          }
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Cambiar el incremento para valores decimales
                      if (cantidad + 0.1 <= (producto.cantidad ?? 0)) {
                        final nuevaCantidad = cantidad + 0.1;
                        widget.onCantidadChanged(nuevaCantidad);
                        _cantidadController.text = nuevaCantidad.toStringAsFixed(1);
                      }
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Icon(Icons.add, size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${total.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onRemove,
            ),
          ),
        ],
      ),
    );
  }
}
