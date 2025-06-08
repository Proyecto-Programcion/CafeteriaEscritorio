import 'package:cafe/logica/controlGastos/controllers/obtenerGananciasController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafe/common/enums.dart';

class GananciasPorCategoriaScreen extends StatelessWidget {
  GananciasPorCategoriaScreen({super.key});

  final gastosPorCategoriaController = Get.put(ObtenerGastosPorCategoriaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0E6),
      appBar: AppBar(
        title: const Text("Gastos por Categoría"),
        backgroundColor: const Color(0xFF9B7B22),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Obx(() {
          if (gastosPorCategoriaController.estado.value == Estado.carga) {
            return const Center(child: CircularProgressIndicator());
          }
          final gastos = gastosPorCategoriaController.listaGastoPorCategoria;
          if (gastos.isEmpty) {
            return const Center(
              child: Text(
                "No hay gastos registrados",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final total = gastos.fold<double>(0.0, (sum, item) => sum + item.totalGasto);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 32),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: Color(0xFF9B7B22), size: 32),
                      const SizedBox(width: 18),
                      const Text(
                        "Gasto Total:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        "\$${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9B7B22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Gastos por Categoría",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: gastos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final item = gastos[idx];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF9B7B22).withOpacity(0.12),
                        child: const Icon(Icons.category, color: Color(0xFF9B7B22)),
                      ),
                      title: Text(
                        item.nombreCategoria,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        "\$${item.totalGasto.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Color(0xFF9B7B22),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}