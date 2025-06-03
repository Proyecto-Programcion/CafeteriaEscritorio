import 'package:cafe/control_Stock/widgets/boton_filtro_control_stock_widgets.dart';
import 'package:cafe/logica/controlStock/controllers/obtener_control_stock_por_fecha.dart';
import 'package:cafe/common/enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class ControlStockScreen extends StatefulWidget {
  const ControlStockScreen({super.key});

  @override
  State<ControlStockScreen> createState() => _ControlStockScreenState();
}

class _ControlStockScreenState extends State<ControlStockScreen> {
  // Inicializar el controller
  final ObtenerControlStockPorFecha controller = Get.put(ObtenerControlStockPorFecha());
  
  //variables para manejar el estado de los botones de filtros
  bool botonActualizado = false;
  bool botonVenta = false;
  bool botonAumento = false;
  //logica para manejar el boton de seleccionar fecha
  bool botonFecha = false;

  // Variables para almacenar las fechas seleccionadas
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    _cargarDatosIniciales();
  }

  void _cargarDatosIniciales() {
    // Cargar todos los registros al inicio
    controller.obtenerTodosLosRegistros(controller.registrosPorPagina.value, 0);
    controller.obtenerTotalRegistrosSinFiltro();
  }

  // Aplicar filtros actuales
  void _aplicarFiltros({int pagina = 1}) {
    List<String> categoriasSeleccionadas = [];
    
    if (botonActualizado) categoriasSeleccionadas.add('actualizado');
    if (botonVenta) categoriasSeleccionadas.add('vendido');
    if (botonAumento) categoriasSeleccionadas.add('agregado');

    // Actualizar la página actual en el controller
    controller.paginaActual.value = pagina;

    if (categoriasSeleccionadas.isEmpty && selectedDateRange == null) {
      // Sin filtros, cargar todos
      controller.obtenerTotalRegistrosSinFiltro().then((_) {
        int offset = (pagina - 1) * controller.registrosPorPagina.value;
        controller.obtenerTodosLosRegistros(controller.registrosPorPagina.value, offset);
      });
    } else {
      // Con filtros
      controller.cargarDatosConFiltros(
        categorias: categoriasSeleccionadas,
        fechaInicio: selectedDateRange?.start,
        fechaFin: selectedDateRange?.end,
        pagina: pagina,
      );
    }
  }

  // Método para mostrar el selector de rango de fechas
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 153, 103, 8),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
        botonFecha = true;
      });
      _aplicarFiltros();
    }
  }

  String _getDateRangeText() {
    if (selectedDateRange == null) return "Fecha";
    final start = selectedDateRange!.start;
    final end = selectedDateRange!.end;
    return "${start.year}/${start.month.toString().padLeft(2, '0')}/${start.day.toString().padLeft(2, '0')} - ${end.year}/${end.month.toString().padLeft(2, '0')}/${end.day.toString().padLeft(2, '0')}";
  }

  void _limpiarFiltroFecha() {
    setState(() {
      selectedDateRange = null;
      botonFecha = false;
    });
    _aplicarFiltros();
  }

  // Widget para el paginador
  Widget _buildPaginador() {
    return Obx(() {
      if (controller.totalPaginas.value <= 1) return const SizedBox.shrink();
      
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mostrando ${((controller.paginaActual.value - 1) * controller.registrosPorPagina.value + 1)}-${controller.paginaActual.value * controller.registrosPorPagina.value > controller.totalRegistros.value ? controller.totalRegistros.value : controller.paginaActual.value * controller.registrosPorPagina.value} de ${controller.totalRegistros.value} registros',
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: controller.paginaActual.value > 1 
                    ? () => _irAPagina(1) 
                    : null,
                  icon: const Icon(Icons.first_page),
                  color: const Color.fromARGB(255, 153, 103, 8),
                ),
                IconButton(
                  onPressed: controller.paginaActual.value > 1 
                    ? () => _irAPagina(controller.paginaActual.value - 1) 
                    : null,
                  icon: const Icon(Icons.chevron_left),
                  color: const Color.fromARGB(255, 153, 103, 8),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 153, 103, 8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${controller.paginaActual.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'de ${controller.totalPaginas.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 153, 103, 8),
                  ),
                ),
                IconButton(
                  onPressed: controller.paginaActual.value < controller.totalPaginas.value 
                    ? () => _irAPagina(controller.paginaActual.value + 1) 
                    : null,
                  icon: const Icon(Icons.chevron_right),
                  color: const Color.fromARGB(255, 153, 103, 8),
                ),
                IconButton(
                  onPressed: controller.paginaActual.value < controller.totalPaginas.value 
                    ? () => _irAPagina(controller.totalPaginas.value) 
                    : null,
                  icon: const Icon(Icons.last_page),
                  color: const Color.fromARGB(255, 153, 103, 8),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _irAPagina(int nuevaPagina) {
    _aplicarFiltros(pagina: nuevaPagina);
  }

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
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              BotonFiltroControlStockWidgets(
                text: _getDateRangeText(),
                isSelected: botonFecha,
                onTap: _selectDateRange,
              ),
              if (selectedDateRange != null)
                TextButton.icon(
                  onPressed: _limpiarFiltroFecha,
                  icon: const Icon(Icons.clear,
                      color: Color.fromARGB(255, 153, 103, 8)),
                  label: const Text(
                    'Limpiar filtro de fecha',
                    style: TextStyle(color: Color.fromARGB(255, 153, 103, 8)),
                  ),
                ),
              BotonFiltroControlStockWidgets(
                  text: "Actualizado",
                  isSelected: botonActualizado,
                  onTap: () {
                    setState(() {
                      botonActualizado = !botonActualizado;
                    });
                    _aplicarFiltros();
                  }),
              BotonFiltroControlStockWidgets(
                  text: "Venta",
                  isSelected: botonVenta,
                  onTap: () {
                    setState(() {
                      botonVenta = !botonVenta;
                    });
                    _aplicarFiltros();
                  }),
              BotonFiltroControlStockWidgets(
                  text: "Aumento",
                  isSelected: botonAumento,
                  onTap: () {
                    setState(() {
                      botonAumento = !botonAumento;
                    });
                    _aplicarFiltros();
                  }),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Lista de cambios de stock',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 153, 103, 8),
            ),
          ),
          const SizedBox(height: 10),
          
          // Cabecera de la tabla
          const CabezerTablaControlStock(),
          
          // Lista con Obx dentro de Expanded
          Expanded(
            child: Obx(() {
              // Manejar estados del controller
              if (controller.estado.value == Estado.carga) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 153, 103, 8),
                  ),
                );
              }
              
              if (controller.estado.value == Estado.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${controller.mensaje.value}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDatosIniciales,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }
              
              if (controller.controlStockPorFecha.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Color.fromARGB(255, 153, 103, 8),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay datos para mostrar',
                        style: TextStyle(
                          color: Color.fromARGB(255, 153, 103, 8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // ListView.builder dentro del Expanded
              return ListView.builder(
                itemCount: controller.controlStockPorFecha.length,
                itemBuilder: (context, index) {
                  final registro = controller.controlStockPorFecha[index];
                  return FilaTablaControlStock(
                    index: index,
                    registro: registro,
                  );
                },
              );
            }),
          ),
          
          // Paginador
          _buildPaginador(),
        ],
      ),
    );
  }
}

