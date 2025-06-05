import 'package:flutter/material.dart';


class CabezeraTablaVentasWidget extends StatelessWidget {
  const CabezeraTablaVentasWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: 50,
      color: const Color.fromARGB(255, 244, 244, 244),
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'Folio',
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
              'Fecha de venta',
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
              'Administrador de caja',
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
              'Total de venta sin descuento',
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
              'Descuento aplicado',
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
              'Total de venta con descuento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
