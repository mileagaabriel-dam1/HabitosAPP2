import 'package:flutter/material.dart';

//COMPONENTE: campo de texto con el mismo diseño en toda la app.
//La pantalla crea el controller y se lo pasa; el campo solo lo usa.
class CampoTextoApp extends StatelessWidget {
  final String etiqueta;
  final TextEditingController controller;
  final bool ocultar; //true para contraseñas: no se ve lo que se escribe

  const CampoTextoApp({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.ocultar = false, //Valor por defecto: si no se pasa, se ve el texto
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: ocultar,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}