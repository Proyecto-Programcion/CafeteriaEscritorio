import 'dart:convert';
import 'dart:typed_data';

import 'package:cafe/administradores/widgets/cabezera_tabla_administradores.dart';
import 'package:cafe/administradores/widgets/fila_tabla_administradores.dart';
import 'package:cafe/administradores/widgets/modal_agregar_Administrador.dart';
import 'package:cafe/administradores/widgets/modal_agregar_sucursal.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/administradores/administrador_modelo.dart';
import 'package:cafe/logica/administradores/controller/agregar_administrador_controller.dart';
import 'package:cafe/logica/administradores/controller/eliminar_administrador_controller.dart';
import 'package:cafe/logica/administradores/controller/listar_administradores_controller.dart';
import 'package:cafe/logica/administradores/controller/listar_sucursales_controller.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdministradoresScreen extends StatefulWidget {
  const AdministradoresScreen({super.key});

  @override
  State<AdministradoresScreen> createState() => _AdministradoresScreenState();
}

class _AdministradoresScreenState extends State<AdministradoresScreen> {
  final ListarAdministradoresController listarAdministradoresController =
      Get.put(ListarAdministradoresController());

  final AgregarAdministradorController agregarAdministradorController =
      Get.put(AgregarAdministradorController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listarAdministradoresController.obtenerAdministradores();

      // SOLUCIÓN: Usar ever() para escuchar cambios de estado
      ever(agregarAdministradorController.estado, (Estado estado) {
        if (estado == Estado.exito) {
          Get.snackbar(
            'Éxito',
            'Administrador agregado con éxito',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );

          // Cerrar modal después de un pequeño delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          });

          // Recargar la lista
          listarAdministradoresController.obtenerAdministradores();
        } else if (estado == Estado.error) {
          Get.snackbar(
            'Error',
            'Error al agregar el administrador',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ////***********************************************TITULO DE LA PANTALLA */

          const Text(
            'LISTA DE USUARIOS ADMINISTRADORES',
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
                          return const ModalAgregarAdministrador();
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
                      children: [
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
                      children: [
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
            child: Column(children: [
              const CabezeraTablaAdministradores(),
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
                  if (listarAdministradoresController.administradores.isEmpty) {
                    return const Center(
                      child: Text('No hay administradores registrados'),
                    );
                  }
                  return ListView.builder(
                    itemCount:
                        listarAdministradoresController.administradores.length,
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
              })),
            ]),
          )),
        ]));
  }

  @override
  void dispose() {
    // Limpiar listeners al salir de la pantalla
    super.dispose();
  }
}
