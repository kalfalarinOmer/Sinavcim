
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/ListelerDetaylarPages/OlusturulanSinavPage.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/SinavlarKisilerPage.dart';
import 'package:sinavci/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GonderilenCevaplarPage extends StatefulWidget {
  final map_cevaplanan; final id_cevaplanan; final collectionReference; final storageReference; final mapSoru; final idSoru;
  const GonderilenCevaplarPage({Key key, this.map_cevaplanan, this.id_cevaplanan, this.collectionReference, this.storageReference, this.mapSoru, this.idSoru,})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return GonderilenCevaplarPageState(this.map_cevaplanan, this.id_cevaplanan, this.collectionReference, this.storageReference, this.mapSoru, this.idSoru,);
  }
}

class GonderilenCevaplarPageState extends State{
  final map_cevaplanan; final id_cevaplanan; final collectionReference; final storageReference; final mapSoru; final idSoru;
  GonderilenCevaplarPageState(this.map_cevaplanan, this.id_cevaplanan, this.collectionReference, this.storageReference, this.mapSoru, this.idSoru,);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool kisinin_sinavAnalizi_kapat = false;
  List <dynamic> sinaviCevaplayanin_cevapladigiSorular = [];
  List <dynamic> sinaviCevaplayanin_dogruCevaplar = [];
  int sinaviCevaplayanin_notu = 0;
  int sinav_toplamPuan = 0;
  var sorularin_puanlari = [];
  String sinaviCevaplayanin_ismi;
  List <dynamic> sorularin_basliklari = [];
  int cevaplayanin_notu = 0;
  List <dynamic> cevaplarin_puanlari = [];
  List <dynamic> isaretledigi_siklar = [];

  bool sinavAnalizi_kapat = false;
  List <dynamic> testSorulari = [];
  List <dynamic> klasikSorular = [];
  List <dynamic> sinaviCevaplayanlar = [];
  List <dynamic> sinaviCevaplayanlar_puanlar = [];
  int cevaplayanlar_toplamPuan = 0;
  List <dynamic> paylasilanlar = [];
  List <dynamic> soru_isaretleyenler_sik = [];
  List <dynamic> dogruSik_isaretleyenler = [];

