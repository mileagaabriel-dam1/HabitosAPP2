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

  final String id;
  final String nombre;
  final String color; //Nombre del color 'Azul' porque un texto sí se puede pasar a JSON
  final String icono; //Nombre del icono 'Agua' por el mismo motivo
  final List<String> fechasCompletadas; //dias completados

  Habito({
    required this.id,
    required this.nombre,
    required this.color,
    required this.icono,
    required this.fechasCompletadas,
    //lo que necesita un habito
  });

  Map<String, dynamic> toJson() { //convierte el habito en un map
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'icono': icono,
      'fechasCompletadas': fechasCompletadas,
      //a la izquierda la clave y a la derecha el valor que corresponde a esa clave
    };
  }

  factory Habito.fromJson(Map<String, dynamic> json) { //recibe un map, el que sale de jsondecode, y crea un habito sacando el valor por su clave
    return Habito(
      id: json['id'],
      nombre: json['nombre'],
      color: json['color'],
      icono: json['icono'],
      fechasCompletadas: List<String>.from(json['fechasCompletadas']),
      //valores que contiene un habito
    );
  }
}