import 'package:cafe/logica/turnoCaja/venta_turno_modelo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilaTablaVentasTurnoCajaScreen extends StatelessWidget {
  final VentaTurnoModel ventaTurnoModel;
  final int index;
  FilaTablaVentasTurnoCajaScreen({
    super.key,
    required this.ventaTurnoModel,
    required this.index,
  });

  Color esDivisible() {
    if (index % 2 == 0) {
      return const Color.fromARGB(255, 255, 255, 255); // blanco
    } else {
      return const Color.fromARGB(255, 244, 244, 244); // RGB(244,244,244)
    }
  }

  bool insIndexOnHover = false;

  indexOnHover(bool value) {
    if (value) {
      return const Color.fromARGB(255, 206, 206, 206); // blanco
    } else {
      return esDivisible();
    }
  }

  void _mostrarDetalleVenta(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 250, 240, 230),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header del modal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 85, 107, 47),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detalle de Venta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Contenido del modal
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ID de Venta
                        _buildInfoCard(
                          icon: Icons.receipt_long,
                          title: 'ID de Venta',
                          value: '#${ventaTurnoModel.idVenta}',
                        ),

                        const SizedBox(height: 16),

                        // Información de fecha y estado
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.access_time,
                                title: 'Fecha y Hora',
                                value: DateFormat('dd/MM/yyyy\nhh:mm a')
                                    .format(ventaTurnoModel.fecha),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInfoCard(
                                icon: ventaTurnoModel.statusCompra
                                    ? Icons.check_circle
                                    : Icons.pending,
                                title: 'Estado',
                                value: ventaTurnoModel.statusCompra
                                    ? 'Completada'
                                    : 'Pendiente',
                                valueColor: ventaTurnoModel.statusCompra
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Información de precios
                        const Text(
                          'Información de Precios',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 153, 103, 8),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildPriceCard(
                          label: 'Precio Total',
                          value: ventaTurnoModel.precioTotal,
                          icon: Icons.attach_money,
                          color: const Color.fromARGB(255, 85, 107, 47),
                        ),

                        const SizedBox(height: 8),

                        _buildPriceCard(
                          label: 'Descuento Aplicado',
                          value: ventaTurnoModel.descuentoAplicado ?? 0.0,
                          icon: Icons.discount,
                          color: Colors.orange,
                        ),

                        const SizedBox(height: 8),

                        _buildPriceCard(
                          label: 'Total con Descuento',
                          value: ventaTurnoModel.precioDescuento,
                          icon: Icons.price_check,
                          color: Colors.green,
                        ),

                        // Información de promociones (si existen)
                        if (ventaTurnoModel.promocionDescuentoNombre != null ||
                            ventaTurnoModel.promocionGratisNombre != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Promociones Aplicadas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 153, 103, 8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (ventaTurnoModel.promocionDescuentoNombre != null)
                            _buildPromocionCard(
                              titulo: 'Promoción de Descuento',
                              nombre: ventaTurnoModel.promocionDescuentoNombre!,
                              detalle:
                                  '${ventaTurnoModel.promocionDescuentoPorcentaje}% de descuento',
                              icono: Icons.percent,
                            ),
                          if (ventaTurnoModel.promocionGratisNombre != null)
                            _buildPromocionCard(
                              titulo: 'Producto Gratis',
                              nombre: ventaTurnoModel.promocionGratisNombre!,
                              detalle:
                                  '${ventaTurnoModel.promocionGratisCantidad}x ${ventaTurnoModel.promocionGratisNombreProducto}',
                              icono: Icons.card_giftcard,
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer con botón de cerrar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, -2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 85, 107, 47),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 85, 107, 47).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 85, 107, 47),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color.fromARGB(255, 153, 103, 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ],
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromocionCard({
    required String titulo,
    required String nombre,
    required String detalle,
    required IconData icono,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 153, 103, 8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _mostrarDetalleVenta(context),
      onHover: (value) {
        insIndexOnHover = value;
        // Redibuja el widget para reflejar el cambio de hover
        (context as Element).markNeedsBuild();
      },
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: indexOnHover(insIndexOnHover),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('dd/MM/yyyy hh:mm a').format(ventaTurnoModel.fecha),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$${ventaTurnoModel.precioTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$ee${ventaTurnoModel.descuentoAplicado}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$aa${ventaTurnoModel.precioDescuento}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 153, 103, 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
