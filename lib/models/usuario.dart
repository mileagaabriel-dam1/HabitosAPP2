//MODELO: una fila de la tabla usuarios
class Usuario {
  final String usuario; //Nombre con el que entra. No se repite, sirve de identificador (clave primaria)
  final String nombre;
  final String apellidos;
  final String email;
  final String contrasena;
  final int objetivo; //Hábitos que quiere hacer cada día
  final String fechaCreacion; //Se pone sola al registrarse: "2026-10-31"
  final String rol; //'administrador' o 'usuario'

  Usuario({
    required this.usuario,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.contrasena,
    required this.objetivo,
    required this.fechaCreacion,
    required this.rol,
  });

  //true solo si su rol es administrador. Es un getter: se usa como un campo (u.esAdmin) pero se calcula con el rol
  bool get esAdmin => rol == 'administrador';

  //BASE DE DATOS: convierte el usuario en un Map (columna → valor) para insertarlo o actualizarlo
  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'contrasena': contrasena,
      'objetivo': objetivo,
      'fecha_creacion': fechaCreacion, //la columna lleva _ y el campo va en camelCase
      'rol': rol,
    };
  }

  //BASE DE DATOS: lo contrario, crea un usuario con el Map de una fila leída con query
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      usuario: map['usuario'],
      nombre: map['nombre'],
      apellidos: map['apellidos'],
      email: map['email'],
      contrasena: map['contrasena'],
      objetivo: map['objetivo'],
      fechaCreacion: map['fecha_creacion'],
      rol: map['rol'],
    );
  }
}