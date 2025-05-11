import 'dart:convert';

import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/controllers/buscador_productos_controller.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:cafe/venta_screen/widgets/modal_realizar_Venta.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  final TextEditingController _searchController = TextEditingController();

  final ObtenerProductosControllers obtenerProductosControllers = Get.put(
    ObtenerProductosControllers(),
  );

  final BuscadorProductosController buscadorProductosController = Get.put(
    BuscadorProductosController(),
  );

  final Set<int> selectedIndexes = {};

  List<ProductoModelo> productosFiltrados = [];
  final List<ProductoCarrito> carrito = [];
  final List<FocusNode> focusNodesCarrito = [];

  @override
  void initState() {
    super.initState();
    cargarProductos();
    _searchController.addListener(_onSearchChanged);
  }

  void cargarProductos() async {
    await obtenerProductosControllers.obtenerProductos();
    setState(() {
      productosFiltrados =
          List<ProductoModelo>.from(obtenerProductosControllers.listaProductos);
    });
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        productosFiltrados = List<ProductoModelo>.from(
            obtenerProductosControllers.listaProductos);
      });
    } else {
      await buscadorProductosController.obtenerProductos(query);
      setState(() {
        productosFiltrados = List<ProductoModelo>.from(
            buscadorProductosController.listaProductos);
      });
    }
  }

  double get totalVenta {
    return carrito.fold<double>(
      0,
      (suma, item) =>
          suma +
          (((item.producto.precio ?? 0) - (item.producto.descuento ?? 0)) *
              item.cantidad),
    );
  }

  double get totalDescuento {
    return carrito.fold<double>(
      0,
      (suma, item) => suma + ((item.producto.descuento ?? 0) * item.cantidad),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalVenta = carrito.fold<double>(
      0,
      (suma, item) => suma +
          ((item.producto.precio ?? 0) - (item.producto.descuento ?? 0)) *
              item.cantidad,
    );
    final double descuento = carrito.fold<double>(
      0,
      (suma, item) => suma + (item.producto.descuento ?? 0) * item.cantidad,
    );

    return Padding(
      padding: const EdgeInsets.all(50),
      child: Row(
        children: [
          /// PARTE DE LISTAR PRODUCTOS
          Expanded(
            flex: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LISTA DE PRODUCTOS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 153, 103, 8),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Buscar articulo por nombre nombre o codigo de barras:',
                    style: TextStyle(
                      fontSize: 19,
                      color: Color.fromARGB(255, 153, 103, 8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: (value) {
                        _onSearchChanged();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                /// PARTE DE lISTAR PRODUCTOS SELECCIONADOS
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (obtenerProductosControllers.estado.value ==
                          Estado.carga) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (obtenerProductosControllers.estado.value ==
                          Estado.error) {
                        return const Center(
                            child: Text('Error al cargar los productos'));
                      } else if (productosFiltrados.isEmpty) {
                        return const Center(
                            child: Text('No hay productos disponibles'));
                      } else {
                        return ListView.builder(
                          itemCount: productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = productosFiltrados[index];
                            return ProductoCard(
                              producto: producto,
                              seleccionado: selectedIndexes.contains(index),
                              onTap: () {
                                setState(() {
                                  final yaEnCarrito = carrito.indexWhere(
                                    (e) =>
                                        e.producto.idProducto ==
                                        producto.idProducto,
                                  );
                                  if (yaEnCarrito >= 0) {
                                    carrito.removeAt(yaEnCarrito);
                                    focusNodesCarrito.removeAt(
                                        yaEnCarrito); // <-- Elimina el focusNode
                                    selectedIndexes.remove(index);
                                  } else {
                                    carrito
                                        .add(ProductoCarrito(producto: producto));
                                    focusNodesCarrito
                                        .add(FocusNode()); // <-- Agrega un nuevo focusNode
                                    selectedIndexes.add(index);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      focusNodesCarrito.last.requestFocus();
                                    });
                                  }
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 26,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total de la venta: \$${totalVenta.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total de la venta: \$${totalDescuento.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final resultado = await showDialog<String>(
                              context: context,
                              builder: (context) => ModalRealizarVenta(
                                totalVenta: totalVenta,
                                descuento: descuento,
                              ),
                            );
                            if (resultado != null) {
                              print('Seleccionado: $resultado');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PAGAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const CabezeraTablaCarritoVenta(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: carrito.length,
                      itemBuilder: (context, index) {
                        final item = carrito[index];
                        return ProductoSeleccionadoFilaWidget(
                          productoCarrito: item,
                          focusNode: focusNodesCarrito[index],
                          onCantidadChanged: (nuevaCantidad) {
                            setState(() {
                              item.cantidad = nuevaCantidad;
                            });
                          },
                          onRemove: () {
                            setState(() {
                              final idx = productosFiltrados.indexWhere((p) =>
                                  p.idProducto == item.producto.idProducto);
                              if (idx >= 0) selectedIndexes.remove(idx);
                              carrito.removeAt(index);
                              focusNodesCarrito.removeAt(index);
                            });
                          },
                        );
                      },
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

class ProductoSeleccionadoFilaWidget extends StatefulWidget {
  final ProductoCarrito productoCarrito;
  final ValueChanged<int> onCantidadChanged;
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
                      if (cantidad > 1) {
                        widget.onCantidadChanged(cantidad - 1);
                        _cantidadController.text = (cantidad - 1).toString();
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
                        focusNode: widget.focusNode, // <-- Aquí
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 2),
                        ),
                        style: const TextStyle(fontSize: 14),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final nuevaCantidad = int.tryParse(value) ?? 1;
                          if (nuevaCantidad > 0 &&
                              nuevaCantidad <= (producto.cantidad ?? 0)) {
                            widget.onCantidadChanged(nuevaCantidad);
                          } else if (nuevaCantidad > (producto.cantidad ?? 0)) {
                            // Si el usuario escribe un número mayor al stock, lo limitas al máximo
                            _cantidadController.text =
                                (producto.cantidad ?? 0).toString();
                            widget.onCantidadChanged(
                                (producto.cantidad ?? 0).toInt());
                          }
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (cantidad < (producto.cantidad ?? 0)) {
                        widget.onCantidadChanged(cantidad + 1);
                        _cantidadController.text = (cantidad + 1).toString();
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

class CabezeraTablaCarritoVenta extends StatelessWidget {
  const CabezeraTablaCarritoVenta({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: Colors.amber,
      child: const Row(children: [
        Expanded(
          flex: 4,
          child: Text(
            'Nombre del producto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Precio',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Descuento',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Cant.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Total',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 40), // Espacio para el botón eliminar
      ]),
    );
  }
}

class ProductoCard extends StatelessWidget {
  final ProductoModelo producto;
  final bool seleccionado;

  final VoidCallback? onTap;

  const ProductoCard({
    super.key,
    required this.producto,
    this.onTap,
    required this.seleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F1E7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Icon(
                  seleccionado
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: seleccionado ? Colors.black54 : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  color: (producto.urlImagen?.isEmpty ?? true)
                      ? Colors.grey[300]
                      : null,
                  image: (producto.urlImagen?.isNotEmpty ?? false)
                      ? DecorationImage(
                          image: Image.memory(base64Decode(producto.urlImagen!))
                              .image,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (producto.urlImagen?.isEmpty ?? true)
                    ? const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 48, color: Colors.grey),
                      )
                    : null,
              ),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '1 ${producto.unidadMedida}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cantidad disponible: ${producto.cantidad} ${producto.unidadMedida}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Precio sin descuento: \$${producto.precio}',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Descuento: \$${producto.descuento}',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Total: \$${(producto.precio ?? 0) - (producto.descuento ?? 0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
