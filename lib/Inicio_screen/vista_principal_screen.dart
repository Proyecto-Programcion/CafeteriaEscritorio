import 'package:cafe/Inicio_screen/widgets/tarjeta_de_informacion_rapida_widget.dart';
import 'package:cafe/logica/clientes/controllers/obtenerClientes.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:cafe/logica/venta/controllers/realizar_venta_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final productosController = Get.put(ObtenerProductosControllers());
  final clientesController = Get.put(ObtenerClientesController());
final ventaController = Get.put(RealizarVentaController());


  @override
  void initState() {
    super.initState();
    productosController.obtenerTotalProductos();
    clientesController.obtenerTotalClientes();
    ventaController.obtenerTotalVentas();
    ventaController.obtenerIngresoTotalDelMes();
  }
List<Map<String, String>> get listaInformacionRapida {
  return [
    {
      'titulo': 'Productos',
      'informacion': productosController.totalProductos.value.toString(),
      'urlLocalImage': 'assets/images/productos.png',
    },
    {
      'titulo': 'Total Ventas',
      'informacion': ventaController.totalVentas.value.toString(),
      'urlLocalImage': 'assets/images/ventas.png',
    },
    {
      'titulo': 'Clientes',
      'informacion': clientesController.totalClientes.value.toString(),
      'urlLocalImage': 'assets/images/clientes.png',
    },
    {
      'titulo': 'Historico Ingresos',
      'informacion': ventaController.ventaTotalMes.value.toString(),
      'urlLocalImage': 'assets/images/ingresos.png',
    },
  ];
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INICIO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 153, 103, 8),
                      ),
                    ),
                    Text(
                      'Sucursal: Centro',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 153, 103, 8),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: Obx(() {
                return Wrap(
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  children: List.generate(listaInformacionRapida.length, (index) {
                    final informacion = listaInformacionRapida[index]['informacion'] ?? '';
                    final titulo = listaInformacionRapida[index]['titulo'] ?? '';
                    final urlLocalImage = listaInformacionRapida[index]['urlLocalImage'] ?? '';
                    return TarjetaDeInformacionRapidaWidgets(
                      informacion: informacion,
                      titulo: titulo,
                      imagenUrl: urlLocalImage,
                    );
                  }),
                );
              }),

                  ),
                  const SizedBox(height: 50),
                  Container(
                    width: double.infinity,
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.7,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: LineChart(mainData()),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

LineChartData mainData() {
  return LineChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 1,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Color(0xFF00BCD4), // Cyan
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return const FlLine(
          color: Color(0xFFFFC107), // AmberAccent
          strokeWidth: 1,
        );
      },
    ),
    titlesData: FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 42,
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: Color(0xFF37434D)), // Azul grisáceo
    ),
    minX: 0,
    maxX: 11,
    minY: 0,
    maxY: 6,
    lineBarsData: [
      LineChartBarData(
        spots: const [
          FlSpot(0, 3),
          FlSpot(2.6, 2),
          FlSpot(4.9, 5),
          FlSpot(6.8, 3.1),
          FlSpot(8, 4),
          FlSpot(9.5, 3),
          FlSpot(11, 4),
        ],
        isCurved: true,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFEB3B), // Amarillo
            Color(0xFFFFEB3B), // Amarillo (mismo color para línea sólida)
          ],
        ),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF9C4), // Amarillo claro
              Color(0x00FFF9C4), // Amarillo claro transparente
            ],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    ],
  );
}
