import '../../../core/Models/tips&rightsModel.dart';
import '../../../core/Services/Supabase/tips&rightsService.dart';

class RightstipsRepository {
  final RightstipsService _service;

  RightstipsRepository(this._service);

  Future<List<tipsRightsModel>> fetchAll() async {
    try {
      return await _service.getAll();
    } catch (e) {
      throw Exception('Failed to fetch resources: $e');
    }
  }

  Future<tipsRightsModel> fetchById(int id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      throw Exception('Failed to fetch resource: $e');
    }
  }

  Future<tipsRightsModel> create(tipsRightsModel resource) async {
    try {
      return await _service.create(resource);
    } catch (e) {
      throw Exception('Failed to create resource: $e');
    }
  }

  Future<tipsRightsModel> update(int id, tipsRightsModel resource) async {
    try {
      return await _service.update(id, resource);
    } catch (e) {
      throw Exception('Failed to update resource: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      throw Exception('Failed to delete resource: $e');
    }
  }
}