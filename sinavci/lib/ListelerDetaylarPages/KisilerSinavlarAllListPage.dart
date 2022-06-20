//SCROLLBAR YAPILACAK
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sinavci/Helpers/MesajGonder.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/ListelerDetaylarPages/GonderilenCevaplarPage.dart';
import 'package:sinavci/ListelerDetaylarPages/OlusturulanSinavPage.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/ProfilPage.dart';
import 'package:sinavci/SinavlarKisilerPage.dart';
import 'package:sinavci/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class KisilerSinavlarAllListPage extends StatefulWidget {
  final collectionReference; final storageReference; final doc_id; final gruplari_getir; final grupAdi;
  const KisilerSinavlarAllListPage({Key key, this.collectionReference, this.storageReference, this.doc_id, this.gruplari_getir, this.grupAdi})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return KisilerSinavlarAllListPageState(this.collectionReference, this.storageReference, this.doc_id, this.gruplari_getir, this.grupAdi);
  }
}

enum Secenek { kisi_ekle, grup_ekle, gruplari_getir }

class KisilerSinavlarAllListPageState extends State {
  final collectionReference; final storageReference; final doc_id; bool gruplari_getir; String grupAdi;
  KisilerSinavlarAllListPageState(this.collectionReference, this.storageReference, this.doc_id, this.gruplari_getir, this.grupAdi);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool kisilerim_gruplandir = false; bool hazirladigimSinavlar_gruplandir = false; bool gonderilenSinavlar_gruplandir = false;
  bool kisilerim_grupEkle = false; bool hazirladigimSinavlar_grupEkle = false; bool gonderilenSinavlar_grupEkle = false;
//  String grupAdi = "";
  QuerySnapshot querySnapshot;
  CollectionReference collectionReference_hs; Reference storageReference_hs;
  CollectionReference collectionReference_gs; Reference storageReference_gs;
  File _imageSelected; String imageFileName;
  bool gonderen_secildi = false; String sinavGonderen_id; String sinavGonderen_kullaniciadi;
  dynamic gonderilenSinav_paylasilanId; dynamic gonderilenSinav_paylasilanMap;

