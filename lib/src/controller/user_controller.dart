import 'package:flutter/material.dart';
import 'package:flutter_getx_palette_diary/src/app.dart';
import 'package:flutter_getx_palette_diary/src/binding/init_binding.dart';
import 'package:flutter_getx_palette_diary/src/model/user.dart';
import 'package:flutter_getx_palette_diary/src/repository/user_repository.dart';
import 'package:flutter_getx_palette_diary/src/view/login_page.dart';
import 'package:flutter_getx_palette_diary/src/view/signup_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  final Rxn<User> _users = Rxn<User>();

  var profileImagePath = ''.obs;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _id = TextEditingController();
  final TextEditingController _signupId = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _signupPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final UserRepository repository;
  UserController({
    required this.repository,
  });

  TextEditingController get name => _name;
  TextEditingController get id => _id;
  TextEditingController get signupId => _signupId;
  TextEditingController get password => _password;
  TextEditingController get signupPassword => _signupPassword;
  TextEditingController get confirmPassword => _confirmPassword;

  void fetchData() {
    final user = {
      'id': id.text.toString(),
      'password': password.text.toString(),
    };

    repository.loginApi(user).then((user) {
      if (user != null) {
        _users.value = user;
        moveToApp();
      } else {
        Get.snackbar(
          "로그인 실패",
          "아이디 또는 비밀번호가 틀렸습니다.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  void putData() {
    final user = {
      'id': _id.value.text,
      'password': _password.value.text.toString()
    };
    repository.putUsers(user);
  }

  void signupFetchData() {
    final user = {
      'id': signupId.text.toString(),
      'name': name.text.toString(),
      'password': signupPassword.text.toString(),
    };

    repository.signupApi(user).then((user) {
      _users.value = user;
      moveToLogin();
    });
  }

  void signupPutData() {
    final signup = {
      'id': _signupId.value.text,
      'name': _name.value.text,
      'password': _signupPassword.value.text.toString(),
    };
    repository.putSignups(signup);
  }

  Future<User?> myinfoFetchData() async {
    try {
      // repository.myinfoApi()가 Future<User?>를 반환하므로 await을 사용하여 비동기 호출
      repository.myinfoApi().then((user) async {
        await GetStorage().write('name', user?.name);
        await GetStorage().write('id', user?.id);

        _users.value = user;

        print(user);

        if (user != null) {
          print("user : $user");
          _users.value = user;
          String? id = user.id ?? '';
          String? name = user.name ?? '';

          _id.text = user.id ?? '';
          _name.text = user.name ?? '';

          return user;
        } else {
          // 예외 처리: user가 null인 경우
          print('User 정보를 가져오는 데 문제가 발생했습니다.');
          return null;
        }
      });
    } catch (e) {
      // Dio 오류 또는 다른 예외 처리
      print('User 정보를 가져오는 도중 오류가 발생했습니다: $e');
      return null;
    }
  }

  void myinfoPutData() {
    final myinfo = {
      'id': _id.value.text,
      'name': _name.value.text,
    };
    repository.putMyinfos(myinfo);
  }

  void logoutfetchData() {
    repository.logoutApi();
  }

  void logoutputData() {
    final user = {
      'id': _id.value.text,
      'password': _password.value.text.toString()
    };
    repository.putUsers(user);
  }

// 화면 크기별 위젯 능동적 조정
  late double screenWidth = 0.0;
  late double screenHeight = 0.0;

  void initScreenWidth(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

// SignUp view 이동
  void moveToRegister() {
    Get.to(() => SignUpPage(), binding: InitBinding());
  }

  // Login view 이동
  void moveToLogin() {
    Get.to(() => LoginPage(), binding: InitBinding());
  }

// App.dart 화면으로 이동
  void moveToApp() {
    Get.to(() => const App(), binding: InitBinding());
  }

  String? readName() {
    return GetStorage().read('name');
  }

  String? readId() {
    return GetStorage().read('id');
  }

  bool get isProfileImageSet => profileImagePath.value.isNotEmpty;
}
