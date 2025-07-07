import 'package:cafe/common/admin_db.dart';
import 'package:postgres/postgres.dart';

class PromocionesCanjeadasService {
  
  // Verificar si un cliente ya canjeó una promoción de descuento
  static Future<bool> clienteYaCanjeoPromocion(int idCliente, int idPromocion) async {
    try {
      final sql = Sql.named('''
        SELECT EXISTS(
          SELECT 1 
          FROM clientes_promociones_canjeadas cpc
          JOIN promocion p ON cpc.id_promocion = p.id_promocion
          WHERE cpc.id_cliente = @id_cliente 
            AND cpc.id_promocion = @id_promocion
            AND p.status = TRUE
            AND p.eliminado = FALSE
        ) as ya_canjeo
      ''');

      final result = await Database.conn.execute(sql, parameters: {
        'id_cliente': idCliente,
        'id_promocion': idPromocion,
      });

      return result.first[0] as bool;
    } catch (e) {
      print('Error verificando promoción canjeada: $e');
      return false; // En caso de error, permitir la promoción
    }
  }
  
  // Verificar si un cliente ya canjeó una promoción de producto gratis
  static Future<bool> clienteYaCanjeoPromocionGratis(int idCliente, int idPromocionGratis) async {
    try {
      final sql = Sql.named('''
        SELECT EXISTS(
          SELECT 1 
          FROM clientes_promociones_productos_gratis_canjeadas cpgc
          JOIN promocion_producto_gratis ppg ON cpgc.id_promocion_productos_gratis = ppg.id_promocion_productos_gratis
          WHERE cpgc.id_cliente = @id_cliente 
            AND cpgc.id_promocion_productos_gratis = @id_promocion_gratis
            AND ppg.status = TRUE
            AND ppg.eliminado = FALSE
        ) as ya_canjeo
      ''');

      final result = await Database.conn.execute(sql, parameters: {
        'id_cliente': idCliente,
        'id_promocion_gratis': idPromocionGratis,
      });

      return result.first[0] as bool;
    } catch (e) {
      print('Error verificando promoción de producto gratis canjeada: $e');
      return false; // En caso de error, permitir la promoción
    }
  }
}