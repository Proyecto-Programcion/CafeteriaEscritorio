import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/turnoCaja/controllers/obtener_detalles_turno_caja.dart';
import 'package:cafe/logica/turnoCaja/turno_caja_modelo.dart';
import 'package:cafe/turnoCaja/widgets/cabezera_tabla_ventas_turno_caja_widget.dart';
import 'package:cafe/turnoCaja/widgets/contenedor_Detalles_turno_caja_widget.dart';
import 'package:cafe/turnoCaja/widgets/fila_tabla_ventas_turno_caja_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetallesTurnoCajaScreen extends StatelessWidget {
  DetallesTurnoCajaScreen({super.key});
  final ObtenerDetallesTurnoCajaController obtenerDetallesTurnoCajaController =
      Get.find<ObtenerDetallesTurnoCajaController>();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> argumentos =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final TurnoCajaModelo turnoCaja =
        argumentos['turnoCaja'] as TurnoCajaModelo;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del Turno de Caja',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 85, 107, 47),
        iconTheme: const IconThemeData(
          color: Colors.white, // Esto cambia el color del ícono de regreso
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 250, 240, 230),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalles del Turno de Caja',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
              const SizedBox(height: 20),
              ContenedorDetallesTurnoCajaWidget(turnoCaja: turnoCaja),
              const SizedBox(height: 20),
              CabezeraTablaVentasTurnoCaja(),
              Obx(() {
                print(
                    'Estado de la carga: ${obtenerDetallesTurnoCajaController.estado.value}');
                if (obtenerDetallesTurnoCajaController.estado.value ==
                    Estado.carga) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (obtenerDetallesTurnoCajaController.estado.value ==
                    Estado.error) {
                  return Center(
                    child: Text(
                        obtenerDetallesTurnoCajaController.mensajeError.value),
                  );
                } else if (obtenerDetallesTurnoCajaController.estado.value ==
                    Estado.exito) {
                  if (obtenerDetallesTurnoCajaController
                      .ventasTurnocaja.isEmpty) {
                    return const Center(
                      child: Text('No hay ventas registradas para este turno.'),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: obtenerDetallesTurnoCajaController
                          .ventasTurnocaja.length,
                      itemBuilder: (context, index) {
                        final venta = obtenerDetallesTurnoCajaController
                            .ventasTurnocaja[index];
                        return FilaTablaVentasTurnoCajaScreen(index: index, ventaTurnoModel: venta,);
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}
