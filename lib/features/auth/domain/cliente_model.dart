class ClienteModel {
  final String id;
  final String numeroDocumento;
  final String nombres;
  final String apellidos;

  const ClienteModel({
    required this.id,
    required this.numeroDocumento,
    required this.nombres,
    required this.apellidos,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] as String,
      numeroDocumento: json['numero_documento'] as String,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero_documento': numeroDocumento,
        'nombres': nombres,
        'apellidos': apellidos,
      };
}
