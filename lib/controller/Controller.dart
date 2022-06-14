import 'package:get/get.dart';

class AudioController extends GetxController {
  RxBool isPlay = false.obs;

  playControl() {
    isPlay.value = !isPlay.value;
    update();
  }
}
