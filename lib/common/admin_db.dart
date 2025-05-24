import 'package:postgres/postgres.dart';

class Database {
  static late final Connection conn;

  static Future<void> connect() async {
    conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'cafe',
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
        correo VARCHAR UNIQUE,
        telefono VARCHAR UNIQUE,
        contrasena VARCHAR,
        imagen VARCHAR,
        idSucursal INT,
        statusDespedido BOOLEAN DEFAULT FALSE,
        rol VARCHAR -- Admin o Empleado
      )
      ''',
        // TABLA SUCURSALES
        '''
        CREATE TABLE IF NOT EXISTS sucursales (
          id_sucursal SERIAL PRIMARY KEY,
          nombre VARCHAR,
          direccion VARCHAR,
          eliminado BOOLEAN DEFAULT FALSE
        )
        ''',

        // TABLA CLIENTES
        '''
        CREATE TABLE IF NOT EXISTS clientes (
          id_cliente SERIAL PRIMARY KEY,
          nombre VARCHAR,
          telefono VARCHAR UNIQUE,
          cantidad_compras INT DEFAULT 0
        )
        ''',

        // TABLA CATEGORIAS
        '''
      CREATE TABLE IF NOT EXISTS categorias (
        id_categoria SERIAL PRIMARY KEY,
        id_usuario INT,
        nombre VARCHAR UNIQUE,
        eliminado BOOLEAN DEFAULT FALSE
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
        codigo_de_barras VARCHAR UNIQUE,
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
        id_promocion INT,
        id_promocion_productos_gratis INT,
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

        // TABLA PROMOCION
        '''
        CREATE TABLE IF NOT EXISTS promocion (
          id_promocion SERIAL PRIMARY KEY,
          nombrePromocion VARCHAR,
          descripcion VARCHAR,
          porcentaje DOUBLE PRECISION,
          comprasNecesarias INT,
          dineroNecesario DOUBLE PRECISION,
          topeDescuento DOUBLE PRECISION,
          status BOOLEAN,
          eliminado BOOLEAN DEFAULT FALSE
        )
        ''',
        //TABLA DE PROMOCION PRODUCTO GRATIS
        '''
        CREATE TABLE IF NOT EXISTS promocion_producto_gratis (
          id_promocion_productos_gratis SERIAL PRIMARY KEY,
          nombre_promocion VARCHAR,
          descripcion VARCHAR,
          id_producto INT,
          compras_necesarias INT,
          dinero_necesario DOUBLE PRECISION,
          status BOOLEAN,
          cantidad_producto DOUBLE PRECISION,
          eliminado BOOLEAN DEFAULT FALSE,
          FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE
        )
        ''',

        // RELACIONES
        '''
      DO \$\$
      BEGIN
        -- Relaciones para categorias
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_categorias_usuario') THEN
          ALTER TABLE categorias ADD CONSTRAINT fk_categorias_usuario
          FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE;
        END IF;
        
        -- Relaciones para productos
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_productos_categoria') THEN
          ALTER TABLE productos ADD CONSTRAINT fk_productos_categoria
          FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria) ON DELETE CASCADE;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_productos_usuario') THEN
          ALTER TABLE productos ADD CONSTRAINT fk_productos_usuario
          FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE;
        END IF;
        
        -- Relaciones para ingresoproducto
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_ingresoproducto_usuario') THEN
          ALTER TABLE ingresoproducto ADD CONSTRAINT fk_ingresoproducto_usuario
          FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE;
        END IF;
        
        -- Relaciones para detallessingresoproducto
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_detallesingreso_ingresoproducto') THEN
          ALTER TABLE detallessingresoproducto ADD CONSTRAINT fk_detallesingreso_ingresoproducto
          FOREIGN KEY (id_ingreso_producto) REFERENCES ingresoproducto(id_ingreso_producto) ON DELETE CASCADE;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_detallesingreso_producto') THEN
          ALTER TABLE detallessingresoproducto ADD CONSTRAINT fk_detallesingreso_producto
          FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE;
        END IF;
        
        -- Relaciones para ventas
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_ventas_usuario') THEN
          ALTER TABLE ventas ADD CONSTRAINT fk_ventas_usuario
          FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_ventas_cliente') THEN
          ALTER TABLE ventas ADD CONSTRAINT fk_ventas_cliente
          FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_ventas_promocion') THEN
          ALTER TABLE ventas ADD CONSTRAINT fk_ventas_promocion
          FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion) ON DELETE SET NULL;
        END IF;
        
        -- Relaciones para detallesventa
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_detallesventa_venta') THEN
          ALTER TABLE detallesventa ADD CONSTRAINT fk_detallesventa_venta
          FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) ON DELETE CASCADE;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_detallesventa_producto') THEN
          ALTER TABLE detallesventa ADD CONSTRAINT fk_detallesventa_producto
          FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_detallesventa_promocion') THEN
          ALTER TABLE detallesventa ADD CONSTRAINT fk_detallesventa_promocion
          FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion) ON DELETE SET NULL;
        END IF;
      END
      \$\$;
      '''
      ];

      // Ejecutar cada sentencia por separado
      for (final sql in statements) {
        await conn.execute(sql);
      }

      print('✅ Tablas, relaciones e índices creados o ya existen.');
    } catch (e) {
      print('❌ Error al crear las tablas o relaciones: $e');
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
