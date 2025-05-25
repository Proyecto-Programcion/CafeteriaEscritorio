import 'dart:convert';
import 'dart:typed_data';

import 'package:cafe/administradores/widgets/modal_agregar_Administrador.dart';
import 'package:cafe/administradores/widgets/modal_agregar_sucursal.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/administradores/administrador_modelo.dart';
import 'package:cafe/logica/administradores/controller/eliminar_administrador_controller.dart';
import 'package:cafe/logica/administradores/controller/listar_administradores_controller.dart';
import 'package:cafe/logica/administradores/controller/listar_sucursales_controller.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AdministradoresScreen extends StatefulWidget {
  const AdministradoresScreen({super.key});

  @override
  State<AdministradoresScreen> createState() => _AdministradoresScreenState();
}

class _AdministradoresScreenState extends State<AdministradoresScreen> {
  final ListarAdministradoresController listarAdministradoresController =
      Get.put(ListarAdministradoresController());

  @override
  void initState() {
    // TODO: implement initState
    listarAdministradoresController.obtenerAdministradores();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ////***********************************************TITULO DE LA PANTALLA */

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
          ////***********************************************BOTON PARA AGREGAR UN NUEVO PRODUCTO */
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    // Acción al presionar
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ModalAgregarAdministrador();
                        });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.person_add, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          'Agregar nuevo administrador',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {
                    final ListarSucursalesController
                        listarSucursalesController =
                        Get.put(ListarSucursalesController());
                    listarSucursalesController.obtenerSucursales();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ModalAgregarSucursalWidget();
                        });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.person_add, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          'Agregar Sucursal',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: const Color.fromARGB(255, 0, 0, 0), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CabezeraTablaAdministradores(),
                Expanded(child: Obx(() {
                  if (listarAdministradoresController.estado.value ==
                      Estado.carga) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (listarAdministradoresController.estado.value ==
                      Estado.error) {
                    return const Center(
                      child: Text('Error al cargar los administradores'),
                    );
                  }
                  if (listarAdministradoresController.estado.value ==
                      Estado.exito) {
                    if (listarAdministradoresController
                        .administradores.isEmpty) {
                      return const Center(
                        child: Text('No hay administradores registrados'),
                      );
                    }
                    return ListView.builder(
                      itemCount: listarAdministradoresController
                          .administradores.length,
                      itemBuilder: (context, index) {
                        print(listarAdministradoresController
                            .administradores[index].imagen);
                        return RowTablaAdministradores(
                          administradorModelo: listarAdministradoresController
                              .administradores[index],
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }))
              ],
            ),
          )),
        ]));
  }
}

class CabezeraTablaAdministradores extends StatelessWidget {
  const CabezeraTablaAdministradores({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 50,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "N°",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'Imagen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "Nombre completo°",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                child: Text(
                  "Telefono",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "Corre",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "Sucursal",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "Tipo",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "Accion",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class RowTablaAdministradores extends StatelessWidget {
  final AdministradorModelo administradorModelo;
  RowTablaAdministradores({
    super.key,
    required this.administradorModelo,
  });

    // Método para convertir base64 a Uint8List
  Uint8List _base64ToUint8List(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error al decodificar base64: $e');
      return Uint8List(0); // Retorna array vacío si hay error
    }
  }


  void eliminarAdministrador() async{
    final EliminarAdministradorController eliminarAdministradorController =
        Get.put(EliminarAdministradorController());
    final resp = await eliminarAdministradorController.eliminarAdministrador(
        administradorModelo.idUsuario);
    if (resp) {
      Get.snackbar(
        'Administrador Despedido',
        'El administrador ha sido despedido correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error al despedir',
        'No se pudo despedir el administrador',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 82,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "${administradorModelo.idUsuario}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (administradorModelo.imagen != null &&
                            administradorModelo.imagen!.isNotEmpty)
                        ? MemoryImage(
                            _base64ToUint8List(administradorModelo.imagen!))
                        : null,
                    child: (administradorModelo.imagen == null ||
                            administradorModelo.imagen!.isEmpty)
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 32)
                        : null,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "${administradorModelo.nombre}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
               Expanded(
                flex: 3,
                child: Center(
                child: Text(
                  "${administradorModelo.telefono}",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              )),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "${administradorModelo.correo ?? 'No tiene'}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "${administradorModelo.nombreSucursal}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "${administradorModelo.rol}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Acción para modificar
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          eliminarAdministrador();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
