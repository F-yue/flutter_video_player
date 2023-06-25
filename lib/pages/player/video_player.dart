// ignore_for_file: must_be_immutable, camel_case_types

import 'package:flutter/services.dart';
import 'package:flutter_video_player/pages/drama_detail/model/video_info_model.dart';
import 'package:flutter_video_player/pages/drama_detail/page/drama_detail_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'controller_overlay.dart';

final overlayKey = GlobalKey(debugLabel: 'overlayKey');

class VideoPlayerLayer extends StatefulWidget
    implements ControllerOverlayCallback {
  VideoPlayerLayer({
    Key? key,
    this.smallScreenCallback,
    this.fullScreenCallback,
    this.nextSourceCallback,
  }) : super(key: key);

  @override
  _VideoPlayerLayerState createState() => _VideoPlayerLayerState();

  @override
  VoidCallback? smallScreenCallback;

  @override
  VoidCallback? fullScreenCallback;

  @override
  VoidCallback? nextSourceCallback;
}

class _VideoPlayerLayerState extends State<VideoPlayerLayer> {
  bool isFullScreen = false;

  late PlayerControllerOverlay overlay;
  VideoPlayerController? oldController;
  late VideoPlayerController newController;

  int? _oldPlayInfoId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    PlayInfo? info =
        DramaPlayInfoWidget.of(context)?.viewModel.playInfoModel?.playInfo;
    int? playId = info?.episodeSid;
    if (_oldPlayInfoId == playId) {
      return;
    }
    try {
      if (oldController != null) {
        oldController?.dispose();
      }
    } catch (e) {
      //(e);
    }

    String playUrl = info?.url ?? '';
    if (playUrl.isNotEmpty) {
      newController = VideoPlayerController.network(playUrl)..initialize();
      _oldPlayInfoId = info?.episodeSid;
      oldController = newController;
    }
  }

  @override
  void dispose() {
    if (newController.value.isPlaying) {
      newController.pause();
    }
    oldController?.dispose();
    newController.dispose();
    super.dispose();
  }

  Widget get playerView {
    return Center(
      child: AspectRatio(
        aspectRatio: newController.value.aspectRatio,
        child: VideoPlayer(newController),
      ),
    );
  }

  PlayerControllerOverlay get controllerOverlay {
    return PlayerControllerOverlay(
      key: overlayKey,
      player: newController,
      isFullScreen: isFullScreen,
      smallScreenCallback: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        setState(() {
          isFullScreen = false;
        });
        widget.smallScreenCallback?.call();
      },
      fullScreenCallback: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        setState(() {
          isFullScreen = true;
        });
        widget.fullScreenCallback?.call();
      },
      nextSourceCallback: widget.nextSourceCallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    DramaPlayInfoWidget.of(context)?.viewModel;
    return FutureBuilder(
      initialData: false,
      future: started(),
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: Colors.black,
            child: Stack(
              children: [
                playerView,
                controllerOverlay,
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<bool> started() async {
    try {
      if (!newController.value.isInitialized &&
          !newController.value.isPlaying) {
        await newController.play();
        return true;
      } else {
        return newController.value.isPlaying;
      }
    } catch (e) {
      return false;
    }
  }
}
