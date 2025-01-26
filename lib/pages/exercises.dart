import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracks/pages/songs.dart';

import '../utils/providers.dart';

class ExercisesPage extends ConsumerStatefulWidget {
  const ExercisesPage({super.key});

  @override
  ConsumerState<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends ConsumerState<ExercisesPage> {

  @override
  Widget build(BuildContext context) {
    final chosenExercises = ref.watch(ChosenExercisesNotifierProvider);
    final notChosenExercises = ref.watch(NotChosenExercisesNotifierProvider);

    print(chosenExercises);

    return Scaffold(
      appBar: AppBar(
        title: Text("Your sets"),
        actions: [
          TextButton(
            child: Text("Next"),
            onPressed: () {
              if (chosenExercises.isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SongsPage()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Select your exercises", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 80, right: 60, left: 60),
              child: Column(
                children: [
                  SizedBox(
                    height: 125,
                    child: Wrap(
                      children: chosenExercises.mapIndexed((index, exercise) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black, elevation: 1,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    ref.read(ChosenExercisesNotifierProvider.notifier).removeExercise(exercise);
                                    ref.read(NotChosenExercisesNotifierProvider.notifier).addExercise(exercise);
                                  });
                                },
                                child: Text(
                                    "${index+1}. ${exercise}",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white, fontWeight: FontWeight.bold)
                                )
                            )
                        );
                      }).toList(),
                    )
                  ),
                  SizedBox(
                    height: 125,
                    child: Wrap(
                      children: notChosenExercises.map((exercise) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, elevation: 1,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    ref.read(ChosenExercisesNotifierProvider.notifier).addExercise(exercise);
                                    ref.read(NotChosenExercisesNotifierProvider.notifier).removeExercise(exercise);
                                  });
                                },
                                child: Text(
                                    exercise,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.black, fontWeight: FontWeight.bold)
                                )
                            )
                        );
                      }).toList(),
                    )
                  )
                ]
              )
            )
          ]
        )
      ),
    );
  }

}