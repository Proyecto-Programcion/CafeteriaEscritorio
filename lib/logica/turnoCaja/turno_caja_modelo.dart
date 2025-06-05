



class TurnoCajaModelo {
  int idTurnoCaja;
  int idUsuario;
  String nombreUsuario;
  String fechaInicio;
  String? fechaFin;
  double montoApertura;
  double? montoCierre;
  String estado;
  int numeroVentas;
  double totalVentas;
  double descuentoAplicado;
  double totalVentasConDescuento;

  TurnoCajaModelo({
    required this.idTurnoCaja,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.fechaInicio,
    required this.fechaFin,
    required this.montoApertura,
    required this.montoCierre,
    required this.estado,
    required this.numeroVentas,
    required this.totalVentas,
    required this.descuentoAplicado,
    required this.totalVentasConDescuento,
  });

  
}