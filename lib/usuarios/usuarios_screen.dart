import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/usuarios/controllers/elimnarUsuario.dart';
import 'package:cafe/logica/usuarios/controllers/obtenerUsuarios.dart';
import 'package:cafe/usuarios/widgets/editarNombreCliente.dart';
import 'package:cafe/usuarios/widgets/registerClientes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsuariosScreen extends StatelessWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colores base
    const fondoColor = Color(0xFFFAF0E6);
    const primaryTextColor = Color(0xFF9B7B22);
    const tableHeaderColor = Color(0xFFF0F0F0);
    const rowAltColor = Color(0xFFF5F5F5);

    // Inyecta el controlador solo una vez
    final clientesController = Get.put(ObtenerClientesController());
    final eliminarController = Get.put(EliminarClienteController());

    return Container(
      color: fondoColor,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÍTULO
          const Text(
            'DIRECTORIO DE CLIENTES',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Botón Nuevo Cliente
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => const ModalRegistrarCliente(),
                );
                await clientesController.obtenerClientes();
              },
              icon:
                  const Icon(Icons.person_add, color: Colors.black87, size: 20),
              label: const Text(
                'Nuevo Cliente',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // TABLA
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.09),
                    blurRadius: 10,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Controles arriba de la tabla
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17, vertical: 12),
                    child: Row(
                      children: [
                        const Text('Mostrar:', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: const [
                              Text('45', style: TextStyle(fontSize: 13)),
                              Icon(Icons.arrow_drop_down, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text('Registros', style: TextStyle(fontSize: 13)),
                        const Spacer(),
                        const Text('Buscar:', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: 140,
                          height: 32,
                          child: TextField(
                            onChanged: (value) =>
                                clientesController.filtro.value = value,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Encabezado de tabla
                  Container(
                    color: tableHeaderColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17, vertical: 10),
                    child: Row(
                      children: const [
                        Expanded(
                            flex: 1,
                            child: Text('Nº',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 4,
                            child: Text('Nombre completo',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 3,
                            child: Text('Teléfono',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('Acciones',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            )),
                      ],
                    ),
                  ),
                  // Filas de usuarios desde la base de datos (con filtro aplicado)
                  Expanded(
                    child: Obx(() {
                      if (clientesController.estado.value == Estado.carga) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (clientesController.estado.value == Estado.error) {
                        return Center(
                            child: Text(clientesController.mensaje.value));
                      }
                      if (clientesController.clientesFiltrados.isEmpty) {
                        return const Center(
                            child: Text('No hay clientes registrados.'));
                      }
                      return ListView.builder(
                        itemCount: clientesController.clientesFiltrados.length,
                        itemBuilder: (context, i) {
                          final cliente =
                              clientesController.clientesFiltrados[i];
                          return Container(
                            color: i % 2 == 0 ? Colors.white : rowAltColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 17, vertical: 13),
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Text('${i + 1}')),
                                Expanded(flex: 4, child: Text(cliente.nombre)),
                                Expanded(
                                    flex: 3,
                                    child: Text(cliente.numeroTelefono)),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: primaryTextColor),
                                        tooltip: 'Editar',
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                ModalEditarNombreCliente(
                                              idCliente: cliente.idCliente,
                                              nombreActual: cliente.nombre,
                                            ),
                                          );
                                          await clientesController
                                              .obtenerClientes();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        tooltip: 'Eliminar',
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  'Eliminar cliente'),
                                              content: Text(
                                                  '¿Seguro que quieres eliminar a "${cliente.nombre}"? Esta acción no se puede deshacer.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text(
                                                    'Eliminar',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await eliminarController
                                                  .eliminarCliente(
                                                      idCliente:
                                                          cliente.idCliente);
                                              await clientesController
                                                  .obtenerClientes();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content:
                                                    Text('Cliente eliminado.'),
                                                backgroundColor:
                                                    primaryTextColor,
                                              ));
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Error al eliminar: $e'),
                                                backgroundColor: Colors.red,
                                              ));
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
