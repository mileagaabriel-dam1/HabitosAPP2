import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/base_datos_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

//REGISTRO: crea un usuario normal y vuelve al inicio de sesión
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  BaseDatosService bd = BaseDatosService();
  TextEditingController usuarioController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidosController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  TextEditingController objetivoController = TextEditingController();
  String mensaje = '';

  @override
  void dispose() {
    usuarioController.dispose();
    nombreController.dispose();
    apellidosController.dispose();
    emailController.dispose();
    contrasenaController.dispose();
    objetivoController.dispose();
    super.dispose();
  }

  //Acción de BotonPrincipal "Registrarse"
  Future<void> registrarse() async {
    String nombre = usuarioController.text;
    String contrasena = contrasenaController.text;
    int? objetivo = int.tryParse(objetivoController.text); //null si no es un número
    if (nombre.isEmpty || contrasena.isEmpty || nombreController.text.isEmpty || emailController.text.isEmpty || objetivo == null) {
      setState(() => mensaje = 'Rellena usuario, nombre, email y contraseña (el objetivo es un número)');
      return;
    }

    //BASE DE DATOS: el nombre de usuario no se puede repetir (es la clave primaria)
    if (await bd.buscarUsuario(nombre) != null) {
      setState(() => mensaje = 'Ese usuario ya existe');
      return;
    }

    //BASE DE DATOS: inserta la fila. La fecha de creación se pone sola (hoy) y el rol siempre es usuario
    await bd.insertarUsuario(Usuario(
      usuario: nombre,
      nombre: nombreController.text,
      apellidos: apellidosController.text,
      email: emailController.text,
      contrasena: contrasena,
      objetivo: objetivo,
      fechaCreacion: DateTime.now().toString().substring(0, 10),
      rol: 'usuario',
    ));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario creado. Ya puedes entrar')));
    Navigator.pop(context); //Vuelve al inicio de sesión
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CampoTextoApp(etiqueta: 'Usuario', controller: usuarioController),
              CampoTextoApp(etiqueta: 'Nombre', controller: nombreController),
              CampoTextoApp(etiqueta: 'Apellidos', controller: apellidosController),
              CampoTextoApp(etiqueta: 'Email', controller: emailController),
              CampoTextoApp(etiqueta: 'Contraseña', controller: contrasenaController, ocultar: true),
              CampoTextoApp(etiqueta: 'Objetivo diario (nº de hábitos)', controller: objetivoController),
              if (mensaje.isNotEmpty) Text(mensaje, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              BotonPrincipal(texto: 'Registrarse', alPulsar: registrarse),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ya tengo cuenta: volver al inicio de sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}