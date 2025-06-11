
import '../models/Art_model.dart';

abstract class ArtTherapyState {}

class  ArtTherapyInitial extends ArtTherapyState {}

class  ArtTherapyLoading extends ArtTherapyState {}

class ArtTherapySuccess extends ArtTherapyState {
  final ArtPrediction prediction;
  ArtTherapySuccess(this.prediction);
}

class ArtTherapyError extends ArtTherapyState {
  final String message;
  ArtTherapyError(this.message);
}
