import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class IniciarSesionController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensajeError = ''.obs;

  Future<bool> iniciarSesion(String correoOTelefono, String password) async {
    print('Iniciando sesión con: $correoOTelefono y $password');
    try {
      estado.value = Estado.carga;
      final sqlObtenerUsuarioPorUsernameOTelefono = Sql.named('''
        SELECT * FROM usuarios WHERE (correo = @correo OR telefono = @telefono);
      ''');
      final resp = await Database.conn.execute(
        sqlObtenerUsuarioPorUsernameOTelefono,
        parameters: {
          'correo': correoOTelefono,
          'telefono': correoOTelefono,
        },
      );
      //si el la respues es vacia significa que no existe el usuario
      if (resp.isEmpty) {
        estado.value = Estado.error;
        mensajeError.value = 'Usuario no encontrado';
        return false;
      }

      print(resp);

      //valido la contaseña fuera de la consulta por si es que la conttraseña se hashea
      print(resp[0]);
      if (password == resp[0][4] as String) {
        estado.value = Estado.exito;
        SesionActiva().idUsuario = resp[0][0] as int;
        SesionActiva().nombreUsuario = resp[0][1] as String;
        SesionActiva().rolUsuario = resp[0][8] as String;
      }
      return true;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      estado.value = Estado.error;
      mensajeError.value = 'Error al iniciar sesión: $e';
      return false;
    }
  }

  Future<bool> recuperarContrasena(String username, String password) async {
    return true; // Simulación de autenticación exitosa
  }

  Future<bool> CerrarSecion(String username, String password) async {
    return true; // Simulación de autenticación exitosa
  }
}