class FilaTablaControlStock extends StatelessWidget {
  final int index;
  final Map<String, dynamic> registro;
  
  const FilaTablaControlStock({
    super.key, 
    required this.index,
    required this.registro,
  });

  Color esDivisible() {
    if (index % 2 == 0) {
      return const Color.fromARGB(255, 255, 255, 255); // blanco
    } else {
      return const Color.fromARGB(255, 244, 244, 244); // RGB(244,244,244)
    }
  }

  String _getTipoCambio(String? categoria) {
    switch (categoria?.toLowerCase()) {
      case 'agregado':
        return 'Aumento';
      case 'vendido':
        return 'Venta';
      case 'actualizado':
        return 'Actualización';
      default:
        return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: esDivisible(),
     
      ),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Text(
              DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(registro['fecha'].toString())),
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              registro['nombre_usuario']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              _getTipoCambio(registro['categoria']?.toString()),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              registro['nombre_producto']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              registro['cantidad_antes']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              registro['cantidad_movimiento']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              registro['cantidad_despues']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CabezerTablaControlStock extends StatelessWidget {
  const CabezerTablaControlStock({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
     
        borderRadius: BorderRadius.circular(5),
      ),
      width: double.infinity,
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Fecha',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
          Expanded(
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
            child: Text(
              'Tipo de Cambio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
         
            Expanded(
            child: Text(
              'Producto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
             Expanded(
            child: Text(
              'antes del cambio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
            Expanded(
            child: Text(
              'cantidad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          ),
            Expanded(
            child: Text(
              'despues del cambio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 103, 8),
              ),
            ),
          )
        ],
      ),
    );
  }
}
