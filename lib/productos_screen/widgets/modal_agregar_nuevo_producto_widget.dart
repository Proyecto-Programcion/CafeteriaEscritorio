import 'package:cafe/logica/categorias/controllers/obtener_categorias_controller.dart';
import 'package:cafe/logica/productos/controllers/agregar_producto_controller.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:get/get_core/src/get_main.dart';

class ModalAgregarNuevoProductoWidget extends StatefulWidget {
  ModalAgregarNuevoProductoWidget({
    super.key,
  });

  @override
  State<ModalAgregarNuevoProductoWidget> createState() =>
      _ModalAgregarNuevoProductoWidgetState();
}

class _ModalAgregarNuevoProductoWidgetState
    extends State<ModalAgregarNuevoProductoWidget> {
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

  //Focus nodes para la navegación entre campos
  final FocusNode codigoFocus = FocusNode();
  final FocusNode nombreFocus = FocusNode();
  final FocusNode descripcionFocus = FocusNode();
  final FocusNode categoriaFocus = FocusNode();
  final FocusNode costoFocus = FocusNode();
  final FocusNode precioFocus = FocusNode();
  final FocusNode stockFocus = FocusNode();
  final FocusNode descuentoFocus = FocusNode();
  final FocusNode unidadMedidaFocus = FocusNode();

  final GlobalKey categoriaDropdownKey = GlobalKey();
  final GlobalKey unidadMedidaDropdownKey = GlobalKey();
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

  void agregarNuevoProducto() async {
    if (formKey.currentState!.validate()) {
      print('codigo de barras: ${codigoDeBarraController.text}');
      final AgregarProductoController agregarProductoController =
          Get.put(AgregarProductoController());
      final resp = await agregarProductoController.agregarProducto(
        nombreController.text,
        descripcionController.text,
        codigoDeBarraController.text,
        categoriaController,
        double.parse(
            costoController.text.isEmpty ? '0.0' : costoController.text),
        double.parse(precioController.text),
        double.parse(
            cantidadController.text.isEmpty ? '0.0' : cantidadController.text),
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
            content: Text('Producto agregado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al agregar el producto: ${agregarProductoController.mensaje}'),
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
    super.initState();
    obtenerCategoriasController.obtenerCategorias();

    // Para desplegar automáticamente el dropdown de categoría
    categoriaFocus.addListener(() {
      if (categoriaFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          final dropdownContext = categoriaDropdownKey.currentContext;
          if (dropdownContext != null) {
            GestureDetector? detector;
            void search(Element element) {
              if (element.widget is GestureDetector) {
                detector = element.widget as GestureDetector;
              }
              element.visitChildren(search);
            }

            dropdownContext.visitChildElements(search);
            detector?.onTap?.call();
          }
        });
      }
    });

    // Para desplegar automáticamente el dropdown de unidad de medida
    unidadMedidaFocus.addListener(() {
      if (unidadMedidaFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          final dropdownContext = unidadMedidaDropdownKey.currentContext;
          if (dropdownContext != null) {
            GestureDetector? detector;
            void search(Element element) {
              if (element.widget is GestureDetector) {
                detector = element.widget as GestureDetector;
              }
              element.visitChildren(search);
            }

            dropdownContext.visitChildElements(search);
            detector?.onTap?.call();
          }
        });
      }
    });

    // Solicita el foco al campo de código al abrir el modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codigoFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    // Dispose de los focus nodes
    codigoFocus.dispose();
    nombreFocus.dispose();
    descripcionFocus.dispose();
    categoriaFocus.dispose();
    costoFocus.dispose();
    precioFocus.dispose();
    stockFocus.dispose();
    descuentoFocus.dispose();
    super.dispose();
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
          border:
              Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
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
              mainAxisSize: MainAxisSize
                  .min, // Importante para evitar que ocupe todo el espacio
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
                  'Ingrese el nuevo producto',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                //***********************APARTADO DE LA SELECCION DE IMAGEN E INPUT DE CODIGO DE BARRAS */
                Row(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Alineación para evitar problemas de layout
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
                                    focusNode: codigoFocus,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(nombreFocus),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Expanded(
                      child: (imagenController != '' &&
                              imagenController != 'urlImagen')
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
                          : Container(),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                //***********************INPUT DE NOMBRE*/
                InputNombre(
                  nombreController: nombreController,
                  focusNode: nombreFocus,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(descripcionFocus),
                ),
                const SizedBox(height: 20),
                //***********************INPUT DE DESCRIPCCION*/
                InputDescripccion(
                  descripcion: descripcionController,
                  focusNode: descripcionFocus,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(categoriaFocus),
                ),
                const SizedBox(height: 20),
                //***********************INPUT DE CATEGORIA*/
                InputCategoria(
                  key: categoriaDropdownKey,
                  categoriaController: categoriaController,
                  focusNode: categoriaFocus,
                  onChanged: (value) {
                    cambiarCategoria(value);
                    FocusScope.of(context).requestFocus(costoFocus);
                  },
                ),
                const SizedBox(height: 20),
                //***********************INPUT DE COSTO Y VENTA*/
                InputCostoYVenta(
                  costoController: costoController,
                  precioController: precioController,
                  costoFocus: costoFocus,
                  precioFocus: precioFocus,
                  onCostoSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(precioFocus),
                  onPrecioSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(unidadMedidaFocus),
                ),
                const SizedBox(height: 20),
                //***********************INPUT DE MEDIDA CANTIDAD Y MINIMA*/
                InputMedidaYCantidad(
                  key: unidadMedidaDropdownKey,
                  onChanged: cambiarUnidadMedida,
                  unidadDeMedidaController: unidadMedidaController,
                  cantidadController: cantidadController,
                  unidadMedidaFocus: unidadMedidaFocus,
                  stockFocus: stockFocus,
                  onStockSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(descuentoFocus),
                ),
                const SizedBox(height: 20),
                //***********************BOTON PARA AGREGAR EL Descuento*/
                InputDescuento(
                  decuentoController: descuentoController,
                  focusNode: descuentoFocus,
                  onFieldSubmitted: (_) => agregarNuevoProducto(),
                ),
                //***********************BOTON PARA AGREGAR EL PRODUCTO*/
                const SizedBox(
                    height:
                        30), // En lugar de Spacer() que puede causar problemas
                SizedBox(
                  width: 300,
                  child: InkWell(
                    onTap: () {
                      obtenerCategoriasController.obtenerCategorias();
                      agregarNuevoProducto();
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
                        'Agregar producto',
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
    required this.unidadMedidaFocus, // Nuevo parámetro
    required this.stockFocus,
    this.onStockSubmitted,
  });

  final String unidadDeMedidaController;
  final TextEditingController cantidadController;
  final void Function(String) onChanged;
  final FocusNode unidadMedidaFocus; // Nuevo parámetro
  final FocusNode stockFocus;
  final void Function(String)? onStockSubmitted;

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
            focusNode: unidadMedidaFocus, // Asigna el focusNode aquí
            items: const [
              DropdownMenuItem(value: 'Gramo', child: Text('Gramo')),
              DropdownMenuItem(value: 'Kilo', child: Text('Kilo')),
              DropdownMenuItem(value: 'Pieza', child: Text('Pieza')),
            ],
            onChanged: (value) {
              onChanged(value!);
              // Al seleccionar, pasa el foco al campo de stock
              FocusScope.of(context).requestFocus(stockFocus);
            },
            onTap: () {
              // Opcional: puedes abrir el dropdown automáticamente si lo deseas
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
            // Opcional: puedes manejar eventos de teclado aquí si lo necesitas
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
            focusNode: stockFocus,
            onFieldSubmitted: onStockSubmitted,
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
    required this.costoFocus,
    required this.precioFocus,
    this.onCostoSubmitted,
    this.onPrecioSubmitted,
  });

  final TextEditingController costoController;
  final TextEditingController precioController;
  final FocusNode costoFocus;
  final FocusNode precioFocus;
  final void Function(String)? onCostoSubmitted;
  final void Function(String)? onPrecioSubmitted;

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
            focusNode: costoFocus,
            onFieldSubmitted: onCostoSubmitted,
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
            focusNode: precioFocus,
            onFieldSubmitted: onPrecioSubmitted,
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
  final FocusNode focusNode;
  final void Function(String) onChanged;

  InputCategoria({
    super.key,
    required this.categoriaController,
    required this.focusNode,
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
              focusNode: focusNode,
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
    required this.focusNode,
    this.onFieldSubmitted,
  });

  final TextEditingController nombreController;
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;

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
            focusNode: focusNode,
            onFieldSubmitted: onFieldSubmitted,
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
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;
  const InputDescripccion({
    super.key,
    required this.descripcion,
    required this.focusNode,
    this.onFieldSubmitted,
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
            focusNode: focusNode,
            onFieldSubmitted: onFieldSubmitted,
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
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;
  InputCodigoDeBarraWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
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
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;
  const InputDescuento({
    super.key,
    required this.decuentoController,
    required this.focusNode,
    this.onFieldSubmitted,
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
            focusNode: focusNode,
            onFieldSubmitted: onFieldSubmitted,
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
