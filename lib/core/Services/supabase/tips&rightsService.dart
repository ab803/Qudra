import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Models/tips&rightsModel.dart';


class RightstipsService {
  final SupabaseClient _client;
  static const _table = 'rights&tips'; // 🔁 rename to your table

  RightstipsService(this._client);

  Future<List<tipsRightsModel>> getAll() async {
    final data = await _client.from(_table).select();
    return (data as List).map((e) => tipsRightsModel.fromJson(e)).toList();
  }

  Future<tipsRightsModel> getById(int id) async {
    final data = await _client.from(_table).select().eq('id', id).single();
    return tipsRightsModel.fromJson(data);
  }

  Future<tipsRightsModel> create(tipsRightsModel resource) async {
    final data = await _client
        .from(_table)
        .insert(resource.toJson())
        .select()
        .single();
    return tipsRightsModel.fromJson(data);
  }

  Future<tipsRightsModel> update(int id, tipsRightsModel resource) async {
    final data = await _client
        .from(_table)
        .update(resource.toJson())
        .eq('id', id)
        .select()
        .single();
    return tipsRightsModel.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}