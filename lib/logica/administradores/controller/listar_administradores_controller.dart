import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/administradores/administrador_modelo.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ListarAdministradoresController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxList<AdministradorModelo> administradores = <AdministradorModelo>[].obs;

  Future<bool> obtenerAdministradores() async {
    administradores.clear();
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
     SELECT 
        u.id_usuario,
        u.nombre,
        u.correo,
        u.telefono,
        u.imagen,
        u.rol,
        u.statusDespedido,
        u.idSucursal,
        s.nombre AS nombre_sucursal
      FROM usuarios u
      LEFT JOIN sucursales s ON u.idSucursal = s.id_sucursal
      WHERE u.statusDespedido = FALSE ;
    ''');
      final result = await Database.conn.execute(sql);
      administradores.value = result
          .map((e) => AdministradorModelo.fromMap(e.toColumnMap()))
          .toList();
      estado.value = Estado.exito;
      return true;
    } catch (e) {
      print('Error al obtener administradores: $e');
      estado.value = Estado.error;
      return false;
    }
  }
}
