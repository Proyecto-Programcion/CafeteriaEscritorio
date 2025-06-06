// En venta_screen.dart (actualizado)
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  
  // Para impresora Serial/USB
  List<String> _availablePrinters = [];
  String? _selectedPrinter;

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
    _buscarImpresoras();
  }

  // Buscar impresoras disponibles en el sistema
  Future<void> _buscarImpresoras() async {
    try {
      if (Platform.isWindows) {
        // En Windows, buscar impresoras instaladas
        final result = await Process.run('wmic', ['printer', 'get', 'name']);
        final lines = result.stdout.toString().split('\n');
        
        setState(() {
          _availablePrinters = lines
              .where((line) => line.trim().isNotEmpty && !line.contains('Name'))
              .map((line) => line.trim())
              .where((name) => name.isNotEmpty)
              .toList();
        });
      } else {
        // Para Linux/Mac, diferentes comandos
        setState(() {
          _availablePrinters = ['Impresora predeterminada'];
        });
      }
    } catch (e) {
      print('Error buscando impresoras: $e');
      setState(() {
        _availablePrinters = ['Impresora predeterminada'];
      });
    }
  }

  // Mostrar modal para seleccionar impresora
  Future<void> _mostrarSelectorImpresora() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Impresora'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona una impresora:'),
            const SizedBox(height: 16),
            if (_availablePrinters.isEmpty)
              const Text('No se encontraron impresoras')
            else
              ...(_availablePrinters.map((printer) => ListTile(
                    title: Text(printer),
                    leading: Radio<String>(
                      value: printer,
                      groupValue: _selectedPrinter,
                      onChanged: (value) {
                        setState(() {
                          _selectedPrinter = value;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _buscarImpresoras,
            child: const Text('Buscar de nuevo'),
          ),
        ],
      ),
    );
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

  // Método para realizar la venta - MODIFICADO para incluir impresión
  Future<void> realizarVenta(
      int? idCliente,
      int? idPromocion,
      int? idPromocionProductoGratis,
      PromocionProductoGratiConNombreDelProductosModelo?
          promocionProductoGratis,
      double descuentoPromocion) async {

    realizarVentaController.sincronizarCarrito(carrito);

    final exito = await realizarVentaController.realizarVenta(
      idCliente: idCliente,
      idPromocion: idPromocion,
      idPromocionProductosGratis: idPromocionProductoGratis,
      promocionProductoGratis: promocionProductoGratis,
      descuentoPromocionAplicado: descuentoPromocion,
    );

    if (exito) {
      // NUEVO: Preguntar si desea imprimir el ticket
      final bool? imprimirTicket = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Venta exitosa'),
          content: const Text('¿Deseas imprimir el ticket?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí, imprimir'),
            ),
          ],
        ),
      );

      if (imprimirTicket == true) {
        
      }

      // Limpiar el carrito local
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

      // Mostrar mensaje de éxito
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
                      // NUEVO: Botón para configurar impresora
                      IconButton(
                        onPressed: _mostrarSelectorImpresora,
                        icon: const Icon(Icons.print),
                        tooltip: 'Configurar impresora',
                        iconSize: 30,
                        color: const Color.fromARGB(255, 153, 103, 8),
                      ),
                    ],
                  ),
                  if (_selectedPrinter != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Impresora: $_selectedPrinter',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
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
