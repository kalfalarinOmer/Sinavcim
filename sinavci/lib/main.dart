import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/GirisPage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main()  async{
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  Reklam.initialization();
  await Firebase.initializeApp();
  runApp(AtaWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: '**SINAVCIM: Çevrim içi sınavını hazırla, paylaş veya paylaşılanı çöz ;)**',

      theme: ThemeData(
        primarySwatch: Colors.purple,
        backgroundColor: Colors.white,
      ),
      home: MyHomePage(),
    );
  }
}
class MyHomePage extends StatefulWidget {

  @override
  MyHomePageState createState() => MyHomePageState();
}
class MyHomePageState extends State<MyHomePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.login, color: Colors.amberAccent,),
            backgroundColor: Colors.blue,
            title: Text("Sınavcım ", style: TextStyle(color: Colors.amberAccent, fontFamily: "Rhodium Libre",  fontSize: 40,
            ),),
            bottom: TabBar(
                tabs: [
                  Tab(
                      child: AtaWidget.of(context).kullaniciadi == null ? Text("Hoşgeldiniz",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))
                          : Text("Hoşgeldiniz "+ AtaWidget.of(context).kullaniciadi,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))
                  )
                ]),
            actions: [
              IconButton(icon: Icon(Icons.campaign, color: Colors.white,), iconSize: 30,
                onPressed: (){
                  AlertDialog alertDialog = new AlertDialog(
                    content: Container( height: 100,
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Center(
                              child: Text("* E-Mail ile ilk girişte kaydolmanız gerekmektedir. Daha sonraki girişlerinizi kullanıcı adı, mail adresi "
                                  "ve şifreniz ile yapabilirsiniz.",
                                style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600), textAlign: TextAlign.justify,),
                            ),
                            Visibility(visible: false, child: SizedBox(height: 10,)),
                            Visibility( visible: false,
                              child: Center(
                                child: Text("* Telefon ile giriş yapabilmek için önce E-mail adresiniz ile uygulamaya kaydolmanız, ardından profilinizden sisteme telefon "
                                    "numaranızı kaydetmeniz gerekir. *Telefon ile Giriş Yap* butonuna tıkladığınızda gelen pencereye E-mail adresinizi yazarak uygulamaya "
                                    "giriş yapabilirsiniz. Bu işlem için erişim izni istenebilir.",
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600), textAlign: TextAlign.justify,),
                              ),
                            ),
                            Visibility( visible: false, child: SizedBox(height: 10,)),
                            Visibility( visible: false,
                              child: Center(
                                child: Text("* Google ile Giriş yapabilmek için önce Google hesap adresiniz ile uygulamaya kaydolmanız gerekmektedir. Ardından "
                                    "*Google ile giriş yap* butonunu kullanarak tek tıkla uygulamaya giriş yapabilirsiniz. İlk işlem için erişim izni istenebilir.",
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600), textAlign: TextAlign.justify,),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      FittedBox(
                        child: Container( height: 30, width: 120,
                          child: FloatingActionButton.extended( backgroundColor: Colors.green,
                              label: Text("DetayaGit",style: TextStyle(fontWeight: FontWeight.bold),),
                              icon: Icon(Icons.info, size: 25, color: Colors.white,),
                              onPressed: (){
                                AlertDialog alertDialog = new AlertDialog(
                                  title: Row(
                                    children: <Widget>[
                                      Icon(Icons.copyright, color: Colors.green, size: 30,),
                                      SizedBox(width: 10,),
                                      Text("ÖMER KALFA", style: TextStyle(color: Colors.green,),),
                                    ],
                                  ),
                                  content: Text("Bu uygulama Burdur/Tefenni Anadolu İmam Hatip Lisesi Matematik Öğretmeni Ömer KALFA tarafından geliştirilmiştir.  "
                                      "Daha fazla bilgiye *Uygulama Detayına Git* butonundan ulaşabilirsiniz", textAlign: TextAlign.justify,),
                                  actions: [
                                    Text("iletişim: omerkalfa1@gmail.com", style: TextStyle(color: Colors.blueGrey, fontSize: 13),),
                                    Text("Tüm hakları saklıdır.   2021", style: TextStyle(color: Colors.red,),
                                      textAlign: TextAlign.end,),
                                    RaisedButton(
                                        color: Colors.amber,
                                        child: Text("Uygulama Detayına Git",
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        onPressed: (){
                                          Navigator.of(context,rootNavigator: true).pop("dialog");
                                          _launchIt("https://docs.google.com/document/d/1hyL44yYkqo_I5CipDKkavDCTdL9Yst_6"
                                              "/edit?usp=sharing&ouid=100033989399631384240&rtpof=true&sd=true");
                                        })
                                  ],
                                );
                                showDialog(context: context, builder: (_) => alertDialog);
                              }),
                        ),
                      )
                    ],
                  );showDialog(context: context, builder: (_) => alertDialog);
                },),
              Builder(
                builder: (context)=>IconButton(
                    tooltip: "Çıkış Yap",
                    icon: Icon(Icons.logout), onPressed: ()async{
                  await _auth.signOut();
                  AtaWidget.of(context).kullaniciadi = " ";
                  AtaWidget.of(context).kullanicimail = " ";

//              setState(() {});
                  if (await GoogleSignIn().isSignedIn()) {
                    await GoogleSignIn().disconnect();
                    await GoogleSignIn().signOut();
                  }
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Başarıyla çıkış yapıldı"),
                  ));
                }),
              ),
            ],
            elevation: 10,
          ),
          body: GirisPage(),
//      bottomNavigationBar: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),),

        ),
        length: 1,
      ),

    );
  }

  void _launchIt(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      AlertDialog alertDialog = new AlertDialog (
        title: Text("Hata: Sayfa Görüntülenemiyor.", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
        content: Text("İnternet bağlantınız kesilmiş yada sayfanın linki hatalı girilmiş olabilir."
          , style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,),
      ); showDialog(context: context, builder: (_) => alertDialog);
    }
  }

}
