import '../../../core/Models/tips&rightsModel.dart';


abstract class RightstipsState {}

class RightstipsInitial extends RightstipsState {}

class RightstipsLoading extends RightstipsState {}

class RightstipsLoaded extends RightstipsState {
  final List<tipsRightsModel> tips;
  RightstipsLoaded(this.tips);
}

class RightstipsActionSuccess extends RightstipsState {
  final String message;
  RightstipsActionSuccess(this.message);
}

class RightstipsError extends RightstipsState {
  final String message;
  RightstipsError(this.message);
}