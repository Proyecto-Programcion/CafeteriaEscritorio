

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/administradores/administrador_modelo.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ListarSucursalesController  extends GetxController{
  Rx<Estado> estado = Estado.inicio.obs;
  RxList<SucursalModelo> sucursales = <SucursalModelo>[].obs;


  Future<bool> obtenerSucursales() async {
    sucursales.clear();
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        SELECT id_sucursal, nombre, direccion
        FROM sucursales
        WHERE eliminado = false;
      ''');
      final result = await Database.conn.execute(sql);
      sucursales.value = result.map((e) => SucursalModelo.fromMap(e.toColumnMap())).toList();
      estado.value = Estado.exito;
      return true;
    } catch (e) {
      estado.value = Estado.error;
      return false;
    }
  } 
  
}