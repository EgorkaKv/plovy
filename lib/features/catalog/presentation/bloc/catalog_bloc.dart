import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plovy/features/catalog/domain/repositories/hairstyle_repository.dart';

// Events

abstract class CatalogEvent {
  const CatalogEvent();
}

class CatalogStarted extends CatalogEvent {
  const CatalogStarted();
}

class CatalogRefreshRequested extends CatalogEvent {
  const CatalogRefreshRequested();
}

// States

abstract class CatalogState {
  const CatalogState();
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogLoaded extends CatalogState {
  const CatalogLoaded(this.result);
  final HairstyleResult result;
}

class CatalogError extends CatalogState {
  const CatalogError(this.message);
  final String message;
}

// Bloc

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(this._repository) : super(const CatalogLoading()) {
    on<CatalogStarted>(_onLoad);
    on<CatalogRefreshRequested>(_onLoad);
  }

  final HairstyleRepository _repository;

  Future<void> _onLoad(CatalogEvent event, Emitter<CatalogState> emit) async {
    emit(const CatalogLoading());
    try {
      final result = await _repository.getHairstyles();
      emit(CatalogLoaded(result));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}
