// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductHiveAdapter extends TypeAdapter<ProductHive> {
  @override
  final int typeId = 0;

  @override
  ProductHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductHive(
      id: fields[0] as String,
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      price: fields[3] as double,
      capacity: fields[4] as String,
      rating: fields[5] as double,
      reviewCount: fields[6] as int,
      category: fields[7] as String,
      description: fields[8] as String,
      specificationsJson: fields[9] as String,
      imageUrlsJson: fields[10] as String,
      lastSynced: fields[11] as DateTime?,
      isSynced: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProductHive obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.capacity)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.reviewCount)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.specificationsJson)
      ..writeByte(10)
      ..write(obj.imageUrlsJson)
      ..writeByte(11)
      ..write(obj.lastSynced)
      ..writeByte(12)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