  Reklam _reklam = new Reklam();
  @override
  void initState() {
    _reklam.createInterad();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: GestureDetector(
          child: Text( AtaWidget.of(context).AllList_kisilerimden == true ? "Kişilerim"
              : AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true ? "Hazırladığım Sınavlarım" : "Gönderilen Sınavlar",
            style: TextStyle(fontFamily: "Cormorant Garamond",
                fontSize: AtaWidget.of(context).AllList_kisilerimden == true ? 35 : 25,
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
          onTap: (){
            AlertDialog alertDialog = new AlertDialog(
              title: Text( AtaWidget.of(context).AllList_kisilerimden == true ? "KİŞİLERİM"
                  : AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true ? "HAZIRLADIĞIM SINAVLARIM" : "GÖNDERİLEN SINAVLAR"),
            );showDialog(context: context, builder: (_)=> alertDialog);
          },),
        actions: [
/*
          Visibility( visible: AtaWidget.of(context).AllList_kisilerimden == true ? true : false,
            child: IconButton(icon: Icon(Icons.outgoing_mail, color: Colors.white,), iconSize: 25,
              onPressed: () {

              },
            ),
          ),
*/
          IconButton(icon: Icon(Icons.campaign, color: Colors.white,), iconSize: 30,
            onPressed: (){
              AlertDialog alertDialog = new AlertDialog(
                title: Text("BİLGİLENDİRME"),
                content: Container( height: 400,
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Visibility( visible: AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true ? true : false,
                          child: Center(
                            child: Text("* Sınava tıkladığınızda sınavı, sınav için girdiğiniz cevabı, sınava gönderilen cevap ve çözümleri görebilir, "
                                "Hazır Eklenen Sınavı silebilirsiniz.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                        ),
                        Visibility( visible: AtaWidget.of(context).AllList_kisilerimden == true ? true : false,
                          child: Center(
                            child: Text("* Kişinin üzerine tıklayarak kişinin görülmesine izin verdiği bilgilerine ulaşabilirsiniz.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Visibility( visible: AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true ? true : false,
                          child: Center(
                            child: Text("* Sınavınızı düzenlemek, cevap eklemek/cevabı güncellemek/kaldırmak veya kişileriniz ile "
                                "Oluşturulan Sınavı silmek için uzun basınız. ",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                        ),
                        Visibility( visible: AtaWidget.of(context).AllList_kisilerimden == true ? true : false,
                          child: Center(
                            child: Text("* Kişinin üzerine uzun tıkladığınızda *Kişiyi Gruplandır* butonunu kullanarak kişiyi istediğiniz bir kişi grubuna ekleyebilirsiniz.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Visibility( visible: AtaWidget.of(context).AllList_kisilerimden == true ? true : false,
                          child: Center(
                            child: Text("* TÜM KİŞİLERİM alanında iken kişiyi yana kaydırarak yada kişinin üzerine uzun tıkladıktan sonra *Kişiyi Sil* butonunu kullanarak "
                                "kişiyi hesabınızdan kaldırabilirsiniz.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: Text("* TÜM GRUPLARIM alanında iken gruba tıklayarak grubun içine girebilir, yana kaydırarak grubu hesabınızdan kaldırabilir, uzun "
                              "tıklayarak grubu düzenleyebilirsiniz. Bu alanda iken yeni kişi/sınav eklenmez.",
                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: Text("* Bir grubun içerisinde yapılan tüm işlemler sadece grup içi işlemler olacaktır. Yani bir grubun içerisinde yapacağınız kişi/sınav "
                              "silme işlemi kişiyi/sınavı sadece gruptan kaldırır, hesaptan kaldırmaz yada kişi/sınav eklerseniz eklediğiniz kişiyi/sınavı o gruba da "
                              "eklemiş olursunuz. Bir kişi grubunuzda sınav paylaştığınızda, sınav kaldırdığınızda yada bir sınav grubunda kişi eklediğinizde, kişi "
                              "kaldırdığınızda o gruba ait tüm kişilerinize/sınavlarınıza bu işlemi gerçekleştirmiş olursunuz.",
                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                        ),
                      ],
                    ),
                  ),
                ),
              );showDialog(context: context, builder: (_) => alertDialog);
            },),
          PopupMenuButton<Secenek>(
              onSelected: islemSec,
              itemBuilder: (BuildContext) => <PopupMenuEntry<Secenek>>[
                PopupMenuItem<Secenek>(
                  value: Secenek.kisi_ekle,
                  child: Text("KİŞİ EKLE"),
                ),
                PopupMenuItem<Secenek>(
                  value: Secenek.grup_ekle,
                  child: Text("GRUP EKLE"),
                ),
                PopupMenuItem<Secenek>(
                  value: Secenek.gruplari_getir,
                  child: gruplari_getir == true ? Text( AtaWidget.of(context).AllList_kisilerimden == true ? "KİŞİLERİ GETİR" : "SINAVLARI GETİR")
                      : Text("GRUPLARI GETİR"),
                ),
              ]),

        ],
      ),
      body: StreamBuilder(
          stream: AtaWidget.of(context).AllList_kisilerimden == true ?
              gruplari_getir == false ? FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim").orderBy("kullaniciadi").snapshots()
              : grupAdi == "" ? FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim").orderBy("grup_adi").snapshots()
              : FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim").where("eklendigi_grup", isEqualTo: grupAdi).snapshots()

              : AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true ?
                gruplari_getir == false ? FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").orderBy("tarih", descending: true).snapshots()
              : grupAdi == "" ? FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").orderBy("grup_adi").snapshots()
              : FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").where("eklendigi_grup", isEqualTo: grupAdi).snapshots()

              : gruplari_getir == false ? collectionReference.where("paylasilanlar", arrayContains: AtaWidget.of(context).kullaniciadi)
                .orderBy("tarih", descending: true).snapshots()
              : grupAdi == "" ? FirebaseFirestore.instance.collection("users").doc(doc_id).collection("paylasilan_sinavlar_gruplari").snapshots()
              : collectionReference.where("paylasilan_gruplar", arrayContains: grupAdi + "/" + AtaWidget.of(context).kullaniciadi)
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
            querySnapshot = snapshot.data;

            collectionReference_hs = FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar");
            storageReference_hs = FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("sinavlar");
            return Column(children: [
              SizedBox(height: 10,),
              ListTile(
                title: Text( AtaWidget.of(context).AllList_kisilerimden == true ?
                gruplari_getir == false ? "TÜM KİŞİLERİM" : grupAdi == "" ? "TÜM GRUPLARIM" : grupAdi.toUpperCase()

                    : gruplari_getir == false ? "TÜM SINAVLARIM" : grupAdi == "" ? "TÜM GRUPLARIM" : grupAdi.toUpperCase(),
                    style: TextStyle(color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),

                trailing: Visibility( visible: AtaWidget.of(context).AllList_kisilerimden == true
                    ? gruplari_getir == true && grupAdi == "" ? false : true : false,
                  child: IconButton(icon: Icon(Icons.outgoing_mail, size: 30, color: Colors.indigo,), tooltip: "Mesaj Gönder",
                    onPressed: (){
                    if(gruplari_getir == true && grupAdi != "" ) {
                      AlertDialog alertdialog = new AlertDialog(
                        title: Text("Bu sayfadan bu grubun tüm üyelerine yada seçtiğiniz üyelerine mesaj gönderilebilir.",
                          textAlign: TextAlign.justify, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                        actions: [
                          ElevatedButton(child: Text("Mesaj Gönder"), onPressed: (){
                            Navigator.of(context, rootNavigator: true).pop("dialog");
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MesajGonder(querySnapshot: querySnapshot, gruptan: true)));
                          },),
                        ],
                      ); showDialog(context: context, builder: (_) => alertdialog);
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MesajGonder(querySnapshot: querySnapshot, gruptan: false,)));
                    }
                    },
                  ),
                ),

              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 8.0),
                child: Divider(height: 1.5, color: Colors.blueGrey, thickness: 2,),
              ),
              Flexible(
                child: querySnapshot.size == 0 ? Center(
                  child: Text( gruplari_getir == false ? "Gösterilecek herhangi bir veri bulunamamıştır" : grupAdi == "" ? "Herhangi bir grup bulunamamıştır."
                                : "Gruba ait herhangi bir veri bulunamamıştır",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),) :
                ListView.builder(
                  itemCount: querySnapshot.size,
                  itemBuilder: (context, index) {
                    final map_liste = querySnapshot.docs[index].data();
                    final id_liste = querySnapshot.docs[index].id;

                    return Builder(
                      builder: (context) => Column(children: [
                        Visibility( visible: AtaWidget.of(context).AllList_kisilerimden == true ?
                          gruplari_getir == false ? map_liste["kullaniciadi"] == "" ? false : true
                            : grupAdi == "" ? map_liste["grup_adi"] == "" ? false : true : map_liste["kullaniciadi"] == "" ? false : true

                          :  gruplari_getir == false ? map_liste["baslik"] == "" ? false : true
                          : grupAdi == "" ? map_liste["grup_adi"] == "" ? false : true : map_liste["baslik"] == "" ? false : true,
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.radio_button_checked, color: Colors.indigo)),
                            title: AtaWidget.of(context).AllList_kisilerimden ?
                              RichText(text: TextSpan(
                                style: TextStyle(),
                                children: <TextSpan> [
                                  TextSpan(text: gruplari_getir == false ? "KullanıcıAdı: " : grupAdi == "" ? "GrupAdı: " : "KullanıcıAdı: ",
                                    style: TextStyle(color: Colors.black, fontSize: 12),),
                                  TextSpan(text: gruplari_getir == false ? map_liste["kullaniciadi"] : grupAdi == "" ? map_liste["grup_adi"] : map_liste["kullaniciadi"],
                                    style: TextStyle(color: Colors.indigo, fontStyle: FontStyle.italic, fontSize: 15),),
                                ]))
                                : RichText(text: TextSpan(
                                style: TextStyle(),
                                children: <TextSpan> [
                                  TextSpan(text: gruplari_getir == false ? "KullanıcıAdı: " : grupAdi == "" ? "GrupAdı: " : "Sınavın Başlığı: ",
                                    style: TextStyle(color: Colors.black, fontSize: 12),),
                                  TextSpan(text: gruplari_getir == false ? map_liste["baslik"] : grupAdi == "" ? map_liste["grup_adi"] : map_liste["baslik"],
                                    style: TextStyle(color: Colors.indigo, fontStyle: FontStyle.italic, fontSize: 15),),
                                ])),
                            subtitle: AtaWidget.of(context).AllList_kisilerimden ?
                              gruplari_getir == false ? Text("mail: " + map_liste["mail"]): grupAdi == "" ? Text("Açıklama: " + map_liste["grupAciklamasi"])
                                : Text("mail: " + map_liste["mail"])

                                : gruplari_getir == false ? Text("konu: " + map_liste["konu"]): grupAdi == "" ? Text("Açıklama: " + map_liste["grupAciklamasi"])
                                : Text("konu: " + map_liste["konu"]),

                            trailing: Icon(Icons.read_more),

                            onTap: () async {
                              _reklam.showInterad();

                              print("collectionReference: " + collectionReference.toString());

                              if(AtaWidget.of(context).AllList_kisilerimden == true){
                                gruplari_getir == false ?  _kisiProfilineGit(id_liste, map_liste) : grupAdi == "" ?  _gruptakileriGetir(map_liste)
                                    : _kisiProfilineGit(id_liste, map_liste);
                              }
                              else if (AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true) {
                                if(gruplari_getir == true && grupAdi == "") {
                                  _gruptakileriGetir(map_liste);
                                } else {
                                  if(map_liste["olusturulanmi"] == true){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                        OlusturulanSinavPage(map_solusturulan: map_liste, id_solusturulan: id_liste, grid_gorunum: false,
                                            collectionReference: collectionReference_hs, storageReference: storageReference_hs)));
                                  } else {
                                    String _doc_baslik; String _doc_cevaplayan; String _doc_id; String _doc_aciklama; String _doc_gorsel; int _doc_puan;
                                    await collectionReference_hs.doc(id_liste.toString()).collection("soruyu_cevaplayanlar")
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

                                    _sinaviGor(map_liste, id_liste, _doc_baslik, _doc_gorsel, _doc_aciklama, _doc_id, _doc_puan);
                                  }
                                }
                              }
                              else {
                                if(gruplari_getir == true && grupAdi == "") {
                                  _gruptakileriGetir(map_liste);
                                } else {
                                  collectionReference_gs = collectionReference;
                                  storageReference_gs = storageReference;

                                  if(map_liste["olusturulanmi"] == true){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                        OlusturulanSinavPage(map_solusturulan: map_liste, id_solusturulan: id_liste, grid_gorunum: false,
                                            collectionReference: collectionReference_gs, storageReference: storageReference_gs)));
                                  } else if (map_liste["olusturulanmi"] == false){
                                    String _doc_baslik; String _doc_cevaplayan; String _doc_id; String _doc_aciklama; String _doc_gorsel;
                                    int _doc_puan;
                                    await collectionReference_gs.doc(id_liste.toString()).collection("soruyu_cevaplayanlar")
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

                                    _sinaviGor(map_liste, id_liste, _doc_baslik, _doc_gorsel, _doc_aciklama, _doc_id, _doc_puan);
                                  }
                                }
                              }
                            },
                            onLongPress: () async {
                              _reklam.showInterad();

                              if (AtaWidget.of(context).AllList_kisilerimden == true) {
                                if(gruplari_getir == true && grupAdi == "") {
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Yapacağınız işlemi seçiniz: "),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Grubu Düzenle"),
                                        onPressed: () {
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor..."),
                                            action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                          _grubuDuzenle(map_liste, id_liste);
                                      },),
                                      ElevatedButton(
                                        child: Text("Grubu Sil"),
                                        onPressed: () {
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          _grubuSil(map_liste, id_liste);
                                        },),
                                    ],
                                  ); showDialog(context: context, builder: (_) => alertDialog);

                                } else {
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Yapacağınız işlemi seçiniz: "),
                                    content: Text("Kişi silme işleminde silinen kişi ile yeni paylaşım yapamazsınız. Kişi silme işleminin ardından varsa "
                                        "onunla paylaştığınız sınavları göremez, sınavlarınıza/sorularınıza cevap gönderemez. Silinen kişi ile yapılan "
                                        "eski paylaşımlar silme işleminden etkilenmez.", style: TextStyle(fontStyle: FontStyle.italic),
                                      textAlign: TextAlign.justify,),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Kişiyi Gruplandır"),
                                        onPressed: (){
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          kisilerim_gruplandir = true;
                                          hazirladigimSinavlar_gruplandir = false;
                                          gonderilenSinavlar_gruplandir = false;

//                                          setState(() {});
                                          _gruplandir(map_liste, id_liste, null, null);
                                        },
                                      ),
                                      ElevatedButton(
                                          child: Text("Kişiyi Sil"),
                                          onPressed: () async {
                                            Navigator.of(context, rootNavigator: true).pop("dialog");
                                            _kisiyiSil(map_liste, id_liste);
                                          }
                                      ),
                                    ],
                                  );showDialog(context: context, builder: (_) => alertDialog);
                                }

                              }
                              else if (AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true) {

                                if(gruplari_getir == true && grupAdi == "") {
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Yapacağınız işlemi seçiniz: "),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Grubu Düzenle"),
                                        onPressed: () {
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          _grubuDuzenle(map_liste, id_liste);
                                        },),
                                      ElevatedButton(
                                        child: Text("Grubu Sil"),
                                        onPressed: () {
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          _grubuSil(map_liste, id_liste);
                                        },),
                                    ],
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                } else {
                                  showDialog(context: context, builder: (_) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: Text("${map_liste["baslik"]}"),
                                      content: Text( map_liste["olusturulanmi"] == true ?
                                      "başlıklı sınavın *açıklama, *konu, *bitiş tarihi, *ders, *grup adı alanlarını buradan düzenleyebilirsiniz. "
                                          "Sınavınızın diğer alanlarını düzenlemek yada soru eklemek için sınava tıklayınız. "
                                          "Sınavınızı paylaşmak için *Sınavı Paylaş* butonunu kullanınız." :
                                      "başlıklı sınavın *açıklama, *konu, *bitiş tarihi, *ders, *grup adı alanlarını güncellemek, "
                                          "sınavınıza *cevap eklemek/değiştirmek için *Sınavı Düzenle* butonuna, kişileriniz ile sınavınızı "
                                          "paylaşmak için *Sınavı Paylaş* butonu basınız."
                                        ,style: TextStyle(color: Colors.black), textAlign: TextAlign.justify,),
                                      actions: [
//********SINAVI DÜZENLE*********
                                        Wrap( spacing: 5, direction: Axis.horizontal,
                                          children: [
                                            ElevatedButton(
                                                child: Text("Sınavı Düzenle"),
                                                onPressed: () {
                                                  Navigator.of(context, rootNavigator: true).pop('dialog');
                                                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor..."),
                                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                                  _sinaviDuzenle(map_liste, id_liste);
                                                }),
                                            ElevatedButton(
                                                child: Text("Sınavı Sil"),
                                                onPressed: () async {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor..."),
                                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                                                  if(map_liste["olusturulanmi"] == true) {
                                                    List <dynamic> sorular = [];
                                                    await collectionReference_hs.doc(id_liste).collection("sorular").get()
                                                        .then((_sorular) => _sorular.docs.forEach((_soru) {
                                                      sorular.add(_soru["baslik"]);
                                                    }));
                                                    os_sinavSil(map_liste, id_liste, sorular);
                                                  } else {
                                                    hs_sinaviSil(map_liste, id_liste);
                                                  }
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
                                              Navigator.of(context, rootNavigator: true).pop("dialog");
                                              AlertDialog alertDialog = new AlertDialog(
                                                title: Text("Bilgilendirme: ", style: TextStyle(color: Colors.green)),
                                                content: Text("Sınavı tüm kişilerinizin içerisinden tek tek kişi seçerek paylaşabilir yada *Grupta Paylaş* seçeneğini "
                                                    "kullanarak herhangi bir kişi grubunuzda paylaşabilirsiniz. Sınavı bir grupta paylaşmak için daha önce o gruptan kimse "
                                                    "ile sınavı paylaşmamış olmanız gerekmektedir. Aksi takdirde uyarı alacak ve paylaşımınız gerçekleşmeyecektir. ",
                                                    style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.justify,),
                                                actions: [
                                                  MaterialButton( child: Text("Anladım", style: TextStyle( decoration: TextDecoration.underline, fontSize: 18,
                                                      decorationColor: Colors.indigo, decorationThickness: 2, color: Colors.indigo, fontWeight: FontWeight.bold),),
                                                    onPressed: () async {
                                                    bool kisilerim;
                                                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
                                                        .get().then((QuerySnapshot querySnapshot)=>{
                                                      querySnapshot.docs.forEach((_doc) async {
                                                        kisilerim = true;
//                                                        setState(() {});
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
                                                      await collectionReference_hs.doc(id_liste.toString()).collection("paylasilanlar")
                                                          .get().then((QuerySnapshot querySnapshot)=>{
                                                        querySnapshot.docs.forEach((_doc) async {
                                                          paylasilanlar.add(_doc["kullaniciadi"]);
//                                                          setState(() {});
                                                        })
                                                      });

                                                      hsAllList_sinaviPaylas(map_liste, id_liste, paylasilanlar, false);
                                                    }
                                                  },),
                                                ],
                                              ); showDialog(context: context, builder: (_)=> alertDialog);
                                            }),
                                      ],
                                    );
                                  });
                                }
                              }
                              else {
                                if(gruplari_getir == true && grupAdi == ""){}
                                else {
                                  await collectionReference.doc(id_liste.toString()).collection("paylasilanlar").where("mail", isEqualTo: AtaWidget.of(context).kullanicimail)
                                      .limit(1).get().then((value) => value.docs.forEach((element) {
                                    gonderilenSinav_paylasilanId =  element.id;
                                    gonderilenSinav_paylasilanMap = element.data();
//                                    setState(() {});
                                  })
                                  );
                                  kisilerim_gruplandir = false;
                                  hazirladigimSinavlar_gruplandir = false;
                                  gonderilenSinavlar_gruplandir = true;

//                                  setState(() {});
                                  _gruplandir(map_liste, id_liste, gonderilenSinav_paylasilanMap, gonderilenSinav_paylasilanId);
                                }
                              }
                            },
                          ),
                        ),
                        Visibility(visible: AtaWidget.of(context).AllList_kisilerimden == true ?
                          gruplari_getir == false ? map_liste["kullaniciadi"] == "" ? false : true
                            : grupAdi == "" ? map_liste["grup_adi"] == "" ? false : true : map_liste["kullaniciadi"] == "" ? false : true

                            : gruplari_getir == false ? map_liste["baslik"] == "" ? false : true
                            : grupAdi == "" ? map_liste["grup_adi"] == "" ? false : true : map_liste["baslik"] == "" ? false : true,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 8.0),
                              child: Divider(height: 1.5, color: Colors.blueGrey, thickness: 2,),
                            )),
                      ]),
                    );
                  },
                ),
              ),
              Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text( AtaWidget.of(context).AllList_kisilerimden == true ?
                    "**Kişileriniz/Gruplarınız harf sıralamasına göre sıralamasına göre listelenmektedir. Bilgilerini görmek istediğiniz "
                      "Kişi/Grubun üzerine tıklayınız.**"
                    : "**Sınavlarınız tarihe göre sondan başa, gruplarınız ise harf sıralamasına göre listelenmektedir. Gitmek istediğiniz sınavın/grubun üzerine "
                      " üzerine tıklayınız.**",
                    style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]);
          }
      ),
      floatingActionButton: Visibility( visible: AtaWidget.of(context).AllList_kisilerimden == false ? false : gruplari_getir == true && grupAdi == "" ? false : true,
        child: Container(height: 100, width: 100,
          child: FittedBox(
            child: FloatingActionButton.extended(
              heroTag: "kisilerimAllList_SinavPaylasKaldir",
              onPressed: () async {
                dynamic map_liste; dynamic id_liste;
                List <dynamic> kisiler_liste_kullaniciadi = [];
                List <dynamic> kisiler_liste_mail = [];
                for (int i=0; i<querySnapshot.size; i++) {
                  map_liste = querySnapshot.docs[i].data();
                  id_liste = querySnapshot.docs[i].data();
                  kisiler_liste_kullaniciadi.add(map_liste["kullaniciadi"]);
                  kisiler_liste_mail.add(map_liste["mail"]);
                }

                _kisilerAllList_sinavPaylasKaldir(kisiler_liste_kullaniciadi, kisiler_liste_mail);
              },
              icon: Icon(Icons.list_alt, size: 50,),
              label: Text("Sınavları Getir", style: TextStyle(fontWeight: FontWeight.bold,),),
            ),
          ),
        ),
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

  void islemSec(Secenek secenek) async {
    switch (secenek) {
      case Secenek.kisi_ekle:
        if (AtaWidget.of(context).AllList_kisilerimden == true ) {
          if(gruplari_getir == true && grupAdi == "" ){
            AlertDialog alertDialog = new AlertDialog(
              title: Text("Tüm Gruplarım alanına sadece grup ekleyebilirisiniz.", style: TextStyle(color: Colors.red)),
            ); showDialog(context: context, builder: (_)=>alertDialog);
          } else {_kisiEkle(); }
        } else {
          AlertDialog alertDialog = new AlertDialog(
            title: Text("Sadece *KİŞİLERİM* sayfasında iken bu işlemi gerçekleştirebilirsiniz. *SINAVLAR* sayfasında yeni kişi eklenemez. ",
                style: TextStyle(color: Colors.red)),
          ); showDialog(context: context, builder: (_)=>alertDialog);
        }
        break;
      case Secenek.grup_ekle:
        if(gruplari_getir == true && grupAdi != "" ){
          AlertDialog alertDialog = new AlertDialog(
            title: Text("Bir grubun içerisine başka bir grup eklenemez.", style: TextStyle(color: Colors.red)),
          ); showDialog(context: context, builder: (_)=>alertDialog);
        } else {
          kisilerim_grupEkle = true;
          hazirladigimSinavlar_grupEkle = false;
          gonderilenSinavlar_grupEkle = false;

//          setState(() {});
          _grupEkle();
        }
        break;
      case Secenek.gruplari_getir:
        print("collectionReference: " + collectionReference.toString());

        if(gruplari_getir == false) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> KisilerSinavlarAllListPage(collectionReference: collectionReference,
            storageReference: storageReference, doc_id: doc_id, gruplari_getir: true, grupAdi: "")));
        }
        else if(gruplari_getir = true) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> KisilerSinavlarAllListPage(collectionReference: collectionReference,
            storageReference: storageReference, doc_id: doc_id, gruplari_getir: false, grupAdi: "")));
        }

        break;
      default:
    }
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
                bool kisi_var = false;
                String kisi_var_id;
                String kisi_var_kullaniciadi;
                String kisiKontrol_kullanici_id;
                bool karsida_kisi_var = false;

                await FirebaseFirestore.instance.collection("users").where("mail", isEqualTo: mail).get()
                    .then((value) => value.docs.forEach((element) {
                      kisiKontrol_kullaniciadi = element["kullaniciadi"];
                      kisiKontrol_kullanici_id = element.id;
//                  setState(() {});
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
                        kisi_var_id = element.id.toString();
                        kisi_var_kullaniciadi = element["kullaniciadi"];
//                        setState(() {});
                      })
                  );

                  if(kisi_var == true){
                    if(kisi_var_kullaniciadi != kullaniciadi){
                      AlertDialog alertDialog = new AlertDialog(
                        title: Text("Hata: ",
                          style: TextStyle(color: Colors.red),),
                        content: Text("Mail adresi ile kullanıcı adı uyuşmamaktadır. Sistem küçük büyük harf ve boşluğa duyarlıdır."),
                      ); showDialog(context: context, builder: (_) => alertDialog);
                    } else {
                      if(gruplari_getir == true && grupAdi != ""){
                        await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").doc(kisi_var_id)
                            .update({"eklendigi_grup": grupAdi});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kişinizin grubu * $grupAdi * olarak tanımlanmıştır.")));
                        Navigator.of(context, rootNavigator: true).pop("dialog");
                      }
                      else {
                        AlertDialog alertDialog = new AlertDialog(
                          title: Text("Bu mail adresi ile kişilerinize kayıtlı bir kullanıcı mevcuttur. Bilgilerin doğruluğundan emin olunuz.",
                            style: TextStyle(color: Colors.red),),
                        ); showDialog(context: context, builder: (_) => alertDialog);
                      }
                    }

                  } else {
                    if(gruplari_getir == true && grupAdi != ""){
                      await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
                          .add({"kullaniciadi": kullaniciadi, "mail": mail, "grup_adi": "", "grupAciklamasi": "", "eklendigi_grup": grupAdi});

                      if(karsida_kisi_var != true) {
                        await FirebaseFirestore.instance.collection("users").doc(kisiKontrol_kullanici_id).collection("kisilerim")
                            .add({"kullaniciadi": AtaWidget.of(context).kullaniciadi, "mail": AtaWidget.of(context).kullanicimail,
                          "grup_adi": "", "grupAciklamasi": "", "eklendigi_grup": ""});
                      }

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(kullaniciadi + " kişilerinize başarıyla eklenmiştir.")));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kişinizin grubu * $grupAdi * olarak tanımlanmıştır.")));
                      Navigator.of(context, rootNavigator: true).pop("dialog");
                    } else {
                      await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
                          .add({"kullaniciadi": kullaniciadi, "mail": mail, "grup_adi": "", "grupAciklamasi": "", "eklendigi_grup": ""});

                      if(karsida_kisi_var != true) {
                        await FirebaseFirestore.instance.collection("users").doc(kisiKontrol_kullanici_id).collection("kisilerim")
                            .add({"kullaniciadi": AtaWidget.of(context).kullaniciadi, "mail": AtaWidget.of(context).kullanicimail,
                          "grup_adi": "", "grupAciklamasi": "", "eklendigi_grup": ""});
                      }

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(kullaniciadi + " kişilerinize başarıyla eklenmiştir.")));
                      Navigator.of(context, rootNavigator: true).pop("dialog");
                    }
                  }
                }
              }
            },)
        ],
      );
    });
  }

  Future<void> _kisiProfilineGit(dynamic id_kisilerim, dynamic map_kisilerim) async {
    String profil_id; String gelen_kisi_grubu; String gelen_kisi_kullaniciadi;
    await FirebaseFirestore.instance.collection("users").where("mail", isEqualTo: map_kisilerim["mail"]).limit(1).get()
        .then((profil) => profil.docs.forEach((profil) async {
          profil_id = profil.id;
//      setState(() {});

      await FirebaseFirestore.instance.collection("users").doc(profil.id).collection("kisilerim").where("mail", isEqualTo: AtaWidget.of(context).kullanicimail)
          .limit(1).get().then((value) => value.docs.forEach((gelen) {
        gelen_kisi_grubu = gelen["eklendigi_grup"];
        gelen_kisi_kullaniciadi = gelen["kullaniciadi"];

//        setState(() {});
        print("profil_id: " + profil_id);
        print("gelen_kisi_kullaniciadi: " + gelen_kisi_kullaniciadi.toString());
        print("gelen_kisi_grubu: " + gelen_kisi_grubu.toString());
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilPage(doc_id: profil_id, gelen_kisi_grubu: gelen_kisi_grubu)));
      }));
    }));
  }

  void _kisiyiSil(dynamic map_liste, dynamic id_liste) async {
    if(gruplari_getir == true && grupAdi != ""){
      AlertDialog alertDialog = new AlertDialog (
        title: Text("Kişi hesabınızdan da kaldırılsın mı?"),
        actions: [
          ElevatedButton(child: Text("EVET"), onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");
            await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar")
                .where("paylasilanlar", arrayContains: map_liste["kullaniciadi"]).get()
                .then((value) => value.docs.forEach((element) {

              element.reference.update({"paylasilanlar": FieldValue.arrayRemove([map_liste["kullaniciadi"]])});

              element.reference.collection("paylasilanlar")
                  .where("kullaniciadi", isEqualTo: map_liste["kullaniciadi"]).limit(1).get()
                  .then((value) => value.docs.forEach((element) {
                element.reference.delete();
              }));
            }));
            await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
                .doc(id_liste.toString()).delete();

            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Kişi başarıyla hesabınızdan kaldırıldı")));
          },),
          ElevatedButton(child: Text("HAYIR"), onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");
            await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").doc(id_liste.toString())
                .update({"eklendigi_grup": ""});
            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Kişi başarıyla gruptan kaldırıldı")));
          },),
        ],
      ); showDialog(context: context, builder: (_) => alertDialog);
    } else {
      await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar")
          .where("paylasilanlar", arrayContains: map_liste["kullaniciadi"]).get()
          .then((value) => value.docs.forEach((element) {

        element.reference.update({"paylasilanlar": FieldValue.arrayRemove([map_liste["kullaniciadi"]])});

        element.reference.collection("paylasilanlar")
            .where("kullaniciadi", isEqualTo: map_liste["kullaniciadi"]).limit(1).get()
            .then((value) => value.docs.forEach((element) {
          element.reference.delete();
        }));
      }));
      await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
          .doc(id_liste.toString()).delete();

      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Kişi başarıyla kaldırıldı")));
    }
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

                if(AtaWidget.of(context).AllList_kisilerimden == true){
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").where("grup_adi", isEqualTo: grupAdi).limit(1)
                      .get().then((value) => value.docs.forEach((element) {
                    element.exists ? grupVar = true : grupVar = false;
//                    setState(() {});
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
                else if(AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true) {
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").where("grup_adi", isEqualTo: grupAdi).limit(1)
                      .get().then((value) => value.docs.forEach((element) {
                    element.exists ? grupVar = true : grupVar = false;
//                    setState(() {});
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
                else if(AtaWidget.of(context).AllList_gonderilenSinavlarimdan == true) {
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("paylasilan_sinavlar_gruplari")
                      .where("grup_adi", isEqualTo: grupAdi).limit(1).get().then((value) => value.docs.forEach((element) {
                    element.exists ? grupVar = true : grupVar = false;
//                    setState(() {});
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

              }
            },
          ),
        ],
      );
    });
  }

  void _gruplandir(dynamic map_gruplandir,dynamic id_gruplandir, gonderilenSinav_paylasilanMap, gonderilenSinav_paylasilanId) async {

    Widget _gruplandirAlertDialog() {
      return Container(
        height: 300, width: 400,
        child: StreamBuilder(
            stream: AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true ? FirebaseFirestore.instance.collection("users").doc(doc_id)
                .collection("sinavlar").snapshots()
                : AtaWidget.of(context).AllList_kisilerimden == true? FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim").snapshots()
                : FirebaseFirestore.instance.collection("users").doc(doc_id).collection("paylasilan_sinavlar_gruplari").snapshots(),
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

                              if(AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true){
                                if(map_gruplandir["eklendigi_grup"] ==  map_gruplar["grup_adi"]){
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").doc(id_gruplandir.toString())
                                      .update({"eklendigi_grup": ""});
                                } else {
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").doc(id_gruplandir.toString())
                                      .update({"eklendigi_grup":  map_gruplar["grup_adi"]});
                                }
                                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("İşlem başarılı")));
                                Navigator.of(context, rootNavigator: true).pop("dialog");
                              }
                              else if(AtaWidget.of(context).AllList_kisilerimden == true){
                                if(map_gruplandir["eklendigi_grup"] ==  map_gruplar["grup_adi"]){
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").doc(id_gruplandir.toString())
                                      .update({"eklendigi_grup": ""});
                                } else {
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").doc(id_gruplandir.toString())
                                      .update({"eklendigi_grup":  map_gruplar["grup_adi"]});
                                }
                                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("İşlem başarılı")));
                                Navigator.of(context, rootNavigator: true).pop("dialog");
                              }
                              else if (AtaWidget.of(context).AllList_gonderilenSinavlarimdan == true) {
                                List <dynamic> paylasilan_gruplar = [];

                                if(gonderilenSinav_paylasilanMap["eklendigi_grup"] ==  map_gruplar["grup_adi"]){

                                  await collectionReference.doc(id_gruplandir.toString()).collection("paylasilanlar")
                                      .where("mail", isEqualTo: AtaWidget.of(context).kullanicimail)..get().then((_paylasilanlar) {
                                    _paylasilanlar.docs.forEach((_paylasilan) {
                                      _paylasilan.reference.update({"eklendigi_grup": ""});
                                    });
                                  });

                                  await collectionReference.doc(id_gruplandir.toString()).get().then((sinav) {
                                    paylasilan_gruplar = sinav.get("paylasilan_gruplar");
                                    paylasilan_gruplar.remove(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                  });
                                  await collectionReference.doc(id_gruplandir.toString()).update({"paylasilan_gruplar": paylasilan_gruplar});
                                }
                                else {
                                  await collectionReference.doc(id_gruplandir.toString()).collection("paylasilanlar")
                                      .where("mail", isEqualTo: AtaWidget.of(context).kullanicimail).get().then((_paylasilanlar) {
                                        _paylasilanlar.docs.forEach((_paylasilan) {
                                         _paylasilan.reference.update({"eklendigi_grup": map_gruplar["grup_adi"]});
                                        });
                                  });

                                  await collectionReference.doc(id_gruplandir.toString()).get().then((sinav) {
                                    paylasilan_gruplar = sinav.get("paylasilan_gruplar");
                                    paylasilan_gruplar.add(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                  });
                                  await collectionReference.doc(id_gruplandir.toString()).update({"paylasilan_gruplar": paylasilan_gruplar});

                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı")));
                                Navigator.of(context, rootNavigator: true).pop("dialog");

                              }

                            },
                            trailing: AtaWidget.of(context).AllList_gonderilenSinavlarimdan == true ?
                              gonderilenSinav_paylasilanMap["eklendigi_grup"] ==  map_gruplar["grup_adi"] ? Icon(Icons.check_circle) : SizedBox.shrink()
                                : map_gruplandir["eklendigi_grup"] ==  map_gruplar["grup_adi"] ? Icon(Icons.check_circle) : SizedBox.shrink(),
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
              Text("Hazırladığınız sınavlarınız için oluşturduğunuz tüm gruplarınız gösterilmektedir. Hali hazırda seçili sınav eklediğiniz grup varsa yanında tik işareti "
                  "ile belirtilmiştir. Sınavı bir gruba eklemek yada ekli gruptan kaldırmak için grubun üzerine tıklamanız yeterlidir. "
                  "Bu işlem için ayrı bir onay istenmeyecektir.",
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ]),
        content: _gruplandirAlertDialog(),

      );
    });
  }

  void _gruptakileriGetir(dynamic map_liste) {
    grupAdi = map_liste["grup_adi"];

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> KisilerSinavlarAllListPage(collectionReference: collectionReference,
        storageReference: storageReference, doc_id: doc_id, gruplari_getir: true, grupAdi: map_liste["grup_adi"])));
