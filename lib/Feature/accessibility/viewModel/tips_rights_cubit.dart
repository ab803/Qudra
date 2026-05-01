import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qudra_0/Feature/accessibility/viewModel/tips_rights_state.dart';
import '../../../core/Models/tips&rightsModel.dart';
import '../../../core/Services/Localization/ar.dart';
import '../../../core/Services/Localization/en.dart';
import '../repo/rights&tipsRepo.dart';

class RightstipsCubit extends Cubit<RightstipsState> {
  final RightstipsRepository _repository;

  // This key reuses the same saved language preference used by the app language cubit.
  static const String _languageKey = 'app_language';

  RightstipsCubit(this._repository) : super(RightstipsInitial());

  Future<void> loadAll() async {
    emit(RightstipsLoading());
    try {
      final tips = await _repository.fetchAll();
      emit(RightstipsLoaded(tips));
    } catch (e) {
      emit(RightstipsError(e.toString()));
    }
  }

  Future<void> create(tipsRightsModel tips) async {
    emit(RightstipsLoading());
    try {
      await _repository.create(tips);
      // This success message is localized based on the saved app language.
      emit(RightstipsActionSuccess(
        await _translate('resource_created_success'),
      ));
      await loadAll();
    } catch (e) {
      emit(RightstipsError(e.toString()));
    }
  }

  Future<void> update(int id, tipsRightsModel tips) async {
    emit(RightstipsLoading());
    try {
      await _repository.update(id, tips);
      // This success message is localized based on the saved app language.
      emit(RightstipsActionSuccess(
        await _translate('resource_updated_success'),
      ));
      await loadAll();
    } catch (e) {
      emit(RightstipsError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    emit(RightstipsLoading());
    try {
      await _repository.delete(id);
      // This success message is localized based on the saved app language.
      emit(RightstipsActionSuccess(
        await _translate('resource_deleted_success'),
      ));
      await loadAll();
    } catch (e) {
      emit(RightstipsError(e.toString()));
    }
  }

  // This helper returns the localized value for a given key based on the saved language or system locale.
  Future<String> _translate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageKey);

    final localeCode = (savedCode == null || savedCode == 'system')
        ? WidgetsBinding.instance.platformDispatcher.locale.languageCode
        : savedCode;

    final values = localeCode == 'ar' ? ar : en;
    return values[key] ?? key;
  }
}