class SucursalModelo {
  final int idSucursal;
  final String nombre;
  final String direccion;
  final bool eliminado;

  SucursalModelo({
    required this.idSucursal,
    required this.nombre,
    required this.direccion,
    required this.eliminado,
  });

  factory SucursalModelo.fromMap(Map<String, dynamic> map) {
    return SucursalModelo(
      idSucursal: map['id_sucursal'] ?? 0,
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      eliminado: map['eliminado'] == true || map['eliminado'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_sucursal': idSucursal,
      'nombre': nombre,
      'direccion': direccion,
      'eliminado': eliminado,
    };
  }
}

class AdministradorModelo {
  final int idUsuario;
  final String nombre;
  final String? correo;
  final String telefono; // Opcional
  final String contrasena;
  final String? imagen; // Opcional (base64)
  final int idSucursal;
  final String nombreSucursal;
  final bool statusDespido;
  final String rol;

  AdministradorModelo({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.contrasena,
    this.imagen,
    required this.idSucursal,
    required this.nombreSucursal,
    required this.statusDespido,
    required this.rol,
  });

  factory AdministradorModelo.fromMap(Map<String, dynamic> map) {
    return AdministradorModelo(
      idUsuario: map['id_usuario'] ?? 0,
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
      telefono: map['telefono'],
      contrasena: map['contrasena'] ?? '',
      imagen: map['imagen'],
      idSucursal: map['idSucursal'] ?? 0,
      nombreSucursal: map['nombre_sucursal'] ?? '',
      statusDespido: map['statusDespido'] == true || map['statusDespido'] == 1,
      rol: map['rol'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'contrasena': contrasena,
      'imagen': imagen,
      'idSucursal': idSucursal,
      'nombre_sucursal': nombreSucursal,
      'statusDespido': statusDespido,
      'rol': rol,
    };
  }
}