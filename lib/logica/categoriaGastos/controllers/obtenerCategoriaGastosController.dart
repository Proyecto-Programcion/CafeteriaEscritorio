import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/categoriaGastos/categoriaGastosModel.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerCategoriasGastosController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxList<CategoriaControlGastosModelo> listaCategorias = <CategoriaControlGastosModelo>[].obs;

  @override
  void onInit() {
    super.onInit();
    obtenerCategorias();
  }

  Future<void> obtenerCategorias() async {
    try {
      estado.value = Estado.carga;

      // ¡AQUÍ EL CAMBIO IMPORTANTE! 
      final sql = Sql.named('''
        SELECT idcategoria AS "idCategoria", nombre, descripcion
        FROM categoriaControlGastos
        ORDER BY idcategoria ASC;
      ''');

      final resp = await Database.conn.execute(sql);
    

      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];
      listaCategorias.value = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        return CategoriaControlGastosModelo.fromMap(map);
      }).toList();

      estado.value = Estado.exito;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener categorías: $e';
    }
  }
}