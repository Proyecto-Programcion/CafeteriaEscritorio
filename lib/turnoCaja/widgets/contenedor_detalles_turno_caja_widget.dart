import 'package:cafe/logica/turnoCaja/turno_caja_modelo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ContenedorDetallesTurnoCajaWidget extends StatelessWidget {
  const ContenedorDetallesTurnoCajaWidget({
    super.key,
    required this.turnoCaja,
  });

  final TurnoCajaModelo turnoCaja;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width * 1 - 40,
          height: 170,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 210, 174, 101),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Contenedor para mantener juntos los textos del administrador
                  Row(
                    children: [
                      Text(
                        'Administrador:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        turnoCaja.nombreUsuario,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
    
                  // Container personalizado para el estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: turnoCaja.estado == 'Activo'
                          ? Colors.green.withOpacity(0.7)
                          : Colors.red.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          turnoCaja.estado == 'Activo'
                              ? Icons.lock_open
                              : Icons.lock,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          turnoCaja.estado == 'Activo'
                              ? 'Caja Abierta'
                              : 'Caja Cerrada',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        'Fecha de apertura de la caja:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        ' ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(turnoCaja.fechaInicio))}',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Row(
                    children: [
                      Text(
                        'Monto de apertura:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '\$${turnoCaja.montoApertura.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        'Numero de ventas realizadas: ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${turnoCaja.numeroVentas}',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Row(
                    children: [
                      Text(
                        'Total de las ventas sin descuento :',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '\$${turnoCaja.totalVentas}',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Row(
                    children: [
                      Text(
                        'Total de descuento aplicado: ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${turnoCaja.descuentoAplicado}',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Row(
                    children: [
                      Text(
                        'Total de ventas con el descuento aplicado: ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${turnoCaja.totalVentasConDescuento}',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        'Fecha del cierre de la caja:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        turnoCaja.fechaFin != null
                            ? ' ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(turnoCaja.fechaFin!))}'
                            : 'N/A',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Row(
                    children: [
                      Text(
                        'Monto de cierre de caja:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '\$${turnoCaja.montoApertura.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
