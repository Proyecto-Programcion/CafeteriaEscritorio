import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerControlStockPorFecha extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxList<Map<String, dynamic>> controlStockPorFecha = <Map<String, dynamic>>[].obs;
  RxString mensaje = ''.obs;
  
  // Variables para paginación
  RxInt totalRegistros = 0.obs;
  RxInt paginaActual = 1.obs;
  RxInt registrosPorPagina = 20.obs;
  RxInt totalPaginas = 0.obs;

  Future<void> obtenerControlStockPorFecha(
    DateTime fechaInicio, 
    DateTime fechaFin, 
    int limit, 
    int offset
  ) async {
    try {
      estado.value = Estado.carga;
      
      final sql = Sql.named('''
        SELECT 
            id AS id_controlstock, 
            controlstock.id_producto,
            cantidad_antes,
            cantidad_movimiento,
            cantidad_despues,
            productos.unidad_medida,
            categoria,
            productos.nombre AS nombre_producto,
            usuarios.nombre AS nombre_usuario,
            usuarios.rol,
            controlstock.fecha
        FROM controlstock 
        INNER JOIN productos ON controlstock.id_producto = productos.id_producto
        INNER JOIN usuarios ON controlstock.id_usuario = usuarios.id_usuario
        WHERE DATE(controlstock.fecha) BETWEEN @fechaInicio AND @fechaFin
        ORDER BY controlstock.fecha DESC
        LIMIT @limit OFFSET @offset;
      ''');

      final resp = await Database.conn.execute(sql, parameters: {
        'fechaInicio': fechaInicio.toIso8601String().split('T')[0], // YYYY-MM-DD
        'fechaFin': fechaFin.toIso8601String().split('T')[0],       // YYYY-MM-DD
        'limit': limit,
        'offset': offset,
      });

      // Obtener nombres de columnas
      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];

      // Mapear cada fila a Map<String, dynamic>
      controlStockPorFecha.value = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        return map;
      }).toList();

      estado.value = Estado.exito;
      mensaje.value = 'Datos obtenidos correctamente';
      
    } catch (e) {
      mensaje.value = 'Error al obtener los datos: $e';
      estado.value = Estado.error;
      print('Error en obtenerControlStockPorFecha: $e');
    }
  }

  // Método para obtener el total de registros para la paginación
  Future<void> obtenerTotalRegistros(DateTime fechaInicio, DateTime fechaFin) async {
    try {
      final sql = Sql.named('''
        SELECT COUNT(*) AS total
        FROM controlstock 
        INNER JOIN productos ON controlstock.id_producto = productos.id_producto
        INNER JOIN usuarios ON controlstock.id_usuario = usuarios.id_usuario
        WHERE DATE(controlstock.fecha) BETWEEN @fechaInicio AND @fechaFin;
      ''');

      final resp = await Database.conn.execute(sql, parameters: {
        'fechaInicio': fechaInicio.toIso8601String().split('T')[0],
        'fechaFin': fechaFin.toIso8601String().split('T')[0],
      });

      if (resp.isNotEmpty) {
        totalRegistros.value = resp.first[0] as int;
        totalPaginas.value = (totalRegistros.value / registrosPorPagina.value).ceil();
      } else {
        totalRegistros.value = 0;
        totalPaginas.value = 0;
      }
      
    } catch (e) {
      print('Error al obtener total de registros: $e');
      totalRegistros.value = 0;
      totalPaginas.value = 0;
    }
  }

  // Método para cargar datos con paginación
  Future<void> cargarDatosPaginados(DateTime fechaInicio, DateTime fechaFin, int pagina) async {
    paginaActual.value = pagina;
    int offset = (pagina - 1) * registrosPorPagina.value;
    
    // Primero obtener el total
    await obtenerTotalRegistros(fechaInicio, fechaFin);
    
    // Luego obtener los datos de la página
    await obtenerControlStockPorFecha(
      fechaInicio, 
      fechaFin, 
      registrosPorPagina.value, 
      offset
    );
  }

  // Método para ir a una página específica
  void irAPagina(int nuevaPagina, DateTime fechaInicio, DateTime fechaFin) {
    if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
      cargarDatosPaginados(fechaInicio, fechaFin, nuevaPagina);
    }
  }

  // Método para obtener todos los registros (sin filtro de fecha)
  Future<void> obtenerTodosLosRegistros(int limit, int offset) async {
    try {
      estado.value = Estado.carga;
      
      final sql = Sql.named('''
        SELECT 
            id AS id_controlstock, 
            controlstock.id_producto,
            cantidad_antes,
            cantidad_movimiento,
            cantidad_despues,
            productos.unidad_medida,
            categoria,
            productos.nombre AS nombre_producto,
            usuarios.nombre AS nombre_usuario,
            usuarios.rol,
            controlstock.fecha
        FROM controlstock 
        INNER JOIN productos ON controlstock.id_producto = productos.id_producto
        INNER JOIN usuarios ON controlstock.id_usuario = usuarios.id_usuario
        ORDER BY controlstock.fecha DESC
        LIMIT @limit OFFSET @offset;
      ''');

      final resp = await Database.conn.execute(sql, parameters: {
        'limit': limit,
        'offset': offset,
      });

      // Obtener nombres de columnas
      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];

      // Mapear cada fila a Map<String, dynamic>
      controlStockPorFecha.value = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        return map;
      }).toList();

      estado.value = Estado.exito;
      mensaje.value = 'Datos obtenidos correctamente';
      
    } catch (e) {
      mensaje.value = 'Error al obtener los datos: $e';
      estado.value = Estado.error;
      print('Error en obtenerTodosLosRegistros: $e');
    }
  }

  // Método para obtener total sin filtro
  Future<void> obtenerTotalRegistrosSinFiltro() async {
    try {
      final sql = Sql.named('''
        SELECT COUNT(*) AS total
        FROM controlstock 
        INNER JOIN productos ON controlstock.id_producto = productos.id_producto
        INNER JOIN usuarios ON controlstock.id_usuario = usuarios.id_usuario;
      ''');

      final resp = await Database.conn.execute(sql);

      if (resp.isNotEmpty) {
        totalRegistros.value = resp.first[0] as int;
        totalPaginas.value = (totalRegistros.value / registrosPorPagina.value).ceil();
      } else {
        totalRegistros.value = 0;
        totalPaginas.value = 0;
      }
      
    } catch (e) {
      print('Error al obtener total de registros sin filtro: $e');
      totalRegistros.value = 0;
      totalPaginas.value = 0;
    }
  }

  // Método para ir a página sin filtro
  void irAPaginaSinFiltro(int nuevaPagina) {
    if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
      paginaActual.value = nuevaPagina;
      int offset = (nuevaPagina - 1) * registrosPorPagina.value;
      obtenerTodosLosRegistros(registrosPorPagina.value, offset);
    }
  }

  // Método para filtrar por categorías con fechas opcionales
  Future<void> filtrarPorCategorias({
    List<String> categorias = const [],
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      estado.value = Estado.carga;
      
      String whereClause = '';
      Map<String, dynamic> parametros = {
        'limit': limit,
        'offset': offset,
      };

      // Construir WHERE clause
      List<String> condiciones = [];

      // Filtro de fechas si se proporciona
      if (fechaInicio != null && fechaFin != null) {
        condiciones.add('DATE(controlstock.fecha) BETWEEN @fechaInicio AND @fechaFin');
        parametros['fechaInicio'] = fechaInicio.toIso8601String().split('T')[0];
        parametros['fechaFin'] = fechaFin.toIso8601String().split('T')[0];
      }

      // Filtro de categorías
      if (categorias.isNotEmpty) {
        String categoriasCondicion = categorias.map((cat) => "'$cat'").join(', ');
        condiciones.add('controlstock.categoria IN ($categoriasCondicion)');
      }

      if (condiciones.isNotEmpty) {
        whereClause = 'WHERE ${condiciones.join(' AND ')}';
      }

      final sql = Sql.named('''
        SELECT 
            id AS id_controlstock, 
            controlstock.id_producto,
            cantidad_antes,
            cantidad_movimiento,
            cantidad_despues,
            productos.unidad_medida,
            categoria,
            productos.nombre AS nombre_producto,
            usuarios.nombre AS nombre_usuario,
            usuarios.rol,
            controlstock.fecha
        FROM controlstock 
        INNER JOIN productos ON controlstock.id_producto = productos.id_producto
        INNER JOIN usuarios ON controlstock.id_usuario = usuarios.id_usuario
        $whereClause
        ORDER BY controlstock.fecha DESC
        LIMIT @limit OFFSET @offset;
      ''');

      final resp = await Database.conn.execute(sql, parameters: parametros);

      // Obtener nombres de columnas
      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];

      // Mapear cada fila a Map<String, dynamic>
      controlStockPorFecha.value = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        return map;
      }).toList();

      estado.value = Estado.exito;
      mensaje.value = 'Datos obtenidos correctamente';
      
    } catch (e) {
      mensaje.value = 'Error al obtener los datos: $e';
      estado.value = Estado.error;
      print('Error en filtrarPorCategorias: $e');
    }
  }

  // Método para obtener total de registros con filtros de categoría
  Future<void> obtenerTotalRegistrosConFiltros({
    List<String> categorias = const [],
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      String whereClause = '';
      Map<String, dynamic> parametros = {};

      // Construir WHERE clause
      List<String> condiciones = [];

      // Filtro de fechas si se proporciona
      if (fechaInicio != null && fechaFin != null) {
        condiciones.add('DATE(controlstock.fecha) BETWEEN @fechaInicio AND @fechaFin');
        parametros['fechaInicio'] = fechaInicio.toIso8601String().split('T')[0];
        parametros['fechaFin'] = fechaFin.toIso8601String().split('T')[0];
      }

      // Filtro de categorías
      if (categorias.isNotEmpty) {
        String categoriasCondicion = categorias.map((cat) => "'$cat'").join(', ');
        condiciones.add('controlstock.categoria IN ($categoriasCondicion)');
      }

      if (condiciones.isNotEmpty) {
        whereClause = 'WHERE ${condiciones.join(' AND ')}';
      }

      final sql = Sql.named('''
        SELECT COUNT(*) AS total
        FROM controlstock 
        INNER JOIN productos ON controlstock.id_producto = productos.id_producto
        INNER JOIN usuarios ON controlstock.id_usuario = usuarios.id_usuario
        $whereClause;
      ''');

      final resp = await Database.conn.execute(sql, parameters: parametros);

      if (resp.isNotEmpty) {
        totalRegistros.value = resp.first[0] as int;
        totalPaginas.value = (totalRegistros.value / registrosPorPagina.value).ceil();
      } else {
        totalRegistros.value = 0;
        totalPaginas.value = 0;
      }
      
    } catch (e) {
      print('Error al obtener total de registros con filtros: $e');
      totalRegistros.value = 0;
      totalPaginas.value = 0;
    }
  }

  // Método para cargar datos con filtros combinados
  Future<void> cargarDatosConFiltros({
    List<String> categorias = const [],
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int pagina = 1,
  }) async {
    paginaActual.value = pagina;
    int offset = (pagina - 1) * registrosPorPagina.value;
    
    // Primero obtener el total
    await obtenerTotalRegistrosConFiltros(
      categorias: categorias,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
    
    // Luego obtener los datos de la página
    await filtrarPorCategorias(
      categorias: categorias,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      limit: registrosPorPagina.value,
      offset: offset,
    );
  }

  // Método para ir a página con filtros
  void irAPaginaConFiltros(
    int nuevaPagina, {
    List<String> categorias = const [],
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
      cargarDatosConFiltros(
        categorias: categorias,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        pagina: nuevaPagina,
      );
    }
  }

  // Limpiar datos
  void limpiarDatos() {
    controlStockPorFecha.clear();
    totalRegistros.value = 0;
    paginaActual.value = 1;
    totalPaginas.value = 0;
    estado.value = Estado.inicio;
    mensaje.value = '';
  }
}