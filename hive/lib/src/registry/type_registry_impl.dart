import 'package:hive/hive.dart';

class TypeRegistryImpl implements TypeRegistry {
  final TypeRegistry parent;
  final _typeAdaptersById = <int, ResolvedAdapter>{};
  final _typeAdaptersByType = <Type, ResolvedAdapter>{};

  TypeRegistryImpl([this.parent]);

  @override
  ResolvedAdapter findAdapterForType(Type type) {
    var resolved = _typeAdaptersByType[type];
    return resolved ?? parent?.findAdapterForType(type);
  }

  @override
  ResolvedAdapter findAdapterForTypeId(int typeId) {
    var adapter = _typeAdaptersById[typeId];
    return adapter ?? parent?.findAdapterForTypeId(typeId);
  }

  @override
  void registerAdapter<T>(TypeAdapter<T> adapter, int typeId) {
    if (typeId < TypeRegistry.minCustomTypeId || typeId > 255) {
      throw HiveError('TypeId $typeId not allowed.');
    }

    if (findAdapterForTypeId(typeId) != null) {
      throw HiveError('There is already a TypeAdapter for typeId $typeId.');
    }

    registerInternal(adapter, typeId);
  }

  void registerInternal<T>(TypeAdapter<T> adapter, int typeId) {
    var resolved = ResolvedAdapter(adapter, typeId);
    _typeAdaptersById[typeId] = resolved;
    _typeAdaptersByType[T] = resolved;
  }

  void resetAdapters() {
    _typeAdaptersById.clear();
    _typeAdaptersByType.clear();
  }
}
