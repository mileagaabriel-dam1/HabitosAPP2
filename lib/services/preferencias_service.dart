import 'dart:convert'; //jsonEncode y jsonDecode, para pasar los habitos a texto, y al reves
import 'package:shared_preferences/shared_preferences.dart'; //
import '../models/habito.dart'; //se llama a la clase de habito

class PreferenciasService {

  static const String claveNombre = 'nombre';
  static const String claveObjetivo = 'objetivo';
  static const String claveTemaOscuro = 'temaOscuro';
  static const String claveTamanoLetra = 'tamanoLetra';
  static const String claveOcultarCompletados = 'ocultarCompletados';
  static const String claveHabitos = 'habitos';
  static const String claveAperturas = 'aperturas';
  static const String claveUltimaApertura = 'ultimaApertura';

  Future<void> guardarNombre(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(claveNombre, nombre);
  }

  Future<String?> leerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(claveNombre);
  }

  Future<void> guardarObjetivo(int objetivo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(claveObjetivo, objetivo);
  }

  Future<int?> leerObjetivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(claveObjetivo);
  }

  Future<void> guardarTemaOscuro(bool oscuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(claveTemaOscuro, oscuro);
  }

  Future<bool> leerTemaOscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(claveTemaOscuro) ?? false;
  }

  Future<void> guardarTamanoLetra(double tamano) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(claveTamanoLetra, tamano);
  }

  Future<double> leerTamanoLetra() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(claveTamanoLetra) ?? 1.0;
  }

  Future<void> guardarOcultarCompletados(bool ocultar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(claveOcultarCompletados, ocultar);
  }

  Future<bool> leerOcultarCompletados() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(claveOcultarCompletados) ?? false;
  }

  Future<void> guardarAperturas(int aperturas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(claveAperturas, aperturas);
  }

  Future<int?> leerAperturas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(claveAperturas);
  }

  Future<void> guardarUltimaApertura(String fecha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(claveUltimaApertura, fecha);
  }

  Future<String?> leerUltimaApertura() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(claveUltimaApertura);
  }

  Future<void> guardarHabitos(List<Habito> habitos) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> lista = [];
    for (Habito h in habitos) {
      lista.add(jsonEncode(h.toJson()));
    }
    await prefs.setStringList(claveHabitos, lista);
  }

  Future<List<Habito>> leerHabitos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> lista = prefs.getStringList(claveHabitos) ?? [];
    List<Habito> habitos = [];
    for (String texto in lista) {
      habitos.add(Habito.fromJson(jsonDecode(texto)));
    }
    return habitos;
  }

  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}