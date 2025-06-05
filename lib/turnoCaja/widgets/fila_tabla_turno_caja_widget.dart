import 'package:cafe/logica/turnoCaja/controllers/obtener_detalles_turno_caja.dart';
import 'package:cafe/logica/turnoCaja/turno_caja_modelo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class FilaTablaTurnoCaja extends StatelessWidget {
  final TurnoCajaModelo turnoCaja;
  final int index;
  FilaTablaTurnoCaja({
    super.key,
    required this.turnoCaja,
    required this.index,
  });

  Color esDivisible() {
    if (index % 2 == 0) {
      return const Color.fromARGB(255, 255, 255, 255); // blanco
    } else {
      return const Color.fromARGB(255, 244, 244, 244); // RGB(244,244,244)
    }
  }

  bool insIndexOnHover = false;

  indexOnHover(bool value) {
    if (value) {
      return const Color.fromARGB(255, 206, 206, 206); // blanco
    } else {
      return esDivisible();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Aquí puedes agregar la lógica para manejar el tap en la fila
        final ObtenerDetallesTurnoCajaController
            obtenerDetallesTurnoCajaController =
            Get.put(ObtenerDetallesTurnoCajaController());
        obtenerDetallesTurnoCajaController
            .obtenerVentasPorTurno(turnoCaja.idTurnoCaja);
        print('Fila $index seleccionada');
        Navigator.pushNamed(context, '/detalle_turno', arguments: {
          'turnoCaja': turnoCaja, // Envías toda la entidad
        });
      },
      onHover: (value) {
        insIndexOnHover = value;
        // Redibuja el widget para reflejar el cambio de hover
        (context as Element).markNeedsBuild();
      },
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: indexOnHover(insIndexOnHover),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '${turnoCaja.nombreUsuario}',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${turnoCaja.fechaInicio}',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$${turnoCaja.montoApertura}',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${turnoCaja.fechaFin ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                turnoCaja.montoCierre != null
                    ? '\$${turnoCaja.montoCierre}'
                    : 'N/A',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${turnoCaja.estado}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$${turnoCaja.totalVentas}',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$${turnoCaja.totalVentasConDescuento}',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
