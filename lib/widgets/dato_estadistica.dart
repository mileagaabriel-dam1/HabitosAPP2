import 'package:flutter/material.dart';

//COMPONENTE: un dato estadístico (icono, valor y etiqueta).
//Sirve para cualquier dato: solo cambian los valores que recibe.
class DatoEstadistica extends StatelessWidget {
  final String etiqueta; //"Racha actual", "Días completados"...
  final String valor;
  final IconData icono;
  final Color color;

  const DatoEstadistica({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.icono,
    this.color = Colors.blue, //Valor por defecto si no se pasa ninguno
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icono, color: color, size: 32),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(etiqueta),
        ],
      ),
    );
  }
}