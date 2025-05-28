import 'package:cafe/common/admin_db.dart';
import 'package:postgres/postgres.dart';

class PromocionesCanjeadasService {
  
  // Verificar si un cliente ya canjeó una promoción de descuento
  static Future<bool> clienteYaCanjeoPromocion(int idCliente, int idPromocion) async {
    try {
      final sql = Sql.named('''
        SELECT EXISTS(
          SELECT 1 FROM clientes_promociones_canjeadas 
          WHERE id_cliente = @id_cliente AND id_promocion = @id_promocion
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
          SELECT 1 FROM clientes_promociones_productos_gratis_canjeadas 
          WHERE id_cliente = @id_cliente AND id_promocion_productos_gratis = @id_promocion_gratis
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