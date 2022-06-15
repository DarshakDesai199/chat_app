import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/controller/Controller.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/service/const.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class ChatRoom extends StatefulWidget {
  final String? chatRoomId;
  final Map<String, dynamic>? userMap;

  const ChatRoom({this.chatRoomId, this.userMap});
  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final _message = TextEditingController();

  var _picker = ImagePicker();
  File? imageFile;
  File? videoFile;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
    getUserData();
    super.initState();
  }

  setStatus(String status) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(kFirebaseAuth.currentUser!.uid)
        .update({"status": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      setStatus("Offline");
      // offline
    }
    super.didChangeAppLifecycleState(state);
  }

  /// message
  void sendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> message = {
        "sendBy": kFirebaseAuth.currentUser?.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp()
      };
      _message.clear();

      await FirebaseFirestore.instance
          .collection("chatroom")
          .doc(widget.chatRoomId)
          .collection("chats")
          .add(message);
    } else {
      print("Enter a some message");
    }
  }

  /// upload image
  getImage() async {
    var result = await _picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      imageFile = File(result.path);
      uploadImageFile();
    }
  }

  Future uploadImageFile() async {
    String fileName = Uuid().v1();
    int status = 1;

    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": kFirebaseAuth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var upload = await FirebaseStorage.instance
        .ref()
        .child('image')
        .child("$fileName.jpg")
        .putFile(imageFile!)
        .catchError(
      (error) async {
        await FirebaseFirestore.instance
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(fileName)
            .delete();
        status = 0;
      },
    );

    if (status == 1) {
      String imageUrl = await upload.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  /// upload video
  getVideo() async {
    var result = await _picker.pickVideo(source: ImageSource.gallery);
    if (result != null) {
      videoFile = File(result.path);
      uploadVideoFile();
    }
  }

  Future uploadVideoFile() async {
    String fileName = Uuid().v1();
    int status = 1;

    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": kFirebaseAuth.currentUser!.displayName,
      "videoFile": "",
      "type": "video",
      "time": FieldValue.serverTimestamp(),
    });

    var upload = await FirebaseStorage.instance
        .ref()
        .child('video')
        .child("$fileName.jpg")
        .putFile(videoFile!)
        .catchError(
      (error) async {
        await FirebaseFirestore.instance
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(fileName)
            .delete();
        status = 0;
      },
    );

    if (status == 1) {
      String videoUrl = await upload.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"videoFile": videoUrl});

      print(videoUrl);
    }
  }

  /// upload mp3
  File? file;
  String? name;
  getAudio() async {
    var result = await FilePicker.platform
        .pickFiles(type: FileType.audio, allowMultiple: false);
    if (result != null) {
      File data = File(result.paths.single.toString());
      setState(() {
        file = data;
      });
      name = result.names.first.toString();

      uploadAudioFile();
    }
  }

  Future uploadAudioFile() async {
    String fileName = Uuid().v1();
    int status = 1;

    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": kFirebaseAuth.currentUser!.displayName,
      "audioFile": "",
      "type": "audio",
      "time": FieldValue.serverTimestamp(),
    });

    var upload = await FirebaseStorage.instance
        .ref()
        .child('audio')
        .child("$fileName.mp3")
        .putFile(file!)
        .catchError(
      (error) async {
        await FirebaseFirestore.instance
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(fileName)
            .delete();
        status = 0;
      },
    );

    if (status == 1) {
      String audioUrl = await upload.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"audioFile": audioUrl});

      print(audioUrl);
    }
  }

  /// upload pdf file
  getFile() async {
    var result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf', 'doc']);
    if (result != null) {
      File doc = File(result.files.single.path.toString());

      setState(() {
        file = doc;
      });
    }
    name = result?.names.first.toString();
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = Uuid().v1();
    int status = 1;

    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": kFirebaseAuth.currentUser!.displayName,
      "document": "",
      "type": "document",
      "time": FieldValue.serverTimestamp(),
    });

    var upload = await FirebaseStorage.instance
        .ref()
        .child('document')
        .child("$fileName.pdf")
        .putFile(file!)
        .catchError(
      (error) async {
        await FirebaseFirestore.instance
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(fileName)
            .delete();
        status = 0;
      },
    );

    if (status == 1) {
      String fileUrl = await upload.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"document": fileUrl});

      print(fileUrl);
    }
  }

  /// user image get on firebase
  String? img;
  void getUserData() async {
    final user = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userMap!['uid'])
        .get();
    Map<String, dynamic>? getUserData = user.data() as Map<String, dynamic>?;
    setState(
      () {
        img = getUserData!['userImage'];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            height: 2.h,
            width: 2.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                  img ??
                      "https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg",
                  fit: BoxFit.cover),
            ),
          ),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userMap!['uid'])
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.data != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.userMap!['username']}",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Text(
                    "${snapshot.data!['status']}",
                    style: TextStyle(fontSize: 9.sp),
                  )
                ],
              );
            } else {
              return Container();
            }
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                height: 80.h,
                width: 100.w,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("chatroom")
                      .doc(widget.chatRoomId)
                      .collection("chats")
                      .orderBy("time", descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return Scrollbar(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> map =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;

                            return messages(map, context);
                          },
                        ),
                      );
                    } else {
                      return Center(child: Container());
                    }
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _message,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: PopupMenuButton(
                            icon: RotatedBox(
                                quarterTurns: 1,
                                child: Icon(
                                  Icons.attach_file,
                                  color: Colors.white,
                                  size: 4.h,
                                )),
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  child: GestureDetector(
                                    onTap: () {
                                      print("====>>  Image Sent");

                                      getImage();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.photo,
                                          size: 2.h,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        Text("Image")
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: GestureDetector(
                                    onTap: () {
                                      print("====>>  Video Sent");
                                      getVideo();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.video_camera_back_outlined,
                                          size: 2.h,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        Text("Video")
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: GestureDetector(
                                    onTap: () {
                                      print("====>>  audio Sent");
                                      getAudio();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.audiotrack,
                                          size: 2.h,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        Text("Audio")
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: GestureDetector(
                                    onTap: () {
                                      print("====>>  document Sent");
                                      getFile();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.file_copy,
                                          size: 2.h,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),
                                        Text("Document")
                                      ],
                                    ),
                                  ),
                                )
                              ];
                            },
                          ),
                        ),
                        hintText: "Send Message",
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () {
                        print("====> Message Sent");
                        sendMessage();
                      },
                      icon: Icon(
                        color: Colors.white,
                        Icons.send,
                        size: 4.h,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget messages(
  Map<String, dynamic> map,
  BuildContext context,
) {
  // VideoPlayerController? videoPlayerController;
  VideoPlayerController? _controllerVideos;
  _controllerVideos = VideoPlayerController.network("${map['videoFile']}");

  final chewieController = ChewieController(
      videoPlayerController: _controllerVideos,
      fullScreenByDefault: true,
      autoPlay: false);

  final playerWidget = Chewie(controller: chewieController);
  AudioPlayer audioPlayer = AudioPlayer();
  AudioController audioController = Get.put(AudioController());

  return map['type'] == "text"
      ? Container(
          width: 100.w,
          alignment: map['sendBy'] == kFirebaseAuth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  // margin: map['sendBy'] == kFirebaseAuth.currentUser!.displayName
                  //     ? EdgeInsets.only(left: 30)
                  //     : EdgeInsets.only(right: 30),
                  padding: EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: map['sendBy'] ==
                              kFirebaseAuth.currentUser!.displayName
                          ? 24
                          : 10,
                      right: map['sendBy'] ==
                              kFirebaseAuth.currentUser!.displayName
                          ? 10
                          : 24),
                  decoration: BoxDecoration(
                    borderRadius:
                        map['sendBy'] == kFirebaseAuth.currentUser!.displayName
                            ? BorderRadius.only(
                                topLeft: Radius.circular(23),
                                topRight: Radius.circular(23),
                                bottomLeft: Radius.circular(23))
                            : BorderRadius.only(
                                topLeft: Radius.circular(23),
                                topRight: Radius.circular(23),
                                bottomRight: Radius.circular(23)),
                    color:
                        map['sendBy'] == kFirebaseAuth.currentUser!.displayName
                            ? Color(0xff004D40)
                            : Color(0xfffafafa),
                  ),
                  child: Text(
                    map['message'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: map['sendBy'] ==
                              kFirebaseAuth.currentUser!.displayName
                          ? Color(0xfffafafa)
                          : Color(0xff004D40),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      : map['type'] == "img"
          ? Container(
              height: 15.h,
              width: 100.w,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              alignment: map['sendBy'] == kFirebaseAuth.currentUser!.displayName
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShowImage(
                      imageUrl: map['message'],
                    ),
                  ),
                ),
                child: Container(
                  height: 30.h,
                  width: 50.w,
                  decoration: BoxDecoration(border: Border.all()),
                  alignment: map['img'] != "" ? null : Alignment.center,
                  child: map['img'] != ""
                      ? Image.network(
                          "${map['message']}",
                          fit: BoxFit.cover,
                        )
                      : CircularProgressIndicator(
                          backgroundColor: Colors.white),
                ),
              ),
            )
          : map['type'] == "videoFile"
              ? Container(
                  height: 15.h,
                  width: 100.w,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  alignment:
                      map['sendBy'] == kFirebaseAuth.currentUser!.displayName
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    height: 30.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2)),
                    alignment: map['videoFile'] != "" ? null : Alignment.center,
                    child: map['videoFile'] != ""
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: playerWidget,
                          )
                        : CircularProgressIndicator(),
                  ),
                )
              : map['type'] == "audioFile"
                  ? Container(
                      height: 7.h,
                      width: 65.w,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      alignment: map['sendBy'] ==
                              kFirebaseAuth.currentUser!.displayName
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        height: 10.h,
                        width: 30.w,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.h),
                            border: Border.all(color: Colors.white, width: 2)),
                        alignment:
                            map['audioFile'] != "" ? null : Alignment.center,
                        child: map['audioFile'] != ""
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Obx(
                                      () {
                                        return IconButton(
                                          onPressed: () async {
                                            audioController.playControl();
                                            if (audioController.isPlay.value ==
                                                true) {
                                              await audioPlayer
                                                  .play(map['audioFile']);
                                            } else {
                                              audioPlayer.pause();
                                            }
                                          },
                                          icon: audioController.isPlay.value ==
                                                  true
                                              ? Icon(Icons.pause)
                                              : Icon(Icons.play_arrow),
                                        );
                                      },
                                    ),
                                    Text("Audio")
                                  ],
                                ),
                              )
                            : CircularProgressIndicator(),
                      ),
                    )
                  : Container(
                      height: 15.h,
                      width: 100.w,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      alignment: map['sendBy'] ==
                              kFirebaseAuth.currentUser!.displayName
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        height: 15.h,
                        width: 100.w,
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        alignment: map['sendBy'] ==
                                kFirebaseAuth.currentUser!.displayName
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PDFViewerFromUrl(url: map['document']),
                            ),
                          ),
                          child: map['document'] != ""
                              ? Container(
                                  height: 11.h,
                                  width: 25.w,
                                  decoration: BoxDecoration(
                                      border: Border.all(), color: Colors.red),
                                  alignment: map['document'] != ""
                                      ? null
                                      : Alignment.center,
                                  child: Center(
                                    child: Text(
                                      "Document",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.sp),
                                    ),
                                  ),
                                )
                              : CircularProgressIndicator(
                                  backgroundColor: Colors.white),
                        ),
                      ),
                    );
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        height: 100.h,
        width: 100.w,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}

class PDFViewerFromUrl extends StatelessWidget {
  const PDFViewerFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(backgroundColor: comColor, automaticallyImplyLeading: true),
      body: const PDF().fromUrl(
        url,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}

// class ShowVideo extends StatelessWidget {
//   final String imageUrl;
//
//   const ShowVideo({required this.imageUrl, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios),
//             onPressed: () {
//               Navigator.pop(context);
//             }),
//       ),
//       body: Container(
//         height: 100.h,
//         width: 100.w,
//         color: Colors.black,
//         child: Image.network(imageUrl),
//       ),
//     );
//   }
// }
