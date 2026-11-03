//MODELO: una fila de la tabla estadisticas (una por hábito)
class Estadistica {
  final int? id; //null mientras no está guardada
  final int habitoId; //De qué hábito es: el id de la tabla habitos
  final int racha; //Días seguidos completados hasta hoy
  final int total; //Total de días completados

  Estadistica({
    required this.id,
    required this.habitoId,
    required this.racha,
    required this.total,
  });

  //BASE DE DATOS: objeto → Map (columna → valor)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habito_id': habitoId,
      'racha': racha,
      'total': total,
    };
  }

  //BASE DE DATOS: Map de una fila → objeto
  factory Estadistica.fromMap(Map<String, dynamic> map) {
    return Estadistica(
      id: map['id'],
      habitoId: map['habito_id'],
      racha: map['racha'],
      total: map['total'],
    );
  }
}