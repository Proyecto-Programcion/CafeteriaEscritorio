import 'dart:convert';
import 'dart:io';

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class AgregarAdministradorController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> agregarAdministrador(
      {required String nombre,
      String? correo,
      required String telefono,
      required String urlImagen,
      required int idSucursal,
      required String contrasena}) async {
    try {
      estado.value = Estado.carga;
      String imagenBase64 = '';

      //pasar la imagen a base 64
      if (urlImagen != '') {
        File imageFile = File(urlImagen);
        List<int> imageBytes = await imageFile.readAsBytes();
        imagenBase64 = base64Encode(imageBytes);
        print('Imagen convertida a Base64');
      }

      final sql = Sql.named('''
       INSERT INTO usuarios (nombre, correo, telefono, contrasena, imagen, idSucursal, rol)
      VALUES (@nombre, @correo , @telefono, @contrasena, @imagen, @idsucursal, @rol);
      ''');

      final resp = await Database.conn.execute(sql, parameters: {
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'contrasena': contrasena,
        'imagen': imagenBase64,
        'idsucursal': idSucursal,
        'rol': 'administrador',
      });

      estado.value = Estado.exito;
      mensaje.value = 'Administrador agregado exitosamente';
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al agregar el administrador: $e';
      return false;
    }
  }
}
