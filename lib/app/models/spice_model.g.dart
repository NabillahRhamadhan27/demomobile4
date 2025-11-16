// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpiceAdapter extends TypeAdapter<Spice> {
  @override
  final int typeId = 0;

  @override
  Spice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Spice(
      id: fields[0] as String,
      name: fields[1] as String,
      origin: fields[2] as String,
      exportStatus: fields[3] as String,
      image: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Spice obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.origin)
      ..writeByte(3)
      ..write(obj.exportStatus)
      ..writeByte(4)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