  List <dynamic> soruyu_cevaplayanlar_puanlar = [];
  List <dynamic> soruyu_dogruCevaplayanlar = [];

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
          child: AtaWidget.of(context).hazirSinav_gonderilenCevaplar == true ||  AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar == true ?
            Text("${map_cevaplanan["baslik"]}** i??in g??nderilen cevaplar ")
              : AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar == true ?
            Text("${mapSoru["baslik"]}** i??in g??nderilen cevaplar ", style: TextStyle(color: Colors.lightGreenAccent  ),)
              : Text("${mapSoru["baslik"]}** i??in yap??lan i??aretlemeler:  ", style: TextStyle(color: Colors.lightGreenAccent),),
          onTap: (){
            AlertDialog alertDialog = new AlertDialog(
              title: AtaWidget.of(context).hazirSinav_gonderilenCevaplar == true ||  AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar == true ?
              Text("${map_cevaplanan["baslik"]}** i??in g??nderilen cevaplar: ")
                  : AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar == true ?
              Text("${mapSoru["baslik"]}** i??in g??nderilen cevaplar ", style: TextStyle(color: Colors.green),)
                  : Text("${mapSoru["baslik"]}** i??in yap??lan i??aretlemeler:  ", style: TextStyle(color: Colors.green),)
            );showDialog(context: context, builder: (_)=> alertDialog);
          },),
        actions: [
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ba??ar??yla ????k???? yap??ld??"),));
                }),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: AtaWidget.of(context).hazirSinav_gonderilenCevaplar == true ?
                collectionReference.doc(id_cevaplanan.toString()).collection("soruyu_cevaplayanlar").orderBy("tarih").snapshots()

              : AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar == true ?
                collectionReference.doc(id_cevaplanan.toString()).collection("sorular").doc(idSoru.toString()).collection("soruyu_cevaplayanlar")
                    .orderBy("tarih", descending: true).snapshots()

              : AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar == true ?
                collectionReference.doc(id_cevaplanan.toString()).collection("sinavi_cevaplayanlar").orderBy("tarih", descending: true).snapshots()

              : collectionReference.doc(id_cevaplanan.toString()).collection("sorular").doc(idSoru.toString()).collection("isaretleyenler")
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
            final querySnapshot = snapshot.data;

            return Column(children: [
              MaterialButton(child:RichText(text: TextSpan(
                  style: TextStyle(),
                  children: <TextSpan>[
                    TextSpan(text: AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar == true
                        || AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == true ? "Sorunun Analizini g??rmek i??in" : "S??nav??n Analizini g??rmek i??in",
                        style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
                    TextSpan(text: "  Buraya t??klay??n??z", style: TextStyle(color: Colors.indigo, decoration: TextDecoration.underline, decorationColor: Colors.indigo,
                        decorationThickness: 3, decorationStyle: TextDecorationStyle.solid,
                        fontSize: 17, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                  ])),
                onPressed: () {
                _reklam.showInterad();

                 AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar == true ? olusturulanSinav_AnalizBilgileriniGetir() 
                     : AtaWidget.of(context).hazirSinav_gonderilenCevaplar == true ? hazirSinav_AnalizBilgileriniGetir(map_cevaplanan)
                     : sorunun_analizBilgileriniGetir();

                  AlertDialog alertDialog = new AlertDialog(
                    title: Text("Bilgilendirme:", style: TextStyle(color: Colors.green)),
                    content: Text(AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar == true ? "Bu analizde soru hakk??nda genel bilgilendirme, ????z??m g??nderenler,"
                        " test sorusu ise i??aretlenen ????klar ve i??aretleyenler, do??ru cevaplama/ i??aretleme say??s?? ve listesi ile sorunun puan ortalamas?? verilmektedir."
                        : "Bu analizde s??nav??n??z hakk??nda genel bilgilendirme ve s??nav??n??za kat??lan kat??l??mc??lar??n puan ortalamas?? ve ba??ar?? y??zdesi"
                        " verilmektedir.", textAlign: TextAlign.justify,),
                    actions: [
                      ElevatedButton(child: Text("Vazge??"), onPressed: () {
                        AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar == true ? sinavAnalizi_kapat = true : false;
                        kisinin_sinavAnalizi_kapat = false;

//                        setState(() {});
                        _analiziKapat();
                        Navigator.of(context, rootNavigator: true).pop("dialog");
                      },),

                      ElevatedButton(child: Text("Analizi G??r"),
                        onPressed: () async {
                          Navigator.of(context, rootNavigator: true).pop("dialog");

                          AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar == true ? 
                          olusturulanSinav_AnaliziniYap(testSorulari, klasikSorular, sinaviCevaplayanlar, sinaviCevaplayanlar_puanlar)
                              : AtaWidget.of(context).hazirSinav_gonderilenCevaplar == true ? hazirSinav_AnaliziniYap()
                              : sorunun_analiziniYap();
                        },
                      ),
                    ],
                  ); showDialog(barrierDismissible: false, context: context, builder: (_) => alertDialog);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 5, top: 5),
                child: Divider(thickness: 2, color: Colors.blueGrey,),
              ),
              Flexible(
                child: querySnapshot.size == 0 ? Center(
                  child: Text("G??nderilen herhangi bir cevap bulunamad??.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),) :
                ListView.builder(
                  itemCount: querySnapshot.size,
                  itemBuilder: (context, index) {
                    final map_cevaplayanlar = querySnapshot.docs[index].data();
                    final id_cevaplayanlar = querySnapshot.docs[index].id;
                    String doc_sik;
                    return Builder(
                      builder: (context) => Column(children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text("${index + 1}"),),

                          title: RichText(text: TextSpan(
                            style: TextStyle(),
                            children: <TextSpan> [
                              TextSpan(text: AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == true ? "????aretleyen: " : "G??nderen: ",
                                style: TextStyle(color: Colors.black, fontSize: 12),),
                              TextSpan(text: map_cevaplayanlar["cevaplayan"], style: TextStyle(color: Colors.indigo,
                                  fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, fontSize: 15),),
                            ])),

                          subtitle: Text( AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == false ? 
                              "tarih: " + map_cevaplayanlar["tarih"].toString().substring(0, 16) 
                              : AtaWidget.of(context).dogruSiktan_puanCevaplayan.contains(map_cevaplayanlar["cevaplayan"])
                              ? "????aretlenen ????k do??rudur. Ki??i sorudan tam puan alm????t??r." : "????aretlenen ????k yanl????t??r. Ki??i sorudan puan alamam????t??r."
                            ),

                          trailing: AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == false ?
                            Visibility( visible: map_cevaplayanlar["puan"] == null || map_cevaplayanlar["puan"] == -1 ? false : true,
                              child: Text("Puan: " + map_cevaplayanlar["puan"].toString()))
                              : Text(map_cevaplayanlar["sik"], style: TextStyle(
                              color: AtaWidget.of(context).dogruSiktan_puanCevaplayan.contains(map_cevaplayanlar["cevaplayan"]) ? Colors.green : Colors.red,
                              fontSize: 20, fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),),

                          onTap: () async {
                            _reklam.showInterad();

                            if(AtaWidget.of(context).hazirSinav_gonderilenCevaplar == true ) {
                              doc_sik = null;
                              gonderiGor_gorseller(map_cevaplayanlar["gorsel"], map_cevaplayanlar["baslik"], map_cevaplayanlar["aciklama"]
                                  , map_cevaplayanlar, id_cevaplayanlar, doc_sik, null, null);
                            }
                            else if (AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar == true) {
                              await collectionReference.doc(id_cevaplanan).collection("sorular")
                                  .doc(idSoru.toString()).collection("isaretleyenler").where("cevaplayan", isEqualTo: map_cevaplayanlar["cevaplayan"])
                                  .get().then((QuerySnapshot querySnapshot)=>{
                                querySnapshot.docs.forEach((doc) {
                                  doc_sik = doc["sik"];
                                })
                              });

                              gonderiGor_gorseller(map_cevaplayanlar["gorsel"], map_cevaplayanlar["baslik"], map_cevaplayanlar["aciklama"]
                                  , map_cevaplayanlar, id_cevaplayanlar, doc_sik, mapSoru, idSoru);
                            }
                            else if (AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar == true){
                              gonderiGor_gorseller_olusturulanSinavdan(map_cevaplayanlar, id_cevaplayanlar);
                            }
                          },
                          onLongPress: (){
                            _reklam.showInterad();

                            if(AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar == true){
                              kisinin_sinavAnalizBilgileriniGetir(map_cevaplayanlar, id_cevaplayanlar);

                              AlertDialog alertDialog = new AlertDialog(
                                title: Text("Bilgilendirme: ", style: TextStyle(color: Colors.green)),
                                content: Text(" *${map_cevaplayanlar["cevaplayan"]}*   isimli ki??inizin ${DateTime.now().toString().substring(0,16)} tarihine kadar "
                                    "  *${map_cevaplanan["baslik"]}*   s??nav?? sorular??na verdi??i cevaplar??n sizin de??erlendirmeleriniz sonucu elde edilen verilerin "
                                    "analizi g??sterilecektir. Analiz bilgilerinin gelmesi biraz zaman alabilir.", textAlign: TextAlign.justify, ),
                                actions: [
                                  ElevatedButton(child: Text("Vazge??"), onPressed: () {
                                    sinavAnalizi_kapat = false;
                                    kisinin_sinavAnalizi_kapat = true;

//                                    setState(() {});
                                    _analiziKapat();
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                  },),
                                  ElevatedButton(child: Text("Ki??inin S??nav Analizini G??r"),
                                    onPressed: () async {
                                      Navigator.of(context, rootNavigator: true).pop("dialog");

                                      kisinin_sinavAnaliziniYap(map_cevaplayanlar, id_cevaplayanlar, sinaviCevaplayanin_cevapladigiSorular, sinaviCevaplayanin_dogruCevaplar
                                          , sinaviCevaplayanin_notu, sinav_toplamPuan, sorularin_puanlari, sorularin_basliklari, cevaplarin_puanlari);

                                    },
                                  ),
                                ],
                              ); showDialog(barrierDismissible: false, context: context, builder: (_) => alertDialog);
                            }

                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15),
                          child: Divider(height: 1.5, color: Colors.blueGrey,)  ,
                        ),
                      ]),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  "* Liste g??nderim tarihine g??re sondan ba??a do??ru s??ralanm????t??r.*",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  "** G??ndenderisini g??rmek istedi??iniz ki??inin ??zerine t??klay??n??z.**",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ),
              Visibility( visible: AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar == true ? true : false,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text("*** S??nav analizini g??rmek istedi??iniz ki??inin ??zerine uzun bas??n??z.***",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]);
          }
          ),
      bottomNavigationBar: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),),

    );
  }



  void _launchIt(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      AlertDialog alertDialog = new AlertDialog (
        title: Text("Hata: Sayfa G??r??nt??lenemiyor.", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
        content: Text("??nternet ba??lant??n??z kesilmi?? yada sayfan??n linki hatal?? girilmi?? olabilir."
          , style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,),
      ); showDialog(context: context, builder: (_) => alertDialog);
    }
  }

  void gonderiGor_gorseller (String gorsel, String baslik, String aciklama, dynamic map_cevaplayanlar, dynamic id_cevaplayanlar, String doc_sik, mapSoru, idSoru) async {
    Widget SetUpAlertDialogContainer() {
      return Container(
          height: gorsel == null || gorsel == "" || gorsel == " " ? 50 : 350, width: 350,
          child: FittedBox(
            child: gorsel == null || gorsel == "" || gorsel == " " ? Center(child: Text("*????z??me ait herhangi bir g??rsele ula????lamam????t??r.*",
              style: TextStyle(color: Colors.orange, ),),) :
            Image.network(gorsel, fit: BoxFit.fill,
              errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                return Center(child: Text("*????z??me ait herhangi bir g??rsele ula????lamam????t??r.*",
                  style: TextStyle(color: Colors.orange, ),),);},),
          )
      );
    }

    showDialog(context: context, builder: (_) {
      return AlertDialog(backgroundColor: Color(0xAA304030),
        title: ListTile(
          title: Text("????z??m: ", style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 20),),
          subtitle: doc_sik == null ? Text(""):
          Text("Bu soruda cevaplayan $doc_sik ????kk??n?? i??aretlemi??tir.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ),
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
                          TextSpan(text: "Ba??l??k:  ",
                              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15, fontWeight: FontWeight.w600)),
                          TextSpan(text: baslik, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18,
                              fontStyle: FontStyle.italic),),
                        ]
                    )),
                    subtitle: RichText(text: TextSpan(
                        style: TextStyle(),
                        children: <TextSpan>[
                          TextSpan(text: "A????klama:  ",
                              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15, fontWeight: FontWeight.w600)),
                          TextSpan(text: aciklama, style: TextStyle(color: Colors.white, fontSize: 12),),
                        ]
                    )),

                  ),

                ]
            ),
          ),
        ),
        actions: [
          Wrap(spacing: 4, children: [
            Visibility( visible: gorsel == "" || gorsel == " " || gorsel == null ? false: true,
              child: ElevatedButton(child: Text("G??rseli A??"),
                  onPressed: () {_launchIt(gorsel);
                  }),
            ),
            Visibility( visible: //AtaWidget.of(context).kullaniciadi == map_cevaplanan["hazirlayan"] ? true :
              map_cevaplayanlar["puan"] == null || map_cevaplayanlar["puan"] == -1 ? true : false,
              child: ElevatedButton(
                child: Text("Puan Ver"),
                onPressed: () async {
                  final _formKey = GlobalKey<FormState>();
                  TextEditingController _puanci = new TextEditingController();
                  AlertDialog alertDialog = new AlertDialog(
                    title: Text("Puan Verin"),
                    content: Form( key: _formKey,
                        child: TextFormField(
                          controller: _puanci,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Puan?? rakamla giriniz",
                              hintText: "Sorunun puan??n?? kontrol ediniz."
                          ),
                          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                          validator: (String value) {
                            if (value.isEmpty) {return "Puan girmeniz gerekmektedir.";
                            } return null;
                          },
                        )),
                    actions: [
                      ElevatedButton(
                        child: Text("Puanla"),
                        onPressed: () async {
                          if(_formKey.currentState.validate()){
                            _formKey.currentState.save();
                            String puan = _puanci.text.trim();
                            int _puan = int.parse(puan);

                            if(AtaWidget.of(context).hazirSinav_gonderilenCevaplar == true){
                              await collectionReference.doc(id_cevaplanan.toString()).get().then((element) async {
                                if(_puan <= element["puan"]) {
                                  await collectionReference.doc(id_cevaplanan.toString()).collection("soruyu_cevaplayanlar")
                                      .doc(id_cevaplayanlar.toString()).update({"puan": _puan});

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevap i??in *$puan* puan verdiniz."),
                                    action: SnackBarAction(label: "Gizle", onPressed: (){
                                      SnackBarClosedReason.hide;
                                    }),));
                                  Navigator.of(context,rootNavigator: true).pop("dialog");
                                  Navigator.of(context,rootNavigator: true).pop("dialog");
                                } else {
                                  AlertDialog alertDialog = new AlertDialog (
                                    title: Text("Hata: ", style: TextStyle(color: Colors.red)),
                                    content: Text("S??nav??n puan??ndan fazla puan verdiniz. Bu s??nav??n puan?? *${element["puan"]}* d??r."),
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                }
                              });

                            } else {

                              await collectionReference.doc(id_cevaplanan.toString()).collection("sorular").doc(idSoru.toString()).get().then((element) async {
                                if(_puan <= element["puan"]){
                                  await collectionReference.doc(id_cevaplanan.toString()).collection("sorular").doc(idSoru.toString()).collection("soruyu_cevaplayanlar")
                                      .doc(id_cevaplayanlar.toString()).update({"puan": _puan});
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevap i??in $puan puan verdiniz."),
                                    action: SnackBarAction(label: "Gizle", onPressed: (){
                                      SnackBarClosedReason.hide;
                                    }),));
                                  Navigator.of(context,rootNavigator: true).pop("dialog");
                                  Navigator.of(context,rootNavigator: true).pop("dialog");
                                } else {
                                  AlertDialog alertDialog = new AlertDialog (
                                    title: Text("Hata: ", style: TextStyle(color: Colors.red)),
                                    content: Text("Sorunun puan??ndan fazla puan verdiniz. Bu soru ${element["puan"]} puand??r."),
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                }
                              });
                            }
                          }
                        },
                      )
                    ],
                  ); showDialog(context: context, builder: (_) => alertDialog);

                },
              ),
            ),
            Visibility (visible: map_cevaplayanlar["puan"] == null || map_cevaplayanlar["puan"] == -1 ? false : true,
              child: ElevatedButton(
                child: Text("Puan?? Sil"),
                onPressed: () async {
                  if (AtaWidget.of(context).hazirSinav_gonderilenCevaplar) {
                    await collectionReference.doc(id_cevaplanan.toString()).collection("soruyu_cevaplayanlar")
                        .doc(id_cevaplayanlar.toString()).update({"puan": -1});
                  } else {
                    await collectionReference.doc(id_cevaplanan.toString()).collection("sorular").doc(idSoru.toString()).collection("soruyu_cevaplayanlar")
                        .doc(id_cevaplayanlar.toString()).update({"puan": -1});
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("i??lem ba??ar??l??"),
                    action: SnackBarAction(label: "Gizle", onPressed: (){
                      SnackBarClosedReason.hide;
                    }),));
                  Navigator.of(context,rootNavigator: true).pop("dialog");
                },
              ),
            ),
          ],),

          Visibility (visible: AtaWidget.of(context).hazirSinav_gonderilenCevaplar == false ? true : false,
            child: MaterialButton(
              child: Text("Cevab?? Do??ru Kabul Et", style: TextStyle(color: Colors.lightBlueAccent,
                decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.lightBlueAccent,), ),
              onPressed: () async {
                AlertDialog alertDialog = new AlertDialog(
                  content: Text("Cevab?? do??ru kabul etmeniz sorunun ????z??m?? i??in ge??erlidir ve cevap sahibinin soruyu do??ru ????zenler listesinde yer almas??n?? sa??lar. "
                      "Cevaplayan bu sorudan tam puan alacakt??r. *Puanla* butonunu kullanarak puan?? de??i??tirebilirsiniz."),
                  actions: [
                    MaterialButton(
                        child: Text("Cevab?? Do??ru Kabul Et", style: TextStyle(color: Colors.lightBlueAccent,
                          decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.lightBlueAccent,), ),
                        onPressed: () async {
                          print("idSoru: " + idSoru.toString());
                          print("id_cevaplayanlar: " + id_cevaplayanlar.toString());
                          print("mapSoru_baslik: " + mapSoru["baslik"]);

                          await collectionReference.doc(id_cevaplanan.toString()).collection("sorular").doc(idSoru.toString()).collection("soruyu_cevaplayanlar")
                              .doc(id_cevaplayanlar.toString()).update({"dogrumu": true, "puan" : mapSoru["puan"]});

                          List <dynamic> dogru_cevaplar = [];  String sinavi_cevaplayan_id;
                          await collectionReference.doc(id_cevaplanan).collection("sinavi_cevaplayanlar").where("mail", isEqualTo: map_cevaplayanlar["mail"])
                              .get().then((value) { value.docs.forEach((element) {
                            dogru_cevaplar = element["dogru_cevaplar"];

                            !dogru_cevaplar.contains(mapSoru["baslik"]) ? dogru_cevaplar.add(mapSoru["baslik"]) : print("dogru_Cevaplarda zaten ${mapSoru["baslik"]} var");

                            sinavi_cevaplayan_id = element.id.toString();
//                            setState(() {});
                          });
                          });
                          print("sinavi_cevaplayan_id: " + sinavi_cevaplayan_id.toString());
                          await collectionReference.doc(id_cevaplanan).collection("sinavi_cevaplayanlar").doc(sinavi_cevaplayan_id)
                              .update({"dogru_cevaplar": dogru_cevaplar});

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("i??lem ba??ar??l??"),
                            action: SnackBarAction(label: "Gizle", onPressed: (){
                              SnackBarClosedReason.hide;
                            }),));
                          Navigator.of(context,rootNavigator: true).pop("dialog");
                          Navigator.of(context,rootNavigator: true).pop("dialog");

                        })
                  ],
                ); showDialog(context: context, builder: (_) => alertDialog);

              },
            ),
          )
        ],
      );
    });
  }

  void gonderiGor_gorseller_olusturulanSinavdan(map_cevaplayanlar, id_cevaplayanlar) async {
    Widget setupAlertDialogContainer() {
      return Container(
        height: 300, width: 300,
        child: StreamBuilder(
            stream: collectionReference.doc(id_cevaplanan.toString()).collection("sinavi_cevaplayanlar").doc(id_cevaplayanlar).snapshots(),
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
              DocumentSnapshot documentSnapshot = snapshot.data;
              List <dynamic> cevapladigi_sorular = documentSnapshot.get("cevapladigi_sorular");

              return ListView.builder(
                  itemCount: cevapladigi_sorular.length,
                  itemBuilder: (BuildContext context, int index){
                    return Column(
                      children: [
                        ListTile(
                          title: Text(cevapladigi_sorular[index]),
                          onTap: () async {

                            String baslik; String aciklama; String gorsel; String doc_sik; String seciliSorunun_id; dynamic seciliSorunun; dynamic soruyuCevaplayan_id;

                            await collectionReference.doc(id_cevaplanan.toString()).collection("sorular").where("baslik", isEqualTo: cevapladigi_sorular[index]).limit(1)
                                .get().then((seciliSoru) => seciliSoru.docs.forEach((_seciliSorunun) async {
                                  seciliSorunun = _seciliSorunun;
                                  seciliSorunun_id = _seciliSorunun.id;

                                  await collectionReference.doc(id_cevaplanan.toString()).collection("sorular").doc(_seciliSorunun.id).collection("soruyu_cevaplayanlar")
                                      .where("cevaplayan", isEqualTo: map_cevaplayanlar["cevaplayan"]).limit(1).get().then((soruyuCevaplayan) =>
                                        soruyuCevaplayan.docs.forEach((soruyuCevaplayanin) {
                                          baslik = soruyuCevaplayanin["baslik"];
                                          aciklama = soruyuCevaplayanin["aciklama"];
                                          gorsel = soruyuCevaplayanin["gorsel"];
                                          soruyuCevaplayan_id = soruyuCevaplayanin.id;
                                        }));
                                }));
                            await collectionReference.doc(id_cevaplanan).collection("sorular")
                                .doc(seciliSorunun_id).collection("isaretleyenler").where("cevaplayan", isEqualTo: map_cevaplayanlar["cevaplayan"])
                                .get().then((QuerySnapshot querySnapshot)=>{
                              querySnapshot.docs.forEach((doc) {
                                doc_sik = doc["sik"];
                              })
                            });

                            gonderiGor_gorseller(gorsel, baslik, aciklama, map_cevaplayanlar, soruyuCevaplayan_id, doc_sik, seciliSorunun, seciliSorunun_id);

                          },
                        ),
                        Divider(thickness: 1, color: Colors.indigo),
                      ],
                    );
                  });
            }),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text(map_cevaplayanlar["cevaplayan"] + " n??n cevaplad?????? sorular listelenmektedir. Cevab??n?? g??rmek istedi??iniz soruya t??klaman??z yeterlidir. ",
            style: TextStyle(fontSize: 15)),
        content: setupAlertDialogContainer()
      );
    });
  }

  Future <void> kisinin_sinavAnalizBilgileriniGetir (map_cevaplayanlar, id_cevaplayanlar) async {

    await collectionReference.doc(id_cevaplanan.toString()).collection("sinavi_cevaplayanlar").doc(id_cevaplayanlar).get().then((sinaviCevaplayanin) {
      sinaviCevaplayanin_cevapladigiSorular = sinaviCevaplayanin["cevapladigi_sorular"];
      sinaviCevaplayanin_dogruCevaplar = sinaviCevaplayanin["dogru_cevaplar"];
      sinaviCevaplayanin_ismi = sinaviCevaplayanin["cevaplayan"];
    });

    await collectionReference.doc(id_cevaplanan.toString()).collection("sorular").get().then((sorular) => sorular.docs.forEach((sorularin) async {
      sorularin_basliklari.add(sorularin["baslik"]);
      sorularin_puanlari.add(sorularin["puan"]);
      sinav_toplamPuan = sorularin_puanlari.fold(0, (i, j) => i + j);

      await sorularin.reference.collection("soruyu_cevaplayanlar").where("cevaplayan", isEqualTo: map_cevaplayanlar["cevaplayan"]).get()
          .then((soruyu_cevaplayan) => soruyu_cevaplayan.docs.forEach((soruyu_cevaplayanin) {
            if(soruyu_cevaplayanin["puan"] > -1 ){
              cevaplarin_puanlari.add(soruyu_cevaplayanin["puan"]);
            }
        sinaviCevaplayanin_notu = cevaplarin_puanlari.fold(0, (i, j) => i + j);
      }));
    }));

    await collectionReference.doc(id_cevaplanan.toString()).collection("sorular").where("soru_testmi", isEqualTo: true).get()
        .then((sorular) => sorular.docs.forEach((sorularin) async {
          print(sorularin["baslik"]);
          await sorularin.reference.collection("isaretleyenler").where("cevaplayan", isEqualTo: map_cevaplayanlar["cevaplayan"]).get()
              .then((soruyu_cevaplayan) => soruyu_cevaplayan.docs.forEach((soruyu_cevaplayanin){
                print(soruyu_cevaplayanin["sik"]);
                isaretledigi_siklar.add(soruyu_cevaplayanin["sik"]);
          }));
    }));

  }

  void kisinin_sinavAnaliziniYap( map_cevaplayanlar, id_cevaplayanlar, List sinaviCevaplayanin_cevapladigiSorular, List sinaviCevaplayanin_dogruCevaplar,
      int sinaviCevaplayanin_notu, int sinav_toplamPuan, List sorularin_puanlari, List sorularin_basliklari, List cevaplarin_puanlari) async {

    double yuzde_basari = (sinaviCevaplayanin_notu/sinav_toplamPuan) * 100;

    Widget setupAlertDialogContainer() {
      return Container(
        height: 500, width: 500,
        child: ListView(
            children: [
              ListTile(
                title: Text("Cevaplayan taraf??ndan *${sinaviCevaplayanin_cevapladigiSorular.length.toString()}* adet soruya cevap g??nderilmi??tir. Cevap g??nderilen sorular??n "
                    "ba??l??klar?? a??a????da verilmi??tir. ",
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                subtitle: Text(sinaviCevaplayanin_cevapladigiSorular.toString(), style: TextStyle(fontSize: 15, color: Colors.purple),)),
              Divider(thickness: 1,),

              ListTile(
                title: Text("Cevaplar aras??ndan *${sinaviCevaplayanin_dogruCevaplar.length.toString()}* tanesini do??ru olarak belirlediniz. Do??ru sorular??n ba??l??klar?? "
                    "a??a????da verilmi??tir.",
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                subtitle: Text(sinaviCevaplayanin_dogruCevaplar.toString(), style: TextStyle(fontSize: 15, color: Colors.purple),)),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("G??nderilen cevaplar i??in ????rencinin ald?????? puanlar a??a????da verilmi??tir.",
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(cevaplarin_puanlari.toString(), style: TextStyle(fontSize: 15, color: Colors.purple),)),
              Divider(thickness: 1,),

              ListTile(
                title: Text("S??navdaki ??oktan se??meli sorularda i??aretlenen ????klar a??a????daki verilmi??tir.",
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                subtitle: Text(isaretledigi_siklar.toString(), style: TextStyle(fontSize: 15, color: Colors.purple),),),
              Divider(thickness: 1,),

              ListTile(
                title: Text("Cevaplayan??n notu/S??nav Puan??: ",
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                subtitle: Text(sinaviCevaplayanin_notu.toString() + "/" + sinav_toplamPuan.toString(), style: TextStyle(fontSize: 20, color: Colors.purple),),),
              Divider(thickness: 1,),

              ListTile(
                title: Text("Cevaplayan??n y??zde ba??ar?? oran?? a??a????da verilmi??tir:",
                  style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),),
                subtitle: Text(yuzde_basari.toString(), style: TextStyle(fontSize: 20, color: Colors.purple),),),
              Divider(thickness: 1,),
            ]),
      );
    }
    showDialog(barrierDismissible: false, context: context, builder: (_) {
      return AlertDialog(
        title: Text("Bu analizde cevaplayan??n s??navdaki ????z??mleri ve i??aretledi??i ????klar hakk??nda genel bilgilendirme yap??lm????, ??u ana kadar elde etti??i puanlar ve ba??ar?? "
            "oran?? verilmi??tir. Analizi *Analizi Kapat* butonunu kullanarak kapat??n??z. Aksi takdirde bir sonraki analiz hatal?? sonu?? verecektir.",
          style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold),
          textAlign: TextAlign.justify,),
        content: setupAlertDialogContainer(),
        actions: [
          ElevatedButton(child: Text("Analizi Kapat"),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop("dialog");
              _analiziKapat();
            },
          ),
        ],
      );
    });


  }

  Future <void> olusturulanSinav_AnalizBilgileriniGetir() async {

   await collectionReference.doc(id_cevaplanan).get().then((sinav) {

     sinav.reference.collection("sorular").where("soru_testmi", isEqualTo: true).get().then((test_sorulari) => test_sorulari.docs.forEach((test_sorusu) {
       testSorulari.add(test_sorusu["baslik"]);
       sorularin_puanlari.add(test_sorusu["puan"]);
       test_sorusu.reference.collection("soruyu_cevaplayanlar").get().then((soruyu_cevaplayanlar) => soruyu_cevaplayanlar.docs.forEach((soruyu_cevaplayan) {
         sinaviCevaplayanlar_puanlar.add(soruyu_cevaplayan["puan"]);
       }));
       test_sorusu.reference.collection("isaretleyenler").get().then((_isaretleyenler) => _isaretleyenler.docs.forEach((_isaretleyen) {
         soru_isaretleyenler_sik.add(test_sorusu["baslik"] + "/ " + _isaretleyen["cevaplayan"] + ": " + _isaretleyen["sik"]);

       }));
       test_sorusu.reference.collection("dogruSik_isaretleyenler").get().then((_isaretleyenler) => _isaretleyenler.docs.forEach((dogru_isaretleyen) {
         dogruSik_isaretleyenler.add(test_sorusu["baslik"] + "/ " + dogru_isaretleyen["cevaplayan"] + ": " + test_sorusu["dogru_sik"]);
         print("dogruSik_isaretleyenler: " + dogruSik_isaretleyenler.toString());
       }));
     }));

     sinav.reference.collection("sorular").where("soru_testmi", isEqualTo: false).get().then((klasik_sorular) => klasik_sorular.docs.forEach((klasik_soru) {
       klasikSorular.add(klasik_soru["baslik"]);
       sorularin_puanlari.add(klasik_soru["puan"]);
       klasik_soru.reference.collection("soruyu_cevaplayanlar").get().then((soruyu_cevaplayanlar) => soruyu_cevaplayanlar.docs.forEach((soruyu_cevaplayan) {
         sinaviCevaplayanlar_puanlar.add(soruyu_cevaplayan["puan"]);
       }));
     }));

     sinav.reference.collection("sinavi_cevaplayanlar").get().then((sinavi_cevaplayanlar) => sinavi_cevaplayanlar.docs.forEach((sinavi_cevaplayan) {
       sinaviCevaplayanlar.add(sinavi_cevaplayan["cevaplayan"]);
     }));

     sinav.reference.collection("paylasilanlar").get().then((_paylasilanlar) => _paylasilanlar.docs.forEach((_paylasilan) {
       paylasilanlar.add(_paylasilan["kullaniciadi"]);
     }));
   });

  }

  void olusturulanSinav_AnaliziniYap(List testSorulari, List klasikSorular, List sinaviCevaplayanlar, List sinaviCevaplayanlar_puanlar) async {
    sinav_toplamPuan = sorularin_puanlari.fold(0, (i, j) => i + j);
    cevaplayanlar_toplamPuan = sinaviCevaplayanlar_puanlar.fold(0, (i, j) => i + j);
    int toplam_soruSayisi = testSorulari.length + klasikSorular.length;
    double yuzde_basari = (cevaplayanlar_toplamPuan / (sinav_toplamPuan*paylasilanlar.length))*100;
    List <dynamic> sorular = testSorulari.followedBy(klasikSorular).toList();


    Widget setupAlertDialogContainer() {
      return Container(
        height: 500, width: 500,
        child: ListView(
            children: [
              ListTile(
                  title: Text("S??nav??n??zda *${testSorulari.length}* tanesi ??oktan se??meli, *${klasikSorular.length}* tanesi klasik olmak ??zere toplam "
                      "*${toplam_soruSayisi}* adet soru bulunmaktad??r.", textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 15, color: Colors.purple,),),
                  subtitle: Text("Sorular?? g??rmek i??in t??klay??n??z.", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  onTap: (){

                    Widget sorulariGoster_alertDialog() {
                      return Container(
                        height: 500, width: 500,
                        child: ListView.builder(
                            itemCount: toplam_soruSayisi,
                            itemBuilder: (context, index) {
                              return Column( children: [
                                ListTile(
                                  title: Text(sorular[index], style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                  trailing: testSorulari.contains(sorular[index]) ? Text("Test", style: TextStyle(decoration: TextDecoration.underline),)
                                      : Text("Klasik", style: TextStyle(decoration: TextDecoration.underline),),
                                ),
                                Divider(thickness: 1,),
                              ],
                              );
                            }
                        ),
                      );
                    }
                    AlertDialog alertDialog = new AlertDialog (
                      title: Text("Sorular: ", style: TextStyle(color: Colors.green)),
                      content: sorulariGoster_alertDialog(),
                    ); showDialog(context: context, builder: (_) => alertDialog);
                  },
              ),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??z??n a????klamas??: ",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  subtitle: Text(map_cevaplanan["aciklama"], style: TextStyle(fontSize: 15, color: Colors.purple,),),
              ),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??z??n biti?? tarihi: ",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(map_cevaplanan["bitis_tarihi"], style: TextStyle(fontSize: 15, color: Colors.purple,) ,)),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??z??n grubu: ",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(map_cevaplanan["eklendigi_grup"] == "" ? "S??nav?? hen??z hi??bir gruba eklemediniz" : map_cevaplanan["eklendigi_grup"],
                    style: TextStyle(fontSize: 15, color: Colors.purple,),)),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??z??n konusu / dersi: ",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(map_cevaplanan["konu"] + "  /  " + map_cevaplanan["ders"], style: TextStyle(fontSize: 15, color: Colors.purple,),)),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??z?? ??imdiye kadar ${paylasilanlar.length} ki??i ile payla??t??n??z. Bunlardan *${sinaviCevaplayanlar.length}* tanesi en az bir soru "
                      "i??in ????z??m g??ndermi??tir. Bununla birlikte s??nav??n??zdaki test soruluar??n??za toplamda *${soru_isaretleyenler_sik.length}* ki??i i??aretleme yapm????t??r.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 15, color: Colors.purple,),),
                  subtitle: Text("????aretlemeleri g??rmek i??in t??klay??n??z.", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  onTap: (){
                    Widget isaretlemeleriGoster_alertDialog() {
                      return Container(
                        height: 500, width: 500,
                        child: ListView.builder(
                            itemCount: soru_isaretleyenler_sik.length,
                            itemBuilder: (context, index) {
                              return Column( children: [
                                ListTile(
                                  title: Text(soru_isaretleyenler_sik[index], style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic)),
                                  trailing: dogruSik_isaretleyenler.contains(soru_isaretleyenler_sik[index]) ? Icon(Icons.check_circle) : SizedBox.shrink(),
                                ),
                                Divider(thickness: 1,),
                              ],
                              );
                            }
                        ),
                      );
                    }
                    AlertDialog alertDialog = new AlertDialog (
                      title: Text("G??sterim *Soru / ????aretleyen : ????aretledi??i ????k* ??eklinde g??sterilmi?? olup, do??ru cevaplayanlar tik i??areti ile belirtilmi??tir. ",
                          style: TextStyle(color: Colors.green, fontSize: 15), textAlign: TextAlign.justify,),
                      content: isaretlemeleriGoster_alertDialog(),
                    ); showDialog(context: context, builder: (_) => alertDialog);
                  },
                ),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??z??n ba??ar?? y??zdesi a??a????da verilmi??tir.",
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(yuzde_basari.toString(), style: TextStyle(fontSize: 15, color: Colors.purple),)),
              Divider(thickness: 1,),

            ]),
      );
    }
    showDialog(barrierDismissible: false, context: context, builder: (_) {
      return AlertDialog(
        title: Text("Olu??turulan s??navlarda ????z??m?? do??ru kabul etti??iniz takdirde yada test sorular?? i??in do??ru ????k i??aretlenmi?? ise cevaplayan sorudan tam puan al??r. "
            "Fakat *Puanla* butonunu ile cevaplayana puan verdiyseniz yukar??daki durumlar olu??sa bile verdi??iniz puan ge??erlidir."
            ,style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.justify,),
        content: setupAlertDialogContainer(),
        actions: [
          ElevatedButton(child: Text("Analizi Kapat"),
            onPressed: (){
            Navigator.of(context, rootNavigator: true).pop("dialog");
            _analiziKapat();
            },
          ),
        ],
      );
    });
  }

  void _analiziKapat() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
        GonderilenCevaplarPage(map_cevaplanan: map_cevaplanan, id_cevaplanan: id_cevaplanan, collectionReference: collectionReference,
          storageReference: storageReference, mapSoru: mapSoru, idSoru: idSoru,)));
