import 'package:cafe/common/enums.dart';
import 'package:cafe/promociones/widgets/actualizarPromocion.dart';
import 'package:cafe/promociones/widgets/eliminarPromocion.dart';
import 'package:cafe/promociones/widgets/obenerPromociones.dart';
import 'package:cafe/promociones/widgets/registrarPromocion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromocionesPage extends StatefulWidget {
  const PromocionesPage({super.key});

  @override
  State<PromocionesPage> createState() => _PromocionesPageState();
}

class _PromocionesPageState extends State<PromocionesPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final porcentajeController = TextEditingController();
  final comprasNecesariasController = TextEditingController();
  bool status = true;

  final RegistrarPromocionController promoController = Get.put(RegistrarPromocionController());
  final ObtenerPromocionesController obtenerController = Get.put(ObtenerPromocionesController());
  final EditarPromocionController editarPromocionController = Get.put(EditarPromocionController());
  final EliminarPromocionController eliminarPromocionController = Get.put(EliminarPromocionController());

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    obtenerController.obtenerPromociones();
  }

  Future<void> agregarPromocion() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await promoController.registrarPromocion(
        nombrePromocion: nombreController.text.trim(),
        descripcion: descripcionController.text.trim(),
        porcentaje: int.tryParse(porcentajeController.text.trim()) ?? 0,
        comprasNecesarias: int.tryParse(comprasNecesariasController.text.trim()) ?? 0,
        status: status,
      );
      nombreController.clear();
      descripcionController.clear();
      porcentajeController.clear();
      comprasNecesariasController.clear();
      status = true;

      mostrarModalRegistroExitoso(context);

      await obtenerController.obtenerPromociones();
    } catch (e) {
      mostrarModalErrorRegistro(context, promoController.mensaje.value.isNotEmpty
        ? promoController.mensaje.value
        : (e.toString().isNotEmpty ? e.toString() : 'Ocurrió un error'));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xF9F5F1FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                margin: const EdgeInsets.only(bottom: 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Crear nueva promoción",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: nombreController,
                        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                        decoration: _rectFieldDecoration("Nombre de la promoción"),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: descripcionController,
                        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                        decoration: _rectFieldDecoration("Descripción de la promo"),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: porcentajeController,
                              keyboardType: TextInputType.number,
                              decoration: _rectFieldDecoration("Porcentaje (%)"),
                              validator: (v) {
                                if (v != null && v.isNotEmpty) {
                                  final val = int.tryParse(v);
                                  if (val == null || val < 0 || val > 100) {
                                    return "0-100";
                                  }
                                } else {
                                  return "Campo obligatorio";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: comprasNecesariasController,
                              keyboardType: TextInputType.number,
                              decoration: _rectFieldDecoration("Compras necesarias"),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Campo obligatorio";
                                }
                                final val = int.tryParse(v);
                                if (val == null || val < 1) {
                                  return "Debe ser mayor a 0";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text(
                            "Activa",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: status,
                            activeColor: const Color(0xFF9B7B22),
                            onChanged: (v) => setState(() => status = v),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B7B22),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: _isLoading ? null : agregarPromocion,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Crear Promoción',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 38),
            const Text(
              "Promociones activas:",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (obtenerController.estado.value == Estado.carga) {
                return const Center(child: CircularProgressIndicator());
              }
              if (obtenerController.listaPromociones.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text("Aún no hay promociones registradas."),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: obtenerController.listaPromociones.length,
                itemBuilder: (context, i) {
                  final promo = obtenerController.listaPromociones[i];
                  return InkWell(
                    onTap: () => mostrarModalEditarPromocion(
                      context,
                      promo,
                      obtenerController,
                      editarPromocionController,
                      eliminarPromocionController,
                    ),
                    child: Card(
                      color: promo.status
                          ? const Color(0xFFFAF0E6)
                          : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.local_offer,
                                color: Color(0xFF9B7B22), size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    promo.nombrePromocion,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF9B7B22),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    promo.descripcion,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _chipPromo("${promo.porcentaje}% de descuento"),
                                      _chipPromo("Compras necesarias: ${promo.comprasNecesarias}"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: promo.status
                                    ? const Color(0xFF9B7B22)
                                    : Colors.grey[600],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                promo.status ? 'Activa' : 'Inactiva',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

Widget _chipPromo(String label) {
  return Container(
    margin: const EdgeInsets.only(right: 7),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF9B7B22).withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Color(0xFF9B7B22), fontSize: 13),
    ),
  );
}

InputDecoration _rectFieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF9B7B22), width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
    ),
    filled: true,
    fillColor: Colors.white,
  );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF9B7B22), size: 44),
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
                      child: const Text('Aceptar', style: TextStyle(fontSize: 14)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF9B7B22), size: 44),
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
                      child: const Text('Aceptar', style: TextStyle(fontSize: 14)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      child: const Text('Cerrar', style: TextStyle(fontSize: 14)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[800], size: 44),
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
                          child: const Text('Cancelar', style: TextStyle(fontSize: 14)),
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
                          child: const Text('Eliminar', style: TextStyle(fontSize: 14)),
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
void mostrarModalEditarPromocion(
  BuildContext context,
  dynamic promo,
  ObtenerPromocionesController obtenerController,
  EditarPromocionController editarPromocionController,
  EliminarPromocionController eliminarPromocionController,
) {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final porcentajeController = TextEditingController();
  final comprasController = TextEditingController();
  bool status = true;
  bool _isUpdating = false;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480,
            minWidth: 350,
          ),
          child: Dialog(
            backgroundColor: const Color(0xFFFAF0E6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Editar Promoción',
                          style: TextStyle(
                            color: Color(0xFF9B7B22),
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: nombreController,
                          decoration: InputDecoration(
                            labelText: "Nombre",
                            labelStyle: const TextStyle(color: Color(0xFF9B7B22)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descripcionController,
                          decoration: InputDecoration(
                            labelText: "Descripción",
                            labelStyle: const TextStyle(color: Color(0xFF9B7B22)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: porcentajeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Porcentaje",
                                  labelStyle: const TextStyle(color: Color(0xFF9B7B22)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: comprasController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Compras",
                                  labelStyle: const TextStyle(color: Color(0xFF9B7B22)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              "Activa",
                              style: TextStyle(color: Color(0xFF9B7B22), fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 10),
                            Switch(
                              value: status,
                              activeColor: const Color(0xFF9B7B22),
                              onChanged: (v) => setState(() => status = v),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9B7B22),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: _isUpdating ? null : () async {
                              setState(() => _isUpdating = true);
                              try {
                                await editarPromocionController.editarPromocion(
                                  idPromocion: promo.idPromocion,
                                  nombre: nombreController.text.trim(),
                                  descripcion: descripcionController.text.trim(),
                                  porcentaje: int.tryParse(porcentajeController.text.trim()) ?? 0,
                                  comprasNecesarias: int.tryParse(comprasController.text.trim()) ?? 0,
                                  status: status,
                                );
                                await obtenerController.obtenerPromociones();
                                Navigator.of(context).pop();
                                mostrarModalActualizadoExitosamente(context);
                              } catch (e) {
                                mostrarModalErrorRegistro(context, editarPromocionController.mensaje.value.isNotEmpty
                                  ? editarPromocionController.mensaje.value
                                  : (e.toString().isNotEmpty ? e.toString() : 'Ocurrió un error'));
                              } finally {
                                setState(() => _isUpdating = false);
                              }
                            },
                            child: _isUpdating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Guardar cambios', style: TextStyle(fontSize: 17)),
                          ),
                        ),
                      ],
                    ),
                    // BOTÓN ELIMINAR PROMOCIÓN
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                        tooltip: 'Eliminar promoción',
                        onPressed: () async {
                          final confirm = await mostrarModalConfirmarEliminacion(context);
                          if (confirm == true) {
                            try {
                              await eliminarPromocionController.eliminarPromocion(promo.idPromocion);
                              await obtenerController.obtenerPromociones();
                              Navigator.of(context).pop(); // Cierra el modal
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Promoción eliminada.'),
                                  backgroundColor: Color(0xFF9B7B22),
                                ),
                              );
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al eliminar: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}