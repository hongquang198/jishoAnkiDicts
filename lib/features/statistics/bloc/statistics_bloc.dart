import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jisho_anki/core/domain/entities/user_data/user_study_stats.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';

// --- Events ---
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudyStats extends StatisticsEvent {
  const LoadStudyStats();
}

class RefreshStudyStats extends StatisticsEvent {
  const RefreshStudyStats();
}

// --- State ---
abstract class StatisticsState extends Equatable {
  const StatisticsState();
  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final UserStudyStats stats;
  const StatisticsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

// --- BLoC ---
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final UserDataRepository repository;
  StreamSubscription? _cardsSubscription;

  StatisticsBloc({required this.repository}) : super(StatisticsInitial()) {
    on<LoadStudyStats>(_onLoadStudyStats);
    on<RefreshStudyStats>(_onRefreshStudyStats);
  }

  Future<void> _onLoadStudyStats(
    LoadStudyStats event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());

    await _cardsSubscription?.cancel();
    _cardsSubscription = repository.watchReviewCards().listen((_) {
      add(const RefreshStudyStats());
    });

    final stats = await repository.getStudyStats();
    emit(StatisticsLoaded(stats));
  }

  Future<void> _onRefreshStudyStats(
    RefreshStudyStats event,
    Emitter<StatisticsState> emit,
  ) async {
    final stats = await repository.getStudyStats();
    emit(StatisticsLoaded(stats));
  }

  @override
  Future<void> close() {
    _cardsSubscription?.cancel();
    return super.close();
  }
}
