import 'package:get_server/get_server.dart';

// default method is Method.get
// name is the path of url
void main() {
  runApp(GetServer(
    getPages: [
      GetPage(name: '/', page:()=> Home()),
    ],
  ));
}

class Home extends GetView {
  @override
  Widget build(BuildContext context) {
    return Text('Welcome to GetX');
  }
}