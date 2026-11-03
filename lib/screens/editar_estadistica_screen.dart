import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../models/estadistica.dart';
import '../services/base_datos_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

//CREAR Y EDITAR ESTADÍSTICA (solo administrador, desde Estadísticas). Misma pantalla para las dos cosas
class EditarEstadisticaScreen extends StatefulWidget {
  final Habito habito; //De qué hábito es
  final Estadistica? estadistica; //null = crear una nueva
  const EditarEstadisticaScreen({super.key, required this.habito, required this.estadistica});

  @override
  State<EditarEstadisticaScreen> createState() => _EditarEstadisticaScreenState();
}

class _EditarEstadisticaScreenState extends State<EditarEstadisticaScreen> {
  BaseDatosService bd = BaseDatosService();
  TextEditingController rachaController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  String mensaje = '';

  //Al editar, ponemos los valores actuales
  @override
  void initState() {
    super.initState();
    if (widget.estadistica != null) {
      rachaController.text = '${widget.estadistica!.racha}';
      totalController.text = '${widget.estadistica!.total}';
    }
  }

  @override
  void dispose() {
    rachaController.dispose();
    totalController.dispose();
    super.dispose();
  }

  //Acción de BotonPrincipal "Guardar"
  Future<void> guardar() async {
    int? racha = int.tryParse(rachaController.text); //null si no es un número
    int? total = int.tryParse(totalController.text);
    if (racha == null || total == null) {
      setState(() => mensaje = 'La racha y el total tienen que ser números');
      return;
    }

    //BASE DE DATOS: sin estadística → insertar; con estadística → actualizar la fila con su mismo id
    if (widget.estadistica == null) {
      await bd.insertarEstadistica(Estadistica(id: null, habitoId: widget.habito.id!, racha: racha, total: total));
    } else {
      await bd.actualizarEstadistica(
          Estadistica(id: widget.estadistica!.id, habitoId: widget.habito.id!, racha: racha, total: total));
    }

    if (!mounted) return;
    Navigator.pop(context); //Vuelve a Estadísticas, que recarga
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estadística de ${widget.habito.nombre}')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CampoTextoApp(etiqueta: 'Racha actual (días)', controller: rachaController),
              CampoTextoApp(etiqueta: 'Días completados', controller: totalController),
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