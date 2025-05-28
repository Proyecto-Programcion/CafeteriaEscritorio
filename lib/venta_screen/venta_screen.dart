// En venta_screen.dart (actualizado)
import 'dart:convert';

import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/controllers/buscador_productos_controller.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:cafe/logica/promociones/promocion_producto_gratis_modelo.dart';
import 'package:cafe/logica/venta/controllers/realizar_venta_controller.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:cafe/venta_screen/widgets/cabezera_tabla_carrito_venta.dart';
import 'package:cafe/venta_screen/widgets/modal_realizar_Venta.dart';
import 'package:cafe/venta_screen/widgets/producto_seleccionado_fila_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Controladores GetX
  final RealizarVentaController realizarVentaController =
      Get.put(RealizarVentaController());
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

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); // Remover listener
    _searchController.dispose();

    // Limpiar todos los FocusNode
    for (final focusNode in focusNodesCarrito) {
      focusNode.dispose();
    }
    focusNodesCarrito.clear();

    super.dispose();
  }

  void cargarProductos() async {
    await obtenerProductosControllers.obtenerProductos();
    if (mounted) {
      // Verificar si está montado
      setState(() {
        productosFiltrados = List<ProductoModelo>.from(
            obtenerProductosControllers.listaProductos);
      });
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      if (mounted) {
        // Verificar si está montado
        setState(() {
          productosFiltrados = List<ProductoModelo>.from(
              obtenerProductosControllers.listaProductos);
        });
      }
    } else {
      await buscadorProductosController.obtenerProductos(query);
      if (mounted) {
        // Verificar si está montado
        setState(() {
          productosFiltrados = List<ProductoModelo>.from(
              buscadorProductosController.listaProductos);
        });
      }
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

  // Método para realizar la venta usando el controlador
  Future<void> realizarVenta(
      int? idCliente, 
      int? idPromocion, 
      int? idPromocionProductoGratis,
      PromocionProductoGratiConNombreDelProductosModelo? promocionProductoGratis) async {
    // Sincronizar el carrito con el controlador
    realizarVentaController.sincronizarCarrito(carrito);

    // Realizar la venta
    final exito = await realizarVentaController.realizarVenta(
        idCliente: idCliente,
        idPromocion: idPromocion,
        idPromocionProductosGratis: idPromocionProductoGratis,
        promocionProductoGratis: promocionProductoGratis, // Pasar la promoción completa
    );

    if (exito) {
      // Limpiar el carrito local
      if (mounted) {
        // Verificar si está montado
        setState(() {
          carrito.clear();
          selectedIndexes.clear();
          // Limpiar los FocusNode antes de limpiar la lista
          for (final focusNode in focusNodesCarrito) {
            focusNode.dispose();
          }
          focusNodesCarrito.clear();
        });
      }

      // Mostrar mensaje de éxito
      if (mounted) {
        // Verificar si está montado
        Get.snackbar(
          '¡Venta exitosa!',
          'La venta se ha completado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(8),
        );
      }

      // Recargar productos para actualizar el inventario en pantalla
      cargarProductos();
    } else {
      // Mostrar mensaje de error
      if (mounted) {
        // Verificar si está montado
        Get.snackbar(
          'Error',
          realizarVentaController.mensaje.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(8),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalVenta = carrito.fold<double>(
      0,
      (suma, item) =>
          suma +
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
                        return const Center(child: CircularProgressIndicator());
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
                                if (mounted) {
                                  // Verificar si está montado
                                  setState(() {
                                    final yaEnCarrito = carrito.indexWhere(
                                      (e) =>
                                          e.producto.idProducto ==
                                          producto.idProducto,
                                    );
                                    if (yaEnCarrito >= 0) {
                                      carrito.removeAt(yaEnCarrito);
                                      // Dispose del FocusNode antes de removerlo
                                      focusNodesCarrito[yaEnCarrito].dispose();
                                      focusNodesCarrito.removeAt(yaEnCarrito);
                                      selectedIndexes.remove(index);
                                    } else {
                                      carrito.add(
                                          ProductoCarrito(producto: producto));
                                      focusNodesCarrito.add(FocusNode());
                                      selectedIndexes.add(index);
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (mounted &&
                                            focusNodesCarrito.isNotEmpty) {
                                          focusNodesCarrito.last.requestFocus();
                                        }
                                      });
                                    }
                                  });
                                }
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
                          'Descuento: \$${descuento.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: carrito.isEmpty
                              ? null
                              : () async {
                                  // Modificamos para usar el ModalRealizarVenta y realizar la venta
                                  await showDialog(
                                    context: context,
                                    builder: (context) => ModalRealizarVenta(
                                      totalVenta: totalVenta,
                                      descuento: descuento,
                                      carrito: carrito,
                                      onIrAPagar: (usuario, idPromocion,
                                          idProductoGratis, promocionProductoGratis) async { // Actualizar la firma
                                        // Aquí usamos el controlador para realizar la venta
                                        await realizarVenta(usuario?.idCliente,
                                            idPromocion, idProductoGratis, promocionProductoGratis);
                                      },
                                    ),
                                  );
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  carrito.isEmpty ? Colors.grey : Colors.black,
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
                            if (mounted) {
                              // Verificar si está montado
                              setState(() {
                                item.cantidad = nuevaCantidad;
                              });
                            }
                          },
                          onRemove: () {
                            if (mounted) {
                              // Verificar si está montado
                              setState(() {
                                final idx = productosFiltrados.indexWhere((p) =>
                                    p.idProducto == item.producto.idProducto);
                                if (idx >= 0) selectedIndexes.remove(idx);
                                carrito.removeAt(index);
                                // Dispose del FocusNode antes de removerlo
                                focusNodesCarrito[index].dispose();
                                focusNodesCarrito.removeAt(index);
                              });
                            }
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
