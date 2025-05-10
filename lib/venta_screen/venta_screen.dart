import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/controllers/buscador_productos_controller.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:cafe/venta_screen/widgets/cabezera_tabla_carrito_venta.dart';
import 'package:cafe/venta_screen/widgets/modal_realizar_Venta.dart';
import 'package:cafe/venta_screen/widgets/producto_seleccionado_fila_widget.dart';
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
      // Si está vacío, muestra todos los productos
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
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Row(
        children: [
          ///////**********************************************************PARTE DE LISTAR PRODUCTOS */
          Expanded(
            flex: 20,
            child: Container(
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
                  const SizedBox(
                    height: 20,
                  ),
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
                  SizedBox(
                    height: 10,
                  ),
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
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ///////**********************************************************PARTE DE lISTAR PRODUCTOS SELECCIONADOS */
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
                                      carrito.add(
                                          ProductoCarrito(producto: producto));
                                      focusNodesCarrito.add(
                                          FocusNode()); // <-- Agrega un nuevo focusNode
                                      selectedIndexes.add(index);
                                      // Espera a que el widget se reconstruya y luego solicita el foco
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
                          'Descuento aplicado: \$${totalDescuento.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  carrito.clear();
                                  focusNodesCarrito.clear();
                                  selectedIndexes.clear();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'CANCELAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return ModalRealizarVenta(
                                        productosCarrito: carrito,
                                        total: totalVenta,
                                        descuento: totalDescuento,
                                      );
                                    });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 55, vertical: 5),
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
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const CabezeraTablaCarritoVenta(),
                  // Aquí puedes agregar el contenido del carrito de venta
                  Expanded(
                    child: ListView.builder(
                      itemCount: carrito.length,
                      itemBuilder: (context, index) {
                        final item = carrito[index];
                        return ProductoSeleccionadoFilaWidget(
                          productoCarrito: item,
                          focusNode: focusNodesCarrito[index], // <-- Aquí
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
                              focusNodesCarrito
                                  .removeAt(index); // <-- Elimina el focusNode
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
