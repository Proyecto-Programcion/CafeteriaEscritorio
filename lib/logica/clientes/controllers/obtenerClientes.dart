import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/clientes/clientesModel.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerClientesController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxList<usuariMmodel> listaClientes = <usuariMmodel>[].obs;
  RxString filtro = ''.obs;

  List<usuariMmodel> get clientesFiltrados {
    final f = filtro.value.trim().toLowerCase();
    if (f.isEmpty) return listaClientes;
    return listaClientes.where((c) =>
      c.nombre.toLowerCase().contains(f) ||
      c.numeroTelefono.toLowerCase().contains(f)
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    obtenerClientes();
  }

  Future<void> obtenerClientes() async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        SELECT 
          id_cliente,
          nombre,
          telefono AS numero_telefono
        FROM clientes
        ORDER BY id_cliente ASC;
      ''');
      final resp = await Database.conn.execute(sql);

      final columns = resp.schema?.columns.map((c) => c).toList() ?? [];

      listaClientes.value = resp.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i].columnName ?? ''] = row[i];
        }
        return usuariMmodel.fromMap(map);
      }).toList();

      estado.value = Estado.exito;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener clientes: $e';
      print('[ERROR] $e');
    }
  }
}