import 'package:flutter/material.dart';

class TarjetaDeInformacionRapidaWidgets extends StatelessWidget {
  final String titulo;
  final String informacion;
  final String? imagenUrl;
  const TarjetaDeInformacionRapidaWidgets({
    super.key,
    required this.titulo,
    required this.informacion,
    this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 120,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 170,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 153, 103, 8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
            child: Center(
              child: imagenUrl != null
                  ? SizedBox(width: 80, height: 80, child: Image.asset(imagenUrl!, fit: BoxFit.scaleDown))
                  : const Icon(Icons.image, size: 48, color: Colors.white),
            ),
          ),
          Container(
            width: 330,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    informacion,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
