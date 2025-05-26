class SesionActiva {
  // 1. Instancia estática privada: se crea una sola vez y se guarda aquí.
  static final SesionActiva _instancia = SesionActiva._interna();

  // 2. Constructor privado: impide que otros creen instancias con 'new SesionActiva()'.
  SesionActiva._interna();

  // 3. Factory constructor: cada vez que haces 'SesionActiva()', retorna la misma instancia.
  factory SesionActiva() {
    return _instancia;
  }

  // 4. Variables de instancia: puedes guardar datos aquí y serán compartidos en toda la app.
  int? idUsuario;
  String? nombreUsuario;
  String? rolUsuario;
  int? idSucursal;
  int? idTurnoCaja = 0;

  // Método para limpiar todos los atributos
  void limpiarSesion() {
    idUsuario = null;
    nombreUsuario = null;
    rolUsuario = null;
    idSucursal = null;
    // idTurnoCaja = null;
  }
}
