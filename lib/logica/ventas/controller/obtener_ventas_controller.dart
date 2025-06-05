import 'dart:math';

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/turnoCaja/venta_turno_modelo.dart';
import 'package:cafe/logica/venta/venta_modelo.dart';
import 'package:cafe/logica/ventas/venta_modelo.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerVentasController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxList<VentaModeloListar> ventasTurnocaja = <VentaModeloListar>[].obs;
  RxString mensajeError = ''.obs;

  // Variables para paginación
  RxInt paginaActual = 1.obs;
  RxInt elementosPorPagina = 10.obs; // Puedes cambiar este valor
  RxInt totalElementos = 0.obs;
  RxInt totalPaginas = 0.obs;

  // Método para obtener ventas con paginación
  Future<void> obtenerVentas({
    int? pagina,
    int? limite,
    String? buscarPorFolio,
  }) async {
    try {
      // Reiniciar el estado y la lista de ventas
      ventasTurnocaja.clear();
      mensajeError.value = '';
      estado.value = Estado.carga;

      // Establecer valores por defecto
      final paginaParam = pagina ?? paginaActual.value;
      final limiteParam = limite ?? elementosPorPagina.value;
      final offset = (paginaParam - 1) * limiteParam;

      // Paso 1: Obtener el total de registros
      await _obtenerTotalRegistros(buscarPorFolio);

      // Paso 2: Obtener los datos paginados
      final sql = Sql.named('''
        SELECT 
            v.id_venta, 
            v.id_promocion, 	
            v.id_promocion_productos_gratis, 
            v.precio_total, 
            v.precio_descuento, 
            v.fecha, 
            v.status_compra, 
            v.descuento_aplicado,
            
            -- Datos del usuario/administrador
            u.nombre AS nombre_usuario,
            
            -- Datos de promoción de descuento
            pd.nombrepromocion AS promocion_descuento_nombre,
            pd.porcentaje AS promocion_descuento_porcentaje,
            
            -- Datos de promoción de producto gratis
            ppg.nombre_promocion AS promocion_gratis_nombre,
            ppg.id_producto AS promocion_gratis_id_producto,
            p.nombre AS promocion_gratis_nombre_producto,
            ppg.cantidad_producto AS promocion_gratis_cantidad
            
        FROM ventas v 
        LEFT JOIN usuarios u ON v.id_usuario = u.id_usuario
        LEFT JOIN promocion pd ON v.id_promocion = pd.id_promocion
        LEFT JOIN promocion_producto_gratis ppg ON v.id_promocion_productos_gratis = ppg.id_promocion_productos_gratis
        LEFT JOIN productos p ON ppg.id_producto = p.id_producto
        ${buscarPorFolio != null ? 'WHERE v.id_venta = @folio' : ''}
        ORDER BY v.fecha DESC
        LIMIT @limite OFFSET @offset;
      ''');

      final parameters = <String, dynamic>{
        'limite': limiteParam,
        'offset': offset,
      };

      if (buscarPorFolio != null) {
        parameters['folio'] = int.tryParse(buscarPorFolio) ?? 0;
      }

      final resp = await Database.conn.execute(sql, parameters: parameters);

      final ventas = resp
          .map((row) => {
                'id_venta': row[0],
                'id_promocion': row[1],
                'id_promocion_productos_gratis': row[2],
                'precio_total': row[3],
                'precio_descuento': row[4],
                'fecha': row[5],
                'status_compra': row[6],
                'descuento_aplicado': row[7],
                'nombre_usuario': row[8],
                'promocion_descuento_nombre': row[9],
                'promocion_descuento_porcentaje': row[10],
                'promocion_gratis_nombre': row[11],
                'promocion_gratis_id_producto': row[12],
                'promocion_gratis_nombre_producto': row[13],
                'promocion_gratis_cantidad': row[14],
              })
          .map((map) => VentaModeloListar.fromMap(map))
          .toList();

      // Actualizar variables de estado
      ventasTurnocaja.value = ventas;
      paginaActual.value = paginaParam;
      elementosPorPagina.value = limiteParam;
      estado.value = Estado.exito;
    } catch (e) {
      print('Error al obtener ventas: $e');
      mensajeError.value = 'Error al obtener ventas: $e';
      estado.value = Estado.error;
      ventasTurnocaja.clear();
    }
  }

// Método privado para obtener el total de registros
  Future<void> _obtenerTotalRegistros(String? buscarPorFolio) async {
    final sqlCount = Sql.named('''
      SELECT COUNT(*) as total
      FROM ventas v
      LEFT JOIN usuarios u ON v.id_usuario = u.id_usuario
      ${buscarPorFolio != null ? 'WHERE v.id_venta = @folio' : ''}
    ''');

    final parametersCount = <String, dynamic>{};
    if (buscarPorFolio != null) {
      parametersCount['folio'] = int.tryParse(buscarPorFolio) ?? 0;
    }

    final respCount =
        await Database.conn.execute(sqlCount, parameters: parametersCount);

    if (respCount.isNotEmpty) {
      totalElementos.value = respCount.first[0] as int;
      totalPaginas.value =
          (totalElementos.value / elementosPorPagina.value).ceil();
    }
  }

  // Métodos de navegación de páginas
  void irAPagina(int pagina) {
    if (pagina >= 1 && pagina <= totalPaginas.value) {
      obtenerVentas(pagina: pagina);
    }
  }

  void paginaSiguiente() {
    if (paginaActual.value < totalPaginas.value) {
      irAPagina(paginaActual.value + 1);
    }
  }

  void paginaAnterior() {
    if (paginaActual.value > 1) {
      irAPagina(paginaActual.value - 1);
    }
  }

  void irAPrimeraPagina() {
    irAPagina(1);
  }

  void irAUltimaPagina() {
    irAPagina(totalPaginas.value);
  }

  // Método para buscar por folio
  void buscarPorFolio(String folio) {
    obtenerVentas(
        pagina: 1, buscarPorFolio: folio.trim().isEmpty ? null : folio);
  }

  // Método para cambiar elementos por página
  void cambiarElementosPorPagina(int nuevosElementos) {
    elementosPorPagina.value = nuevosElementos;
    obtenerVentas(pagina: 1); // Resetear a la primera página
  }

  // Método para limpiar búsqueda
  void limpiarBusqueda() {
    obtenerVentas(pagina: 1);
  }

  // Getters útiles
  bool get hayPaginaAnterior => paginaActual.value > 1;
  bool get hayPaginaSiguiente => paginaActual.value < totalPaginas.value;

  String get infoPaginacion {
    final inicio = (paginaActual.value - 1) * elementosPorPagina.value + 1;
    final fin = min(
        paginaActual.value * elementosPorPagina.value, totalElementos.value);
    return 'Mostrando $inicio-$fin de ${totalElementos.value} registros';
  }

  List<int> get paginasVisibles {
    const rangoVisible = 5;
    final inicio = max(1, paginaActual.value - rangoVisible ~/ 2);
    final fin = min(totalPaginas.value, inicio + rangoVisible - 1);
    return List.generate(fin - inicio + 1, (index) => inicio + index);
  }
}
