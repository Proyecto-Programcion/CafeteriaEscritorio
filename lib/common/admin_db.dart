import 'package:postgres/postgres.dart';

class Database {
  static late final Connection conn;

  static Future<void> connect() async {
    conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'prueba02',
        username: 'postgres',
        password: '211099',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    print('✅ Conexión establecida con PostgreSQL.');
    await _crearTablasSiNoExisten();
  }

  static Future<void> _crearTablasSiNoExisten() async {
    try {
      // Ejecutar cada sentencia SQL por separado
      final statements = [
        // TABLA USUARIOS
        '''
        CREATE TABLE IF NOT EXISTS usuarios (
          id_usuario SERIAL PRIMARY KEY,
          nombre VARCHAR,
          correo VARCHAR,
          telefono VARCHAR,
          contrasena VARCHAR,
          rol VARCHAR -- Admin o Empleado
        )
        ''',

        // TABLA CLIENTES
        '''
        CREATE TABLE IF NOT EXISTS clientes (
          id_cliente SERIAL PRIMARY KEY,
          nombre VARCHAR,
          telefono INT UNIQUE
        )
        ''',

        // TABLA CATEGORIAS
        '''
        CREATE TABLE IF NOT EXISTS categorias (
          id_categoria SERIAL PRIMARY KEY,
          id_usuario INT,
          nombre VARCHAR,
          eliminado BOOLEAN DEFAULT FALSE,
        )
        ''',

        // TABLA PRODUCTOS
        '''
        CREATE TABLE IF NOT EXISTS productos (
          id_producto SERIAL PRIMARY KEY,
          id_categoria INT,
          id_usuario INT,
          nombre VARCHAR NOT NULL,
          cantidad DOUBLE PRECISION,
          precio DOUBLE PRECISION NOT NULL,
          costo DOUBLE PRECISION,
          descuento DOUBLE PRECISION,
          codigo_de_barras VARCHAR,
          url_imagen VARCHAR,
          eliminado BOOLEAN DEFAULT FALSE,
          descripcion VARCHAR,
          unidad_medida VARCHAR -- kilo, tonelada, gramo, pieza
        )
        ''',

        // TABLA INGRESOPRODUCTO
        '''
        CREATE TABLE IF NOT EXISTS ingresoproducto (
          id_ingreso_producto SERIAL PRIMARY KEY,
          id_usuario INT,
          precio_total DOUBLE PRECISION,
          fecha VARCHAR
        )
        ''',

        // TABLA DETALLESINGRESOPRODUCTO
        '''
        CREATE TABLE IF NOT EXISTS detallessingresoproducto (
          id_ingreso_detalle_producto SERIAL PRIMARY KEY,
          id_ingreso_producto INT,
          id_producto INT,
          cantidad DOUBLE PRECISION,
          precio DOUBLE PRECISION,
          fecha VARCHAR
        )
        ''',

        // TABLA VENTAS
        '''
        CREATE TABLE IF NOT EXISTS ventas (
          id_venta SERIAL PRIMARY KEY,
          id_usuario INT,
          id_cliente INT,
          id_cupon INT,
          precio_total DOUBLE PRECISION,
          precio_descuento DOUBLE PRECISION,
          fecha VARCHAR,
          status_compra BOOLEAN
        )
        ''',

        // TABLA DETALLESVENTA
        '''
        CREATE TABLE IF NOT EXISTS detallesventa (
          id_detalle_venta SERIAL PRIMARY KEY,
          id_venta INT,
          id_producto INT,
          id_promocion INT,
          precio DOUBLE PRECISION,
          cantidad DOUBLE PRECISION,
          precio_total DOUBLE PRECISION,
          precio_descuento DOUBLE PRECISION
        )
        ''',

        // TABLA CUPONES
        '''
        CREATE TABLE IF NOT EXISTS cupones (
          id_cupon SERIAL PRIMARY KEY,
          id_usuario INT,
          id_cliente INT,
          porcentaje DOUBLE PRECISION,
          cantidad DOUBLE PRECISION,
          codigo VARCHAR,
          fecha_inicio VARCHAR,
          fecha_termino VARCHAR,
          uso_maximo INT,
          status BOOLEAN
        )
        ''',

        // TABLA PROMOCION
        '''
        CREATE TABLE IF NOT EXISTS promocion (
          id_promocion SERIAL PRIMARY KEY,
          id_usuario INT,
          id_cliente INT,
          descripcion VARCHAR,
          porcentaje INT,
          cantidad DOUBLE PRECISION,
          codigo VARCHAR,
          fecha_inicio VARCHAR,
          fecha_termino VARCHAR,
          uso_maximo INT,
          status BOOLEAN
        )
        ''',
      ];

      // Ejecutar cada sentencia por separado
      for (final sql in statements) {
        await conn.execute(sql);
      }

      print('✅ Tablas e índices creados o ya existen.');
    } catch (e) {
      print('❌ Error al crear las tablas: $e');
      rethrow;
    }
  }

  static Future<void> execute(String sql) async {
    try {
      await conn.execute(sql);
      print('✅ Consulta ejecutada: $sql');
    } catch (e) {
      print('❌ Error al ejecutar la consulta: $e');
    }
  }

  static Future<void> close() async {
    await conn.close();
    print('🔌 Conexión cerrada.');
  }
}
