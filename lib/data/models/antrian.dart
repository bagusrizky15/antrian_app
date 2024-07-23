// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Antrian {
  final int? id;
  final String nama;
  final String noAntrian;
  final bool isActive;
  Antrian({
    this.id,
    required this.nama,
    required this.noAntrian,
    required this.isActive,
  });

  Antrian copyWith({
    int? id,
    String? nama,
    String? noAntrian,
    bool? isActive,
  }) {
    return Antrian(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      noAntrian: noAntrian ?? this.noAntrian,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nama': nama,
      'noAntrian': noAntrian,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Antrian.fromMap(Map<String, dynamic> map) {
    return Antrian(
      id: map['id'] != null ? map['id'] as int : null,
      nama: map['nama'] as String,
      noAntrian: map['noAntrian'] as String,
      isActive: map['isActive'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Antrian.fromJson(String source) => Antrian.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Antrian(id: $id, nama: $nama, noAntrian: $noAntrian, isActive: $isActive)';
  }

  @override
  bool operator ==(covariant Antrian other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.nama == nama &&
      other.noAntrian == noAntrian &&
      other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      nama.hashCode ^
      noAntrian.hashCode ^
      isActive.hashCode;
  }
}

var dataAntrian = [
  Antrian(
    id: 1,
    nama: 'Teller',
    noAntrian: 'A-1',
    isActive: true
  ),
  Antrian(
    id: 2,
    nama: 'STNK',
    noAntrian: 'B-1',
    isActive: false
  ),
  Antrian(
    id: 3,
    nama: 'SIM',
    noAntrian: 'C-1',
    isActive: true
  ),
];
