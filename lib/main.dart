import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (_) => AppModel(),
        child: App(),
    )
  );
}

const List<String> urls = [
  "https://live.staticflickr.com/65535/50489498856_67fbe52703_b.jpg",
  "https://live.staticflickr.com/65535/50488789068_de551f0ba7_b.jpg",
  "https://live.staticflickr.com/65535/50488789118_247cc6c20a.jpg",
  "https://live.staticflickr.com/65535/50488789168_ff9f1f8809.jpg"
];

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            title: 'Photo Viewer',
            home: GalleryPage(
              title: "Image Gallery",
            ),
    );
  }
}

class AppModel extends ChangeNotifier {
  bool isTagging = false;

  List<PhotoState> photoStates = List.of(urls.map((url) => PhotoState(url)));

  Set<String> tags = {"all", "nature", "cat"};

  void toggleTagging(String? url) {
    isTagging = !isTagging;
    photoStates.forEach((element) {
      if (isTagging && element.url == url) {
        element.selected = true;
      } else {
        element.selected = false;
      }
    });
    notifyListeners();
  }

  void onPhotoSelect(String url, bool selected) {
    photoStates.forEach((element) {
      if (element.url == url) {
        element.selected = selected;
      }
    });
    notifyListeners();
  }

  void selectTag(String tag) {
    if (isTagging) {
      if (tag != "all") {
        photoStates.forEach((element) {
          if (element.selected!) {
            element.tags.add(tag);
          }
        });
      }
      toggleTagging(null);
    } else {
      photoStates.forEach((element) {
        element.display = tag == "all" ? true : element.tags.contains(tag);
      });
    }
    notifyListeners();
  }
}

class PhotoState {
  String url;
  bool? selected;
  bool? display;
  Set<String> tags = {};

  PhotoState(this.url, {selected = false, display = true, tags});
}

class GalleryPage extends StatelessWidget {
  final String? title;

  GalleryPage({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title!)),
      body: GridView.count(
          primary: false,
          crossAxisCount: 2,
          children: List.of(context.watch<AppModel>().photoStates
              .where((ps) => ps.display ?? true)
              .map((ps) => Photo(state: ps))
          )
      ),
      drawer: Drawer(
          child: ListView(
        children: List.of(context.watch<AppModel>().tags.map((t) => ListTile(
              title: Text(t),
              onTap: () {
                context.read<AppModel>().selectTag(t);
                Navigator.of(context).pop();
              },
            ))),
      )),
    );
  }
}

class Photo extends StatelessWidget {
  final PhotoState? state;

  Photo({this.state});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      GestureDetector(
          child: Image.network(state!.url),
          onLongPress: () => context.read<AppModel>().toggleTagging(state!.url))
    ];

    if (context.watch<AppModel>().isTagging) {
      children.add(Positioned(
          left: 20,
          top: 0,
          child: Theme(
              data: Theme.of(context)
                  .copyWith(unselectedWidgetColor: Colors.grey[200]),
              child: Checkbox(
                onChanged: (value) {
                  context.read<AppModel>().onPhotoSelect(state!.url, value!);
                },
                value: state!.selected,
                activeColor: Colors.white,
                checkColor: Colors.black,
              ))));
    }

    return Container(
        padding: EdgeInsets.only(top: 10),
        child: Stack(alignment: Alignment.center, children: children));
  }
}
