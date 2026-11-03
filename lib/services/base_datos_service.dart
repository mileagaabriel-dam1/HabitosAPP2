import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/usuario.dart';
import '../models/habito.dart';
import '../models/estadistica.dart';

//SERVICIO DE BASE DE DATOS: el ÚNICO sitio que usa sqflite (SQLite).
//Tiene el CRUD (crear, leer, actualizar, eliminar) de las tres tablas: usuarios, habitos y estadisticas.
//Todo es async porque leer y escribir en la base de datos tarda; await espera a que termine.
class BaseDatosService {
  //static: una sola conexión para toda la app, aunque cada pantalla cree su BaseDatosService()
  static Database? baseDatos;

  //Abre la base de datos y la devuelve. La primera vez (si no existe el archivo) la crea con onCreate
  Future<Database> abrir() async {
    if (baseDatos != null) return baseDatos!; //Ya estaba abierta
    String ruta = join(await getDatabasesPath(), 'habitos.db'); //Carpeta de bases de datos del móvil + nombre del archivo
    baseDatos = await openDatabase(ruta, version: 1, onCreate: crearTablas);
    return baseDatos!;
  }

  //Solo se ejecuta la primera vez, cuando el archivo habitos.db todavía no existe
  Future<void> crearTablas(Database db, int version) async {
    //execute: ejecuta una sentencia SQL que no devuelve filas
    await db.execute('''
      CREATE TABLE usuarios (
        usuario TEXT PRIMARY KEY,
        nombre TEXT,
        apellidos TEXT,
        email TEXT,
        contrasena TEXT,
        objetivo INTEGER,
        fecha_creacion TEXT,
        rol TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE habitos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT,
        nombre TEXT,
        color TEXT,
        icono TEXT,
        fechas TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE estadisticas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habito_id INTEGER,
        racha INTEGER,
        total INTEGER
      )
    ''');
    await crearAdmin(db);
  }

  //ADMIN: cuenta fija admin / admin con rol administrador. Nadie se puede registrar como administrador
  Future<void> crearAdmin(Database db) async {
    await db.insert('usuarios', Usuario(
      usuario: 'admin',
      nombre: 'Administrador',
      apellidos: '',
      email: '',
      contrasena: 'admin',
      objetivo: 0,
      fechaCreacion: DateTime.now().toString().substring(0, 10),
      rol: 'administrador',
    ).toMap());
  }

  //---------- USUARIOS ----------

  //CREATE: inserta una fila nueva en usuarios
  Future<void> insertarUsuario(Usuario usuario) async {
    final db = await abrir();
    await db.insert('usuarios', usuario.toMap());
  }

  //READ: todos los usuarios (lo usa Administración). Sin where devuelve todas las filas
  Future<List<Usuario>> leerUsuarios() async {
    final db = await abrir();
    List<Map<String, dynamic>> filas = await db.query('usuarios'); //query devuelve una lista de filas, cada fila es un Map
    List<Usuario> usuarios = [];
    for (Map<String, dynamic> fila in filas) {
      usuarios.add(Usuario.fromMap(fila)); //cada fila se convierte en un objeto Usuario
    }
    return usuarios;
  }

  //READ: un usuario por su nombre. null si no existe
  Future<Usuario?> buscarUsuario(String nombre) async {
    final db = await abrir();
    //where con ? y whereArgs: el ? se cambia por el valor de forma segura, sin pegar texto en el SQL
    List<Map<String, dynamic>> filas = await db.query('usuarios', where: 'usuario = ?', whereArgs: [nombre]);
    if (filas.isEmpty) return null;
    return Usuario.fromMap(filas.first);
  }

  //UPDATE: cambia los datos de la fila con ese usuario
  Future<void> actualizarUsuario(Usuario usuario) async {
    final db = await abrir();
    await db.update('usuarios', usuario.toMap(), where: 'usuario = ?', whereArgs: [usuario.usuario]);
  }

  //DELETE: borra el usuario y también sus hábitos (y las estadísticas de esos hábitos), para que no queden datos sueltos
  Future<void> eliminarUsuario(String nombre) async {
    List<Habito> habitos = await leerHabitosDe(nombre);
    for (Habito h in habitos) {
      await eliminarHabito(h.id!);
    }
    final db = await abrir();
    await db.delete('usuarios', where: 'usuario = ?', whereArgs: [nombre]);
  }

