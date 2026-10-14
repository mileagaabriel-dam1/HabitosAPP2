import 'package:flutter/material.dart';
import '../main.dart'; //Para avisar a la app de que cambie el tema y la letra
import '../services/preferencias_service.dart';
import 'bienvenida_screen.dart';

//AJUSTES: tema, tamaño de letra, ocultar completados y borrar datos
class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  PreferenciasService servicio = PreferenciasService();
  bool temaOscuro = false;
  double tamanoLetra = 1.0;
  bool ocultarCompletados = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  //PERSISTENCIA: lee los ajustes para que los controles salgan como estaban
  Future<void> cargarDatos() async {
    temaOscuro = await servicio.leerTemaOscuro();
    tamanoLetra = await servicio.leerTamanoLetra();
    ocultarCompletados = await servicio.leerOcultarCompletados();
    if (!mounted) return;
    setState(() {});
  }

  //PERSISTENCIA: guarda el tema (bool) y avisa a la app para aplicarlo al momento
  Future<void> cambiarTema(bool valor) async {
    setState(() => temaOscuro = valor);
    await servicio.guardarTemaOscuro(valor);
    if (!mounted) return;
    HabitosApp.recargarAjustes(context);
  }

  //PERSISTENCIA: guarda el tamaño de letra (double) y avisa a la app
  Future<void> cambiarLetra(double valor) async {
    setState(() => tamanoLetra = valor);
    await servicio.guardarTamanoLetra(valor);
    if (!mounted) return;
    HabitosApp.recargarAjustes(context);
  }

  //PERSISTENCIA: guarda el interruptor (bool). La principal lo lee al volver
  Future<void> cambiarOcultar(bool valor) async {
    setState(() => ocultarCompletados = valor);
    await servicio.guardarOcultarCompletados(valor);
  }

  //PERSISTENCIA: pide confirmación, borra todo y vuelve a la bienvenida
  Future<void> borrarDatos() async {
    //La ventana devuelve true (Borrar) o false (Cancelar) con Navigator.pop
    bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar todos los datos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Borrar')),
        ],
      ),
    );
    if (confirmado != true) return;

    await servicio.borrarTodo();
    if (!mounted) return;
    HabitosApp.recargarAjustes(context); //Tema y letra vuelven a sus valores por defecto
    //Va a la bienvenida y quita todas las pantallas anteriores (no se puede volver atrás)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const BienvenidaScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(title: const Text('Tema oscuro'), value: temaOscuro, onChanged: cambiarTema),
              const SizedBox(height: 16),
              const Text('Tamaño de letra'),
              Slider(value: tamanoLetra, min: 0.8, max: 1.6, divisions: 4, onChanged: cambiarLetra),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Ocultar hábitos completados hoy'),
                value: ocultarCompletados,
                onChanged: cambiarOcultar,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: borrarDatos, child: const Text('Borrar datos')),
            ],
          ),
        ),
      ),
    );
  }
}