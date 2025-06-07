import 'dart:convert';

import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:flutter/material.dart';

class ProductoCard extends StatelessWidget {
  final ProductoModelo producto;
  final bool seleccionado;
  final bool sinStock; // NUEVO PARÁMETRO
  final VoidCallback onTap;

  const ProductoCard({
    Key? key,
    required this.producto,
    required this.seleccionado,
    required this.sinStock, // NUEVO PARÁMETRO REQUERIDO
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: sinStock
            ? Colors.grey.shade300 // Color gris si no hay stock
            : seleccionado
                ? Colors.blue.withOpacity(0.1)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sinStock
              ? Colors.grey.shade400 // Borde gris si no hay stock
              : seleccionado
                  ? Colors.blue
                  : Colors.grey.shade300,
          width: seleccionado ? 2 : 1,
        ),
        boxShadow: sinStock
            ? [] // Sin sombra si no hay stock
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: sinStock ? null : onTap, // Deshabilitar tap si no hay stock
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Imagen del producto
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: producto.urlImagen != null && producto.urlImagen!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            producto.urlImagen!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        )
                      : Icon(Icons.inventory_2, color: Colors.grey),
                ),
                const SizedBox(width: 16),

                // Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: sinStock ? Colors.grey.shade600 : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        producto.descripcion ?? 'Sin descripción',
                        style: TextStyle(
                          fontSize: 14,
                          color: sinStock ? Colors.grey.shade500 : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '\$${producto.precio.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: sinStock ? Colors.grey.shade600 : const Color.fromARGB(255, 153, 103, 8),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: sinStock
                                  ? Colors.red.withOpacity(0.2)
                                  : producto.cantidad < 10
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sinStock
                                  ? 'Sin stock'
                                  : 'Stock: ${producto.cantidad.toInt()}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sinStock
                                    ? Colors.red.shade700
                                    : producto.cantidad < 10
                                        ? Colors.orange.shade700
                                        : Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Indicador de selección o sin stock
                if (sinStock)
                  Icon(
                    Icons.block,
                    color: Colors.red.shade400,
                    size: 24,
                  )
                else if (seleccionado)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
