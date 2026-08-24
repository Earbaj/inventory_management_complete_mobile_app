import 'package:equatable/equatable.dart';
import '../../domain/entities/export_file_entity.dart';

abstract class ExportState extends Equatable {
  const ExportState();

  @override
  List<Object?> get props => [];
}

class ExportInitialState extends ExportState {
  const ExportInitialState();
}

class ExportLoadingState extends ExportState {
  final String message;

  const ExportLoadingState({this.message = 'Generating export file...'});

  @override
  List<Object?> get props => [message];
}

class ExportSuccessState extends ExportState {
  final ExportFileEntity exportFile;

  const ExportSuccessState(this.exportFile);

  @override
  List<Object?> get props => [exportFile];
}

class ExportErrorState extends ExportState {
  final String message;

  const ExportErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
