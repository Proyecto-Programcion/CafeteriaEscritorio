import 'dart:convert';

import 'package:cafe/logica/productos/controllers/eliminar_producto_controller.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:cafe/productos_screen/widgets/modal_Agregar_stock_widget.dart';
import 'package:cafe/productos_screen/widgets/modal_editar_producto_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class FilaTablaProductoWidget extends StatelessWidget {
  final ProductoModelo producto;
  final int index;
  final void Function(int) actualizarImagen;

  const FilaTablaProductoWidget({
    super.key,
    required this.producto,
    required this.index,
    required this.actualizarImagen,
  });

  Color esDivisible() {
    if (index % 2 == 0) {
      return const Color.fromARGB(255, 255, 255, 255); // blanco
    } else {
      return const Color.fromARGB(255, 244, 244, 244); // RGB(244,244,244)
    }
  }

  void eliminarProducto(BuildContext context) async {
    final EliminarProductoController eliminarProductoController = Get.put(
      EliminarProductoController(),
    );
    final eliminado =
        await eliminarProductoController.eliminarProducto(producto.idProducto);
    if (eliminado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto eliminado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: esDivisible(),
      width: double.infinity,
      height: 110,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '${index}',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                producto.nombre,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                producto.nombreCategoria,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${producto.precio}',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${producto.descuento}',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                producto.codigoDeBarras ?? '',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${producto.cantidad} - ${producto.unidadMedida}',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color.fromARGB(103, 158, 158, 158),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: (producto.urlImagen != null &&
                      producto.urlImagen?.isNotEmpty == true)
                  ? Image.memory(base64Decode(producto.urlImagen!),
                      fit: BoxFit.scaleDown)
                  : InkWell(
                      onTap: () {
                        // Aquí puedes abrir tu modal para subir imagen
                        actualizarImagen(producto.idProducto);
                      },
                      child: const Center(
                        child: Icon(Icons.add, size: 48, color: Colors.white),
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //----------------------------------------- BOTON EDITAR ----------------------------------
                  IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return ModalEditarProducto(
                              idProducto: producto.idProducto,
                              idCategoria: producto.idCategoria,
                              nombre: producto.nombre,
                              descripcion: producto.descripcion ?? '',
                              codigoDeBarras: producto.codigoDeBarras ?? '',
                              categoria: 'categoria',
                              costo: producto.costo ?? 0,
                              precio: producto.precio,
                              cantidad: producto.cantidad,
                              unidadMedida: producto.unidadMedida ?? '',
                              imgBase64: producto.urlImagen ?? '',
                              descuento: producto.descuento ?? 0,
                            );
                          });
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  //----------------------------------------- BOTNON ELIMINAR ----------------------------------
                  IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Eliminar producto'),
                              content: const Text(
                                  '¿Estás seguro de que deseas eliminar este producto? ya no podras usarlo nunca mas'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Acción al presionar "Cancelar"
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    eliminarProducto(context);
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  //
                  IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return ModalAgregarStockWidget(
                              idProducto: producto.idProducto,
                              nombreProducto: producto.nombre,
                              unidadDeMedida: producto.unidadMedida ?? '',
                              stockActual: producto.cantidad,
                            );
                          });
                    },
                    icon: const Icon(Icons.inventory),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
