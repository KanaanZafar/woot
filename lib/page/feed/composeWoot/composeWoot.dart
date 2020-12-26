import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:translator/translator.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wootter_x/bloc/notifications_sender.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/page/feed/composeWoot/widget/composeWooPool.dart';
import 'package:wootter_x/page/feed/composeWoot/widget/composeWootVideo.dart';
import 'package:wootter_x/widgets/woot/components/video_thumbnail.dart';
import 'package:wootter_x/widgets/woot/widgets/wootImage.dart';
import '../../../helper/constant.dart';
import '../../../helper/theme.dart';
import '../../../helper/utility.dart';
import '../composeWoot/state/composeWootState.dart';
import '../composeWoot/widget/composeBottomIconWidget.dart';
import '../composeWoot/widget/composeWootImage.dart';
import 'package:wootter_x/page/feed/composeWoot/widget/widgetView.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/state/searchState.dart';
import 'package:wootter_x/widgets/customAppBar.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/customUrlText.dart';
import 'package:wootter_x/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';
import 'package:wootter_x/widgets/woot/woot.dart';
import 'package:wootter_x/widgets/woot/widgets/wootBottomSheet.dart';

class ComposeWootPage extends StatefulWidget {
  ComposeWootPage({Key key, this.isRewoot, this.isWoot = true})
      : super(key: key);

  final bool isRewoot;
  final bool isWoot;

  _ComposeWootReplyPageState createState() => _ComposeWootReplyPageState();
}

class _ComposeWootReplyPageState extends State<ComposeWootPage> {
  bool isScrollingDown = false;
  FeedModel model;
  ScrollController scrollcontroller;
  final translator = GoogleTranslator();
  File _image;
  File _video;
  File _thumbnail;
  PickedFile pfile;
  TextEditingController _textEditingController;
  String _translation = "";
  String _lastText = "";
  List<File> _recentImages = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Pool Ui
  bool isWootTypePool = false;
  final GlobalKey<FormBuilderState> _fbPoolFormKey =
      GlobalKey<FormBuilderState>();

  @override
  void dispose() {
    scrollcontroller.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.wootToReplyModel;
    print("------model: ${model}");

    scrollcontroller = ScrollController();
    _textEditingController = TextEditingController();
    scrollcontroller..addListener(_scrollListener);
    _textEditingController.addListener(() {
      if (_textEditingController.text.length != _lastText.length) {
        setState(() {
          _lastText = _textEditingController.text;
          _translation = "";
        });
      }
    });
    photoPermissionHandler();
    super.initState();
  }

