import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_video_player/util/util.dart';

class HomeBigEyeView extends StatelessWidget {
  HomeBigEyeView({
    Key? key,
    this.imgUrl,
  }) : super(key: key);

  final String? imgUrl;
  set imageUrl(String? url) {
    if (url?.isEmpty == true) {
      return;
    }
    imgUrlNotify.value = url;
  }

  late final ValueNotifier<String?> imgUrlNotify =
      ValueNotifier<String?>(imgUrl);

  @override
  Widget build(BuildContext context) {
    /*媒体查询获取屏幕尺寸，返回值为Size对象，包含屏幕宽、高*/
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = width / Util.bigEyeImgRatio;
    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height,
            /*在侦听器中构建UI，当imgUrlNotify的值改变时动态重构子树*/
            child: ValueListenableBuilder<String?>(
              valueListenable: imgUrlNotify,
              builder: (context, url, child) {
                if (url?.isEmpty == true) {
                  return const SizedBox.shrink();
                }
                return Image.network(
                  url ?? '',
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                );
              },
            ),
          ),
          Positioned(
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                /*渐变色组件*/
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF383B4B),
                    Color(0x99383B4B),
                    Color(0x00383B4B),
                  ],
                  stops: [0.60, 0.79, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height,
            /*将元素裁剪为矩形*/
            child: ClipRect(
              /*设置背景模糊*/
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Opacity(
                  opacity: 0,
                  child: Container(
                    color: Colors.black45,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: height - 200,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FFFFFF), Colors.white],
                  stops: [0, 0.72],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
