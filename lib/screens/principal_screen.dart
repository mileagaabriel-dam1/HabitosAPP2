import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';
import '../services/base_datos_service.dart';
import '../widgets/tarjeta_habito.dart';
import 'habito_form_screen.dart';
import 'estadisticas_screen.dart';
import 'ajustes_screen.dart';
import 'login_screen.dart';
//widgets y las clases necesarias

class PrincipalScreen extends StatefulWidget { //stateful porque cambia
  final Usuario usuario;
  const PrincipalScreen({super.key, required this.usuario});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState(); //variables
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  PreferenciasService servicio = PreferenciasService(); //servicio para leer y guardar
  BaseDatosService bd = BaseDatosService(); //base de datos: los hábitos
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
    habitos = await bd.leerHabitosDe(widget.usuario.usuario); //solo las filas de la tabla habitos de este usuario
    ocultarCompletados = await servicio.leerOcultarCompletados();
    //lee los habitos (base de datos) y el boolean de ocultar completados (preferencias)
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
    await bd.actualizarHabito(habito); //actualiza la fila de ese habito en la base de datos (y su estadistica)
    if (!mounted) return;
    //comprueba si la pantalla sigue abierta
    setState(() {});
    //se redibuja la pantalla
  }

  Future<void> borrar(Habito habito) async {
    //Antes de borrar se pide confirmación. La ventana devuelve true (Eliminar) o false (Cancelar) con Navigator.pop
    bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar "${habito.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado != true) return; //si no se ha pulsado Eliminar, no se borra nada

    habitos.remove(habito); //coge el habito, si se ha borrado, lo quita de la lista
    await bd.eliminarHabito(habito.id!); //borra su fila de la base de datos (y su estadistica)
    if (!mounted) return;
    //comprueba si la pantalla sigue abierta
    setState(() {});
    //se redibuja la pantalla
  }

  Future<void> abrirEditor(Habito? habito) async {
    final Habito? resultado = await Navigator.push<Habito>( //navega a la pantalla del habito seleccionado, en este caso
      //espera a que devuelvas el editor, lo que devuelva el editor con "navigator.pop" , se guarda en resultado
      context,
      MaterialPageRoute(builder: (context) => HabitoFormScreen(habito: habito, usuario: widget.usuario.usuario)),//se le indica que el editor devuelve un habito
    );
    if (resultado == null) return; //si el editor no devuelve nada, volver atras

    //si no tiene id es nuevo: se inserta (la base de datos le pone el id). Si tiene id, se actualiza su fila
    if (resultado.id == null) {
      await bd.insertarHabito(resultado);
    } else {
      await bd.actualizarHabito(resultado);
    }
    if (!mounted) return;
    cargarDatos();
    //se vuelve a leer la lista de la base de datos, asi el nuevo ya tiene su id, y se redibuja
  }

  Future<void> abrir(Widget pantalla) async { //abre la pantalla estadisticas o ajustes, la que se le mande
    await Navigator.push(context, MaterialPageRoute(builder: (context) => pantalla)); //recarga los datos cuando se vuelve a esa pantalla
    if (!mounted) return;
    cargarDatos();
    //se redibuja la pantalla con los datos
  }

  //Cerrar sesión: vuelve al login y quita todas las pantallas anteriores (no se puede volver atrás)
  void cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //estructura de la pantalla
      appBar: AppBar( //barra de arriba
        title: const Text('HabitosApp'), //el titulo de la barra de arriba
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => abrir(EstadisticasScreen(usuario: widget.usuario.usuario))), //icono
          IconButton(icon: const Icon(Icons.settings), onPressed: () => abrir(const AjustesScreen())), //icono
          IconButton(icon: const Icon(Icons.logout), onPressed: cerrarSesion), //icono para cerrar sesión
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
                'Hola, ${widget.usuario.usuario}', //texto de hola "nombre"
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Objetivo diario: ${widget.usuario.objetivo} hábitos', //en un hueco de 8px, se muestra "objetivo diario, habitos"
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Hoy llevas ${contarHechos()} de ${widget.usuario.objetivo} hábitos',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24), //24px
              //Mensaje si todavía no hay hábitos
              if (habitos.isEmpty)
                const Text(
                  'Todavía no tienes hábitos. Pulsa "Crear hábito" para añadir uno.',
                  textAlign: TextAlign.center,
                ),
              for (Habito h in habitos) //una ficha para cada habito
                if (!ocultarCompletados || !hechoHoy(h)) //solo se muestra si ocultar esta desacticado o no esta hecho hoy
                  TarjetaHabito( //ficha de cada habito
                    nombre: h.nombre,
                    color: Habito.colores[h.color]!,
                    completado: hechoHoy(h),
                    icono: Habito.iconos[h.icono]!,
                    alCompletar: () => marcar(h, !hechoHoy(h)), //si no estaba hecho lo marca, y si lo estaba lo desmarca
                    alEditar: () => abrirEditor(h),
                    alEliminar: () => borrar(h),
                  ),
              const SizedBox(height: 80), //hueco para que el botón flotante no tape la última ficha
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