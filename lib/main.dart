import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart' as c;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class IOFileSystem implements c.FileSystem {
  final Future<Directory> _fileDir;

  IOFileSystem(String key) : _fileDir = createDirectory(key);

  static Future<Directory> createDirectory(String key) async {
    var baseDir = await getExternalStorageDirectory();
    var path = p.join(baseDir!.path, key);

    var fs = const LocalFileSystem();
    var directory = fs.directory((path));
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    return (await _fileDir).childFile(name);
  }

}

class _MyHomePageState extends State<MyHomePage> {

  static const key = 'customCacheKey';
  static CacheManager instanceCacheManager = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 20,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: Image.network(
              'https://image.shutterstock.com/z/stock-photo-mobile-virtual-reality-user-d-render-of-man-experiencing-augmented-reality-on-mobile-phone-to-685831765.jpg',
            ),
            alignment: Alignment.center,
          ),
          Container(
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: Image(
                image: CachedNetworkImageProvider(
                  'https://image.shutterstock.com/z/stock-photo-data-interface-explorer-astronaut-d-illustration-of-space-suit-wearing-male-figure-accessing-2076066187.jpg',
                  cacheManager: instanceCacheManager
                )
            ),
          ),
        ],
      ),
    );
  }
}
