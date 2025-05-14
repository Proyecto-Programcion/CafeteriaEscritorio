import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:cafe/logica/promociones/controllers/obtener_promociones_productos_gratis.dart';
import 'package:cafe/logica/promociones/controllers/registrar_promocion_producto_gratis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class FormPromocionProductoGratis extends StatefulWidget {
  const FormPromocionProductoGratis({super.key});

  @override
  State<FormPromocionProductoGratis> createState() =>
      _FormPromocionProductoGratisState();
}

class _FormPromocionProductoGratisState
    extends State<FormPromocionProductoGratis> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final comprasNecesariasController = TextEditingController();
  final dineroNecesarioController = TextEditingController();
  final cantidadProductoGratisController = TextEditingController();
  bool status = true;
  bool isLoading = false;
  int? productoSeleccionadoId;

  List<DropdownMenuItem<int>> productosDropdownMenuItems = [];

  final ObtenerProductosControllers obtenerProductosControllers = Get.put(
    ObtenerProductosControllers(),
  );
  final ObtenerPromocionesProductosGratisController
      obtenerPromocionesProductosGratisController = Get.put(
    ObtenerPromocionesProductosGratisController(),
  );

  final RegistrarPromocionProductoGratis registrarPromocionProductoGratis =
      Get.put(
    RegistrarPromocionProductoGratis(),
  );

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    comprasNecesariasController.dispose();
    dineroNecesarioController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void crearPromocionProductoGratis() async {
    // Aquí va tu lógica para crear la promoción de producto gratis

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final resp = await registrarPromocionProductoGratis.registrarPromocion(
          nombrePromocion: nombreController.text,
          descripcion: descripcionController.text,
          idProducto: productoSeleccionadoId!,
          comprasNecesarias: int.parse(comprasNecesariasController.text),
          dineroNecesario: double.parse(dineroNecesarioController.text),
          status: status,
          cantidad_producto:
              double.parse(cantidadProductoGratisController.text));

      //limpiar campos
      nombreController.clear();
      descripcionController.clear();
      comprasNecesariasController.clear();
      dineroNecesarioController.clear();
      productoSeleccionadoId = null;
      
      if (resp) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Promoción creada correctamente"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        obtenerPromocionesProductosGratisController.obtenerPromociones();
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(registrarPromocionProductoGratis.mensaje.value),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    cargarProductos();
    super.initState();
  }

  void cargarProductos() async {
    await obtenerProductosControllers.obtenerProductos();
    setState(() {
      final productosFiltrados =
          List<ProductoModelo>.from(obtenerProductosControllers.listaProductos);
      productosDropdownMenuItems = productosFiltrados.map((producto) {
        return DropdownMenuItem(
          value: producto.idProducto,
          child: Text(producto.nombre),
        );
      }).toList();
    });

    print("Productos cargados, ${productosDropdownMenuItems.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 820),
      width: 820,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
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
                  "Crear nueva promoción de producto gratis",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 19,
                  ),
                ),
                Icon(Icons.discount)
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
                  child: DropdownButtonFormField<int>(
                    value: productoSeleccionadoId,
                    decoration: _rectFieldDecoration("Productos gratis"),
                    items: productosDropdownMenuItems,
                    onChanged: (val) {
                      if (val != null) {
                        productoSeleccionadoId = int.parse(val.toString());
                      }
                    },
                    validator: (v) {
                      if (v == null) return "Campo obligatorio";

                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 190,
                  child: TextFormField(
                    controller: cantidadProductoGratisController,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Campo obligatorio";
                      }
                      final val = double.tryParse(v);
                      if (val == null || val <= -1) {
                        return "Debe ser mayor o igual a 0";
                      }
                      return null;
                    },
                    decoration: _rectFieldDecoration("Cantidad"),
                  ),
                )
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
                onPressed: isLoading ? null : crearPromocionProductoGratis,
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
