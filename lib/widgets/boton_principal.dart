import 'package:flutter/material.dart';

//COMPONENTE: botón de las acciones principales (entrar, registrarse, guardar...).
//Cambiando el estilo aquí, cambian todos los botones principales de la app.
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback alPulsar; //La acción la decide la pantalla que lo usa

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    //SizedBox con double.infinity: el botón ocupa todo el ancho
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: alPulsar,
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
        child: Text(texto, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}