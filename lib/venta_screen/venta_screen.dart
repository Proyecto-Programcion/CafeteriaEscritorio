// En venta_screen.dart (actualizado)
import 'dart:convert';
import 'dart:io';

import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/controllers/buscador_productos_controller.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:cafe/logica/promociones/promocion_producto_gratis_modelo.dart';
import 'package:cafe/logica/venta/controllers/realizar_venta_controller.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:cafe/venta_screen/widgets/cabezera_tabla_carrito_venta.dart';
import 'package:cafe/venta_screen/widgets/modal_realizar_Venta.dart';
import 'package:cafe/venta_screen/widgets/producto_seleccionado_fila_widget.dart';
import 'package:cafe/venta_screen/metodos_impresora.dart'; // NUEVO IMPORT
import 'package:cafe/venta_screen/widgets/modal_confirmar_impresion.dart'; // AGREGAR ESTE IMPORT
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // YA NO NECESITAMOS _verificarImpresoraWindows() aquí porque se hace en el singleton
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    for (final focusNode in focusNodesCarrito) {
      focusNode.dispose();
    }
    focusNodesCarrito.clear();
    super.dispose();
  }

  void cargarProductos() async {
    await obtenerProductosControllers.obtenerProductos();
    if (mounted) {
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
        setState(() {
          productosFiltrados = List<ProductoModelo>.from(
              obtenerProductosControllers.listaProductos);
        });
      }
    } else {
      await buscadorProductosController.obtenerProductos(query);
      if (mounted) {
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

  Future<void> realizarVenta(
      int? idCliente,
      int? idPromocion,
      int? idPromocionProductoGratis,
      PromocionProductoGratiConNombreDelProductosModelo?
          promocionProductoGratis,
      double descuentoPromocion) async {
    realizarVentaController.sincronizarCarrito(carrito);
    print('el descuento promocion es: $descuentoPromocion');
    
    // GUARDAR LOS DATOS ANTES DE LA VENTA (por si se limpian después)
    final carritoParaImprimir = List<ProductoCarrito>.from(carrito);
    final totalVentaParaImprimir = totalVenta;
    final totalDescuentoParaImprimir = totalDescuento;
    
    final exito = await realizarVentaController.realizarVenta(
      idCliente: idCliente,
      idPromocion: idPromocion,
      idPromocionProductosGratis: idPromocionProductoGratis,
      promocionProductoGratis: promocionProductoGratis,
      descuentoPromocionAplicado: descuentoPromocion,
    );

    if (exito) {
      // LIMPIAR CARRITO PRIMERO (para que la UI se actualice)
      if (mounted) {
        setState(() {
          carrito.clear();
          selectedIndexes.clear();
          for (final focusNode in focusNodesCarrito) {
            focusNode.dispose();
          }
          focusNodesCarrito.clear();
        });
      }

      // MOSTRAR MENSAJE DE ÉXITO
      if (mounted) {
        Get.snackbar(
          '¡Venta exitosa!',
          'La venta se ha completado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(8),
        );
      }

      // AHORA MOSTRAR MODAL DE IMPRESIÓN CON LOS DATOS GUARDADOS
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.print, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Imprimir Ticket'),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¿Deseas imprimir el ticket de la venta?'),
                  SizedBox(height: 16),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No Imprimir'),
                ),
                TextButton(
                   child: Text('Imprimir'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    
                    try {
                      // USAR LOS DATOS GUARDADOS PARA IMPRIMIR
                      await AdminImpresora.imprimirTicket(
                        carrito: carritoParaImprimir, // Usar la copia guardada
                        totalVenta: totalVentaParaImprimir, // Usar el total guardado
                        descuento: totalDescuentoParaImprimir, // Usar el descuento guardado
                        promocionDescuento: descuentoPromocion,
                      );
                      
                      if (mounted) {
                        Get.snackbar(
                          'Impresión enviada',
                          'El ticket se ha enviado a la impresora',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blue.withOpacity(0.8),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(8),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        Get.snackbar(
                          'Error de impresión',
                          'No se pudo imprimir: $e',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange.withOpacity(0.8),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(8),
                        );
                      }
                    }
                  },
                 
                ),
              ],
            );
          },
        );
      }

      cargarProductos();
    } else {
      if (mounted) {
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

    return Obx(() {
      if (realizarVentaController.estado.value == Estado.carga) {
        return const Center(child: CircularProgressIndicator());
      }
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
                  Row(
                    children: [
                      const Text(
                        'LISTA DE PRODUCTOS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 153, 103, 8),
                        ),
                      ),
                      const Spacer(),
                      // SIMPLIFICADO: Solo un botón para opciones de impresión
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.print),
                        iconSize: 30,
                        color: const Color.fromARGB(255, 153, 103, 8),
                      ),
                    ],
                  ),
                  // SIMPLIFICADO: Mostrar estado de la impresora
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Buscar articulo por nombre o codigo de barras:',
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// PARTE DE LISTAR PRODUCTOS SELECCIONADOS
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
                                  if (mounted) {
                                    setState(() {
                                      final yaEnCarrito = carrito.indexWhere(
                                        (e) =>
                                            e.producto.idProducto ==
                                            producto.idProducto,
                                      );
                                      if (yaEnCarrito >= 0) {
                                        carrito.removeAt(yaEnCarrito);
                                        focusNodesCarrito[yaEnCarrito]
                                            .dispose();
                                        focusNodesCarrito.removeAt(yaEnCarrito);
                                        selectedIndexes.remove(index);
                                      } else {
                                        carrito.add(ProductoCarrito(
                                            producto: producto));
                                        focusNodesCarrito.add(FocusNode());
                                        selectedIndexes.add(index);
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (mounted &&
                                              focusNodesCarrito.isNotEmpty) {
                                            focusNodesCarrito.last
                                                .requestFocus();
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
                                        onIrAPagar: (usuario,
                                            idPromocion,
                                            idProductoGratis,
                                            promocionProductoGratis,
                                            descuentoPromocion) async {
                                          // Actualizar firma

                                          await realizarVenta(
                                              usuario?.idCliente,
                                              idPromocion,
                                              idProductoGratis,
                                              promocionProductoGratis,
                                              descuentoPromocion);
                                        },
                                      ),
                                    );
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 5),
                              decoration: BoxDecoration(
                                color: carrito.isEmpty
                                    ? Colors.grey
                                    : Colors.black,
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
                                setState(() {
                                  item.cantidad = nuevaCantidad;
                                });
                              }
                            },
                            onRemove: () {
                              if (mounted) {
                                setState(() {
                                  final idx = productosFiltrados.indexWhere(
                                      (p) =>
                                          p.idProducto ==
                                          item.producto.idProducto);
                                  if (idx >= 0) selectedIndexes.remove(idx);
                                  carrito.removeAt(index);
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
    });
  }
}
