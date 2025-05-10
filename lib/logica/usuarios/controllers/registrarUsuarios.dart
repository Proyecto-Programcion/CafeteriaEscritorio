import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class RegistrarUsuariosController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

Future<void> registrarUsuario({
  required String nombre,
  required String numeroTelefono,
}) async {
  try {
    estado.value = Estado.carga;
    final sql = Sql.named('''
      INSERT INTO clientes (nombre, telefono)
      VALUES (@nombre, @telefono)
    ''');

    await Database.conn.execute(sql, parameters: {
      'nombre': nombre,
      'telefono': numeroTelefono,
    });

    estado.value = Estado.exito;
  } catch (e) {
    estado.value = Estado.error;
    final errorMsg = e.toString();
    if (errorMsg.contains('duplicate key value violates unique constraint')) {
      throw Exception('Ya existe un cliente con ese teléfono.');
    }
    mensaje.value = 'Error al registrar usuario: $e';
    throw Exception('Error al registrar usuario: $e');
  }
}
}