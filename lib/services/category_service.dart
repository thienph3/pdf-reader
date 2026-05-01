import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';

const _boxName = 'categories';
const _uuid = Uuid();

class CategoryService {
  late Box<Map> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  List<Category> getAll() {
    return _box.values.map((m) => Category.fromMap(m)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Category? getById(String id) {
    final map = _box.get(id);
    if (map == null) return null;
    return Category.fromMap(map);
  }

  Future<Category> create({required String name, int? colorValue}) async {
    final cat = Category(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue ?? 0xFF6366F1,
      createdAt: DateTime.now(),
    );
    await _box.put(cat.id, cat.toMap());
    return cat;
  }

  Future<Category> update(Category cat) async {
    await _box.put(cat.id, cat.toMap());
    return cat;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
