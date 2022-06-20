import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/ListelerDetaylarPages/GonderilenCevaplarPage.dart';
import 'package:sinavci/ListelerDetaylarPages/OlusturulanSinavPage.dart';
import 'package:sinavci/SinavlarKisilerPage.dart';
import 'package:url_launcher/url_launcher.dart';

class HerkeseAcikSinavlar extends StatefulWidget {
  final gruplari_getir; final grup_adi; final doc_id; final map; final doc_avatar; final gonderen_secildi;
  const HerkeseAcikSinavlar({Key key, this.doc_id, this.gruplari_getir, this.grup_adi, this.map, this.doc_avatar, this.gonderen_secildi}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HerkeseAcikSinavlarState(this.doc_id, this.gruplari_getir, this.grup_adi, this.map, this.doc_avatar, this.gonderen_secildi);
  }

}

enum Secenek_has {grup_ekle, sinavlari_getir, gruplari_getir}

class HerkeseAcikSinavlarState extends State<HerkeseAcikSinavlar>{
  final gruplari_getir; String grup_adi; final doc_id; final map; final doc_avatar; final gonderen_secildi;
  HerkeseAcikSinavlarState(this.doc_id, this.gruplari_getir, this.grup_adi, this.map, this.doc_avatar, this.gonderen_secildi);

  CollectionReference collectionReference_has; Reference storageReference_has;
  File _imageSelected; String imageFileName;
  String soruyu_cevaplayan_id;
  List<dynamic> has_grup_liste = [];
  List<dynamic> has_grup_liste_id = [];
  List<dynamic> has_grupYok_mesaj = [{"grup_adi" : "Henüz Herkese Açık Sınavlar için hiç bir grup oluşturmadınız.",
    "grupAciklamasi": "", "tarih": "ddfdsasdsdasdasdasdasdasdasdasdasasfdsffsddsfds"}];
  List <dynamic> has_gruplar = [];
  List <dynamic> has_gruptakiler = [];
  List<dynamic> has_gruptaSinavYok_mesaj = [{"baslik" : "Bu gruba eklenmiş bir sınav bulunmamaktadır",
    "konu": "", "tarih": "ddfdsasdsdasdasdasdasdasdasdasdasasfdsffsddsfds", "has_iletisim_izin": false, "hazirlayan": "", "mail" : ""}];

  final _formKey = GlobalKey<FormState>();
  List<String> has_baslik = [];
  List<String> has_konu = [];
  List<String> has_hazirlayan = [];
  List<String> has_hazirlayan_id = [];
  List<String> has_mail = [];
  List<String> has_tarih = [];
  List<dynamic> herkese_acik_sinavlar = [];
  List<dynamic> herkese_acik_sinavlar_id = [];

  TextEditingController has_controller = new TextEditingController();
  String filtre;

  Reklam _reklam = new Reklam();

  @override

