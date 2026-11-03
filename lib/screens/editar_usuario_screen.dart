import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/base_datos_service.dart';
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
  BaseDatosService bd = BaseDatosService();
  TextEditingController usuarioController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidosController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  TextEditingController objetivoController = TextEditingController();
  bool esAdmin = false; //El administrador puede hacer administrador a otro usuario
  String mensaje = '';

  //Al editar, ponemos los datos actuales del usuario recibido
  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      usuarioController.text = widget.usuario!.usuario;
      nombreController.text = widget.usuario!.nombre;
      apellidosController.text = widget.usuario!.apellidos;
      emailController.text = widget.usuario!.email;
      contrasenaController.text = widget.usuario!.contrasena;
      objetivoController.text = '${widget.usuario!.objetivo}';
      esAdmin = widget.usuario!.esAdmin;
    }
  }

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

  //Acción de BotonPrincipal "Guardar"
  Future<void> guardar() async {
    String nombre = usuarioController.text;
    String contrasena = contrasenaController.text;
    int? objetivo = int.tryParse(objetivoController.text);
    if (nombre.isEmpty || contrasena.isEmpty || objetivo == null) {
      setState(() => mensaje = 'Rellena el usuario y la contraseña (el objetivo es un número)');
      return;
    }

    //Al crear, el nombre no puede existir ya (es la clave primaria)
    if (widget.usuario == null && await bd.buscarUsuario(nombre) != null) {
      setState(() => mensaje = 'Ese usuario ya existe');
      return;
    }

    //Al editar se mantiene la fecha de creación; al crear, la de hoy
    Usuario usuario = Usuario(
      usuario: nombre,
      nombre: nombreController.text,
      apellidos: apellidosController.text,
      email: emailController.text,
      contrasena: contrasena,
      objetivo: objetivo,
      fechaCreacion: widget.usuario?.fechaCreacion ?? DateTime.now().toString().substring(0, 10),
      rol: esAdmin ? 'administrador' : 'usuario',
    );

    //BASE DE DATOS: nuevo → insert; ya existía → update de su fila
    if (widget.usuario == null) {
      await bd.insertarUsuario(usuario);
    } else {
      await bd.actualizarUsuario(usuario);
    }

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
              //Al editar no se cambia el nombre de usuario: es la clave primaria y lo que une al usuario con sus hábitos
              if (widget.usuario == null)
                CampoTextoApp(etiqueta: 'Usuario', controller: usuarioController)
              else
                Text('Usuario: ${widget.usuario!.usuario}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CampoTextoApp(etiqueta: 'Nombre', controller: nombreController),
              CampoTextoApp(etiqueta: 'Apellidos', controller: apellidosController),
              CampoTextoApp(etiqueta: 'Email', controller: emailController),
              CampoTextoApp(etiqueta: 'Contraseña', controller: contrasenaController, ocultar: true),
              CampoTextoApp(etiqueta: 'Objetivo diario (nº de hábitos)', controller: objetivoController),
              //El rol de la cuenta fija admin no se puede cambiar
              if (widget.usuario?.usuario != 'admin')
                SwitchListTile(
                  title: const Text('Administrador'),
                  value: esAdmin,
                  onChanged: (valor) => setState(() => esAdmin = valor),
                ),
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