import 'dart:convert'; //jsonEncode y jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../models/habito.dart';

//SERVICIO: el ÚNICO sitio que usa SharedPreferences. Las pantallas solo llaman a estos métodos.
//Todos son async porque leer y guardar en disco tarda; await espera a que termine.
class PreferenciasService {
  //CLAVES en constantes, para no escribir textos sueltos por el código
  static const String claveTemaOscuro = 'temaOscuro';
  static const String claveTamanoLetra = 'tamanoLetra';
  static const String claveOcultarCompletados = 'ocultarCompletados';
  static const String claveAperturas = 'aperturas';
  static const String claveUltimaApertura = 'ultimaApertura';
  static const String claveUsuarios = 'usuarios';
  static const String claveHabitos = 'habitos';

  //TEMA OSCURO (bool). Si es null, ?? false = tema claro
  Future<void> guardarTemaOscuro(bool oscuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(claveTemaOscuro, oscuro);
  }

  Future<bool> leerTemaOscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(claveTemaOscuro) ?? false;
  }

  //TAMAÑO DE LETRA (double). Si es null, ?? 1.0 = tamaño normal
  Future<void> guardarTamanoLetra(double tamano) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(claveTamanoLetra, tamano);
  }

  Future<double> leerTamanoLetra() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(claveTamanoLetra) ?? 1.0;
  }

  //OCULTAR COMPLETADOS (bool). Si es null, ?? false = no ocultar
  Future<void> guardarOcultarCompletados(bool ocultar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(claveOcultarCompletados, ocultar);
  }

  Future<bool> leerOcultarCompletados() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(claveOcultarCompletados) ?? false;
  }

  //APERTURAS (int). Devuelve null la primera vez
  Future<void> guardarAperturas(int aperturas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(claveAperturas, aperturas);
  }

  Future<int?> leerAperturas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(claveAperturas);
  }

  //ÚLTIMA APERTURA (String). Devuelve null la primera vez
  Future<void> guardarUltimaApertura(String fecha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(claveUltimaApertura, fecha);
  }

  Future<String?> leerUltimaApertura() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(claveUltimaApertura);
  }

  //USUARIOS (List<String>): cada usuario → toJson() → jsonEncode → texto
  Future<List<Usuario>> leerUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> lista = prefs.getStringList(claveUsuarios) ?? [];
    List<Usuario> usuarios = [];
    for (String texto in lista) {
      usuarios.add(Usuario.fromJson(jsonDecode(texto)));
    }
    return usuarios;
  }

  Future<void> guardarUsuarios(List<Usuario> usuarios) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> lista = [];
    for (Usuario u in usuarios) {
      lista.add(jsonEncode(u.toJson()));
    }
    await prefs.setStringList(claveUsuarios, lista);
  }

  //Busca un usuario por su nombre. null si no existe
  Future<Usuario?> buscarUsuario(String nombre) async {
    List<Usuario> usuarios = await leerUsuarios();
    for (Usuario u in usuarios) {
      if (u.usuario == nombre) return u;
    }
    return null;
  }

  //Si ya existe un usuario con ese nombre lo sustituye (editar); si no, lo añade (crear)
  Future<void> guardarUsuario(Usuario usuario) async {
    List<Usuario> usuarios = await leerUsuarios();
    int posicion = usuarios.indexWhere((u) => u.usuario == usuario.usuario); //-1 si es nuevo
    if (posicion == -1) {
      usuarios.add(usuario);
    } else {
      usuarios[posicion] = usuario;
    }
    await guardarUsuarios(usuarios);
  }

  //Borra el usuario y también todos sus hábitos
  Future<void> eliminarUsuario(String nombre) async {
    List<Usuario> usuarios = await leerUsuarios();
    usuarios.removeWhere((u) => u.usuario == nombre);
    await guardarUsuarios(usuarios);

    List<Habito> habitos = await leerHabitos();
    habitos.removeWhere((h) => h.usuario == nombre);
    await guardarHabitos(habitos);
  }

  //ADMIN: si no hay ningún usuario guardado, crea la cuenta fija admin / admin
  Future<void> crearAdmin() async {
    List<Usuario> usuarios = await leerUsuarios();
    if (usuarios.isNotEmpty) return;
    usuarios.add(Usuario(
      usuario: 'admin',
      contrasena: 'admin',
      objetivo: 0,
      esAdmin: true,
      fechaCreacion: DateTime.now().toString().substring(0, 10),
    ));
    await guardarUsuarios(usuarios);
  }

  //HÁBITOS (List<String>): se guardan los de todos los usuarios juntos en una lista
  Future<List<Habito>> leerHabitos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> lista = prefs.getStringList(claveHabitos) ?? [];
    List<Habito> habitos = [];
    for (String texto in lista) {
      habitos.add(Habito.fromJson(jsonDecode(texto)));
    }
    return habitos;
  }

  Future<void> guardarHabitos(List<Habito> habitos) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> lista = [];
    for (Habito h in habitos) {
      lista.add(jsonEncode(h.toJson()));
    }
    await prefs.setStringList(claveHabitos, lista);
  }

  //Solo los hábitos de un usuario: así cada uno ve únicamente los suyos
  Future<List<Habito>> leerHabitosDe(String nombre) async {
    List<Habito> habitos = await leerHabitos();
    List<Habito> suyos = [];
    for (Habito h in habitos) {
      if (h.usuario == nombre) suyos.add(h);
    }
    return suyos;
  }

  //Guarda la lista de hábitos de un usuario: quita los suyos de la lista completa,
  //añade los nuevos y guarda todo. Así no se tocan los hábitos de los demás usuarios
  Future<void> guardarHabitosDe(String nombre, List<Habito> suyos) async {
    List<Habito> habitos = await leerHabitos();
    habitos.removeWhere((h) => h.usuario == nombre);
    habitos.addAll(suyos);
    await guardarHabitos(habitos);
  }

  //BORRAR TODO: la app queda como recién instalada
  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}