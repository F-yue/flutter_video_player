import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_video_player/custom/navigationbar.dart';
import 'package:flutter_video_player/pages/home/view_model/home_view_model.dart';
import 'package:flutter_video_player/util/util.dart';

import '../../../models/models.dart';
import '../../../routes/route_manager.dart';
import '../../../user/user_manager.dart';
import '../model/home_model.dart';
import '../views/big_eye_view.dart';
import '../views/cell_big_eye.dart';
import '../views/cell_guide.dart';
import '../views/cell_multi.dart';
import '../views/cell_single_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // bool changeColor = true;
  /*滚动控制器*/
  late final ScrollController _scrollController;
  late final HomeViewModel viewModel;

  late final HomeBigEyeView _bigEyeView;

  final ValueNotifier<double> offSetNotifier = ValueNotifier<double>(0);
  final ValueNotifier<bool> changeColorNotifier = ValueNotifier<bool>(true);

  /*在build方法之前进行初始化*/
  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      viewModel.requestData().then((value) {
        /*确保State已被插入到树中*/
        if (mounted) {
          _bigEyeView = HomeBigEyeView(
            imgUrl: value?.imgUrl,
          );
          setState(() {});
        }
      });
    });

    /*滚动控制器*/
    _scrollController = ScrollController(initialScrollOffset: 0);
    _scrollController.addListener(
      () {
        if (_scrollController.offset <= 0) {
          offSetNotifier.value = 0;
          if (changeColorNotifier.value == false) {
            changeColorNotifier.value = true;
          }
        } else {
          offSetNotifier.value = -_scrollController.offset;
          if (changeColorNotifier.value) {
            changeColorNotifier.value = false;
          }
        }
      },
    );
  }

  @override
  void dispose() {
    offSetNotifier.dispose();
    changeColorNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _createUI();
  }

  Widget _createUI() {
    return viewModel.pageModelList.isEmpty
        ? Container(
            alignment: Alignment.topCenter,
            color: Colors.white,
            child: Container(
              color: Colors.amber,
              height: Util.navgationBarHeight,
              child: _navigationBar..color = const Color(0xE5383B4B),
            ),
          )
        : Stack(
            children: <Widget>[
              /*轮播图背景*/
              ValueListenableBuilder<double>(
                valueListenable: offSetNotifier,
                builder: (context, offsetX, child) {
                  return Positioned(
                    top: offsetX,
                    left: 0,
                    right: 0,
                    child: _bigEyeView,
                  );
                },
              ),
              /*导航栏图标*/
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: Util.navgationBarHeight,
                child: ValueListenableBuilder<bool>(
                  valueListenable: changeColorNotifier,
                  builder: (context, value, child) {
                    // changeColor = value;
                    return _navigationBar;
                  },
                ),
              ),
              /*轮播图和电影列表*/
              Positioned(
                top: Util.navgationBarHeight,
                left: 0,
                right: 0,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: Util.instance.contentHeight(),
                  ),
                  /*下拉刷新，上拉加载更多*/
                  child: EasyRefresh(
                    firstRefresh: false,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: _scrollController,
                      itemCount: viewModel.pageModelList.length,
                      itemBuilder: _itemBuilder,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                    ),
                    onRefresh: () async {
                      viewModel.requestData().then((value) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                  ),
                ),
              )
            ],
          );
  }

  /*构建列表项*/
  Widget _itemBuilder(BuildContext context, int index) {
    HomePageModel model = viewModel.pageModelList[index];
    if (model.type == SectionType.bigEye) {
      List<BigEyeModel> models = model.itemArray as List<BigEyeModel>;
      return BigEyeViewCell(
        modelList: models,
        indexChanged: (index) {
          if (mounted) {
            _bigEyeView.imageUrl = models[index].imgUrl;
          }
        },
      );
    }
    if (model.type == SectionType.guide) {
      return GuideViewCell(
        itemArray: model.itemArray as List<GuideModel>,
      );
    }
    if (model.type == SectionType.singleImage) {
      return SingleImageViewCell(
        model: model.itemArray.first,
      );
    }

    if (model.type == SectionType.mutilEntry) {
      return MultiItemCell(
        model: model,
      );
    }

    return Container(
      height: 20,
    );
  }
  /*UINavigationBar是iOS开发中的一个导航栏控件*/
  UINavigationBar get _navigationBar => UINavigationBar(
        title: '首页推荐',
        isCenterTitle: false,
        isSecondPage: false,
        color: changeColorNotifier.value
            ? Colors.amber.withOpacity(0)
            : const Color(0xE5383B4B),
        tailing: <Widget>[
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 42,
            child: const Icon(
              Icons.history,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigator.pushNamed(
              //   context,
              //   RouteManager.fullScreenPlayer,
              // );
            },
          ),
          const SizedBox(
            width: 12,
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 42,
            child: const Icon(
              Icons.search,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () async {
                Navigator.pushNamed(context, RouteManager.login);
            },
          ),
        ],
      );
}
