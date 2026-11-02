import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/preferencias_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

//CREAR Y EDITAR USUARIO (desde Administración). Misma pantalla para las dos cosas
class EditarUsuarioScreen extends StatefulWidget {
  final Usuario? usuario; //null = crear uno nuevo
  const EditarUsuarioScreen({super.key, required this.usuario});

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  PreferenciasService servicio = PreferenciasService();
  TextEditingController usuarioController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  TextEditingController objetivoController = TextEditingController();
  String mensaje = '';

  //Al editar, ponemos los datos actuales del usuario recibido
  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      usuarioController.text = widget.usuario!.usuario;
      contrasenaController.text = widget.usuario!.contrasena;
      objetivoController.text = '${widget.usuario!.objetivo}';
    }
  }

  @override
  void dispose() {
    usuarioController.dispose();
    contrasenaController.dispose();
    objetivoController.dispose();
    super.dispose();
  }

  //Acción de BotonPrincipal "Guardar"
  Future<void> guardar() async {
    String nombre = usuarioController.text;
    String contrasena = contrasenaController.text;
    int? objetivo = int.tryParse(objetivoController.text);
    if (nombre.isEmpty || contrasena.isEmpty || objetivo == null) {
      setState(() => mensaje = 'Rellena todos los campos (el objetivo es un número)');
      return;
    }

    //Al crear, el nombre no puede existir ya
    if (widget.usuario == null && await servicio.buscarUsuario(nombre) != null) {
      setState(() => mensaje = 'Ese usuario ya existe');
      return;
    }

    //PERSISTENCIA: al editar se mantienen el rol y la fecha de creación; al crear, usuario normal de hoy
    await servicio.guardarUsuario(Usuario(
      usuario: nombre,
      contrasena: contrasena,
      objetivo: objetivo,
      esAdmin: widget.usuario?.esAdmin ?? false,
      fechaCreacion: widget.usuario?.fechaCreacion ?? DateTime.now().toString().substring(0, 10),
    ));

    if (!mounted) return;
    Navigator.pop(context); //Vuelve a Administración, que recarga la lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.usuario == null ? 'Crear usuario' : 'Editar usuario')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              //Al editar no se cambia el nombre: es lo que identifica al usuario y a sus hábitos
              if (widget.usuario == null)
                CampoTextoApp(etiqueta: 'Usuario', controller: usuarioController)
              else
                Text('Usuario: ${widget.usuario!.usuario}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CampoTextoApp(etiqueta: 'Contraseña', controller: contrasenaController, ocultar: true),
              CampoTextoApp(etiqueta: 'Objetivo diario (nº de hábitos)', controller: objetivoController),
              if (mensaje.isNotEmpty) Text(mensaje, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              BotonPrincipal(texto: 'Guardar', alPulsar: guardar),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ],
          ),
        ),
      ),
    );
  }
}