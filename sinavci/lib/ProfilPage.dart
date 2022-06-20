import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class ProfilPage extends StatefulWidget {
  final doc_id; final gelen_kisi_grubu;
  const ProfilPage({Key key, this.doc_id, this.gelen_kisi_grubu }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProfilPageState(this.doc_id, this.gelen_kisi_grubu);
  }

}

class ProfilPageState extends State{
  final doc_id; final gelen_kisi_grubu;
  ProfilPageState(this.doc_id, this.gelen_kisi_grubu);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File _imageSelected; String gizlilik;
  bool avatar_gizlilik_kontrol; bool mail_gizlilik_kontrol; bool tel_gizlilik_kontrol; bool adres_gizlilik_kontrol;
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List <dynamic> tum_kisiler = [];

  bool avatardan = false; bool telden = false; bool meslekten = false; bool gorevYeriden = false; bool hakkindadan = false; bool sosyaldan = false;

  Reklam _reklam = new Reklam();
  @override

  void initState() {
    _reklam.createInterad();
    super.initState();
  }
  Widget build(BuildContext context) {

    return Scaffold( key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: Icon(Icons.account_circle, ),
        title: Text("Hesabım", style: TextStyle( fontFamily: "Cormorant Garamond", fontSize: 35, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
        actions: [
          IconButton(icon: Icon(Icons.campaign,), onPressed: () {
            AlertDialog alertDialog = new AlertDialog(
              title: Text("BİLGİLENDİRME"),
              content: Container( height: 400,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MaterialButton(child: Text("Profil Sayfası asistan video için Tıklayın.", style: TextStyle(color: Colors.green),
                        textAlign: TextAlign.center,),
                        onPressed: (){
                          _launchIt("https://drive.google.com/file/d/1QLBAYop4muYozhsUB5GgImx45smwXKuN/view?usp=sharing");
                        },),
                      SizedBox(height: 10,),
                      Center(
                        child: Text("* Bu sayfada profil bilgileriniz görüntülenmektedir. Profil resminiz ve *Hakkında* alanına tıklayarak daha büyük görebilirsiniz. "
                            "Kullanıcı adı ve E-mial adresiniz haricindeki tüm alanlara uzun basarak alanı güncelleyebilirsiniz. Kişileriniz kullanıcı adı ve mail"
                            " adresinizi kullanarak sizi listelerine eklemiş olabilecekleri için bu alanlar değiştirilemez.",
                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                      ),
                      SizedBox(height: 10,),
                      Center(
                        child: Text("* Profilinizdeki her bilgiyi tüm kişileriniz ile paylaşmak istemeyebilirsiniz. Avatar resminiz de dahil olmak üzere kullanıcıadı ve"
                            " mail adresiniz haricindeki tüm bilgilerin kime gösterildiğini kontrol edebilir, gizlilğini değiştirebilirsiniz. Alanlarınızın gizliliğini tüm "
                            "kişilerinize yada seçtiğiniz kişi gruplarınıza açmayı tercih edebilirsiniz. Kullanıcı adınız ve E-mail adresiniz ile kişilerinizin listelerine "
                            "eklenmiş olabileceğiniz için bu alanların gizliliği kapatılamaz.",
                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                      ),
                      SizedBox(height: 10,),
                    ],
                  ),
                ),
              ),
            );showDialog(context: context, builder: (_) => alertDialog);
          },),
          Builder(
            builder: (context) => IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await _auth.signOut();
                  AtaWidget.of(context).kullaniciadi = " ";
                  AtaWidget.of(context).kullanicimail = " ";

//                  setState(() {});
                  if (await GoogleSignIn().isSignedIn()) {
                    await GoogleSignIn().disconnect();
                    await GoogleSignIn().signOut();
                  }
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Başarıyla çıkış yapıldı"),));
                }),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").doc(doc_id).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if(snapshot.hasError){ return Center(child: Text("Hata: Bilgilere ulaşılamadı", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),);}
          if(snapshot.connectionState == ConnectionState.waiting){ return Center( child: CircularProgressIndicator());}
          if(snapshot.data == null){return Center( child: CircularProgressIndicator());}

          DocumentSnapshot documentSnapshot = snapshot.data;

          String doc_avatar = documentSnapshot.get("avatar").toString();
          List <dynamic> doc_avatar_gizlilik = documentSnapshot.get("avatar_gizlilik");
          String doc_cevap = documentSnapshot.get("cevap").toString();
          String doc_gorevYeri = documentSnapshot.get("gorevYeri").toString();
          List <dynamic> doc_gorevYeri_gizlilik = documentSnapshot.get("gorevYeri_gizlilik");
          String doc_hakkinda = documentSnapshot.get("hakkinda").toString();
          List <dynamic> doc_hakkinda_gizlilik = documentSnapshot.get("hakkinda_gizlilik");
          String doc_kullaniciadi = documentSnapshot.get("kullaniciadi").toString();
          String doc_mail = documentSnapshot.get("mail").toString();
          String doc_meslek = documentSnapshot.get("meslek").toString();
          List <dynamic> doc_meslek_gizlilik = documentSnapshot.get("meslek_gizlilik");
          String doc_sifre = documentSnapshot.get("sifre").toString();
          String doc_soru = documentSnapshot.get("soru").toString();
          String doc_sosyal_facebook = documentSnapshot.get("sosyal_facebook").toString();
          String doc_sosyal_instagram = documentSnapshot.get("sosyal_instagram").toString();
          String doc_sosyal_twitter = documentSnapshot.get("sosyal_twitter").toString();
          List <dynamic> doc_sosyal_gizlilik = documentSnapshot.get("sosyal_gizlilik");
          String doc_tel = documentSnapshot.get("tel").toString();
          List <dynamic> doc_tel_gizlilik = documentSnapshot.get("tel_gizlilik");

          return Center(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container( color: Colors.lightBlue.shade100,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10,),
                              GestureDetector(
                                onLongPress: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor..."),
                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                  imageFromGallery();
                                },
                                onTap: (){
                                  _reklam.showInterad();

                                  Widget SetUpAlertDialogContainer() {
                                    return Container(height: 300, width: 300,
                                      child: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_avatar_gizlilik.contains("Tüm Kişilerim")
                                          || doc_avatar_gizlilik.contains(gelen_kisi_grubu) ?
                                      Image.network(doc_avatar,
                                        fit: BoxFit.cover, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                          return Center(
                                            child: Text("Avatar resmi bulunamadı", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),),
                                          );
                                        },
                                      ) :  Text("Avatar gizlenmiştir.", textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                    );
                                  }showDialog(context: context, builder: (_) {
                                    return AlertDialog( backgroundColor: Colors.lightBlue.shade100,
                                      title: Text(doc_kullaniciadi),
                                      content: SetUpAlertDialogContainer(),
                                    );
                                  });
                                },
                                child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align( alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: CircleAvatar( radius: 100, backgroundColor: Colors.white,
                                          child: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_avatar_gizlilik.contains("Tüm Kişilerim")
                                             || doc_avatar_gizlilik.contains(gelen_kisi_grubu) ?
                                          ClipOval(
                                              child: Image.network(documentSnapshot.get("avatar").toString(), fit: BoxFit.cover, width: 200, height: 200,
                                                errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                  return Center(child: Text("Avatar resmi bulunamadı", textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),),
                                                  );
                                                },
                                              )
                                          ): Text("Avatar gizlenmiştir.", textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only( right: 50.0),
                                      child: Wrap( direction: Axis.vertical,
                                          children: [
                                            Text("kullanıcı adı: ", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                                            SizedBox(height: 20,),
                                            Container( width: 120,
                                              child: Text(doc_kullaniciadi, style: TextStyle(color: Colors.indigo, fontSize: 18, fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic),),
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10,),
                              Visibility( visible: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi ? true : false,
                                child: Align(alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: MaterialButton(
                                        child: Text("Avatarınızın gizliliğini görmek için buraya Tıklayınız", style: TextStyle(fontSize: 12, color: Colors.blueGrey ), ),
                                        onPressed: () async {
                                          AlertDialog alertDialog = new AlertDialog(
                                            title: Text("Avatarınız aşağıdaki gruplara gösterilmektedir: "),
                                            content: Text(doc_avatar_gizlilik.toString(), style: TextStyle(color: Colors.green,)),
                                            actions: [
                                              ElevatedButton(
                                                child: Text("Gizliliği Değiştir"),
                                                onPressed: (){
                                                  Navigator.of(context, rootNavigator: true).pop("dialog");
                                                  avatardan = true;
                                                  telden = false;
                                                  meslekten = false;
                                                  gorevYeriden = false;
                                                  hakkindadan = false;
                                                  sosyaldan = false;

//                                                  setState(() {});
                                                  _gizliligiDegistir(doc_avatar_gizlilik);
                                                },
                                              ),
                                            ],
                                          ); showDialog(context: context, builder: (_) => alertDialog);
                                        },
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: Icon(Icons.radio_button_checked, color: Colors.green,),
                          title: Text("E-mail:", style: TextStyle(color: Colors.black, fontSize: 17, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(doc_mail, style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
                          child: Divider(height: 2, color: Colors.blueGrey, thickness: 2,),),

                        Builder(builder: (context) => ListTile(
                          leading: Icon(Icons.radio_button_checked, color: Colors.green,),
                          title: Text("Telefon:", style: TextStyle(color: Colors.black, fontSize: 17, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Wrap(direction: Axis.vertical ,children: [
                            Text( AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_tel_gizlilik.contains("Tüm Kişilerim")
                                || doc_tel_gizlilik.contains(gelen_kisi_grubu) ? doc_tel
                                : "Alan gizlenmiştir.",
                              style: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_tel_gizlilik.contains("Tüm Kişilerim")
                                  || doc_tel_gizlilik.contains(gelen_kisi_grubu) ?
                              TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)
                                  : TextStyle(fontSize: 15, color: Colors.red, fontStyle: FontStyle.italic)),
                            Visibility(visible: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi ? true : false,
                                child: MaterialButton(
                                  child: Text("Alanın gizliliğini görmek için buraya Tıklayınız", style: TextStyle(fontSize: 12, color: Colors.blueGrey ), ),
                                  onPressed: () async {
                                    AlertDialog alertDialog = new AlertDialog(
                                      title: Text("Telefon numaranız aşağıdaki gruplara gösterilmektedir: "),
                                      content: Text(doc_tel_gizlilik.toString(), style: TextStyle(color: Colors.green,)),
                                      actions: [
                                        ElevatedButton(
                                          child: Text("Gizliliği Değiştir"),
                                          onPressed: (){
                                            Navigator.of(context, rootNavigator: true).pop("dialog");
                                            avatardan = false;
                                            telden = true;
                                            meslekten = false;
                                            gorevYeriden = false;
                                            hakkindadan = false;
                                            sosyaldan = false;

//                                            setState(() {});
                                            _gizliligiDegistir(doc_tel_gizlilik);
                                          },
                                        ),
                                      ],
                                    ); showDialog(context: context, builder: (_) => alertDialog);
                                  },
                                ),),
                          ],),
                          onLongPress: () async {
                            telden = true;
                            meslekten = false;
                            gorevYeriden = false;
                            hakkindadan = false;
                            sosyaldan = false;

//                            setState(() {});
                            bilgileriGuncelle();
                          },
                        ),),
                        Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 8),
                          child: Divider(height: 2, color: Colors.blueGrey, thickness: 2,),),

                        Builder(builder: (context) => ListTile(
                          leading: Icon(Icons.radio_button_checked, color: Colors.green,),
                          title: Text("Meslek:", style: TextStyle(color: Colors.black, fontSize: 17, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Wrap(direction: Axis.vertical ,children: [
                            Text(AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_meslek_gizlilik.contains("Tüm Kişilerim")
                                || doc_meslek_gizlilik.contains(gelen_kisi_grubu) ? doc_meslek
                                : "Alan gizlenmiştir.",
                                style: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_meslek_gizlilik.contains("Tüm Kişilerim")
                                    || doc_meslek_gizlilik.contains(gelen_kisi_grubu) ?
                                TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)
                                    : TextStyle(fontSize: 15, color: Colors.red, fontStyle: FontStyle.italic)),
                            Visibility(visible: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi ? true : false,
                              child: MaterialButton(
                                child: Text("Alanın gizliliğini görmek için buraya Tıklayınız", style: TextStyle(fontSize: 12, color: Colors.blueGrey ), ),
                                onPressed: () async {
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Mesleğiniz aşağıdaki gruplara gösterilmektedir: "),
                                    content: Text(doc_meslek_gizlilik.toString(), style: TextStyle(color: Colors.green,)),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Gizliliği Değiştir"),
                                        onPressed: (){
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          avatardan = false;
                                          telden = false;
                                          meslekten = true;
                                          gorevYeriden = false;
                                          hakkindadan = false;
                                          sosyaldan = false;

//                                          setState(() {});
                                          _gizliligiDegistir(doc_meslek_gizlilik);
                                        },
                                      ),
                                    ],
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                },
                              ),),
                          ],),
                          onLongPress: () async {
                            telden = false;
                            meslekten = true;
                            gorevYeriden = false;
                            hakkindadan = false;
                            sosyaldan = false;

//                            setState(() {});
                            bilgileriGuncelle();
                          },
                        ),),
                        Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 8),
                          child: Divider(height: 2, color: Colors.blueGrey, thickness: 2,),),

                        Builder(builder: (context) => ListTile(
                          leading: Icon(Icons.radio_button_checked, color: Colors.green,),
                          title: Text("Görev Yeri:", style: TextStyle(color: Colors.black, fontSize: 17, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Wrap(direction: Axis.vertical ,children: [
                            Text(AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_gorevYeri_gizlilik.contains("Tüm Kişilerim")
                                || doc_gorevYeri_gizlilik.contains(gelen_kisi_grubu) ? doc_gorevYeri
                                : "Alan gizlenmiştir.",
                                style: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_gorevYeri_gizlilik.contains("Tüm Kişilerim")
                                    || doc_gorevYeri_gizlilik.contains(gelen_kisi_grubu) ?
                                TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)
                                    : TextStyle(fontSize: 15, color: Colors.red, fontStyle: FontStyle.italic)),
                            Visibility(visible: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi ? true : false,
                              child: MaterialButton(
                                child: Text("Alanın gizliliğini görmek için buraya Tıklayınız", style: TextStyle(fontSize: 12, color: Colors.blueGrey ), ),
                                onPressed: () async {
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Görev Yeriniz aşağıdaki gruplara gösterilmektedir: "),
                                    content: Text(doc_gorevYeri_gizlilik.toString(), style: TextStyle(color: Colors.green,)),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Gizliliği Değiştir"),
                                        onPressed: (){
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          avatardan = false;
                                          telden = false;
                                          meslekten = false;
                                          gorevYeriden = true;
                                          hakkindadan = false;
                                          sosyaldan = false;

//                                          setState(() {});
                                          _gizliligiDegistir(doc_gorevYeri_gizlilik);
                                        },
                                      ),
                                    ],
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                },
                              ),),
                          ],),
                          onLongPress: () async {
                            telden = false;
                            meslekten = false;
                            gorevYeriden = true;
                            hakkindadan = false;
                            sosyaldan = false;

//                            setState(() {});
                            bilgileriGuncelle();
                          },
                        ),),
                        Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 8),
                          child: Divider(height: 2, color: Colors.blueGrey, thickness: 2,),),

                        Builder(builder: (context) => ListTile(
                          leading: Icon(Icons.radio_button_checked, color: Colors.green,),
                          title: Text("Hakkında:", style: TextStyle(color: Colors.black, fontSize: 17, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Wrap(direction: Axis.vertical ,children: [
                            Text(AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_hakkinda_gizlilik.contains("Tüm Kişilerim")
                                || doc_hakkinda_gizlilik.contains(gelen_kisi_grubu) ? doc_hakkinda
                                : "Alan gizlenmiştir.",
                                style: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_hakkinda_gizlilik.contains("Tüm Kişilerim")
                                    || doc_hakkinda_gizlilik.contains(gelen_kisi_grubu) ?
                                TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)
                                    : TextStyle(fontSize: 15, color: Colors.red, fontStyle: FontStyle.italic)),
                            Visibility(visible: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi ? true : false,
                              child: MaterialButton(
                                child: Text("Alanın gizliliğini görmek için buraya Tıklayınız", style: TextStyle(fontSize: 12, color: Colors.blueGrey ), ),
                                onPressed: () async {
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Hakkında aşağıdaki gruplara gösterilmektedir: "),
                                    content: Text(doc_hakkinda_gizlilik.toString(), style: TextStyle(color: Colors.green,)),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Gizliliği Değiştir"),
                                        onPressed: (){
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          avatardan = false;
                                          telden = false;
                                          meslekten = false;
                                          gorevYeriden = false;
                                          hakkindadan = true;
                                          sosyaldan = false;

//                                          setState(() {});
                                          _gizliligiDegistir(doc_hakkinda_gizlilik);
                                        },
                                      ),
                                    ],
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                },
                              ),),
                          ],),
                          onLongPress: () async {
                            telden = false;
                            meslekten = false;
                            gorevYeriden = false;
                            hakkindadan = true;
                            sosyaldan = false;

//                            setState(() {});
                            bilgileriGuncelle();
                          },
                        ),),
                        Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 8),
                          child: Divider(height: 2, color: Colors.blueGrey, thickness: 2,),),

                        Builder(builder: (context) => ListTile(
                          leading: Icon(Icons.radio_button_checked, color: Colors.green,),
                          title: Text("Sosyal Ağlar:", style: TextStyle(color: Colors.black, fontSize: 17, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Wrap(direction: Axis.vertical ,children: [
                            Visibility( visible: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_hakkinda_gizlilik.contains("Tüm Kişilerim")
                              || doc_hakkinda_gizlilik.contains(gelen_kisi_grubu) ? true: false,
                              child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                Visibility( visible: doc_sosyal_twitter == "" ? false : true,
                                  child: IconButton(icon: Icon(FontAwesome.twitter_square, color: Colors.indigo, size: 30,),
                                    onPressed: (){
                                      _reklam.showInterad();

                                      _launchIt(doc_sosyal_twitter);
                                    },
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Visibility( visible: doc_sosyal_facebook == "" ? false : true,
                                  child: IconButton(icon: Icon(FontAwesome.facebook_f, color: Colors.blue, size: 30,),
                                    onPressed: (){
                                      _reklam.showInterad();

                                      _launchIt(doc_sosyal_facebook);
                                    },),
                                ),
                                SizedBox(width: 10,),
                                Visibility( visible: doc_sosyal_instagram == "" ? false : true,
                                  child: IconButton(icon: Icon(FontAwesome.instagram, color: Colors.purple, size: 30,),
                                    onPressed: (){
                                      _reklam.showInterad();

                                      _launchIt(doc_sosyal_instagram);
                                    },),
                                ),
                              ],),
                            ),
                            Visibility(visible: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi || doc_hakkinda_gizlilik.contains("Tüm Kişilerim")
                                || doc_hakkinda_gizlilik.contains(gelen_kisi_grubu) ? false: true,
                                child: Text("Alan gizlenmiştir.", style: TextStyle(fontSize: 15, color: Colors.red, fontStyle: FontStyle.italic))),
                            Visibility(visible: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi ? true : false,
                              child: MaterialButton(
                                child: Text("Alanın gizliliğini görmek için buraya Tıklayınız", style: TextStyle(fontSize: 12, color: Colors.blueGrey ), ),
                                onPressed: () async {
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Sosyal Ağlarınız aşağıdaki gruplara gösterilmektedir: "),
                                    content: Text(doc_sosyal_gizlilik.toString(), style: TextStyle(color: Colors.green,)),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Gizliliği Değiştir"),
                                        onPressed: (){
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          avatardan = false;
                                          telden = false;
                                          meslekten = false;
                                          gorevYeriden = false;
                                          hakkindadan = false;
                                          sosyaldan = true;

//                                          setState(() {});
                                          _gizliligiDegistir(doc_sosyal_gizlilik);
                                        },
                                      ),
                                    ],
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                },
                              ),),
                          ],),
                          onLongPress: () async {
                            telden = false;
                            meslekten = false;
                            gorevYeriden = false;
                            hakkindadan = false;
                            sosyaldan = true;

//                            setState(() {});
                            bilgileriGuncelle();
                          },
                        ),),
                        Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 8),
                          child: Divider(height: 2, color: Colors.blueGrey, thickness: 2,),),

