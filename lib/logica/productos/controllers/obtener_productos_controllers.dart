import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerProductosControllers extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxList<ProductoModelo> listaProductos = <ProductoModelo>[].obs;

  @override
  void onInit() {
    super.onInit();
    obtenerProductos();
  }

  Future<void> obtenerProductos() async {
    try {
      estado.value = Estado.carga;
      // Simulación de la obtención de productos
      final sql = Sql.named('''
        SELECT 
          productos.*, 
          categorias.nombre AS nombre_categoria
        FROM productos
        LEFT JOIN categorias ON productos.id_categoria = categorias.id_categoria
        WHERE productos.eliminado = false
        ORDER BY productos.id_producto ASC;
      ''');

      final resp = await Database.conn.execute(sql);

      // Obtener nombres de columnas
      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];

      // Mapear cada fila a ProductoModelo usando fromMap
      listaProductos.value = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        return ProductoModelo.fromMap(map);
      }).toList();

      estado.value = Estado.exito;
    } catch (e) {
      print('Error al obtener productos: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener productos: $e';
    }
  }
}
