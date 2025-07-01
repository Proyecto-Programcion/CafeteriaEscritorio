import 'dart:convert';
import 'dart:io';

import 'package:cafe/logica/productos/producto_modelos.dart';

class AdminImpresora {
  static AdminImpresora? _instance;

  AdminImpresora._internal();

  factory AdminImpresora() {
    _instance ??= AdminImpresora._internal();
    return _instance!;
  }

  static AdminImpresora get instance {
    _instance ??= AdminImpresora._internal();
    return _instance!;
  }

  static Future<void> imprimirTicket({
    String puerto = 'USB002',
    required List<ProductoCarrito> carrito,
    required double totalVenta,
    required double? descuento,
    double? promocionDescuento,
  }) async {
    String nombreArchivo = 'ticket_temp.txt';
    
    try {
      final tempDir = Directory.systemTemp;
      final file = await File('${tempDir.path}/$nombreArchivo').create();

      // Calcular totales
      double subtotal = carrito.fold(0.0, (suma, item) => suma + (item.producto.precio * item.cantidad));
      
      // Descuentos individuales por producto (ya vienen como positivos)
      double descuentosProductos = carrito.fold(0.0, (suma, item) => suma + ((item.producto.descuento ?? 0) * item.cantidad));
      
      // Promoción (viene positiva, la convertimos a negativa para el cálculo)
      double promocionAplicada = promocionDescuento ?? 0;
      
      // Total de descuentos (ambos como positivos para mostrar)
      double totalDescuentos = descuentosProductos + promocionAplicada;
      
      // Cálculo final: subtotal menos todos los descuentos
      double totalFinal = subtotal - totalDescuentos;

      // Ticket usando los productos REALES del carrito
      String ticketPrueba = '''
================================
        CAFE PAQUITO
         Cafeteria
================================

Fecha: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}
Hora: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}
Ticket: #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}

================================
           PRODUCTOS
================================

${carrito.map((producto) {
        String nombreLimpio = producto.producto.nombre;
        String descripcionLimpia = producto.producto.descripcion ?? "Sin descripcion";
        double precioUnitario = producto.producto.precio;
        double descuentoUnitario = producto.producto.descuento ?? 0;
        double totalProducto = (precioUnitario - descuentoUnitario) * producto.cantidad;
        
        return '${producto.cantidad}x $nombreLimpio\n'
            '   Precio unitario: \$${precioUnitario.toStringAsFixed(2)}\n'
            '   Descuento: \$${descuentoUnitario.toStringAsFixed(2)}\n'
            '   Subtotal: \$${totalProducto.toStringAsFixed(2)}\n'
            '   ----------------------\n';
      }).join('')}

================================
Subtotal:              \$${subtotal.toStringAsFixed(2)}
Descuento productos:   -\$${descuentosProductos.toStringAsFixed(2)}
Promocion aplicada:    -\$${promocionAplicada.toStringAsFixed(2)}
================================
TOTAL A PAGAR:         \$${totalFinal.toStringAsFixed(2)}
================================
''';

      final ancho = 32;
      final List<String> lineas = [];
      final palabras = ticketPrueba.split('\n');
      for (final linea in palabras) {
        int i = 0;
        while (i < linea.length) {
          lineas.add(linea.substring(
              i, (i + ancho > linea.length) ? linea.length : i + ancho));
          i += ancho;
        }
      }

      String textoLimpio = lineas.join('\r\n') + '\r\n\r\n\r\n';

      // Limpiar caracteres problemáticos
      textoLimpio = textoLimpio.replaceAll('¡', '!');
      textoLimpio = textoLimpio.replaceAll('ó', 'o');
      textoLimpio = textoLimpio.replaceAll('é', 'e');
      textoLimpio = textoLimpio.replaceAll('í', 'i');
      textoLimpio = textoLimpio.replaceAll('á', 'a');
      textoLimpio = textoLimpio.replaceAll('ú', 'u');
      textoLimpio = textoLimpio.replaceAll('ñ', 'n');

      await file.writeAsString(textoLimpio, encoding: utf8);


      


      final rutaArchivo = file.path.replaceAll('/', '\\');
      final nombreCompartido = r'\\localhost\printtest';



      final result = await Process.run(
        'cmd',
        ['/c', 'copy', '/b', rutaArchivo, nombreCompartido],
        runInShell: true,
      );

      if (result.stderr.isNotEmpty) {
      }

      await file.delete();
      print('Archivo eliminado');
    } catch (e) {
      print('Error al imprimir ticket: $e');
      try {
        final file = File(nombreArchivo);
        if (await file.exists()) {
          await file.delete();
          print('Archivo temporal eliminado después del error');
        }
      } catch (deleteError) {
        print('Error al eliminar archivo temporal: $deleteError');
      }
    }
  }
}
