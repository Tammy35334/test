// lib/blocs/product_event.dart

import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent(); // Added const constructor

  @override
  List<Object> get props => [];
}

class FetchProducts extends ProductEvent {
  const FetchProducts(); // Added const constructor
}