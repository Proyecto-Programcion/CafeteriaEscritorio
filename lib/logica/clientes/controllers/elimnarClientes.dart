import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class EliminarClienteController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<void> eliminarCliente({
    required int idCliente,
  }) async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
      DELETE FROM clientes
      WHERE id_cliente = @id_cliente
    ''');

      final result = await Database.conn.execute(sql, parameters: {
        'id_cliente': idCliente,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Cliente eliminado correctamente.';
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al eliminar cliente: $e';
      print('[EliminarClienteController] Error: $e');
      throw Exception('Error al eliminar cliente: $e');
    }
  }
}
