
import 'package:equatable/equatable.dart';

abstract class OrderCodeState extends Equatable {
  const OrderCodeState();

  @override
  List<Object?> get props => [];
}

class OrderCodeInitial extends OrderCodeState {}

class OrderCodeLoading extends OrderCodeState {}

class OrderCodeSuccess extends OrderCodeState {}

class OrderCodeFailure extends OrderCodeState {
  final String errorKey;
  const OrderCodeFailure(this.errorKey);

  @override
  List<Object?> get props => [errorKey];
}
