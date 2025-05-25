import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class AgregarCategoriaGastosController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> agregarCategoria(
    String nombre,
    String descripcion,
  ) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        INSERT INTO categoriaControlGastos (
          nombre,
          descripcion
        ) VALUES (
          @nombre,
          @descripcion
        );
      ''');

      await Database.conn.execute(sql, parameters: {
        'nombre': nombre,
        'descripcion': descripcion.isEmpty ? null : descripcion,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Categoría agregada exitosamente';
      return true;
    } catch (e) {
      print('Error al agregar categoría: $e');
      if (e.toString().contains('23505:')) {
        mensaje.value = 'El nombre de la categoría ya existe';
        return false;
      } else {
        mensaje.value = 'Error al agregar la categoría: $e';
        return false;
      }
    }
  }
}