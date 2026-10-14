import 'package:flutter/material.dart'; //traemos los botones, textos, pantallas...
import 'services/preferencias_service.dart'; //llamamos a servicio, el que lee y guarda
import 'screens/bienvenida_screen.dart'; //llamamos a la pantalla de bienvenida para mostrarla
import 'screens/principal_screen.dart'; //y llamamos a la principal para mostrarla

void main() { //lo primero que se ejecuta
  WidgetsFlutterBinding.ensureInitialized(); //se prepara para poder guardar datos
  runApp(const HabitosApp()); //se arranca la app
}

class HabitosApp extends StatefulWidget { //stateful porque la app cambia, primero esta cargando y despues el tema y la letra pueden cambiar
  const HabitosApp({super.key}); //constructor

  static void recargarAjustes(BuildContext context) { //un tipo de aviso que usa la pantalla de ajustes, si se cambia el tema o la letra
    context.findAncestorStateOfType<_HabitosAppState>()?.cargarAjustes();
  }

  @override
  State<HabitosApp> createState() => _HabitosAppState(); //se le dice a flutter que las variables de la app estan en _HabitosAppState
}

class _HabitosAppState extends State<HabitosApp> {
  PreferenciasService servicio = PreferenciasService(); //se usa para leer y guardar
  bool cargando = true; //empieza en true, porque al abrir aun no se ha abierto nada
  String? nombre; //null si es la primera vez
  int objetivo = 0; //int para objetivo
  bool temaOscuro = false; //boolean para el tema
  double tamanoLetra = 1.0; //y un double para el tamaño de letra, ya que puede ser decimal

  @override
  void initState() { //se ejecuta una sola vez al abrir la app, esto empieza a leer datos
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async { //async porque leer y guardar tarda
    int aperturas = await servicio.leerAperturas() ?? 0; //see lee cuantas veces se ha abierto la app
    await servicio.guardarAperturas(aperturas + 1);
    await servicio.guardarUltimaApertura(DateTime.now().toString().substring(0, 16)); //guarda la fecha y hora

    nombre = await servicio.leerNombre();
    objetivo = await servicio.leerObjetivo() ?? 0;
    temaOscuro = await servicio.leerTemaOscuro();
    tamanoLetra = await servicio.leerTamanoLetra();
    //se leen los cuatro datos guardados y se meten en las variables (await porque espera a tenerlo)

    if (!mounted) return; //comprueba que la app sigue abierta despues de la espera
    setState(() {
      cargando = false; //si ya no esta cargando, el circulito de cargando desaparece
    });
  }

  Future<void> cargarAjustes() async { //se lee el tema, la letra, y lo redibuja
    temaOscuro = await servicio.leerTemaOscuro();
    tamanoLetra = await servicio.leerTamanoLetra();
    if (!mounted) return;
    setState(() {});
  }


  Widget pantallaInicial() { //pantalla inicial
    if (cargando) return const Scaffold(body: Center(child: CircularProgressIndicator())); //si esta cargando, el circulito
    if (nombre == null) return const BienvenidaScreen(); //si el nombre es null, devolver la pantalla de bienvenida
    return PrincipalScreen(nombre: nombre!, objetivo: objetivo); //si hay nombre y objetivo, devolver la pantalla de principal
  }

  @override
  Widget build(BuildContext context) { //dibuja la app
    return MaterialApp(
      title: 'HabitosApp', //titulo
      theme: ThemeData.light(), //tema light
      darkTheme: ThemeData.dark(), //tema dark
      themeMode: temaOscuro ? ThemeMode.dark : ThemeMode.light, //elige si el tema esta en oscuro, o claro, carga segun el ajuste

      builder: (context, child) => MediaQuery( //una opcion del materialapp,(antes de enseñar alguna pantalla la pasa por aqui),child es la pantalla que toca enseñar en el momento
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(tamanoLetra)), //coge la informacion que ya tenia en pantalla, hace una copia igual a eso,
        //pero cambia algo, que es el tamaño de letra, y el textscaler, multiplica el tamaño de todos los textos por el numero elegido
        child: child!, //mete la pantalla child dentro de mediaQuery, para que los textos de esa, usen los tamaños asignados
      ),
      home: pantallaInicial(), //home segun la pantalla que carga (bienvenida o principal)
    );
  }
}