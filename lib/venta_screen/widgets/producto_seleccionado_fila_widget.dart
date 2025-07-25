import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductoSeleccionadoFilaWidget extends StatefulWidget {
  final ProductoCarrito productoCarrito;
  final ValueChanged<double> onCantidadChanged;
  final VoidCallback onRemove;
  final FocusNode? focusNode;

  const ProductoSeleccionadoFilaWidget({
    super.key,
    required this.productoCarrito,
    required this.onCantidadChanged,
    required this.onRemove,
    this.focusNode,
  });

  @override
  State<ProductoSeleccionadoFilaWidget> createState() =>
      _ProductoSeleccionadoFilaWidgetState();
}

class _ProductoSeleccionadoFilaWidgetState
    extends State<ProductoSeleccionadoFilaWidget> {
  final List<_FraccionOpcion> _opciones = [
    _FraccionOpcion(label: "1/4", value: 0.25),
    _FraccionOpcion(label: "1/2", value: 0.5),
    _FraccionOpcion(label: "3/4", value: 0.75),
    _FraccionOpcion(label: "1", value: 1.0),
    _FraccionOpcion(label: "Otra cantidad...", value: -1),
  ];

  late TextEditingController _cantidadController;
  double? _valorSeleccionado;
  bool _editandoOtraCantidad = false;

  @override
  void initState() {
    super.initState();
    _cantidadController = TextEditingController(
      text: widget.productoCarrito.cantidad.toString(),
    );
    _valorSeleccionado = _opciones
                .firstWhere((e) => e.value == widget.productoCarrito.cantidad,
                    orElse: () => _FraccionOpcion(label: "", value: -1))
                .value !=
            -1
        ? widget.productoCarrito.cantidad
        : -1;
    _editandoOtraCantidad = _valorSeleccionado == -1;
  }

  @override
  void didUpdateWidget(covariant ProductoSeleccionadoFilaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editandoOtraCantidad &&
        widget.productoCarrito.cantidad.toString() !=
            _cantidadController.text) {
      _cantidadController.text = widget.productoCarrito.cantidad.toString();
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  void _seleccionarOpcion(double valor) {
    setState(() {
      if (valor == -1) {
        _editandoOtraCantidad = true;
        _valorSeleccionado = -1;
      } else {
        _editandoOtraCantidad = false;
        _valorSeleccionado = valor;
        _cantidadController.text = valor.toString();
        widget.onCantidadChanged(valor);
      }
    });
  }

  void _procesarOtraCantidad(String valor) {
    double nuevaCantidad = double.tryParse(valor.replaceAll(',', '.')) ?? 0;
    double stock =
        widget.productoCarrito.producto.cantidad?.toDouble() ?? double.infinity;

    if (nuevaCantidad <= 0) return;

    if (nuevaCantidad > stock) {
      // Si excede el stock, lo ajusta al máximo permitido
      _cantidadController.text = stock.toString();
      widget.onCantidadChanged(stock);
      // Mueve el cursor al final del texto
      _cantidadController.selection = TextSelection.fromPosition(
          TextPosition(offset: _cantidadController.text.length));
    } else {
      widget.onCantidadChanged(nuevaCantidad);
    }
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.productoCarrito.producto;
    final cantidad = widget.productoCarrito.cantidad;
    
    // Nuevas variables para mayoreo
    final aplicaMayoreo = widget.productoCarrito.aplicaPrecioMayoreo;
    final precioMostrar = widget.productoCarrito.precioFinal;
    final descuento = producto.descuento ?? 0;
    final total = widget.productoCarrito.totalConMayoreo; // Usar el total con mayoreo

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1E7),
      ),
      child: Row(
        children: [
          // Nombre del producto con indicador de mayoreo
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  producto.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                if (aplicaMayoreo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'Precio Mayoreo',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Precio unitario con indicador si es mayoreo
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${precioMostrar.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: aplicaMayoreo ? FontWeight.bold : FontWeight.normal,
                    color: aplicaMayoreo ? Colors.green[700] : Colors.black,
                  ),
                ),
                if (aplicaMayoreo && producto.precio != precioMostrar)
                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          
          Expanded(
            flex: 2,
            child: Text(
              '\$${descuento.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
            ),
          ),
          
          // MANTENER TODA LA LÓGICA DE FRACCIONES
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<double>(
                  value: _valorSeleccionado,
                  onChanged: (double? value) {
                    if (value != null) _seleccionarOpcion(value);
                  },
                  items: _opciones
                      .map((op) => DropdownMenuItem<double>(
                            value: op.value,
                            child: Text(op.label),
                          ))
                      .toList(),
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
                SizedBox(width: 4),
                SizedBox(
                  width: 65,
                  height: 32,
                  child: TextFormField(
                    controller: _cantidadController,
                    focusNode: widget.focusNode,
                    enabled: _editandoOtraCantidad,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      isDense: true,
                      fillColor: _editandoOtraCantidad
                          ? Colors.white
                          : Colors.grey[200],
                      filled: true,
                      hintText: _editandoOtraCantidad ? '' : '',
                    ),
                    style: const TextStyle(fontSize: 14),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,8}')),
                    ],
                    onChanged:
                        _editandoOtraCantidad ? _procesarOtraCantidad : null,
                  ),
                ),
              ],
            ),
          ),
          
          // Total con color diferente si es mayoreo
          Expanded(
            flex: 2,
            child: Text(
              '\$${total.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: aplicaMayoreo ? Colors.green[700] : Colors.black,
              ),
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

class _FraccionOpcion {
  final String label;
  final double value;
  const _FraccionOpcion({required this.label, required this.value});
}
