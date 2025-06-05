import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/ventas/controller/obtener_ventas_controller.dart';
import 'package:cafe/venta_screen/widgets/cabezera_tabla_ventas_widget.dart';
import 'package:cafe/venta_screen/widgets/fila_tabla_ventas_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerVentasScreen extends StatefulWidget {
  const VerVentasScreen({super.key});

  @override
  State<VerVentasScreen> createState() => _VerVentasScreenState();
}

class _VerVentasScreenState extends State<VerVentasScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ObtenerVentasController obtenerVentasController = Get.put(
    ObtenerVentasController(),
  );

  @override
  void initState() {
    super.initState();
    obtenerVentasController.obtenerVentas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _buscarVentas() {
    final folio = _searchController.text.trim();
    if (folio.isNotEmpty) {
      obtenerVentasController.buscarPorFolio(folio);
    } else {
      obtenerVentasController.limpiarBusqueda();
    }
  }

  void _limpiarBusqueda() {
    _searchController.clear();
    obtenerVentasController.limpiarBusqueda();
  }

  // Nuevo método para refrescar
  void _refrescarVentas() {
    _searchController.clear(); // Limpiar el campo de búsqueda
    obtenerVentasController.obtenerVentas(); // Recargar todas las ventas desde la primera página
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ventas',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 153, 103, 8),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visualiza todas las ventas realizadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 153, 103, 8),
            ),
          ),
          const SizedBox(height: 20),

          // Barra de búsqueda
          Row(
            children: [
              // Buscador
              Container(
                width: 400, // Ancho fijo de 400px
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar por folio',
                          hintText: 'Ingrese el número de folio',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color.fromARGB(255, 153, 103, 8),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _limpiarBusqueda,
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 153, 103, 8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 153, 103, 8),
                              width: 2,
                            ),
                          ),
                        ),
                        onFieldSubmitted: (_) => _buscarVentas(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _buscarVentas,
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Buscar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 85, 107, 47),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16), // Espaciado entre el buscador y el botón de refrescar
              
              // Botón de refrescar
              ElevatedButton.icon(
                onPressed: _refrescarVentas,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: const Text(
                  'Refrescar',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 85, 107, 47),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Información de paginación
          Obx(() => obtenerVentasController.estado.value == Estado.exito
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    obtenerVentasController.infoPaginacion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 153, 103, 8),
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          // Tabla de ventas
          CabezeraTablaVentasWidget(),

          // Lista de ventas
          Expanded(
            child: Obx(() {
              if (obtenerVentasController.estado.value == Estado.carga) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 85, 107, 47),
                  ),
                );
              } else if (obtenerVentasController.estado.value == Estado.error) {
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
                        obtenerVentasController.mensajeError.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => obtenerVentasController.obtenerVentas(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              } else if (obtenerVentasController.estado.value == Estado.exito) {
                if (obtenerVentasController.ventasTurnocaja.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Color.fromARGB(255, 153, 103, 8),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay ventas disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 153, 103, 8),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: obtenerVentasController.ventasTurnocaja.length,
                  itemBuilder: (context, index) {
                    final venta = obtenerVentasController.ventasTurnocaja[index];
                    return FilaTablaVentasWidget(
                      index: index,
                      ventaModeloListar: venta,
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            }),
          ),

          // Controles de paginación
          Obx(() => obtenerVentasController.estado.value == Estado.exito &&
                  obtenerVentasController.totalPaginas.value > 1
              ? _buildPaginacionControles()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildPaginacionControles() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón primera página
          IconButton(
            onPressed: obtenerVentasController.hayPaginaAnterior
                ? obtenerVentasController.irAPrimeraPagina
                : null,
            icon: const Icon(Icons.first_page),
            tooltip: 'Primera página',
          ),

          // Botón página anterior
          IconButton(
            onPressed: obtenerVentasController.hayPaginaAnterior
                ? obtenerVentasController.paginaAnterior
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
          ),

          // Números de página
          ...obtenerVentasController.paginasVisibles.map((pagina) {
            final esActual = pagina == obtenerVentasController.paginaActual.value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: esActual
                    ? const Color.fromARGB(255, 85, 107, 47)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => obtenerVentasController.irAPagina(pagina),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$pagina',
                      style: TextStyle(
                        color: esActual
                            ? Colors.white
                            : const Color.fromARGB(255, 85, 107, 47),
                        fontWeight: esActual ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),

          // Botón página siguiente
          IconButton(
            onPressed: obtenerVentasController.hayPaginaSiguiente
                ? obtenerVentasController.paginaSiguiente
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Página siguiente',
          ),

          // Botón última página
          IconButton(
            onPressed: obtenerVentasController.hayPaginaSiguiente
                ? obtenerVentasController.irAUltimaPagina
                : null,
            icon: const Icon(Icons.last_page),
            tooltip: 'Última página',
          ),
        ],
      ),
    );
  }
}
