import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../models/estadistica.dart';
import '../services/preferencias_service.dart';
import '../services/base_datos_service.dart';
import '../widgets/dato_estadistica.dart';
import 'editar_estadistica_screen.dart';

//ESTADÍSTICAS de un usuario: la racha y el total de cada hábito se leen de la tabla estadisticas.
//El administrador además puede crearlas, editarlas y eliminarlas (esAdmin: true).
class EstadisticasScreen extends StatefulWidget { //stateful porque habran cambios
  final String usuario;
  final bool esAdmin; //true solo si la abre Administración
  const EstadisticasScreen({super.key, required this.usuario, this.esAdmin = false});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  PreferenciasService servicio = PreferenciasService(); //servicio para leer
  BaseDatosService bd = BaseDatosService(); //base de datos: hábitos y estadísticas
  int aperturas = 0; //int de las veces que se ha abierto la app
  String ultimaApertura = ''; //ultima vez abierta (fecha y hora)
  List<Habito> habitos = []; //una lista de los habitos, que empieza vacia
  Map<int, Estadistica> estadisticas = {}; //id del hábito → su estadística

  @override
  void initState() { //se ejecuta una vez al abrir la pagina
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    aperturas = await servicio.leerAperturas() ?? 0; //espera a tener el dato de aperturas para leerlo
    ultimaApertura = await servicio.leerUltimaApertura() ?? ''; //espera para leerlo
    habitos = await bd.leerHabitosDe(widget.usuario); //espera para leerlo
    //BASE DE DATOS: la fila de estadisticas de cada hábito. Si no tiene, no se añade al Map
    estadisticas = {};
    for (Habito h in habitos) {
      Estadistica? e = await bd.buscarEstadisticaDe(h.id!);
      if (e != null) estadisticas[h.id!] = e;
    }
    if (!mounted) return;
    //comprueba si la pagina sigue abierta
    setState(() {});
    //se redibuja la pagina
  }

  //Solo admin: abre la pantalla para crear (estadistica = null) o editar una estadística, y recarga al volver
  Future<void> abrirEditor(Habito habito, Estadistica? estadistica) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarEstadisticaScreen(habito: habito, estadistica: estadistica)),
    );
    if (!mounted) return;
    cargarDatos();
  }

  //Solo admin: borra la fila de la tabla estadisticas, después de confirmar
  Future<void> eliminar(Habito habito, Estadistica e) async {
    bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar la estadística de "${habito.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado != true) return;
    await bd.eliminarEstadistica(e.id!);
    cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //estructura de la pagina
      appBar: AppBar(title: const Text('Estadísticas')),
      body: SingleChildScrollView( //scroll unico
        child: Padding(
          padding: const EdgeInsets.all(16), //16px
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Veces abierta: $aperturas'), //las veces que se ha abierto la app, lo mete en la variable correspondiente
              Text('Última apertura: $ultimaApertura'), //lo mismo con el dato de ultima apertura
              const SizedBox(height: 16), //hueco de 16px
              if (habitos.isEmpty) const Text('Todavía no hay hábitos.'),
              //Una tarjeta por hábito: el nombre arriba y sus dos datos debajo, así se ve a qué hábito pertenece cada dato
              for (Habito h in habitos)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(h.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        //Si el hábito no tiene fila en estadisticas (por ejemplo, el admin la ha borrado)
                        if (estadisticas[h.id] == null)
                          const Text('Sin estadística')
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              DatoEstadistica(
                                etiqueta: 'Racha actual',
                                valor: '${estadisticas[h.id]!.racha} días',
                                icono: Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                              //Total = cuántos días se ha completado, guardado en la tabla
                              DatoEstadistica(
                                etiqueta: 'Días completados',
                                valor: '${estadisticas[h.id]!.total}',
                                icono: Icons.check_circle,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        //Botones solo para el administrador: crear si no tiene, editar y eliminar si tiene
                        if (widget.esAdmin && estadisticas[h.id] == null)
                          TextButton(onPressed: () => abrirEditor(h, null), child: const Text('Crear estadística')),
                        if (widget.esAdmin && estadisticas[h.id] != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(onPressed: () => abrirEditor(h, estadisticas[h.id]), child: const Text('Editar')),
                              TextButton(onPressed: () => eliminar(h, estadisticas[h.id]!), child: const Text('Eliminar')),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}