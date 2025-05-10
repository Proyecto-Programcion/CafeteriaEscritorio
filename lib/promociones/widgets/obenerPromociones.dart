import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/promociones/promocionModel.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerPromocionesController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;
  RxList<Promocion> listaPromociones = <Promocion>[].obs;
  RxString filtro = ''.obs;

  List<Promocion> get promocionesFiltradas {
    final f = filtro.value.trim().toLowerCase();
    if (f.isEmpty) return listaPromociones;
    return listaPromociones.where((p) =>
      (p.nombrePromocion).toLowerCase().contains(f) ||
      (p.descripcion).toLowerCase().contains(f)
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    obtenerPromociones();
  }

  Future<void> obtenerPromociones() async {
    try {
      estado.value = Estado.carga;
      mensaje.value = '';

      final sql = Sql.named('''
        SELECT 
          id_promocion,
          nombrePromocion,
          descripcion,
          porcentaje,
          comprasNecesarias,
          status
        FROM promocion
        ORDER BY id_promocion DESC;
      ''');

      final resp = await Database.conn.execute(sql);

      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];

      final promociones = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        // Puedes quitar el print si ya no necesitas debug
        // print('PROMO FETCH: $map');
        return Promocion.fromMap(map);
      }).toList();

      listaPromociones.value = promociones;

      estado.value = Estado.exito;
      mensaje.value = 'Promociones obtenidas correctamente';
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener promociones: ${e.toString()}';
      print('[ERROR] $e');
    }
  }
}