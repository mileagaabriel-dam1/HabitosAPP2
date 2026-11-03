import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/preferencias_service.dart';
import '../services/base_datos_service.dart';
import '../widgets/boton_principal.dart';
import 'editar_usuario_screen.dart';
import 'principal_screen.dart';
import 'estadisticas_screen.dart';
import 'login_screen.dart';

//ADMINISTRACIÓN: solo la ve un administrador (el login solo la abre si su rol es administrador).
//Gestiona los usuarios y, desde cada uno, sus hábitos y sus estadísticas.
class AdministracionScreen extends StatefulWidget {
  const AdministracionScreen({super.key});

  @override
  State<AdministracionScreen> createState() => _AdministracionScreenState();
}

class _AdministracionScreenState extends State<AdministracionScreen> {
  PreferenciasService servicio = PreferenciasService();
  BaseDatosService bd = BaseDatosService();
  List<Usuario> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  //BASE DE DATOS: lee todas las filas de la tabla usuarios
  Future<void> cargarDatos() async {
    usuarios = await bd.leerUsuarios();
    if (!mounted) return;
    setState(() {});
  }

  //Abre una pantalla y, al volver, recarga la lista (puede haber cambios)
  Future<void> abrir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => pantalla));
    if (!mounted) return;
    cargarDatos();
  }

  //Ventana de confirmación. Devuelve true si se pulsa Aceptar
  Future<bool> confirmar(String pregunta) async {
    bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pregunta),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Aceptar')),
        ],
      ),
    );
    return confirmado == true;
  }

  //BASE DE DATOS: borra el usuario, sus hábitos y sus estadísticas, y recarga
  Future<void> eliminarUsuario(Usuario u) async {
    if (!await confirmar('¿Eliminar a ${u.usuario} y sus hábitos?')) return;
    await bd.eliminarUsuario(u.usuario);
    cargarDatos();
  }

  //Borra todo: vacía las tablas (deja solo el admin), borra los ajustes y vuelve al login
  Future<void> borrarTodo() async {
    if (!await confirmar('¿Borrar todos los datos de la app?')) return;
    await bd.borrarTodo();
    await servicio.borrarTodo();
    if (!mounted) return;
    cerrarSesion();
  }

  void cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  //Tarjeta de un usuario con sus acciones
  Widget tarjetaUsuario(Usuario u) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(u.usuario, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('${u.nombre} ${u.apellidos} · ${u.email}'),
            Text('${u.esAdmin ? 'Administrador' : 'Usuario'} · Creado el ${u.fechaCreacion} · Objetivo: ${u.objetivo}'),
            //Wrap: como Row, pero si no caben los botones pasan a la línea de abajo
            Wrap(
              children: [
                TextButton(onPressed: () => abrir(PrincipalScreen(usuario: u)), child: const Text('Hábitos')),
                TextButton(onPressed: () => abrir(EstadisticasScreen(usuario: u.usuario, esAdmin: true)), child: const Text('Estadísticas')),
                TextButton(onPressed: () => abrir(EditarUsuarioScreen(usuario: u)), child: const Text('Editar')),
                //La cuenta fija admin no se puede eliminar
                if (u.usuario != 'admin') TextButton(onPressed: () => eliminarUsuario(u), child: const Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        actions: [
          IconButton(icon: const Icon(Icons.delete_forever), tooltip: 'Borrar todos los datos', onPressed: borrarTodo),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Cerrar sesión', onPressed: cerrarSesion),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BotonPrincipal(texto: 'Crear usuario', alPulsar: () => abrir(const EditarUsuarioScreen(usuario: null))),
              const SizedBox(height: 16),
              for (Usuario u in usuarios) tarjetaUsuario(u),
            ],
          ),
        ),
      ),
    );
  }
}