import 'package:equatable/equatable.dart';

class WelcomeState extends Equatable {
  const WelcomeState({this.page = 0});

  static const int pageCount = 3;

  /// 0-based slide index.
  final int page;

  bool get isLast => page == pageCount - 1;

  @override
  List<Object?> get props => <Object?>[page];
}
