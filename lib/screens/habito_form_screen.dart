import 'package:flutter/material.dart';
import '../models/habito.dart';

//EDITAR HÁBITO: cambia nombre y color (o crea uno si recibe null).
//No guarda: devuelve el resultado con Navigator.pop y la principal lo guarda.
class HabitoFormScreen extends StatefulWidget {
  final Habito? habito;
  const HabitoFormScreen({super.key, required this.habito});

  @override
  State<HabitoFormScreen> createState() => _HabitoFormScreenState();
}

class _HabitoFormScreenState extends State<HabitoFormScreen> {
  TextEditingController nombreController = TextEditingController();
  String colorElegido = 'Azul';
  String iconoElegido = 'Agua';

  //Si editamos, ponemos los datos actuales del hábito recibido
  @override
  void initState() {
    super.initState();
    if (widget.habito != null) {
      nombreController.text = widget.habito!.nombre;
      colorElegido = widget.habito!.color;
      iconoElegido = widget.habito!.icono;
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  //GUARDAR: devuelve el hábito a la principal con pop(context, resultado)
  void guardar() {
    if (nombreController.text.isEmpty) return;
    //Si es nuevo: id con los milisegundos actuales y sin fechas. Si no, mantiene los suyos
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    List<String> fechas = [];
    if (widget.habito != null) {
      id = widget.habito!.id;
      fechas = widget.habito!.fechasCompletadas;
    }
    Navigator.pop(
      context,
      Habito(id: id, nombre: nombreController.text, color: colorElegido, icono: iconoElegido, fechasCompletadas: fechas),
    );
  }

  //Botón de un icono. El elegido sale en azul y los demás en gris
  Widget botonIcono(String nombreIcono) {
    return IconButton(
      icon: Icon(Habito.iconos[nombreIcono]),
      iconSize: 32,
      color: nombreIcono == iconoElegido ? Colors.blue : Colors.grey,
      onPressed: () => setState(() => iconoElegido = nombreIcono),
    );
  }

  //Botón de un color. El elegido lleva ✓ delante
  Widget botonColor(String nombreColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Habito.colores[nombreColor], foregroundColor: Colors.white),
      onPressed: () => setState(() => colorElegido = nombreColor),
      child: Text(nombreColor == colorElegido ? '✓ $nombreColor' : nombreColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar hábito')), //Su flecha vuelve sin resultado (null)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del hábito', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              //Los tres botones de icono, en una Row
              Row(
                children: [
                  botonIcono('Agua'),
                  botonIcono('Comida'),
                  botonIcono('Correr'),
                ],
              ),
              Text('Icono: $iconoElegido'),
              const SizedBox(height: 20),
              Row(
                children: [
                  botonColor('Azul'),
                  const SizedBox(width: 8),
                  botonColor('Verde'),
                  const SizedBox(width: 8),
                  botonColor('Naranja'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Seleccionado: $colorElegido'),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(onPressed: guardar, child: const Text('Guardar')),
                  const SizedBox(width: 10),
                  //Cancelar: vuelve sin resultado (null), así no se cambia nada
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}