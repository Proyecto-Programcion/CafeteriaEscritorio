import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/logica/administradores/controller/agregar_sucursal_controller.dart';
import 'package:cafe/logica/administradores/controller/listar_sucursales_controller.dart';
import 'package:cafe/logica/categorias/controllers/actualizar_categoria_por_id.dart';
import 'package:cafe/logica/categorias/controllers/agregar_categoria_controller.dart';
import 'package:cafe/logica/categorias/controllers/eliminar_categoria_controller.dart';
import 'package:cafe/logica/categorias/controllers/obtener_categorias_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModalAgregarSucursalWidget extends StatelessWidget {
  ModalAgregarSucursalWidget({super.key});

  Color esDivisible(int index) {
    if (index % 2 == 0) {
      return const Color.fromARGB(255, 255, 255, 255); // blanco
    } else {
      return const Color.fromARGB(255, 244, 244, 244); // RGB(244,244,244)
    }
  }

  final ListarSucursalesController listarSucursalesController =
      Get.put(ListarSucursalesController());
  // Clave para el formulario
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyActualizar = GlobalKey<FormState>();

  // Controlador para el campo de texto
  final TextEditingController nombreSucursalController =
      TextEditingController();
  final TextEditingController direccionSucursalController =
      TextEditingController();
  final TextEditingController nombreSucursalControllerActualizar =
      TextEditingController();

  void agregarCategoria(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final AgregarSucursalController agregarSucursalController = Get.put(
        AgregarSucursalController(),
      );
      final categoriaAgregada = await agregarSucursalController.agregarSucursal(
        nombreSucursalController.text,
        direccionSucursalController.text,
      );

      if (categoriaAgregada) {
        nombreSucursalController.clear();
        direccionSucursalController.clear();
        listarSucursalesController.obtenerSucursales();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sucursal  agregada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        nombreSucursalController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(agregarSucursalController.mensaje.value),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void eliminarCategoria(BuildContext context, int idCategoria) async {
   
  }

  void actualizarCategoria(BuildContext context, int idCategoria) async {
   
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        width: 600,
        height: 860,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Text(
                'Agregar sucursal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nombreSucursalController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese un nombre';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nombre de la sucursal',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: direccionSucursalController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una dirección';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Direccion de la sucursal',
                        ),
                      ),
                    ],
                  )),
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
                'Sucursales  existentes',
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
                    if (listarSucursalesController.estado.value ==
                        Estado.carga) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (listarSucursalesController.estado.value ==
                        Estado.error) {
                      return const Center(
                          child: Text(
                              'A ocurrdio un erro al untentar obtener las sucrsales'));
                    } else if (listarSucursalesController.sucursales.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aún no hay sucursales agregadas',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: listarSucursalesController.sucursales.length,
                        itemBuilder: (context, index) {
                          final sucursal = listarSucursalesController.sucursales[index];
                          return Container(
                            color: esDivisible(index),
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Info de la sucursal alineada a la izquierda
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sucursal.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20, // Más grande el nombre
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Direccion:  ${sucursal.direccion}',
                                      style: const TextStyle(
                                        fontSize: 15, // Más pequeño y sin bold
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                // Botones de acción alineados a la derecha
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Actualizar sucursal: ${sucursal.nombre}'),
                                              content: Container(
                                                width: 700,
                                                height: 100,
                                                child: Form(
                                                  key: formKeyActualizar,
                                                  child: TextFormField(
                                                    controller: nombreSucursalControllerActualizar,
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
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    actualizarCategoria(
                                                        context, sucursal.idSucursal);
                                                  },
                                                  child: const Text('Actualizar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        eliminarCategoria(context, sucursal.idSucursal);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  })),
            ],
          ),
        ),
      ),
    );
  }
}
