import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/preferencias_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

//REGISTRO: crea un usuario normal y vuelve al inicio de sesión
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  PreferenciasService servicio = PreferenciasService();
  TextEditingController usuarioController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  TextEditingController objetivoController = TextEditingController();
  String mensaje = '';

  @override
  void dispose() {
    usuarioController.dispose();
    contrasenaController.dispose();
    objetivoController.dispose();
    super.dispose();
  }

  //Acción de BotonPrincipal "Registrarse"
  Future<void> registrarse() async {
    String nombre = usuarioController.text;
    String contrasena = contrasenaController.text;
    int? objetivo = int.tryParse(objetivoController.text); //null si no es un número
    if (nombre.isEmpty || contrasena.isEmpty || objetivo == null) {
      setState(() => mensaje = 'Rellena todos los campos (el objetivo es un número)');
      return;
    }

    //PERSISTENCIA: el nombre de usuario no se puede repetir
    if (await servicio.buscarUsuario(nombre) != null) {
      setState(() => mensaje = 'Ese usuario ya existe');
      return;
    }

    //PERSISTENCIA: guarda el usuario. La fecha de creación se pone sola (hoy)
    await servicio.guardarUsuario(Usuario(
      usuario: nombre,
      contrasena: contrasena,
      objetivo: objetivo,
      esAdmin: false,
      fechaCreacion: DateTime.now().toString().substring(0, 10),
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