import 'dart:convert';

import 'package:cafe/logica/categorias/controllers/obtener_categorias_controller.dart';
import 'package:cafe/logica/productos/controllers/actualizar_producto_controller.dart';
import 'package:cafe/logica/productos/controllers/agregar_producto_controller.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';


class ModalEditarProducto extends StatefulWidget {
  final int idProducto;
  final String nombre;
  final String descripcion;
  final String codigoDeBarras;
  final String categoria;
  final double costo;
  final double precio;
  final double cantidad;
  final String unidadMedida;
  final String imgBase64;
  final int idCategoria;
  final double descuento;

  ModalEditarProducto({
    super.key,
    required this.idProducto,
    required this.nombre,
    required this.descripcion,
    required this.codigoDeBarras,
    required this.categoria,
    required this.costo,
    required this.precio,
    required this.cantidad,
    required this.unidadMedida,
    required this.imgBase64,
    required this.idCategoria,
    required this.descuento,
  });

  @override
  State<ModalEditarProducto> createState() => _ModalEditarProductoState();
}

class _ModalEditarProductoState extends State<ModalEditarProducto> {
  //Controladores para los TextField
  final TextEditingController nombreController = TextEditingController();

  final TextEditingController codigoDeBarraController = TextEditingController();

  final TextEditingController descripcionController = TextEditingController();

  final TextEditingController costoController = TextEditingController();

  final TextEditingController precioController = TextEditingController();

  final TextEditingController cantidadController = TextEditingController();

  final TextEditingController descuentoController = TextEditingController();

  String unidadMedidaController = 'Gramo';

  String categoriaController = '1';

  String imagenController = '';

