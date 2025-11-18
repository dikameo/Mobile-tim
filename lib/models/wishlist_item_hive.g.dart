// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_item_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WishlistItemHiveAdapter extends TypeAdapter<WishlistItemHive> {
  @override
  final int typeId = 1;

  @override
  WishlistItemHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WishlistItemHive(
      userId: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      productImageUrl: fields[3] as String,
      productPrice: fields[4] as double,
      productCapacity: fields[5] as String,
      productRating: fields[6] as double,
      productReviewCount: fields[7] as int,
      productCategory: fields[8] as String,
      productSpecifications: (fields[9] as Map).cast<dynamic, dynamic>(),
      productDescription: fields[10] as String,
      productImageUrls: (fields[11] as List).cast<dynamic>(),
      addedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WishlistItemHive obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.productImageUrl)
      ..writeByte(4)
      ..write(obj.productPrice)
      ..writeByte(5)
      ..write(obj.productCapacity)
      ..writeByte(6)
      ..write(obj.productRating)
      ..writeByte(7)
      ..write(obj.productReviewCount)
      ..writeByte(8)
      ..write(obj.productCategory)
      ..writeByte(9)
      ..write(obj.productSpecifications)
      ..writeByte(10)
      ..write(obj.productDescription)
      ..writeByte(11)
      ..write(obj.productImageUrls)
      ..writeByte(12)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItemHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
