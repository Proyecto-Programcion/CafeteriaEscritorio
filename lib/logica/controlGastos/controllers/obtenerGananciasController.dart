import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class GastoPorCategoria {
  final int idCategoria;
  final String nombreCategoria;
  final double totalGasto;

  GastoPorCategoria({
    required this.idCategoria,
    required this.nombreCategoria,
    required this.totalGasto,
  });
}

class ObtenerGastosPorCategoriaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxList<GastoPorCategoria> listaGastoPorCategoria = <GastoPorCategoria>[].obs;

  @override
  void onInit() {
    super.onInit();
    obtenerGastosPorCategoria();
  }

  Future<void> obtenerGastosPorCategoria() async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        SELECT 
          c.idCategoria AS "idCategoria",
          c.nombre AS "nombreCategoria",
          COALESCE(SUM(g.monto), 0) AS "totalGasto"
        FROM categoriaControlGastos c
        LEFT JOIN controlGastos g ON c.idCategoria = g.idCategoria
        GROUP BY c.idCategoria, c.nombre
        ORDER BY "totalGasto" DESC;
      ''');

      final resp = await Database.conn.execute(sql);
      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];

      listaGastoPorCategoria.value = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        return GastoPorCategoria(
          idCategoria: map['idCategoria'] is int
              ? map['idCategoria'] as int
              : int.parse(map['idCategoria'].toString()),
          nombreCategoria: map['nombreCategoria'] ?? '',
          totalGasto: (map['totalGasto'] is num)
              ? (map['totalGasto'] as num).toDouble()
              : double.tryParse(map['totalGasto'].toString()) ?? 0.0,
        );
      }).toList();

      estado.value = Estado.exito;
    } catch (e) {
      print('Error al obtener gastos por categoría: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener gastos por categoría: $e';
    }
  }
}