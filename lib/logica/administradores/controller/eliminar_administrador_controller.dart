

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/administradores/controller/listar_administradores_controller.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class EliminarAdministradorController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> eliminarAdministrador(int idUsuario) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        UPDATE usuarios SET statusDespedido = TRUE WHERE id_usuario = @idUsuario;
      ''');

      await Database.conn.execute(sql, parameters: {
        'idUsuario': idUsuario,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Administrador eliminado exitosamente';
      final ListarAdministradoresController listarAdministradoresController =
          Get.find<ListarAdministradoresController>();
      listarAdministradoresController.obtenerAdministradores();
      return true;
    } catch (e) {
      print('Error al eliminar el administrador: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al eliminar el administrador: $e';
      return false;
    }
  }
  
}