/*
      testSorulari.clear();
      klasikSorular.clear();
      sinaviCevaplayanlar.clear();
      sinaviCevaplayanlar_puanlar.clear();
      cevaplayanlar_toplamPuan = 0;
      soru_isaretleyenler_sik.clear();
      sorularin_puanlari.clear();
      sinav_toplamPuan = 0;
      dogruSik_isaretleyenler.clear();
      sinaviCevaplayanin_cevapladigiSorular.clear();
      sinaviCevaplayanin_dogruCevaplar.clear();
      sinaviCevaplayanin_notu = 0;
      sinav_toplamPuan = 0;
      sorularin_puanlari.clear();
      String sinaviCevaplayanin_ismi;
      sorularin_basliklari.clear();
      cevaplayanin_notu = 0;
      isaretledigi_siklar.clear();
      cevaplarin_puanlari.clear();
      isaretledigi_siklar.clear();
      soruyu_cevaplayanlar_puanlar.clear();
      soruyu_dogruCevaplayanlar.clear();
      soruyu_dogruCevaplayanlar.clear();
      soru_isaretleyenler_sik.clear();
      dogruSik_isaretleyenler.clear();
      cevaplayanlar_toplamPuan = 0;
      if(AtaWidget.of(context).hazirSinav_gonderilenCevaplar != true){paylasilanlar.clear();}

      setState(() {});
*/
  }

  Future <void> sorunun_analizBilgileriniGetir() async {


    await collectionReference.doc(id_cevaplanan.toString()).collection("sorular").doc(idSoru.toString()).get().then((soru) {

      soru.reference.collection("soruyu_cevaplayanlar").get().then((_soruyu_cevaplayanlar) => _soruyu_cevaplayanlar.docs.forEach((_soruyu_cevaplayanlarin) {
        if(_soruyu_cevaplayanlarin["puan"] >= 0){ soruyu_cevaplayanlar_puanlar.add(_soruyu_cevaplayanlarin["puan"]); }

        if( _soruyu_cevaplayanlarin["dogrumu"] == true){ soruyu_dogruCevaplayanlar.add(_soruyu_cevaplayanlarin["cevaplayan"]); }

      }));

      soru.reference.collection("isaretleyenler").get().then((_isaretleyenler) => _isaretleyenler.docs.forEach((_isaretleyenlerin) {
        soru_isaretleyenler_sik.add(_isaretleyenlerin["cevaplayan"] + ": " + _isaretleyenlerin["sik"]);
      }));

      soru.reference.collection("dogruSik_isaretleyenler").get().then((_dogruSik_isaretleyenler) => _dogruSik_isaretleyenler.docs.forEach((_dogruSik_isaretleyenlerin) {
        dogruSik_isaretleyenler.add(_dogruSik_isaretleyenlerin["cevaplayan"]);
      }));

      collectionReference.doc(id_cevaplanan).collection("paylasilanlar").get().then((_paylasilanlar) => _paylasilanlar.docs.forEach((_paylasilan) {
        paylasilanlar.add(_paylasilan["kullaniciadi"]);
      }));
    });

  }

  void sorunun_analiziniYap() async {
    AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == false ? cevaplayanlar_toplamPuan = soruyu_cevaplayanlar_puanlar.fold(0, (i, j) => i + j)
        : cevaplayanlar_toplamPuan = mapSoru["puan"]*AtaWidget.of(context).dogruSiktan_puanCevaplayan.length;

    double yuzde_basari = (cevaplayanlar_toplamPuan/(mapSoru["puan"]*paylasilanlar.length)) * 100;

    Widget soruAnaliziAlertDialog() {
      return Container(
        height: 500, width: 500,
        child: ListView(
            children: [
              ListTile(
                title: Text(mapSoru["soru_testmi"] == true ?
                  "Soru *${mapSoru["puan"].toString()}* puan de??erinde ??oktan se??meli bir sorudur. Sorunun do??ru ????kk??n?? *${mapSoru["dogru_sik"].toString()}* olarak "
                      "belirlediniz."
                    : "Soru *${mapSoru["puan"].toString()}* puan de??erinde a????k u??lu bir sorudur. ",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 15, color: Colors.purple,),),

              ),
              Divider(thickness: 1,),

              ListTile(
                title: Text("Soruya g??nderilen ????z??mlerin *${soruyu_dogruCevaplayanlar.length.toString()}* tanesini do??ru kabul ettiniz.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 15, color: Colors.purple,),
                ),
                subtitle: Text("Do??ru ????z??m g??nderenleri g??rmek i??in t??klay??nz.", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                onTap: (){

                  Widget dogruCevaplayanlariGoster_alertDialog() {
                    return Container(
                      height: 500, width: 500,
                      child: ListView.builder(
                          itemCount: soruyu_dogruCevaplayanlar.length,
                          itemBuilder: (context, index) {
                            return Column( children: [
                              ListTile(
                                title: Text(soruyu_dogruCevaplayanlar[index], style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic)),
                              ),
                              Divider(thickness: 1,),
                              ],
                            );
                          }
                      ),
                    );
                  }
                  AlertDialog alertDialog = new AlertDialog (
                    title: Text("Burada G??nderilen Cevaplar aras??ndan do??ru kabul ettikleriniz g??sterilir:", style: TextStyle(color: Colors.green)),
                    content: dogruCevaplayanlariGoster_alertDialog(),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                },
              ),
              Divider(thickness: 1,),

              Visibility( visible: AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == true ? false : mapSoru["soru_testmi"] == true ? true : false,
                child: ListTile(
                    title: Text("Soruda *${soru_isaretleyenler_sik.length.toString()}* ki??i ????klar?? i??aretlemi??tir.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 15, color: Colors.purple,),),
                  subtitle: Text("Kimin hangi ????kk?? i??aretledi??ini g??rmek i??in t??klay??n??z.", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  onTap: (){

                    Widget IsaretleyenlerSikiGoster_alertDialog() {
                      return Container(
                        height: 500, width: 500,
                        child: ListView.builder(
                            itemCount: soru_isaretleyenler_sik.length,
                            itemBuilder: (context, index) {
                              return Column( children: [
                                ListTile(
                                  title: Text(soru_isaretleyenler_sik[index], style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic)),
                                ),
                                Divider(thickness: 1,),
                              ],
                              );
                            }
                        ),
                      );
                    }
                    AlertDialog alertDialog = new AlertDialog (
                      title: Text("G??sterim ??ekli *Soruyu ????aretleyen: ????k* ??eklindedir.", style: TextStyle(color: Colors.green)),
                      content: IsaretleyenlerSikiGoster_alertDialog(),
                    ); showDialog(context: context, builder: (_) => alertDialog);
                  },
                ),
              ),
              Visibility( visible: AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == true ? false : mapSoru["soru_testmi"] == true ? true : false,
                  child: Divider(thickness: 1,)),

              Visibility( visible: AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == true ? false : mapSoru["soru_testmi"] == true ? true : false,
                child: ListTile(
                    title: Text("Soruyu i??aretlenen ????klar??n *${dogruSik_isaretleyenler.length.toString()}* tanesi do??rudur.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 15, color: Colors.purple,),),
                  subtitle: Text("Do??ru ????kk?? i??aretleyenleri g??rmek i??in t??klay??n??z.", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  onTap: (){

                    Widget dogruSikIsaretleyenleriGoster_alertDialog() {
                      return Container(
                        height: 500, width: 500,
                        child: ListView.builder(
                            itemCount: dogruSik_isaretleyenler.length,
                            itemBuilder: (context, index) {
                              return Column( children: [
                                ListTile(
                                  title: Text(dogruSik_isaretleyenler[index],
                                      style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic)),
                                ),
                                Divider(thickness: 1,),
                                ],
                              );
                            }
                        ),
                      );
                    }
                    AlertDialog alertDialog = new AlertDialog (
                      title: Text("Do??ru ????kk?? i??aretleyenler: ", style: TextStyle(color: Colors.green)),
                      content: dogruSikIsaretleyenleriGoster_alertDialog(),
                    ); showDialog(context: context, builder: (_) => alertDialog);
                  },
                ),
              ),
              Visibility( visible: AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == true ? false : mapSoru["soru_testmi"] == true ? true : false,
                  child: Divider(thickness: 1,)),

              ListTile(
                  title: Text(AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == true ? "Soruda *${soru_isaretleyenler_sik.length}* ki??i i??aretleme yapm????t??r. "
                      "Bunlar??n *${dogruSik_isaretleyenler.length}* tanesi do??rudur. ????aretleyenlerin ald??klar?? toplam puan ise: ":
                  "Soruya cevap g??nderenlerin ald?????? toplam puan: ",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(cevaplayanlar_toplamPuan.toString(), style: TextStyle(fontSize: 15, color: Colors.purple,),)),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("Sorunun ba??ar?? y??zdesi: ",
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(yuzde_basari.toString(), style: TextStyle(fontSize: 15, color: Colors.purple),)),
              Divider(thickness: 1,),

            ]),
      );
    }
    showDialog(barrierDismissible: false, context: context, builder: (_) {
      return AlertDialog(
        title: Text( AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler == true ? "????aretlenen ????klar, i??aretleyenler ve do??ruluk durumu sayfada "
            "listelenmi??tir. Bu analiz sadece ????klardaki i??aretlemeler baz al??narak yap??ld??????ndan sorunun ????z??m??ne verilmi?? puanlar burada hesaba kat??lmaz. Do??ru ????kk?? "
            "i??aretleyenler sorudan tam puan al??rken, yanl???? i??aretleyenler 0 puan al??rlar."
            : "Soruya cevap g??nderenler ve ald??klar?? puanlar sayfada listelenmi??tir. Ki??ilere t??klayarak cevaplar??na ula??abilirsiniz. "
            "Sorunun ????z??m??n?? do??ru kabul etti??iniz takdirde yada test sorular?? i??in do??ru ????k i??aretlenmi?? ise cevaplayan sorudan tam puan al??r. "
            "Fakat *Puanla* butonu ile cevaplayana puan verdiyseniz yukar??daki durumlar olu??sa bile verdi??iniz puan ge??erlidir."
          ,style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.justify,),
        content: soruAnaliziAlertDialog(),
        actions: [
          ElevatedButton(child: Text("Analizi Kapat"),
            onPressed: (){
              Navigator.of(context, rootNavigator: true).pop("dialog");
              _analiziKapat();
            },
          ),
        ],
      );
    });
  }

  void hazirSinav_AnalizBilgileriniGetir(map_cevaplanan) async {
    paylasilanlar = map_cevaplanan["paylasilanlar"];

//    setState(() {});
    print("paylasilanlar: " + paylasilanlar.toString());
    print("paylasilanlar_map: " + map_cevaplanan["paylasilanlar"].toString());
    await collectionReference.doc(id_cevaplanan.toString()).collection("soruyu_cevaplayanlar").get()
        .then((_sinavi_cevaplayanlar) => _sinavi_cevaplayanlar.docs.forEach((_sinavi_cevaplayanlarin) {
          if(_sinavi_cevaplayanlarin["puan"] >= 0){ sinaviCevaplayanlar_puanlar.add(_sinavi_cevaplayanlarin["puan"]); }
    }));


  }

  void hazirSinav_AnaliziniYap() async {

    print("S??nav??n??z??n konusu: " + map_cevaplanan["konu"]);
    print("S??nav??n??z??n a????klamas??: " + map_cevaplanan["aciklama"]);
    print("S??nav??n??z??n puan??: " + map_cevaplanan["puan"].toString());
    print("S??nav??n??z??n eklendi??i grup: " + map_cevaplanan["eklendigi_grup"]);
    print("S??nav??n biti?? tarihi: " + map_cevaplanan["bitis_tarihi"]);
    print("S??nav??n??z?? ??imdiye kadar *${paylasilanlar.length}* ki??iyle payla??t??n??z.");
    print("S??nav??n??z?? payla??t??????n??z ki??iler: " + paylasilanlar.toString());
    print("S??nav??n??za ????z??m/cevap g??nderenler ve ald??klar?? puanlar sayfada listelenmi??tir.");
    print("sinaviCevaplayanlar_puanlar: " + sinaviCevaplayanlar_puanlar.toString());
    cevaplayanlar_toplamPuan = sinaviCevaplayanlar_puanlar.fold(0, (i, j) => i + j);
    print("cevaplayanlar_toplamPuan: " + cevaplayanlar_toplamPuan.toString());
    double yuzde_basari = (cevaplayanlar_toplamPuan / (map_cevaplanan["puan"]*paylasilanlar.length))*100;
    print("S??nav??n??z??n y??zde ba??ar?? oran??: " + yuzde_basari.toString());

    Widget setupAlertDialogContainer() {
      return Container(
        height: 500, width: 500,
        child: ListView(
            children: [
              ListTile(
                  title: Text("S??nav??n??z??n dersi/ konusu: ",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(map_cevaplanan["konu"] + "  /  " + map_cevaplanan["ders"], style: TextStyle(fontSize: 15, color: Colors.purple,),)),
              Divider(thickness: 1,),

              ListTile(
                title: Text("S??nav??n??z??n a????klamas?? / puan??: ",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
                subtitle: Text(map_cevaplanan["aciklama"] + " / " + map_cevaplanan["puan"].toString(), style: TextStyle(fontSize: 15, color: Colors.purple,),),
              ),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??z??n biti?? tarihi: ",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(map_cevaplanan["bitis_tarihi"], style: TextStyle(fontSize: 15, color: Colors.purple,) ,)),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??z??n grubu: ",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(map_cevaplanan["eklendigi_grup"] == "" ? "S??nav?? hen??z hi??bir gruba eklemediniz" : map_cevaplanan["eklendigi_grup"],
                    style: TextStyle(fontSize: 15, color: Colors.purple,),)),
              Divider(thickness: 1,),

              ListTile(
                title: Text("S??nav??n??z?? ??imdiye kadar *${paylasilanlar.length}* ki??i ile payla??t??n??z. S??nav??n??za ????z??m/cevap g??nderenler ve ald??klar?? puanlar sayfada "
                    "listelenmi??tir.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 15, color: Colors.purple,),),
              ),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??za cevap/????z??m g??nderenlerin ald??klar?? puan toplam??: ",
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(cevaplayanlar_toplamPuan.toString(), style: TextStyle(fontSize: 15, color: Colors.purple),)),
              Divider(thickness: 1,),

              ListTile(
                  title: Text("S??nav??n??z??n ba??ar?? y??zdesi: ",
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),),
                  subtitle: Text(yuzde_basari.toString(), style: TextStyle(fontSize: 15, color: Colors.purple),)),
              Divider(thickness: 1,),

            ]),
      );
    }
    showDialog(barrierDismissible: false, context: context, builder: (_) {
      return AlertDialog(
        title: Text("S??nav??n??z??n *${DateTime.now().toString().substring(0,16)}* tarihine kadar analizi: "
          ,style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.justify,),
        content: setupAlertDialogContainer(),
        actions: [
          ElevatedButton(child: Text("Analizi Kapat"),
            onPressed: (){
              Navigator.of(context, rootNavigator: true).pop("dialog");
              _analiziKapat();
            },
          ),
        ],
      );
    });
  }

}

