import 'package:flutter/material.dart'; //widgets de flutter
import '../models/habito.dart'; //import de la clase habito.dart

class HabitoTile extends StatelessWidget {  //widget de la ficha, stateless porque no cambia nada, solo dibuja lo que se le pase
  final Habito habito; //el habito que tiene que dibujar
  final bool hecho; //boolean de si esta hecha o no
  final void Function(bool?) alMarcar;
  final void Function() alEditar;
  final void Function() alBorrar;
//funciones de que hacer cuando se pulsen las casillas o botones

  const HabitoTile({ //el constructor, que obliga a pasarle las cinco cosas al crear la ficha
    super.key,
    required this.habito,
    required this.hecho,
    required this.alMarcar,
    required this.alEditar,
    required this.alBorrar,
  });

  @override
  Widget build(BuildContext context) { //se dibuja la ficha
    return Card( //recuadro con sombra, "ficha" que pide interfaces
      child: Padding(
        padding: const EdgeInsets.all(16), //padding de 16px por dentro, para que no se toquen los bordes
        child: Column( //se pone una debajo de la otra
          crossAxisAlignment: CrossAxisAlignment.start, //se alinea ttodo a la izquierda
          children: [
            Row( //fila con una cosa al lado de la otra
              children: [
                //El icono elegido, pintado con el color elegido
                Icon(Habito.iconos[habito.icono], color: Habito.colores[habito.color]), //iconos que se pueden escoger y el color
                const SizedBox(width: 10), //hueco de 10xp entre el icono y el texto
                Text(habito.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), //nombre del habito, tamaño, en negrita
              ],
            ),

            const SizedBox(height: 8), //hueco de 8px arriba
            Text('Color: ${habito.color}'), //color del habito
            Row(
              children: [
                Checkbox(value: hecho, onChanged: alMarcar),
                Text(hecho ? 'Hecho hoy' : 'Pendiente'), //texto de 'hecho hoy', o si esta pendiente el habito
              ],
            ),

            Row(
              children: [
                ElevatedButton(onPressed: alEditar, child: const Text('Editar hábito')), //un boton, que al pulsarlo, en este caso el de editar, abre el editor
                const SizedBox(width: 10),
                ElevatedButton(onPressed: alBorrar, child: const Text('Borrar')), //al pulsar el boton de borrar, se borra el habito y guarda
              ],
            ),
          ],
        ),
      ),
    );
  }
}