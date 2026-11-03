import 'package:shared_preferences/shared_preferences.dart';

//SERVICIO: el ÚNICO sitio que usa SharedPreferences. Las pantallas solo llaman a estos métodos.
//Ahora solo guarda los ajustes y las aperturas (valores sueltos clave → valor).
//Los usuarios, hábitos y estadísticas están en la base de datos (BaseDatosService).
//Todos son async porque leer y guardar en disco tarda; await espera a que termine.
class PreferenciasService {
  //CLAVES en constantes, para no escribir textos sueltos por el código
  static const String claveTemaOscuro = 'temaOscuro';
  static const String claveTamanoLetra = 'tamanoLetra';
  static const String claveOcultarCompletados = 'ocultarCompletados';
  static const String claveAperturas = 'aperturas';
  static const String claveUltimaApertura = 'ultimaApertura';

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

  //BORRAR TODO: borra los ajustes y las aperturas
  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}