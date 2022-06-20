
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/MesajGonder.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/Helpers/SinavOlusturPage.dart';
import 'package:sinavci/ListelerDetaylarPages/Bildirimler.dart';
import 'package:sinavci/ListelerDetaylarPages/GonderilenCevaplarPage.dart';
import 'package:sinavci/ListelerDetaylarPages/HerkeseAcikSinavlar.dart';
import 'package:sinavci/ListelerDetaylarPages/KisilerSinavlarAllListPage.dart';
import 'package:sinavci/ListelerDetaylarPages/OlusturulanSinavPage.dart';
import 'package:sinavci/ProfilPage.dart';
import 'package:sinavci/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SinavlarKisilerPage extends StatefulWidget {
  final doc_id; final map; final doc_avatar; final gonderen_secildi;
  const SinavlarKisilerPage({Key key, this.doc_id, this.map, this.doc_avatar, this.gonderen_secildi}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SinavlarKisilerPageState(this.doc_id, this.map, this.doc_avatar, this.gonderen_secildi);
  }
}

class SinavlarKisilerPageState extends State<SinavlarKisilerPage> {
  final doc_id; final map; final doc_avatar; bool gonderen_secildi;
  SinavlarKisilerPageState(this.doc_id, this.map, this.doc_avatar, this.gonderen_secildi);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference collectionReference_hs; Reference storageReference_hs;
  CollectionReference collectionReference_gs; Reference storageReference_gs;
  CollectionReference collectionReference_has; Reference storageReference_has;
  File _imageSelected; String imageFileName;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String soruyu_cevaplayan_id;
  String sinavGonderen_id; String sinavGonderen_kullaniciadi;
  bool kisilerim_grupEkle = false; bool hazirladigimSinavlar_grupEkle = false; bool gonderilenSinavlar_grupEkle = false; bool herkeseAcikSinavlar_grupEkle = false;
  bool kisilerim_gruplandir = false; bool hazirladigimSinavlar_gruplandir = false; bool gonderilenSinavlar_gruplandir = false; bool has_gruplandir = false;
  dynamic gonderilenSinav_paylasilanId; dynamic gonderilenSinav_paylasilanMap; dynamic gs_id_sinav;

  List<String> has_baslik = [];
  List<String> has_konu = [];
  List<String> has_hazirlayan = [];
  List<String> has_hazirlayan_id = [];
  List<String> has_mail = [];
  List<String> has_tarih = [];
  List<dynamic> herkese_acik_sinavlar = [];
  List<dynamic> herkese_acik_sinavlar_id = [];
  List <dynamic> has_gruplar = [];
  List<dynamic> has_grup_liste = [];
  List<dynamic> has_grup_liste_id = [];
  dynamic map_bildirimler;
  List<dynamic> okunan_bildirimler = [];
  List<dynamic> okunan_bildirimler_id = [];
  List<dynamic> okunmayan_bildirimler = [];
  List<dynamic> okunmayan_bildirimler_id = [];

  TextEditingController has_controller = new TextEditingController();
  String filtre;

  Reklam _reklam = new Reklam();
  @override

