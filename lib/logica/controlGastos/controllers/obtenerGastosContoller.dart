import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/controlGastos/controlGastosModel.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerGastosController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxList<GastoModelo> listaGastos = <GastoModelo>[].obs;

  @override
  void onInit() {
    super.onInit();
    obtenerGastos();
  }

  Future<void> obtenerGastos() async {
    try {
      estado.value = Estado.carga;

      // SELECT con JOIN para traer el nombre de la categoría
      final sql = Sql.named('''
        SELECT 
          g.idgasto AS "idGasto",
          g.idcategoria AS "idCategoria",
          g.descripcion,
          g.monto,
          g.fechagasto AS "fechaGasto",
          g.metodopago AS "metodoPago",
          g.notas,
          g.ubicacion,
          c.nombre AS "nombreCategoria"
        FROM controlGastos g
        INNER JOIN categoriaControlGastos c ON c.idcategoria = g.idcategoria
        ORDER BY g.idgasto DESC;
      ''');

      final resp = await Database.conn.execute(sql);
      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];

      listaGastos.value = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        // Debug: imprime el map para ver los tipos y valores
        // print("GASTO MAP: $map");
        return GastoModelo.fromMap(map);
      }).toList();

      estado.value = Estado.exito;
    } catch (e) {
      print('Error al obtener gastos: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener gastos: $e';
    }
  }
}