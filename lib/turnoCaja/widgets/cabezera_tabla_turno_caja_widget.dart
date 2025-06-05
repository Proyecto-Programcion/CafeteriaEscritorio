import 'package:flutter/material.dart';

class CabezeraTablaTurnoCajaWidget extends StatelessWidget {
  const CabezeraTablaTurnoCajaWidget({super.key});

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
            flex: 2,
            child: Text(
              'Administrador',
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
              'Fecha de inicio',
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
              'apertura de caja',
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
              'fecha de cierre',
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
              'cierre de caja',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Estado',
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
              'Total de ventas sin descuento',
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
              'Total de ventas con descuento',
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
