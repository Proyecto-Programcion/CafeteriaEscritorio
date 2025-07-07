import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/logica/categorias/controllers/actualizar_categoria_por_id.dart';
import 'package:cafe/logica/categorias/controllers/agregar_categoria_controller.dart';
import 'package:cafe/logica/categorias/controllers/eliminar_categoria_controller.dart';
import 'package:cafe/logica/categorias/controllers/obtener_categorias_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModalAgregarCategoriasWidget extends StatefulWidget {
  const ModalAgregarCategoriasWidget({super.key});

  @override
  State<ModalAgregarCategoriasWidget> createState() =>
      _ModalAgregarCategoriasWidgetState();
}

class _ModalAgregarCategoriasWidgetState
    extends State<ModalAgregarCategoriasWidget> {
  Color esDivisible(int index) {
    if (index % 2 == 0) {
      return const Color.fromARGB(255, 255, 255, 255); // blanco
    } else {
      return const Color.fromARGB(255, 244, 244, 244); // RGB(244,244,244)
    }
  }

  final ObtenerCategoriasController obtenerCategoriasController =
      Get.put(ObtenerCategoriasController());
  // Clave para el formulario
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyActualizar = GlobalKey<FormState>();

  // Controlador para el campo de texto
  final TextEditingController nombreCategoriaController =
      TextEditingController();
  final TextEditingController nombreCategoriaControllerActualizar =
      TextEditingController();

  void agregarCategoria(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final nombreCategoria = nombreCategoriaController.text;
      final AgregarCategoriaController agregarCategoriaController = Get.put(
        AgregarCategoriaController(),
      );
      final categoriaAgregada = await agregarCategoriaController
          .agregarCategoria(SesionActiva().idUsuario!, nombreCategoria);
      if (categoriaAgregada) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoría agregada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        nombreCategoriaController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(agregarCategoriaController.mensaje.value),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void eliminarCategoria(BuildContext context, int idCategoria) async {
    final EliminarCategoriaController eliminarCategoriaController =
        Get.put(EliminarCategoriaController());
    final categoriaEliminada =
        await eliminarCategoriaController.eliminarCategoria(idCategoria);
    if (categoriaEliminada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoría eliminada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void actualizarCategoria(BuildContext context, int idCategoria) async {
    if (formKeyActualizar.currentState!.validate()) {
      final ActualizarCategoriaPorId actualizarCategoriaPorId =
          Get.put(ActualizarCategoriaPorId());
      final resp = await actualizarCategoriaPorId.actualizarCategoria(
          idCategoria, nombreCategoriaControllerActualizar.text);
      if (resp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoría actualizada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        nombreCategoriaControllerActualizar.clear();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar la categoría'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final FocusNode nombreFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nombreFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    nombreFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        width: 600,
        height: 790,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Text(
                'Agregar Categoría',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: formKey,
                child: TextFormField(
                  focusNode: nombreFocus,
                  controller: nombreCategoriaController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nombre de la categoría',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  agregarCategoria(context);
                },
                child: const Text('Agregar'),
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              const Text(
                'Categorías existentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: double.infinity,
                  height: 480,
                  child: Obx(() {
                    if (obtenerCategoriasController.estado.value ==
                        Estado.carga) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (obtenerCategoriasController.estado.value ==
                        Estado.error) {
                      return Center(
                          child:
                              Text(obtenerCategoriasController.mensaje.value));
                    } else {
                      return ListView.builder(
                          itemCount:
                              obtenerCategoriasController.categorias.length,
                          itemBuilder: (context, index) {
                            final categoria =
                                obtenerCategoriasController.categorias[index];
                            return Container(
                              color: esDivisible(index),
                              width: double.infinity,
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      categoria.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 90,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Actualizar Categoría: ${categoria.nombre}'),
                                                      content: Container(
                                                        width: 700,
                                                        height: 100,
                                                        child: Form(
                                                          key:
                                                              formKeyActualizar,
                                                          child: TextFormField(
                                                            controller:
                                                                nombreCategoriaControllerActualizar,
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Por favor ingrese un nombre';
                                                              }
                                                              return null;
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              labelText:
                                                                  'Nombre de la categoría',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      actions: [
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Cancelar'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            actualizarCategoria(
                                                                context,
                                                                categoria
                                                                    .idCategoria);
                                                          },
                                                          child: const Text(
                                                              'Actualizar'),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              eliminarCategoria(context,
                                                  categoria.idCategoria);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                  })),
            ],
          ),
        ),
      ),
    );
  }
}
