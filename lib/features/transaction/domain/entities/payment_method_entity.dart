import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final String id;
  final String name;

  const PaymentMethodEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];

  PaymentMethodEntity copyWith({String? id, String? name}) {
    return PaymentMethodEntity(id: id ?? this.id, name: name ?? this.name);
  }
}
