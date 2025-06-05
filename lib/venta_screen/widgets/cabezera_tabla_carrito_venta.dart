import 'dart:convert';

import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:flutter/material.dart';

class CabezeraTablaCarritoVenta extends StatelessWidget {
  const CabezeraTablaCarritoVenta({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: Colors.amber,
      child: const Row(children: [
        Expanded(
          flex: 4,
          child: Text(
            'Nombre del producto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Precio',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Descuento',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Cant.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Total',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 40), // Espacio para el botón eliminar
      ]),
    );
  }
}

class ProductoCard extends StatelessWidget {
  final ProductoModelo producto;
  final bool seleccionado;

  final VoidCallback? onTap;

  const ProductoCard({
    super.key,
    required this.producto,
    this.onTap,
    required this.seleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 180,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F1E7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Icon(
                  seleccionado
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: seleccionado ? Colors.black54 : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 80, // <--- Cambiado de 150 a 80
                height: 80, // <--- Cambiado de 150 a 80
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  color: (producto.urlImagen?.isEmpty ?? true)
                      ? Colors.grey[300]
                      : null,
                  image: (producto.urlImagen?.isNotEmpty ?? false)
                      ? DecorationImage(
                          image: Image.memory(base64Decode(producto.urlImagen!))
                              .image,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (producto.urlImagen?.isEmpty ?? true)
                    ? const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 32, color: Colors.grey), // <--- Más pequeño
                      )
                    : null,
              ),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '1 ${producto.unidadMedida}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cantidad disponible: ${producto.cantidad} ${producto.unidadMedida}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Precio sin descuento: \$${producto.precio}',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Descuento: \$${producto.descuento}',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Text(
                          'Total: \$${(producto.precio ?? 0) - (producto.descuento ?? 0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      ])
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
