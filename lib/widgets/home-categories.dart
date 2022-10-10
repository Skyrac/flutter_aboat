import 'package:Talkaboat/models/podcasts/podcast-category.model.dart';
import 'package:Talkaboat/screens/podcase-category.screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreenCategoriesTab extends StatefulWidget {
  const HomeScreenCategoriesTab({Key? key}) : super(key: key);

  @override
  State<HomeScreenCategoriesTab> createState() => _HomeScreenCategoriesTabState();
}

class _HomeScreenCategoriesTabState extends State<HomeScreenCategoriesTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [buildSearchField(context), buildCategoryList(context)],
    ));
  }

  //TextEditingController searchController = TextEditingController();
  String search = '';

  Widget buildSearchField(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(29, 40, 58, 1.0),
                    border: Border(bottom: BorderSide(width: 2, color: Color.fromRGBO(188, 140, 75, 1.0)))),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                        child: TextField(
                      //controller: searchController,
                      onChanged: ((text) {
                        setState(() {
                          search = text.toLowerCase();
                        });
                      }),
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "Search for category...", suffixIcon: Icon(Icons.search)),
                      style: Theme.of(context).textTheme.titleLarge,
                    ))))));
  }

  var data = <PodcastCategory>[
    PodcastCategory("Arts", const AssetImage("assets/icons/icon-art.png"), 1),
    PodcastCategory("Health & Fitness", const AssetImage("assets/icons/icon-workout.png"), 2),
    PodcastCategory("Business", const AssetImage("assets/icons/icon-business-deal.png"), 3),
    PodcastCategory("Fiction", const AssetImage("assets/icons/icon-fiction.png"), 4),
    PodcastCategory("Government", const AssetImage("assets/icons/icon-poll.png"), 5),
    PodcastCategory("History", const AssetImage("assets/icons/icon-history.png"), 6),
    PodcastCategory("Leisure", const AssetImage("assets/icons/icon-art.png"), 7),
    PodcastCategory("Music", const AssetImage("assets/icons/icon-workout.png"), 8),
    PodcastCategory("News", const AssetImage("assets/icons/icon-workout.png"), 9),
    PodcastCategory("Religion & Spirituality", const AssetImage("assets/icons/icon-workout.png"), 10),
    PodcastCategory("Science", const AssetImage("assets/icons/icon-art.png"), 11),
    PodcastCategory("Sports", const AssetImage("assets/icons/icon-workout.png"), 12),
    PodcastCategory("Technology", const AssetImage("assets/icons/icon-art.png"), 13),
    PodcastCategory("TV & Film", const AssetImage("assets/icons/icon-workout.png"), 14),
    PodcastCategory("Society & Culture", const AssetImage("assets/icons/icon-art.png"), 15),
    PodcastCategory("Kids & Family", const AssetImage("assets/icons/icon-workout.png"), 16),
    PodcastCategory("Education", const AssetImage("assets/icons/icon-art.png"), 17),
    PodcastCategory("Comedy", const AssetImage("assets/icons/icon-workout.png"), 18),
  ];

  Widget buildCategoryList(BuildContext context) {
    var filteredItems = data.where((element) => search == '' || element.name.toLowerCase().contains(search)).toList();

    return GridView.count(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        shrinkWrap: true,
        crossAxisCount: 2,
        semanticChildCount: data.length,
        childAspectRatio: 170 / 70,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(filteredItems.length, (index) {
          final item = filteredItems[index];
          return makeCard(context, item, index);
        }));
  }

  Widget makeCard(BuildContext context, PodcastCategory category, int index) {
    return SizedBox(
      width: 170,
      height: 70,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
              color: const Color.fromRGBO(29, 40, 58, 1.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      print("push");
                      await Navigator.of(context).push(PageTransition(
                          alignment: Alignment.bottomCenter,
                          curve: Curves.bounceOut,
                          type: PageTransitionType.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 500),
                          reverseDuration: const Duration(milliseconds: 500),
                          child: CategoryScreen(category)));
                    },
                    child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Image(
                                image: category.image,
                                fit: BoxFit.cover,
                              ),
                            )),
                            Expanded(
                                child: Center(
                                    child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(category.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.labelLarge))))
                          ],
                        ))),
              ))),
    );
  }
}