  void photoPermissionHandler() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      final option = FilterOption(
        needTitle: true,
      );
      FilterOptionGroup _options = FilterOptionGroup()
        ..setOption(AssetType.video, option);
      List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
      List<AssetEntity> _iamges = list.length > 0
          ? await list?.first?.getAssetListRange(start: 0, end: 10)
          : List<AssetEntity>();
      _iamges.forEach((element) async {
        _recentImages.add(await element.file);
      });
      setState(() {});
    } else {}
  }

  Future<void> _textEditingTranslate(String code) async {
    try {
      if (_textEditingController.text.isEmpty) return;
      Translation _trans =
          await translator.translate(_textEditingController.text, to: code);
      setState(() {
        _translation = _trans.text;
      });
    } catch (e) {
      print("$e");
    }
  }

  _scrollListener() {
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        Provider.of<ComposeWootState>(context, listen: false)
            .setIsScrollingDown = true;
      }
    }
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.forward) {
      Provider.of<ComposeWootState>(context, listen: false).setIsScrollingDown =
          false;
    }
  }

  void _onCrossIconPressed() {
    setState(() {
      _image = null;
      isWootTypePool = false;
      _video = null;
    });
  }

  void setImage(ImageSource source) {
    ImagePicker()
        .getImage(source: source, imageQuality: 20)
        .then((PickedFile file) {
      setState(() {
        if (file != null) {
          _image = File(file.path);
        }
      });
    });
  }

  void setVideo() async {
    /* ImagePicker().getVideo(source: source)
        .then((PickedFile file) {
          pfile = file;
      setState(() {
        if (file != null) {
          _video = File(file.path);
        }
      });
    });*/

    // PhotoPicker.clearThumbMemoryCache();

    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    var x = result?.files.single.path ?? '-1';
    if (x != '-1') {
      _video = File(result.files.single.path);
      VideoThumbnail.thumbnailFile(video: _video.path).then((response) {
        _thumbnail = File(response);
      });
    } else
      _video = null;
    setState(() {});
  }

  void _onImageIconSelcted(File file) {
    setState(() {
      _image = file;
    });
  }

  /// Submit woot to save in firebase realtime database
  void _submitButton() async {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty ||
        _textEditingController.text.length > 280) {
      return;
    }
    if (isWootTypePool && !_fbPoolFormKey.currentState.saveAndValidate()) {
      return;
    }

    var state = Provider.of<FeedState>(context, listen: false);

    FeedModel wootModel = createWootModel();
    kScreenloader.showLoader(context);

    /// If woot contain image
    /// First image is uploaded on firebase storage
    /// After successfull image upload to firebase storage it returns image path
    /// Add this image path to woot model and save to firebase database
    if (_image != null) {
      /// firebase storage image upload....
      /*await state.uploadFile(_image).then((imagePath) {
        if (imagePath != null) {
          wootModel.imagePath = imagePath;

          /// If type of woot is new woot
          if (widget.isWoot) {
            state.createWoot(wootModel);
          }

          /// If type of woot is  rewoot
          else if (widget.isRewoot) {
            print('__creating reWoot__');
            state.createReWoot(wootModel);
          }

          /// If type of woot is new comment woot
          else {
            print('__creating  commentToWoot__');
            state.addcommentToPost(wootModel);
          }
        }
      });*/

      String imagePath = null;
      ParseFileBase parseFile = new ParseFile(File(_image.path));
      ParseObject parseObject = ParseObject('Images')
        ..set('imageFile', parseFile);

      print("getParsedFileObj = " + parseObject.toString());
      ParseResponse response = await parseObject.save();

      if (response.success) {
        var map = response.results.first;
        print(map);
        print(map['imageFile'].url);
        imagePath = response.results.first['imageFile'].url;
      }

      if (imagePath != null) {
        wootModel.imagePath = imagePath;

        /// If type of woot is new woot
        if (widget.isWoot) {
          print('__creating woot__');
          state.createWoot(wootModel);
        }

        /// If type of woot is  rewoot
        else if (widget.isRewoot) {
          print('__creating reWoot__');
          state.createReWoot(wootModel);
        }

        /// If type of woot is new comment woot
        else {
          print('__creating  commentToWoot__');
          state.addcommentToPost(wootModel);
        }
      }
    } else if (_video != null) {
      /// upload video to firebase storage....
      /*await state.uploadFile(_video).then((videoPath) async {
        if (videoPath != null) {
          /// If type of woot is new woot
          if (widget.isWoot) {
            FeedModel woot = postNewWoot();
            woot.video = videoPath;
            await state.createWoot(woot);
          }

          /// If type of woot is  rewoot
          else if (widget.isRewoot) {
            print('__creating reWoot__');
            state.createReWoot(wootModel);
          }

          /// If type of woot is new comment woot
          else {
            print('__creating  commentToWoot__');
            state.addcommentToPost(wootModel);
          }
        }
      });*/

      print('__creating video woot___');
      String videoPath;

      // String path = pfile.path;
      // int i = path.lastIndexOf('.');
      // path = path.substring(0,i);
      // path = path + '.mp4';
      // print(path);
      // path.replaceFirst('image_picker', 'video_picker');

      ParseFileBase parseFile = new ParseFile(_video);
      ParseObject parseObject = ParseObject('Videos')
        ..set('videoFile', parseFile);

      print("getParsedFileObj = " + parseObject.toString());
      ParseResponse response = await parseObject.save();

      if (response.success) {
        var map = response.results.first;
        print(map);
        print(map['videoFile'].url);
        videoPath = response.results.first['videoFile'].url;
      }

      if (videoPath != null) {
        /// If type of woot is new woot
        if (widget.isWoot) {
          FeedModel woot = postNewWoot();
          woot.video = videoPath;
          await state.createWoot(woot);
        }

        /// If type of woot is  rewoot
        else if (widget.isRewoot) {
          print('__creating reWoot__');
          state.createReWoot(wootModel);
        }

        /// If type of woot is new comment woot
        else {
          print('__creating  commentToWoot__');
          state.addcommentToPost(wootModel);
        }
      }
    }

    /// If woot did not contain image/video
    else {
      /// If type of woot is new woot
      if (widget.isWoot) {
        FeedModel woot = postNewWoot();
        if (isWootTypePool) {
          Map<dynamic, dynamic> _pool = {};
          _fbPoolFormKey.currentState.value.forEach((key, value) {
            if (value.toString().trim().length > 0) {
              _pool[value] = ['value'];
            }
          });
          woot.newPool = _pool;
        }
        state.createWoot(woot);

        final searchState = context.read<SearchState>().userlist;
        await SendFCM().newWootCreated(woot.user, searchState);
      }

      /// If type of woot is  rewoot
      else if (widget.isRewoot) {
        print('__creating reWoot__');
        state.createReWoot(wootModel);
      }

      /// If type of woot is new comment woot only text
      else {
        print('__creating  commentToWoot__');
        state.addcommentToPost(wootModel);
        var authState = Provider.of<AuthState>(context, listen: false);
        await SendFCM()
            .commentOnPost(wootModel, wootModel.user, authState.userModel);
      }
    }

    /// Checks for username in woot description
    /// If found sends notification to all tagged user
    /// If no user found or not compost woot screen is closed and redirect back to home page.
    await Provider.of<ComposeWootState>(context, listen: false)
        .sendNotification(
            wootModel, Provider.of<SearchState>(context, listen: false))
        .then((_) {
      /// Hide running loader on screen
      kScreenloader.hideLoader();

      /// Navigate back to home page
      Navigator.pop(context);
    });

    kScreenloader.hideLoader();
  }

  FeedModel postNewWoot() {
    var user = Provider.of<AuthState>(context, listen: false).userModel;
    user.contact = null;
    var tags = getHashTags(_textEditingController.text);
    FeedModel model = FeedModel(
      description: _translation.trim().length == 0
          ? _textEditingController.text
          : _translation,
      user: user,
      createdAt: DateTime.now().toUtc().toString(),
      tags: tags,
      parentkey: null,
      childRewootkey: null,
      userId: user.userId,
    );
    return model;
  }

  /// Return Woot model which is either a new Woot , rewoot model or comment model
  /// If woot is new woot then `parentkey` and `childRewoottkey` should be null
  /// IF woot is a comment then it should have `parentkey`
  /// IF woot is a rewoot then it should have `childRewootkey`
  FeedModel createWootModel() {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    var myUser = authState.userModel;
    var profilePic = myUser.profilePic ?? dummyProfilePic;
    var commentedUser = MyUser(
      displayName: myUser.displayName ?? myUser.email.split('@')[0],
      profilePic: profilePic,
      userId: myUser.userId,
      isVerified: authState.userModel.isVerified,
      userName: authState.userModel.userName,
      totalLikes: myUser.totalLikes ?? 0,
      totalDisLikes: myUser.totalDisLikes ?? 0,
      ratingPattern: myUser.ratingPattern,
    );
    var tags = getHashTags(_textEditingController.text);
    FeedModel reply = FeedModel(
        description: _translation.trim().length == 0
            ? _textEditingController.text
            : _translation,
        user: commentedUser,
        createdAt: DateTime.now().toUtc().toString(),
        tags: tags,
        parentkey: widget.isWoot
            ? null
            : widget.isRewoot
                ? null
                : state.wootToReplyModel.key,
        childRewootkey: widget.isWoot
            ? null
            : widget.isRewoot
                ? model.key
                : null,
        userId: myUser.userId,
        likeList: List<String>(),
        dislikeList: List<String>());

    // print('return wootModel');
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    // print('${widget.isRewoot} -- ${widget.isWoot}');

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: customTitleText(''),
        onActionPressed: _submitButton,
        isCrossButton: true,
        submitButtonText: widget.isWoot
            ? 'Woot'
            : widget.isRewoot
                ? 'Rewoot'
                : 'Reply',
        isSubmitDisable:
            !Provider.of<ComposeWootState>(context).enableSubmitButton ||
                Provider.of<FeedState>(context).isBusy,
        isbootomLine: Provider.of<ComposeWootState>(context).isScrollingDown,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollcontroller,
              child: widget.isRewoot
                  ? _ComposeRewoot(this)
                  : _ComposeWoot(this, _translation),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentImages.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return GestureDetector(
                            onTap: () => setImage(ImageSource.camera),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              width: 60,
                              child: Icon(
                                Icons.camera_alt,
                                color: TwitterColor.bondiBlue,
                              ),
                            ),
                          );
                        } else if (index == 1) {
                          return GestureDetector(
                            onTap: () => setVideo(),
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              width: 60,
                              child: Icon(
                                Icons.videocam,
                                color: TwitterColor.bondiBlue,
                              ),
                            ),
                          );
                        } else if (index == _recentImages.length + 1) {
                          return GestureDetector(
                            onTap: () => setImage(ImageSource.gallery),
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              width: 60,
                              child: Icon(
                                Icons.image,
                                color: TwitterColor.bondiBlue,
                              ),
                            ),
                          );
                        }
                        index = index - 2;
                        return GestureDetector(
                          onTap: () {
                            _onImageIconSelcted(_recentImages[index]);
                          },
                          child: Container(
                            width: 60,
                            margin: EdgeInsets.only(left: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                _recentImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  ComposeBottomIconWidget(
                    textEditingController: _textEditingController,
                    onImageIconSelcted: _onImageIconSelcted,
                    onTranslationTap: buildTranslationDialog,
                    onPoolIconTap: wootPoolSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void buildTranslationDialog() {
    showDialog(
      context: context,
      child: SimpleDialog(
        title: Text(
          "Language",
          textAlign: TextAlign.center,
        ),
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((e) {
              return ListTile(
                dense: true,
                title: Text("${e.language}"),
                onTap: () async {
                  await _textEditingTranslate(e.code);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void wootPoolSubmit() {
    setState(() {
      isWootTypePool = true;
    });
  }
}

class _ComposeRewoot
    extends WidgetView<ComposeWootPage, _ComposeWootReplyPageState> {
  _ComposeRewoot(this.viewState) : super(viewState);

  final _ComposeWootReplyPageState viewState;

  Widget _woot(BuildContext context, FeedModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // SizedBox(width: 10),

        SizedBox(width: 20),
        Container(
          width: fullWidth(context) - 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: 25,
                    height: 25,
                    child: customImage(context, model.user.profilePic),
                  ),
                  SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 0, maxWidth: fullWidth(context) * .5),
                    child: TitleText(model.user.displayName,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 3),
                  model.user.isVerified
                      ? customIcon(
                          context,
                          icon: AppIcon.blueTick,
                          istwitterIcon: true,
                          iconColor: AppColor.primary,
                          size: 13,
                          paddingIcon: 3,
                        )
                      : SizedBox(width: 0),
                  SizedBox(width: model.user.isVerified ? 5 : 0),
                  Flexible(
                    child: customText(
                      '${model.user.userName}',
                      style: userNameStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  customText('· ${getChatTime(model.createdAt)}',
                      style: userNameStyle),
                  Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
        UrlText(
          text: model.description,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          urlStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),
        ),
        model.imagePath != null
            ? WootImage(
                model: model,
                type: WootType.Image,
              )
            : Container(),
        model.video != null
            ? VideoThumbnailWidget(
                path: model.video,
                model: model,
                type: WootType.Reply,
              )
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Container(
      height: fullHeight(context),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child:
                    customImage(context, authState.user?.photoURL, height: 40),
              ),
              Expanded(
                child: _TextField(
                  isWoot: false,
                  isRewoot: true,
                  textEditingController: viewState._textEditingController,
                ),
              ),
              SizedBox(
                width: 16,
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 16, left: 80, bottom: 8),
            child: ComposeWootImage(
              image: viewState._image,
              onCrossIconPressed: viewState._onCrossIconPressed,
            ),
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 75, right: 16, bottom: 16),
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColor.extraLightGrey, width: .5),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: _woot(context, viewState.model),
                    ),
                  ],
                ),
                _UserList(
                  list: Provider.of<SearchState>(context).userlist,
                  textEditingController: viewState._textEditingController,
                )
              ],
            ),
          ),
          SizedBox(height: 50)
        ],
      ),
    );
  }
}

