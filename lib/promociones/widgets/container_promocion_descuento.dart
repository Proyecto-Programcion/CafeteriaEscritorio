import 'package:cafe/logica/promociones/promocionModel.dart';
import 'package:cafe/promociones/widgets/modal_actualizar_promocion_descuento.dart';
import 'package:flutter/material.dart';

class ContenedorPromocionDescuento extends StatelessWidget {
  final Promocion promocion;
  const ContenedorPromocionDescuento({
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
              return ModalActualizarPromocionDescuento(promocion: promocion);
            });
      },
      child: Card(
        color: promocion.status ? const Color(0xFFFFF8E1) : Colors.grey[300],
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
              const Icon(Icons.local_offer, color: Color(0xFF9B7B22), size: 28),
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
                        _chipPromo("${promocion.porcentaje}% de descuento"),
                        _chipPromo(
                            "Tope de descuento: ${promocion.topeDescuento}"),
                        _chipPromo(
                            "Compras necesarias: ${promocion.comprasNecesarias}"),
                        _chipPromo(
                            "Dinero necesario: ${promocion.dineroNecesario}"),
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
