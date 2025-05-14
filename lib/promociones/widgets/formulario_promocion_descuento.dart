import 'package:cafe/logica/promociones/controllers/obenerPromociones.dart';
import 'package:cafe/logica/promociones/controllers/registrarPromocion.dart';
import 'package:cafe/promociones/promocionesScreeen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class FormPromocionDescuento extends StatefulWidget {
  const FormPromocionDescuento({super.key});

  @override
  State<FormPromocionDescuento> createState() => _FormPromocionDescuentoState();
}

class _FormPromocionDescuentoState extends State<FormPromocionDescuento> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final porcentajeController = TextEditingController();
  final topeDescuentoController = TextEditingController();
  final comprasNecesariasController = TextEditingController();
  final dineroNecesarioController = TextEditingController();
  bool isLoading = false;
  bool statusPromocionDescuento = true;
  bool _isLoading = false;

  final RegistrarPromocionController promoController =
      Get.put(RegistrarPromocionController());
  final ObtenerPromocionesController obtenerController =
      Get.put(ObtenerPromocionesController());

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    porcentajeController.dispose();
    topeDescuentoController.dispose();
    comprasNecesariasController.dispose();
    dineroNecesarioController.dispose();
    super.dispose();
  }

  Future<void> agregarPromocion() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resp = await promoController.registrarPromocion(
        nombrePromocion: nombreController.text.trim(),
        descripcion: descripcionController.text.trim(),
        porcentaje: double.tryParse(porcentajeController.text.trim()) ?? 0,
        comprasNecesarias:
            int.tryParse(comprasNecesariasController.text.trim()) ?? 0,
        dineroNecesario: dineroNecesarioController.text.isNotEmpty
            ? double.parse(dineroNecesarioController.text.trim())
            : 0,
        topeDescuento: topeDescuentoController.text.isNotEmpty
            ? double.parse(topeDescuentoController.text.trim())
            : 0,
        status: statusPromocionDescuento,
      );
      nombreController.clear();
      descripcionController.clear();
      porcentajeController.clear();
      comprasNecesariasController.clear();
      dineroNecesarioController.clear();
      topeDescuentoController.clear();
      statusPromocionDescuento = true;

      if (resp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promoción creada correctamente'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error al crear la promoción ${promoController.mensaje}'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }

      await obtenerController.obtenerPromociones();
    } catch (e) {
      mostrarModalErrorRegistro(
          context,
          promoController.mensaje.value.isNotEmpty
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      width: 520,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      margin: const EdgeInsets.only(bottom: 36),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Crear promoción",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9B7B22)),
                ),
                Icon(Icons.local_offer)
              ],
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: nombreController,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obligatorio' : null,
              decoration: _rectFieldDecoration("Nombre de la promoción"),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: descripcionController,
              decoration: _rectFieldDecoration("Descripción de la promo"),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: porcentajeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: _rectFieldDecoration("Porcentaje (%)"),
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final val = double.tryParse(v);
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
                    controller: topeDescuentoController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: _rectFieldDecoration("Tope descuento"),
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final val = double.tryParse(v);
                        if (val == null || val < 0) {
                          return "Debe ser mayor o igual a 0";
                        }
                      } else {
                        return "Campo obligatorio";
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
                Expanded(
                  child: TextFormField(
                    controller: comprasNecesariasController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _rectFieldDecoration("Compras necesarias"),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Campo obligatorio";
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: dineroNecesarioController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: _rectFieldDecoration("Compra minima"),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Campo obligatorio";
                      }
                      final val = double.tryParse(v);
                      if (val == null || val < 0) {
                        return "Debe ser mayor o igual a 0";
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
                  value: statusPromocionDescuento,
                  activeColor: const Color(0xFF9B7B22),
                  onChanged: (v) =>
                      setState(() => statusPromocionDescuento = v),
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
                onPressed: isLoading ? null : agregarPromocion,
                child: isLoading
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _rectFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
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
}