  //---------- HÁBITOS ----------

  //CREATE: inserta el hábito y le crea su fila de estadísticas a 0
  Future<void> insertarHabito(Habito habito) async {
    final db = await abrir();
    int id = await db.insert('habitos', habito.toMap()); //insert devuelve el id que le ha puesto la base de datos
    await insertarEstadistica(Estadistica(id: null, habitoId: id, racha: 0, total: 0));
  }

  //READ: todos los hábitos
  Future<List<Habito>> leerHabitos() async {
    final db = await abrir();
    List<Map<String, dynamic>> filas = await db.query('habitos');
    List<Habito> habitos = [];
    for (Map<String, dynamic> fila in filas) {
      habitos.add(Habito.fromMap(fila));
    }
    return habitos;
  }

  //READ: solo los hábitos de un usuario. Así cada usuario ve únicamente los suyos
  Future<List<Habito>> leerHabitosDe(String nombre) async {
    final db = await abrir();
    List<Map<String, dynamic>> filas = await db.query('habitos', where: 'usuario = ?', whereArgs: [nombre]);
    List<Habito> habitos = [];
    for (Map<String, dynamic> fila in filas) {
      habitos.add(Habito.fromMap(fila));
    }
    return habitos;
  }

  //UPDATE: guarda los cambios del hábito (nombre, color, icono o fechas) y recalcula su estadística
  Future<void> actualizarHabito(Habito habito) async {
    final db = await abrir();
    await db.update('habitos', habito.toMap(), where: 'id = ?', whereArgs: [habito.id]); //sin where cambiaría todas las filas
    await recalcularEstadistica(habito);
  }

  //DELETE: borra primero su estadística y después el hábito
  Future<void> eliminarHabito(int id) async {
    final db = await abrir();
    await db.delete('estadisticas', where: 'habito_id = ?', whereArgs: [id]);
    await db.delete('habitos', where: 'id = ?', whereArgs: [id]);
  }

  //---------- ESTADÍSTICAS ----------

  //CREATE
  Future<void> insertarEstadistica(Estadistica estadistica) async {
    final db = await abrir();
    await db.insert('estadisticas', estadistica.toMap());
  }

  //READ: la estadística de un hábito. null si no tiene
  Future<Estadistica?> buscarEstadisticaDe(int habitoId) async {
    final db = await abrir();
    List<Map<String, dynamic>> filas = await db.query('estadisticas', where: 'habito_id = ?', whereArgs: [habitoId]);
    if (filas.isEmpty) return null;
    return Estadistica.fromMap(filas.first);
  }

  //UPDATE
  Future<void> actualizarEstadistica(Estadistica estadistica) async {
    final db = await abrir();
    await db.update('estadisticas', estadistica.toMap(), where: 'id = ?', whereArgs: [estadistica.id]);
  }

  //DELETE
  Future<void> eliminarEstadistica(int id) async {
    final db = await abrir();
    await db.delete('estadisticas', where: 'id = ?', whereArgs: [id]);
  }

  int calcularRacha(List<String> fechas) {
    int dias = 0; //valor de dias para la racha
    DateTime dia = DateTime.now(); //fecha actual
    while (fechas.contains(dia.toString().substring(0, 10))) { //mientras la fecha este en la lista de habitos, lo pasa a texto tipo "2026-10-14"
      dias++; //se suman los dias
      dia = dia.subtract(const Duration(days: 1)); //Día anterior
    }
    return dias; //devuelve los dias de racha
  }

  //Calcula la racha y el total del hábito y los guarda en su fila de estadísticas (si no tiene fila, la crea)
  Future<void> recalcularEstadistica(Habito habito) async {
    int racha = calcularRacha(habito.fechasCompletadas);
    int total = habito.fechasCompletadas.length; //Total = cuántas fechas tiene su lista (.length)
    Estadistica? actual = await buscarEstadisticaDe(habito.id!);
    if (actual == null) {
      await insertarEstadistica(Estadistica(id: null, habitoId: habito.id!, racha: racha, total: total));
    } else {
      await actualizarEstadistica(Estadistica(id: actual.id, habitoId: habito.id!, racha: racha, total: total));
    }
  }

 //BORRAR
  Future<void> borrarTodo() async {
    final db = await abrir();
    await db.delete('estadisticas');
    await db.delete('habitos');
    await db.delete('usuarios');
    await crearAdmin(db);
  }
}