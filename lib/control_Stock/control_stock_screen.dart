import 'package:cafe/control_Stock/widgets/boton_filtro_control_stock_widgets.dart';
import 'package:flutter/material.dart';

class ControlStockScreen extends StatefulWidget {
  const ControlStockScreen({super.key});

  @override
  State<ControlStockScreen> createState() => _ControlStockScreenState();
}

class _ControlStockScreenState extends State<ControlStockScreen> {
  //variables para manejar el estado de los botones de filtros
  bool botonActualizado = false;
  bool botonVenta = false;
  bool botonAumento = false;
  //logca para manejar el boton de seleccionar fecha
  bool botonFecha = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Control Stock',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 153, 103, 8),
            ),
          ),
          const Text(
            'Vizualiza los cambios de stock de los productos estos las diferentes formas de cambio Actuliazacion, Venta y Aumento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 153, 103, 8),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              BotonFiltroControlStockWidgets(
                  text: "Fecha",
                  isSelected: botonFecha,
                  onTap: () {
                    setState(() {
                      botonFecha = !botonFecha;
                    });
                  }),
              const SizedBox(
                width: 10,
              ),
              BotonFiltroControlStockWidgets(
                  text: "Actualizado",
                  isSelected: botonActualizado,
                  onTap: () {
                    setState(() {
                      botonActualizado = !botonActualizado;
                    });
                  }),
              const SizedBox(
                width: 10,
              ),
              BotonFiltroControlStockWidgets(
                  text: "Venta",
                  isSelected: botonVenta,
                  onTap: () {
                    setState(() {
                      botonVenta = !botonVenta;
                    });
                  }),
              const SizedBox(
                width: 10,
              ),
              BotonFiltroControlStockWidgets(
                  text: "Aumento",
                  isSelected: botonAumento,
                  onTap: () {
                    setState(() {
                      botonAumento = !botonAumento;
                    });
                  }),
            ],
          )
        ],
      ),
    );
  }
}
