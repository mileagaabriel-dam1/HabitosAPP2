import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';
import '../widgets/dato_estadistica.dart';

class EstadisticasScreen extends StatefulWidget { //stateful porque habran cambios
  final String usuario;
  const EstadisticasScreen({super.key, required this.usuario});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  PreferenciasService servicio = PreferenciasService(); //servicio para leer
  int aperturas = 0; //int de las veces que se ha abierto la app
  String ultimaApertura = ''; //ultima vez abierta (fecha y hora)
  List<Habito> habitos = []; //una lista de los habitos, que empieza vacia

  @override
  void initState() { //se ejecuta una vez al abrir la pagina
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    aperturas = await servicio.leerAperturas() ?? 0; //espera a tener el dato de aperturas para leerlo
    ultimaApertura = await servicio.leerUltimaApertura() ?? ''; //espera para leerlo
    habitos = await servicio.leerHabitosDe(widget.usuario); //espera para leerlo
    if (!mounted) return;
    //comprueba si la pagina sigue abierta
    setState(() {});
    //se redibuja la pagina
  }

  int racha(Habito h) {
    int dias = 0; //valor de dias para la racha
    DateTime dia = DateTime.now(); //fecha actual
    while (h.fechasCompletadas.contains(dia.toString().substring(0, 10))) { //mientras la fecha este en la lista de habitos, lo pasa a texto tipo "2026-10-14"
      dias++; //se suman los dias
      dia = dia.subtract(const Duration(days: 1)); //Día anterior
    }
    return dias; //devuelve los dias de racha
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            DatoEstadistica(
                              etiqueta: 'Racha actual',
                              valor: '${racha(h)} días',
                              icono: Icons.local_fire_department,
                              color: Colors.orange,
                            ),
                            //Total = cuántas fechas tiene su lista (.length)
                            DatoEstadistica(
                              etiqueta: 'Días completados',
                              valor: '${h.fechasCompletadas.length}',
                              icono: Icons.check_circle,
                              color: Colors.green,
                            ),
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