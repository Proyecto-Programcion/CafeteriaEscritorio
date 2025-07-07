import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/promociones/controllers/actualizarPromocion.dart';
import 'package:cafe/logica/promociones/controllers/eliminarPromocion.dart';
import 'package:cafe/logica/promociones/controllers/obenerPromociones.dart';
import 'package:cafe/logica/promociones/controllers/obtener_promociones_productos_gratis.dart';
import 'package:cafe/logica/promociones/promocionModel.dart';
import 'package:cafe/logica/promociones/promocion_producto_gratis_modelo.dart';
import 'package:cafe/promociones/widgets/container_promocion_descuento.dart';
import 'package:cafe/promociones/widgets/container_promocion_productos_gratis.dart';
import 'package:cafe/promociones/widgets/formulario_promocion_descuento.dart';
import 'package:cafe/promociones/widgets/formulario_promocion_producto_gratis.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromocionesPage extends StatefulWidget {
  const PromocionesPage({super.key});

  @override
  State<PromocionesPage> createState() => _PromocionesPageState();
}

class _PromocionesPageState extends State<PromocionesPage> {
  final _promocionesProductosGratisFormkey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final porcentajeController = TextEditingController();
  final comprasNecesariasController = TextEditingController();
  final topeDescuentoController = TextEditingController();
  final dineroNecesarioController = TextEditingController();

  bool statusPromocionDescuento = true;
  bool statusPromocionProductoGratis = true;

  final ObtenerPromocionesController obtenerController =
      Get.put(ObtenerPromocionesController());
  final ActualizarPromocion editarPromocionController =
      Get.put(ActualizarPromocion());
  final EliminarPromocionController eliminarPromocionController =
      Get.put(EliminarPromocionController());
  final ObtenerPromocionesProductosGratisController
      obtenerPromocionesProductosGratisController =
      Get.put(ObtenerPromocionesProductosGratisController());

  @override
  void initState() {
    super.initState();
    obtenerController.obtenerPromociones();
    obtenerPromocionesProductosGratisController.obtenerPromociones();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reemplazamos el Row fijo por un SingleChildScrollView horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FormPromocionDescuento(),
                const SizedBox(width: 24),
                FormPromocionProductoGratis()
              ],
            ),
          ),
          const SizedBox(height: 38),
          const Text(
            "Promociones activas:",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (obtenerController.estado.value == Estado.carga ||
                obtenerPromocionesProductosGratisController.estado.value ==
                    Estado.carga) {
              return const Center(child: CircularProgressIndicator());
            }
            if (obtenerController.listaPromociones.isEmpty &&
                obtenerPromocionesProductosGratisController
                    .listaPromociones.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text("Aún no hay promociones registradas."),
              );
            }
            final List<Object> listaPromociones = [
              ...obtenerController.promocionesFiltradas,
              ...obtenerPromocionesProductosGratisController.listaPromociones
            ];
            print('PROMOCIONES FILTRADAS: ${listaPromociones}');
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaPromociones.length,
              itemBuilder: (context, i) {
                final promo = listaPromociones[i];
                if (promo is Promocion) {
                  return ContenedorPromocionDescuento(
                    promocion: promo,
                  );
                } else if (promo
                    is PromocionProductoGratiConNombreDelProductosModelo) {
                  return ContenedorPromocionProductoGratis(
                    promocion: promo,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          }),
        ],
      ),
    ),
  );
}
}
void mostrarModalRegistroExitoso(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 290,
        ),
        child: Dialog(
          backgroundColor: const Color(0xFFFAF0E6),
          insetPadding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Color(0xFF9B7B22), size: 44),
                  const SizedBox(height: 10),
                  Text(
                    '¡Registro exitoso!',
                    style: TextStyle(
                      color: Color(0xFF9B7B22),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La promoción se registró correctamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9B7B22),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9B7B22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child:
                          const Text('Aceptar', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void mostrarModalActualizadoExitosamente(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 290,
        ),
        child: Dialog(
          backgroundColor: const Color(0xFFFAF0E6),
          insetPadding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Color(0xFF9B7B22), size: 44),
                  const SizedBox(height: 10),
                  Text(
                    '¡Actualizados!',
                    style: TextStyle(
                      color: Color(0xFF9B7B22),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los datos de la promoción fueron actualizados correctamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9B7B22),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9B7B22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child:
                          const Text('Aceptar', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void mostrarModalErrorRegistro(BuildContext context, String error) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 290,
        ),
        child: Dialog(
          backgroundColor: const Color(0xFFFAF0E6),
          insetPadding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[800], size: 44),
                  const SizedBox(height: 10),
                  Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9B7B22),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child:
                          const Text('Cerrar', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// MODAL DE CONFIRMACIÓN DE ELIMINACIÓN PERSONALIZADO
Future<bool?> mostrarModalConfirmarEliminacion(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 290),
        child: Dialog(
          backgroundColor: const Color(0xFFFAF0E6),
          insetPadding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red[800], size: 44),
                  const SizedBox(height: 10),
                  Text(
                    '¿Eliminar promoción?',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¿Estás seguro que deseas eliminar esta promoción? Esta acción no se puede deshacer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9B7B22),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar',
                              style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Eliminar',
                              style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// MODAL DE EDICIÓN: Campos en blanco para que el usuario escriba lo que quiera, NO se cargan datos anteriores