  //controlador del form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Seleccionar la imagen
  Future<void> selectImage() async {
    XTypeGroup typeGroup = const XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
    );

    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file == null) return;

    setState(() {
      imagenController = file.path;
    });
  }

  void actualizarProducto() async {
    if (formKey.currentState!.validate()) {
      print('codigo de barras: ${codigoDeBarraController.text}');
      final ActualizarProductoController actualizarProductoController =
          Get.put(ActualizarProductoController());
      final resp = await actualizarProductoController.actualizarProducto(
        widget.idProducto,
        nombreController.text,
        descripcionController.text,
        codigoDeBarraController.text,
        categoriaController,
        double.parse(
            costoController.text.isEmpty ? '0.0' : costoController.text),
        double.parse(precioController.text),
        double.parse(cantidadController.text.isEmpty ? '0.0' : cantidadController.text),
        widget.cantidad,
        unidadMedidaController,
        imagenController,
        int.parse(categoriaController),
        double.parse(descuentoController.text.isEmpty
            ? '0.0'
            : descuentoController.text),
      );
      if (resp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto actualizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al actualizar el producto: ${actualizarProductoController.mensaje}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  void cambiarCategoria(String value) {
    categoriaController = value;
  }

  void cambiarUnidadMedida(String value) {
    unidadMedidaController = value;
  }

  //obtener categorias para el dropdown
  final ObtenerCategoriasController obtenerCategoriasController =
      Get.put(ObtenerCategoriasController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obtenerCategoriasController.obtenerCategorias();
    nombreController.text = widget.nombre;
    descripcionController.text = widget.descripcion;
    codigoDeBarraController.text = widget.codigoDeBarras;
    categoriaController = widget.idCategoria.toString();
    costoController.text = widget.costo.toString();
    precioController.text = widget.precio.toString();
    cantidadController.text = widget.cantidad.toString();
    unidadMedidaController = widget.unidadMedida;
    descuentoController.text = widget.descuento.toString();
  }

 @override
Widget build(BuildContext context) {
  return AlertDialog(
    backgroundColor: Colors.transparent,
    content: Container(
      padding: const EdgeInsets.all(20),
      width: 850,
      // Removemos la altura fija para permitir que el contenido determine el tamaño
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Importante para evitar que ocupe todo el espacio
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              const Text(
                'ACTUALIZANDO PRODUCTO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              //***********************APARTADO DE LA SELECCION DE IMAGEN E INPUT DE CODIGO DE BARRAS */
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Alineación para evitar problemas de layout
                children: [
                  Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Imagen',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 70),
                              InkWell(
                                onTap: () {
                                  // Aquí puedes abrir tu modal para subir imagen
                                  selectImage();
                                },
                                child: Container(
                                  width: 160,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        103, 158, 158, 158),
                                    border: Border.all(
                                        color: Colors.black, width: 1),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.add,
                                        size: 30, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 50),
                          Row(
                            children: [
                              const Text(
                                'Codigo',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 70),
                              Expanded(
                                child: InputCodigoDeBarraWidget(
                                  controller: codigoDeBarraController,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  Expanded(
                    child: (imagenController != '')
                        ? SizedBox(
                            width: 120,
                            height: 120,
                            child: Image.file(
                              File(imagenController),
                              fit: BoxFit.scaleDown,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 60),
                            ),
                          )
                        : (widget.imgBase64.isNotEmpty)
                            ? SizedBox(
                                width: 120,
                                height: 120,
                                child: Image.memory(
                                  base64Decode(widget.imgBase64),
                                  fit: BoxFit.scaleDown,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 60),
                                ),
                              )
                            : Container(),
                  )
                ],
              ),
              const SizedBox(height: 20),
              //***********************INPUT DE NOMBRE*/
              InputNombre(nombreController: nombreController),
              const SizedBox(height: 20),
              //***********************INPUT DE DESCRIPCCION*/
              InputDescripccion(descripcion: descripcionController),
              const SizedBox(height: 20),
              //***********************INPUT DE CATEGORIA*/
              InputCategoria(
                categoriaController: categoriaController,
                onChanged: cambiarCategoria,
              ),
              const SizedBox(height: 20),
              //***********************INPUT DE COSTO Y VENTA*/
              InputCostoYVenta(
                  costoController: costoController,
                  precioController: precioController),
              const SizedBox(height: 20),
              //***********************INPUT DE MEDIDA CANTIDAD Y MINIMA*/
              InputMedidaYCantidad(
                onChanged: cambiarUnidadMedida,
                unidadDeMedidaController: unidadMedidaController,
                cantidadController: cantidadController,
              ),
              const SizedBox(height: 20),
              //***********************BOTON PARA AGREGAR EL Descuento*/
              InputDescuento(
                decuentoController: descuentoController,
              ),
              //***********************BOTON PARA ACTUALIZAR EL PRODUCTO*/
              const SizedBox(height: 30), // En lugar de Spacer() que puede causar problemas
              SizedBox(
                width: 300,
                child: InkWell(
                  onTap: () {
                    obtenerCategoriasController.obtenerCategorias();
                    actualizarProducto();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Actualizar producto',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

/////////////////////////////////////////////////////////////////////////////////////// WIDGETS
class InputMedidaYCantidad extends StatelessWidget {
  const InputMedidaYCantidad({
    super.key,
    required this.cantidadController,
    required this.unidadDeMedidaController,
    required this.onChanged,
  });

  final String unidadDeMedidaController;
  final TextEditingController cantidadController;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'Unidad de medida',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 28),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: unidadDeMedidaController,
            items: const [
              DropdownMenuItem(value: 'Gramo', child: Text('Gramo')),
              DropdownMenuItem(value: 'Kilo', child: Text('Kilo')),
              DropdownMenuItem(value: 'Tonelada', child: Text('Tonelada')),
              DropdownMenuItem(value: 'Pieza', child: Text('Pieza')),
            ],
            onChanged: (value) {
              onChanged(value!);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            dropdownColor: Colors.white,
          ),
        ),
        const SizedBox(width: 30),
        const Text(
          'Stock',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 38),
        SizedBox(
          width: 200,
          child: TextFormField(
            controller: cantidadController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            style: const TextStyle(
              backgroundColor: Colors.transparent,
            ),
          ),
        )
      ],
    );
  }
}

class InputCostoYVenta extends StatelessWidget {
  const InputCostoYVenta({
    super.key,
    required this.costoController,
    required this.precioController,
  });

  final TextEditingController costoController;
  final TextEditingController precioController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Costo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 30),
        SizedBox(
          width: 200,
          child: TextFormField(
            controller: costoController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            style: const TextStyle(
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        const SizedBox(width: 30),
        const Text(
          'Precio',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 30),
        SizedBox(
          width: 200,
          child: TextFormField(
            controller: precioController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese un precio';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            style: const TextStyle(
              backgroundColor: Colors.transparent,
            ),
          ),
        )
      ],
    );
  }
}

class InputCategoria extends StatelessWidget {
  final String categoriaController;
  final void Function(String) onChanged;

  InputCategoria({
    super.key,
    required this.categoriaController,
    required this.onChanged,
  });

  final ObtenerCategoriasController obtenerCategoriasController =
      Get.put(ObtenerCategoriasController());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Categoria',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 47),
        Expanded(
          child: Obx(() {
            final items = obtenerCategoriasController.dropdownItems;
            return DropdownButtonFormField<String>(
              value: categoriaController,
              items: items,
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              dropdownColor: Colors.white,
            );
          }),
        )
      ],
    );
  }
}

class InputNombre extends StatelessWidget {
  const InputNombre({
    super.key,
    required this.nombreController,
  });

  final TextEditingController nombreController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Nombre',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          child: TextFormField(
            controller: nombreController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese un nombre';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            style: const TextStyle(
              backgroundColor: Colors.transparent,
            ),
          ),
        )
      ],
    );
  }
}

class InputDescripccion extends StatelessWidget {
  final TextEditingController descripcion;
  const InputDescripccion({
    super.key,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          child: TextFormField(
            controller: descripcion,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            style: const TextStyle(
              backgroundColor: Colors.transparent,
            ),
          ),
        )
      ],
    );
  }
}

class InputCodigoDeBarraWidget extends StatelessWidget {
  final TextEditingController controller;
  InputCodigoDeBarraWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: const TextStyle(
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class InputDescuento extends StatelessWidget {
  final TextEditingController decuentoController;
  const InputDescuento({
    super.key,
    required this.decuentoController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Descuento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 48),
        Expanded(
          child: TextFormField(
            controller: decuentoController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            style: const TextStyle(
              backgroundColor: Colors.transparent,
            ),
          ),
        )
      ],
    );
  }
}