  void initState() {
    _reklam.createInterad();
    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          title: GestureDetector(
            onTap: () {
              AlertDialog alertdialog = new AlertDialog(
                title: Text("HERKESE AÇIK SINAVLAR",),
              ); showDialog(context: context, builder: (_) => alertdialog);
            },
            child: Text("Herkese Açık Sınavlar", style: TextStyle( fontFamily: "Cormorant Garamond",
                fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),)),
          actions: [
          PopupMenuButton<Secenek_has>( color: Colors.blue.shade100,
            elevation: 50 , onSelected: islemSec,
            itemBuilder: (Buildcontext) => <PopupMenuEntry<Secenek_has>>[
              PopupMenuItem<Secenek_has>(
                value: Secenek_has.grup_ekle,
                child: Wrap(children:[
                  Text("GRUP EKLE", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                  Divider(thickness: 4, color: Colors.black),
                ]),
              ),
              PopupMenuItem<Secenek_has>(
                value: Secenek_has.sinavlari_getir,
                child: Wrap(children: [
                  Text("SINAVLARI GETİR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                  Divider(thickness: 4, color: Colors.black),

                ])
              ),
              PopupMenuItem<Secenek_has>(
                  value: Secenek_has.gruplari_getir,
                  child: Wrap(children: [
                    Text("GRUPLARI GETİR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    Divider(thickness: 4, color: Colors.black),
                  ])
              ),
            ],
          ),
          ],
        ),],
        body: AtaWidget.of(context).herkeseAcik_sinavlar == null || AtaWidget.of(context).herkeseAcik_sinavlar.length == 0 ?
        Center(
          child: ListTile(
          title: Text( gruplari_getir == true ? AtaWidget.of(context).has_grup_liste == null || AtaWidget.of(context).has_grup_liste.length == 0 ?
          "Henüz Herkese Açık Sınavlar için hiç grup oluşturmadınız." : "" :
          "Sınav bulanamadı. Bir önceki sayfadan filtreyi değiştirebilir yada herkese açık sınavların tümünü getirmeyi deneyebilirsiniz."
            ,style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
          ),),
        ) :
        SingleChildScrollView(
        child: Container( height: double.maxFinite, color: Colors.white,
          child: Column(
            children: [
              Visibility( visible: gruplari_getir == true ? false : true,
                child: Wrap(children: [
                  SizedBox(height: 5,),
                  Text("1) Arama yapmak için bir önceki sayfada bulunan Herkese Açık Sınavlar alanını kullanınız.",
                    style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
                  SizedBox(height: 10,),
                  Text("2) Sınavı görmek için tıklamanız, gruplandırmak için uzun basmanız yeterlidir.",
                    style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
                  SizedBox(height: 5,),
                  Text("3) Sadece hazırlayanı tarafından izin verilen sınavlar için çevrimiçi çözüm ekleyebilir veya hazırlayan iletişim bilgilerini görüntüleyebilirsiniz.",
                    style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
                ],),
              ),

              SizedBox(height: 5,),
              Text("Değişikliklerin görüntülenmesi için sağ alttaki butonu kullanarak sayfayı yenilemeniz gerekmektedir.",
                style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              SizedBox(height: 10,),
              Text( AtaWidget.of(context).has_filtre == null ? "Herkese Açık Sınavlar Filtresiz olarak getirilmiştir."
                  : "Herkese Açık Sınavlar *${AtaWidget.of(context).has_filtre.toUpperCase()} filtresine göre getirilmiştir.",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),

              Visibility( visible: gruplari_getir == true ? true : false,
                  child: SizedBox(height: 10,)),
              Visibility( visible: gruplari_getir == true ? true : false,
                child: Text( grup_adi == null ?  "TÜM GRUPLAR" : AtaWidget.of(context).has_grup_adi,
                  style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 20, decoration: TextDecoration.underline,
                  decorationColor: Colors.indigo, decorationStyle: TextDecorationStyle.double, decorationThickness: 3
                ),),
              ),

              SingleChildScrollView( physics: ClampingScrollPhysics(),
                child: Theme( data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all(Colors.indigo),
                  ),
                ),
                  child: Scrollbar( thickness: 10,
                    child: Container( height: 600,
                      child: ListView.builder(
                        itemCount: gruplari_getir == false ? AtaWidget.of(context).herkeseAcik_sinavlar.length
                            : AtaWidget.of(context).has_grup_liste.length == 0 || AtaWidget.of(context).has_grup_liste == null ? has_grupYok_mesaj.length
                            : grup_adi == null ? AtaWidget.of(context).has_grup_liste.length
                            : AtaWidget.of(context).has_gruptakiler.length == 0 || AtaWidget.of(context).has_gruptakiler == null ? has_gruptaSinavYok_mesaj.length
                            : AtaWidget.of(context).has_gruptakiler.length,
                        itemBuilder: (context, index) {
                          final map_sinavGrup = gruplari_getir == false ? AtaWidget.of(context).herkeseAcik_sinavlar[index]
                              : AtaWidget.of(context).has_grup_liste.length == 0 || AtaWidget.of(context).has_grup_liste == null ? has_grupYok_mesaj[index]
                              : grup_adi == null ? AtaWidget.of(context).has_grup_liste[index]
                              : AtaWidget.of(context).has_gruptakiler.length == 0 || AtaWidget.of(context).has_gruptakiler == null ? has_gruptaSinavYok_mesaj[index]
                              : AtaWidget.of(context).has_gruptakiler[index];
                          int sira = index + 1;

                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: GestureDetector(
                              onTap: () async {
                                _reklam.showInterad();
                                collectionReference_has = FirebaseFirestore.instance.collection("users").doc(map_sinavGrup["id_hazirlayan"])
                                    .collection("sinavlar");
                                storageReference_has = FirebaseStorage.instance.ref().child("users").child(map_sinavGrup["hazirlayan"])
                                    .child("sinavlar");

                                if(map_sinavGrup["olusturulanmi"] == true){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                      OlusturulanSinavPage(map_solusturulan: map_sinavGrup, id_solusturulan: map_sinavGrup["id_sinav"], grid_gorunum: false,
                                          collectionReference: collectionReference_has, storageReference: storageReference_has)));
                                } else if(map_sinavGrup["olusturulanmi"] == false){
                                  String _doc_baslik; String _doc_cevaplayan; String _doc_id; String _doc_aciklama; String _doc_gorsel;
                                  int _doc_puan;
                                  await collectionReference_has.doc(map_sinavGrup["id_sinav"].toString()).collection("soruyu_cevaplayanlar")
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

                                  _sinaviGor(map_sinavGrup, map_sinavGrup["id_sinav"], _doc_baslik, _doc_gorsel, _doc_aciklama, _doc_id, _doc_puan);
                                }


                              },
                              onLongPress: () async {
                                _reklam.createInterad();

                                has_gruplar.clear();
                                collectionReference_has = FirebaseFirestore.instance.collection("users").doc(map_sinavGrup["id_hazirlayan"])
                                    .collection("sinavlar");

                                await collectionReference_has.doc(map_sinavGrup["id_sinav"]).get().then((fields) {
                                  has_gruplar = fields.get("has_gruplar");
                                });
                                _gruplandir(map_sinavGrup, map_sinavGrup["id_sinav"]);

                              },
                              child: gruplari_getir == false ?
                              Card( elevation: 20, color: Colors.blue.shade100,
                                child: Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar( child: Text(sira.toString(), style: TextStyle(fontWeight: FontWeight.bold),)),
                                        title: Text(map_sinavGrup["baslik"],
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        subtitle: Wrap( direction: Axis.vertical, spacing: 4,
                                            children: [
                                              Text(map_sinavGrup["konu"]),
                                              Visibility( visible: map_sinavGrup["has_iletisim_izin"] == true ? true : false,
                                                child: Card( elevation: 10, color: Colors.blue.shade100,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Container(color: Colors.blue.shade100,
                                                      child: Wrap( direction: Axis.vertical, spacing: 2,
                                                        children: [
                                                          Text("HAZIRLAYAN: "+ map_sinavGrup["hazirlayan"], style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic)),
                                                          Text("E-mail: "+ map_sinavGrup["mail"], style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ] ),
                                        trailing: Wrap(direction: Axis.vertical,
                                              children: [
                                                Text(map_sinavGrup["tarih"].toString().substring(0,10)),
                                                Text(map_sinavGrup["tarih"].toString().substring(11,16),)
                                              ]
                                          ),
                                      ),
                                    ]
                                ),
                              )
                                  :
                              gruplari_getir == true && grup_adi != null ?
                              Card( elevation: 20, color: AtaWidget.of(context).has_gruptakiler.length == 0 || AtaWidget.of(context).has_gruptakiler == null
                                  ? Colors.orange : Colors.blue.shade100,
                                child: Column(
                                    children: [
                                      ListTile(
                                        leading: AtaWidget.of(context).has_gruptakiler.length == 0 || AtaWidget.of(context).has_gruptakiler == null
                                            ? Icon(Icons.info_outline, color: Colors.white, size: 40,)
                                            : CircleAvatar( child: Text(sira.toString(), style: TextStyle(fontWeight: FontWeight.bold),)),
                                        title: Text(map_sinavGrup["baslik"],
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        subtitle: Wrap( direction: Axis.vertical, spacing: 4,
                                            children: [
                                              Text(map_sinavGrup["konu"]),
                                              Visibility( visible: map_sinavGrup["has_iletisim_izin"] == true ? true : false,
                                                child: Card( elevation: 10, color: Colors.blue.shade100,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Container(color: Colors.blue.shade100,
                                                      child: Wrap( direction: Axis.vertical, spacing: 2,
                                                        children: [
                                                          Text("HAZIRLAYAN: "+ map_sinavGrup["hazirlayan"],
                                                              style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic)),
                                                          Text("E-mail: "+ map_sinavGrup["mail"],
                                                              style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ] ),
                                        trailing: Visibility( visible: AtaWidget.of(context).has_gruptakiler.length == 0 || AtaWidget.of(context).has_gruptakiler == null
                                            ? false : true,
                                          child: Wrap(direction: Axis.vertical,
                                              children: [
                                                Text(map_sinavGrup["tarih"].toString().substring(0,10)),
                                                Text(map_sinavGrup["tarih"].toString().substring(11,16),)
                                              ]
                                          ),
                                        ),
                                      ),
                                    ]
                                ),
                              )
                                  :
                              Wrap( children: [
                                ListTile(
                                  leading: Visibility( visible: AtaWidget.of(context).has_grup_liste.length == 0
                                      || AtaWidget.of(context).has_grup_liste == null ? false : true,
                                      child: CircleAvatar( child: Text(sira.toString(), style: TextStyle(fontWeight: FontWeight.bold),))),

                                  title: Text(map_sinavGrup["grup_adi"],
                                      style:  AtaWidget.of(context).has_grup_liste.length == 0
                                          || AtaWidget.of(context).has_grup_liste == null ? TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)
                                          : TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),

                                  subtitle: Visibility( visible: AtaWidget.of(context).has_grup_liste.length == 0
                                      || AtaWidget.of(context).has_grup_liste == null ? false : true,
                                      child: Text(map_sinavGrup["grupAciklamasi"])),
                                  trailing: Visibility( visible: AtaWidget.of(context).has_grup_liste.length == 0
                                      || AtaWidget.of(context).has_grup_liste == null ? false : true,
                                    child: Wrap(direction: Axis.vertical,
                                        children: [
                                          Text(map_sinavGrup["tarih"].toString().substring(0,10)),
                                          Text(map_sinavGrup["tarih"].toString().substring(11,16),)
                                        ]
                                    ),
                                  ),
                                  onTap: (){
                                    _reklam.showInterad();

                                    AtaWidget.of(context).has_grup_adi = map_sinavGrup["grup_adi"];
                                    has_gruptakiler.clear();
                                    for( int i = 0; i<AtaWidget.of(context).herkeseAcik_sinavlar.length; i++) {

                                      AtaWidget.of(context).herkeseAcik_sinavlar[i]["has_gruplar"].forEach((element) {
                                        if(element == "${map_sinavGrup["grup_adi"]}/${AtaWidget.of(context).kullaniciadi}") {
                                          has_gruptakiler.add(AtaWidget.of(context).herkeseAcik_sinavlar[i]);
                                        }
                                      });

                                    }
                                    AtaWidget.of(context).has_gruptakiler =  has_gruptakiler;

                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                                        HerkeseAcikSinavlar(gruplari_getir: true, grup_adi: map_sinavGrup["grup_adi"], doc_id: doc_id
                                            , map: map, gonderen_secildi: gonderen_secildi, doc_avatar: doc_avatar
                                        )));
                                  },
                                  onLongPress: () async {
                                    _reklam.showInterad();

                                    dynamic id_grup;
                                    if(AtaWidget.of(context).has_grup_liste_id != null || AtaWidget.of(context).has_grup_liste.length != 0){
                                      id_grup = AtaWidget.of(context).has_grup_liste_id[index];
                                    }

                                    if(has_gruplar.isNotEmpty){ has_gruplar.clear();}

                                    await FirebaseFirestore.instance.collection("users").get().then((kullanicilar) => kullanicilar.docs.forEach((kullanici) {
                                      kullanici.reference.collection("sinavlar").where("herkeseAcik", isEqualTo: true)
                                          .where("has_gruplar", arrayContains: "${map_sinavGrup["grup_adi"]}/${AtaWidget.of(context).kullaniciadi}").get()
                                          .then((sinavlar) => sinavlar.docs.forEach((sinav) {
                                        has_gruplar = sinav.data()["has_gruplar"];
                                      }));
                                    }));

                                    AtaWidget.of(context).has_grup_adi = map_sinavGrup["grup_adi"];
                                    has_gruptakiler.clear();
                                    for( int i = 0; i<AtaWidget.of(context).herkeseAcik_sinavlar.length; i++) {

                                      AtaWidget.of(context).herkeseAcik_sinavlar[i]["has_gruplar"].forEach((element) {
                                        if(element == "${map_sinavGrup["grup_adi"]}/${AtaWidget.of(context).kullaniciadi}") {
                                          has_gruptakiler.add(AtaWidget.of(context).herkeseAcik_sinavlar[i]);
                                        }
                                      });

                                    }
                                    AtaWidget.of(context).has_gruptakiler =  has_gruptakiler;

                                    SimpleDialog simpledialog = new SimpleDialog(
                                      title: Text("Yapmak istediğiniz işlemi seçiniz: ", textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                      children: [
                                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                          SimpleDialogOption(child: Text("Grubu Düzenle", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                            onPressed: (){
                                              _grubuDuzenle(map_sinavGrup, id_grup);
                                            },
                                          ),
                                          SimpleDialogOption(child: Text("Grubu Sil", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                            onPressed: (){
                                              _grubuSil(map_sinavGrup, id_grup);
                                            },
                                          )
                                        ],),
                                      ],
                                    ); showDialog(context: context, builder: (_)=> simpledialog);
                                  },
                                ),
                                Container( padding: EdgeInsets.only(left: 20, right: 10),
                                    child: Divider(thickness: 2, color: Colors.indigo,)),
                              ],),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
      floatingActionButton: Container( height: 50,
        child: FittedBox(
          child: FloatingActionButton( heroTag: "sayfayı_yenile", elevation: 10, child: Icon(Icons.refresh_rounded, size: 50, color: Colors.indigo,),
            backgroundColor: Colors.white,
            onPressed: () async {
              _reklam.showInterad();

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

              sayfayi_yenile();
/*
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                  HerkeseAcikSinavlar(gruplari_getir: false, grup_adi: null, doc_id: doc_id
                      , map: map, gonderen_secildi: gonderen_secildi, doc_avatar: doc_avatar
                  )));
*/
          },),
        ),
      ),
      bottomNavigationBar: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),),
    );
  }

  void islemSec(Secenek_has secenek) async {

    switch (secenek) {
      case Secenek_has.grup_ekle:
        if(gruplari_getir == true && grup_adi != null ){
          AlertDialog alertDialog = new AlertDialog(
            title: Text("Bir grubun içerisine başka bir grup eklenemez.", style: TextStyle(color: Colors.red)),
          ); showDialog(context: context, builder: (_)=>alertDialog);
        } else {
//          setState(() {});
          _grupEkle();
        }
        break;
      case Secenek_has.sinavlari_getir:

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
              HerkeseAcikSinavlar(gruplari_getir: false, grup_adi: null, doc_id: doc_id, map: map, gonderen_secildi: gonderen_secildi, doc_avatar: doc_avatar)));

        break;
      case Secenek_has.gruplari_getir:

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
              HerkeseAcikSinavlar(gruplari_getir: true, grup_adi: null, doc_id: doc_id, map: map, gonderen_secildi: gonderen_secildi, doc_avatar: doc_avatar)));

        break;
      default:
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

                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("herkeseAcik_sinavlar_gruplari")
                      .where("grup_adi", isEqualTo: grupAdi).limit(1).get().then((value) => value.docs.forEach((element) {
                    element.exists ? grupVar = true : grupVar = false;
                    setState(() {});
                  }));

                  if(grupVar == true){ AlertDialog alertDialog = new AlertDialog (
                    title: Text("Aynı isimle oluşturulmuş bir grup mevcuttur. Lütfen farklı bir isimle grubu yeniden oluşturunuz.", style: TextStyle(color: Colors.red),),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                  }
                  else{
                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("herkeseAcik_sinavlar_gruplari")
                        .add({"grup_adi": grupAdi, "grupAciklamasi": grupAciklamasi, "tarih": DateTime.now().toString(), });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz başarıyla oluşturulmuştur")));
                    Navigator.of(context, rootNavigator: true).pop("dialog");
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
            stream: FirebaseFirestore.instance.collection("users").doc(doc_id).collection("herkeseAcik_sinavlar_gruplari").snapshots(),
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

                                if(has_gruplar.contains(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi)){
                                  has_gruplar.remove(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                  await collectionReference_has.doc(id_gruplandir).update({"has_gruplar": has_gruplar});

                                  Navigator.of(context, rootNavigator: true).pop("dialog");

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                }
                                else {
                                  has_gruplar.add(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                  await collectionReference_has.doc(id_gruplandir).update({"has_gruplar": has_gruplar});

                                  Navigator.of(context, rootNavigator: true).pop("dialog");

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                }

                            },
                            trailing: has_gruplar.contains(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi)
                                ? Icon(Icons.check_circle) : SizedBox.shrink(),),
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
                  await collectionReference_has.doc(id_sinav.toString()).update({"kilitli" : false})
                      : await collectionReference_has.doc(id_sinav.toString()).update({"kilitli" : true});
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
                          collectionReference: collectionReference_has, storageReference: storageReference_has, mapSoru: mapSoru,
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

                      final DocumentReference _ref = await collectionReference_has.doc(id_sinav.toString()).collection("soruyu_cevaplayanlar").add(
                          {"gorsel": url, "baslik": baslik, "aciklama": newaciklama, "tarih": DateTime.now().toString(), "cevaplayan": cevaplayan, "puan": -1});
                      soruyu_cevaplayan_id = _ref.id.toString();

                    } else {
                      await collectionReference_has.doc(id_sinav.toString()).collection("soruyu_cevaplayanlar").add(
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
              collectionReference_has.doc(id_sinav).collection("soruyu_cevaplayanlar")
                  .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                  .get().then((QuerySnapshot querySnapshot)=>{
                querySnapshot.docs.forEach((_doc) async {

                  collectionReference_has.doc(id_sinav).collection("soruyu_cevaplayanlar").doc(_doc.id.toString()).delete();

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

  void sayfayi_yenile() async {
    AlertDialog alertDialog = new AlertDialog(
      title: Text("Aşağıdaki filterlerden birini seçerek sayfayı yenileyin."),
      actions: [
        Container(height: 280,
            child: Column( mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            )
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
              HerkeseAcikSinavlar(doc_id: doc_id, gruplari_getir: false, grup_adi: null, map: map,
                  gonderen_secildi: gonderen_secildi, doc_avatar: doc_avatar)));
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                    HerkeseAcikSinavlar(doc_id: doc_id, gruplari_getir: false, grup_adi: null, map: map,
                        gonderen_secildi: gonderen_secildi, doc_avatar: doc_avatar)));
              },
              ),
            ],
          ); showDialog(context: context, builder: (_) => alertdialog);

        },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertdialog);
  }

  void _grubuSil(dynamic map_grup, dynamic id_grup) async {

    AlertDialog alertDialog = new AlertDialog(
      title: Text("Dikkat: "), content: Text("Grubu silseniz sınavlar silinmez. Sildiğiniz grubun sınavlarına tüm listeden ulaşabilirsiniz."),
      actions: [
        ElevatedButton(child: Text("Grubu Sil"), onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop("dialog");
          Navigator.of(context, rootNavigator: true).pop("dialog");
          has_gruptakiler.remove(map_grup);
          has_gruplar.remove("${map_grup["grup_adi"]}/${AtaWidget.of(context).kullaniciadi}");

          await FirebaseFirestore.instance.collection("users").get().then((kullanicilar) => kullanicilar.docs.forEach((kullanici) {
            kullanici.reference.collection("sinavlar").where("herkeseAcik", isEqualTo: true)
                .where("has_gruplar", arrayContains: "${map_grup["grup_adi"]}/${AtaWidget.of(context).kullaniciadi}").get()
                .then((sinavlar) => sinavlar.docs.forEach((sinav) {
                  sinav.reference.update({"has_gruplar": has_gruplar});
            }));
          }));


          await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("herkeseAcik_sinavlar_gruplari")
              .where("grup_adi", isEqualTo: map_grup["grup_adi"]).get().then((gruplar) => gruplar.docs.forEach((grup) {
                grup.reference.delete();
          }));
          AtaWidget.of(context).has_gruptakiler.remove(map_grup["grup_Adi"]);
          AtaWidget.of(context).has_grup_liste.remove(map_grup["grup_Adi"]);

        },),
      ],
    ); showDialog(context: context, builder: (_)=> alertDialog);
  }

  void _grubuDuzenle(dynamic map_grup, dynamic id_grup) async {

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

                if(AtaWidget.of(context).has_gruptakiler == null || AtaWidget.of(context).has_gruptakiler.length == 0) {
                  await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("herkeseAcik_sinavlar_gruplari").doc(id_grup)
                      .update({"grup_adi" : grupAdi});
                  Navigator.of(context, rootNavigator: true).pop("dialog");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grup adı başarı ile güncellendi."),
                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                } else {
                  AlertDialog alertdialog = new AlertDialog(
                    title: Text("Grupta sınav bulunmaktadır. Sınavı bulunan grupların adları değiştirilemez.",
                      style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold),),
                  ); showDialog(context: context, builder: (_) => alertdialog);
                }
              }

              if(_formKey_aciklama.currentState.validate()){
                _formKey_aciklama.currentState.save();

                final grupAciklamasi = _aciklamaci.text.trim();
                await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("herkeseAcik_sinavlar_gruplari").doc(id_grup)
                    .update({"grupAciklamasi" : grupAciklamasi});
                Navigator.of(context, rootNavigator: true).pop("dialog");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grup açıklamsı başarı ile güncellendi."),
                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
              }
            },
          ),
        ],
      );
    });
  }

}