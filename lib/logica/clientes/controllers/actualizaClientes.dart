import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class EditarClienteController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<void> editarNombreCliente({
    required int idCliente,
    required String nuevoNombre,
  }) async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        UPDATE clientes
        SET nombre = @nombre
        WHERE id_cliente = @id_cliente
      ''');

      await Database.conn.execute(sql, parameters: {
        'nombre': nuevoNombre,
        'id_cliente': idCliente,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Nombre actualizado correctamente.';
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al actualizar el nombre: $e';
      throw Exception('Error al actualizar el nombre: $e');
    }
  }
}