//MODELO: los datos de un usuario de la app
class Usuario {
  final String usuario; //Nombre con el que entra. No se repite, sirve de identificador
  final String contrasena;
  final int objetivo; //Hábitos que quiere hacer cada día
  final bool esAdmin; //true solo para la cuenta admin
  final String fechaCreacion; //Se pone sola al registrarse: "2026-10-31"

  Usuario({
    required this.usuario,
    required this.contrasena,
    required this.objetivo,
    required this.esAdmin,
    required this.fechaCreacion,
  });

  //PERSISTENCIA: convierte el usuario en un Map, para pasarlo a texto con jsonEncode
  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'contrasena': contrasena,
      'objetivo': objetivo,
      'esAdmin': esAdmin,
      'fechaCreacion': fechaCreacion,
    };
  }

  //PERSISTENCIA: lo contrario, crea un usuario a partir del Map que da jsonDecode
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuario: json['usuario'],
      contrasena: json['contrasena'],
      objetivo: json['objetivo'],
      esAdmin: json['esAdmin'],
      fechaCreacion: json['fechaCreacion'],
    );
  }
}