//    setState(() {});
  }

  void _grubuSil(dynamic map_liste, dynamic id_liste) async {
    AlertDialog alertDialog = new AlertDialog(
      title: Text("Dikkat: "), content: Text("Grubu silseniz de gruba ait kişi yada sınavlar silinmez. Sildiğiniz grubun elemanlarına tüm listeden ulaşabilirsiniz."),
      actions: [
        ElevatedButton(child: Text("Grubu Sil"), onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop("dialog");

          if(AtaWidget.of(context).AllList_kisilerimden == true){
            await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").where("eklendigi_grup", isEqualTo: map_liste["grup_adi"])
                .get().then((value) => value.docs.forEach((element) {
              element.reference.update({"eklendigi_grup": ""});
            }));
            await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").doc(id_liste.toString()).delete();

          } else if (AtaWidget.of(context).AllList_hazirladigimSinavlarimdan) {
            await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").where("eklendigi_grup", isEqualTo: map_liste["grup_adi"])
                .get().then((value) => value.docs.forEach((element) {
              element.reference.update({"eklendigi_grup": ""});
            }));

            await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").doc(id_liste.toString()).delete();
          } else {}
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Grup başaraıyla silindi.")));
        },),
      ],
    ); showDialog(context: context, builder: (_)=> alertDialog);
  }

  void _kisilerAllList_sinavPaylasKaldir(List <dynamic> kisiler_liste_kullaniciadi, List <dynamic> kisiler_liste_mail) async {
    Widget _kisilerAllList_sinavPaylasAlertDialog() {
      return Container(
        height: 300, width: 400,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").orderBy("tarih", descending: true).snapshots(),
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
            final _querySnapshot = snapshot.data;


              return ListView.builder(
                  itemCount: _querySnapshot.size,
                  itemBuilder: (BuildContext context, int index){
                    final map_sinavlar = _querySnapshot.docs[index].data();
                    final id_sinavlar = _querySnapshot.docs[index].id;

                    return Column(
                      children: [
                        Visibility( visible: map_sinavlar["baslik"] == "" ? false : true,
                          child: Dismissible( key: UniqueKey(),
                            onDismissed: (direction) async {

                              List <dynamic> paylasilanlar = map_sinavlar["paylasilanlar"];
                              List <dynamic> cakisanlar = [];

                              kisiler_liste_kullaniciadi.forEach((element) {
                                if(paylasilanlar.contains(element)){
                                  cakisanlar.add(element);
                                }
                              });
                              await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinavlar.toString())
                                  .update({"paylasilanlar": FieldValue.arrayRemove(cakisanlar)});

                              for (int i = 0; i<cakisanlar.length; i++){
                                await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinavlar.toString())
                                    .collection("paylasilanlar").where("kullaniciadi", isEqualTo: cakisanlar[i]).get()
                                    .then((value) => value.docs.forEach((element) { element.reference.delete(); }));
                              }


                              _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Sınav yıkarıda listelenen kişilerinizden başarıyla kaldırıldı."),));
                              Navigator.of(context, rootNavigator: true).pop("dialog");
                            },
                            child: ListTile(
                              title: Text(map_sinavlar["baslik"]),
                              subtitle: Text(map_sinavlar["konu"]),
                              onTap: () async {

                                List <dynamic> paylasilanlar = map_sinavlar["paylasilanlar"];
                                List <dynamic> cakisanlar = [];

                                kisiler_liste_kullaniciadi.forEach((element) {
                                  if(paylasilanlar.contains(element)){
                                    cakisanlar.add(element);
                                  }
                                });
                                if(cakisanlar.length != 0){
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Hata: Bu sınav aşağıdaki kişileriniz ile daha önceden paylaşılmıştır.", style: TextStyle(color: Colors.red, fontSize: 15),),
                                    content: ListTile(
                                      title: Text("Çoklu paylaşımlarda sınav daha önceden gruptaki herhangi bir kişiniz ile paylaşılmamış olmalıdır. Aşağıda listelenen "
                                          "kişilerden paylaşımı kaldırarak tekrar buradan çoklu paylaşımı gerçekleştirebilir yada sınavı tek tek kişi seçerek "
                                          "paylaşabilirsiniz."),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 15.0, bottom: 8),
                                        child: Text(cakisanlar.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                                      ),

                                    ),
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                } else {
                                  List <dynamic> paylasilacak_kisiler_liste_kullaniciadi = [];
                                  List <dynamic> paylasilacak_kisiler_liste_mail = [];

                                  kisiler_liste_kullaniciadi.forEach((element) {
                                    if(element != "") {
                                      paylasilacak_kisiler_liste_kullaniciadi.add(element);
                                    }
                                  });
                                  kisiler_liste_mail.forEach((element) {
                                    if(element != "") {
                                      paylasilacak_kisiler_liste_mail.add(element);
                                    }
                                  });
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinavlar.toString())
                                      .update({"paylasilanlar": paylasilacak_kisiler_liste_kullaniciadi});

                                  for (int i = 0; i<paylasilacak_kisiler_liste_kullaniciadi.length; i++){
                                    await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinavlar.toString())
                                        .collection("paylasilanlar").add({"kullaniciadi": paylasilacak_kisiler_liste_kullaniciadi[i],
                                    "mail": paylasilacak_kisiler_liste_mail[i], "eklendigi_grup":""});
                                  }

                                 _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Sınav yukarıda listenen kişileriniz ile başarıyla paylaşıldı."),));
                                  Navigator.of(context, rootNavigator: true).pop("dialog");
                                }

                              },
                            ),
                          ),
                        ),
                        Visibility(visible: map_sinavlar["baslik"] == "" ? false : true,
                            child: Divider(thickness: 3, color: Colors.indigo)),
                      ],
                    );
                  });
            }),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Wrap(children: [
          Text("Sınavı Paylaş/Kaldır: ", style: TextStyle(color: Colors.green,)),
          Divider(thickness: 5, color: Colors.white,),
          Text(gruplari_getir == false ? "Tıkladığınız sınavınız tüm kişileriniz ile paylaşılacaktır. Daha önceden bu sınavı paylaştığınız kişiniz varsa "
              "paylaşımın yapılamayacağı uyarısı alacaksınız. Tüm kişilerinizden kaldırmak istediğiniz sınavı ise yana kaydırmanız yeterlidir."
              : "Tıkladığınız sınavınız grubunuzdaki tüm kişileriniz ile paylaşılacaktır. Eğer bu kişilerden biriyle sınavınızı daha önce paylaştıysanız uyarı alacak "
              "paylaşım yapılamayacaktır. Grubunuzdan kaldırmak istediğiniz sınavı ise yana kaydırmanız yeterlidir.",
              textAlign: TextAlign.justify, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
        ]),
        content: _kisilerAllList_sinavPaylasAlertDialog(),
      );
    });
  }

  _sinaviGor(dynamic map_liste, dynamic id_liste, String _doc_baslik, String _doc_gorsel, String _doc_aciklama, String _doc_id, int _doc_puan) async {
    Widget SetUpAlertDialogContainer() {
      return Container(
        height: 500, width: 500,
        child: Image.network(map_liste["gorsel"], fit: BoxFit.fill,
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
                    TextSpan(text: map_liste["baslik"].toString().toUpperCase(),
                      style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic, fontSize: 20),
                    )
                  ]
              )),
          subtitle: RichText(textAlign: TextAlign.center,
              text: TextSpan(style: TextStyle(),
                  children: <TextSpan>[
                    TextSpan(text: "Konu: "),
                    TextSpan(text: map_liste["konu"],
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic, fontSize: 15),
                    )
                  ]
              )),
          trailing: Builder(
            builder: (context)=> IconButton( color: Colors.white,
              tooltip: map_liste["kilitli"] == true ? "Cevap kilitlidir." : "Cevap kilidi açılmıştır.",
              icon: map_liste["kilitli"] == true ? Icon(Icons.lock): Icon(Icons.lock_open),
              onPressed: ()async{
                print(id_liste.toString());
                if(AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"]){
                  map_liste["kilitli"] == true ?
                  await collectionReference_hs.doc(id_liste.toString()).update({"kilitli" : false})
                      : await collectionReference_hs.doc(id_liste.toString()).update({"kilitli" : true});
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
                  _launchIt(map_liste["gorsel"]);

                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }),
            Visibility(visible: AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"] ? true : false, child: SizedBox(width: 20,)),
            Visibility( visible: AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"] ? true : false,
              child: ElevatedButton(
                  child: Text("Gönderilen Cevaplar"),
                  onPressed: () {
                    dynamic mapSoru; dynamic idSoru;
                    AtaWidget.of(context).hazirSinav_gonderilenCevaplar = true;
                    Navigator.of(context, rootNavigator: true).pop('dialog');

                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        GonderilenCevaplarPage(map_cevaplanan: map_liste, id_cevaplanan: id_liste,
                          collectionReference: collectionReference_hs, storageReference: storageReference_hs, mapSoru: mapSoru,
                          idSoru: idSoru,)));
                  }),
            ),
            Visibility(visible: AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"] ? true : map_liste["kilitli"] == false ? true : false,
                child: SizedBox(width: 20,)),
            Visibility( visible: AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"] ? true
                : map_liste["kilitli"] == false ? true : false,
              child: ElevatedButton(
                  child: Text("Cevabı Gör"),
                  onPressed: () {
                    map_liste["gorsel_cevap"] == null || map_liste["gorsel_cevap"] == " " || map_liste["gorsel_cevap"] == "" ?
                    _metinselCevapGoster(map_liste) : _launchIt(map_liste["gorsel_cevap"]);

                  }),
            ),
            Visibility( visible: AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"] ? false : true,
              child: Visibility( visible: map_liste["kilitli"] == true ? true : false,
                  child: Visibility( visible: _doc_baslik == null ? true : false,
                      child: SizedBox(width: 20,))),
            ),
            Visibility( visible: AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"] ? false : true,
              child: Visibility( visible: map_liste["kilitli"] == true ? true : false,
                child: Visibility( visible: _doc_baslik == null ? true : false,
                  child: ElevatedButton(
                      child: Text("Cevabını Gönder"),
                      onPressed: () {

                        ogrenci_cevapEkle(id_liste, map_liste);
                      }),
                ),
              ),
            ),
            Visibility( visible: AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"] ? false : true,
              child: Visibility( visible: _doc_baslik != null ? true : false,
                child: ElevatedButton(
                    child: Text("Kendi Cevabını Gör"),
                    onPressed: () {
                      ogrenci_CevabiniGor(map_liste, id_liste, _doc_baslik, _doc_gorsel, _doc_aciklama, _doc_id, _doc_puan);
                    }),
              ),
            ),
            Visibility( visible: AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"] ? true : false, child: SizedBox(width: 20,)),
            Visibility( visible: AtaWidget.of(context).kullaniciadi == map_liste["hazirlayan"] ? true : false,
              child: GestureDetector(onDoubleTap: (){},
                child: RaisedButton(
                    color: Colors.amber,
                    child: Text("Sınavı Sil"),
                    onPressed: () async {
                      hs_sinaviSil(map_liste, id_liste);
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

  void ogrenci_cevapEkle(dynamic id_sinav, dynamic map_sinav) async {
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor..."),
                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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

                    } else {
                      await collectionReference_gs.doc(id_sinav.toString()).collection("soruyu_cevaplayanlar").add(
                          {"gorsel": "", "baslik": baslik, "aciklama": newaciklama, "tarih": DateTime.now().toString(), "cevaplayan": cevaplayan, "puan": -1});

                    }

//                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevap başarıyla gönderildi."),));
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
          Visibility( visible: _doc_puan == null || _doc_puan == -1 ? false : true,
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
                              "değiştirilemez. Düzenleme işlemini sonlandırmak için *Onay* butonuna basınız.",
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
                            child: Text(" Cevabı resim olarak eklemek için tıklayınız.",
                              style: TextStyle(fontStyle: FontStyle.italic,
                                  color: Colors.blueGrey),),
                            onTap: (){
                              imageFromGallery(map_sinav, id_sinav);
                            },),
                          SizedBox(height: 15,),
                          GestureDetector(
                            child: Text(" Cevabı belge olarak eklemek için tıklayınız.",
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

//                                            setState(() {});
                                            Navigator.of(context, rootNavigator: true).pop("dialog");
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
              setState(() {
                kisilerim_gruplandir = false;
                hazirladigimSinavlar_gruplandir = true;
                gonderilenSinavlar_gruplandir = false;
              });
              _gruplandir(map_sinav, id_sinav, null, null);
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

  //**** HAZIR SINAVA GÖRSEL CEVAP GETİRME****
  Future imageFromGallery(dynamic map_sinav, dynamic id_sinav) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    _imageSelected = image;

//    setState(() {});
    uploadImage(map_sinav, id_sinav);

  }

  //**** HAZIR SINAVA GÖRSEL CEVAP EKLEME****
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

                  final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                      .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"]).child("cevap_gorseli  "+map_sinav["baslik"]);

                  await ref.putFile(_imageSelected);
                  var downloadUrl = await ref.getDownloadURL();
                  String url = downloadUrl.toString();

                  await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                      .update({"gorsel_cevap": url, "metinsel_cevap": ""});


//                  setState(() {});
                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DersNotlariPage()));

                  Navigator.of(context, rootNavigator: true).pop('dialog');

                }
              },
            ),
          ),
        ],
      );
    });
  }

  void hs_sinaviSil(dynamic map_liste,dynamic id_liste) async {
    try{
      FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
          .child("sinavlar").child("hazir_sinavlar").child(map_liste["baslik"]).listAll()
          .then((value) => value.items.forEach((element) {element.delete();}));

      FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
          .child("sinavlar").child("hazir_sinavlar").child(map_liste["baslik"])
          .child("cevaplayanlarin_gorselleri").listAll()
          .then((value) => value.items.forEach((element) {element.delete();}));


    } catch (e) {debugPrint(e.toString());}

    await collectionReference_hs.doc(id_liste.toString()).delete();

    await collectionReference_hs.doc(id_liste.toString()).collection("soruyu_cevaplayanlar")
        .get().then((snapshot) { for( DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }});
    await collectionReference_hs.doc(id_liste.toString()).collection("paylasilanlar")
        .get().then((snapshot) { for( DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sınav başarıyla silindi"),));
    Navigator.of(context, rootNavigator: true).pop("dialog");
  }

  void os_sinavSil(dynamic map_liste, dynamic id_liste, List sorular) async {
    try {
      FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
          .child("sinavlar").child("olusturulan_sinavlar").child(map_liste["baslik"]).listAll()
          .then((value) => value.items.forEach((element) {element.delete();}));

      for (int i = 0; i <sorular.length ; i++) {

        FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("sinavlar").child("olusturulan_sinavlar")
            .child(map_liste["baslik"]).child("sorular").child(sorular[i]).listAll().then((value) => value.items.forEach((element) {element.delete();}));

        FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("sinavlar").child("olusturulan_sinavlar")
            .child(map_liste["baslik"]).child("sorular").child(sorular[i]).child("şıklar").listAll().then((value) => value.items.forEach((element) {element.delete();}));

        FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("sinavlar").child("olusturulan_sinavlar")
            .child(map_liste["baslik"]).child("sorular").child(sorular[i]).child("cevaplayanlarin_gorselleri").listAll()
            .then((value) => value.items.forEach((element) {element.delete();}));

      }
      await collectionReference_hs.doc(id_liste.toString()).delete();

      await collectionReference_hs.doc(id_liste.toString()).collection("sinavi_cevaplayanlar")
          .get().then((snapshot) { for( DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }});

      await collectionReference_hs.doc(id_liste.toString()).collection("paylasilanlar")
          .get().then((snapshot) { for( DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }});

      await collectionReference_hs.doc(id_liste.toString()).collection("sorular").get().then((_sorular) => _sorular.docs.forEach((_soru) {
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


  void _grubuDuzenle(dynamic map_liste, dynamic id_liste) async {
    TextEditingController _grupadici = TextEditingController();
    TextEditingController _aciklamaci = TextEditingController();

    final _formKey_grupAdi = GlobalKey<FormState>();
    final _formKey_aciklama = GlobalKey<FormState>();

    Widget __grupEkleAlertDialog() {
      return Container(
        height: 200, width: 300,
        child: Column(children: [
          Form(key: _formKey_grupAdi,
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
                        if (value.isEmpty) {return "Alan değişmeyecektir.";
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
                          if (value.isEmpty) {return "Alan değişmeyecektir.";
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
              child: Text("Grubu Düzenle: ", style: TextStyle(fontSize: 20, color: Colors.green, ),)),
          Text("Yeni bilgi girmediğiniz alanlar aynen bırakılacaktır.", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),),
        ]),
        content: __grupEkleAlertDialog(),
        actions: [
          ElevatedButton(
            child: Text("Onayla"),
            onPressed: () async {
              if(_formKey_grupAdi.currentState.validate()){
                _formKey_grupAdi.currentState.save();

                final grupAdi = _grupadici.text.trim();
                final grupAciklamasi = _aciklamaci.text.trim();

                if(AtaWidget.of(context).AllList_kisilerimden == true){
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
                      .where("eklendigi_grup", isEqualTo: map_liste["grup_adi"]).get().then((value) => value.docs.forEach((element) {
                    element.reference.update({"eklendigi_grup": grupAdi});
                  }));
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").doc(id_liste.toString())
                      .update({"grup_adi": grupAdi, });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı")));

                }
                else if(AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true) {
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar")
                      .where("eklendigi_grup", isEqualTo: map_liste["grup_adi"]).get().then((value) => value.docs.forEach((element) {
                    element.reference.update({"eklendigi_grup": grupAdi});
                  }));
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").doc(id_liste.toString())
                      .update({"grup_adi": grupAdi, });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı")));

                }
                else if(AtaWidget.of(context).AllList_gonderilenSinavlarimdan == true) {

//**************PAYLAŞILAN SINAV GRUPLARI EKLENDİĞİ GRUP DÜZENLENECEK***********

                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("paylasilan_sinavlar_gruplari").doc(id_liste.toString())
                      .update({"grup_adi": grupAdi, });
                  await
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz başarıyla oluşturulmuştur")));
                }

              }

              if(_formKey_aciklama.currentState.validate()){
                _formKey_aciklama.currentState.save();

                final grupAdi = _grupadici.text.trim();
                final grupAciklamasi = _aciklamaci.text.trim();

                if(AtaWidget.of(context).AllList_kisilerimden == true){

                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim").doc(id_liste.toString())
                      .update({"grupAciklamasi": grupAciklamasi, });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı")));

                }
                else if(AtaWidget.of(context).AllList_hazirladigimSinavlarimdan == true) {

                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar").doc(id_liste.toString())
                      .update({"grupAciklamasi": grupAciklamasi,});

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı")));

                }
                else if(AtaWidget.of(context).AllList_gonderilenSinavlarimdan == true) {

//**************PAYLAŞILAN SINAV GRUPLARI EKLENDİĞİ GRUP DÜZENLENECEK***********

                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("paylasilan_sinavlar_gruplari").doc(id_liste.toString())
                      .update({"grupAciklamasi": grupAciklamasi,});

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz başarıyla oluşturulmuştur")));
                }

              }
            },
          ),
        ],
      );
    });
  }
//********HAZIRLADIĞIM SINAVLAR SINAV PAYLAŞ******
  void hsAllList_sinaviPaylas(dynamic map_sinav, dynamic id_sinav, var paylasilanlar, bool grupta_paylas) async {
    String paylasilan_uid;

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
                        Dismissible( key: UniqueKey(),
                          onDismissed: (direction) async {
                            await FirebaseFirestore.instance.collection("users").where("kullaniciadi", isEqualTo: map_kisilerim["kullaniciadi"])
                                .get().then((value) => value.docs.forEach((element) {
                              paylasilan_uid = element.id.toString();
                            }));

                            if(grupta_paylas == false){
                              await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                  .collection("paylasilanlar").where("kullaniciadi", isEqualTo: map_kisilerim["kullaniciadi"]).limit(1)
                                  .get().then((QuerySnapshot querySnapshot)=>{
                                querySnapshot.docs.forEach((_doc) async {
                                  _doc.reference.delete();

                                  paylasilanlar.remove(map_kisilerim["kullaniciadi"]);

                                  await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                      .update({"paylasilanlar" : paylasilanlar});

//                                  setState(() {});
                                })
                              });
                            }
//*********SINAVI GRUPTAN SİL kaldır********
                            else {
                              List <dynamic> kisiler_liste_kullaniciadi = [];
                              List <dynamic> kisiler_liste_mail = [];

                              await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim")
                                  .where("eklendigi_grup", isEqualTo: map_kisilerim["grup_adi"]).get().then((value) => value.docs.forEach((element) {
                                kisiler_liste_kullaniciadi.add(element["kullaniciadi"]);
                                kisiler_liste_mail.add(element["mail"]);
                              })
                              );
                              List <dynamic> paylasilanlar = map_sinav["paylasilanlar"];
                              List <dynamic> cakisanlar = [];

                              kisiler_liste_kullaniciadi.forEach((element) {
                                if(paylasilanlar.contains(element)){
                                  cakisanlar.add(element);
                                }
                              });
                              await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                  .update({"paylasilanlar": FieldValue.arrayRemove(cakisanlar)});

                              for (int i = 0; i<cakisanlar.length; i++){
                                await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                    .collection("paylasilanlar").where("kullaniciadi", isEqualTo: cakisanlar[i]).get()
                                    .then((value) => value.docs.forEach((element) { element.reference.delete(); }));
                              }

                            }

                          },
                          child: Visibility( visible: grupta_paylas == false
                              ? map_kisilerim["kullaniciadi"] == "" ? false : true : map_kisilerim["grup_adi"] == "" ? false : true,
                            child: ListTile(
                              title: Text(grupta_paylas == false ? map_kisilerim["kullaniciadi"] : map_kisilerim["grup_adi"] ),
                              subtitle: Text(grupta_paylas == false ? map_kisilerim["mail"] : map_kisilerim["grupAciklamasi"]),
                              onTap: () async {
                                if(grupta_paylas == false){

                                  await FirebaseFirestore.instance.collection("users").where("kullaniciadi", isEqualTo: map_kisilerim["kullaniciadi"])
                                      .get().then((value) => value.docs.forEach((element) {
                                    paylasilan_uid = element.id.toString();
                                  }));

                                  if(paylasilanlar.contains(map_kisilerim["kullaniciadi"]) ){
                                    AlertDialog alertDialog = new AlertDialog (
                                      title: Text("Sınav zaten kişi ile paylaşılmış. Silmek için kişiyi yana kaydırın.",
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                    ); showDialog(context: context, builder: (_) => alertDialog);
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

                                else {
                                  List <dynamic> kisiler_liste_kullaniciadi = [];
                                  List <dynamic> kisiler_liste_mail = [];
                                  
                                  await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("kisilerim")
                                      .where("eklendigi_grup", isEqualTo: map_kisilerim["grup_adi"]).get().then((value) => value.docs.forEach((element) {
                                        kisiler_liste_kullaniciadi.add(element["kullaniciadi"]);
                                        kisiler_liste_mail.add(element["mail"]);
                                      })
                                  );
                                  List <dynamic> paylasilanlar = map_sinav["paylasilanlar"];
                                  List <dynamic> cakisanlar = [];

                                  kisiler_liste_kullaniciadi.forEach((element) {
                                    if(paylasilanlar.contains(element)){
                                      cakisanlar.add(element);
                                    }
                                  });
                                  if(cakisanlar.length != 0){
                                    AlertDialog alertDialog = new AlertDialog(
                                      title: Text("Hata: Bu sınav aşağıdaki kişileriniz ile daha önceden paylaşılmıştır.", style: TextStyle(color: Colors.red, fontSize: 15),),
                                      content: ListTile(
                                        title: Text("Çoklu paylaşımlarda sınav daha önceden gruptaki herhangi bir kişiniz ile paylaşılmamış olmalıdır. Aşağıda listelenen "
                                            "kişilerden paylaşımı kaldırarak tekrar çoklu paylaşımı gerçekleştirebilir yada sınavı tekli olarak paylaşabilirsiniz."),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 15.0, bottom: 8),
                                          child: Text(cakisanlar.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                                        ),

                                      ),
                                    ); showDialog(context: context, builder: (_) => alertDialog);
                                  } else {
                                    List <dynamic> paylasilacak_kisiler_liste_kullaniciadi = [];
                                    List <dynamic> paylasilacak_kisiler_liste_mail = [];

                                    kisiler_liste_kullaniciadi.forEach((element) {
                                      if(element != "") {
                                        paylasilacak_kisiler_liste_kullaniciadi.add(element);
                                      }
                                    });
                                    kisiler_liste_mail.forEach((element) {
                                      if(element != "") {
                                        paylasilacak_kisiler_liste_mail.add(element);
                                      }
                                    });
                                    await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                        .update({"paylasilanlar": paylasilacak_kisiler_liste_kullaniciadi});

                                    for (int i = 0; i<paylasilacak_kisiler_liste_kullaniciadi.length; i++){
                                      await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                                          .collection("paylasilanlar").add({"kullaniciadi": paylasilacak_kisiler_liste_kullaniciadi[i],
                                        "mail": paylasilacak_kisiler_liste_mail[i], "eklendigi_grup":""});
                                    }

                                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Sınav gruptaki kişileriniz ile başarıyla paylaşıldı."),));
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                  }
                                }
                              },
                              trailing: paylasilanlar.contains(map_kisilerim["kullaniciadi"]) ? Icon(Icons.check_circle) : SizedBox.shrink(),
                            ),
                          ),
                        ),
                        Visibility(visible: grupta_paylas == false
                            ? map_kisilerim["kullaniciadi"] == "" ? false : true : map_kisilerim["grup_adi"] == "" ? false : true,
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
                RichText(text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: "Sınavı Paylaş", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 20,)),
                      TextSpan(text: " / ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                          color: Colors.black )),
                      TextSpan(text: "Paylaşımı Kaldır", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 20,)),
                    ]
                )),
                Wrap(
                  children: [
                    Text( grupta_paylas == false ?
                        "* Tüm kişileriniz gösterilmektedir. Halihazırda sınavın paylaşıldığı kişiler yanında işaretli gelmiştir. Bu kişiler ile paylaşımı sonlandırmak "
                        "için yana kaydırınız. Diğer kişiler ile paylaşım yapmak için üzerine tıklamanız yeterlidir. Listeyi güncellemek ""yenile butonuna basınız."
                            : "* Tüm gruplarınız gösterilmektedir. İçerisinde sınavın paylaşıldığı kişinizi barındıran grup ile paylaşım yapamazsınız. "
                        "Diğer gruplar ile paylaşım yapmak için üzerine tıklamanız yeterlidir. ",
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    Divider(thickness: 5, color: Colors.white,),
                    Text("** TÜM KİŞİLERİM sayfasından grupları getirerek sınavınızı seçtiğinizi grup ile de paylaşabilirsiniz.",
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  ],
                ),
              ]),
          content: setupAlertDialogContainer(),
          actions: [
            MaterialButton(
              child: RichText(text: TextSpan( style: TextStyle(decoration: TextDecoration.underline, decorationColor: Colors.indigo, decorationThickness: 3),
                  children: <TextSpan>[
                    TextSpan(text: "Grupta Paylaş", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo,)),
                    TextSpan(text: " / ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                        color: Colors.black )),
                    TextSpan(text: "Paylaşımı Kaldır", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo,)),
                  ]
              )),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop("dialog");
                setState(() {
                  grupta_paylas = true;
                });
                hsAllList_sinaviPaylas(map_sinav, id_sinav, paylasilanlar, true);
              },
            ),
            IconButton(icon: Icon(Icons.refresh_sharp, size: 30, color: Colors.lightBlueAccent,), onPressed: (){
              Navigator.of(context, rootNavigator: true).pop("dialog");
              hsAllList_sinaviPaylas(map_sinav, id_sinav, paylasilanlar, grupta_paylas);
            })
          ]
      );
    });
  }

}

