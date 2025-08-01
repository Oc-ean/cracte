// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavouriteRecipeAdapter extends TypeAdapter<FavouriteRecipe> {
  @override
  final int typeId = 3;

  @override
  FavouriteRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavouriteRecipe(
      recipe: fields[0] as Recipe,
      dateCreated: fields[1] as DateTime,
      lastModified: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavouriteRecipe obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.recipe)
      ..writeByte(1)
      ..write(obj.dateCreated)
      ..writeByte(2)
      ..write(obj.lastModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouriteRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
