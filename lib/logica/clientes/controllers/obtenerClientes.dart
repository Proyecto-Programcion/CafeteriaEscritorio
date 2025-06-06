import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/clientes/clientesModel.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

// AGREGAR ESTA ENUM (puedes moverla a otro archivo si prefieres)
enum OrdenClientes { recientes, antiguos }

class ObtenerClientesController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxInt totalClientes = 0.obs;
  RxList<usuariMmodel> listaClientes = <usuariMmodel>[].obs;
  RxString filtro = ''.obs;

  // AGREGAR ESTA VARIABLE
  Rx<OrdenClientes> orden = OrdenClientes.recientes.obs;

  List<usuariMmodel> get clientesFiltrados {
    final f = filtro.value.trim().toLowerCase();
    List<usuariMmodel> filtrados = f.isEmpty
        ? listaClientes
        : listaClientes
            .where((c) =>
                c.nombre.toLowerCase().contains(f) ||
                c.numeroTelefono.toLowerCase().contains(f))
            .toList();
    return filtrados;
  }

  @override
  void onInit() {
    super.onInit();
    obtenerClientes();
  }

  Future<void> obtenerClientes() async {
    try {
      listaClientes.clear();
      estado.value = Estado.carga;

      // USAR EL ORDEN SEGÚN LA VARIABLE
      String orderBy = orden.value == OrdenClientes.recientes
          ? 'id_cliente DESC'
          : 'id_cliente ASC';

      final sql = Sql.named('''
        SELECT 
          id_cliente,
          nombre,
          telefono AS numero_telefono,
          cantidad_compras
        FROM clientes
        ORDER BY $orderBy
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

  Future<void> obtenerTotalClientes() async {
    try {
      final sql = Sql.named('''
        select count(*) from clientes;
      ''');
      final resp = await Database.conn.execute(sql);
      if (resp.isNotEmpty) {
        totalClientes.value = resp.first[0] as int;
      } else {
        totalClientes.value = 0;
      }
    } catch (e) {
      print('Error al obtener total de clientes: $e');
    }
  }
}