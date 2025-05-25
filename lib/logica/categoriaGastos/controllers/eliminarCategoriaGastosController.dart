import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/categoriaGastos/controllers/obtenerCategoriaGastosController.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class EliminarCategoriaGastoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> eliminarCategoria(int idCategoria) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        DELETE FROM categoriaControlGastos
        WHERE idcategoria = @id_categoria;
      ''');

      await Database.conn.execute(sql, parameters: {
        'id_categoria': idCategoria,
      });

      estado.value = Estado.exito;
      final ObtenerCategoriasGastosController categoriasController =
          Get.find<ObtenerCategoriasGastosController>();
      await categoriasController.obtenerCategorias();
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al eliminar la categoría: $e';
      return false;
    }
  }
}