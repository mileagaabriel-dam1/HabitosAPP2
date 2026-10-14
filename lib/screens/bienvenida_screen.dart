import 'package:flutter/material.dart';
import '../services/preferencias_service.dart';
import 'principal_screen.dart';

class BienvenidaScreen extends StatefulWidget { //stateful porque tiene que recordar lo que se escribe en esa pantalla
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState(); //se dice que clase guarda las variables
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  PreferenciasService servicio = PreferenciasService(); //servicio para leer y guardar datos
  TextEditingController nombreController = TextEditingController();
  TextEditingController objetivoController = TextEditingController();
  //controller por campo para leer el texto escrito

  @override
  void dispose() { //se ejecuta una vez al cerrar la pantalla
    nombreController.dispose();
    objetivoController.dispose();
    //se borran los controllers porque ya no hacen falta
    super.dispose();
    //aqui se deja que flutter haga su parte
  }

  Future<void> comenzar() async {
    String nombre = nombreController.text; //se utiliza el controller para mostrar el nombre
    int? objetivo = int.tryParse(objetivoController.text); //null si no es un número
    if (nombre.isEmpty || objetivo == null) return; //si esta vacio, sale del metodo sin hacer nada

    await servicio.guardarNombre(nombre);
    await servicio.guardarObjetivo(objetivo);
    //guarda el nombre y el objetivo,

    if (!mounted) return;
    //Pasamos los datos al constructor de la principal
    //pushReplacement quita la bienvenida para no poder volver atrás a ella
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PrincipalScreen(nombre: nombre, objetivo: objetivo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //estructura de la pagina
      appBar: AppBar(title: const Text('Bienvenida')),
      body: SingleChildScrollView( //scroll unico
        child: Padding(
          padding: const EdgeInsets.all(16), //16px
          child: Column(
            children: [
              const Text('HabitosApp', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Tu nombre', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: objetivoController,
                decoration: const InputDecoration(labelText: 'Objetivo diario', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: comenzar, child: const Text('Comenzar')),
            ],
          ),
        ),
      ),
    );
  }
}