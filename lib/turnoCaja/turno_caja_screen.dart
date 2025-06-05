import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/turnoCaja/controllers/obtener_turnos_caja.dart';
import 'package:cafe/turnoCaja/widgets/cabezera_tabla_turno_caja_widget.dart';
import 'package:cafe/turnoCaja/widgets/fila_tabla_turno_caja_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TurnoCajaScreen extends StatefulWidget {
  const TurnoCajaScreen({super.key});

  @override
  State<TurnoCajaScreen> createState() => _TurnoCajaScreenState();
}

class _TurnoCajaScreenState extends State<TurnoCajaScreen> {
  final ObtenerTurnosCajaController obtenerTurnosCajaController =
      ObtenerTurnosCajaController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obtenerTurnosCajaController.obtenerTurnosCaja();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Turnos de caja',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 153, 103, 8),
            ),
          ),
          const Text(
            'Vizualiza los turnos de caja de los empleados.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 153, 103, 8),
            ),
          ),
          const SizedBox(height: 20),
          const CabezeraTablaTurnoCajaWidget(),
          Obx(() {
            if (obtenerTurnosCajaController.estado.value == Estado.carga) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (obtenerTurnosCajaController.estado.value ==
                Estado.error) {
              return Center(
                child: Text(obtenerTurnosCajaController.mensajeError.value),
              );
            } else if (obtenerTurnosCajaController.estado.value ==
                Estado.exito || obtenerTurnosCajaController.estado.value == Estado.inicio) {
              if (obtenerTurnosCajaController.turnosCaja.isEmpty) {
                return const Center(
                  child: Text('No hay turnos de caja disponibles.'),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: obtenerTurnosCajaController.turnosCaja.length,
                  itemBuilder: (context, index) {
                    final turno = obtenerTurnosCajaController.turnosCaja[index];
                    return FilaTablaTurnoCaja(
                      turnoCaja: turno,
                      index: index,
                    );
                  },
                ),
              );
            }
            return SizedBox.shrink();
          })
        ],
      ),
    );
  }
}
