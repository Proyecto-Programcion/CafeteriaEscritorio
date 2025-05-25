import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/categoriaGastos/controllers/obtenerCategoriaGastosController.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ActualizarCategoriaGastoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> actualizarCategoria({
    required int idCategoria,
    required String nombre,
    required String descripcion,
  }) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        UPDATE categoriaControlGastos
        SET nombre = @nombre,
            descripcion = @descripcion
        WHERE idcategoria = @idcategoria;
      ''');

      await Database.conn.execute(sql, parameters: {
        'idcategoria': idCategoria,
        'nombre': nombre,
        'descripcion': descripcion,
      });

      estado.value = Estado.exito;
      // actualiza la lista de categorías después de editar
      final ObtenerCategoriasGastosController cats = Get.find<ObtenerCategoriasGastosController>();
      await cats.obtenerCategorias();
      return true;
    } catch (e) {
      print('Error al actualizar la categoría: $e');
      mensaje.value = 'Ocurrió un error al actualizar la categoría: $e';
      estado.value = Estado.error;
      return false;
    }
  }
}