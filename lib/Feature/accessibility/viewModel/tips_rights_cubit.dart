
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_0/Feature/accessibility/viewModel/tips_rights_state.dart';

import '../../../core/Models/tips&rightsModel.dart';
import '../repo/rights&tipsRepo.dart';


class RightstipsCubit extends Cubit<RightstipsState> {
  final RightstipsRepository _repository;

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
      emit(RightstipsActionSuccess('Resource created successfully'));
      await loadAll();
    } catch (e) {
      emit(RightstipsError(e.toString()));
    }
  }

  Future<void> update(int id, tipsRightsModel tips) async {
    emit(RightstipsLoading());
    try {
      await _repository.update(id, tips);
      emit(RightstipsActionSuccess('Resource updated successfully'));
      await loadAll();
    } catch (e) {
      emit(RightstipsError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    emit(RightstipsLoading());
    try {
      await _repository.delete(id);
      emit(RightstipsActionSuccess('Resource deleted successfully'));
      await loadAll();
    } catch (e) {
      emit(RightstipsError(e.toString()));
    }
  }
}