import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';
import '../widgets/habito_tile.dart';
import 'habito_form_screen.dart';
import 'estadisticas_screen.dart';
import 'ajustes_screen.dart';
//widgets y las clases necesarias

class PrincipalScreen extends StatefulWidget { //stateful porque cambia
  final String nombre; //devuelve el nombre que se ha puesto
  final int objetivo; //y el objetivo que el usuario a escogido
  const PrincipalScreen({super.key, required this.nombre, required this.objetivo}); //constructor, la principal screen necesita si o si el nombre y objetivo para cargar

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState(); //variables
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  PreferenciasService servicio = PreferenciasService(); //servicio para leer y guardar
  List<Habito> habitos = []; //lista que mostrara los habitos
  bool ocultarCompletados = false; //un boolean para ocultar los completados, empieza como false
  String hoy = DateTime.now().toString().substring(0, 10); //la fecha de hoy

  @override
  void initState() {
    super.initState();
    cargarDatos();
    //se ejecuta una vez al abrir la pantalla, cargando los datos
  }

  Future<void> cargarDatos() async {
    habitos = await servicio.leerHabitos();
    ocultarCompletados = await servicio.leerOcultarCompletados();
    //lee los habitos y el boolean de ocultar completados con el servicio
    if (!mounted) return;
    //comprueba que la pantalla sigue abierta
    setState(() {});
    //redibuja con los datos leídos
  }

  bool hechoHoy(Habito h) { //boolean de hecho hoy
    return h.fechasCompletadas.contains(hoy); //devuelve una lista con los habitos hechos HOY
  }

  int contarHechos() { //int para contar los habitos hechos
    int hechos = 0; //empieza por 0
    for (Habito h in habitos) {
      if (hechoHoy(h)) hechos++; //si hay habitos hechos, se suman 1 a la lista
    }
    return hechos; //se devuelven los habitos hechos
  }

  Future<void> marcar(Habito habito, bool? marcado) async {
    if (marcado == true) { //si marcado es "true" en ese habito,
      habito.fechasCompletadas.add(hoy); //añade la fecha de hoy a la lista
    } else {
      habito.fechasCompletadas.remove(hoy); //si se desmarca, se quita la fecha de la lista
    }
    await servicio.guardarHabitos(habitos); //guarda la lista entera con los cambios
    if (!mounted) return;
    //comprueba si la pantalla sigue abierta
    setState(() {});
    //se redibuja la pantalla
  }

  Future<void> borrar(Habito habito) async {
    habitos.remove(habito); //coge el habito, si se ha borrado, lo quita de la lista
    await servicio.guardarHabitos(habitos); //se guarda la lista de habitos con los cambios
    if (!mounted) return;
    //comprueba si la pantalla sigue abierta
    setState(() {});
    //se redibuja la pantalla
  }

  Future<void> abrirEditor(Habito? habito) async {
    final Habito? resultado = await Navigator.push<Habito>( //navega a la pantalla del habito seleccionado, en este caso
      //espera a que devuelvas el editor, lo que devuelva el editor con "navigator.pop" , se guarda en resultado
      context,
      MaterialPageRoute(builder: (context) => HabitoFormScreen(habito: habito)),//se le indica que el editor devuelve un habito
    );
    if (resultado == null) return; //si el editor no devuelve nada, volver atras

    int posicion = habitos.indexWhere((h) => h.id == resultado.id); //busca en que posicion de la lista esta el habito con ese id,
    if (posicion == -1) { //si no lo encuentra, devuelve -1
      habitos.add(resultado); //
    } else {
      habitos[posicion] = resultado; //si existe, lo sustituye por su version editada
    }
    await servicio.guardarHabitos(habitos); //guarda la lista de habitos con los cambios
    if (!mounted) return;
    setState(() {});
    //se redibuja la pantalla
  }

  Future<void> abrir(Widget pantalla) async { //abre la pantalla estadisticas o ajustes, la que se le mande
    await Navigator.push(context, MaterialPageRoute(builder: (context) => pantalla)); //recarga los datos cuando se vuelve a esa pantalla
    if (!mounted) return;
    cargarDatos();
    //se redibuja la pantalla con los datos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //estructura de la pantalla
      appBar: AppBar( //barra de arriba
        title: const Text('HabitosApp'), //el titulo de la barra de arriba
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => abrir(const EstadisticasScreen())), //icono
          IconButton(icon: const Icon(Icons.settings), onPressed: () => abrir(const AjustesScreen())), //icono
        ],
      ),
      body: SingleChildScrollView( //scroll unico
        child: Padding(
          padding: const EdgeInsets.all(16), //margen de 16px
          child: Column( //columna

            crossAxisAlignment: CrossAxisAlignment.stretch, //hace que se ocupe el ancho entero
            children: [
              const Icon(Icons.waving_hand, size: 60, color: Colors.amber), //icono de mano saludando
              const SizedBox(height: 8), //hueco de 8px
              Text(
                'Hola, ${widget.nombre}', //texto de hola "nombre"
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Objetivo diario: ${widget.objetivo} hábitos', //en un hueco de 8px, se muestra "objetivo diario, habitos"
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Hoy llevas ${contarHechos()} de ${widget.objetivo} hábitos',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24), //24px
              for (Habito h in habitos) //una ficha para cada habito
                if (!ocultarCompletados || !hechoHoy(h)) //solo se muestra si ocultar esta desacticado o no esta hecho hoy
                  HabitoTile( //ficha de cada habito
                    habito: h,
                    hecho: hechoHoy(h),
                    alMarcar: (valor) => marcar(h, valor),
                    alEditar: () => abrirEditor(h),
                    alBorrar: () => borrar(h),
                  ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended( //boton flotante con texto, al pulsarlo se abre el editor
        onPressed: () => abrirEditor(null),
        icon: const Icon(Icons.add),
        label: const Text('Crear hábito', style: TextStyle(fontSize: 18)), //texto de crear habito (en le boton)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, //el boton se pone en el centro
    );
  }
}