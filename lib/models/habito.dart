import 'package:flutter/material.dart';

class Habito {
  static const Map<String, Color> colores = { //se crea un tipo de mapa de colores
    'Azul': Colors.blue,
    'Verde': Colors.green,
    'Naranja': Colors.orange,
    //los colores que se pueden escoger
  };

  static const Map<String, IconData> iconos = {
    'Agua': Icons.water_drop,
    'Comida': Icons.lunch_dining,
    'Correr': Icons.directions_run,
    //iconos que se pueden escoger al crear un habito
  };

  final int? id; //null mientras no está guardado: el número lo pone la base de datos al insertarlo (AUTOINCREMENT)
  final String usuario;
  final String nombre;
  final String color; //Nombre del color 'Azul' porque un texto sí se puede pasar a JSON
  final String icono; //Nombre del icono 'Agua' por el mismo motivo
  final List<String> fechasCompletadas; //dias completados

  Habito({
    required this.id,
    required this.usuario,
    required this.nombre,
    required this.color,
    required this.icono,
    required this.fechasCompletadas,
    //lo que necesita un habito
  });

  Map<String, dynamic> toMap() { //convierte el habito en un map, para insertarlo o actualizarlo en la tabla habitos
    return {
      'id': id,
      'usuario': usuario,
      'nombre': nombre,
      'color': color,
      'icono': icono,
      'fechas': fechasCompletadas.join(','), //una columna no puede guardar una lista: se guarda como texto separado por comas "2026-10-30,2026-10-31"
      //a la izquierda la clave y a la derecha el valor que corresponde a esa clave
    };
  }

  factory Habito.fromMap(Map<String, dynamic> map) { //recibe un map, el de una fila leída de la tabla, y crea un habito sacando el valor por su clave
    String fechas = map['fechas'];
    return Habito(
      id: map['id'],
      usuario: map['usuario'],
      nombre: map['nombre'],
      color: map['color'],
      icono: map['icono'],
      fechasCompletadas: fechas.isEmpty ? [] : fechas.split(','), //split corta el texto por las comas. Si está vacío, lista vacía ("".split daría [""])
      //valores que contiene un habito
    );
  }
}