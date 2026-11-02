import 'package:flutter/material.dart';

//COMPONENTE: tarjeta de un hábito de la lista. No guarda nada: muestra lo que recibe
//y, al pulsar, ejecuta los callbacks. Lo que pasa después lo decide la pantalla.
class TarjetaHabito extends StatelessWidget {
  final String nombre;
  final Color color;
  final bool completado; //true si está hecho hoy
  final IconData icono;
  final VoidCallback alCompletar;
  final VoidCallback alEditar;
  final VoidCallback alEliminar;

  const TarjetaHabito({
    super.key,
    required this.nombre,
    required this.color,
    required this.completado,
    this.icono = Icons.star, //Valor por defecto si no se pasa ninguno
    required this.alCompletar,
    required this.alEditar,
    required this.alEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: color, size: 32),
                const SizedBox(width: 10),
                //Expanded: el nombre ocupa el espacio que queda y, si es largo, baja de línea
                Expanded(
                  child: Text(nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            //Completado y pendiente se distinguen por la casilla, el texto y el color
            Row(
              children: [
                Checkbox(value: completado, onChanged: (valor) => alCompletar()),
                Text(
                  completado ? 'Completado hoy' : 'Pendiente',
                  style: TextStyle(color: completado ? Colors.green : Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                TextButton.icon(onPressed: alEditar, icon: const Icon(Icons.edit), label: const Text('Editar')),
                const SizedBox(width: 10),
                TextButton.icon(onPressed: alEliminar, icon: const Icon(Icons.delete), label: const Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}