import 'package:cafe/logica/promociones/promocion_producto_gratis_modelo.dart';
import 'package:cafe/promociones/widgets/modal_actualizar_promocion_producto_gratis.dart';
import 'package:flutter/material.dart';

class ContenedorPromocionProductoGratis extends StatelessWidget {
  final PromocionProductoGratiConNombreDelProductosModelo promocion;
  const ContenedorPromocionProductoGratis({
    super.key,
    required this.promocion,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return ModalActualizarPromocionProductoGratis(
                  promocion: promocion);
            });
      },
      child: Card(
        color: promocion.status
            ? const Color(0xFFE8F5E9)
            : const Color.fromARGB(255, 238, 246, 239),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.discount, color: Color(0xFF9B7B22), size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promocion.nombrePromocion,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9B7B22),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      promocion.descripcion,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _chipPromo(
                            "Compras necesarias: ${promocion.comprasNecesarias}"),
                        _chipPromo(
                            "Compra minima: ${promocion.dineroNecesario}"),
                        _chipPromo(
                            "Regalo: ${promocion.nombreProducto} : CANTIDAD: ${promocion.cantidadProducto} ${promocion.unidadDeMedidaProducto}"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: promocion.status
                      ? const Color(0xFF9B7B22)
                      : Colors.grey[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  promocion.status ? 'Activa' : 'Inactiva',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              )
            ],
          ),
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

void mostrarModalEditarPromocion(
  BuildContext context,
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
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
                            labelStyle:
                                const TextStyle(color: Color(0xFF9B7B22)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descripcionController,
                          decoration: InputDecoration(
                            labelText: "Descripción",
                            labelStyle:
                                const TextStyle(color: Color(0xFF9B7B22)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
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
                                  labelStyle:
                                      const TextStyle(color: Color(0xFF9B7B22)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
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
                                  labelStyle:
                                      const TextStyle(color: Color(0xFF9B7B22)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
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
                              style: TextStyle(
                                  color: Color(0xFF9B7B22),
                                  fontWeight: FontWeight.w500),
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
                            onPressed: () {},
                            child: _isUpdating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Guardar cambios',
                                    style: TextStyle(fontSize: 17)),
                          ),
                        ),
                      ],
                    ),
                    // BOTÓN ELIMINAR PROMOCIÓN
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 28),
                        tooltip: 'Eliminar promoción',
                        onPressed: () {},
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
