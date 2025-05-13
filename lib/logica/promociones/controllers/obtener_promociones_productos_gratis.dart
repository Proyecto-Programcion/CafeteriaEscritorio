import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/promociones/promocionModel.dart';
import 'package:cafe/logica/promociones/promocion_producto_gratis_modelo.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerPromocionesProductosGratisController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;
  RxList<PromocionProductoGratiConNombreDelProductosModelo> listaPromociones =
      <PromocionProductoGratiConNombreDelProductosModelo>[].obs;

  @override
  void onInit() {
    super.onInit();
    obtenerPromociones();
  }

  Future<void> obtenerPromociones() async {
    try {
      //limpiar lista
      listaPromociones.clear();
      estado.value = Estado.carga;
      mensaje.value = '';

     final sql = Sql.named('''
      SELECT 
        promocion_producto_gratis.*, 
        productos.nombre AS nombre_producto,
        productos.unidad_medida AS unidad_de_medida_producto
      FROM promocion_producto_gratis
      JOIN productos ON promocion_producto_gratis.id_producto = productos.id_producto 
      WHERE promocion_producto_gratis.eliminado = false
      ORDER BY id_promocion_productos_gratis DESC;
    ''');

      final resp = await Database.conn.execute(sql);

      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];

      final promociones = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        // Puedes quitar el print si ya no necesitas debug
        print('PROMO FETCH PROMOCIONES PRODUCTOS GRATIS: $map');
        return PromocionProductoGratiConNombreDelProductosModelo.fromMap(map);
      }).toList();

      listaPromociones.value = promociones;

      estado.value = Estado.exito;
      mensaje.value = 'Promociones obtenidas correctamente';
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value =
          'Error al obtener promociones productos gratis: ${e.toString()}';
      print('[ERROR productos gratis] $e');
    }
  }
}
