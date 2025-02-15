import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/discovery/discovery.dart';
import 'package:music_app/ui/home/view-model.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:music_app/ui/user/account.dart';

import '../../data/model/song.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Application',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true),
      home: MusicHomePage(),
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> tabs = [
    const HomeTab(),
    const Discovery(),
    const Account(),
    const Settings()
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text("Music Application"),
        ),
        child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
                backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.album), label: 'Discovery'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Account'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings), label: 'Settings')
                ]),
            tabBuilder: (BuildContext context, int index) {
              return tabs[index];
            }));
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

/*
* This is default ui contain list song
*/
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return Divider(
          color: Colors.grey,
          thickness: 1, // dộ dày 1px
          indent: 24, // cách bên trái 24px
          endIndent: 24, // cách bên phải 24px
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(
      parent: this,
      song: songs[index],
    );
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }
}

class _SongItemSection extends StatelessWidget {
  final _HomeTabPageState parent;
  final Song song;

  const _SongItemSection({required this.parent, required this.song});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: 24,
        right: 8
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: "assets/images/song-thumb.png",
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "assets/images/song-thumb.png",
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing:
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
    );
  }
}
