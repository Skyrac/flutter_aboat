import 'package:flutter/material.dart';
import 'package:talkaboat/services/repositories/mediacenter.repository.dart';
import 'package:talkaboat/themes/colors.dart';
import 'package:talkaboat/widgets/library-preview.widget.dart';

import '../models/podcasts/podcast.model.dart';
import '../widgets/home-app-bar.widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  List<Widget> createListOfCategories() {
    List<Podcast> podcasts = MediacenterRepository.getLibraryMock();
    List<Widget> libraryPreviews = podcasts
        .map((Podcast podcast) => LibraryPreviewWidget(podcast: podcast))
        .toList();
    return libraryPreviews;
  }

  Widget createLibraryPreviewGrid() {
    return Container(
        height: 400,
        padding: const EdgeInsets.all(10),
        child: GridView.count(
          childAspectRatio: 5 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: createListOfCategories(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: Column(
        children: [
          HomeAppBarWidget(),
          SizedBox(height: 5),
          createLibraryPreviewGrid()
        ],
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    ));
  }
}