                        SizedBox(height: 10,),
                       Center( child: MaterialButton(
                         child: Text("Hesabımı Kapat", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, decoration: TextDecoration.underline,
                             decorationColor: Colors.red, decorationThickness: 3),),
                         onPressed: (){ _hesapKapat(); },
                       )),

                       SizedBox(height: 10,),
/*
                        Visibility(visible: AtaWidget.of(context).kullaniciadi == doc_kullaniciadi ? true : false,
                          child: MaterialButton(
                            child: Text("Kayıt bilgilerinizi görmek için Tıklayınız.", style: TextStyle(
                              color: Colors.indigo, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline, decorationColor: Colors.indigo, decorationThickness: 3),),
                            onPressed: () async {
                              _kayitBilgileriGetir(doc_sifre, doc_soru, doc_cevap,);
                            },
                          ),
                        ),
*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),),

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

  void _gizliligiDegistir(List <dynamic> gizlilik) async {
    List <dynamic> gizlilik_tumKisiler = ["Tüm Kişilerim"];

    AlertDialog alertDialog = new AlertDialog (
      title: Text("Gizliliği Değiştir: "),
      content: Text("Alanı tüm kişilerinize yada bazı kişi gruplarınıza göstermeyi tercih edebilirsiniz.", textAlign: TextAlign.justify,),
      actions: [
        MaterialButton(child: Text("Tüm Kişilerime Göster", style: TextStyle(fontSize: 13, color: Colors.indigo,
            decoration: TextDecoration.underline, decorationColor: Colors.indigo, decorationThickness: 2),),
          onPressed: () async {
            avatardan == true ?
            await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"avatar_gizlilik": gizlilik_tumKisiler})
                : telden == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"tel_gizlilik": gizlilik_tumKisiler})
                : meslekten == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"meslek_gizlilik": gizlilik_tumKisiler})
                : gorevYeriden == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"gorevYeri_gizlilik": gizlilik_tumKisiler})
                : hakkindadan == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"hakkinda_gizlilik": gizlilik_tumKisiler})
                : await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"sosyal_gizlilik": gizlilik_tumKisiler});

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Alan Tüm Kişilernize gösterilecektir"),));
            Navigator.of(context, rootNavigator: true).pop("dialog");
          },
        ),
        MaterialButton(child: Text("Gruplara Göster/Gizle", style: TextStyle(fontSize: 13, color: Colors.indigo,
            decoration: TextDecoration.underline, decorationColor: Colors.indigo, decorationThickness: 2),),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");
            alanSeciliGruplaraGosterGizle(gizlilik);
          },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);
  }

  void alanSeciliGruplaraGosterGizle(List <dynamic> gizlilik) async {
    Widget _gosterilecekGrupSecAlertDialog() {
      return Container(
        height: 400, width: 400,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim").where("grup_adi", isNotEqualTo: "").snapshots(),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Icon(Icons.error, size: 40),
                );
              } else if (snapshot.data == null) {
                return Center(child: CircularProgressIndicator(),
                );
              }
              final _querySnapshot = snapshot.data;

              return ListView.builder(
                  itemCount: _querySnapshot.size,
                  itemBuilder: (BuildContext context, int index){
                    final map_gruplar = _querySnapshot.docs[index].data();
                    final id_gruplar = _querySnapshot.docs[index].id;

                    return Column(
                      children: [
                        Builder(
                          builder: (context) => Dismissible( key: UniqueKey(),
                            onDismissed: (direction) async {
                              if(gizlilik.contains(map_gruplar["grup_adi"])){
                                gizlilik.remove(map_gruplar["grup_adi"]);
                                avatardan == true ?
                                await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"avatar_gizlilik": gizlilik})
                                    : telden == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"tel_gizlilik": gizlilik})
                                    : meslekten == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"meslek_gizlilik": gizlilik})
                                    : gorevYeriden == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id)
                                    .update({"gorevYeri_gizlilik": gizlilik})
                                    : hakkindadan == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"hakkinda_gizlilik": gizlilik})
                                    : await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"sosyal_gizlilik": gizlilik});
                                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Alan gruba başarıyla gizlendi"),));
                              }
                            },
                            child: ListTile(
                                title: Text(map_gruplar["grup_adi"] ),
                                subtitle: Text(map_gruplar["grupAciklamasi"]),
                                onTap: () async {

                                  if(gizlilik.contains("Tüm Kişilerim")){
                                    gizlilik.clear();
                                    gizlilik.add(map_gruplar["grup_adi"]);
                                    if(avatardan == true){
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"avatar_gizlilik": []});
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"avatar_gizlilik": gizlilik});
                                    }
                                    if (telden == true) {
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"tel_gizlilik": []});
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"tel_gizlilik": gizlilik});
                                    }
                                    if (meslekten == true) {
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"meslek_gizlilik": []});
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"meslek_gizlilik": gizlilik});
                                    }
                                    if (gorevYeriden == true) {
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"gorevYeri_gizlilik": []});
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"gorevYeri_gizlilik": gizlilik});
                                    }
                                    if (hakkindadan == true) {
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"hakkinda_gizlilik": []});
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"hakkinda_gizlilik": gizlilik});
                                    }
                                    if (sosyaldan == true) {
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"sosyal_gizlilik": []});
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"sosyal_gizlilik": gizlilik});
                                    }
                                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Alan seçtiğiniz gruba gösterilecektir.")));

                                  } else {
                                    if(gizlilik.contains(map_gruplar["grup_adi"])) {
                                      AlertDialog alertDialog = new AlertDialog(
                                        title: Text("Alan zaten gruba gösterilmektedir. Gizlemek için grubu yana kaydırınız",
                                            style: TextStyle(color: Colors.red)),
                                      ); showDialog(context: context, builder: (_) => alertDialog);
                                    } else {
                                      gizlilik.add(map_gruplar["grup_adi"]);
                                      avatardan == true ?
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"avatar_gizlilik": gizlilik})
                                          : telden == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"tel_gizlilik": gizlilik})
                                          : meslekten == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"meslek_gizlilik": gizlilik})
                                          : gorevYeriden == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id)
                                          .update({"gorevYeri_gizlilik": gizlilik})
                                          : hakkindadan == true ? await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"hakkinda_gizlilik": gizlilik})
                                          : await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"sosyal_gizlilik": gizlilik});
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Alan görünürlüğü seçtiğiniz gruba açılmıştır.")));

                                    }
                                  }
                                },
                                trailing: gizlilik.contains(map_gruplar["grup_adi"]) ? Icon(Icons.check_circle) : SizedBox.shrink(),
                            ),
                          ),
                        ),
                        Visibility(visible: map_gruplar["grup_adi"] == "" ? false : true,
                            child: Divider(thickness: 3, color: Colors.indigo)),
                      ],
                    );
                  });
            }),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text("Hali hazırda alanın gizliliği açık olan gruplar yanında tik işareti ile gelmiştir. Buradaki kişileriniz alanı görebilirler. "
            "İşaretli olmayan gruplarınıza alan gizlenmiştir. Buradaki kişileriniz alanı göremezler. Gizli olan gruba tıklayarak grubun kişilerine alanı "
            "görme izni verebilirsiniz. Alanı görme izni olan tik işaretli gruplara alanı gizlemek için bu grubu yana kaydırınız.",
          style: TextStyle(fontSize: 13, color: Colors.deepOrange, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
        content: _gosterilecekGrupSecAlertDialog(),
        actions: [
          IconButton(icon: Icon(Icons.refresh_sharp, size: 30, color: Colors.lightBlueAccent,), onPressed: (){
            Navigator.of(context, rootNavigator: true).pop("dialog");
            alanSeciliGruplaraGosterGizle(gizlilik);
          })
        ],
      );
    });
  }

  Future imageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    _imageSelected = image;
//    setState(() {});
    uploadImage();
  }

  void uploadImage() async {

    Widget _uploadImageAlertDialog() {
      return Container(height: 300, width: 400,
        child: Column(children: [
          Flexible(
            child: Container(
                child: _imageSelected == null
                    ? Center(
                    child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ))
                    : Image.file(_imageSelected, fit: BoxFit.contain,)
            ),
          ),

          SizedBox(height: 10,),
          Text("**Resmin yüklenme süresi boyutuna ve internet hızınıza bağlıdır.**",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange), textAlign: TextAlign.center,),
        ]),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text("Profil Resimini Güncelle: ", style: TextStyle(color: Colors.green),
        ),
        content: _uploadImageAlertDialog(),
        actions: [
          Wrap( direction: Axis.horizontal, spacing: 150,
            children: [
              Container( height: 50, width: 80,
                child: FittedBox(
                  child: FloatingActionButton.extended(
                      elevation: 0,
                      icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                      label: Text("Kırp", style: TextStyle(color: Colors.purple)),
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        if(_imageSelected == null) return;
                        var image = await cropImage(_imageSelected);
                        if(image==null)
                          return;
                        _imageSelected = image;

                        showDialog(context: context, builder: (_) => AlertDialog(
                          title: Text("Profil Resimini Güncelle: ", style: TextStyle(color: Colors.green),),
                          content: _uploadImageAlertDialog(),
                          actions: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: GestureDetector(onDoubleTap: (){},
                                child: ElevatedButton(
                                  child: Text("Yükle"),
                                  onPressed: () async {
                                    if (_imageSelected == null) {return null;
                                    } else {

                                      final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("avatar");

                                      await ref.putFile(_imageSelected);
                                      var downloadUrl = await ref.getDownloadURL();
                                      String url = downloadUrl.toString();

                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"avatar": url,});

//                  setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Avatarınız başarıyla güncellendi."),
                                        action: SnackBarAction(
                                          label: 'Gizle',
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          },
                                        ),
                                      ));
                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ));
                      }
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: GestureDetector(onDoubleTap: (){},
                  child: ElevatedButton(
                    child: Text("Yükle"),
                    onPressed: () async {
                      if (_imageSelected == null) {return null;
                      } else {

                        final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("avatar");

                        await ref.putFile(_imageSelected);
                        var downloadUrl = await ref.getDownloadURL();
                        String url = downloadUrl.toString();

                        await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"avatar": url,});

//                  setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Avatarınız başarıyla güncellendi."),
                          action: SnackBarAction(
                            label: 'Gizle',
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ));
                        Navigator.of(context, rootNavigator: true).pop('dialog');

                      }
                    },
                  ),
                ),
              ),
            ],
          ),

        ],
      );
    });
  }

  void _kayitBilgileriGetir(String doc_sifre, String doc_soru, String doc_cevap,) async {
    Widget setupAlertDialogContainer() {
      return Container(
        height: 500, width: 300,
        child: ListView(
            children: [
              ListTile(leading: Icon(Icons.radio_button_checked), title: Text("Şifre:",
                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),),
                subtitle: Text(doc_sifre, style: TextStyle(fontSize: 20, color: Colors.purple),),
              ),
              Divider(thickness: 1,),
              ListTile(leading: Icon(Icons.radio_button_checked), title: Text("Güvenlik sorusu:",
                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),),
                subtitle: Text(doc_soru, style: TextStyle(fontSize: 20, color: Colors.purple),),
              ),
              Divider(thickness: 1,),
              ListTile(leading: Icon(Icons.radio_button_checked), title: Text("Güvenlik cevabı:",
                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),),
                subtitle: Text(doc_cevap, style: TextStyle(fontSize: 20, color: Colors.purple),),
              ),
              Divider(thickness: 1,),
            ]),
      );
    }showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Column( children: [
          Text("Mail ile Kayıt bilgileriniz: "),
          Text("Şifreniz, güvenlik sorunuz ve cevabınız görüntülenir. *Bilgileri Güncelle* butonuna basarak bilgilerinizi güncelleyebilirsiniz.",
            style: TextStyle(color: Colors.red, fontSize: 13, fontStyle: FontStyle.italic),),
        ],),
        content: setupAlertDialogContainer(),
        actions: [
          ElevatedButton(
            child: Text("Bilgileri Güncelle"),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("dialog");

              String sifre; String soru; String cevap;
              final _formKey_sifre = GlobalKey<FormState>();
              final _formKey_soru = GlobalKey<FormState>();
              final _formKey_cevap = GlobalKey<FormState>();

              TextEditingController sifreci = TextEditingController();
              TextEditingController sorucu = TextEditingController();
              TextEditingController cevapci = TextEditingController();

              Widget kayitBilgileriGuncelleDialog() {
                return Container( height: 400, width: 400,
                  child: ListView(
                    children: [
                      Form(key: _formKey_sifre,
                        child: TextFormField(
                          controller: sifreci,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Yeni şifrenizi giriniz"),
                          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                          validator: (String value) {
                            if(value.isEmpty){
                              sifre = "";

//                              setState(() {});
                              return "Alan değişmeyecektir"; } return null;
                          },
                        ),),
                      SizedBox(height: 10,),
                      Form(key: _formKey_soru,
                        child: TextFormField(
                          controller: sorucu,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Yeni güvenlik sorunuzu giriniz"),
                          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                          validator: (String value) {
                            if(value.isEmpty){
                              soru = "";
//                              setState(() {});
                              return "Alan değişmeyecektir"; } return null;
                          },
                        ),),
                      SizedBox(height: 10,),
                      Form(key: _formKey_cevap,
                        child: TextFormField(
                          controller: cevapci,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Yeni güvenlik cevabınızı giriniz"),
                          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                          validator: (String value) {
                            if(value.isEmpty){
                              cevap = "";

//                              setState(() {});
                              return "Alan değişmeyecektir"; } return null;
                          },
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ),
                );
              }
              showDialog(context: context, builder: (_) {
                return AlertDialog (
                  title: Text("Kayıt Bilgileri Güncelleme: ", style: TextStyle(color: Colors.green),),
                  content: kayitBilgileriGuncelleDialog(),
                  actions: [
                     ElevatedButton(
                        child: Text("Güncelle"),
                        onPressed: () async {

                          if(_formKey_sifre.currentState.validate()){
                            _formKey_sifre.currentState.save();
                            sifre = sifreci.text.trim();
                            await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"sifre": sifre});
                          }
                          if(_formKey_soru.currentState.validate()){
                            _formKey_soru.currentState.save();
                            soru = sorucu.text;
                            await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"soru": soru});
                          }
                          if(_formKey_cevap.currentState.validate()){
                            _formKey_cevap.currentState.save();
                            cevap = cevapci.text;
                            await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"cevap": cevap});
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Alan(lar) başarıyla güncellendi."),
                            action: SnackBarAction(
                              label: 'Gizle',
                              onPressed: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              },
                            ),
                          ));
                        },
                      ),

                  ],
                );
              });

            },
          ),
        ],
      );
    });
  }

  void bilgileriGuncelle() async {

    String tel; String meslek; String gorevYeri; String hakkinda; String twitter; String facebook; String instagram;
    final _formKey_tel = GlobalKey<FormState>();
    final _formKey_meslek = GlobalKey<FormState>();
    final _formKey_gorevYeri = GlobalKey<FormState>();
    final _formKey_hakkinda = GlobalKey<FormState>();
    final _formKey_twitter = GlobalKey<FormState>();
    final _formKey_facebook = GlobalKey<FormState>();
    final _formKey_instagram = GlobalKey<FormState>();

    TextEditingController telci = TextEditingController();
    TextEditingController meslekci = TextEditingController();
    TextEditingController gorevYerici = TextEditingController();
    TextEditingController hakkindaci = TextEditingController();
    TextEditingController twitterci = TextEditingController();
    TextEditingController facebookcu = TextEditingController();
    TextEditingController instagramci = TextEditingController();

    Widget BilgileriGuncelleDialog() {
      return Container( height: 200, width: 400,
        child: ListView(
          children: [
            Form(key: telden == true ? _formKey_tel : meslekten == true ? _formKey_meslek : gorevYeriden == true ? _formKey_gorevYeri
                : hakkindadan == true ? _formKey_hakkinda : _formKey_twitter,
              child: TextFormField(
                controller: telden == true ? telci : meslekten == true ? meslekci : gorevYeriden == true ? gorevYerici
                    : hakkindadan == true ? hakkindaci : twitterci,
                maxLines: hakkindadan == true ? null : 1,
                keyboardType: telden == true ? TextInputType.number : hakkindadan == true ? TextInputType.multiline : TextInputType.name,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: sosyaldan == true ? "TWITTER alanıdır!" : "",
                    labelText: "Yeni bilgileri giriniz"),
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                validator: (String value) {
                  if(value.isEmpty){
                    if(sosyaldan == true){ return "Alan değişmeyecektir";}
                    else { return "Alan boş bırakılamaz"; }
                     } return null;
                },
              ),),
            SizedBox(height: 10,),
            Visibility( visible: sosyaldan == true ? true : false,
              child: Form(key: _formKey_facebook,
                child: TextFormField(
                  controller: facebookcu,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "FACEBOOK alanıdır!",
                      labelText: "Yeni bilgileri giriniz"),
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                  validator: (String value) {
                    if(value.isEmpty){
                      return "Alan değişmeyecektir"; } return null;
                  },
                ),),
            ),
            Visibility( visible: sosyaldan == true ? true : false,
                child: SizedBox(height: 10,)),
            Visibility( visible: sosyaldan == true ? true : false,
              child: Form(key: _formKey_instagram,
                child: TextFormField(
                  controller: instagramci,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "INSTAGRAM alanıdır!",
                      labelText: "Yeni bilgileri giriniz"),
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                  validator: (String value) {
                    if(value.isEmpty){
                      return "Alan değişmeyecektir"; } return null;
                  },
                ),),
            ),
            Visibility( visible: sosyaldan == true ? true : false,
                child: SizedBox(height: 10,)),
          ],
        ),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog (
        title: Column(
          children: [
            Text(
              telden == true ? "Telefonu Güncelle: " : meslekten == true ? "Mesleği Güncelle: " : gorevYeriden == true ? "Görev Yerini Güncelle: "
                  : hakkindadan == true ? "Hakkındayı Güncelle: " : "Sosyal Ağları Güncelle: ", style: TextStyle(color: Colors.green),
            ),
            Text("Alan bilgilerini silmek için boşluk tuşuna basarak güncelleyiniz.", style: TextStyle(fontSize: 15),),
          ]
        ),
        content: BilgileriGuncelleDialog(),
        actions: [
          ElevatedButton( child: Text("Güncelle"),
            onPressed: () async {
              if(telden == true){
                if(_formKey_tel.currentState.validate()){
                  _formKey_tel.currentState.save();
                  tel = telci.text.trim();
                  await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"tel": tel});
                }
              } else if (meslekten == true){
                if(_formKey_meslek.currentState.validate()){
                  _formKey_meslek.currentState.save();
                  meslek = meslekci.text.trim();
                  await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"meslek": meslek});
                }
              } else if (gorevYeriden == true) {
                if(_formKey_gorevYeri.currentState.validate()){
                  _formKey_gorevYeri.currentState.save();
                  gorevYeri = gorevYerici.text.trim();
                  await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"gorevYeri": gorevYeri});
                }
              } else if (hakkindadan == true) {
                if(_formKey_hakkinda.currentState.validate()){
                  _formKey_hakkinda.currentState.save();
                  hakkinda = hakkindaci.text.trim();
                  await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"hakkinda": hakkinda});
                }
              } else if (sosyaldan == true) {
                if(_formKey_twitter.currentState.validate()){
                  _formKey_twitter.currentState.save();
                  twitter = twitterci.text.trim();
                  await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"sosyal_twitter": twitter});
                }
                if(_formKey_facebook.currentState.validate()){
                  _formKey_facebook.currentState.save();
                  facebook = facebookcu.text.trim();
                  await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"sosyal_facebook": facebook});
                }
                if(_formKey_instagram.currentState.validate()){
                  _formKey_instagram.currentState.save();
                  instagram = instagramci.text.trim();
                  await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"sosyal_instagram": instagram});
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Alan(lar) başarıyla güncellendi."),
                action: SnackBarAction(
                  label: 'Gizle',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ));
            },
          ),
        ],
      );
    });
  }

  Future<File> cropImage(var image)async{
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop My Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );
    return croppedFile;
  }

  Future<File> getImageFromSource(ImageSource source, bool toCrop)async{
    var image = await ImagePicker().getImage(source: source);
    if(image==null)
      return null;
    if(toCrop){
      var croppedImage = await cropImage(File(image.path));
      return croppedImage;
    }
    return File(image.path);
  }

  void _hesapKapat() async {
    var pasiflestirme_tarihi = DateTime.now();
    var sonPasifTarih = pasiflestirme_tarihi.add(Duration(days: 90));

    await FirebaseFirestore.instance.collection("users").get().then((users) => users.docs.forEach((user) {
      if(user.get("mail") != "yoneticikullanici1@gmail.com"){
        user.reference.collection("kisilerim").get().then((kisiler) => kisiler.docs.forEach((kisi) {
          tum_kisiler.add(kisi.get("mail").toString());

        }));
      }
    }));

    AlertDialog alertDialog = new AlertDialog(
      title: Text("Dikkat: ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, decoration: TextDecoration.underline,
          decorationColor: Colors.red, decorationThickness: 3), ),
      content: Text("Hesabınızı kapatma işleminin başlatılması için kimsenin kişi listesinde yer almamanız gerekemektedir. Aksi takdirde hesap kapatma işlemi başlatılamaz. "
          "Bunun sebebi boş hesap ile herhangi bir alışverişin önüne geçmektir. Lütfen işlemi başlatmadan önce kimsenin listesinde bulunmadığınızdan emin olun. ",
        textAlign: TextAlign.justify, style: TextStyle(fontWeight: FontWeight.w600,),
      ),
      actions: [
        ElevatedButton(child: Text("İşlemi Başlat"),
          onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop("dialog");

          if (tum_kisiler.contains(AtaWidget.of(context).kullanicimail)) {
            AlertDialog alertDialog = new AlertDialog(
              title: Text("HATA: ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, decoration: TextDecoration.underline,
                  decorationColor: Colors.red, decorationThickness: 3), ),
              content: Text("Kişi listesinde ekli olduğunuz en az bir kullanıcı mevcut olduğundan hesap kapatma işlemi başlatılamıyor. Bu kullanıcılara ulaşarak onlardan "
                  "sizi kendi kişi listelerinden çıkarmalarını isteyebilirsiniz.",
                textAlign: TextAlign.justify, style: TextStyle(fontWeight: FontWeight.w600,),
              ),
            ); showDialog(context: context, builder: (_) => alertDialog);
          } else {

            await FirebaseFirestore.instance.collection("users").doc(doc_id).update({"pasiflestirildi" : true,
              "pasiflestirme_tarihi" : pasiflestirme_tarihi, "sonPasifTarih": sonPasifTarih,
            });

            AlertDialog alertDialog = new AlertDialog(
              title: Text("İşlem Başlatıldı: ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, decoration: TextDecoration.underline,
                  decorationColor: Colors.green, decorationThickness: 3), ),
              content: Text("Hesap kapatma işlemi başlatıldı. Güvenlik veya işlemin yanlışlıkla gerçekleştirilmiş olma ihtimali nedenlerinden dolayı "
                  "ilk olarak hesabını 90 gün pasif hale getireceğiz. Bu süreçte görülebilir olsan da kimse seninle herhangi bir paylaşımda bulunamayacaktır. "
                  "90 gün içerisinde uygulamaya tekrar giriş yaptığında hesabın otomatik olarak aktif hale getirilecektir. 90 günün ardından hesabını kapatman için "
                  "uygulamaya son bir giriş yaparak hesap kapatma işlemini onaylaman gerekmektedir. Hesabı kapatılan kişinin kişisel verileri (Profil sayfasındaki "
                  "bilgiler) otomatik olarak silinir. Seni tekrar görmek dileğiyle...",
                textAlign: TextAlign.justify, style: TextStyle(fontWeight: FontWeight.w600,),
              ),
            ); showDialog(context: context, builder: (_) => alertDialog);
          }
//***************** KULLANICI ADI HERKESİN KİŞİ LİSTESİNDE KONTROL EDİLECEK **********************

          },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);
  }
}