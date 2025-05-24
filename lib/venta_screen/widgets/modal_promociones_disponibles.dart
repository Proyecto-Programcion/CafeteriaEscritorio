import 'package:cafe/logica/promociones/promocionModel.dart';
import 'package:cafe/logica/promociones/promocion_producto_gratis_modelo.dart';
import 'package:cafe/venta_screen/widgets/modal_realizar_Venta.dart';
import 'package:flutter/material.dart';

// Creamos un nuevo modal para las promociones
class ModalPromocionesDisponibles extends StatefulWidget {
  final List<Promocion> promocionesDescuento;
  final List<PromocionProductoGratiConNombreDelProductosModelo>
      promocionesProductosGratis;
  final Promocion? promocionDescuentoSeleccionada;
  final PromocionProductoGratiConNombreDelProductosModelo?
      promocionProductoGratisSeleccionada;

  const ModalPromocionesDisponibles({
    Key? key,
    required this.promocionesDescuento,
    required this.promocionesProductosGratis,
    this.promocionDescuentoSeleccionada,
    this.promocionProductoGratisSeleccionada,
  }) : super(key: key);

  @override
  State<ModalPromocionesDisponibles> createState() =>
      _ModalPromocionesDisponiblesState();
}

class _ModalPromocionesDisponiblesState
    extends State<ModalPromocionesDisponibles> {
  Promocion? promocionDescuentoSeleccionada;
  PromocionProductoGratiConNombreDelProductosModelo?
      promocionProductoGratisSeleccionada;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    promocionDescuentoSeleccionada = widget.promocionDescuentoSeleccionada;
    promocionProductoGratisSeleccionada =
        widget.promocionProductoGratisSeleccionada;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
// Agregar este método en la clase _ModalRealizarVentaState

  @override
  Widget build(BuildContext context) {
    final double ancho = MediaQuery.of(context).size.width * 0.6;
    final double alto = MediaQuery.of(context).size.height * 0.6;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: ancho,
        height: alto,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Promociones Disponibles",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color.fromARGB(255, 153, 103, 8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop({
                      'promocionDescuento': promocionDescuentoSeleccionada,
                      'promocionProductoGratis':
                          promocionProductoGratisSeleccionada,
                    }),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      // Mostrar promociones de descuento con selector único
                      if (widget.promocionesDescuento.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12, top: 8),
                          child: Text(
                            "Selecciona una promoción de descuento:",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                        DropdownButtonFormField<int>(
                          value: promocionDescuentoSeleccionada?.idPromocion,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.green[50],
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.green[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.green[200]!),
                            ),
                          ),
                          items: [
                            // Opción para no seleccionar ninguna promoción
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text(
                                'Ninguna promoción seleccionada',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            // Opciones para cada promoción
                            ...widget.promocionesDescuento
                                .map(
                                  (promo) => DropdownMenuItem<int>(
                                    value: promo.idPromocion,
                                    child: Text(
                                      '${promo.nombrePromocion} (${promo.porcentaje.toStringAsFixed(0)}%) - Mín: \$${promo.dineroNecesario.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                          onChanged: (int? selectedId) {
                            setState(() {
                              promocionDescuentoSeleccionada =
                                  selectedId == null
                                      ? null
                                      : widget.promocionesDescuento.firstWhere(
                                          (promo) =>
                                              promo.idPromocion == selectedId);
                            });
                          },
                        ),

                        // Si hay una promoción seleccionada, mostrar detalles
                        if (promocionDescuentoSeleccionada != null) ...[
                          const SizedBox(height: 12),
                          CardPromocionDescuento(
                            promocion: promocionDescuentoSeleccionada!,
                            seleccionada: true,
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],

                      // Mostrar promociones de productos gratis con selector único
                      if (widget.promocionesProductosGratis.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12, top: 8),
                          child: Text(
                            "Selecciona un producto gratis:",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                        DropdownButtonFormField<int>(
                          value: promocionProductoGratisSeleccionada
                              ?.idPromocionProductoGratis,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blue[50],
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue[200]!),
                            ),
                          ),
                          items: [
                            // Opción para no seleccionar ninguna promoción
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text(
                                'Ningún producto gratis seleccionado',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            // Opciones para cada promoción de producto gratis
                            ...widget.promocionesProductosGratis
                                .map(
                                  (promo) => DropdownMenuItem<int>(
                                    value: promo.idPromocionProductoGratis,
                                    child: Text(
                                      '${promo.nombreProducto} - Mín: \$ ${promo.dineroNecesario.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                          onChanged: (int? selectedId) {
                            setState(() {
                              promocionProductoGratisSeleccionada =
                                  selectedId == null
                                      ? null
                                      : widget.promocionesProductosGratis
                                          .firstWhere((promo) =>
                                              promo.idPromocionProductoGratis ==
                                              selectedId);
                            });
                          },
                        ),

                        // Si hay una promoción de producto gratis seleccionada, mostrar detalles
                        if (promocionProductoGratisSeleccionada != null) ...[
                          const SizedBox(height: 12),
                          CardPromocionProductoGratis(
                            promocion: promocionProductoGratisSeleccionada!,
                            seleccionada: true,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop({
                      'promocionDescuento': promocionDescuentoSeleccionada,
                      'promocionProductoGratis':
                          promocionProductoGratisSeleccionada,
                    });
                  },
                  child: const Text('Confirmar selección'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
