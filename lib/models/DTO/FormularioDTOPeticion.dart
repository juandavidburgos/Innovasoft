class FormularioDTOPeticion {
  final int? id_formulario;
  final String titulo;
  final String descripcion;
  final DateTime fecha_creacion;

  FormularioDTOPeticion({
    this.id_formulario,
    required this.titulo,
    required this.descripcion,
    required this.fecha_creacion,
  });

  factory FormularioDTOPeticion.fromJson(Map<String, dynamic> json) {
    return FormularioDTOPeticion(
      id_formulario: json['id_formulario'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fecha_creacion: DateTime.parse(json['fecha_creacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_creacion': fecha_creacion.toIso8601String(),
    };
  }
}