class _ComposeWoot
    extends WidgetView<ComposeWootPage, _ComposeWootReplyPageState> {
  _ComposeWoot(this.viewState, this.translation) : super(viewState);

  final _ComposeWootReplyPageState viewState;
  final String translation;

  Widget _tweerCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 30),
                margin: EdgeInsets.only(left: 20, top: 20, bottom: 3),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 2.0,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: fullWidth(context) - 72,
                      child: UrlText(
                        text: viewState.model?.description ?? '',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        urlStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    UrlText(
                      text:
                          'Replying to ${viewState.model?.user?.userName ?? viewState.model?.user?.displayName}',
                      style: TextStyle(
                        color: TwitterColor.paleSky,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  customImage(context, viewState.model.user.profilePic,
                      height: 40),
                  SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 0, maxWidth: fullWidth(context) * .5),
                    child: TitleText(viewState.model.user.displayName,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 3),
                  viewState.model.user.isVerified
                      ? customIcon(
                          context,
                          icon: AppIcon.blueTick,
                          istwitterIcon: true,
                          iconColor: AppColor.primary,
                          size: 13,
                          paddingIcon: 3,
                        )
                      : SizedBox(width: 0),
                  SizedBox(width: viewState.model.user.isVerified ? 5 : 0),
                  customText('${viewState.model.user.userName}',
                      style: userNameStyle.copyWith(fontSize: 15)),
                  SizedBox(width: 5),
                  Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: customText(
                        '- ${getChatTime(viewState.model.createdAt)}',
                        style: userNameStyle.copyWith(fontSize: 12)),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var feedState = Provider.of<FeedState>(context, listen: false);

    var authState = Provider.of<AuthState>(context, listen: false);
    return Container(
      height: fullHeight(context),
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          viewState.widget.isWoot ? SizedBox.shrink() : _tweerCard(context),
          viewState.widget.isWoot == false && viewState.widget.isRewoot == false
              ? Column(
                  children: List<Widget>.generate(
                      (viewState.model.replyWootKeyList.length), (index) {
                    FeedModel singleFeedModel = feedState.feedlist
                        .where((element) =>
                            element.key ==
                            viewState.model.replyWootKeyList[index])
                        .first;
                    return Woot(
                      model: singleFeedModel,
                      trailing: WootBottomSheet().wootOptionIcon(
                        context,
                        singleFeedModel,
                        WootType.Woot,
                      ),
                    );
                    return Container(
                      height: 50,
                      width: 50,
                      color: Colors.red,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Text("${singleFeedModel.description}"),
                    );
                  }),
                )
              : Container(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              customImage(context, authState.user?.photoURL, height: 40),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: _TextField(
                  isWoot: widget.isWoot,
                  textEditingController: viewState._textEditingController,
                ),
              )
            ],
          ),
          Stack(
            children: <Widget>[
              viewState.isWootTypePool
                  ? ComposeWootPool(
                      fbKey: viewState._fbPoolFormKey,
                      onCrossIconPressed: viewState._onCrossIconPressed,
                    )
                  : viewState._video != null
                      ? ComposeWootVideo(
                          video: viewState._video,
                          onCrossIconPressed: viewState._onCrossIconPressed,
                        )
                      : ComposeWootImage(
                          image: viewState._image,
                          onCrossIconPressed: viewState._onCrossIconPressed,
                        ),
              _UserList(
                list: Provider.of<SearchState>(context).userlist,
                textEditingController: viewState._textEditingController,
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(20),
            child: Text("$translation"),
          )
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  _TextField(
      {Key key,
      this.textEditingController,
      this.isWoot = false,
      this.isRewoot = false})
      : super(key: key);
  final TextEditingController textEditingController;
  final bool isWoot;
  final bool isRewoot;

  var translator = GoogleTranslator();

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: textEditingController,
          onChanged: (text) async {
            Provider.of<ComposeWootState>(context, listen: false)
                .onDescriptionChanged(text, searchState);
          },
          enableSuggestions: true,
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isWoot
                  ? 'What\'s happening?'
                  : isRewoot
                      ? 'Add a comment'
                      : 'Woot your reply',
              hintStyle: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({Key key, this.list, this.textEditingController})
      : super(key: key);
  final List<MyUser> list;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return !Provider.of<ComposeWootState>(context).displayUserList ||
            list == null ||
            list.length < 0 ||
            list.length == 0
        ? SizedBox.shrink()
        : Container(
            padding: EdgeInsetsDirectional.only(bottom: 50),
            color: TwitterColor.white,
            constraints:
                BoxConstraints(minHeight: 30, maxHeight: double.infinity),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return _UserTile(
                  user: list[index],
                  onUserSelected: (user) {
                    textEditingController.text =
                        Provider.of<ComposeWootState>(context)
                            .getDescription(user.userName);
                    textEditingController.selection = TextSelection.collapsed(
                        offset: textEditingController.text.length);
                    Provider.of<ComposeWootState>(context).onUserSelected();
                  },
                );
              },
            ),
          );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key key, this.user, this.onUserSelected}) : super(key: key);
  final MyUser user;
  final ValueChanged<MyUser> onUserSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onUserSelected(user);
      },
      leading: customImage(context, user.profilePic, height: 35),
      title: Row(
        children: <Widget>[
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: 0, maxWidth: fullWidth(context) * .5),
            child: TitleText(user.displayName,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 3),
          user.isVerified
              ? customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  istwitterIcon: true,
                  iconColor: AppColor.primary,
                  size: 13,
                  paddingIcon: 3,
                )
              : SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName),
    );
  }
}