  void initState() {
    _reklam.createInterad();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold( key: UniqueKey(),
      floatingActionButton: Visibility(
        child: Align( alignment: Alignment(-.9,.95),
          child: FloatingActionButton( child: Icon(Icons.notifications_active,
            size: AtaWidget.of(context).okunmayan_bildirimler == null || AtaWidget.of(context).okunmayan_bildirimler.length == 0 ? 30 : 40,
            color: AtaWidget.of(context).okunmayan_bildirimler == null || AtaWidget.of(context).okunmayan_bildirimler.length == 0 ? Colors.white : Colors.yellow,),
            heroTag: "bildirim_msj", elevation: 20, backgroundColor: Colors.indigo, tooltip: "Okunmamış bildirim(ler)iniz var...",
            onPressed: () {
              okunan_bildirimler.clear();
              okunmayan_bildirimler.clear();

              okunmayanBildirimleri_getir();


//              print(AtaWidget.of(context).bildirimler.toString().toUpperCase());
            },),
        ),
      ),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: GestureDetector(
          child: Wrap( direction: Axis.vertical,
            children: [
              RichText(text: TextSpan(
                  style: TextStyle(),
                  children: <TextSpan>[
                    TextSpan(text: "  Hoşgeldiniz  ",
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
                    TextSpan(text: AtaWidget.of(context).kullaniciadi, style: TextStyle(color: Colors.indigo,
                        fontSize: 25, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                  ]
              )),
              Text("  *Profilinize gitmek için Tıklayınız", style: TextStyle(fontSize: 10, color: Colors.white)),
            ]
          ),
          onTap: (){
 //*********PROFİL SAYFASINA GİDİLECEK*******
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilPage(doc_id: doc_id,)));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(icon: Icon(Icons.campaign), iconSize: 30,
              onPressed: (){
                AlertDialog alertDialog = new AlertDialog(
                  title: Text("BİLGİLENDİRME"),
                  content: Container( height: 300,
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MaterialButton(child: Text("Hazırladığım Sınavlarım asistan video için Tıklayın.", style: TextStyle(color: Colors.green),
                            textAlign: TextAlign.center,),
                            onPressed: (){
                              _launchIt("https://drive.google.com/file/d/1QG5Cdfr-7ob8jki1b54ZlrqB3M5MCp9j/view?usp=sharing");
                            },),
                          MaterialButton(child: Text("Gönderilen Sınavlar asistan video için Tıklayın.", style: TextStyle(color: Colors.green),
                            textAlign: TextAlign.center,),
                            onPressed: (){
                              _launchIt("https://drive.google.com/file/d/1Q5GUj_mVKNrDaN5J2RAeZsfXJvl1fKSV/view?usp=sharing");
                            },),
                          MaterialButton(child: Text("Kişilerim asistan video için Tıklayın.", style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                            onPressed: (){
                              _launchIt("https://drive.google.com/file/d/1QLqFqcey17jNQcu_KdgyknpNLNBLFkGr/view?usp=sharing");
                            },),
                          Center(
                            child: Text("* İsminize tıklayarak profil sayfanıza gidebilirsiniz.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text("* Sayfada HAZIRLADIĞIM SINAVLARIM, GÖNDERİLEN SINAVLAR ve KİŞİLERİM olmak üzere üç kart bulunmaktadır. Kartlarda yapılabilecek "
                                " işlemler hakkında detaylı bilgi alabilmek için karta ait duyuru ikonuna basınız.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text("* Her karta özel gruplar oluşturabilirsiniz. Oluşturduğunuz bu gruplara karta ait kişi/sınav eklediğinizde ileride bu elemanları "
                                "bulmanız daha kolay olacaktır. Grup oluşturmak için kartların altında bulunan *Grup Ekle* butonuna basınız. Oluşturulan gruplar "
                                "kartın kendi sayfasında görüntülenir.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                        ],
                      ),
                    ),
                  ),
                );showDialog(context: context, builder: (_) => alertDialog);
              },),
          ),
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
          )
        ],
      ),
      body: ListView(
        children: [
          Padding( padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Text("**Bu sayfada son sınavlarınız ve tüm kişileriniz görüntülenir. Sizinle paylaşılan veya Herkese Açık"
                " sınavları görmek için Sınavlar Kartını sağa kaydırınız.**",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                textAlign: TextAlign.justify),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(Colors.black),
                trackColor: MaterialStateProperty.all(Colors.black38),
                trackBorderColor: MaterialStateProperty.all(Colors.black54),
                showTrackOnHover: true, mainAxisMargin: 30, crossAxisMargin: 22, minThumbLength: 10,

              ),
            ),
            child: Scrollbar( thickness: 5, radius: Radius.elliptical(10, 10), hoverThickness: 5, showTrackOnHover: true,
              child: Container(height: 420,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only( bottom: 30.0),
                        child: SizedBox(height: 390, width: 330,
                            child: Card( elevation: 20.0, shadowColor: Colors.black,
                                color: Colors.grey.shade500,
                                child: ListTile(
//                                leading: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.list_alt, color: Colors.indigo, size: 30),),
                                  title: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.list_alt, color: Colors.indigo, size: 30),),
                                      Text("Hazırladığım Sınavlarım", style: TextStyle( fontFamily: "Cormorant Garamond",
                                          color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 25),
                                        textAlign: TextAlign.center,
                                      ),
                                    ]
                                  ),
                                  subtitle: Wrap( children: [
                                    Container(height: 280,
                                      child: StreamBuilder(
                                          stream: FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar")
                                              .orderBy("tarih", descending: true).snapshots(),
                                          builder: (context, snapshot) {
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

                                            collectionReference_hs = FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar");
                                            storageReference_hs = FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                .child("sinavlar");
                                            final querySnapshot = snapshot.data;
                                            return Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: (){
                                                      AtaWidget.of(context).AllList_kisilerimden = false;
                                                      AtaWidget.of(context).AllList_gonderilenSinavlarimdan = false;
                                                      AtaWidget.of(context).AllList_hazirladigimSinavlarimdan = true;

                                                      _reklam.showInterad();
                                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                                          KisilerSinavlarAllListPage(collectionReference: collectionReference_hs,
                                                        storageReference: storageReference_hs, doc_id: doc_id, gruplari_getir: false, grupAdi: "")));


                                                    },
                                                    child: RichText(text: TextSpan(
                                                        style: TextStyle(), children:<TextSpan>[
                                                      TextSpan(text: "Sınavlar sondan başa doğru sıralanmıştır. Hazırladığınız tüm sınavları veya sınav "
                                                          "gruplarınızı görmek için ",
                                                        style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,
                                                          fontSize: 12,),),
                                                      TextSpan(text: "  *Buraya Tıklayınız.*",
                                                          style: TextStyle(color: Colors.indigo, fontSize: 18, fontStyle: FontStyle.italic,
                                                              fontWeight: FontWeight.bold)),
                                                    ]
                                                    ), textAlign: TextAlign.justify,),
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Flexible(
                                                    child: querySnapshot.size == 0 ? Center(
                                                      child: Text("Gösterilecek herhangi bir sınav bulunamadı.",
                                                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                                                    ) :
                                                    ListView.builder(
                                                        itemCount: querySnapshot.size,
                                                        itemBuilder: (context, index) {
                                                          final map_sinav = querySnapshot.docs[index].data();
                                                          final id_sinav = querySnapshot.docs[index].id;

                                                          return Column(children: [
                                                            SizedBox(height: 5,),
                                                            Container(
                                                              color: Colors.blue.shade100,
                                                              child: Visibility( visible: map_sinav["baslik"] == "" ? false : true,
                                                                child: GestureDetector(
                                                                  onDoubleTap: (){
                                                                    map_sinav["gorsel_cevap"] == null || map_sinav["gorsel_cevap"] == " " || map_sinav["gorsel_cevap"] == "" ?
                                                                    _metinselCevapGoster(map_sinav) : _launchIt(map_sinav["gorsel_cevap"]);
                                                                  },
                                                                  child: ListTile(
                                                                      title: Text(map_sinav["baslik"],
                                                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                                                      subtitle: Text(map_sinav["konu"]),
                                                                      trailing: Wrap(direction: Axis.vertical,
                                                                          children: [
                                                                            Text(map_sinav["tarih"].toString().substring(0,10)),
                                                                            Text(map_sinav["tarih"].toString().substring(11,16),)
                                                                          ] ),

                                                                      onTap: () async {
                                                                        _reklam.showInterad();

                                                                        if(map_sinav["olusturulanmi"] == true){

                                                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                                                              OlusturulanSinavPage(map_solusturulan: map_sinav, id_solusturulan: id_sinav, grid_gorunum: false,
                                                                                  collectionReference: collectionReference_hs, storageReference: storageReference_hs)));
                                                                        } else if(map_sinav["olusturulanmi"] == false){
                                                                          String _doc_baslik; String _doc_cevaplayan; String _doc_id; String _doc_aciklama; String _doc_gorsel;
                                                                          int _doc_puan;
                                                                          await collectionReference_hs.doc(id_sinav.toString()).collection("soruyu_cevaplayanlar")
                                                                              .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                                                                              .get().then((QuerySnapshot querySnapshot)=>{
                                                                            querySnapshot.docs.forEach((_doc) async {

                                                                              _doc_baslik = _doc["baslik"];
                                                                              _doc_cevaplayan = _doc["cevaplayan"];
                                                                              _doc_aciklama = _doc["aciklama"];
                                                                              _doc_gorsel = _doc["gorsel"];
                                                                              _doc_puan = _doc["puan"];
                                                                              _doc_id = _doc.id.toString();

                                                                            })
                                                                          });

                                                                          _sinaviGor(map_sinav, id_sinav, _doc_baslik, _doc_gorsel, _doc_aciklama, _doc_id, _doc_puan);
                                                                        }
                                                                      },
                                                                      onLongPress: () async {
                                                                        _reklam.createInterad();

                                                                        showDialog(context: context, builder: (_) {
                                                                          return AlertDialog(
                                                                            backgroundColor: Colors.white,
                                                                            title: Text("${map_sinav["baslik"]}"),
                                                                            content: Text( map_sinav["olusturulanmi"] == true ?
                                                                            "başlıklı sınavın *açıklama, *konu, *bitiş tarihi, *ders, *grup adı alanlarını buradan "
                                                                                "düzenleyebilirsiniz. ""Sınavınızın diğer alanlarını düzenlemek yada soru eklemek "
                                                                                "için sınava "
                                                                                "tıklayınız. ""Sınavınızı paylaşmak için *Sınavı Paylaş* butonunu kullanınız." :
                                                                            "başlıklı sınavın *açıklama, *konu, *bitiş tarihi, *ders, *grup adı alanlarını güncellemek, "
                                                                                "sınavınıza *cevap eklemek/değiştirmek için *Sınavı Düzenle* butonuna, kişileriniz ile "
                                                                                "sınavınızı "
                                                                                "paylaşmak için *Sınavı Paylaş* butonu basınız."
                                                                              ,style: TextStyle(color: Colors.black), textAlign: TextAlign.justify,),
                                                                            actions: [
                                                                              Wrap( spacing: 8,
                                                                                children: [
                                                                                  MaterialButton( color: Colors.amber,
                                                                                      child: Text("Sınavı Sil"),

                                                                                      onPressed: () async {
                                                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
                                                                                        Text("İşleminiz yapılıyor..."),
                                                                                          action: SnackBarAction(label: "Gizle",
                                                                                              onPressed: () => SnackBarClosedReason.hide ),));
                                                                                        if(map_sinav["olusturulanmi"] == true) {
                                                                                          List <dynamic> sorular = [];
                                                                                          await collectionReference_hs.doc(id_sinav).collection("sorular").get()
                                                                                              .then((_sorular) => _sorular.docs.forEach((_soru) {
                                                                                                sorular.add(_soru["baslik"]);
                                                                                          }));
                                                                                          os_sinavSil(map_sinav, id_sinav, sorular);
                                                                                        } else {
                                                                                          hs_sinaviSil(map_sinav, id_sinav);
                                                                                        }
                                                                                      }),
                                                                                  ElevatedButton(
                                                                                      child: Text("Sınavı Düzenle"),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
                                                                                        Text("İşleminiz yapılıyor..."),
                                                                                          action: SnackBarAction(label: "Gizle", onPressed: () =>
                                                                                          SnackBarClosedReason.hide ),));
                                                                                        _sinaviDuzenle(map_sinav, id_sinav);
                                                                                      }),
                                                                                ],
                                                                              ),
                                                                              ElevatedButton(
                                                                                  child: RichText(text: TextSpan(
                                                                                    children: <TextSpan>[
                                                                                      TextSpan(text: "Sınavı Paylaş", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                      TextSpan(text: " / ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                                                                                          color: Colors.black )),
                                                                                      TextSpan(text: "Paylaşımı Kaldır", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                    ]
                                                                                  )),
                                                                                  onPressed: () async {

                                                                                    bool kisilerim;
                                                                                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString())
                                                                                        .collection("kisilerim").get().then((QuerySnapshot querySnapshot)=>{
                                                                                      querySnapshot.docs.forEach((_doc) async {
                                                                                        kisilerim = true;
//                                                                                setState(() {});
                                                                                      })
                                                                                    });

                                                                                    if(kisilerim != true){
                                                                                      AlertDialog alertDialog = new AlertDialog(
                                                                                        title: Text("Hiç kişiniz bulunamamıştır. Önce hesabınıza kişi ekleyiniz.",
                                                                                            style: TextStyle(color: Colors.red)),
                                                                                      );showDialog(context: context, builder: (_) => alertDialog);
                                                                                    } else {
                                                                                      Navigator.of(context, rootNavigator: true).pop('dialog');

                                                                                      var paylasilanlar = [];
                                                                                      await collectionReference_hs.doc(id_sinav.toString()).collection("paylasilanlar")
                                                                                          .get().then((QuerySnapshot querySnapshot)=>{
                                                                                        querySnapshot.docs.forEach((_doc) async {
                                                                                          paylasilanlar.add(_doc["kullaniciadi"]);
//                                                                                          setState(() {});
                                                                                        })
                                                                                      });

                                                                                      _sinaviPaylas(map_sinav, id_sinav, paylasilanlar);
                                                                                    }
                                                                                  }),
                                                                            ],
                                                                          );
                                                                        });
                                                                      },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Visibility( visible: map_sinav["baslik"] == "" ? false : true,
                                                                child: Divider(height: 8,thickness: 2, color: Colors.black,))
                                                          ]);
                                                        }),

                                                  ),
                                                ]
                                            );
                                          }),
                                    ),
                                    Align(alignment: Alignment.bottomRight,
                                      child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(icon: Icon(Icons.campaign, color: Colors.white), iconSize: 30,
                                            onPressed: (){
                                              _reklam.createInterad();

                                              AlertDialog alertDialog = new AlertDialog(
                                                title: Text("BİLGİLENDİRME"),
                                                content: Container( height: 400,
                                                  child: SingleChildScrollView(
                                                    physics: ClampingScrollPhysics(),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        MaterialButton(child: Text("Hazırladığım Sınavlarım asistan video için Tıklayın.",
                                                          style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                          onPressed: (){
                                                            _launchIt("https://drive.google.com/file/d/1QG5Cdfr-7ob8jki1b54ZlrqB3M5MCp9j/view?usp=sharing");
                                                          },),
                                                        Center(
                                                          child: Text("*Sınavların paylaşıldığı kişiler sınavları görebilir ve çözebilir. Sınav sadece hazırlayıcısı tarafından "
                                                              "düzenlenip, silinebilir. Sınavınızı düzenlemek, silmek, cevap eklemek/cevabı güncellemek/kaldırmak veya kişileriniz "
                                                              "ile paylaşmak için uzun basınız. Sınava çift tıkladığınızda resim formatında çözüm dökümanı eklediyseniz bu döküman "
                                                              "tarayıcıda gösterilir. Belge formatındaki çözümler ise tarayıcıdan indirilir.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Center(
                                                          child: Text("*Herkes uygulama üzerinden sınav hazırlayıp kişileri ile paylaşabilir. Dilerseniz sınavınızı veya "
                                                              "kişilerinizi gruplandırabilirsiniz. Sınavınız herkese açık olarak gösterilmez.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Visibility(
                                                          child: Center(
                                                            child: Text("*Hazır Sınav Ekleme seçeneğinde pdf, word yada resim olarak bir seferde tek bir döküman eklenebilir. "
                                                                "Dökümanın kaç sayfadan oluştuğu önemli değildir. Her bir döküman için tek bir çözüm/cevap ekleyebilirsiniz. "
                                                                "Birden fazla döküman ekleyecekseniz Sınav Oluştur seçeneğini kullanmalısınız. ",
                                                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Visibility(
                                                          child: Center(
                                                            child: Text("*Sınav Oluştur seçeneğinde istediğiniz sayıda soru yada sınavı telefonunuzun dosyalarım klasöründen "
                                                                "yada kamerasından resim olarak ekleyebileceğiniz gibi uygulama içinden metin olarak da girebilirsiniz. Sınav Oluşturma esnasında "
                                                                "dilerseniz kendi test sorunuzu da oluşturabilir ve bunu sınavınıza ekleyebilirsiniz.",
                                                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Visibility(
                                                          child: Center(
                                                            child: Text("Mutlu Sınavlar...",
                                                              style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );showDialog(context: context, builder: (_) => alertDialog);
                                            },),
                                          Container( height: 60, width: 60,
                                              child: FittedBox(
                                                child: FloatingActionButton.extended(
                                                  heroTag: "hazirladigimSinav_GrupEkle",
                                                  label: Text("Grup Ekle", style: TextStyle(color: Colors.indigo),),
                                                  backgroundColor: Colors.white,
                                                  onPressed: () async {
                                                    _reklam.createInterad();
                                                      herkeseAcikSinavlar_grupEkle = false;
                                                      kisilerim_grupEkle = false;
                                                      hazirladigimSinavlar_grupEkle = true;
                                                      gonderilenSinavlar_grupEkle = false;
                                                      print("kisilerim_grupEkle: " + kisilerim_grupEkle.toString());
                                                      print("hazirladigimSinavlar_grupEkle: " + hazirladigimSinavlar_grupEkle.toString());
                                                      print("gonderilenSinavlar_grupEkle: " + gonderilenSinavlar_grupEkle.toString());

                                                      _grupEkle();
                                                  },),)),
                                          Container(height: 80, width: 80,
                                            child: FittedBox(
                                              child: FloatingActionButton.extended(
                                                heroTag: "sınavEkle",
                                                onPressed: () {
                                                  _reklam.createInterad();

                                                  AlertDialog alertDialog = new AlertDialog(
                                                    actions: [
                                                      RaisedButton(
                                                          color: Colors.green,
                                                          child: Text("Hazır Sınav Ekle"),
                                                          onPressed: () async {

                                                            Navigator.of(context,rootNavigator: true).pop('dialog');
                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor"),
                                                              action: SnackBarAction(label: "Gizle", onPressed: (){
                                                                SnackBarClosedReason.hide;
                                                              }),));

                                                            await _sinavEkle();
                                                          }),
                                                      RaisedButton(
                                                          color: Colors.blue,
                                                          child: Text("Sınav Oluştur"),
                                                          onPressed: () async{
                                                            AtaWidget.of(context).baslik_sinavOlustur = null;
                                                            AtaWidget.of(context).sinav_baslik_sinavOlustur = null;
                                                            AtaWidget.of(context).soruSelected_sinavOlustur = null;
                                                            AtaWidget.of(context).soru_testmi_sinavOlustur = null;
                                                            AtaWidget.of(context).harf_sinavOlustur = null;
                                                            AtaWidget.of(context).id_subCol_newDoc_sinavOlustur = null;
                                                            AtaWidget.of(context).metinsel_soru_sinavOlustur = null;
                                                            AtaWidget.of(context).gorsel_soru_sinavOlustur = null;
                                                            AtaWidget.of(context).soru_metni_sinavOlustur = null;
                                                            AtaWidget.of(context).sayi_sinavOlustur = null;
                                                            AtaWidget.of(context).idnewDoc_sinavOlustur = null;
                                                            AtaWidget.of(context).cevapSelected_sinavOlustur = null;
                                                            AtaWidget.of(context).test_mesaji_sinavOlustur = null;

                                                            Navigator.of(context,rootNavigator: true).pop('dialog');
                                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                                                SinavOlusturPage(collectionreference: collectionReference_hs, storageReference: storageReference_hs,)));

                                                          }),
                                                    ],
                                                    title: Text("SINAV EKLE", style: TextStyle(color: Colors.green)),
                                                    content: Column(children: [
                                                      MaterialButton(child: Text("Hazır Sınav Ekle asistan video için Tıklayın.",
                                                        style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                        onPressed: (){
                                                          _launchIt("https://drive.google.com/file/d/1QG5Cdfr-7ob8jki1b54ZlrqB3M5MCp9j/view?usp=sharing");
                                                        },),
                                                      MaterialButton(child: Text("Sınav Oluştur asistan video için Tıklayın.",
                                                        style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                        onPressed: (){
                                                          _launchIt("https://drive.google.com/file/d/1QEVw8_M9vPHrxcHDRTUo1aL-ZHKHAdNW/view?usp=sharing");
                                                        },),
                                                      Text("* Sınavınızı tek resim yada tek belge olarak telefonunuzdan hazır ekleyebilir yada buradan sınav oluşturabilirsiniz. ",
                                                        style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Text("* Alıştırmaların cevap/çözüm linkini buradan girebilirsiniz. Uzun açıklamaya sahip yada görsel "
                                                          "cevap/çözüm eklerinizi daha sonra cevap ekleme butonundan da ekleyebilirsiniz.",
                                                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                                      ),
                                                      SizedBox(height: 20,),
                                                      Text("* Aşağıdaki alanlardan birini seçerek işleme devam edebilirsiniz.",
                                                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                                      ),
                                                    ]),
                                                  );
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) => Container(
                                                        child: SingleChildScrollView(
                                                          physics: ClampingScrollPhysics(),
                                                          child: alertDialog,
                                                        ),
                                                      ));
                                                },
                                                backgroundColor: Colors.white,
                                                icon: Icon(Icons.add, color: Colors.indigo, size: 50,),
                                                label: Text("Sınav Ekle", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),),
                                              ),
                                            ),

                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  ),
                                )

                            ),

                        ),
                      ),
                      SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only( bottom: 30.0),
                        child: SizedBox(height: 390, width: 350,
                          child: Card( elevation: 20.0, shadowColor: Colors.black,
                              color: Colors.grey.shade500,
                              child: ListTile(
//                              leading: CircleAvatar( backgroundColor: Colors.white, child: Icon(Icons.list_alt, color: Colors.indigo, size: 30),),
                                title: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CircleAvatar( backgroundColor: Colors.white, child: Icon(Icons.list_alt, color: Colors.indigo, size: 30),),
                                    Text("Gönderilen Sınavlar", style: TextStyle( fontFamily: "Cormorant Garamond",
                                        color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 25),
                                      textAlign: TextAlign.center,
                                    ),
                                  ]
                                ),
                                subtitle: Wrap( children: [
                                  Container(height: 280,
                                    child: gonderen_secildi != true ?
                                    Center(
                                      child: Container(
                                        child: FittedBox(
                                          child: FloatingActionButton.extended(
                                            label: Text("Gönderen Seç", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                            heroTag: "gonderenSec",
                                            backgroundColor: Colors.white,
                                            onPressed: () async {
//                                      setState(() {gonderen_secildi = true;});
                                              _gonderenSec();
                                            },
                                          ),
                                        ),
                                      )
                                    ) :
                                    StreamBuilder(
                                        stream: FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id).collection("sinavlar")
                                            .where("paylasilanlar", arrayContains: AtaWidget.of(context).kullaniciadi).orderBy("tarih", descending: true).snapshots(),
                                        builder: (context, snapshot) {
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

                                          collectionReference_gs = FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id)
                                              .collection("sinavlar");
                                          storageReference_gs = FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).sinavGonderen_kullaniciadi)
                                              .child("sinavlar");
                                          final querySnapshot = snapshot.data;
                                          return Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: (){
                                                    AtaWidget.of(context).AllList_kisilerimden = false;
                                                    AtaWidget.of(context).AllList_gonderilenSinavlarimdan = true;
                                                    AtaWidget.of(context).AllList_hazirladigimSinavlarimdan = false;

                                                    _reklam.showInterad();

                                                    print("AtaWidget.of(context).sinavGonderen_id: " + AtaWidget.of(context).sinavGonderen_id);
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                                        KisilerSinavlarAllListPage(collectionReference: collectionReference_gs,
                                                          storageReference: storageReference_gs, doc_id: doc_id, gruplari_getir: false, grupAdi: "")));
                                                  },
                                                  child: RichText(text: TextSpan(
                                                      style: TextStyle(), children:<TextSpan>[
                                                    TextSpan(text: "Sınavlar sondan başa doğru sıralanmıştır. Tüm sınavları/grupları görmek için",
                                                      style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),),
                                                    TextSpan(text: "  *Buraya Tıklayınız.*",
                                                        style: TextStyle(color: Colors.indigo, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                                  ]
                                                  ), textAlign: TextAlign.justify,),
                                                ),
                                                SizedBox(height: 10,),
                                                Flexible(
                                                  child: querySnapshot.size == 0 ? Center(
                                                    child: Text("Gösterilecek herhangi bir veri bulunamadı.",
                                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                                                  ) :
                                                  ListView.builder(
                                                      itemCount: querySnapshot.size,
                                                      itemBuilder: (context, index) {
                                                        final map_sinav = querySnapshot.docs[index].data();
                                                        final id_sinav = querySnapshot.docs[index].id;

                                                        return Column(children: [
                                                          SizedBox(height: 5,),
                                                          Container(
                                                            color: Colors.blue.shade100,
                                                            child: GestureDetector(
                                                              onDoubleTap: () {
                                                                map_sinav["kilitli"] == false ?
                                                                map_sinav["gorsel_cevap"] == null || map_sinav["gorsel_cevap"] == " " || map_sinav["gorsel_cevap"] == "" ?
                                                                _metinselCevapGoster(map_sinav) : _launchIt(map_sinav["gorsel_cevap"])
                                                                    :
                                                                showDialog(context: context, builder: (_) {
                                                                  return AlertDialog(
                                                                    title: Text("*Hata: Sınavın cevapları kilitlidir, görülemez", style: TextStyle(color: Colors.red)),
                                                                  );
                                                                });
                                                              },
                                                              child: ListTile(
                                                                  title: Text(map_sinav["baslik"],
                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                                                  subtitle: Text(map_sinav["konu"]),
                                                                  trailing: Wrap(direction: Axis.vertical,
                                                                      children: [
                                                                        Text(map_sinav["tarih"].toString().substring(0,10)),
                                                                        Text(map_sinav["tarih"].toString().substring(11,16),)
                                                                      ] ),

                                                                  onTap: () async {

                                                                    if(map_sinav["olusturulanmi"] == true){

                                                                      _reklam.showInterad();

                                                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                                                          OlusturulanSinavPage(map_solusturulan: map_sinav, id_solusturulan: id_sinav, grid_gorunum: false,
                                                                              collectionReference: collectionReference_gs, storageReference: storageReference_gs)));
                                                                    } else if(map_sinav["olusturulanmi"] == false){
                                                                      String _doc_baslik; String _doc_cevaplayan; String _doc_id; String _doc_aciklama; String _doc_gorsel;
                                                                      int _doc_puan;
                                                                      await collectionReference_gs.doc(id_sinav.toString()).collection("soruyu_cevaplayanlar")
                                                                          .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                                                                          .get().then((QuerySnapshot querySnapshot)=>{
                                                                        querySnapshot.docs.forEach((_doc) async {

                                                                          _doc_baslik = _doc["baslik"];
                                                                          _doc_cevaplayan = _doc["cevaplayan"];
                                                                          _doc_aciklama = _doc["aciklama"];
                                                                          _doc_gorsel = _doc["gorsel"];
                                                                          _doc_puan = _doc["puan"];
                                                                          _doc_id = _doc.id.toString();

                                                                        })
                                                                      });

                                                                      _sinaviGor(map_sinav, id_sinav, _doc_baslik, _doc_gorsel, _doc_aciklama, _doc_id, _doc_puan);
                                                                    }
                                                                  },
                                                                  onLongPress: () async {
                                                                    _reklam.createInterad();

                                                                    gs_id_sinav = id_sinav;
                                                                    await FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id)
                                                                        .collection("sinavlar").doc(id_sinav.toString()).collection("paylasilanlar")
                                                                        .where("kullaniciadi", isEqualTo: AtaWidget.of(context).kullaniciadi).limit(1).get()
                                                                        .then((value) => value.docs.forEach((element) {
                                                                          gonderilenSinav_paylasilanId =  element.id;
                                                                          gonderilenSinav_paylasilanMap = element.data();
//                                                                  setState(() {});
                                                                        }));

                                                                      kisilerim_gruplandir = false;
                                                                      hazirladigimSinavlar_gruplandir = false;
                                                                      gonderilenSinavlar_gruplandir = true;
                                                                      has_gruplandir = false;
//                                                              setState(() {});
                                                                    _gruplandir(gonderilenSinav_paylasilanMap, gonderilenSinav_paylasilanId);
                                                                  }
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(height: 8,thickness: 2, color: Colors.black,)
                                                        ]);
                                                      }),

                                                ),
                                              ]
                                          );
                                        }),
                                  ),
                                  Align(alignment: Alignment.bottomRight,
                                    child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(icon: Icon(Icons.campaign, color: Colors.white), iconSize: 30,
                                          onPressed: (){
                                            _reklam.createInterad();

                                            AlertDialog alertDialog = new AlertDialog(
                                              title: Text("BİLGİLENDİRME"),
                                              content: Container( height: 400,
                                                child: SingleChildScrollView(
                                                  physics: ClampingScrollPhysics(),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      MaterialButton(child: Text("Gönderilen Sınavlar asistan video için Tıklayın.",
                                                        style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                        onPressed: (){
                                                          _launchIt("https://drive.google.com/file/d/1Q5GUj_mVKNrDaN5J2RAeZsfXJvl1fKSV/view?usp=sharing");
                                                        },),
                                                      Center(
                                                        child: Text("* Bu kartta kişilerinizin sizinle paylaştığı tüm sınavlar gösterilmektedir. Sınavı görmek, "
                                                            "çözmek, çözümünüzü silmek için üzerine tıklayınız. Sınavın çözümünü görmek için çift tıklayınız. Cevap kilidi "
                                                            "açılmış sınavların çözümleri resim formatında ise tarayıcı üzerinden görülebilir, belge formatında ise tarayıcı "
                                                            "üzerinden indirilebilir. Hazırlayan tarafından cevap kilidi açılmamış sınavların çözümleri gösterilmez.",
                                                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Center(
                                                        child: Text("* Sınavınızın üzerine uzun basarak onu gruplandırabiliriniz. Sınavı gruplandırmak ileride daha kolay bulmanıza "
                                                            "yardımcı olacaktır. ",
                                                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Cevap kağıdı kilitli sınavlara kendi cevap/çözümünüzü gönerebilirisiniz ama sınavın cevap kağıdını "
                                                              "göremezsiniz. Bu kilidi açma-kapama yetkisi sadece sınavı hazırlayana aittir. Cevap kilidi açılan sınavların cevap "
                                                              "kağıdı görülebilir ama cevaplayanlar artık sınava cevap gönderemezler.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Tek resim olarak yüklenen sınavlar uygulama üzerinden görülebilir. Bazı sınavlar ise pdf, word formatında "
                                                              "hazırlanmış olabilir o sınavlar uygulama üzerinden görülemezler. Sınava tıkladığınızda tarayıcınızdan sınavı indirerek "
                                                              "telefonunuzdaki ilgili uygulamada sınavı görebilirsiniz. Çözümünüzü yine uygulama üzerinden gönderebilirsiniz.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Bazı sınavlar birden fazla görsel yada metinsel soru yüklenerek oluşturulmuştur. Bu formatta oluşturulan "
                                                              "sınavlara tek bir cevap yüklemesi yapılamaz. Her soru için ayrı ayrı cevap/çözüm yüklemesi yapmalısınız. Ayrıca "
                                                              "çoktan seçmeli test soruları için şıkkın işaretlenmesi ve çözümünün gönderilmesi ayrı işlemlerdir.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* SINAVCIM uygulaması ile herkes kolayca sınav hazırlayabilir. Sadece sınav çözen olarak kalmayın, "
                                                              "kendi sınavınızı hazırlayın ve kişileriniz ile paylaşın. ",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("Mutlu Sınavlar...",
                                                            style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );showDialog(context: context, builder: (_) => alertDialog);
                                          },),
                                        Container( height: 60, width: 60,
                                            child: FittedBox(
                                              child: FloatingActionButton.extended(
                                                heroTag: "gonderilenSinav_GrupEkle",
                                                label: Text("Grup Ekle", style: TextStyle(color: Colors.indigo),),
                                                backgroundColor: Colors.white,
                                                onPressed: () async {
                                                  _reklam.createInterad();
                                                    herkeseAcikSinavlar_grupEkle = false;
                                                    kisilerim_grupEkle = false;
                                                    hazirladigimSinavlar_grupEkle = false;
                                                    gonderilenSinavlar_grupEkle = true;
                                                  _grupEkle();
                                                },),)),
                                        Container(height: 80, width: 80,
                                          child: FittedBox(
                                            child: FloatingActionButton.extended(
                                              heroTag: "AlanTemizle",
                                              onPressed: () {
                                                _reklam.createInterad();

                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                                                    SinavlarKisilerPage(doc_id: doc_id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
                                              },
                                              backgroundColor: Colors.white,
                                              label: Text("Alanı Temizle", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),),
                                            ),
                                          ),

                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                ),
                              )

                          ),

                        ),
                      ),
                      SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only( bottom: 30.0),
                        child: SizedBox(height: 390, width: 350,
                          child: Card( elevation: 20.0, shadowColor: Colors.black,
                              color: Colors.grey.shade500,
                              child: ListTile(
//                              leading: CircleAvatar( backgroundColor: Colors.white, child: Icon(Icons.list_alt, color: Colors.indigo, size: 30),),
                                title: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CircleAvatar( backgroundColor: Colors.white, child: Icon(Icons.list_alt, color: Colors.indigo, size: 30),),
                                      Text("Herkese Açık Sınavlar", style: TextStyle( fontFamily: "Cormorant Garamond",
                                          color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 25),
                                        textAlign: TextAlign.center,
                                      ),
                                    ]
                                ),
                                subtitle: Wrap( children: [
                                  Container(height: 280,
                                    child: AtaWidget.of(context).has_filtreSecildi != true ?
                                    Column( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Aşağıdaki butonları kullanarak tüm sınavları yada filtrelenmiş sınavları getirebilirsiniz.",
                                            style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                        Container( height: 70, color: Colors.blue.shade100,
                                          child: MaterialButton( color: Colors.blue.shade100,
                                            child: Text("Tüm Sınavlar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            onPressed: () async {
                                              has_filtresiz();
                                            },
                                          ),
                                        ),
                                        Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container( height: 50, color: Colors.blue.shade100,
                                              child:MaterialButton( color: Colors.blue.shade100,
                                                child: Text("Ders/Alan", style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () {
                                                  filtre = "ders";
                                                  AtaWidget.of(context).has_filtre = filtre;
                                                  has_filtreli();
                                                },
                                              ),
                                            ),
                                            Container( height: 50, color: Colors.blue.shade100,
                                              child: MaterialButton( color: Colors.blue.shade100,
                                                child: Text("Başlık", style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () {
                                                  filtre = "baslik";
                                                  AtaWidget.of(context).has_filtre = filtre;
                                                  has_filtreli();
                                                },
                                              ),
                                            ),
                                            Container( height: 50, color: Colors.blue.shade100,
                                              child: MaterialButton( color: Colors.blue.shade100,
                                                child: Text("Konu", style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () {
                                                  filtre = "konu";
                                                  AtaWidget.of(context).has_filtre = filtre;
                                                  has_filtreli();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container( height: 50, color: Colors.blue.shade100,
                                              child: MaterialButton( color: Colors.blue.shade100,
                                                child: Text("Bitiş Tarihi", style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () {
                                                  filtre = "bitis_tarihi";
                                                  AtaWidget.of(context).has_filtre = filtre;
                                                  has_filtreli();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                    ],
                                    ) :
                                    HerkeseAcikSinavlariGetir()
                                  ),
                                  Align(alignment: Alignment.bottomRight,
                                    child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(icon: Icon(Icons.campaign, color: Colors.white), iconSize: 30,
                                          onPressed: (){
                                            _reklam.createInterad();

                                            AlertDialog alertDialog = new AlertDialog(
                                              title: Text("BİLGİLENDİRME"),
                                              content: Container( height: 400,
                                                child: SingleChildScrollView(
                                                  physics: ClampingScrollPhysics(),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      MaterialButton(child: Text("Herkese Açık Sınavlar asistan video için Tıklayın.",
                                                        style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                        onPressed: (){
                                                          _launchIt("");
                                                        },),
                                                      Center(
                                                        child: Text("* Bu kartta görülen sınavlar hazırlayanları tarafından Sınavcım' ı kullanan herkese açılmış"
                                                            "sınavlardır.",
                                                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Center(
                                                        child: Text("* Tüm sınavlar görüntülenebilir fakat sadece hazırlayanı tarafından çözüm izni verilmiş sınavlar "
                                                            "için hazırlayana çözüm gönderilebilir.",
                                                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Sadece iletişim izni verilen sınavların hazırlayan ad/soyad ve E-mail bilgileri "
                                                              "erişime açıktır.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Herkese Açık Sınavlar ile mümkün olduğunca fazla miktarda sınav veya soruyu mümkün olduğunca "
                                                              "fazla kişiye ulaştırmak amaçlanmıştır.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("Mutlu Sınavlar...",
                                                            style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );showDialog(context: context, builder: (_) => alertDialog);
                                          },),
                                        Container( height: 60, width: 60,
                                            child: FittedBox(
                                              child: FloatingActionButton.extended(
                                                heroTag: "herkeseAçıkSinav_GrupEkle",
                                                label: Text("Grup Ekle", style: TextStyle(color: Colors.indigo),),
                                                backgroundColor: Colors.white,
                                                onPressed: () async {
                                                  _reklam.createInterad();
                                                    herkeseAcikSinavlar_grupEkle = true;;
                                                    kisilerim_grupEkle = false;
                                                    hazirladigimSinavlar_grupEkle = false;
                                                    gonderilenSinavlar_grupEkle = false;
                                                  _grupEkle();
                                                },),)),
                                        Container(height: 80, width: 80,
                                          child: FittedBox(
                                            child: FloatingActionButton.extended(
                                              heroTag: "has_alanıTemizle",
                                              onPressed: () {
                                                _reklam.createInterad();
                                                if(AtaWidget.of(context).has_grup_liste != null){
                                                  AtaWidget.of(context).has_grup_liste.clear();
                                                }
                                                has_grup_liste.clear();
                                                if(AtaWidget.of(context).has_grup_liste_id != null){
                                                  AtaWidget.of(context).has_grup_liste_id.clear();
                                                }
                                                has_grup_liste_id.clear();
                                                filtre = null;
                                                AtaWidget.of(context).has_filtre = null;
                                                herkese_acik_sinavlar.clear();
                                                herkese_acik_sinavlar_id.clear();
                                                if(AtaWidget.of(context).herkeseAcik_sinavlar !=null){
                                                  AtaWidget.of(context).herkeseAcik_sinavlar.clear();
                                                }
                                                if(AtaWidget.of(context).herkeseAcik_sinavlar_id != null){
                                                  AtaWidget.of(context).herkeseAcik_sinavlar_id.clear();
                                                }
                                                AtaWidget.of(context).has_filtreSecildi = false;
                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                                                    SinavlarKisilerPage(doc_id: doc_id, map: map, doc_avatar: doc_avatar, gonderen_secildi: gonderen_secildi,)));
                                              },
                                              backgroundColor: Colors.white,
                                              label: Text("Alanı Temizle", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),),
                                            ),
                                          ),

                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                ),
                              )

                          ),

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 320, width: 380,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim").orderBy("kullaniciadi").snapshots(),
              builder: (context, snapshot) {
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
                final querySnapshot = snapshot.data;

                return Card(
                    color: Colors.grey.shade500,
                    elevation: 2.0,
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.people, color: Colors.indigo, size: 30),),
                      title: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Kişilerim", textAlign: TextAlign.center, style: TextStyle( fontFamily: "Cormorant Garamond",
                              color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 30),
                          ),

                          IconButton(icon: Icon(Icons.outgoing_mail, size: 30, color: Colors.indigo,), tooltip: "Mesaj Gönder",
                            onPressed: (){
                              AlertDialog alertdialog = new AlertDialog(
                                title: Text("Buradan tüm kişilerinize yada tek bir kişinize mesaj gönderebilirsiniz. Kişilerim sayfanızdan "
                                    "ayrıca grup mesajı da gönderebilirsiniz. Mesajlar alıcıda bildirim şeklinde görüntülenir."
                                    " Teknik_destek/Yorum butonunu kullanarak oylama ve yorum gönderme "
                                    "penceresini açabilir ve bize mesaj gönderebilirsiniz.", textAlign: TextAlign.justify,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                content: Text("Aşağıdakilerden birini seçerek işleme devam edebilirsiniz.", textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),),
                                actions: [
                                  ElevatedButton(child: Text("Teknik_Destek/Yorum"), onPressed: (){
                                    bool oylama_yapildi;
                                    bool oylama_gosterme;
                                    int giris_sayisi;
                                    try {
                                      giris_sayisi = map["giris_sayisi"];
                                    } catch (e) {
                                      giris_sayisi = 1;
                                    }

                                    oyla_dialog(map, doc_id, oylama_yapildi, giris_sayisi, doc_avatar, oylama_gosterme);

                                  },),
                                  ElevatedButton(child: Text("Kişilerime Mesaj"), onPressed: (){
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => MesajGonder(querySnapshot: querySnapshot, gruptan: false,)));
                                  },),
                                ],
                              ); showDialog(context: context, builder: (_) => alertdialog);
                            },
                          ),

                        ],
                      ),
                      subtitle: Wrap( children: [
                        Container(height: 200,
                          child: Column(
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    AtaWidget.of(context).AllList_kisilerimden = true;
                                    AtaWidget.of(context).AllList_gonderilenSinavlarimdan = false;
                                    AtaWidget.of(context).AllList_hazirladigimSinavlarimdan = false;

                                    _reklam.showInterad();

                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                        KisilerSinavlarAllListPage(collectionReference: collectionReference_gs,
                                        storageReference: storageReference_gs, doc_id: doc_id, gruplari_getir: false, grupAdi: "")));
                                    },
                                  child: RichText(text: TextSpan(
                                      style: TextStyle(), children:<TextSpan>[
                                        TextSpan(text: "Kişileriniz harf sıralamasına göre gösterilmektedir. Tüm kişilerinizi/kişi gruplarınızı görmek için ",
                                          style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),),
                                    TextSpan(text: "  *Buraya Tıklayınız.*",
                                        style: TextStyle(color: Colors.indigo, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                  ]
                                  ), textAlign: TextAlign.justify,),
                                ),
                                SizedBox(height: 10,),
                                Flexible(
                                  child: querySnapshot.size == 0 ? Center(
                                    child: Text("Hesabınıza ekli hiç kişiniz yok.",
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                                  ) :
                                  ListView.builder(
                                      itemCount: querySnapshot.size,
                                      itemBuilder: (context, index) {
                                        final map_kisilerim = querySnapshot.docs[index].data();
                                        final id_kisilerim = querySnapshot.docs[index].id;

                                        return Column(children: [
                                          SizedBox(height: 5,),
                                          Container(
                                            color: Colors.blue.shade100,
                                            child: Visibility( visible: map_kisilerim["kullaniciadi"] == "" ? false : true,
                                              child: ListTile(
                                                title: Text( map_kisilerim["kullaniciadi"] == null ? map_kisilerim["mail"] :
                                                map_kisilerim["kullaniciadi"],
                                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                                subtitle: Text(map_kisilerim["mail"]),
                                                onTap: (){
                                                  _reklam.showInterad();

                                                  _kisiProfilineGit(id_kisilerim, map_kisilerim);
                                                  },
                                                onLongPress: (){
                                                  _reklam.createInterad();

                                                  AlertDialog alertDialog = new AlertDialog(

                                                    title: Text("Yapacağınız işlemi seçiniz: "),
                                                    content: Text("Kişi silme işleminde silinen ile yeni paylaşım yapamazsınız. Kişi silme işleminin ardından varsa "
                                                        "onunla paylaştığınız sınavları göremez, sınavlarınıza/sorularınıza cevap gönderemez. Siline kişi ile yapılan "
                                                        "eski paylaşımlar silme işleminden etkilenmez.", style: TextStyle(fontStyle: FontStyle.italic),
                                                      textAlign: TextAlign.justify,),
                                                    actions: [
                                                      ElevatedButton(
                                                        child: Text("Kişiyi Gruplandır/ Gruptan Kaldır"),
                                                        onPressed: (){
                                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                                          kisilerim_gruplandir = true;
                                                          hazirladigimSinavlar_gruplandir = false;
                                                          gonderilenSinavlar_gruplandir = false;
                                                          has_gruplandir = false;
//                                                           setState(() {});
                                                          _gruplandir(map_kisilerim, id_kisilerim);
                                                          },
                                                      ),
                                                      ElevatedButton(
                                                          child: Text("Kişiyi Sil"),
                                                          onPressed: () async {

                                                            await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar")
                                                                .where("paylasilanlar", arrayContains: map_kisilerim["kullaniciadi"]).get()
                                                                .then((value) => value.docs.forEach((element) {

                                                                  element.reference.update({"paylasilanlar": FieldValue.arrayRemove([map_kisilerim["kullaniciadi"]])});

                                                                  element.reference.collection("paylasilanlar")
                                                                      .where("kullaniciadi", isEqualTo: map_kisilerim["kullaniciadi"]).limit(1).get()
                                                                      .then((value) => value.docs.forEach((element) {element.reference.delete();
                                                                      }));
                                                                }));
                                                            await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
                                                                .doc(id_kisilerim.toString()).delete();

                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kişi başarıyla kaldırıldı")));
                                                            Navigator.of(context, rootNavigator: true).pop("dialog");
                                                          }
                                                          ),
                                                    ],
                                                  );showDialog(context: context, builder: (_) => alertDialog);
                                                  },

                                              ),
                                            ),
                                          ),
                                          Visibility( visible: map_kisilerim["kullaniciadi"] == "" ? false : true,
                                              child: Divider(height: 8,thickness: 2, color: Colors.black,))
                                        ]);
                                      }),

                                ),
                              ]
                          ),
                        ),
                        Align(alignment: Alignment.bottomRight,
                          child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(icon: Icon(Icons.campaign, color: Colors.white,), iconSize: 30,
                                onPressed: (){
                                  _reklam.createInterad();

                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("BİLGİLENDİRME"),
                                    content: Container( height: 400,
                                      child: SingleChildScrollView(
                                        physics: ClampingScrollPhysics(),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            MaterialButton(child: Text("Kişilerim asistan video için Tıklayın.", style: TextStyle(color: Colors.green),
                                              textAlign: TextAlign.center,),
                                              onPressed: (){
                                                _launchIt("https://drive.google.com/file/d/1QLqFqcey17jNQcu_KdgyknpNLNBLFkGr/view?usp=sharing");
                                              },),
                                            Center(
                                              child: Text("* Kişinin üzerine tıklayarak kişinin görülmesine izin verdiği bilgilerine ulaşabilirsiniz.",
                                                style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                            ),
                                            SizedBox(height: 10,),
                                            Center(
                                              child: Text("* Kişinin üzerine uzun tıkladığınızda *Kişiyi Sil* botonuna basarak kişiyi hesabınızdan kaldırabilir, "
                                                  "*Kişiyi Gruplandır* butonuna basarak herhangi bir kişi grubunuza ekleyebilirsiniz yada ekli grubundan kaldırabilirsiniz.",
                                                style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );showDialog(context: context, builder: (_) => alertDialog);
                                },),
                              Container( height: 60, width: 60,
                                  child: FittedBox(
                                    child: FloatingActionButton.extended(
                                      heroTag: "kisilerim_grupEkle",
                                      label: Text("Grup Ekle", style: TextStyle(color: Colors.indigo),),
                                      backgroundColor: Colors.white,
                                      onPressed: () async {
                                        _reklam.createInterad();

                                        herkeseAcikSinavlar_grupEkle = false;
                                        kisilerim_grupEkle = true;
                                        hazirladigimSinavlar_grupEkle = false;
                                        gonderilenSinavlar_grupEkle = false;

                                        _grupEkle();
                                      },),)),

                              Container(height: 80, width: 80,
                                child: FittedBox(
                                  child: FloatingActionButton.extended(
                                    heroTag: "kisiEkle",
                                    onPressed: () {
                                      _reklam.createInterad();

                                      _kisiEkle();
                                    },
                                    backgroundColor: Colors.white,
                                    icon: Icon(Icons.add, color: Colors.indigo, size: 50,),
                                    label: Text("Kişi Ekle", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                      ),
                    )

                );
              }
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container( height: 50, width: 300, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),),
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

  _sinavEkle() async {
    AlertDialog alertDialog = new AlertDialog(title: Text("DİKKAT: "),
      content: Wrap( spacing: 4, children: [
        Text("1. Resim formatındaki sınavları tek bir görsel olarak ekleyiniz. Birden fazla görseli "
            "tek bir sınav için kullanacaksanız *Sınav Oluştur* seçeneğini kullanınız. "),
        SizedBox(height: 10,),
        Text("2. Resimden farklı türde eklediğiniz (word, pdf gibi) sınavlar uygulama üzerinden gösterilmez. "
            "Sınav paylaşıldığı kişi sınava tıklayarak telefonuna indirebilir."),
        SizedBox(height: 10,),
        Text("3. Hazır Sınavlar için bir defada en fazla 10, oluşturulan sınavlardaki her bir soru için en fazla 5 mb büyüklüğünde döküman ekleyebilirsiniz."),
        SizedBox(height: 10,),
        Text("4. Hazır Sınavlar için .jpg, .jpeg, .png, .doc, .docx, .pdf uzantılı dosyaları; Oluşturulan sınavlar için ise .jpg, .jpeg, .png uzantılı dosyaları "
            "yükleyebilirsiniz."),
        ],
      ),
      actions: [
      ElevatedButton(
          child: Text("Sınav Ekle"),onPressed: () async {
            belgeEkle();
          }),
    ],);
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void belgeEkle() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile _file = result.files.first;
      final File fileForFirebase = File(_file.path);

      if (_file.extension == "jpg" || _file.extension == "jpeg" ||
          _file.extension == "png" || _file.extension == "doc" ||
          _file.extension == "docx" ||
          _file.extension == "pdf") {
        if (_file.size <= 10485760) {

          TextEditingController _baslikci = TextEditingController();
          TextEditingController _konucu = TextEditingController();
          TextEditingController _cevapci = TextEditingController();
          TextEditingController _dersci = TextEditingController();
          TextEditingController _aciklamaci = TextEditingController();
          TextEditingController _bitis_tarihci = TextEditingController();
          TextEditingController _puanci = TextEditingController();


          final _formKey = GlobalKey<FormState>();
          final _formKey_cevap = GlobalKey<FormState>();
          final _formKey_aciklama = GlobalKey<FormState>();

          Widget _uploadImageAlertDialog() {
            return Container(
              height: 500, width: 400,
              child: Column(children: [
                Form(key: _formKey,
                    child: Flexible(
                      child: ListView(children: [
                        SizedBox(height: 10,),
                        TextFormField(
                            controller: _baslikci,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Sınavınıza başlık giriniz."),
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {
                                return "başlık girmeniz gerekmektedir.";
                              }
                              return null;
                            }),
                        SizedBox(height: 10,),
                        TextFormField(
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            controller: _konucu,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Sınavınızın konusunu giriniz."),
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {
                                return "konu girmeniz gerekmektedir.";
                              }
                              return null;
                            }),
                        SizedBox(height: 10,),
                        TextFormField(
                            controller: _dersci,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Sınavınızın dersini giriniz."),
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {
                                return "ders girmeniz gerekmektedir.";
                              }
                              return null;
                            }),
                        SizedBox(height: 10,),
                        TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _puanci,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Sınavınızın puanını giriniz."),
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {
                                return "puan girmeniz gerekmektedir.";
                              }
                              return null;
                            }),
                        SizedBox(height: 10,),
                        TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _bitis_tarihci,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Sınavınızın bitis tarihini giriniz."),
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {
                                return "bitiş tarihi girmeniz gerekmektedir.";
                              }
                              return null;
                            }),
                        SizedBox(height: 10,),
                        Form(key: _formKey_cevap,
                          child: TextFormField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: _cevapci,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Sınavınıza cevap linkini yada metnini girebilirsiniz."),
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 15),
                              validator: (String PicName) {
                                if (PicName.isEmpty) {
                                  return "Cevap linki/metni girilmeyecektir.";
                                }
                                return null;
                              }),
                        ),
                        SizedBox(height: 10,),
                        Form(key: _formKey_aciklama,
                          child: TextFormField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: _aciklamaci,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Sınavınız için açıklama girebilirsiniz."),
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 15),
                              validator: (String PicName) {
                                if (PicName.isEmpty) {
                                  return "Açıklama girilmeyecektir.";
                                }
                                return null;
                              }),
                        ),
                      ]),
                    )),
                SizedBox(height: 10,),
                Text(
                  "**Dökümanın yüklenme süresi boyutuna ve internet hızınıza bağlıdır.**",
                  style: TextStyle(fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ]),
            );
          }

          showDialog(context: context, builder: (_) {
            return AlertDialog(
              title: Text(_file.name + "." + _file.extension +
                  " isimli dosya yüklenecektir."),
              content: _uploadImageAlertDialog(),
              actions: [
                GestureDetector(onDoubleTap: () {},
                  child: ElevatedButton(
                    child: Text("Yükle"),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        _formKey_cevap.currentState.save();
                        _formKey_aciklama.currentState.save();
                        imageFileName = _baslikci.text;
                        final newkonu = _konucu.text;
                        final newcevap = _cevapci.text.trim();
                        final newaciklama = _aciklamaci.text;
                        final new_bitis_tarihi = _bitis_tarihci.text.trim();
                        final newders = _dersci.text.trim();
                        String _puan = _puanci.text.trim();
                        int puan = int.parse(_puan);
                        List <String> paylasilanlar = [];
                        List <String> paylasilan_gruplar = [];

                        final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                            .child("sinavlar").child("hazir_sinavlar").child(imageFileName).child("sınav_gorseli  " + imageFileName);

                        await ref.putFile(fileForFirebase);
                        var downloadUrl = await ref.getDownloadURL();
                        String url = downloadUrl.toString();

                        await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").add({"olusturulanmi": false,
                          "aciklama": newaciklama, "bitis_tarihi": new_bitis_tarihi, "gorsel": url, "eklendigi_grup": "", "konu": newkonu,
                          "tarih": DateTime.now().toString(), "gorsel_cevap": "", "grup_adi": "", "grupAciklamasi": "", "baslik": imageFileName,
                          "metinsel_cevap": newcevap, "kilitli": true, "ders": newders, "hazirlayan": AtaWidget.of(context).kullaniciadi,
                          "paylasilanlar": paylasilanlar, "paylasilan_gruplar": paylasilan_gruplar, "puan": puan
                        });


//                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Sınav başarıyla eklendi"),
                          duration: Duration(seconds: 5),));
                        Navigator.of(context, rootNavigator: true).pop(
                            'dialog');
                        Navigator.of(context, rootNavigator: true).pop(
                            'dialog');
                      } else {}
                    },
                  ),
                ),
              ],
            );
          });

      } else {
        AlertDialog alertDialog = new AlertDialog (
          title: Text("Dosya çok büyük. En fazla 10 mb büyüklüğünde dosya seçiniz.", style: TextStyle(color: Colors.red,
                  fontSize: 20, fontWeight: FontWeight.bold)),
        );
        showDialog(context: context, builder: (_) => alertDialog);
      }
    } else {
      AlertDialog alertDialog = new AlertDialog (
        title: Text("Yanlış uzantılı bir dosya seçtiniz. Lütfen .jpg, .jpeg, .png, .doc, .docx, .pdf uzantıya sahip bir dosya seçiniz.",
            style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
      );
      showDialog(context: context, builder: (_) => alertDialog);
    }
    } else {
      // User canceled the picker
    }
  }

  //**** SINAVA GÖRSEL CEVAP GETİRME****
  Future imageFromGallery(dynamic map_sinav, dynamic id_sinav) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    _imageSelected = image;
//    setState(() {});
    uploadImage(map_sinav, id_sinav);

  }

  //**** SINAVA GÖRSEL CEVAP EKLEME****
  void uploadImage(dynamic map_sinav,dynamic id_sinav) async {

    Widget _uploadImageAlertDialog() {
      return Container(
        height: 500, width: 400,
        child: Column(children: [
          Flexible(
            child: Container(
                child: _imageSelected == null
                    ? Center(
                    child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ))
                    : Image.file(_imageSelected, fit: BoxFit.contain,
                )),
          ),
          SizedBox(height: 20,),
          Text("**Resmin yüklenme süresi boyutuna ve internet hızınıza bağlıdır.**",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
            textAlign: TextAlign.center,
          ),
        ]),
      );
    }

    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text("Resim Yükleme", style: TextStyle(color: Colors.green),
        ),
        content: _uploadImageAlertDialog(),
        actions: [
          GestureDetector(onDoubleTap: (){},
            child: ElevatedButton(
              child: Text("Yükle"),
              onPressed: () async {
                if (_imageSelected == null) {return null;
                } else {
                    if(map_sinav["olusturulanmi"] == true) {
                      final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                          .child("sinavlar").child("olusturulan_sinavlar").child(map_sinav["baslik"]).child("sınavın cevap gorseli_"+map_sinav["baslik"]);

                      await ref.putFile(_imageSelected);
                      var downloadUrl = await ref.getDownloadURL();
                      String url = downloadUrl.toString();

                      await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                          .update({"gorsel_cevap": url, "metinsel_cevap": ""});
                    }
                    else {
                      final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                          .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"]).child("sınavın cevap gorseli_"+map_sinav["baslik"]);

                      await ref.putFile(_imageSelected);
                      var downloadUrl = await ref.getDownloadURL();
                      String url = downloadUrl.toString();

                      await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                          .update({"gorsel_cevap": url, "metinsel_cevap": ""});
                    }


                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevap başarıyla eklendi"), action: SnackBarAction(
                        label: "Gizle", onPressed: () { SnackBarClosedReason.hide; }),));
                    Navigator.of(context, rootNavigator: true).pop('dialog');

                }
              },
            ),
          ),
        ],
      );
    });
  }

  _sinaviGor(dynamic map_sinav, dynamic id_sinav, String _doc_baslik, String _doc_gorsel, String _doc_aciklama, String _doc_id, int _doc_puan) async {
    Widget SetUpAlertDialogContainer() {
      return Container(
        height: 500, width: 500,
        child: Image.network(map_sinav["gorsel"], fit: BoxFit.fill,
          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
            return Center(
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Text("Bu sınavda her hangi bir görsel bulunamamıştır. Resim formatında olmayan sınavlar uygulamada gösterilmez. *Sınava Git* butonu ile tarayıcınız "
                      "ile sınavı indirip çözebilir, *Cevabını Gönder* butonunu kullanarak çözümünüzü gönderebilirsiniz.",
                      style: TextStyle(color: Colors.lightBlue, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 20,),
                  Text("*Sınava Git* butonu ile herhangi bir indirme olmuyorsa sınav sisteme yüklenmemiş yada başka bir sorun yaşanmış olabilir.",
                    style: TextStyle(color: Colors.orange,)),
                ],
              ),
            );
          },
        ),
      );
    }
    showDialog(context: context, builder: (_) {
          return AlertDialog(
            backgroundColor: Color(0xAA304030),
            title: ListTile(
              title: RichText(textAlign: TextAlign.center,
                  text: TextSpan(style: TextStyle(),
                      children: <TextSpan>[
                        TextSpan(text: "Başlık:  "),
                        TextSpan(text: map_sinav["baslik"].toString().toUpperCase(),
                          style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic, fontSize: 20),
                        )
                      ]
                  )),
              subtitle: RichText(textAlign: TextAlign.center,
                  text: TextSpan(style: TextStyle(),
                      children: <TextSpan>[
                        TextSpan(text: "Konu: "),
                        TextSpan(text: map_sinav["konu"],
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic, fontSize: 15),
                        )
                      ]
                  )),
              trailing: Builder(
                builder: (context)=> IconButton( color: Colors.white,
                  tooltip: map_sinav["kilitli"] == true ? "Cevap kilitlidir." : "Cevap kilidi açılmıştır.",
                  icon: map_sinav["kilitli"] == true ? Icon(Icons.lock): Icon(Icons.lock_open),
                  onPressed: ()async{
                  print(id_sinav.toString());
                    if(AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"]){
                      map_sinav["kilitli"] == true ?
                          await collectionReference_hs.doc(id_sinav.toString()).update({"kilitli" : false})
                          : await collectionReference_hs.doc(id_sinav.toString()).update({"kilitli" : true});
                      Navigator.of(context, rootNavigator: true).pop("dialog");
                    } else {
                      AlertDialog alertDialog = new AlertDialog(title: Text("Hata: "),
                        content: Text(" İşlemi yapmaya yetkiniz yok."),);
                      showDialog(context: context, builder: (_) => alertDialog);
                    }
                  },
                ),
              ),
            ),
            content: SetUpAlertDialogContainer(),
            actions: [

              Center(child: Wrap(spacing: 4, children: [
                    ElevatedButton(
                        child: Text("Sınava Git"),
                        onPressed: () {
                          _launchIt(map_sinav["gorsel"]);

                          Navigator.of(context, rootNavigator: true).pop('dialog');
                        }),
                Visibility(visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? true : false, child: SizedBox(width: 20,)),
                Visibility( visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? true : false,
                  child: ElevatedButton(
                      child: Text("Gönderilen Cevaplar"),
                      onPressed: () {
                        dynamic mapSoru; dynamic idSoru;
                        AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar = false;
                        AtaWidget.of(context).hazirSinav_gonderilenCevaplar = true;
                        AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar = false;
                        AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler = false;

                        Navigator.of(context, rootNavigator: true).pop('dialog');
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          GonderilenCevaplarPage(map_cevaplanan: map_sinav, id_cevaplanan: id_sinav,
                            collectionReference: collectionReference_hs, storageReference: storageReference_hs, mapSoru: mapSoru,
                            idSoru: idSoru,)));
                      }),
                ),
                Visibility(visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? true : map_sinav["kilitli"] == false ? true : false,
                    child: SizedBox(width: 20,)),
                Visibility( visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? true
                    : map_sinav["kilitli"] == false ? true : false,
                  child: ElevatedButton(
                      child: Text("Cevabı Gör"),
                      onPressed: () {
                        map_sinav["gorsel_cevap"] == null || map_sinav["gorsel_cevap"] == " " || map_sinav["gorsel_cevap"] == "" ?
                        _metinselCevapGoster(map_sinav) : _launchIt(map_sinav["gorsel_cevap"]);

                      }),
                ),
                Visibility( visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? false : true,
                  child: Visibility( visible: map_sinav["kilitli"] == true ? true : false,
                      child: Visibility( visible: _doc_baslik == null ? true : false,
                          child: SizedBox(width: 20,))),
                ),
                Visibility( visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? false : true,
                  child: Visibility( visible: map_sinav["kilitli"] == true ? true : false,
                    child: Visibility( visible: _doc_baslik == null ? true : false,
                      child: ElevatedButton(
                          child: Text("Cevabını Gönder"),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor..."),
                              action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                            ogrenci_cevapEkle(id_sinav, map_sinav);
                          }),
                        ),
                  ),
                ),
                Visibility( visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? false : true,
                  child: Visibility( visible: _doc_baslik != null ? true : false,
                    child: ElevatedButton(
                        child: Text("Kendi Cevabını Gör"),
                        onPressed: () {
                          ogrenci_CevabiniGor(map_sinav, id_sinav, _doc_baslik, _doc_gorsel, _doc_aciklama, _doc_id, _doc_puan);
                        }),
                  ),
                ),
              ],
              ),
              ),

            ],
          );
        });

  }

  void _metinselCevapGoster(dynamic map_sinav) async {
    Widget SetUpAlertDialogContainer() {
      return Container(height: 350, width: 400,
        child: Center(child: Text(map_sinav["metinsel_cevap"], style: TextStyle(color: Colors.white, ),),),
      );
    }

    showDialog(context: context, builder: (_) {
      return AlertDialog(backgroundColor: Color(0xAA304030),
        title: Center(
            child: Text("*Sınavın çözümü link olarak verilmişse tarayıcıda da açabilirsiniz.",
              style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic, fontSize: 15),
              textAlign: TextAlign.justify,
            )),
        content: map_sinav["gorsel_cevap"] == "" && map_sinav["metinsel_cevap"] == "" ? Text("CEVAP DAHA EKLENMEMİŞTİR !",
          style: TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.bold),)
            : SetUpAlertDialogContainer(),
        actions: [
          ElevatedButton(child: Text("Tarayıcıda Aç"),
              onPressed: () {_launchIt(map_sinav["metinsel_cevap"]);
              })
        ],
      );
    });
  }

  void _sinaviDuzenle(dynamic map_sinav, dynamic id_sinav) async {

    final _formKey_konu = GlobalKey<FormState>();
    final _formKey_aciklama = GlobalKey<FormState>();
    final _formKey_bitis_tarihi = GlobalKey<FormState>();
    final _formKey_cevap = GlobalKey<FormState>();
    final _formKey_ders = GlobalKey<FormState>();


    TextEditingController _konucu = TextEditingController();
    TextEditingController _cevapci = TextEditingController();
    TextEditingController _dersci = TextEditingController();
    TextEditingController _aciklamaci = TextEditingController();
    TextEditingController _bitis_tarihci = TextEditingController();


    final _formKey = GlobalKey<FormState>();

    Widget _uploadImageAlertDialog() {
      return Container(height: 300, width: 400,
        child: Column(
            children: [
              Form(key: _formKey,
                  child: Flexible(
                    child: ListView(
                        children: [Center(
                          child: Text("Değişmesini istediğiniz alanlara yeni verileri yazınız ve onay butonuna"
                              " tıklayınız. Yeni veri girmediğiniz alanlar aynen kalacaktır. Sınavın başlığı "
                              "değiştirilemez. Düzenleme işlemeini sonlandrmak için *Onay* butonuna basınız.",
                            style: TextStyle(color: Colors.red, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                          SizedBox(height: 10,),
                          Form(key: _formKey_ders,
                            child: TextFormField(
                                controller: _dersci,
                                decoration: InputDecoration(border: OutlineInputBorder(),
                                    labelText: "Sınavınızın dersini giriniz."),
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                validator: (String PicName) {
                                  if (PicName.isEmpty) {return "Alan değişmeyecektir.";
                                  } return null;
                                }),
                          ),
                          SizedBox(height: 10,),
                          Form(key: _formKey_konu,
                            child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: _konucu,
                                decoration: InputDecoration(border: OutlineInputBorder(),
                                    labelText: "Sınavınızın konusunu giriniz."),
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                validator: (String PicName) {
                                  if (PicName.isEmpty) {return "Alan değişmeyecektir.";
                                  } return null;
                                }),
                          ),
                          SizedBox(height: 10,),
                          Form(key: _formKey_aciklama,
                            child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: _aciklamaci,
                                decoration: InputDecoration(border: OutlineInputBorder(),
                                    labelText: "Sınavınıza açıklama giriniz."),
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                validator: (String PicName) {
                                  if (PicName.isEmpty) {return "Alan değişmeyecektir.";
                                  } return null;
                                }),
                          ),
                          SizedBox(height: 10,),
                          Form(key: _formKey_bitis_tarihi,
                            child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _bitis_tarihci,
                                decoration: InputDecoration(border: OutlineInputBorder(),
                                    labelText: "Sınavınızın bitiş tarihini giriniz."),
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                validator: (String PicName) {
                                  if (PicName.isEmpty) {return "Alan değişmeyecektir.";
                                  } return null;
                                }),
                          ),
                          SizedBox(height: 10,),
                          Form(key: _formKey_cevap,
                            child: GestureDetector(
                              onDoubleTap: (){
                                AlertDialog alertDialog = new AlertDialog(
                                  content: Text(_cevapci.text),
                                ); showDialog(context: context, builder: (_) => alertDialog);
                              },
                              child: TextFormField(
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  controller: _cevapci,
                                  decoration: InputDecoration(border: OutlineInputBorder(),
                                      labelText: "Cevap metni yada linki giriniz."),
                                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                  validator: (String PicName) {
                                    if (PicName.isEmpty) {return "Alan değişmeyecektir.";
                                    } return null;
                                  }),
                            ),
                          ),
                          SizedBox(height: 15,),
                          GestureDetector(
                            child: Text(" Cevabı anahtarını resim olarak eklemek için tıklayınız.",
                              style: TextStyle(fontStyle: FontStyle.italic,
                                  color: Colors.blueGrey),),
                            onTap: (){
                              imageFromGallery(map_sinav, id_sinav);
                            },),
                          SizedBox(height: 15,),
                          GestureDetector(
                            child: Text(" Cevabı anahtarını belge olarak eklemek için tıklayınız.",
                              style: TextStyle(fontStyle: FontStyle.italic,
                                  color: Colors.blueGrey),),

                            onTap: () async {
                              FilePickerResult result = await FilePicker.platform.pickFiles();
                              if(result != null) {
                                PlatformFile _file = result.files.first;
                                final File fileForFirebase = File(_file.path);

                                if (_file.extension == "jpg" || _file.extension == "jpeg" ||
                                    _file.extension == "png" || _file.extension == "doc" ||
                                    _file.extension == "docx" ||
                                    _file.extension == "pdf") {
                                  if (_file.size <= 10485760) {

                                    AlertDialog alertDialog = new AlertDialog (
                                      title: Text(map_sinav["baslik"] + " için aşağıdaki belge cevap olarak "
                                          "yüklenecektir.", style: TextStyle( color: Colors.lightGreen,
                                          fontSize: 15, fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),),
                                      content: Text(_file.name+"."+ _file.extension),
                                      actions: [
                                        ElevatedButton(
                                          child: Text("Yükle"),
                                          onPressed: () async {
                                            if (map_sinav["olusturulanmi"] == true) {
                                              final Reference ref = await FirebaseStorage.instance.ref()
                                                  .child("users").child(AtaWidget.of(context).kullaniciadi)
                                                  .child("sinavlar").child("olusturulan_sinavlar").child(map_sinav["baslik"])
                                                  .child("Sınavın cevap_belgesi "+map_sinav["baslik"]);

                                              await ref.putFile(fileForFirebase);
                                              var downloadUrl = await ref.getDownloadURL();
                                              String url = downloadUrl.toString();

                                              await FirebaseFirestore.instance.collection("users")
                                                  .doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                                  .update({"gorsel_cevap": url, "metinsel_cevap": ""});

//                                              setState(() {});
                                              Navigator.of(context, rootNavigator: true).pop("dialog");
                                            }
                                            else {
                                              final Reference ref = await FirebaseStorage.instance.ref()
                                                  .child("users").child(AtaWidget.of(context).kullaniciadi)
                                                  .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"])
                                                  .child("cevap_belgesi  "+map_sinav["baslik"]);

                                              await ref.putFile(fileForFirebase);
                                              var downloadUrl = await ref.getDownloadURL();
                                              String url = downloadUrl.toString();

                                              await FirebaseFirestore.instance.collection("users")
                                                  .doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                                  .update({"gorsel_cevap": url, "metinsel_cevap": ""});

//                                              setState(() {});
                                              Navigator.of(context, rootNavigator: true).pop("dialog");
                                            }
                                          },
                                        )
                                      ],
                                    );
                                    showDialog(context: context, builder: (_) => alertDialog);

                                  } else {
                                    AlertDialog alertDialog = new AlertDialog (
                                      title: Text("Dosya çok büyük. En fazla 10 mb büyüklüğünde dosya seçiniz.", style: TextStyle(color: Colors.red,
                                          fontSize: 20, fontWeight: FontWeight.bold)),
                                    );
                                    showDialog(context: context, builder: (_) => alertDialog);
                                  }
                                } else {
                                  AlertDialog alertDialog = new AlertDialog (
                                    title: Text("Yanlış uzantılı bir dosya seçtiniz. Lütfen .jpg, .jpeg, .png, .doc, .docx, .pdf uzantıya sahip bir dosya seçiniz.",
                                        style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                                  );
                                  showDialog(context: context, builder: (_) => alertDialog);
                                }


                              }
                            },),
                          SizedBox(height: 12,),
                        ]),
                  )),
            ]),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Center(
          child: Text("${map_sinav["baslik"]} Düzenleme",
            style: TextStyle(color: Colors.green),
          ),
        ),
        content: _uploadImageAlertDialog(),
        actions: [
          MaterialButton(
            child: Text("Sınavı Gruplandır/ Gruptan Kaldır", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline, decorationThickness: 2, decorationColor: Colors.indigo)),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("dialog");
              kisilerim_gruplandir = false;
              hazirladigimSinavlar_gruplandir = true;
              gonderilenSinavlar_gruplandir = false;
              has_gruplandir = false;

//              setState(() {});
              _gruplandir(map_sinav, id_sinav);
            },

          ),

          GestureDetector(onDoubleTap: (){},
            child: ElevatedButton(
                child: Text("Onay"),
                onPressed: () async {

                  if (_formKey_konu.currentState.validate()) {
                    _formKey_konu.currentState.save();
                    String newkonu = _konucu.text;

                    await collectionReference_hs.doc(id_sinav.toString()).update({"konu": newkonu,});
                  } else {}

                  if (_formKey_aciklama.currentState.validate()) {
                    _formKey_aciklama.currentState.save();
                    final newaciklama = _aciklamaci.text;

                    await collectionReference_hs.doc(id_sinav.toString()).update({"aciklama": newaciklama,});
                  } else {}

                  if (_formKey_bitis_tarihi.currentState.validate()) {
                    _formKey_bitis_tarihi.currentState.save();
                    final newtarih = _bitis_tarihci.text.trim();

                    await collectionReference_hs.doc(id_sinav.toString()).update({"bitis_tarihi": newtarih,});
                  } else {}

                  if (_formKey_ders.currentState.validate()) {
                    _formKey_ders.currentState.save();
                    final newders = _dersci.text.trim();

                    await collectionReference_hs.doc(id_sinav.toString()).update({"ders": newders,});
                  } else {}

                  if (_formKey_cevap.currentState.validate()) {
                    _formKey_cevap.currentState.save();
                    final newcevap = _cevapci.text.trim();

                    await collectionReference_hs.doc(id_sinav.toString()).update({
                      "metinsel_cevap": newcevap, "gorsel_cevap": ""});
                    try {
                      final Reference ref = await FirebaseStorage.instance.ref()
                          .child("users").child(AtaWidget.of(context).kullaniciadi)
                          .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"])
                          .child("cevap_belgesi  "+map_sinav["baslik"]);
                      await ref.delete();
                    } catch (e) {print(e.toString());}
                    try {
                      final Reference _ref = await FirebaseStorage.instance.ref()
                          .child("users").child(AtaWidget.of(context).kullaniciadi)
                          .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"])
                          .child("cevap_gorseli  "+map_sinav["baslik"]);
                      await _ref.delete();
                    } catch (e) {print(e.toString());}

                  } else {}

//                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Değişiklikler kaydedilmiştir."),));
                  Navigator.of(context, rootNavigator: true).pop("dialog");

                }),
          ),
        ],
      );
    });
  }

  Future ogrenci_cevapEkle(dynamic id_sinav, dynamic map_sinav) async {
    AlertDialog alertDialog = new AlertDialog (
      title: Text("Bilgiledirme: ", style: TextStyle(color: Colors.green)),
      content: Text("*Anladım* butonuna bastığınızda otomatik olarak galerinizden resim seçmeye yönlendirileceksiniz. Resim seçmeden çözümünüzü sadece metin girerek "
          "açıklamayı tercih edebilirsiniz. Matematik gibi işlemlerin olduğu dersler için çözümünüzün resmini eklemenizi öneririz. Test sorularında şıkkı işaretlemek "
          "için *Şıkları Gör* butonunu tıklayınız"
        , textAlign: TextAlign.justify,),
      actions: [
        MaterialButton(
            child: Text("Anladım", style: TextStyle(color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.black,),),
            onPressed: ()async {
              Navigator.of(context, rootNavigator: true).pop("dialog");
              var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
              _imageSelected = image;

//              setState(() {});
              ogrenci_cevapGonder(id_sinav, map_sinav);
            })
      ],
    );showDialog(context: context, builder: (_) => alertDialog);
  }

  void ogrenci_cevapGonder(dynamic id_sinav, dynamic map_sinav) async {
    TextEditingController _baslikci = TextEditingController();
    TextEditingController _aciklamaci = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    Widget _uploadImageAlertDialog() {
      return Container(
        height: 300, width: 400,
        child: Column(children: [
          Flexible(
            child: GestureDetector(
              onTap: (){
                Widget SetUpAlertDialogContainer() {
                  return Container(
                      height: 500, width: 500,
                      child: Image.file(_imageSelected, fit: BoxFit.fill,)
                  );
                }
                showDialog(context: context, builder: (_) => AlertDialog(
                  content: SetUpAlertDialogContainer(),
                ));
              },
              child: Container(
                  child: _imageSelected == null ? Center(
                      child: Text("Resim seçilmedi. Cevabınıza görsel eklenmeyecektir.",
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ))
                      : Image.file(_imageSelected, fit: BoxFit.contain,
                  )),
            ),
          ),
          Form(key: _formKey,
              child: Flexible(
                child: ListView(children: [
                  SizedBox(height: 10,),
                  TextFormField(
                      controller: _baslikci,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Cevabınız için başlık giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "başlık girmeniz gerekmektedir.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  GestureDetector(
                    onDoubleTap: (){
                      Widget SetUpAlertDialogContainer() {
                        return Container(
                          height: 500, width: 500,
                          child: Center(
                              child: Text(_aciklamaci.text.trim(), textAlign: TextAlign.justify,
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontStyle: FontStyle.italic))),
                        );
                      }
                      showDialog(context: context, builder: (_) => AlertDialog(
                        backgroundColor: Color(0xAA304030),
                        content: SetUpAlertDialogContainer(),
                      ));
                    },
                    child: TextFormField(
                        controller: _aciklamaci,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Çözümünüzü açıklayınız."),
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                        validator: (String PicName) {
                          if (PicName.isEmpty) {return "Alan boş bırakılamaz.";
                          } return null;
                        }),
                  ),

                ]),
              )),
          GestureDetector(
            onTap: (){

              AlertDialog alertDialog = new AlertDialog(title: Column(children: [
                Visibility(visible: _imageSelected == null ? false: true, child: SizedBox(height: 10,)),
                Visibility(visible: _imageSelected == null ? false: true,
                  child: Text("* Görselin yüklenme süresi boyutuna ve internet hızınıza bağlıdır. Bir defada sadece tek bir görsel yükleyebilirsiniz. *",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.black),
                    textAlign: TextAlign.center,),
                ),
                SizedBox(height: 10,),
                Visibility(visible: _imageSelected == null ? false: true,
                  child: Text("*Görselinizi daha büyük görmek için üzerine çift tıklayınız.*",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.black),
                    textAlign: TextAlign.center,),
                ),
                SizedBox(height: 10,),
                Text("** Açıklamanızı daha büyük görmek için üzerine çift tıklayınız.**",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.black),
                  textAlign: TextAlign.center,),
                SizedBox(height: 10,),
                Text("*** Cevaplama işleminin tek bir yükleme ile tamamlanması tavsiye edilir. Bir soru için birden fazla yükleme yapacaksanız başlık kısmında "
                    "numaralandırma yapabilir ve bunu açıklama kısmında belirtebilirsiniz.***",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.black),
                  textAlign: TextAlign.center,),
              ]), );
              showDialog(context: context, builder: (_)=> alertDialog);

            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 10),
              child: RichText(text: TextSpan(
                  style: TextStyle(),
                  children: <TextSpan>[
                    TextSpan(text: "*Önemli bilgilendirmeleri görmek için ",
                        style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
                    TextSpan(text: " Buraya tıklayınız. ", style: TextStyle(color: Colors.indigo,
                        fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                  ]
              )),
            ),
          ),

        ]),
      );
    }

    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text("Cevabını Yükle", style: TextStyle(color: Colors.green),
        ),
        content: _uploadImageAlertDialog(),
        actions: [
          Builder(
            builder: (context)=> GestureDetector(onDoubleTap: (){},
              child: RaisedButton(
                child: Text("Yükle"), color: Colors.green,
                onPressed: () async {

                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    final baslik = _baslikci.text;
                    final newaciklama = _aciklamaci.text;
                    final cevaplayan = AtaWidget.of(context).kullaniciadi;

                    if(_imageSelected != null){
                      final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).sinavGonderen_kullaniciadi)
                          .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"])
                          .child("cevaplayanlarin_gorselleri").child(baslik + "_" + cevaplayan);

                      await ref.putFile(_imageSelected);
                      var downloadUrl = await ref.getDownloadURL();
                      String url = downloadUrl.toString();

                      final DocumentReference _ref = await collectionReference_gs.doc(id_sinav.toString()).collection("soruyu_cevaplayanlar").add(
                          {"gorsel": url, "baslik": baslik, "aciklama": newaciklama, "tarih": DateTime.now().toString(), "cevaplayan": cevaplayan, "puan": -1});
                      soruyu_cevaplayan_id = _ref.id.toString();

                    } else {
                      await collectionReference_gs.doc(id_sinav.toString()).collection("soruyu_cevaplayanlar").add(
                          {"gorsel": "", "baslik": baslik, "aciklama": newaciklama, "tarih": DateTime.now().toString(), "cevaplayan": cevaplayan, "puan": -1});

                    }

//                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevabınız başarıyla gönderildi"),
                      action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  }
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  void ogrenci_CevabiniGor(dynamic map_sinav, dynamic id_sinav, String _doc_baslik, String _doc_gorsel, String _doc_aciklama, String _doc_id, int _doc_puan) async {
    Widget SetUpAlertDialogContainer() {
      return Container(
          height: _doc_gorsel == null || _doc_gorsel == "" || _doc_gorsel == " " ? 50 : 350, width: 350,
          child: FittedBox(
            child: Image.network(_doc_gorsel, fit: BoxFit.fill,
              errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                return Center(child: Text("Çözümünüze ait her hangi bir görsele ulaşılamamıştır.",
                  style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),),);},),
          )
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(backgroundColor: Color(0xAA304030),
        title: Center(
            child: Text(map_sinav["baslik"] + " için çözümünüz: ", textAlign: TextAlign.center,
              style: TextStyle(color: Colors.lightGreen, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            )),
        content: Container(
          child: SingleChildScrollView( physics: ClampingScrollPhysics(),
            child: Column( mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SetUpAlertDialogContainer(),
                  SizedBox(height: 20,),
                  ListTile(
                    title: RichText(text: TextSpan(
                        style: TextStyle(),
                        children: <TextSpan>[
                          TextSpan(text: "Başlık:  ",
                              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15, fontWeight: FontWeight.w600)),
                          TextSpan(text: _doc_baslik, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18,
                              fontStyle: FontStyle.italic),),
                        ]
                    )),
                    subtitle: RichText(text: TextSpan(
                        style: TextStyle(),
                        children: <TextSpan>[
                          TextSpan(text: "Açıklama:  ",
                              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15, fontWeight: FontWeight.w600)),
                          TextSpan(text: _doc_aciklama, style: TextStyle(color: Colors.white, fontSize: 12),),
                        ]
                    )),

                  ),

                ]
            ),
          ),
        ),
        actions: [
          Visibility( visible: map_sinav["kilitli"] == true ? false : _doc_puan == null || _doc_puan == -1 ? false : true,
            child: RichText(text: TextSpan(
              style: TextStyle(), children: <TextSpan> [
                TextSpan(text: "Puanınız: ", style: TextStyle(color: Colors.lightBlueAccent, fontSize: 13)),
                TextSpan(text: _doc_puan.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ]
            ),),
          ),
          SizedBox(width: 20,),
          Visibility( visible: _doc_gorsel == "" || _doc_gorsel == " " || _doc_gorsel == null ? false: true,
            child: RaisedButton(color: Colors.blueAccent, child: Text("Görseli Aç"),
                onPressed: () {_launchIt(_doc_gorsel);
                }),
          ),
          ElevatedButton(
            child: Text("Cevabını Sil"),
            onPressed: () async {
              collectionReference_gs.doc(id_sinav).collection("soruyu_cevaplayanlar")
                  .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                  .get().then((QuerySnapshot querySnapshot)=>{
                querySnapshot.docs.forEach((_doc) async {

                  collectionReference_gs.doc(id_sinav).collection("soruyu_cevaplayanlar").doc(_doc.id.toString()).delete();

                  try{
                    final Reference ref = await FirebaseStorage.instance.ref().child("users").child(map_sinav["hazirlayan"])
                        .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"]).child("cevaplayanlarin_gorselleri")
                        .child(_doc["baslik"] + "_" + AtaWidget.of(context).kullaniciadi);
                    await ref.delete();
                  } catch (e) { print(e.toString());}

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),));
                  Navigator.of(context, rootNavigator: true).pop("dialog");
                  Navigator.of(context, rootNavigator: true).pop("dialog");

                })
              });
            },
          )
        ],
      );
    });
  }

  void _sinaviPaylas(dynamic map_sinav, dynamic id_sinav, var paylasilanlar, ) async {
    String paylasilan_uid;  bool kisi_pasif;  String kisi_mail;   List<dynamic> paylasilanKisi_pasifler = [];

    Widget setupAlertDialogContainer() {
      return Container(
        height: 300, width: 300,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim").snapshots(),
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
                    final map_kisilerim = _querySnapshot.docs[index].data();
                    final id_kisilerim = _querySnapshot.docs[index].id;

                    return Column(
                      children: [
                        Dismissible( key: Key(_querySnapshot.docs[index].id),
                          onDismissed: (direction) async {
                            await FirebaseFirestore.instance.collection("users").where("kullaniciadi", isEqualTo: map_kisilerim["kullaniciadi"])
                                .get().then((value) => value.docs.forEach((element) {
                                  paylasilan_uid = element.id.toString();
                            }));

                            await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                .collection("paylasilanlar").where("kullaniciadi", isEqualTo: map_kisilerim["kullaniciadi"]).limit(1)
                                .get().then((QuerySnapshot querySnapshot)=>{
                              querySnapshot.docs.forEach((_doc) async {
                                _doc.reference.delete();

                                paylasilanlar.remove(map_kisilerim["kullaniciadi"]);

                                await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                    .update({"paylasilanlar" : paylasilanlar});

//                                setState(() {});
                              })
                            });
                          },
                          child: Visibility( visible: map_kisilerim["kullaniciadi"] == "" ? false : true,
                            child: ListTile(
                              title: Text(map_kisilerim["kullaniciadi"] ),
                              subtitle: Text(map_kisilerim["mail"]),
                              onTap: () async {
                                await FirebaseFirestore.instance.collection("users").where("kullaniciadi", isEqualTo: map_kisilerim["kullaniciadi"])
                                    .get().then((value) => value.docs.forEach((element) {
                                  paylasilan_uid = element.id.toString();

                                  print(element.data()["pasiflestirildi"].toString().toUpperCase());

                                  kisi_pasif = element.data()["pasiflestirildi"];
                                  kisi_mail = element.data()["mail"];

                                }));

                                if(paylasilanlar.contains(map_kisilerim["kullaniciadi"]) ){
                                  AlertDialog alertDialog = new AlertDialog (
                                    title: Text("Sınav zaten kişi ile paylaşılmış. Silmek için kişiyi yana kaydırın.",
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                } else {

                                  if (kisi_pasif == true) {
                                    AlertDialog alertdialog = new AlertDialog(
                                      title: Text("Bu kullanıcı hesabını pasifleştirdiği için onunla herhangi bir paylaşımda bulunamazsınız.",
                                        style: TextStyle(color: Colors.red)
                                      )
                                    ); showDialog(context: context, builder: (_) => alertdialog);
                                    
                                    await FirebaseFirestore.instance.collection("paylasilanKisi_pasifler").add({
                                      "paylasan_mail" : AtaWidget.of(context).kullanicimail, "paylasilan_mail": kisi_mail, "paylasim": map_sinav["baslik"],
                                      "tarih": DateTime.now().toString().substring(0, 16)
                                    });

//                                    pasifeOtomatikMail( kisi_mail );

                                  } else {
                                    await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar")
                                        .doc(id_sinav.toString()).collection("paylasilanlar")
                                        .add({ "kullaniciadi": map_kisilerim["kullaniciadi"], "mail": map_kisilerim["mail"], "eklendigi_grup":"" });

                                    paylasilanlar.add(map_kisilerim["kullaniciadi"]);

                                    await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                        .update({"paylasilanlar" : paylasilanlar});

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sınav başarıyla paylaşıldı")));
                                  }

                                }

                              },
                              trailing: paylasilanlar.contains(map_kisilerim["kullaniciadi"]) ? Icon(Icons.check_circle) : SizedBox.shrink(),
                            ),
                          ),
                        ),
                        Visibility(visible: map_kisilerim["kullaniciadi"] == "" ? false : true,
                            child: Divider(thickness: 3, color: Colors.indigo)),
                      ],
                    );
                  });
            }),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Wrap(
            children: [
              Text("Sınavı Paylaş", style: TextStyle(color: Colors.green),),
              Wrap(
                children: [
                  Text("* Tüm kişileriniz gösterilmektedir. Halihazırda sınavın paylaşıldığı kişiler yanında işaretli gelmiştir. Bu kişiler ile paylaşımı sonlandırmak "
                      "için yana kaydırınız. Diğer kişiler ile paylaşım yapmak için üzerine tıklamanız yeterlidir. Listeyi güncellemek için yenile butonuna basınız.",
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  Divider(thickness: 5, color: Colors.white,),
                  Text("** TÜM KİŞİLERİM sayfasından grupları getirerek sınavınızı seçtiğinizi grup ile de paylaşabilirsiniz.",
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  Divider(thickness: 5, color: Colors.white,),
                  Text("*** HerkeseAçık butonuna basarak sınavınızı herkese açabilirsiniz. Herkese Açık sınavlar uygulama üzerinden herkesçe görüntüleyebilir, "
                      "indirilebilir yada izninize bağlı olarak çözüm gönderebilir. Herkese açık sınavlar listenizde olmayan kişiler tarafından tanınmanız açısından "
                      "önemlidir.",
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ]),
        content: setupAlertDialogContainer(),
        actions: [
          Container( width: 120,
            child: ElevatedButton( child: Text( map_sinav["herkeseAcik"] == true ? "Herkese Açma" : "HerkeseAç"), onPressed: () async {
              has_ayarlama(map_sinav, id_sinav);
            },),
          ),
          Container( width: 120,
            child: ElevatedButton( child: Text("TümKişilerim/Gruplarım"), onPressed: () {
              AlertDialog alertdialog = new AlertDialog (
                title: Text("Dikkat: "),
                content: Text("Sınavın tüm kişiler yada belli bir kişi grubu ile paylaşılabilme işlemi *Tüm Kişilerim sayfasından yapılabilmektedir.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ); showDialog(context: context, builder: (_) => alertdialog);

            },),
          ),

          IconButton(icon: Icon(Icons.refresh_sharp, size: 30, color: Colors.lightBlueAccent,), onPressed: (){
            Navigator.of(context, rootNavigator: true).pop("dialog");
            _sinaviPaylas(map_sinav, id_sinav, paylasilanlar, );
          })
        ]
    );
    });
  }

  void has_ayarlama( dynamic map_sinav, dynamic id_sinav ) async {
    bool has_cozum_izin; bool has_iletisim_izin; String Shas_cozum_izin; String Shas_iletisim_izin;

    if(map_sinav["herkeseAcik"] == true) {
      await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
          .update({"herkeseAcik" : false});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sınavın herkese açık özelliği kapatıldı. Sınavınız sadece kişilerim listenizden "
          "paylaştıklarınız için görülebilir."), action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
      Navigator.of(context, rootNavigator: true).pop("dialog");
    } else {
      Navigator.of(context, rootNavigator: true).pop("dialog");
      AlertDialog alertdialog = new AlertDialog(
        title: Scrollbar(
          child: Container(height: 250,
            child: SingleChildScrollView( physics: ClampingScrollPhysics(),
              child: Column(children: [
                Text("DİKKAT: "),
                SizedBox(height: 10,),
                Text("* Sınavınızı herkese açmak için aşağıdaki izinleri yanıtlamanız ve Onayla butonuna tıklamanız gerekmektedir.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                SizedBox(height: 10,),
                Text("1) Sınavınızı herkese açmayı tercih ettiniz. Sınavcım uygulamasına sahip herkes kişi listenizde olmasa da bu sınavınıza erişebilecektir.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                SizedBox(height: 10,),
                Text("2) Listenizde olmayan bu kişilere aşağıdaki izinleri vermeniz durumunda size çözüm gönderebilecekler veya sizinle iletişime "
                    "geçebileceklerdir. Aksi takdirde belirtilen işlemleri yapamazlar. Verilen izinler birbirinden bağımsızdır.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),),
                SizedBox(height: 10,),
                Text("3) Çözüm Gönderme izni verdiğinizde herkesin size çözüm göndermesine izin vermiş olursunuz. Bu durum sınavınızın geçerliliğini ve "
                    "kalitesini daha geniş bir kitleden gelen çözümler ile ölçmenize olanak verir. Sınavınız belli sayıda bir grup için özelleştirilmiş "
                    "bir sınav ise bu seçeneğe izin vermeniz önerilmez.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),),
                SizedBox(height: 10,),
                Text("4) İletişim izni verdiğinizde sınavı görüntüleyen herkes için AdSoyad ve Emailiniz de görülebilir olacaktır. Bu durumda tanıdığınızdan "
                    "çok daha fazla kişiyle bağlantılı olabilir, yeni fırsatlar elde edebilirsiniz. Bu izin ile Profil Sayfanızın görüntülenmesi arasında "
                    "bir ilişki yoktur. Profil Sayfanız ve oradaki bilgilerin gizliliği aynı şekilde devam edecektir.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),),
              ]
              ),
            ),
          ),
        ),
        content: Container( height: 200,
          child: Column(
              children: [
                ListTile(
                  title: Text("Sınavınıza herkes çözüm göndersin mi?", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
                  subtitle: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    MaterialButton(child: Text("EVET", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                        onPressed: () {
                          has_cozum_izin = true;
                          Shas_cozum_izin = "evet";
                        }),
                    MaterialButton(child: Text("HAYIR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                        onPressed: () {
                          has_cozum_izin = false;
                          Shas_cozum_izin = "hayır";
                        }),
                  ],),
                ),
                ListTile(
                  title: Text("AdSoyad ve Email adresiniz sınavda görünsün mü?", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
                  subtitle: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    MaterialButton(child: Text("EVET", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                        onPressed: () {
                          has_iletisim_izin = true;
                          Shas_iletisim_izin = "evet";
                        }),
                    MaterialButton(child: Text("HAYIR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                        onPressed: () {
                          has_iletisim_izin = false;
                          Shas_iletisim_izin = "hayır";
                        }),
                  ],),
                ),
              ]
          ),
        ),
        actions: [
          ElevatedButton(child: Text("Onayla"), onPressed: () async {
            List <dynamic> has_gruplar = [];
            if(has_iletisim_izin == null || has_cozum_izin == null){
              AlertDialog alertDialog = new AlertDialog(
                title: Text("İzin sorularından en az birini yanıtlamadınız", style: TextStyle(color: Colors.red)),
              ); showDialog(context: context, builder: (_) => alertDialog);
            } else {
              await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                  .update({"herkeseAcik" : true, "mail": AtaWidget.of(context).kullanicimail, "id_sinav": id_sinav, "id_hazirlayan" : doc_id,
                "has_cozum_izin": has_cozum_izin, "has_iletisim_izin": has_iletisim_izin, "has_gruplar": has_gruplar,
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sınavınız herkese açıldı. Sınavınızın çözümm izni "
                  "*${Shas_cozum_izin.toUpperCase()} ve iletisim izni *${Shas_iletisim_izin.toUpperCase()} olarak ayarlandı."),
                duration: Duration(seconds: 10),
                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
              Navigator.of(context, rootNavigator: true).pop("dialog");
            }
          },),
        ],
      ); showDialog(context: context, builder: (_) => alertdialog);

    }
  }

  void _gonderenSec() async {
    Widget setupAlertDialogContainer() {
      return Container(
        height: 300, width: 300,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim").snapshots(),
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


              return Container(
                child:  _querySnapshot.size == 0 ?  Center(
                  child: Text("Hesabınıza ekli hiç kişiniz bulunamadı. Önce kişi ekleyiniz.",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                ) :
                  ListView.builder(
                    itemCount: _querySnapshot.size,
                    itemBuilder: (BuildContext context, int index){
                      final map_kisilerim = _querySnapshot.docs[index].data();
                      final id_kisilerim = _querySnapshot.docs[index].id;


                      return Column(
                        children: [
                          Dismissible( key: Key(_querySnapshot.docs[index].id),
                            child: Visibility( visible: map_kisilerim["kullaniciadi"] == "" ? false : true,
                              child: ListTile(
                                title: Text(map_kisilerim["kullaniciadi"]),
                                subtitle: Text(map_kisilerim["mail"]),
                                onTap: () async {
                                  AlertDialog alertDialog = new AlertDialog (
                                    title: Text(map_kisilerim["kullaniciadi"]),
                                    content: Text("isimli göndereni seçtiniz."),
                                    actions: [
                                      MaterialButton(
                                        child: Text("Sınavlarını Getir", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 20)),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance.collection("users").where("kullaniciadi", isEqualTo: map_kisilerim["kullaniciadi"])
                                              .get().then((QuerySnapshot querySnapshot)=>{
                                            querySnapshot.docs.forEach((_doc) async {
                                              sinavGonderen_id = _doc.id.toString();
                                              sinavGonderen_kullaniciadi = map_kisilerim["kullaniciadi"];
                                              AtaWidget.of(context).sinavGonderen_id = sinavGonderen_id;
                                              AtaWidget.of(context).sinavGonderen_kullaniciadi = sinavGonderen_kullaniciadi;

                                            })
                                          });
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          Navigator.of(context, rootNavigator: true).pop("dialog");

                                          collectionReference_gs = FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id)
                                              .collection("sinavlar");
                                          storageReference_gs = FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).sinavGonderen_kullaniciadi)
                                              .child("sinavlar");
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                                              SinavlarKisilerPage(doc_id: doc_id, map: map, doc_avatar: doc_avatar, gonderen_secildi: true,)));
                                        },
                                      ),
                                    ]
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                },
                                selectedTileColor: Colors.green,
                              ),
                            ),
                          ),
                          Visibility( visible: map_kisilerim["kullaniciadi"] == "" ? false : true,
                              child: Divider(thickness: 3, color: Colors.indigo)),
                        ],
                      );
                    }),
              );
            }),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
          title: Wrap(
              children: [
                Text("Gönderen Seç", style: TextStyle(color: Colors.green),),
                Text("Tüm kişileriniz gösterilmektedir. Seçtiğiniz gönderenin sizinle paylaştığı sınavları göreceksiniz. Gönderen seçmek için üzerine tıklayınız.",
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ]),
          content: setupAlertDialogContainer(),
      );
    });
  }

  void _kisiEkle() async {
    TextEditingController _kullaniciadici = TextEditingController();
    TextEditingController _mailci = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    Widget __kisiEkleAlertDialog() {
      return Container(
        height: 300, width: 400,
        child: Column(children: [
          Form(key: _formKey,
              child: Flexible(
                child: ListView(children: [
                  SizedBox(height: 10,),
                  TextFormField(
                      controller: _kullaniciadici,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Kişinin kullaniciadini giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String value) {
                        if (value.isEmpty) {return "kullaniciadi girmeniz gerekmektedir.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  TextFormField(
                      controller: _mailci,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Kişinin Email adresini giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String value) {
                        if (value.isEmpty) {return "Email adresi girmeniz gerekmektedir.";
                        } return null;
                      }),

                ]),
              )),

        ]),
      );
    }
   showDialog(context: context, builder: (_) {
     return AlertDialog(
       title: Text("Kişilerime Ekle"),
       content: __kisiEkleAlertDialog(),
       actions: [
         ElevatedButton(
           child: Text("Kişiyi Ekle"),
           onPressed: () async {
             if(_formKey.currentState.validate()){
               _formKey.currentState.save();
               final kullaniciadi = _kullaniciadici.text.trim();
               final mail = _mailci.text.trim();
               String kisiKontrol_kullaniciadi;
               String kisiKontrol_kullanici_id;
               bool kisi_var = false;
               bool karsida_kisi_var = false;

               await FirebaseFirestore.instance.collection("users").where("mail", isEqualTo: mail).get()
                   .then((value) => value.docs.forEach((element) {
                 kisiKontrol_kullaniciadi = element["kullaniciadi"];
                 kisiKontrol_kullanici_id = element.id;

//               setState(() {});

                 element.reference.collection("kisilerim").where("mail", isEqualTo: AtaWidget.of(context).kullanicimail).get()
                     .then((value) => value.docs.forEach((element){
                       if(element.exists){
                         print("karşıda kişi var");
                         karsida_kisi_var = true;
                       }
                     }));
                   }));

               if(kisiKontrol_kullaniciadi != kullaniciadi){
                 AlertDialog alertDialog = new AlertDialog(
                   title: Text("Girilen bilgilerle sisteme kayıtlı kişi bulunamadı.",
                     style: TextStyle(color: Colors.red),),
                   content: Text("Kişinin uygulamaya kaydolduğundan yada girdiğiniz bilgilerin doğruluğundan emin olunuz. Sistem büyük küçük harf ve boşluklara duyarlıdır."),
                 ); showDialog(context: context, builder: (_) => alertDialog);
               } else {

                 await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").where("mail", isEqualTo: mail)
                     .get().then((value) => value.docs.forEach((element) {
                       kisi_var = true;
//                   setState(() {});
                     })
                 );

                 if(kisi_var == true){
                   AlertDialog alertDialog = new AlertDialog(
                     title: Text("Bu mail adresi ile kişilerinize kayıtlı bir kullanıcı mevcuttur. Bilgilerin doğruluğundan emin olunuz.",
                       style: TextStyle(color: Colors.red),),
                   ); showDialog(context: context, builder: (_) => alertDialog);
                 } else {
                   await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
                       .add({"kullaniciadi": kullaniciadi, "mail": mail, "grup_adi": "", "grupAciklamasi": "", "eklendigi_grup": ""});

                   if(karsida_kisi_var != true) {
                     await FirebaseFirestore.instance.collection("users").doc(kisiKontrol_kullanici_id).collection("kisilerim")
                         .add({"kullaniciadi": AtaWidget.of(context).kullaniciadi, "mail": AtaWidget.of(context).kullanicimail,
                       "grup_adi": "", "grupAciklamasi": "", "eklendigi_grup": ""});
                   }

                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(kullaniciadi + " kişilerinize başarıyla eklenmiştir."),
                     action: SnackBarAction(label: "Gizle", onPressed: ()=> SnackBarClosedReason.hide),));
                   Navigator.of(context, rootNavigator: true).pop("dialog");
                 }
               }
             }
           },)
       ],
     );
   });
  }

  void _grupEkle() async {
    TextEditingController _grupadici = TextEditingController();
    TextEditingController _aciklamaci = TextEditingController();

    final _formKey = GlobalKey<FormState>();
    final _formKey_aciklama = GlobalKey<FormState>();

    Widget __grupEkleAlertDialog() {
      return Container(
        height: 200, width: 300,
        child: Column(children: [
          Form(key: _formKey,
              child: Flexible(
                child: ListView(children: [
                  SizedBox(height: 10,),
                  TextFormField(
                      controller: _grupadici,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Grup adını giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String value) {
                        if (value.isEmpty) {return "Alan boş bırakılamaz.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  Form( key: _formKey_aciklama,
                    child: TextFormField(
                        controller: _aciklamaci,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Grup açıklaması girebilirsiniz."),
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                        validator: (String value) {
                          if (value.isEmpty) {return "Grubunuz için açıklama girilmemiştir.";
                          } return null;
                        }),
                  ),

                ]),
              )),

        ]),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Column(children: [
          Align( alignment: Alignment.topLeft,
              child: Text("Grup Ekle", style: TextStyle(fontSize: 20, color: Colors.green, ),)),
          Text("Açıklama alanı zorunlu değildir.", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),),
        ]),
        content: __grupEkleAlertDialog(),
        actions: [
          ElevatedButton(
            child: Text("Grubu oluştur"),
            onPressed: () async {
              if(_formKey.currentState.validate()){
                _formKey.currentState.save();
                _formKey_aciklama.currentState.save();

                final grupAdi = _grupadici.text.trim();
                final grupAciklamasi = _aciklamaci.text.trim();
                bool grupVar = false;

                if(kisilerim_grupEkle == true){
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").where("grup_adi", isEqualTo: grupAdi).limit(1)
                      .get().then((value) => value.docs.forEach((element) {
                    element.exists ? grupVar = true : grupVar = false;
                    setState(() {});
                  }));
                  if(grupVar == true){ AlertDialog alertDialog = new AlertDialog (
                    title: Text("Aynı isimle oluşturulmuş bir grup mevcuttur. Lütfen farklı bir isim ile grubu yeniden oluşturunuz.", style: TextStyle(color: Colors.red),),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                  }
                  else{
                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
                        .add({"grup_adi": grupAdi, "grupAciklamasi": grupAciklamasi, "tarih": DateTime.now().toString(), "kullaniciadi": "", "mail": ""});

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz başarıyla oluşturulmuştur")));
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                  }
                }
                else if(hazirladigimSinavlar_grupEkle == true) {
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").where("grup_adi", isEqualTo: grupAdi).limit(1)
                      .get().then((value) => value.docs.forEach((element) {
                    element.exists ? grupVar = true : grupVar = false;
                    setState(() {});
                  }));
                  if(grupVar == true){ AlertDialog alertDialog = new AlertDialog (
                    title: Text("Aynı isimle oluşturulmuş bir grup mevcuttur. Lütfen farklı bir isim ile grubu yeniden oluşturunuz.", style: TextStyle(color: Colors.red),),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                  }
                  else{
                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar")
                        .add({"grup_adi": grupAdi, "grupAciklamasi": grupAciklamasi, "tarih": DateTime.now().toString(), "baslik": "", "konu": ""});

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz başarıyla oluşturulmuştur")));
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                  }
                }
                else if(gonderilenSinavlar_grupEkle == true) {
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("paylasilan_sinavlar_gruplari")
                      .where("grup_adi", isEqualTo: grupAdi).limit(1).get().then((value) => value.docs.forEach((element) {
                    element.exists ? grupVar = true : grupVar = false;
                    setState(() {});
                  }));
                  if(grupVar == true){ AlertDialog alertDialog = new AlertDialog (
                    title: Text("Aynı isimle oluşturulmuş bir grup mevcuttur. Lütfen farklı bir isim ile grubu yeniden oluşturunuz.", style: TextStyle(color: Colors.red),),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                  }
                  else{
                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("paylasilan_sinavlar_gruplari")
                        .add({"grup_adi": grupAdi, "grupAciklamasi": grupAciklamasi, "tarih": DateTime.now().toString(), });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz başarıyla oluşturulmuştur")));
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                  }
                }
                else if(herkeseAcikSinavlar_grupEkle == true) {
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("herkeseAcik_sinavlar_gruplari")
                      .where("grup_adi", isEqualTo: grupAdi).limit(1).get().then((value) => value.docs.forEach((element) {
                    element.exists ? grupVar = true : grupVar = false;
                    setState(() {});
                  }));
                  if(grupVar == true){ AlertDialog alertDialog = new AlertDialog (
                    title: Text("Aynı isimle oluşturulmuş bir grup mevcuttur. Lütfen farklı bir isim ile grubu yeniden oluşturunuz.", style: TextStyle(color: Colors.red),),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                  }
                  else{
                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("herkeseAcik_sinavlar_gruplari")
                        .add({"grup_adi": grupAdi, "grupAciklamasi": grupAciklamasi, "tarih": DateTime.now().toString(), });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz başarıyla oluşturulmuştur")));
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                  }
                }
              }
            },
          ),
        ],
      );
    });
  }

  void _gruplandir(dynamic map_gruplandir,dynamic id_gruplandir) async {

    Widget _gruplandirAlertDialog() {
      return Container(
        height: 300, width: 400,
        child: StreamBuilder(
            stream: hazirladigimSinavlar_gruplandir == true ? FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").snapshots()
                : kisilerim_gruplandir == true ? FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim").snapshots()
                : gonderilenSinavlar_gruplandir ? FirebaseFirestore.instance.collection("users").doc(doc_id).collection("paylasilan_sinavlar_gruplari").snapshots()
                : FirebaseFirestore.instance.collection("users").doc(doc_id).collection("herkeseAcik_sinavlar_gruplari").snapshots(),
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
                        Visibility( visible: map_gruplar["grup_adi"] == "" ? false : true,
                          child: ListTile(
                            title: Text(map_gruplar["grup_adi"] ),
                            subtitle: Text(map_gruplar["grupAciklamasi"]),
                            onTap: () async {

                              if(hazirladigimSinavlar_gruplandir == true){
                                if(map_gruplandir["eklendigi_grup"] ==  map_gruplar["grup_adi"]){
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").doc(id_gruplandir.toString())
                                      .update({"eklendigi_grup": ""});
                                } else {
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").doc(id_gruplandir.toString())
                                      .update({"eklendigi_grup":  map_gruplar["grup_adi"]});
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                Navigator.of(context, rootNavigator: true).pop("dialog");
                              }
                              else if(kisilerim_gruplandir == true){
                                if(map_gruplandir["eklendigi_grup"] ==  map_gruplar["grup_adi"]){
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").doc(id_gruplandir.toString())
                                      .update({"eklendigi_grup": ""});
                                } else {
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").doc(id_gruplandir.toString())
                                      .update({"eklendigi_grup":  map_gruplar["grup_adi"]});
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                Navigator.of(context, rootNavigator: true).pop("dialog");
                              }
                              else if (gonderilenSinavlar_gruplandir == true) {
                                List <dynamic> paylasilan_gruplar = [];

                                if(map_gruplandir["eklendigi_grup"] ==  map_gruplar["grup_adi"]){

                                  await FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id).collection("sinavlar")
                                      .doc(gs_id_sinav.toString()).get().then((value) {
                                        paylasilan_gruplar = value.get("paylasilan_gruplar");
                                        paylasilan_gruplar.remove(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                      });
                                  await FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id).collection("sinavlar")
                                      .doc(gs_id_sinav.toString()).update({"paylasilan_gruplar": paylasilan_gruplar});

                                  await FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id).collection("sinavlar")
                                      .doc(gs_id_sinav.toString()).collection("paylasilanlar").doc(gonderilenSinav_paylasilanId).update({"eklendigi_grup": ""});


                                } else {
                                  await FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id).collection("sinavlar")
                                      .doc(gs_id_sinav.toString()).get().then((value) {
                                    paylasilan_gruplar = value.get("paylasilan_gruplar");
                                    paylasilan_gruplar.add(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                  });
                                  await FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id).collection("sinavlar")
                                      .doc(gs_id_sinav.toString()).update({"paylasilan_gruplar": paylasilan_gruplar});

                                  await FirebaseFirestore.instance.collection("users").doc(AtaWidget.of(context).sinavGonderen_id).collection("sinavlar")
                                      .doc(gs_id_sinav.toString()).collection("paylasilanlar").doc(gonderilenSinav_paylasilanId)
                                      .update({"eklendigi_grup":  map_gruplar["grup_adi"]});
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                Navigator.of(context, rootNavigator: true).pop("dialog");

                              }
                              else if (has_gruplandir == true) {
                                if(has_gruplar.contains(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi)){
                                  has_gruplar.remove(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                  await collectionReference_has.doc(id_gruplandir).update({"has_gruplar": has_gruplar});

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                  Navigator.of(context, rootNavigator: true).pop("dialog");
                                }
                                else {
                                  has_gruplar.add(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                  await collectionReference_has.doc(id_gruplandir).update({"has_gruplar": has_gruplar});

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                  Navigator.of(context, rootNavigator: true).pop("dialog");
                                }
                              }
                            },
                            trailing: has_gruplandir == true
                                ? has_gruplar.contains(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi)
                                ? Icon(Icons.check_circle) : SizedBox.shrink()
                                : map_gruplandir["eklendigi_grup"] == map_gruplar["grup_adi"] ? Icon(Icons.check_circle) : SizedBox.shrink(),
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
          title: Wrap(
              children: [
                Text("Gruba Ekle", style: TextStyle(color: Colors.green),),
                Text("Listelene Sınavlarınız için oluşturduğunuz tüm gruplarınız gösterilmektedir. Hali hazırda seçili sınav eklediğiniz grup varsa yanında tik işareti "
                    "ile belirtilmiştir. Sınavı bir gruba eklemek yada ekli gruptan kaldırmak için grubun üzerine tıklamanız yeterlidir. "
                    "Bu işlem için ayrı bir onay istenmeyecektir.",
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ]),
          content: _gruplandirAlertDialog(),

      );
    });
  }

  Future<void> _kisiProfilineGit(dynamic id_kisilerim, dynamic map_kisilerim) async {
    String profil_id; String gelen_kisi_grubu; String gelen_kisi_kullaniciadi;
    await FirebaseFirestore.instance.collection("users").where("mail", isEqualTo: map_kisilerim["mail"]).limit(1).get().then((profil) => profil.docs.forEach((profil) async {
      profil_id = profil.id;

//      setState(() {});

      await FirebaseFirestore.instance.collection("users").doc(profil.id).collection("kisilerim").where("mail", isEqualTo: map["mail"]).limit(1).get()
          .then((value) => value.docs.forEach((gelen) {
            gelen_kisi_grubu = gelen["eklendigi_grup"];
            gelen_kisi_kullaniciadi = gelen["kullaniciadi"];

//            setState(() {});
            print("profil_id: " + profil_id);
            print("gelen_kisi_kullaniciadi: " + gelen_kisi_kullaniciadi.toString());
            print("gelen_kisi_grubu: " + gelen_kisi_grubu.toString());
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilPage(doc_id: profil_id, gelen_kisi_grubu: gelen_kisi_grubu)));
      }));
    }));
  }

  void hs_sinaviSil(dynamic map_sinav, dynamic id_sinav) async {
      try{
        FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
            .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"]).listAll()
            .then((value) => value.items.forEach((element) {element.delete();}));

        FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
            .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"])
            .child("cevaplayanlarin_gorselleri").listAll()
            .then((value) => value.items.forEach((element) {element.delete();}));


      } catch (e) {debugPrint(e.toString());}

      await collectionReference_hs.doc(id_sinav.toString()).delete();

      await collectionReference_hs.doc(id_sinav.toString()).collection("soruyu_cevaplayanlar")
          .get().then((snapshot) { for( DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }});
      await collectionReference_hs.doc(id_sinav.toString()).collection("paylasilanlar")
          .get().then((snapshot) { for( DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sınav başarıyla silindi"),));
      Navigator.of(context, rootNavigator: true).pop("dialog");
  }

  void os_sinavSil(dynamic map_sinav, dynamic id_sinav, List sorular) async {
    try {
      FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
          .child("sinavlar").child("olusturulan_sinavlar").child(map_sinav["baslik"]).listAll()
          .then((value) => value.items.forEach((element) {element.delete();}));

      for (int i = 0; i <sorular.length ; i++) {

        FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("sinavlar").child("olusturulan_sinavlar")
            .child(map_sinav["baslik"]).child("sorular").child(sorular[i]).listAll().then((value) => value.items.forEach((element) {element.delete();}));

        FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("sinavlar").child("olusturulan_sinavlar")
            .child(map_sinav["baslik"]).child("sorular").child(sorular[i]).child("şıklar").listAll().then((value) => value.items.forEach((element) {element.delete();}));

        FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("sinavlar").child("olusturulan_sinavlar")
            .child(map_sinav["baslik"]).child("sorular").child(sorular[i]).child("cevaplayanlarin_gorselleri").listAll()
            .then((value) => value.items.forEach((element) {element.delete();}));

      }
      await collectionReference_hs.doc(id_sinav.toString()).delete();

      await collectionReference_hs.doc(id_sinav.toString()).collection("sinavi_cevaplayanlar")
          .get().then((snapshot) { for( DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }});

      await collectionReference_hs.doc(id_sinav.toString()).collection("paylasilanlar")
          .get().then((snapshot) { for( DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }});

      await collectionReference_hs.doc(id_sinav.toString()).collection("sorular").get().then((_sorular) => _sorular.docs.forEach((_soru) {
        _soru.reference.collection("A_isaretleyenler").get().then((A_isaretleyenler) => A_isaretleyenler.docs.forEach((A_isaretleyen) {
          A_isaretleyen.reference.delete();}));
        _soru.reference.collection("B_isaretleyenler").get().then((B_isaretleyenler) => B_isaretleyenler.docs.forEach((B_isaretleyen) {
          B_isaretleyen.reference.delete();}));
        _soru.reference.collection("C_isaretleyenler").get().then((C_isaretleyenler) => C_isaretleyenler.docs.forEach((C_isaretleyen) {
          C_isaretleyen.reference.delete();}));
        _soru.reference.collection("D_isaretleyenler").get().then((D_isaretleyenler) => D_isaretleyenler.docs.forEach((D_isaretleyen) {
          D_isaretleyen.reference.delete();}));
        _soru.reference.collection("dogruSik_isaretleyenler").get().then((dogruSik_isaretleyenler) => dogruSik_isaretleyenler.docs.forEach((dogruSik_isaretleyen) {
          dogruSik_isaretleyen.reference.delete();}));
        _soru.reference.collection("isaretleyenler").get().then((isaretleyenler) => isaretleyenler.docs.forEach((isaretleyen) {
          isaretleyen.reference.delete();}));
        _soru.reference.collection("soruyu_cevaplayanlar").get().then((soruyu_cevaplayanlar) => soruyu_cevaplayanlar.docs.forEach((soruyu_cevaplayan) {
          soruyu_cevaplayan.reference.delete();}));
        _soru.reference.delete();

      }));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sınav başarıyla silindi"),));
      Navigator.of(context, rootNavigator: true).pop("dialog");
    }
    catch (e) {print(e.toString());}
  }

  Widget HerkeseAcikSinavlariGetir () {

    return Column(
        children: [
          GestureDetector(
            onTap: () async {
              _reklam.showInterad();
              if(AtaWidget.of(context).has_grup_liste != null && AtaWidget.of(context).has_grup_liste_id != null ){
                AtaWidget.of(context).has_grup_liste.clear();
                AtaWidget.of(context).has_grup_liste_id.clear();
              }

              await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("herkeseAcik_sinavlar_gruplari")
                  .orderBy("tarih", descending: true).get().then((has_gruplar) => has_gruplar.docs.forEach((has_grup) {
                has_grup_liste.add(has_grup.data());
                has_grup_liste_id.add(has_grup.id);

              }));
              AtaWidget.of(context).has_grup_liste = has_grup_liste;
              AtaWidget.of(context).has_grup_liste_id = has_grup_liste_id;

              print(AtaWidget.of(context).has_grup_liste);
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  HerkeseAcikSinavlar(doc_id: doc_id, gruplari_getir: false, grup_adi: null, map: map, gonderen_secildi: gonderen_secildi, doc_avatar: doc_avatar)));
            },
            child: RichText(text: TextSpan(
                style: TextStyle(), children:<TextSpan>[
              TextSpan(text: "Sınavlar sondan başa doğru sıralanmıştır. Tüm sınavları/grupları görmek için",
                style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),),
              TextSpan(text: "  *Buraya Tıklayınız.*",
                  style: TextStyle(color: Colors.indigo, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
            ]
            ), textAlign: TextAlign.justify,),
          ),
          SizedBox(height: 10,),
          Flexible(
            child: AtaWidget.of(context).herkeseAcik_sinavlar.length == 0 ? Center(
              child: Text("Gösterilecek herhangi bir veri bulunamadı.",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            ) :
            ListView.builder(
                itemCount: AtaWidget.of(context).herkeseAcik_sinavlar.length,
                itemBuilder: (context, index) {
                  final map_sinav = AtaWidget.of(context).herkeseAcik_sinavlar[index];
                  final id_sinav = AtaWidget.of(context).herkeseAcik_sinavlar_id[index];

                  return Column(children: [
                    SizedBox(height: 5,),
                    Container(
                      color: Colors.blue.shade100,
                      child: GestureDetector(
                        onDoubleTap: () {
                          map_sinav["kilitli"] == false ?
                          map_sinav["gorsel_cevap"] == null || map_sinav["gorsel_cevap"] == " " || map_sinav["gorsel_cevap"] == "" ?
                          _metinselCevapGoster(map_sinav) : _launchIt(map_sinav["gorsel_cevap"])
                              :
                          showDialog(context: context, builder: (_) {
                            return AlertDialog(
                              title: Text("*Hata: Sınavın cevapları kilitlidir, görülemez", style: TextStyle(color: Colors.red)),
                            );
                          });
                        },
                        child: ListTile(
                            title: Text(map_sinav["baslik"],
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            subtitle: Wrap( direction: Axis.vertical, spacing: 4,
                                children: [
                                  Text(map_sinav["konu"]),
                                  Visibility( visible: map_sinav["has_iletisim_izin"] == true ? true : false,
                                    child: Card( elevation: 10, color: Colors.blue.shade100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Container(color: Colors.blue.shade100,
                                          child: Wrap( direction: Axis.vertical, spacing: 2,
                                            children: [
                                              Text("HAZIRLAYAN: "+ map_sinav["hazirlayan"], style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic)),
                                              Text("E-mail: "+ map_sinav["mail"], style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ] ),
                            trailing: Wrap(direction: Axis.vertical,
                                children: [
                                  Text(map_sinav["tarih"].toString().substring(0,10)),
                                  Text(map_sinav["tarih"].toString().substring(11,16),)
                                ]
                            ),

                            onTap: () async {

                              collectionReference_has = FirebaseFirestore.instance.collection("users").doc(map_sinav["id_hazirlayan"])
                                  .collection("sinavlar");
                              storageReference_has = FirebaseStorage.instance.ref().child("users").child(map_sinav["hazirlayan"])
                                  .child("sinavlar");

                              if(map_sinav["olusturulanmi"] == true){

                                _reklam.showInterad();

                                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                    OlusturulanSinavPage(map_solusturulan: map_sinav, id_solusturulan: id_sinav, grid_gorunum: false,
                                        collectionReference: collectionReference_has, storageReference: storageReference_has)));
                              } else if(map_sinav["olusturulanmi"] == false){
                                String _doc_baslik; String _doc_cevaplayan; String _doc_id; String _doc_aciklama; String _doc_gorsel;
                                int _doc_puan;
                                await collectionReference_has.doc(id_sinav.toString()).collection("soruyu_cevaplayanlar")
                                    .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                                    .get().then((QuerySnapshot querySnapshot)=>{
                                  querySnapshot.docs.forEach((_doc) async {

                                    _doc_baslik = _doc["baslik"];
                                    _doc_cevaplayan = _doc["cevaplayan"];
                                    _doc_aciklama = _doc["aciklama"];
                                    _doc_gorsel = _doc["gorsel"];
                                    _doc_puan = _doc["puan"];
                                    _doc_id = _doc.id.toString();

                                  })
                                });

                                _sinaviGor(map_sinav, id_sinav, _doc_baslik, _doc_gorsel, _doc_aciklama, _doc_id, _doc_puan);
                              }
                            },
                            onLongPress: () async {
                              _reklam.createInterad();

                              has_gruplar.clear();
                              collectionReference_has = FirebaseFirestore.instance.collection("users").doc(map_sinav["id_hazirlayan"])
                                  .collection("sinavlar");

                              kisilerim_gruplandir = false;
                              hazirladigimSinavlar_gruplandir = false;
                              gonderilenSinavlar_gruplandir = false;
                              has_gruplandir = true;

                              await collectionReference_has.doc(id_sinav).get().then((fields) {
                                has_gruplar = fields.get("has_gruplar");
                              });
                              _gruplandir(map_sinav, id_sinav);
                            }
                        ),
                      ),
                    ),
                    Divider(height: 8,thickness: 2, color: Colors.black,)
                  ]);
                }),

          ),
        ]
    );

  }

  void has_filtresiz() async {
    String hasSinav_baslik;

    await FirebaseFirestore.instance.collection("users").get().then((kullanicilar) => kullanicilar.docs.forEach((kullanici) {
      kullanici.reference.collection("sinavlar").where("herkeseAcik", isEqualTo: true).orderBy("tarih", descending: true).get().then((sinavlar) =>
          sinavlar.docs.forEach((sinav) {
            herkese_acik_sinavlar.add(sinav.data());
            herkese_acik_sinavlar_id.add(sinav.id);
          }));
    }));

    AlertDialog alertdialog = new AlertDialog(
      title: Text("Herkese açık olarak paylaşılan tüm sınavlar hiç bir filtreye uğramadan gösterilecektir. Özel bir arama "
          "için aşağıdaki filterleri kullanmanız önerilir.",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),
      actions: [
        ElevatedButton(child: Text("Tüm Sınavları Getir"), onPressed: () async {
          AtaWidget.of(context).herkeseAcik_sinavlar = herkese_acik_sinavlar;
          AtaWidget.of(context).herkeseAcik_sinavlar_id = herkese_acik_sinavlar_id;

          AtaWidget.of(context).has_filtreSecildi = true;
          Navigator.of(context, rootNavigator: true).pop("dialog");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
              SinavlarKisilerPage(doc_id: doc_id, map: map, doc_avatar: doc_avatar, gonderen_secildi: gonderen_secildi,)));
        },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertdialog);
  }

  void has_filtreli() async {

    AlertDialog alertdialog = new AlertDialog(
      title: Text("Arama yapmak istediğiniz dersin yada alanın adını giriniz. Alan büyük-küçük harf veya boşluklara "
          "duyarlıdır.",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: has_controller,
          decoration: InputDecoration(
            labelText: filtre == "baslik" ? "Başlığı giriniz" : filtre == "konu" ? "konuyu giriniz"
                : filtre == "bitis_tarihi" ? "Bitiş tarihini giriniz" : "Ders/Alan adını giriniz",
          ),
        ),
      ),
      actions: [
        ElevatedButton(child: Text("Onayla"), onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop("dialog");

          await FirebaseFirestore.instance.collection("users").get().then((kullanicilar) =>
              kullanicilar.docs.forEach((kullanici) {kullanici.reference.collection("sinavlar")
                  .where("herkeseAcik", isEqualTo: true).where( filtre, isEqualTo: has_controller.text.trim()).orderBy("tarih", descending: true)
                  .get().then((sinavlar) =>
                  sinavlar.docs.forEach((sinav) {
                    herkese_acik_sinavlar.add(sinav.data());
                    herkese_acik_sinavlar_id.add(sinav.id);
                  }));
              }));

          AlertDialog alertdialog = new AlertDialog(
            title: Text(
              filtre == "baslik" ? "Başlığı * ${has_controller.text.trim()}* olan herkese açık sınavlar getirilecektir. "
                  : filtre == "konu" ?  "Konusu * ${has_controller.text.trim()}* olan herkese açık sınavlar getirilecektir. "
                  : filtre == "bitis_tarihi" ? "Bitiş tarihi * ${has_controller.text.trim()}* olan herkese açık sınavlar getirilecektir. "
                  : "Ders/Alan adı * ${has_controller.text.trim()}* olan herkese açık sınavlar getirilecektir. " ,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),
            actions: [
              ElevatedButton(child: Text("Sınavları Getir"), onPressed: () async {
                AtaWidget.of(context).herkeseAcik_sinavlar = herkese_acik_sinavlar;
                AtaWidget.of(context).herkeseAcik_sinavlar_id = herkese_acik_sinavlar_id;

                AtaWidget.of(context).has_filtreSecildi = true;
                Navigator.of(context, rootNavigator: true).pop("dialog");
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                    SinavlarKisilerPage(doc_id: doc_id, map: map, doc_avatar: doc_avatar,
                      gonderen_secildi: gonderen_secildi,)));
              },
              ),
            ],
          ); showDialog(context: context, builder: (_) => alertdialog);

        },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertdialog);
  }

  void oyla_dialog(dynamic map, dynamic id, bool oylama_yapildi, int giris_sayisi, String doc_avatar, bool oylama_gosterme,) async {
    TextEditingController _controller_oylama = TextEditingController();
    final _formKey_oylama = GlobalKey<FormState>();

    double girisSayisi_bolu10 = giris_sayisi/10;

      Dialog dialog = new Dialog(
        backgroundColor: Colors.white, elevation: 100, insetAnimationDuration: Duration(seconds: 7),
        child: Container( width: 800, height: 500,
            child: ListView( children: [
              SizedBox(height: 10,),
              Center(
                child: Text("GÖRÜŞLERİNİZ BİZİM İÇİN DEĞERLİDİR...", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold,
                    fontSize: 15, decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.green),),
              ),
              SizedBox(height: 10,),
              ListTile(
                title: Text("Gönderdiğiniz her geri bildirimi kendimizi geliştirmek için bir fırsat olarak görüyoruz. Bize Google Play Store "
                    "üzerinden puan verebilir ve yorum yazabilirsiniz. Dilerseniz uygulama üzerinden sadece bizim göreceğimiz geri bildiriminizi "
                    "gönderebilirsiniz.",
                  style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 13, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.justify,
                ),
                subtitle: Text("",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15),
                child: FloatingActionButton.extended(label: Text("Play Store' da OYLA", style: TextStyle(color: Colors.blue),),
                  backgroundColor: Colors.white, elevation: 20,
                  icon: Container( height: 20, width: 20,
                      child: Image.asset("assets/playStore_icon.png", fit: BoxFit.contain,)), onPressed: (){
                    _launchIt("https://play.google.com/store/apps/details?id=com.sinavci&hl=tr");

                    FirebaseFirestore.instance.collection("users").doc(id).update({"oylama_yapildi" : true});
                    Navigator.of(context, rootNavigator: true).pop("dialog");

                    AlertDialog alertDialog = new AlertDialog(
                      content: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.blue, size: 30,),
                        title: Text("Play Store' da geri bildirim vererek gelişmemize katkıda bulunduğunuz için teşekkür ederiz.",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                      ),
                    ); showDialog(context: context, builder: (_) => alertDialog);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                        SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Divider(thickness: 3, color: Colors.indigo,),
              ),
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text("Bize uygulama ile ilgili deneyimlerinizi, görüş, eleştiri ve önerilerinizi içeren geri bildirim gönderebiliriniz: ",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),),
                ),
                subtitle: Align( alignment: Alignment.centerLeft,
                    child: Text("Yorum: ", style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),)),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form( key: _formKey_oylama,
                  child: TextFormField(
                    controller: _controller_oylama,
                    decoration: InputDecoration(
                        labelText: "Yorumunuzu buraya yazınız.",
                        hintText: "Buraya yazıdığınız yorumunuz gizlidir, sadece bizim tarafımızdan görüntülenir.",
                        hintStyle: TextStyle(fontSize: 10),
                        border: OutlineInputBorder()
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    validator: (value) {
                      if(value.isEmpty){ return "Yorum yazılmadı."; }
                      else { return null; }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: FloatingActionButton.extended( elevation: 20,
                  label: Text("Yorumunu Bize Gönder"), icon: Icon(Icons.send, color: Colors.greenAccent,), heroTag: "oylamayiGonder_buton",
                  onPressed: () async {
                    if(_formKey_oylama.currentState.validate()){
                      _formKey_oylama.currentState.save();
                      List<dynamic> alicilar_mail = ["yoneticikullanici1@gmail.com"];
                      List<dynamic> alicilar_ad = ["Yönetici Kullanıcı"];
                      List<dynamic> okuyanlar = [];

                      await FirebaseFirestore.instance.collection("bildirimler").add({ "tarih": DateTime.now().toString(), "alicilar_mail" : alicilar_mail,
                        "gonderen_adi" : AtaWidget.of(context).kullaniciadi, "gonderen_mail" : AtaWidget.of(context).kullanicimail, "alicilar_ad" : alicilar_ad,
                        "konu" : "${AtaWidget.of(context).kullaniciadi}' nın geri bildirimi_${giris_sayisi}", "mesaj" : _controller_oylama.text.trim(),
                        "okuyanlar" : okuyanlar,
                      });
                      Navigator.of(context, rootNavigator: true).pop("dialog");
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                          SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: gonderen_secildi,)));
                      AlertDialog alertDialog = new AlertDialog(
                        content: ListTile(
                          leading: Icon(Icons.check_circle, color: Colors.blue, size: 30,),
                          title: Text("Geri bildiriminiz için teşekkür ederiz. Geri Bildiriminize gönderilen mesajlar bölümünden ulaşabilirsiniz. Bildiriminiz incelenerek "
                              "size en yakın zamanda dönüş sağlayacağız. Google Play Store üzerinden de oylamayı ve yorum yazmayı unutmayın.",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                        ),
                      ); showDialog(context: context, builder: (_) => alertDialog);
                    }
                  },
                ),
              ),
              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility( visible: girisSayisi_bolu10 > 1 ? true : false,
                      child: Align( alignment: Alignment.centerLeft,
                        child: MaterialButton( child: Text("Bir daha Gösterme", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 20,
                          fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.red, decorationThickness: 3,),),
                          onPressed: (){
                            FirebaseFirestore.instance.collection("users").doc(id).update({"oylama_gosterme" : true});

                            Navigator.of(context, rootNavigator: true).pop("dialog");
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
                            AlertDialog alertDialog = new AlertDialog(
                              content: ListTile(
                                leading: Icon(Icons.info, color: Colors.blue, size: 30,),
                                title: Text("Bu pencereyi bir daha görmeyeceksin. Geri bildirim göndermek yada her hangi bir sorunda bizimle "
                                    "iletişime geçmek istersen *KİŞİLERİM alanından *MESAJ_GÖNDER ikonuna tıkladıktan sonra *TEKNİK_DESTEK/YORUM seçeneğini seçerek bize "
                                    "mesaj atabilir yada E-mail adresimize mail atabilirsin.",
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                              ),
                            ); showDialog(context: context, builder: (_) => alertDialog);
                          },
                        ),
                      ),
                    ),
                    Align( alignment: Alignment.centerRight,
                      child: MaterialButton( child: Text("Şimdi Değil", style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic, fontSize: 20,
                        fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.orange, decorationThickness: 3,),),
                        onPressed: (){
                          Navigator.of(context, rootNavigator: true).pop("dialog");
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                              SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
                          AlertDialog alertDialog = new AlertDialog(
                            content: ListTile(
                              leading: Icon(Icons.info, color: Colors.blue, size: 30,),
                              title: Text("Bu pencereyi ileri bir tarihte bir daha göreceksin. O zaman gelinceye kadar geri bildirim göndermek yada her hangi bir "
                                  "sorunda bizimle iletişime geçmek istersen *KİŞİLERİM alanından *MESAJ_GÖNDER ikonuna tıkladıktan sonra *TEKNİK_DESTEK/YORUM "
                                  "seçeneğini seçerek bize mesaj atabilirsin.",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                            ),
                          ); showDialog(context: context, builder: (_) => alertDialog);
                        },
                      ),
                    ),
                  ]
              ),
              SizedBox(height: 10,)
            ],
            )
        ),
      ); showDialog(context: context, builder: (_) => dialog);


  }

  void okunmayanBildirimleri_getir() {
    List <dynamic> bildirimi_okuyanlar = [];

    for(int i = 0; i<AtaWidget.of(context).bildirimler.length; i++){
      final map_bildirimler = AtaWidget.of(context).bildirimler[i];
      final id_bildirimler = AtaWidget.of(context).bildirimler_id[i];

      if(map_bildirimler["okuyanlar"].contains(AtaWidget.of(context).kullanicimail) == true ){
        okunan_bildirimler.add(map_bildirimler);
        okunan_bildirimler_id.add(id_bildirimler);
      }
      if(map_bildirimler["okuyanlar"].contains(AtaWidget.of(context).kullanicimail) == false ){
        okunmayan_bildirimler.add(map_bildirimler);
        okunmayan_bildirimler_id.add(id_bildirimler);
      }
    }

    Widget okunmayanBildirimler_Widget() {
      String msj; String gonderen_adi; String tarih; String konu;
      return Container(
        height: 300, width: 500,
        child: okunmayan_bildirimler.length == 0 ?
        Center( child: Text("Okunmayan bildiriminiz yoktur.", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),) :
        ListView.builder(
            itemCount: okunmayan_bildirimler.length,
            itemBuilder: (context, index) {

              msj = okunmayan_bildirimler[index]["mesaj"];
              konu = okunmayan_bildirimler[index]["konu"];
              gonderen_adi = okunmayan_bildirimler[index]["gonderen_adi"];
              tarih = okunmayan_bildirimler[index]["tarih"];
              return Column(
                children: [

                  Card( elevation: 50, color: Colors.blue.shade100,
                    child: ListTile(
                      title: RichText(text: TextSpan(
                          style: TextStyle(), children:<TextSpan>[
                        TextSpan(text: "konu: ", style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),),
                        TextSpan(text: okunmayan_bildirimler[index]["konu"].toString().toUpperCase(),
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ]),),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Wrap(
                          children: [
                            RichText(text: TextSpan(
                                style: TextStyle(), children:<TextSpan>[
                              TextSpan(text: "mesaj: ", style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),),
                              TextSpan(text: okunmayan_bildirimler[index]["mesaj"].toString().length < 50 ? okunmayan_bildirimler[index]["mesaj"]
                                  : okunmayan_bildirimler[index]["mesaj"].toString().substring(0, 50) + "...",
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 13)),
                            ]),),
                            SizedBox(height: 5,),
                            Wrap( direction: Axis.horizontal,
                                children: [
                                  Text("tarih: ", style: TextStyle(fontStyle: FontStyle.italic,)),
                                  Text(okunmayan_bildirimler[index]["tarih"].toString().substring(0, 16),
                                      style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                                ] ),
                          ]
                        ),
                      ),

                      trailing: Wrap( direction: Axis.vertical, spacing: 4,
                          children: [
                            Text("gönderen: ", style: TextStyle(fontStyle: FontStyle.italic,)),
                            Text(okunmayan_bildirimler[index]["gonderen_adi"], style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),

                          ] ),
                      onTap: () async {
                        await FirebaseFirestore.instance.collection("bildirimler").doc(okunmayan_bildirimler_id[index]).get()
                            .then((bildirim) {
                              bildirimi_okuyanlar = bildirim.get("okuyanlar");
                              if(bildirimi_okuyanlar.contains(AtaWidget.of(context).kullanicimail)){
                                print("bildirim zaten okundu olarak işaretlendi");
                              } else {
                                bildirimi_okuyanlar.add(AtaWidget.of(context).kullanicimail);
                                bildirim.reference.update({"okuyanlar" : bildirimi_okuyanlar});
                              }

                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bildirim okundu olarak işaretlenmiştir."),
                          action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));

                        _bildirimiGor(index);
                      },
                    ),
                  ),
                ]
              );

            }),
      );
    }

   AlertDialog alertdialog = new AlertDialog(backgroundColor: Colors.transparent,
     title: ListTile(
       title: Text("Okunmayan bildirimleriniz görüntülenmektedir.", style: TextStyle(color: Colors.blue.shade100, fontWeight: FontWeight.bold,
           fontSize: 16,), textAlign: TextAlign.center,),
       subtitle: Padding(
         padding: const EdgeInsets.only( top: 15.0),
         child: Center(child: Text("Bildirimler sondan başa doğru sıralanmıştır. Görmek istediğiniz bildirimin üzerine tıklayınız.",
             style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 12), textAlign: TextAlign.justify,)),
       ),
     ),
     content: okunmayanBildirimler_Widget(),
     actions: [
       MaterialButton(
         child: Text("Tümünü Gör", style: TextStyle(color: Colors.blue.shade100, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline,
          decorationThickness: 2, decorationColor: Colors.blue.shade100,
         ),),
         onPressed: () {
           Navigator.of(context, rootNavigator: true).pop("dialog");
           Navigator.push(context, MaterialPageRoute(builder: (context) => Bildirimler(okunan_bildirimler: okunan_bildirimler,
             okunan_bildirimler_id: okunan_bildirimler_id, okunmayan_bildirimler: okunmayan_bildirimler, okunmayan_bildirimler_id: okunmayan_bildirimler_id,)));
         },
       ),
     ],
   ); showDialog(context: context, builder: (_) => alertdialog);
  }

  void _bildirimiGor(int index) {
    AlertDialog alertdialog = new AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap( direction: Axis.vertical, spacing: 4,
              children: [
                Text("gönderen: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline)),
                Text(okunmayan_bildirimler[index]["gonderen_adi"], style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
              ] ),
          Wrap( direction: Axis.vertical,
              children: [
                Text("tarih: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline)),
                Text(okunmayan_bildirimler[index]["tarih"].toString().substring(0, 10),
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                Text(okunmayan_bildirimler[index]["tarih"].toString().substring(11, 16),
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
              ] ),
        ],
      ),
      content: Container( height: 300, width: 300,
        child: ListView(
          children: [
            ListTile(
              title: Text("konu: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),),
              subtitle: Text(okunmayan_bildirimler[index]["konu"].toString().toUpperCase(),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            ListTile(
              title: Text("mesaj: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),),
              subtitle: Text(okunmayan_bildirimler[index]["mesaj"],
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
      actions: [
        Visibility( visible: AtaWidget.of(context).kullaniciadi == "Yönetici Kullanıcı" ? true : false,
          child: FloatingActionButton.extended( heroTag: "yanitla", backgroundColor: Colors.indigo, elevation: 50, icon: Icon(Icons.arrow_back_rounded),
              onPressed: (){
                yanitla(okunmayan_bildirimler[index]);
              },
              label: Text("Yanıtla", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertdialog);
  }

  void yanitla(dynamic map_bildirimler) async {
    GlobalKey<FormState> formKey_yanitla = GlobalKey<FormState>();
    TextEditingController yanitlayici = TextEditingController();
    List <dynamic> okuyanlar = [];

    AlertDialog alertDialog = new AlertDialog(
      title: Wrap( spacing: 10,
          children: [
            Wrap(
              children: [
                Text("konu: ", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 13),),
                Text("${map_bildirimler["konu"].toString().toUpperCase()} için yanıt", style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.indigo, fontSize: 15, decoration: TextDecoration.underline),),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0,),
              child: Wrap(
                children: [
                  Text("Alıcı kullanıcı adı: ",
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: Colors.blueGrey, fontSize: 13), ),
                  Text("${map_bildirimler["gonderen_adi"]}",
                    style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w500, color: Colors.indigo, fontSize: 13), ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0,),
              child: Wrap(
                children: [
                  Text("Alıcı E-mail: ",
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: Colors.blueGrey, fontSize: 13), ),
                  Text("${map_bildirimler["gonderen_mail"]}",
                    style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w500, color: Colors.indigo, fontSize: 13), ),
                ],
              ),
            ),
          ]),
      content: Form( key: formKey_yanitla,
          child: TextFormField(controller: yanitlayici,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Yanıtınızı buraya yazınız."),
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
              validator: (String yanit) {
                if (yanit.isEmpty) {return "Alan boş bırakılamaz.";
                } return null;
              }
          )),
      actions: [
        ElevatedButton(
          child: Text("Gönder"),
          onPressed: () async {
            if(formKey_yanitla.currentState.validate()){
              formKey_yanitla.currentState.save();

              await FirebaseFirestore.instance.collection("bildirimler").add({ "tarih": DateTime.now().toString(),
                "alicilar_mail" : [map_bildirimler["gonderen_mail"]], "alicilar_ad" : [map_bildirimler["gonderen_adi"]],
                "gonderen_adi" : AtaWidget.of(context).kullaniciadi, "gonderen_mail" : AtaWidget.of(context).kullanicimail,
                "konu" : "${map_bildirimler["konu"].toString().toUpperCase()} için yanıt", "mesaj" : yanitlayici.text.trim(), "okuyanlar" : okuyanlar,
              });
              Navigator.of(context, rootNavigator: true).pop("dilaog");
              Navigator.of(context, rootNavigator: true).pop("dilaog");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Yanıtınız başarıyla gönderilmiştir."),
                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
            }

          },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);
  }


  void pasifeOtomatikMail(String kisi_mail) async {
//*******************************************************PASİFE OTOMATİK MAİL GÖNDERİLECEK MAİLER KULLANILACAK**************

    String username = "yoneticikullanici1@gmail.com";
    String password = "Hjnxfg236:)";
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username)
      ..recipients.add(kisi_mail)
      ..subject = "Sınav paylaşımı  ${DateTime.now()}"
      ..text = "Hesabınız pasif durumda olduğu için sizinle paylaşılmak istenen sınavı alamadınız. Sınavları almak için Sınavcım hesabınızı aktif hale getiriniz.";

      final sendReport = await send(message, smtpServer);


  }


}