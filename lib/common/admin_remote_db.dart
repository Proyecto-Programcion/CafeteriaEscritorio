import 'package:postgres/postgres.dart';

class DatabaseRemote {
  static late final Connection conn;

  static Future<void> connect() async {
    conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'cafe',
        username: 'postgres',
        password: '13960',
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

        '''
        CREATE TABLE IF NOT EXISTS categoriaControlGastos (
          idCategoria SERIAL PRIMARY KEY,
          nombre VARCHAR(50) NOT NULL UNIQUE,
          descripcion VARCHAR(200)
        )
        ''',

        '''
        CREATE TABLE IF NOT EXISTS controlGastos (
            idGasto SERIAL PRIMARY KEY,
            idCategoria INTEGER NOT NULL,
            descripcion VARCHAR(255) NOT NULL,
            monto NUMERIC(10,2) NOT NULL,
            fechaGasto DATE NOT NULL,
            metodoPago VARCHAR(50) DEFAULT 'Efectivo',
            notas TEXT,
            ubicacion VARCHAR(255),
            CONSTRAINT fk_controlGastos_categoria 
              FOREIGN KEY (idCategoria) REFERENCES categoriaControlGastos(idCategoria) 
              ON DELETE RESTRICT ON UPDATE CASCADE
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

        // TABLA TURNOS_CAJA
        '''
        CREATE TABLE IF NOT EXISTS turnos_caja (
          id SERIAL PRIMARY KEY,
          id_usuario INT,
          fecha_inicio TIMESTAMP,
          fecha_fin TIMESTAMP,
          monto_inicial NUMERIC(10,2),
          monto_final NUMERIC(10,2),
          activo BOOLEAN DEFAULT TRUE,
          CONSTRAINT fk_turnos_caja_usuario 
            FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) 
            ON DELETE CASCADE
        )
        ''',

        // TABLA CATEGORIAS
        '''
      CREATE TABLE IF NOT EXISTS categorias (
        id_categoria SERIAL PRIMARY KEY,
        id_usuario INT,
        nombre VARCHAR UNIQUE,
        eliminado BOOLEAN DEFAULT FALSE,
        CONSTRAINT fk_categorias_usuario 
          FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) 
          ON DELETE CASCADE
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
        unidad_medida VARCHAR, -- kilo, tonelada, gramo, pieza
        CONSTRAINT fk_productos_categoria 
          FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria) 
          ON DELETE CASCADE,
        CONSTRAINT fk_productos_usuario 
          FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) 
          ON DELETE CASCADE
      )
      ''',

        // Agregar esta sección al array statements:
        '''
          CREATE TABLE IF NOT EXISTS controlStock (
              id SERIAL PRIMARY KEY,
              id_producto INT NOT NULL,
              cantidad_antes DOUBLE PRECISION NOT NULL,
              cantidad_movimiento DOUBLE PRECISION NOT NULL,
              cantidad_despues DOUBLE PRECISION NOT NULL,
              unidad_medida VARCHAR(50),
              categoria VARCHAR(20) NOT NULL CHECK (categoria IN ('agregado', 'vendido', 'actualizado')),
              id_usuario INT NOT NULL,
              fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              CONSTRAINT fk_controlStock_producto 
                  FOREIGN KEY (id_producto) REFERENCES productos(id_producto) 
                  ON DELETE CASCADE,
              CONSTRAINT fk_controlStock_usuario 
                  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) 
                  ON DELETE CASCADE
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
          CONSTRAINT fk_promocion_productos_gratis_producto 
            FOREIGN KEY (id_producto) REFERENCES productos(id_producto) 
            ON DELETE CASCADE
        )
        ''',

        // TABLA VENTAS
        '''
      CREATE TABLE IF NOT EXISTS ventas (
        id_venta SERIAL PRIMARY KEY,
        id_usuario INT,
        id_sucursal INT,
        id_turno_caja INT,
        id_cliente INT,
        id_promocion INT,
        id_promocion_productos_gratis INT,
        precio_total DOUBLE PRECISION,
        precio_descuento DOUBLE PRECISION,
        descuento_aplicado DOUBLE PRECISION,
        fecha VARCHAR,
        status_compra BOOLEAN,
        CONSTRAINT fk_ventas_usuario 
          FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) 
          ON DELETE CASCADE,
        CONSTRAINT fk_ventas_cliente 
          FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) 
          ON DELETE SET NULL,
        CONSTRAINT fk_ventas_promocion 
          FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion) 
          ON DELETE SET NULL,
        CONSTRAINT fk_ventas_turno_caja 
          FOREIGN KEY (id_turno_caja) REFERENCES turnos_caja(id) 
          ON DELETE SET NULL,
        CONSTRAINT fk_ventas_promocion_productos_gratis 
          FOREIGN KEY (id_promocion_productos_gratis) REFERENCES promocion_producto_gratis(id_promocion_productos_gratis) 
          ON DELETE SET NULL
      )
      ''',

        // TABLA detalle_ventas
        '''
         CREATE TABLE IF NOT EXISTS detalle_ventas (
          id_detalle SERIAL PRIMARY KEY,
          id_venta INT,
          id_producto INT,
          cantidad DOUBLE PRECISION,
          precio_unitario DOUBLE PRECISION,
          descuento_unitario DOUBLE PRECISION,
          CONSTRAINT fk_detalle_ventas_venta 
            FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) 
            ON DELETE CASCADE,
          CONSTRAINT fk_detalle_ventas_producto 
            FOREIGN KEY (id_producto) REFERENCES productos(id_producto) 
            ON DELETE CASCADE
        )
        ''',

        '''
        -- Tabla para promociones de descuento canjeadas
          CREATE TABLE IF NOT EXISTS clientes_promociones_canjeadas (
              id SERIAL PRIMARY KEY,
              id_cliente INT NOT NULL,
              id_promocion INT NOT NULL,
              id_venta INT NOT NULL, -- Para trazabilidad
              fecha_canje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              CONSTRAINT fk_clientes_promociones_cliente 
                  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE,
              CONSTRAINT fk_clientes_promociones_promocion 
                  FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion) ON DELETE CASCADE,
              CONSTRAINT fk_clientes_promociones_venta 
                  FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) ON DELETE CASCADE,
              -- Evitar duplicados
              CONSTRAINT unique_cliente_promocion UNIQUE (id_cliente, id_promocion)
          )
        ''',

        '''
          -- Tabla para promociones de productos gratis canjeadas
          CREATE TABLE IF NOT EXISTS clientes_promociones_productos_gratis_canjeadas (
              id SERIAL PRIMARY KEY,
              id_cliente INT NOT NULL,
              id_promocion_productos_gratis INT NOT NULL,
              id_venta INT NOT NULL, -- Para trazabilidad
              fecha_canje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              cantidad_canjeada DOUBLE PRECISION DEFAULT 1, -- Por si puede canjear múltiples veces
              CONSTRAINT fk_clientes_promo_gratis_cliente 
                  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE,
              CONSTRAINT fk_clientes_promo_gratis_promocion 
                  FOREIGN KEY (id_promocion_productos_gratis) REFERENCES promocion_producto_gratis(id_promocion_productos_gratis) ON DELETE CASCADE,
              CONSTRAINT fk_clientes_promo_gratis_venta 
                  FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) ON DELETE CASCADE,
              -- Evitar duplicados (o permitir múltiples si es necesario)
              CONSTRAINT unique_cliente_promo_gratis UNIQUE (id_cliente, id_promocion_productos_gratis)
          )
        ''',

        '''
          CREATE INDEX IF NOT EXISTS idx_clientes_promociones_cliente ON clientes_promociones_canjeadas(id_cliente)
          ''',

        '''
          CREATE INDEX IF NOT EXISTS idx_clientes_promociones_gratis_cliente ON clientes_promociones_productos_gratis_canjeadas(id_cliente)
        ''',

        '''
        CREATE INDEX IF NOT EXISTS idx_controlStock_producto ON controlStock(id_producto)
        ''',

        '''
        CREATE INDEX IF NOT EXISTS idx_controlStock_fecha ON controlStock(fecha)
        ''',

        '''
        CREATE INDEX IF NOT EXISTS idx_controlStock_categoria ON controlStock(categoria)
        ''',

        '''
        -- Función para incrementar compras del cliente
        CREATE OR REPLACE FUNCTION incrementar_compras_cliente()
        RETURNS TRIGGER AS \$\$
        BEGIN
            -- Solo incrementar si la venta tiene un cliente asignado y el status_compra es TRUE
            IF NEW.id_cliente IS NOT NULL AND NEW.status_compra = TRUE THEN
                -- Si es un INSERT o si se está cambiando el status_compra de FALSE a TRUE
                IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.status_compra = FALSE AND NEW.status_compra = TRUE) THEN
                    UPDATE clientes 
                    SET cantidad_compras = cantidad_compras + 1
                    WHERE id_cliente = NEW.id_cliente;
                END IF;
                
                -- Si es un UPDATE y se está cambiando el status_compra de TRUE a FALSE (cancelar venta)
                IF TG_OP = 'UPDATE' AND OLD.status_compra = TRUE AND NEW.status_compra = FALSE THEN
                    UPDATE clientes 
                    SET cantidad_compras = GREATEST(cantidad_compras - 1, 0)
                    WHERE id_cliente = NEW.id_cliente;
                END IF;
                
                -- Si es un UPDATE y se cambió el cliente (de un cliente a otro)
                IF TG_OP = 'UPDATE' AND OLD.id_cliente IS NOT NULL AND OLD.id_cliente != NEW.id_cliente AND OLD.status_compra = TRUE THEN
                    -- Decrementar del cliente anterior
                    UPDATE clientes 
                    SET cantidad_compras = GREATEST(cantidad_compras - 1, 0)
                    WHERE id_cliente = OLD.id_cliente;
                END IF;
            END IF;
            
            -- Si se está eliminando una venta y tenía cliente asignado con status_compra TRUE
            IF TG_OP = 'DELETE' AND OLD.id_cliente IS NOT NULL AND OLD.status_compra = TRUE THEN
                UPDATE clientes 
                SET cantidad_compras = GREATEST(cantidad_compras - 1, 0)
                WHERE id_cliente = OLD.id_cliente;
                RETURN OLD;
            END IF;
            
            RETURN NEW;
        END;
        \$\$ LANGUAGE plpgsql
        ''',

        '''
        -- Crear el trigger si no existe
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_incrementar_compras_cliente') THEN
                CREATE TRIGGER trigger_incrementar_compras_cliente
                    AFTER INSERT OR UPDATE OR DELETE ON ventas
                    FOR EACH ROW
                    EXECUTE FUNCTION incrementar_compras_cliente();
            END IF;
        END
        \$\$
        ''',

        '''
        -- Crear el trigger si no existe
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_incrementar_compras_cliente') THEN
                CREATE TRIGGER trigger_incrementar_compras_cliente
                    AFTER INSERT OR UPDATE OR DELETE ON ventas
                    FOR EACH ROW
                    EXECUTE FUNCTION incrementar_compras_cliente();
            END IF;
        END
        \$\$
        ''',

        // AGREGAR AQUÍ EL NUEVO TRIGGER
        '''
        -- Función para registrar promociones canjeadas automáticamente
        CREATE OR REPLACE FUNCTION registrar_promociones_canjeadas()
        RETURNS TRIGGER AS \$\$
        BEGIN
            -- Si es INSERT de una venta con cliente y promoción de descuento
            IF TG_OP = 'INSERT' AND NEW.id_cliente IS NOT NULL AND NEW.id_promocion IS NOT NULL AND NEW.status_compra = TRUE THEN
                INSERT INTO clientes_promociones_canjeadas (id_cliente, id_promocion, id_venta)
                VALUES (NEW.id_cliente, NEW.id_promocion, NEW.id_venta)
                ON CONFLICT (id_cliente, id_promocion) DO NOTHING; -- Evitar duplicados
            END IF;
            
            -- Si es INSERT de una venta con cliente y promoción de producto gratis
            IF TG_OP = 'INSERT' AND NEW.id_cliente IS NOT NULL AND NEW.id_promocion_productos_gratis IS NOT NULL AND NEW.status_compra = TRUE THEN
                INSERT INTO clientes_promociones_productos_gratis_canjeadas (id_cliente, id_promocion_productos_gratis, id_venta)
                VALUES (NEW.id_cliente, NEW.id_promocion_productos_gratis, NEW.id_venta)
                ON CONFLICT (id_cliente, id_promocion_productos_gratis) DO NOTHING; -- Evitar duplicados
            END IF;
            
            RETURN NEW;
        END;
        \$\$ LANGUAGE plpgsql
        ''',

        '''
        -- Crear el trigger para registrar promociones canjeadas
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_registrar_promociones_canjeadas') THEN
                CREATE TRIGGER trigger_registrar_promociones_canjeadas
                    AFTER INSERT ON ventas
                    FOR EACH ROW
                    EXECUTE FUNCTION registrar_promociones_canjeadas();
            END IF;
        END
        \$\$
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
      print('✅REMOTE: Consulta ejecutada: $sql');
    } catch (e) {
      print('❌REMOTE: Error al ejecutar la consulta: $e');
    }
  }

  static Future<void> close() async {
    await conn.close();
    print('🔌REMOTE: Conexión cerrada.');
  }
}
