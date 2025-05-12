import 'package:cafe/logica/promociones/promocionModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModalActualizarPromocionDescuento extends StatefulWidget {
  final Promocion promocion;
  ModalActualizarPromocionDescuento({super.key, required this.promocion});

  @override
  State<ModalActualizarPromocionDescuento> createState() =>
      _ModalActualizarPromocionDescuentoState();
}

class _ModalActualizarPromocionDescuentoState
    extends State<ModalActualizarPromocionDescuento> {
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

  @override
  void initState() {
    // TODO: implement initState
    nombreController.text = widget.promocion.nombrePromocion;
    descripcionController.text = widget.promocion.descripcion;
    porcentajeController.text = widget.promocion.porcentaje.toString();
    topeDescuentoController.text = widget.promocion.topeDescuento.toString();
    comprasNecesariasController.text =
        widget.promocion.comprasNecesarias.toString();
    dineroNecesarioController.text =
        widget.promocion.dineroNecesario.toString();
    statusPromocionDescuento = widget.promocion.status;
    super.initState();
  }

  void _actualizarPromocion() async {
    if (_formKey.currentState!.validate()) {
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
        content: Container(
      constraints: const BoxConstraints(maxWidth: 520),
      width: 520,
      height: 500,
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Actualizar promoción",
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
                    decoration: _rectFieldDecoration("Dinero necesario"),
                    validator: (v) {
                      if (v == null || v.isEmpty || v == "") {
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
                onPressed: () {
                  _actualizarPromocion();
                },
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
                        'Actualizar Promoción',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ],
        ),
      ),
    ));
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
