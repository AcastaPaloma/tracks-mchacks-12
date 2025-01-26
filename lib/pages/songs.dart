import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracks/pages/record.dart';

import '../utils/providers.dart';
import '../utils/variables.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  ConsumerState<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> {
  @override
  Widget build(BuildContext context) {
    final chosenGenres = ref.watch(ChosenSongGenresProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Songs Pick"),
        actions: [
          TextButton(
            child: Text("Next"),
            onPressed: () {
              if (chosenGenres.isEmpty) return;
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const RecordPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Choose your genre", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.network("https://blog.boostcollective.ca/hs-fs/hubfs/Spotify%20Black%20Logo%20PNG.png?width=400&name=Spotify%20Black%20Logo%20PNG.png", scale: 30,), SizedBox(width: 5), Text("Spotify connected ✅"),],),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 80, right: 60, left: 60),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(Genres.length, (index) {
                  final genre = Genres[index];
                  final isSelected = chosenGenres.contains(genre);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? HighlightColor : Colors.white, elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        child: Text(
                          genre,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)
                        ),
                        onPressed: () {
                          setState(() {
                            ref.read(ChosenSongGenresProvider.notifier).processGenre(genre);
                          });
                        }
                    )
                  );
                }),
              )
            )
          ],
        )
      )
    );
  }

}