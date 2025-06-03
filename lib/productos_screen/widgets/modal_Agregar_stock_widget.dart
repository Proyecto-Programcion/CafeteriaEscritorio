import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/controllers/aumentar_stock_producto_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ModalAgregarStockWidget extends StatelessWidget {
  final int idProducto;
  final String nombreProducto;
  final String unidadDeMedida;
  final double stockActual;
  ModalAgregarStockWidget(
      {super.key,
      required this.idProducto,
      required this.nombreProducto,
      required this.unidadDeMedida, required this.stockActual});

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController cantidadController = TextEditingController();

  final AumentarStockProductoController aumentarStockProductoController =
      Get.put(AumentarStockProductoController());

  void AgregarStock(BuildContext context) {
    if (formKey.currentState!.validate()) {
      final cantidad = double.tryParse(cantidadController.text);
      aumentarStockProductoController.aumentarStockProducto(
          idProducto, cantidad!, stockActual, unidadDeMedida);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        width: 400,
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Text(
              'Agregar Stock',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Agrerega la cantidad de stock que deseas agregar al producto en ${unidadDeMedida}.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Producto: $nombreProducto',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Form(
              key: formKey,
              child: TextFormField(
                controller: cantidadController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Cantidad',
                ),
                keyboardType: TextInputType.number,
                validator: (context) {
                  if (context == null || context.isEmpty) {
                    return 'Por favor ingresa una cantidad';
                  }
                  final cantidad = int.tryParse(context);
                  if (cantidad == null || cantidad <= 0) {
                    return 'Ingresa un número válido mayor a 0';
                  }
                  return null;
                },
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => AgregarStock(context),
                  child: const Text('Agregar'),
                ),
              ],
            ),
           
          ],
        ),
      ),
    );
  }
}
