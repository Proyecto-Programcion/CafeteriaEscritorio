import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/categorias/categoria_modelo.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:postgres/postgres.dart';

class ObtenerCategoriasController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxList<CategoriaModelo> categorias = <CategoriaModelo>[].obs;

  Future<bool> obtenerCategorias() async {
    try {
      // Limpiar la lista de categorías antes de obtener nuevas
      categorias.clear();
      estado.value = Estado.carga;
      final sql = Sql.named('''
        SELECT * FROM categorias WHERE eliminado = false;
      ''');
      final resp = await Database.conn.execute(sql);
      print('resp: $resp');
      resp.forEach((element) {
        categorias.add(CategoriaModelo(
          idCategoria: element[0] as int,
          idUsuario: element[1] != null ? element[1] as int : 1,
          nombre: element[2] as String,
        ));
      });

      estado.value = Estado.exito;
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener las categorías: $e';
      return false;
    }
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    return [
      ...categorias.map((cat) => DropdownMenuItem<String>(
            value: cat.idCategoria.toString(),
            child: Text(cat.nombre),
          ))
    ];
  }
}
