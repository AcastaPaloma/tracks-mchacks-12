
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracks/utils/variables.dart';

class ChosenExercisesNotifier extends Notifier<Set<String>> {

  @override
  Set<String> build() {
    return {};
  }

  void addExercise(String exercise) {
    state.add(exercise);
  }

  void removeExercise(String exercise) {
    if (state.contains(exercise)) {
      state.remove(exercise);
    }
  }
}

class NotChosenExercisesNotifier extends Notifier<Set<String>> {

  @override
  Set<String> build() {
    Set<String> exercises = {};
    for (String exercise in Exercises) {
      exercises.add(exercise);
    }
    return exercises;
  }

  void addExercise(String exercise) {
    state.add(exercise);
  }

  void removeExercise(String exercise) {
    if (state.contains(exercise)) {
      state.remove(exercise);
    }
  }

}

class ChosenSongGenres extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void addGenre(String genre) {
    state.add(genre);
  }

  void removeGenre(String genre) {
    if (state.contains(genre)) {
      state.remove(genre);
    }
  }

  void processGenre(String genre) {

    if (state.contains(genre)) {
      state.remove(genre);
    } else {
      if (state.length >= 3) {
        return;
      }
      state.add(genre);
    }
  }
}

final ChosenExercisesNotifierProvider = NotifierProvider<ChosenExercisesNotifier, Set<String>>(() {
  return ChosenExercisesNotifier();
});

final NotChosenExercisesNotifierProvider = NotifierProvider<NotChosenExercisesNotifier, Set<String>>(() {
  return NotChosenExercisesNotifier();
});

final ChosenSongGenresProvider = NotifierProvider<ChosenSongGenres, Set<String>>(() {
  return ChosenSongGenres();
});