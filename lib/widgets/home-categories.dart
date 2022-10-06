import 'package:flutter/material.dart';

class HomeScreenCategoriesTab extends StatefulWidget {
  const HomeScreenCategoriesTab({Key? key}) : super(key: key);

  @override
  State<HomeScreenCategoriesTab> createState() => _HomeScreenCategoriesTabState();
}

class PodcastCategory {
  String name;
  AssetImage image;

  PodcastCategory(this.name, this.image);
}

class _HomeScreenCategoriesTabState extends State<HomeScreenCategoriesTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [buildCategoryList(context)],
    ));
  }

  var data = <PodcastCategory>[
    PodcastCategory("Arts", const AssetImage("assets/images/aboat.png")),
    PodcastCategory("Arts2", const AssetImage("assets/images/aboat.png")),
    PodcastCategory("Arts3", const AssetImage("assets/images/aboat.png"))
  ];

  Widget buildCategoryList(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            semanticChildCount: data.length,
            childAspectRatio: 170 / 70,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(data.length, (index) {
              if (data[index] == null) {
                return const ListTile();
              } else {
                final item = data[index]!;
                return makeCard(context, item, index);
              }
            })));
  }

  Widget makeCard(BuildContext context, PodcastCategory category, int index) {
    return Padding(
        padding: EdgeInsets.only(bottom: 10, left: index / 2.0 == 0.5 ? 5 : 0, right: index / 2.0 == 0.0 ? 5 : 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: const Color.fromRGBO(99, 163, 253, 0.5),
            child: Center(
                child: InkWell(
              onTap: () async {
                /*await userService.UpdatePodcastVisitDate(entry.id);
            setState(() {});
            Navigator.push(
                context,
                PageTransition(
                    alignment: Alignment.bottomCenter,
                    curve: Curves.bounceOut,
                    type: PageTransitionType.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                    child: PodcastDetailScreen(podcastSearchResult: entry)));*/
              },
              child: SizedBox(
                  width: 170,
                  height: 70,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 90,
                                width: 90,
                                child: Image(
                                  image: category.image,
                                  fit: BoxFit.cover,
                                ),
                              ))),
                      Center(
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(category.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.titleMedium)))
                    ],
                  )),
            )),
          ),
        ));
  }
}
