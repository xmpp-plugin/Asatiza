import 'package:flutter_bloc/flutter_bloc.dart';

import 'welcome_state.dart';

/// Tracks the visible Welcome slide.
class WelcomeCubit extends Cubit<WelcomeState> {
  WelcomeCubit() : super(const WelcomeState());

  void pageChanged(int page) {
    if (page >= 0 && page < WelcomeState.pageCount) {
      emit(WelcomeState(page: page));
    }
  }
}
