import 'dart:io';

import 'package:bloc/bloc.dart';

import '../models/Art_model.dart';
import '../service.dart';
import 'Art_state.dart';

class ArtCubit extends Cubit<ArtTherapyState> {
  ArtCubit() : super(ArtTherapyInitial());
  Art(File file) async {
    try {
      emit(ArtTherapyLoading());
      ArtPrediction? result = await ApiService().fetchDataFromApi(file);

      emit(ArtTherapySuccess(result!));
    } catch (e) {
      emit(ArtTherapyError("Error: $e"));
    }
    return null;
  }
}
