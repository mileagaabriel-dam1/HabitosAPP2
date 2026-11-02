import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/preferencias_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import 'registro_screen.dart';
import 'principal_screen.dart';
import 'administracion_screen.dart';

//INICIO DE SESIÓN: comprueba usuario y contraseña y abre la pantalla que toca según el rol
class LoginScreen extends StatefulWidget { //stateful porque tiene que recordar lo que se escribe en esa pantalla
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState(); //se dice que clase guarda las variables
}

class _LoginScreenState extends State<LoginScreen> {
  PreferenciasService servicio = PreferenciasService(); //servicio para leer y guardar datos
  //La pantalla crea los controllers y se los pasa a CampoTextoApp
  TextEditingController usuarioController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  //controller por campo para leer el texto escrito
  String mensaje = ''; //Mensaje de error. Vacío = no se muestra

  @override
  void initState() {
    super.initState();
    servicio.crearAdmin(); //La primera vez crea la cuenta admin / admin
  }

  @override
  void dispose() { //se ejecuta una vez al cerrar la pantalla
    usuarioController.dispose();
    contrasenaController.dispose();
    //se borran los controllers porque ya no hacen falta
    super.dispose();
    //aqui se deja que flutter haga su parte
  }

  //Acción de BotonPrincipal "Entrar"
  Future<void> entrar() async {
    String nombre = usuarioController.text;
    String contrasena = contrasenaController.text;
    if (nombre.isEmpty || contrasena.isEmpty) {
      setState(() => mensaje = 'Rellena el usuario y la contraseña');
      return;
    }

    //PERSISTENCIA: busca el usuario guardado y compara la contraseña
    final Usuario? usuario = await servicio.buscarUsuario(nombre);
    if (usuario == null || usuario.contrasena != contrasena) {
      setState(() => mensaje = 'Usuario o contraseña incorrectos');
      return;
    }

    if (!mounted) return;
    //pushReplacement: quita el login para no volver atrás a él. El admin va a Administración
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => usuario.esAdmin ? const AdministracionScreen() : PrincipalScreen(usuario: usuario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //estructura de la pagina
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SingleChildScrollView( //scroll unico
        child: Padding(
          padding: const EdgeInsets.all(16), //16px
          child: Column(
            children: [
              const Text('HabitosApp', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CampoTextoApp(etiqueta: 'Usuario', controller: usuarioController),
              CampoTextoApp(etiqueta: 'Contraseña', controller: contrasenaController, ocultar: true),
              //Solo se ve si hay mensaje
              if (mensaje.isNotEmpty) Text(mensaje, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              BotonPrincipal(texto: 'Entrar', alPulsar: entrar),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistroScreen()),
                ),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}