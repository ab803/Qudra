import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Models/tips&rightsModel.dart';

class RightstipsService {
  final SupabaseClient _client;

  // This constant stores the Supabase table name used for awareness resources.
  static const _table = 'rights&tips';

  RightstipsService(this._client);

  // This constant explicitly selects both old and new awareness resource columns.
  static const String _resourceColumns = '''
    id,
    created_at,
    title,
    description,
    disability_type,
    content_type,
    media_url,
    read_time_minutes,
    is_daily_tip,
    is_featured
  ''';

  // This method loads all awareness resources from Supabase, newest first.
  Future<List<tipsRightsModel>> getAll() async {
    final data = await _client
        .from(_table)
        .select(_resourceColumns)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data)
        .map((row) => tipsRightsModel.fromJson(row))
        .toList();
  }

  // This method loads one awareness resource by id.
  Future<tipsRightsModel> getById(int id) async {
    final data = await _client
        .from(_table)
        .select(_resourceColumns)
        .eq('id', id)
        .single();

    return tipsRightsModel.fromJson(data);
  }

  // This method creates a new awareness resource in Supabase.
  Future<tipsRightsModel> create(tipsRightsModel resource) async {
    final data = await _client
        .from(_table)
        .insert(resource.toJson())
        .select(_resourceColumns)
        .single();

    return tipsRightsModel.fromJson(data);
  }

  // This method updates an existing awareness resource in Supabase.
  Future<tipsRightsModel> update(int id, tipsRightsModel resource) async {
    final data = await _client
        .from(_table)
        .update(resource.toJson())
        .eq('id', id)
        .select(_resourceColumns)
        .single();

    return tipsRightsModel.fromJson(data);
  }

  // This method deletes an awareness resource from Supabase.
  Future<void> delete(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}