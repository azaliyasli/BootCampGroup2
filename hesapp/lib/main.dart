import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hesapp/screens/user_login_screen.dart';
import 'package:hesapp/screens/bist_screen.dart';
import 'package:hesapp/firebase_options.dart';
import 'package:hesapp/screens/wallet_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  //Flutter uygulamasının başlatılmadan önce gerekli ayarların ve işlemlerin
  // yapılmasını sağlar. Bu, özellikle platform kanalları kullanılarak yapılan
  // işlemler veya Firebase gibi dış bağımlılıkların başlatılması gerektiğinde önemlidir.
  WidgetsFlutterBinding.ensureInitialized();

  /*
  Firebase'in uygulamanızda kullanılabilmesi için gerekli başlatma işlemlerini
  yapar. Bu işlem, Firebase hizmetlerinin (örneğin, Authentication, Firestore,
  Realtime Database) kullanılabilmesi için gereklidir.
   */
  await Firebase.initializeApp(
    /*
    Bu, Firebase projesinin yapılandırma seçeneklerini belirtir.
    DefaultFirebaseOptions.currentPlatform, Firebase projenizin platforma
    özgü ayarlarını içerir ve genellikle firebase_options.dart dosyasında tanımlanır.
     */
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ChangeNotifierProvider(
    create: (context) => WalletProvider(),
    child: const MyWidget(),
  ),);
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //StreamBuilder, bir Stream'i dinler ve bu Stream'den gelen veriye göre kullanıcı arayüzünü günceller.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          //Bu if ifadesi, Stream'in şu anda veri sağladığını kontrol eder.
          // ConnectionState.active durumu, Stream'in veri sağladığını ve dinlenmeye devam ettiğini gösterir.
          if (snapshot.connectionState == ConnectionState.active) {
            //Bu kod parçasında, snapshot.data oturum açma durumunu kontrol etmek için kullanılır
            if (snapshot.data == null || !snapshot.data!.emailVerified) {
              return const UserLoginScreen();
            } else {
              return const StockList();
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}