
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/FormHelper.dart';
import 'package:sinavci/Helpers/ImageToPdfPage.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/ListelerDetaylarPages/GonderilenCevaplarPage.dart';
import 'package:sinavci/SinavlarKisilerPage.dart';
import 'package:sinavci/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class OlusturulanSinavPage extends StatefulWidget {
  final map_solusturulan; final id_solusturulan; final collectionReference; final storageReference; final grid_gorunum;
  const OlusturulanSinavPage({Key key, this.map_solusturulan, this.id_solusturulan, this.storageReference, this.collectionReference, this.grid_gorunum}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return OlusturulanSinavPageState(this.map_solusturulan, this.id_solusturulan, this.storageReference, this.collectionReference, this.grid_gorunum);
  }
}



class OlusturulanSinavPageState extends State {
  final map_solusturulan; final id_solusturulan; final collectionReference; final storageReference; bool grid_gorunum;
  OlusturulanSinavPageState(this.map_solusturulan, this.id_solusturulan, this.storageReference, this.collectionReference, this.grid_gorunum);

  CollectionReference collectionReference_solusturulan_soruyuCevaplayanlar;
  File _imageSelected; File _soruSelected;
  bool gorsel_cevap_ekle;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey_gorselSoru = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String id_subCol_newDoc;  String baslik; String idnewDoc; String sinav_baslik;
  bool metinsel_soru; bool gorsel_soru; bool soru_testmi;
  bool test_mesaji = false;
  bool soru_bitti; bool a_sikki_bitti; bool b_sikki_bitti; bool c_sikki_bitti; bool d_sikki_bitti;
  File a_sikki_gorsel; File b_sikki_gorsel; File c_sikki_gorsel; File d_sikki_gorsel;
  String a_sikki_metin; String b_sikki_metin; String c_sikki_metin; String d_sikki_metin;
  String dogru_sik;
  String soru_metni;
  String soruyu_cevaplayan_id;
  String puan; int _puan;
  final _screenshotController = ScreenshotController();
  bool ss_bannerKapat = false;
  List<Axis> axis_scroll_list = [Axis.vertical, Axis.horizontal];
  static const IconData screenshot_outlined = IconData(0xf345, fontFamily: 'MaterialIcons');
  static const IconData screenshot = IconData(0xe562, fontFamily: 'MaterialIcons');
  static const IconData screenshot_rounded = IconData(0xf0137, fontFamily: 'MaterialIcons');
  static const IconData screenshot_sharp = IconData(0xec58, fontFamily: 'MaterialIcons');
  bool ustbilgi = false; bool altbilgi = false; bool yazili = false;
  bool kameradan_resim; bool galeriden_resim;

  Reklam _reklam = new Reklam();
  @override
  void initState() {
    _reklam.createInterad();
    super.initState();
  }

  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;
    double statusBar_sizeHeight = MediaQuery.of(context).padding.top;

    return Scaffold(//key: _scaffoldKey,
      body:
      SingleChildScrollView( scrollDirection: Axis.horizontal,
        child: SingleChildScrollView( scrollDirection: Axis.vertical,
          child: Screenshot(
            controller: _screenshotController,
            child: Container( height: grid_gorunum == true && AtaWidget.of(context).a4 == true ? sizeHeight*1.2 - statusBar_sizeHeight - 10
                : sizeHeight - statusBar_sizeHeight - 20,
              width: grid_gorunum == true && AtaWidget.of(context).a4 == true ? sizeWidth*1.5 : sizeWidth,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    automaticallyImplyLeading: grid_gorunum == true ? false : true,
                    toolbarHeight: grid_gorunum != true ? 50 : map_solusturulan["yazili_girildi"] == true ? 50
                        : map_solusturulan["ustbilgi"].toString().length > 100 ? 50
                        : map_solusturulan["ustbilgi"] == null || map_solusturulan["ustbilgi"] == "" || map_solusturulan["ustbilgi"] == " " ? 0
                        : 30,
                    backgroundColor: grid_gorunum == true ? Colors.white : Colors.blue,
                    elevation: grid_gorunum == true ? 0 : 4,
                    title: GestureDetector(
                      onTap: (){
                        AlertDialog alertDialog = new AlertDialog(
                          title: Text(map_solusturulan["baslik"]),
                        );showDialog(context: context, builder: (_)=> alertDialog);
                      },
                      child: grid_gorunum != true ? Text(map_solusturulan["baslik"], style: TextStyle(fontSize: 18,)):
                      ListTile(
                        title: map_solusturulan["yazili_girildi"] == true ?
                        Text(map_solusturulan["yazili_baslik"], style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
                            :  Text(map_solusturulan["ustbilgi"], style: TextStyle(color: Colors.black,
                          fontSize: map_solusturulan["ustbilgi_punto"] == null || map_solusturulan["ustbilgi_punto"] == "" ? 10 :
                          double.parse(map_solusturulan["ustbilgi_punto"].toString()),
                          fontWeight: map_solusturulan["ustbilgi_kalin"] == true ? FontWeight.bold : FontWeight.normal,
                          fontStyle: map_solusturulan["ustbilgi_italic"] == true ? FontStyle.italic : FontStyle.normal,),
                          textAlign: TextAlign.center,
                        ),
                        subtitle: Visibility( visible: map_solusturulan["yazili_girildi"] == true ? true : false,
                          child: Center(
                            child: Wrap(
                                children: [
                                  Text("Ad-Soyad: ", style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),),
                                  SizedBox(width: 200,),
                                  Wrap( direction: Axis.horizontal,
                                      children: [
                                        Text("S??n??f: ", style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),),
                                        SizedBox(width: 130,),
                                        Text("Puan: ", style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),),
                                      ]),
                                ] ),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      Visibility( visible: grid_gorunum == true ? false : true,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(icon: Icon(Icons.campaign), iconSize: 30,
                            onPressed: (){
                              AlertDialog alertDialog = new AlertDialog(
                                title: Text("B??LG??LEND??RME"),
                                content: Container( height: 300,
                                  child: SingleChildScrollView(
                                    physics: ClampingScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        MaterialButton(child: Text("Olu??turulan S??nav asistan video i??in T??klay??n.", style: TextStyle(color: Colors.green),
                                          textAlign: TextAlign.center,),
                                          onPressed: (){
                                            _launchIt("https://drive.google.com/file/d/1QBTgmBUDMXGa918BIkHiBvmO7Oyw-dFE/view?usp=sharing");
                                          },),
                                        MaterialButton(child: Text("Olu??turulan S??nav ????kt?? G??r??n??m?? asistan video i??in T??klay??n.", style: TextStyle(color: Colors.green),
                                          textAlign: TextAlign.center,),
                                          onPressed: (){
                                            _launchIt("https://drive.google.com/file/d/1Q7ncu3m2TF76zBpha2ljLp_lMuJTC-So/view?usp=sharing");
                                          },),
                                        Center(
                                          child: Text("*S??navda farkl?? formatlarda soru tipleri olabilir. ??oktan se??meli sorular??n ????klar??n?? g??rmek ve i??aretlemek"
                                              " i??in *????klar?? G??r* butonuna bas??n??z.",
                                            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                        ),
                                        SizedBox(height: 10,),
                                        Center(
                                          child: Text("*S??nav?? ????zenler soru g??rseline t??kland??????nda kilit a????lm???? ise sorular??n cevab??n?? g??rebilirler ama kendileri cevap"
                                              " g??nderemezler. Kilit kapal?? iken s??nav i??in cevap g??nderilebilir ama sorular??n ????z??mleri g??sterilmez.",
                                            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                        ),
                                        SizedBox(height: 10,),
                                        Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                                          child: Center(
                                            child: Text("*Soruya uzun basarak sorunuzu silebilir yada sorunuza ????z??m ekleyip mevcut ????z??m?? g??ncelleyebilirsiniz.",
                                              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Center(
                                          child: Text("* Soruya ??ift t??klayarak daha b??y??k g??rebilirsiniz, dilerseniz g??rsel sorular?? taray??c??da da a??abilirsiniz.",
                                            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                        ),
                                        SizedBox(height: 10,),
                                        Center(
                                          child: Text("* Izgara i??aretine t??klayarak ????kt?? G??r??n??m??n?? etkinle??tirebilirsiniz. Olu??turdu??unuz s??nav??n ????kt?? G??r??n??m??n?? etkinle??tirdikten"
                                              " sonra ekran g??r??nt??s??n?? al??n. Bu sayede resim haline getirdi??iniz s??nav?? istedi??iniz yere ekleyerek d??zenleyebilir, ????kt??s??n?? "
                                              "alabilirsiniz.",
                                            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                        ),
                                        SizedBox(height: 10,),
                                        Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                                          child: Center(
                                            child: Text("*??oktan se??meli sorularda ????kka uzun basarak d??zenleyebilir yada ????kk?? do??ru ????k olarak belirleyebilirsiniz.",
                                              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Visibility(
                                          child: Center(
                                            child: Text("*Sayfada yapt??????n??z de??i??ikliklerin g??r??nmesi i??in sayfay?? yenilemeniz gerekebilir.",
                                              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );showDialog(context: context, builder: (_) => alertDialog);
                            },),
                        ),
                      ),
                      Visibility( visible: grid_gorunum == true ? false : true,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Builder(
                            builder: (context)=> IconButton(
                              icon: map_solusturulan["kilitli"] == true ? Icon(Icons.lock): Icon(Icons.lock_open),
                              onPressed: ()async{
                                if(AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"]){
                                  bool locked = true;
                                  if(map_solusturulan["kilitli"] == true){locked = false;}
                                  await collectionReference.doc(id_solusturulan).update({"kilitli": locked});
//                    setState(() {});
                                  Navigator.pop(context);
                                } else {
                                  AlertDialog alertDialog = new AlertDialog(title: Text("Hata: "),
                                    content: Text(" ????lemi yapmaya yetkiniz yok."),);
                                  showDialog(context: context, builder: (_) => alertDialog);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility( visible: grid_gorunum == true ? false : true,
                        child: Builder(
                          builder: (context) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                                icon: Icon(Icons.grid_view),
                                onPressed: (){
                                  grid_gorunum == false ? true : false;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????kt?? G??r??n??m?? etkinle??tirildi. Sayfan??n ??st taraf??nda bulunan "
                                      "ye??il yuvarlak butona t??klayarak gerekli bilgilendirmeleri alabilir, bu ????kt?? g??r??n??m??ne ??zg?? i??lem yapabilirsiniz.",
                                      textAlign: TextAlign.justify,),
                                    duration: Duration(seconds: 7),
                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));


                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                      OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: true,
                                          collectionReference: collectionReference, storageReference: storageReference)));
                                }
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                body:
                Theme(
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thumbColor: MaterialStateProperty.all(Colors.black),
                      trackColor: MaterialStateProperty.all(Colors.black38),
                      trackBorderColor: MaterialStateProperty.all(Colors.black54),
                      showTrackOnHover: true, crossAxisMargin: 8,
                    ),
                  ),
                  child: Scrollbar( thickness: 10, radius: Radius.elliptical(10, 10), hoverThickness: 20, showTrackOnHover: true,
                    child: Container(
                      color: Colors.white,
                      child: StreamBuilder(
                        stream: collectionReference.doc(id_solusturulan.toString()).collection("sorular").orderBy("tarih").snapshots(),
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

                          return Container(
                            child: Column(children: [
                              SizedBox(height: grid_gorunum == true ? 0 : 10,),
                              Visibility( visible: grid_gorunum == true ? false : true,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                                  child: GestureDetector(
                                      onTap: (){
                                        _aciklamayiGor();
                                      },
                                      onLongPress: (){
                                        if(AtaWidget.of(context).kullaniciadi != map_solusturulan["hazirlayan"]){
                                          AlertDialog alertDialog = new AlertDialog(
                                            title: Text("Hata: "),
                                            content: Text("????lemi yapmaya yetkiniz yok, S??nav sadece haz??rlayan taraf??ndan g??ncellenebilir."),
                                          );
                                          showDialog(context: context, builder: (_) => alertDialog);
                                        } else {
                                          _aciklamaGir();
                                        }
                                      },
                                      child: map_solusturulan["aciklama"] == "" ?
                                      Visibility(visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true: false,
                                        child: Text("Buraya t??klayarak s??nav??n??z i??in ekstra a????klama girebilirsiniz", style: TextStyle(color: Colors.green, fontSize: 15,
                                            fontWeight: FontWeight.w500), textAlign: TextAlign.justify,),
                                      ) :
                                      Column(children: [
                                        Text(map_solusturulan["aciklama"].toString().length > 40 ? map_solusturulan["aciklama"].toString().substring(0, 40) + "..."
                                            : map_solusturulan["aciklama"]
                                          , textAlign: TextAlign.justify, style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.w500), ),

                                        SizedBox(height: 5,),
                                        Align(alignment: Alignment.bottomRight,
                                            child: Text( AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ?
                                              "A????klaman??n tamam??n?? g??rmek veya de??i??tirmek i??in t??klay??n??z" : "A????klaman??n tamam??n?? g??rmek i??in t??klay??n??z"
                                              , style: TextStyle(fontSize: 12),)),
                                      ]
                                      )
                                  ),
                                ),
                              ),
                              Visibility( //visible: grid_gorunum == true ? false : true,
                                child: Padding(padding: const EdgeInsets.only(left: 20.0, right: 50,),
                                  child: Divider(thickness: 1, color: Colors.black),),
                              ),
                              Visibility( visible: querySnapshot.size == 0 ? true : false,
                                child: Expanded(
                                  child: Center(
                                    child: Text("S??navda hi?? soru bulunamad??.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 20)),),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        mainAxisSpacing: grid_gorunum == true && AtaWidget.of(context).a4 == true
                                            ? AtaWidget.of(context).sorular_arasi_mesafe == null ? 10 : AtaWidget.of(context).sorular_arasi_mesafe
                                            : 10,
                                        crossAxisSpacing: grid_gorunum == true && AtaWidget.of(context).a4 == true
                                            ? AtaWidget.of(context).sorular_arasi_mesafe == null ? 10 : AtaWidget.of(context).sorular_arasi_mesafe
                                            : 10,
                                        crossAxisCount: grid_gorunum == true && AtaWidget.of(context).a4 == true
                                            ? AtaWidget.of(context).sutun_sayisi == null ? 2 : AtaWidget.of(context).sutun_sayisi
                                            : 1,
                                        childAspectRatio: grid_gorunum == true && AtaWidget.of(context).a4 == true ?
                                        AtaWidget.of(context).soru_ici_bosluk == null ? 2 : AtaWidget.of(context).soru_ici_bosluk/10 : 2,
                                      ),
                                      itemCount: querySnapshot.size,
                                      itemBuilder: (context, index) {
                                        final mapSoru = querySnapshot.docs[index].data();
                                        final idSoru = querySnapshot.docs[index].id;
                                        int sira = index + 1;
                                        return Padding(
                                          padding: grid_gorunum == true ? const EdgeInsets.only(left: 10.0) : const EdgeInsets.only(left: 10.0, bottom: 10),
                                          child: GestureDetector(
// GR??DT??LE CARD ??????NE AALINARAK FOOTER KISMINDAK?? FLOAT??NGbUTTONLAR CARDTA EN ALTA KONUMLANDIRILACAK**********
                                            child: GridTile(
                                                footer: Visibility( visible: grid_gorunum == true ? false : true,
                                                  child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Align(
                                                        child: Visibility( visible: mapSoru["soru_testmi"] == true ? true : false,
                                                          child: Container(height: 70, width: 70,
                                                            child: FittedBox(
                                                              child: FloatingActionButton.extended(
                                                                backgroundColor: Colors.green,
                                                                heroTag: "????klar??G??r${sira.toString()}",
                                                                onPressed: () {
                                                                  _reklam.showInterad();

                                                                  siklariGor(idSoru, mapSoru);
                                                                },
                                                                label: Text("????klar?? G??r"),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        child: Container(height: 100, width: 100,
                                                          child: FittedBox(
                                                            child: Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                                                              child: FloatingActionButton.extended(
                                                                backgroundColor: Colors.green,
                                                                heroTag: "cevaplar??G??r${sira.toString()}",
                                                                onPressed: () async {
                                                                  _reklam.showInterad();

                                                                  AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar = true;
                                                                  AtaWidget.of(context).hazirSinav_gonderilenCevaplar = false;
                                                                  AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar = false;
                                                                  AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler = false;

                                                                  _gonderilenCevaplariGor_soru(map_solusturulan, id_solusturulan, collectionReference
                                                                      , storageReference, mapSoru, idSoru, querySnapshot, sira);
                                                                },
                                                                label: Text("G??nderilen Cevaplar"),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                header: Container(
                                                  color: grid_gorunum == true ? Colors.transparent : Color(0xAA200000),
                                                  child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      RichText(text: TextSpan(
                                                          style: TextStyle(),
                                                          children: <TextSpan>[
                                                            TextSpan(text: sira.toString() +".",
                                                              style: grid_gorunum == true ? TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15) :
                                                              TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                                                            TextSpan(text: grid_gorunum == true ? "" :
                                                              mapSoru["baslik"].toString().length >= 40 ? mapSoru["baslik"].toString().substring(0,40)
                                                                :   mapSoru["baslik"],
                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600,
                                                                fontStyle: FontStyle.italic, fontSize: 13),),
                                                          ]
                                                      )),
                                                      Text(grid_gorunum == true ? "" : "puan: " + mapSoru["puan"].toString(),
                                                        style: TextStyle(color: Colors.yellowAccent, fontSize: 13, fontWeight: FontWeight.w600,),),
                                                    ],
                                                  ),
                                                ),
                                                child: Container(
                                                    margin: EdgeInsets.only( top: 20,
                                                        left: grid_gorunum == true && AtaWidget.of(context).a4 == true
                                                            ? AtaWidget.of(context).sorularin_boyutu == null ? 0 : AtaWidget.of(context).sorularin_boyutu
                                                            : 0,
                                                        right: grid_gorunum == true && AtaWidget.of(context).a4 == true
                                                            ? AtaWidget.of(context).sorularin_boyutu == null ? 0 : AtaWidget.of(context).sorularin_boyutu
                                                            : 0,
                                                        bottom: grid_gorunum == true && AtaWidget.of(context).a4 == true
                                                            ? AtaWidget.of(context).sorularin_boyutu == null ? 0 : AtaWidget.of(context).sorularin_boyutu
                                                            : 0,
                                                        ),
                                                    color: grid_gorunum == true ? Colors.white : Colors.blue.shade100,
                                                    child: mapSoru["gorsel_soru"] == "" ||  mapSoru["gorsel_soru"] == null ||  mapSoru["gorsel_soru"] == " "  ?
                                                    mapSoru["metinsel_soru"] == "" ||  mapSoru["metinsel_soru"] == " " ||  mapSoru["metinsel_soru"] == null  ?
                                                    Text("SORU BULUNAMADI"):
                                                    Container( alignment: grid_gorunum == true ? Alignment(0, -.7) : Alignment(0, 0),
                                                      child: Text(mapSoru["metinsel_soru"], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,
                                                        fontSize: grid_gorunum == true ? 10 : 15,), textAlign: TextAlign.center,
                                                      ),
                                                    ):
                                                    Container(alignment: grid_gorunum == true ? Alignment(0,-.7) : Alignment(0, 0),
                                                      child: Image.network(mapSoru["gorsel_soru"],
                                                        errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                        return Center(
                                                          child: Text("SORUYA ULA??ILAMADI"),
                                                        );
                                                      },
                                                      ),
                                                    ))),
                                            onTap: () async {
                                              _reklam.showInterad();

//SORUNUN CEVABI G??STER??L??YOR
                                              if(AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"]){
                                                Widget SetUpAlertDialogContainer() {
                                                  return Container(height: 350, width: 400,
                                                    child: mapSoru["gorsel_cevap"] != "" ?
                                                    Image.network(mapSoru["gorsel_cevap"], fit: BoxFit.fill, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                      return Center(child: Text("Sorunun cevap g??rseline ula????lamam????t??r."),);},)
                                                        : Center(child: Text(mapSoru["metinsel_cevap"], style: TextStyle(color: Colors.white, ),),),
                                                  );
                                                }
                                                showDialog(context: context, builder: (_) {
                                                  return AlertDialog(backgroundColor: Color(0xAA304030),
                                                    title: Center(
                                                        child: Text(sira.toString() + ". sorunun cevab??: ", style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                    content: mapSoru["gorsel_cevap"] == "" && mapSoru["metinsel_cevap"] == "" ? Text("Cevap daha eklenmemi??tir.",
                                                      style: TextStyle(fontSize: 18, color: Colors.white),)
                                                        : SetUpAlertDialogContainer(),
                                                    actions: [
                                                      Visibility( visible: mapSoru["gorsel_cevap"] == "" || mapSoru["gorsel_cevap"] == " " || mapSoru["gorsel_cevap"] == null ? false: true,
                                                        child: RaisedButton(color: Colors.blueAccent, child: Text("Taray??c??da A??"),
                                                            onPressed: () {_launchIt(mapSoru["gorsel_cevap"]);
                                                            }),
                                                      )
                                                    ],
                                                  );
                                                });
                                              }
                                              else {
                                              String _doc_baslik; String _doc_cevaplayan; String _doc_id; String _doc_aciklama; String _doc_gorsel; int _doc_puan;
                                              await collectionReference.doc(id_solusturulan).collection("sorular")
                                                  .doc(idSoru.toString()).collection("soruyu_cevaplayanlar")
                                                  .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi).limit(1)
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

                                              AlertDialog alertDialog = new AlertDialog(
                                                  title: Text("Yapaca????n??z i??lemi se??iniz: "),
                                                  content: Text("????z??m kilidi a????k olan sorular??n haz??rlayan taraf??ndan girildiyse ????z??mleri g??r??lebilir fakat soru art??k "
                                                      "cevaplanamaz. ????z??mleri kilitli sorular??n ????z??mleri g??r??lemez fakat bu sorulara s??nav?? g??renler kendi ????z??mlerini "
                                                      "ekleyebilir, mevcut ????z??mlerini de??i??tirebilir yada silebilirler.", textAlign: TextAlign.justify,),
                                                  actions: [
                                                   ElevatedButton(
                                                     child: Text("Sorunun ????z??m??n?? G??r"),
                                                     onPressed: (){
                                                       if (map_solusturulan["kilitli"] == false) {
                                                         Widget SetUpAlertDialogContainer() {
                                                           return Container(height: 350, width: 400,
                                                             child: mapSoru["gorsel_cevap"] != "" ?
                                                             Image.network(mapSoru["gorsel_cevap"], fit: BoxFit.fill, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                               return Center(child: Text("Sorunun cevap g??rseline ula????lamam????t??r."),);},)
                                                                 : Center(child: Text(mapSoru["metinsel_cevap"], style: TextStyle(color: Colors.white, ),),),
                                                           );
                                                         }
                                                         showDialog(context: context, builder: (_) {
                                                           return AlertDialog(backgroundColor: Color(0xAA304030),
                                                             title: Center(
                                                                 child: Text(sira.toString() + ". sorunun cevab??: ", style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
                                                                   textAlign: TextAlign.center,
                                                                 )),
                                                             content: mapSoru["gorsel_cevap"] == "" && mapSoru["metinsel_cevap"] == "" ? Text("Cevap daha eklenmemi??tir.",
                                                               style: TextStyle(fontSize: 18, color: Colors.white),)
                                                                 : SetUpAlertDialogContainer(),
                                                             actions: [
                                                               Visibility( visible: mapSoru["gorsel_cevap"] == "" || mapSoru["gorsel_cevap"] == " " || mapSoru["gorsel_cevap"] == null
                                                                   ? false: true,
                                                                 child: RaisedButton(color: Colors.blueAccent, child: Text("Taray??c??da A??"),
                                                                     onPressed: () {_launchIt(mapSoru["gorsel_cevap"]);
                                                                     }),
                                                               )
                                                             ],
                                                           );
                                                         });
                                                       } else {
                                                         AlertDialog alertDialog = new AlertDialog(title: Text("UYARI: "),
                                                           content: Text("S??nav?? haz??rlayan cevaplar??n kilidini a??mam????t??r. Cevaplar g??r??lemez."),);
                                                         showDialog(context: context, builder: (_) => alertDialog);
                                                       }
                                                     },
                                                   ),
                                                    Visibility( visible: _doc_baslik == null ? false : true,
                                                      child: ElevatedButton(

                                                        child: Text("Kendi ????z??m??n?? G??r"),
                                                        onPressed: (){
                                                            Widget SetUpAlertDialogContainer() {
                                                              return Container(
                                                                height: _doc_gorsel == null || _doc_gorsel == "" || _doc_gorsel == " " ? 50 : 350, width: 350,
                                                                child: FittedBox(
                                                                  child: Image.network(_doc_gorsel, fit: BoxFit.fill,
                                                                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                                    return Center(child: Text("????z??m??n??ze ait her hangi bir g??rsele ula????lamam????t??r.",
                                                                      style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),),);},),
                                                                )
                                                              );
                                                            }
                                                            showDialog(context: context, builder: (_) {
                                                              return AlertDialog(backgroundColor: Color(0xAA304030),
                                                                title: Center(
                                                                    child: Text(sira.toString() + ". soru i??in ????z??m??n??z: ", textAlign: TextAlign.center,
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
                                                                                  TextSpan(text: "Ba??l??k:  ",
                                                                                      style: TextStyle(color: Colors.lightBlueAccent, fontSize: 15, fontWeight: FontWeight.w600)),
                                                                                  TextSpan(text: _doc_baslik, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18,
                                                                                      fontStyle: FontStyle.italic),),
                                                                                ]
                                                                            )),
                                                                            subtitle: RichText(text: TextSpan(
                                                                                style: TextStyle(),
                                                                                children: <TextSpan>[
                                                                                  TextSpan(text: "A????klama:  ",
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
                                                                  Visibility( visible: map_solusturulan["kilitli"] == true ? false : _doc_puan == null || _doc_puan == -1 ? false : true,
                                                                    child: RichText(text: TextSpan(
                                                                        style: TextStyle(), children: <TextSpan> [
                                                                      TextSpan(text: "Puan??n??z: ", style: TextStyle(color: Colors.lightBlueAccent, fontSize: 13)),
                                                                      TextSpan(text: _doc_puan.toString(),
                                                                          style: TextStyle(color: Colors.yellowAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                                                                    ]
                                                                    ),),
                                                                  ),
                                                                  SizedBox(width: 20,),
                                                                  Visibility( visible: _doc_gorsel == "" || _doc_gorsel == " " || _doc_gorsel == null ? false: true,
                                                                    child: RaisedButton(color: Colors.blueAccent, child: Text("G??rseli A??"),
                                                                        onPressed: () {_launchIt(_doc_gorsel);
                                                                        }),
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        },
                                                      ),
                                                    ),
                                                    Wrap(direction: Axis.horizontal, spacing: 4, children: [
                                                      Visibility( visible: _doc_baslik == null ? true : false,
                                                        child: ElevatedButton(
                                                          child: Text("????z??m??n?? G??nder"),
                                                          onPressed: (){
                                                            Navigator.of(context, rootNavigator: true).pop("dialog");
                                                            if(map_solusturulan["kilitli"] == true){
                                                              ogrenci_cevapEkle(idSoru, mapSoru);
                                                            }else {
                                                              AlertDialog alertDialog = new AlertDialog(title: Text("*HATA: "), content: Text("Haz??rlayan s??nav??n/sorunun "
                                                                  "cevab??n?? g??r??lebilir yapt?????? i??in art??k ????z??m??n??z?? g??nderemezsiniz."),);
                                                              showDialog(context: context, builder: (_)=> alertDialog);
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      Visibility( visible: _doc_baslik == null ? false : true,
                                                        child: ElevatedButton(
                                                          child: Text("????z??m??n?? Sil"),
                                                          onPressed: () async {
                                                           _cevaplayanCozumSil(idSoru, mapSoru);

                                                          },
                                                        ),
                                                      ),
                                                    ],),

                                                  ],
                                                ); showDialog(context: context, builder: (_) => alertDialog);
                                              }
                                            },
                                            onLongPress: () async {
                                              _reklam.showInterad();

                                              if(AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"]){

                                                AlertDialog _alertDialog = new AlertDialog(
                                                  title: Text("Yapmak istedi??iniz i??lemi se??iniz: "),
                                                  actions: [
//SORUYU S??L
                                                    MaterialButton(
                                                        child: Text("Soruyu Sil",style: TextStyle(color: Colors.indigo, fontSize: 15, fontWeight: FontWeight.bold),),
                                                        onPressed: () async {
                                                          _soruyuSil(idSoru, mapSoru);
                                                        },

                                                      ),
                                                    MaterialButton(
                                                      child: Text("????z??m Ekle/G??ncelle",
                                                        style: TextStyle(color: Colors.indigo, fontSize: 15, fontWeight: FontWeight.bold),),
                                                      onPressed: (){
                                                        Navigator.of(context, rootNavigator: true).pop("dialog");
                                                        AlertDialog alertDialog = new AlertDialog(
                                                          title: Text("Sorunun ????z??m??n?? g??rsel ya da metinsel olarak girebilirsiniz. "),
                                                          actions: [
                                                            RaisedButton(
                                                              color: Colors.blue,
                                                              child: Text("????z??m?? Metin Olarak Gir"),
                                                              onPressed: () async{
                                                                Navigator.of(context,rootNavigator: true).pop('dialog');
                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                                                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                                                                metinselCevapEkle(idSoru, mapSoru);

                                                              },
                                                            ),
                                                            Wrap(direction: Axis.horizontal, spacing: 4, children: [
                                                              RaisedButton(
                                                                color: Colors.green,
                                                                child: Text("Telefondan ????z??m se??"),
                                                                onPressed: ()async{
                                                                  Navigator.of(context,rootNavigator: true).pop('dialog');
                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                                                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                                                  _galeridenCozumEkle(idSoru, mapSoru);
                                                                },
                                                              ),
                                                              RaisedButton(
                                                                  color: Colors.green,
                                                                  child: Text("Kameradan ????z??m ??ek"),
                                                                  onPressed: ()async{
                                                                    Navigator.of(context,rootNavigator: true).pop('dialog');
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                                                                      action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                                                    _kameradanCozumEkle(idSoru, mapSoru);
                                                                  }),
                                                            ],),

                                                          ],
                                                        );
                                                        showDialog(context: context, builder: (_) => alertDialog);
                                                      },
                                                    ),
                                                  ],
                                                ); showDialog(context: context, builder: (_) => _alertDialog);

                                              }
                                              else {
                                                AlertDialog alertDialog = new AlertDialog(
                                                  title: Text("Hata: "),
                                                  content: Text(" ????lemi yapmaya yetkiniz yok, Sayfa sadece sahibi taraf??ndan g??ncellenebilir."),
                                                );
                                                showDialog(context: context, builder: (_) => alertDialog);
                                              }
                                            },
                                            onDoubleTap: (){
                                              Widget SetUpAlertDialogContainer() {
                                                return Container(
                                                    height: 500, width: 500,
                                                    child: mapSoru["gorsel_soru"] == "" ||  mapSoru["gorsel_soru"] == null ||  mapSoru["gorsel_soru"] == " "
                                                        ? mapSoru["metinsel_soru"] == "" ||  mapSoru["metinsel_soru"] == " " ||  mapSoru["metinsel_soru"] == null
                                                        ? Text("SORU BULUNAMADI")
                                                        : Center(child: Text(mapSoru["metinsel_soru"], style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)))
                                                        : Image.network(mapSoru["gorsel_soru"], fit: BoxFit.contain,
                                                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                          return Center(child
                                                              : Text("SORUYA ULA??ILAMADI"),);
                                                    },
                                                    )
                                                );
                                              }
                                              showDialog(context: context, builder: (_) => AlertDialog(
                                                content: SetUpAlertDialogContainer(),
                                                actions: [
                                                  Visibility( visible: mapSoru["gorsel_soru"] == "" ||  mapSoru["gorsel_soru"] == null ||  mapSoru["gorsel_soru"] == " "
                                                      ? false : true,
                                                    child: ElevatedButton(
                                                      child: Text("Taray??c??da A??"),
                                                      onPressed: (){
                                                        _launchIt(mapSoru["gorsel_soru"]);
                                                      },
                                                    ),
                                                  ),

                                                ],
                                              ));
                                            },
                                          ),
                                        );
                                      }),
                                ),
                              ),
                              Visibility( visible: grid_gorunum == true ? false : true,
                                child: Center(
                                  child: Padding(padding: EdgeInsets.only(top:10),
                                      child:map_solusturulan["kilitli"] == false ?Text("**Cevap kilidi a????lm????t??r.**",
                                          style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold)):
                                      Text("*Cevaplar kilitlidir.*", style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold))),
                                ),
                              ),
                              Visibility( visible: grid_gorunum == true ? false : true,
                                child: GestureDetector(
                                  onTap: (){
                                    _reklam.showInterad();

                                    AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar = false;
                                    AtaWidget.of(context).hazirSinav_gonderilenCevaplar = false;
                                    AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar = true;
                                    AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler = false;

                                    Navigator.push(context, MaterialPageRoute(builder: (_) => GonderilenCevaplarPage(
                                      map_cevaplanan: map_solusturulan, id_cevaplanan: id_solusturulan, collectionReference: collectionReference, storageReference: storageReference,
                                    )));

                                  },
                                  child: Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                                    child: Center(
                                      child: RichText(text: TextSpan(
                                          style: TextStyle(),
                                          children: <TextSpan>[
                                            TextSpan(text: "**G??nderilen cevaplar?? g??rmek i??in",
                                                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
                                            TextSpan(text: " Buraya t??klay??n??z.**", style: TextStyle(color: Colors.indigo,
                                                fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                          ]
                                      )),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility( visible: grid_gorunum == false ? false : map_solusturulan["altbilgi"] == null || map_solusturulan["altbilgi"] == "" ||
                                  map_solusturulan["altbilgi"] == " " ? false : true,
                                child: Padding(
                                  padding: const EdgeInsets.only( top: 10.0),
                                  child: Text(map_solusturulan["altbilgi"], style: TextStyle(color: Colors.black,
                                      fontSize: map_solusturulan["altbilgi_punto"] == null || map_solusturulan["altbilgi_punto"] == "" ? 12 :
                                        double.parse(map_solusturulan["altbilgi_punto"].toString()),
                                      fontWeight: map_solusturulan["altbilgi_kalin"] == true ? FontWeight.bold : FontWeight.normal,
                                      fontStyle: map_solusturulan["altbilgi_italic"] == true ? FontStyle.italic : FontStyle.normal,),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ),
                              SizedBox(height: grid_gorunum == true ? 10 : 20,),
                            ]),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

//******SORU EKLEME********
      floatingActionButton: Align( alignment: grid_gorunum == true
          ? map_solusturulan["yazili_girildi"] == true ? Alignment(1,-.68)
          : map_solusturulan["ustbilgi"] == null || map_solusturulan["ustbilgi"] == "" ? Alignment(1, -.79)
          : map_solusturulan["ustbilgi"].toString().length > 100 ?  Alignment(1,-.68)
          : Alignment(1,-.72)
          : Alignment(1,1),
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: grid_gorunum == true ?
          Container(
            child: FittedBox(
              child: CircleAvatar(backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(Icons.radio_button_checked, color: Colors.green, size: 30,),
                  tooltip: "Butonlara eri??mek i??in t??klay??n",
                  onPressed: (){
                    AlertDialog alertdialog = new AlertDialog(
                      title: Text("Bilgilendirme: "),
                      content: Container(height: 500, width: 500,
                        child: SingleChildScrollView( physics: ClampingScrollPhysics(),
                          child: Column(
                            children: [
                              MaterialButton(child: Text("Olu??turulan S??nav ????kt?? G??r??n??m?? asistan video i??in T??klay??n.", style: TextStyle(color: Colors.green),
                                textAlign: TextAlign.center,),
                                onPressed: (){
                                  _launchIt("https://drive.google.com/file/d/1Q7ncu3m2TF76zBpha2ljLp_lMuJTC-So/view?usp=sharing");
                                },),
                              Text("1) Mobil ????kt?? g??r??n??m??ndesiniz. Bu g??r??n??mde s??nav??n??z??n ????kt?? g??r??n??m??n?? ki??iselle??tirebilir, ????kt??s??n?? alabilirsiniz.",
                                style: TextStyle(fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                              SizedBox(height: 5,),
                              Text( AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ?
                                "2) Sorular??n ??zerine ??ift t??klad??????n??zda sorular daha b??y??k pencerede g??r??necektir. ????kt?? modunda g??r??n??m??n?? be??enmedi??iniz "
                                  "soruya ??ift t??klay??n ve taray??c??da a????n. Ekran g??r??nt??s??n?? alarak soruyu kaydedin ve normal g??r??n??mde soruyu kare ??eklinde "
                                  "k??rparak tekrar s??nava ekleyin. Sorunun eski halini silin. B??ylece ayn?? soruyu daha iyi bir g??r??n??me sahip olarak eklemi?? olursunuz."
                                  : "2) Sorular??n ??zerine ??ift t??klad??????n??zda sorular daha b??y??k pencerede g??r??necektir. ",
                                style: TextStyle(fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                              SizedBox(height: 5,),
                              Text( AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ?
                                "3) A??a????daki butonlar?? kullanarak sa??dan itibaren s??ras??yla *????kt?? g??r??n??m??nden ????kabilir, **????kt?? g??r??n??m??nde s??nava metin ekleyebilir, "
                                  "***s??nav??n g??r??n??m??n?? A4 format??na g??re ki??iselle??tirebilir, ****s??nav??n ekran g??r??nt??s??n?? alabilir, *****s??nav??n pdf olarak ????kt??s??n?? "
                                    "alabilir, ******A4 g??r??n??m??nden ????kabilirsiniz."
                                  : "3) A??a????daki butonlar?? kullanarak sa??dan itibaren s??ras??yla ????kt?? g??r??n??m??nden ????kabilir,"
                                  "s??nav??n ekran g??r??nt??s??n?? alabilir, s??nav??n pdf olarak ????kt??s??n?? alabilirsiniz.",
                                  style: TextStyle(fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                              SizedBox(height: 5,),
                              Text(
                              "4) S??nav??n??z??n ????kt??s??n?? almadan ??nce A4 butonuna basarak s??nav??n??z??n g??r??n??m??n?? A4 ka????da en uygun ve istedi??iniz ??ekilde ayarlay??n. "
                                  "Ard??ndan Ekran G??r??nt??s??n?? a??a????daki butonu kullanarak al??n. Aksi takdirde reklamlar kaybolmayacakt??r. Son olarak PDf butonuna "
                                  "basarak ald??????n??z akran g??r??nt??lerini PDFe D??n????t??r sayfas??na ekleyin ve PDF ????kt??s??n?? al??n. S??nav??n??z??n PDF ????kt??s?? tarih ve saat "
                                  "ile belgelerinize kaydedilmi??tir. E??er yaz??c??n??z uyumlu ise PDF g??r??nt??leyici program??n??z ile telefonunuzu yaz??c??ya ba??layarak direkt "
                                  "s??nav??n??z?? yazd??rabilirsiniz. Dilerseniz telefonunuzu bilgisayara ba??layarak da yazd??rma i??lemini ger??ekle??tirebilirsiniz.",
                                style: TextStyle(fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                              SizedBox(height: 5,),
                              Text(
                                "5) En iyi ????kt??y?? elde etmek i??in s??nav??n??z??n A4 format??nda ekran g??r??n??t??s??n?? ald??ktan sonra bilgisayardan Word'e ekleyin ve resmi Word "
                                    "??zerinde d??zenleyin.",
                                style: TextStyle(fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                              SizedBox(height: 5,),
                            ]
                          ),
                        ),
                      ),
                      actions: [
                        Wrap(
                          children: [
                            IconButton(
                              icon: CircleAvatar(
                                child: Text("A4", style: TextStyle(decoration: TextDecoration.lineThrough, decorationColor: Colors.black, decorationThickness: 5,
                                  decorationStyle: TextDecorationStyle.solid, color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15,),
                                ), backgroundColor: Colors.black, radius: 12.5,
                              ),
                              onPressed: (){
                                AtaWidget.of(context).a4 = false;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("A4 G??r??n??m?? kapat??larak, Mobil ????kt?? G??r??n??m??ne ge??ilmi??tir. "
                                    "Bu g??r??n??m A4 ????kt?? almaya elveri??li de??ildir. G??r??n??mde uyumsuzluklar olabilir."),
                                  duration: Duration(seconds: 4), action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),
                                ));
                                Navigator.of(context, rootNavigator: true).pop("dialog");
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OlusturulanSinavPage(
                                    map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                                    collectionReference: collectionReference, storageReference: storageReference
                                )));
                              },
                            ),
                            IconButton(
                                icon: Icon(Icons.picture_as_pdf_outlined), tooltip: "PDF ????kt??s?? Al", onPressed: () {
                              _reklam.showInterad();
                              Navigator.of(context, rootNavigator: true).pop("dialog");

                              AlertDialog alertDialog = new AlertDialog (
                                title: Text("Dikkat: "),
                                content: Text("S??nav??n??z??n ekran g??r??nt??lerini ald??????n??zdan emin olun. PDF ????kt??s?? s??nav??n ekran g??r??nt??lerini eklenerek "
                                    "al??nacakt??r.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  MaterialButton(child: Text("PDFe D??n????t??r", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.black,
                                  )),
                                    onPressed: () {
                                      List<File> images = [];
                                      Navigator.of(context, rootNavigator: true).pop("dilaog");
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ImageToPdfPage(images: images,)));
                                    },
                                  ),
                                ],
                              ); showDialog(context: context, builder: (_) => alertDialog);

                            }),
                            IconButton(
                                icon: CircleAvatar(child: Image.asset("assets/twotone_screenshot_black_24.png", height: 25,), backgroundColor: Colors.white,),
                                tooltip: "Ekran G??r??nt??s?? Al", onPressed: () async {
                              Navigator.of(context, rootNavigator: true).pop("dialog");
                              _reklam.showInterad();

                              AlertDialog alertDialog = new AlertDialog (
                                title: Text("Dikkat: "),
                                content: Text("Ekran g??r??nt??s?? almadan ??nce A4 butonunu kullanarak s??nav??n??z?? A4 format??nda d??zenledi??inizden emin olun. Aksi takdirde "
                                    "do??rudan mobil ekran g??r??n??m?? ile ????kt?? alacaks??n??z ve mobil g??r??n??m ??o??u telefon i??in A4 ????kt??s?? ile uyumsuzdur.",
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  MaterialButton(child: Text("Ekran G??r??nt??s?? Al", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.black,
                                  )),
                                    onPressed: () {
                                      MediaQuery.of(context).removePadding(removeTop: true);
                                      _takeScreenshot();
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ekran g??r??nt??s?? galerinize kaydedilmi??tr."),
                                        action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                      Navigator.of(context, rootNavigator: true).pop("dialog");
                                    },
                                  ),
                                ],
                              ); showDialog(context: context, builder: (_) => alertDialog);

                            }),
                            IconButton(
                                icon: CircleAvatar( child: Text("A4", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),), radius: 12,
                                  backgroundColor: Colors.black,), tooltip: "A4 G??r??m??n??", onPressed: () {
                              _reklam.showInterad();
                              AtaWidget.of(context).a4 = true;

/*                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("A4 G??r??n??m??ne ge??tiniz."), duration: Duration(seconds: 4),
                                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),
                              ));
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OlusturulanSinavPage(
                                map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                                storageReference: storageReference, grid_gorunum: grid_gorunum,
                              )));
*/
                              Navigator.of(context, rootNavigator: true).pop("dialog");

                              _a4Ayarla();
                            }),
                          ],
                        ),

                        Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                          child: IconButton(
                              icon: Icon(Icons.text_fields), tooltip: "Metin Ekle", onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop("dialog");
                            _reklam.showInterad();

                            AlertDialog alertdialog = new AlertDialog(
                              title: Text("A??a????dakilerden birini se??erek girece??iniz metnin yerini ve format??n?? belirleyiniz. Buraya yazd??????n??z metin sadece ????kt?? "
                                  "g??r??n??m??nde ve s??nav??n payla????ld?????? herkeste g??r??n??r. ??stbilgi ve yaz??l?? giri??i ayn?? s??nav i??in kullan??lamaz. Altbilgi giri??i ise "
                                  "??stbilgi veya yaz??l?? "
                                  "giri??inden ba????ms??zd??r.", textAlign: TextAlign.justify,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text("Ekran boyutlar?? telefondan telefona farkl?? oldu??undan baz?? telefonlarda girilen altbilgi ????kt?? modunda g??r??nmeyebilir. "
                                      "Buradaki Ekran G??r??nt??s?? "
                                      "Alma butonu ile Telefonunuzun ekran g??r??nt??s??n?? ald????n??zda altbilgi g??r??necektir.", textAlign: TextAlign.justify,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey)),
                                ),
                              actions: [
                                MaterialButton(
                                  child: Text("??stbilgi", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
                                  onPressed: (){
                                    _reklam.showInterad();

                                    ustbilgi = true; altbilgi = false; yazili = false;
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                    cikti_metinEkle();
                                  },
                                ),
                                MaterialButton(
                                  child: Text("Altbilgi", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
                                  onPressed: (){
                                    _reklam.showInterad();

                                    ustbilgi = false; altbilgi = true; yazili = false;
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                    cikti_metinEkle();
                                  },
                                ),
                                MaterialButton(
                                  child: Text("Yaz??l??", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
                                  onPressed: (){
                                    _reklam.showInterad();

                                    ustbilgi = false; altbilgi = false; yazili = true;
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                    cikti_metinEkle();
                                  },
                                ),
                              ],
                            ); showDialog(context: context, builder: (_) => alertdialog);

                          }),
                        ),
                        IconButton(icon: Icon(Icons.grid_off), tooltip: "????kt?? G??r??n??m??n?? Kapat",
                            onPressed: (){
                              Navigator.of(context, rootNavigator: true).pop("dialog");
                              grid_gorunum = false;
                              _reklam.showInterad();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                  OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: false,
                                      collectionReference: collectionReference, storageReference: storageReference)));
                            }),

                      ],
                    ); showDialog(context: context, builder: (_) => alertdialog);
                  },
              ),
              ),
            ),
          ) :
          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 80, width: 100,
                  child: FittedBox(
                    child: grid_gorunum == true ? Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                      child: IconButton(
                          icon: Icon(Icons.text_fields), tooltip: "Metin Ekle", onPressed: () {
                        _reklam.showInterad();
                        cikti_metinEkle();
                      }),
                    )
                        : Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"]
                        || map_solusturulan["kilitli"] == false ? true : false,
                      child: FloatingActionButton.extended(
                          heroTag: "cevapGoster",
                          label: Text("Cevap Anahtar??"),
                          onPressed: () async {

                            if(map_solusturulan["gorsel_cevap"] == "" || map_solusturulan["gorsel_cevap"] == " " || map_solusturulan["gorsel_cevap"] == null ){
                              if(map_solusturulan["metinsel_cevap"] == "" || map_solusturulan["metinsel_cevap"] == " " || map_solusturulan["metinsel_cevap"] == null){
                                AlertDialog alertDialog = new AlertDialog (
                                  title: Text("S??nava cevap anahtar?? eklenmemi??tir.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
                                ); showDialog(context: context, builder: (_) => alertDialog);
                              }
                            } else {
                              Widget SetUpAlertDialogContainer() {
                                return Container(
                                    height: 500, width: 500,
                                    child: Image.network(map_solusturulan["gorsel_cevap"], fit: BoxFit.fill,)
                                );
                              }
                              showDialog(context: context, builder: (_) => AlertDialog(
                                title: Text("Resim format??ndaki cevap anahtalar??n?? hem bu pencerede g??r??nt??leyebilir hem de taray??c??da a??abilirsiniz. Fakat metin "
                                    "format??ndaki cevap anahtarlar??n?? sadece bu pencerede g??r??nt??lebilir, taray??c??da a??amazs??n??z. Belge format??nda y??klenmi?? cevap "
                                    "anahatarlar??n?? ise *Taray??c??da A??* butonunu kullanarak telefonunuza indirdikten sonra ilgili uygulaman??z arac??l??????yla "
                                    "g??r??nt??leyebilirsiniz.", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                                  textAlign: TextAlign.justify,
                                ),
                                content: map_solusturulan["gorsel_cevap"] == "" || map_solusturulan["gorsel_cevap"] == " " ||
                                    map_solusturulan["gorsel_cevap"] == null ? Text(map_solusturulan["metinsel_cevap"]) : SetUpAlertDialogContainer(),
                                actions: [
                                  Visibility( visible: map_solusturulan["gorsel_cevap"] == "" || map_solusturulan["gorsel_cevap"] == " " ||
                                      map_solusturulan["gorsel_cevap"] == null ? false : true,
                                    child: ElevatedButton(child: Text("Taray??c??da A??"),
                                      onPressed: () => _launchIt(map_solusturulan["gorsel_cevap"]),
                                    ),
                                  ),
                                ],
                              ));
                            }
                          }
                      ),
                    ),
                  ),
                ),
                Container( height: 80, width: 100,
                  child: FittedBox(
                    child:  grid_gorunum == true ?
                    IconButton(icon: Icon(Icons.grid_off),
                        onPressed: (){
                          grid_gorunum = false;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                              OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: false,
                                  collectionReference: collectionReference, storageReference: storageReference)));
                        })
                        : Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                      child: FloatingActionButton.extended(
                        heroTag: "soruEkle",
                        icon: Icon(Icons.add, size: 50,),
                        label: Text( soru_bitti == true || a_sikki_bitti == true || b_sikki_bitti == true || c_sikki_bitti == true ? "DevamEt"
                            : "Soru Ekle",
                          style: TextStyle(fontWeight: FontWeight.bold),),

                        onPressed: ()async {

                          print("A B??TT?? " + a_sikki_bitti.toString().toUpperCase());
                          print("B B??TT?? " + b_sikki_bitti.toString().toUpperCase());
                          print("C B??TT?? " + c_sikki_bitti.toString().toUpperCase());
                          print("D B??TT?? " + d_sikki_bitti.toString().toUpperCase());
                          if (soru_bitti == true ) { soru_siklariOlustur(); }
                          else if (a_sikki_bitti == true ) { b_sikkinaGec(); }
                          else if (b_sikki_bitti == true ) { c_sikkinaGec(); }
                          else if (c_sikki_bitti == true ) { d_sikkinaGec(); }
                          else {
                            AlertDialog alertDialog = new AlertDialog (
                              title: Text("Ekleyece??iniz soru tipini se??iniz: "),
                              actions: [
                                ElevatedButton(
                                  child: Text("Soru G??rseli Ekle"),
                                  onPressed: (){
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                    AlertDialog alertDialog = new AlertDialog(
                                      title: Text("Soru Ekleme", style: TextStyle(color: Colors.green),),
                                      content: Container(
                                        child: SingleChildScrollView(
                                          physics: ClampingScrollPhysics(),
                                          child: Text("Sorunuz ??oktan se??meli mi?", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                      actions: [
                                        MaterialButton(
                                          child: Text("EVET", style: TextStyle(color: Colors.indigo, fontSize: 20),),
                                          onPressed: (){
                                            test_mesaji = true; soru_testmi = true;

//                                  setState(() {});
                                            Navigator.of(context, rootNavigator: true).pop("dialog");
                                            AlertDialog alertDialog = new AlertDialog(
                                              title: Text("Soru g??rselini ekleyece??iniz y??ntemi se??iniz:  "),
                                              actions: [
                                                Container( height: 50, width: 120,
                                                  child: FittedBox(
                                                    child: ElevatedButton(
                                                      child: Text("Telefondan soru se??"),
                                                      onPressed: ()async{
                                                        Navigator.of(context,rootNavigator: true).pop('dialog');
//                                                        var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                                                        gorsel_soru = true;
                                                        metinsel_soru = false;
//                                                        _soruSelected = image;

                                                        galeriden_resim = true;
                                                        kameradan_resim = false;

//                                          setState(() {});
                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                                                          action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                                        _soruYukle();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Container(height: 50, width: 120,
                                                  child: FittedBox(
                                                    child: ElevatedButton(
                                                        child: Text("Kameradan soru ??ek"),
                                                        onPressed: ()async{
                                                          Navigator.of(context,rootNavigator: true).pop('dialog');
//                                                          var image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
                                                          gorsel_soru = true;
                                                          metinsel_soru = false;
//                                                          _soruSelected = image;

                                                          galeriden_resim = false;
                                                          kameradan_resim = true;
//                                            setState(() {});
                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                                                            action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                                          _soruYukle();
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            );
                                            showDialog(context: context, builder: (_) => alertDialog);
                                          },
                                        ),
                                        MaterialButton(
                                          child: Text("HAYIR", style: TextStyle(color: Colors.indigo, fontSize: 20),),
                                          onPressed: (){
                                            test_mesaji = true; soru_testmi = false;
//                                  setState(() {});
                                            Navigator.of(context, rootNavigator: true).pop("dialog");
                                            AlertDialog alertDialog = new AlertDialog(
                                              title: Text("Soru g??rselini ekleyece??iniz y??ntemi se??iniz:  "),
                                              actions: [
                                                Container( height: 50, width: 120,
                                                  child: FittedBox(
                                                    child: ElevatedButton(
                                                      child: Text("Telefondan soru se??"),
                                                      onPressed: ()async{
                                                        Navigator.of(context,rootNavigator: true).pop('dialog');
//                                                        var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                                                        gorsel_soru = true;
                                                        metinsel_soru = false;
//                                                        _soruSelected = image;
                                                        galeriden_resim = true;
                                                        kameradan_resim = false;
//                                          setState(() {});
                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                                                          action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                                        _soruYukle();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Container( height: 50, width: 120,
                                                  child: FittedBox(
                                                    child: ElevatedButton(
                                                        child: Text("Kameradan soru ??ek"),
                                                        onPressed: ()async{
                                                          Navigator.of(context,rootNavigator: true).pop('dialog');
//                                                          var image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
                                                          gorsel_soru = true;
                                                          metinsel_soru = false;
//                                                          _soruSelected = image;
                                                          galeriden_resim = false;
                                                          kameradan_resim = true;
//                                            setState(() {});
                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                                                            action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                                          _soruYukle();
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            );
                                            showDialog(context: context, builder: (_) => alertDialog);
                                          },
                                        ),
                                      ],
                                    ); showDialog(context: context, builder: (_)=> alertDialog);
                                  },
                                ),
                                ElevatedButton(
                                  child: Text("Soru Metni Gir"),
                                  onPressed: (){
                                    Navigator.of(context,rootNavigator: true).pop('dialog');
                                    AlertDialog alertDialog = new AlertDialog(
                                      title: Text("Soru Ekleme", style: TextStyle(color: Colors.green),),
                                      content: Container(
                                        child: SingleChildScrollView(
                                          physics: ClampingScrollPhysics(),
                                          child: Text("Sorunuz ??oktan se??meli mi?", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                      actions: [
                                        MaterialButton(
                                            onPressed: (){
                                              test_mesaji = true; soru_testmi = true;

//                                  setState(() {});
                                              Navigator.of(context, rootNavigator: true).pop("dialog");
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                                                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                              _soruMetniGir();
                                            },
                                            child: Text("EVET", style: TextStyle(color: Colors.indigo, fontSize: 20),)),
                                        MaterialButton(
                                            onPressed: (){

                                              test_mesaji = true; soru_testmi = false;
//                                  setState(() {});
                                              Navigator.of(context, rootNavigator: true).pop("dialog");
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                                                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                              _soruMetniGir();
                                            },
                                            child: Text("HAYIR", style: TextStyle(color: Colors.indigo, fontSize: 20),)),
                                      ],
                                    ); showDialog(context: context, builder: (_)=> alertDialog);
                                    gorsel_soru = false;
                                    metinsel_soru = true;
//                        setState(() {});
                                  },
                                )
                              ],
                            ); showDialog(context: context, builder: (_) => alertDialog);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ]
          ),
        ),
      ),
      bottomNavigationBar: Visibility(
          child: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),)),

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

  void _aciklamaGir() async {
    TextEditingController _controller = TextEditingController();
    final _formKey = GlobalKey<FormState>();
/*
    Widget _uploadTextNoteAlertDialog() {
      return Container(
        height: 200, width: 400,
        child: Column(children: [
          ListTile(
              title: Text("Mevcut bilgi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              subtitle: map_solusturulan["aciklama"] == null || map_solusturulan["aciklama"] == ""
                  ? Text( "Soru i??in metinsel bir ????z??m/cevap girmediniz", style: TextStyle(fontStyle: FontStyle.italic),)
                  : Text(map_solusturulan["aciklama"], style: TextStyle(fontWeight: FontWeight.bold),)
          ),
          ListTile(
              title: Text("G??ncellenecek hali:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              subtitle: AtaWidget.of(context).formHelper == null
                  ? Text("Yeni bilgi giri??i bulunamad??", style: TextStyle(fontStyle: FontStyle.italic),)
                  : Text(AtaWidget.of(context).formHelper, style: TextStyle(fontWeight: FontWeight.bold),)
          ),

          Form(key: _formKey,
              child: Flexible(
                child: ListView(children: [
                  SizedBox(height: 10,),
                  TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _controller,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "S??nav??n??za a????klama girebilirsiniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "A????klama girmediniz.";
                        } return null;
                      }),
                ]),
              )),
        ]),
      );
    }
*/    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("A??IKLAMA G??R", style: TextStyle(color: Colors.orange),
            ),
//            content: _uploadTextNoteAlertDialog(),
            actions: [
              ElevatedButton(child: Text(AtaWidget.of(context).formHelper == null
                  ? map_solusturulan["aciklama"] == null || map_solusturulan["aciklama"] == ""
                  ? "A????klama Gir" : "A????klamay?? De??i??tir" : "A????klamay?? De??i??tir"),
                  onPressed: () {
                    AtaWidget.of(context).formHelper = null;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "aciklama",
                      map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                      storageReference: storageReference, mapSoru: null, idSoru: null,) ));

                    Navigator.of(context, rootNavigator: true).pop("dialog");
                  }
              ),
              ElevatedButton(child: Text("Vazge??"),
                  onPressed: () {
/*                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                      OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, storageReference: storageReference,
                        collectionReference: collectionReference, grid_gorunum: grid_gorunum,)));
                  Navigator.of(context, rootNavigator: true).pop("dialog");
*/
                    AtaWidget.of(context).formHelper = null;
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                  }
              ),
/*              ElevatedButton(
                child: Text("Y??kle"),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    final newaciklama = _controller.text;

                    final newaciklama = AtaWidget.of(context).formHelper;
                    await collectionReference.doc(id_solusturulan).update({"aciklama": newaciklama});

//                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("A????klama ba??ar??yla g??ncellendi"),
                      action: SnackBarAction(label: "Gizle", onPressed: (){
                        SnackBarClosedReason.hide;
                      },),));

                    AtaWidget.of(context).formHelper = null;
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.pop(context);
//                  }
                },
                                ),
*/            ],
          );
        });
  }

  Future ogrenci_cevapEkle(dynamic idSoru, dynamic mapSoru) async {

    AlertDialog alertDialog = new AlertDialog (
      title: Text("Bilgiledirme: ", style: TextStyle(color: Colors.green)),
      content: Text( AtaWidget.of(context).formHelper_ogrenci_cevap_baslik == null ?
        "*Anlad??m* butonuna bast??????n??zda Cevap/????z??m??n??ze ba??l??k ve a????klama girmeniz i??in *FORMu DOLDUR sayfas??na y??nlendirileceksiniz. Ard??ndan ba??l??k ve a????klamay?? "
            "onaylarak bu sayfaya d??nebilir, cevap ekleme i??lemine devam edebilirsiniz. Test sorular??nda ????kk?? i??aretlemek i??in *????klar?? G??r* butonuna t??klay??n??z"
          : "*FORMu DOLDUR sayfas??ndan cevab??n??z i??in ba??l??k ve a????klama girdiniz. *G??rsel Ekle butonuna basarak dilerseniz cevab??n??z i??in telefonunuzdan g??rsel "
          "ekleyebilirsiniz. G??rsel eklemeden devam etmek *Devam Et butonuna bas??n??z."
          , textAlign: TextAlign.center,),
      actions: [
        ElevatedButton(
          child: Text("Vazge??"),
          onPressed: () {
            AtaWidget.of(context).formHelper_ogrenci_cevap_baslik = null;
            AtaWidget.of(context).formHelper_ogrenci_cevap_aciklama = null;
            Navigator.of(context, rootNavigator: true).pop("dialog");
          },
        ),
        Visibility( visible: AtaWidget.of(context).formHelper_ogrenci_cevap_baslik == null ? false : true,
          child: ElevatedButton(
            child: Text("Devam Et"),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("dialog");

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
              ogrenci_cevapGonder(idSoru, mapSoru);
            },
          ),
        ),
        Visibility( visible: AtaWidget.of(context).formHelper_ogrenci_cevap_baslik == null ? false : true,
          child: ElevatedButton(
            child: Text("G??rsel Ekle"),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("dialog");

              var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
              _imageSelected = image;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
              ogrenci_cevapGonder(idSoru, mapSoru);
            },
          ),
        ),
        Visibility( visible: AtaWidget.of(context).formHelper_ogrenci_cevap_baslik == null ? true : false,
          child: MaterialButton(
              child: Text("Anlad??m", style: TextStyle(color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.black,),),
              onPressed: ()async {
                Navigator.of(context, rootNavigator: true).pop("dialog");

                Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "ogrenci_cevap",
                  map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                  storageReference: storageReference, mapSoru: mapSoru, idSoru: idSoru,) ));

              }),
        )
      ],
    );showDialog( barrierDismissible: false,
        context: context, builder: (_) => alertDialog);
  }

//********????RENC?? CEVAPLARI FORMU DOLADURA AKTARILMADI*********
  void ogrenci_cevapGonder(dynamic idSoru, dynamic mapSoru) async {
    String baslik = AtaWidget.of(context).formHelper_ogrenci_cevap_baslik;
    String newaciklama = AtaWidget.of(context).formHelper_ogrenci_cevap_aciklama;

    TextEditingController _baslikci = TextEditingController();
    TextEditingController _aciklamaci = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    Widget _uploadImageAlertDialog() {
      return Container(
        height: 500, width: 400,
        child: ListView(children: [
          ListTile(
            title: Text("Ba??l??k:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            subtitle: baslik == null ?
            Text("Cevab??n??z??n ba??l??????n?? giriniz.", style: TextStyle(fontStyle: FontStyle.italic),)
                : Text(baslik, style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            title: Text("A????klama:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            subtitle: newaciklama == null ?
            Text("Cevab??n??z??n a????klamas??n?? giriniz.", style: TextStyle(fontStyle: FontStyle.italic),)
                : Text(newaciklama, style: TextStyle(fontWeight: FontWeight.bold),),
          ),
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
                      child: Text("Resim se??ilmedi. Cevab??n??za g??rsel eklenmeyecektir.",
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ))
                      : Image.file(_imageSelected, fit: BoxFit.contain,
                  )),
            ),
          ),
/*
          Form(key: _formKey,
              child: Flexible(
                child: ListView(children: [
                  SizedBox(height: 10,),
                  TextFormField(
                      controller: _baslikci,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Cevab??n??z i??in ba??l??k giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "ba??l??k girmeniz gerekmektedir.";
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
                            labelText: "????z??m??n??z?? a????klay??n??z."),
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                        validator: (String PicName) {
                          if (PicName.isEmpty) {return "Alan bo?? b??rak??lamaz.";
                          } return null;
                        }),
                  ),

                ]),
              )),
*/
          GestureDetector(
            onTap: (){

              AlertDialog alertDialog = new AlertDialog(title: Column(children: [
                Visibility(visible: _imageSelected == null ? false: true, child: SizedBox(height: 10,)),
                Visibility(visible: _imageSelected == null ? false: true,
                  child: Text("* G??rselin y??klenme s??resi boyutuna ve internet h??z??n??za ba??l??d??r. Bir defada sadece tek bir g??rsel y??kleyebilirsiniz. *",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.black),
                    textAlign: TextAlign.center,),
                ),
                SizedBox(height: 10,),
                Visibility(visible: _imageSelected == null ? false: true,
                  child: Text("*G??rselinizi daha b??y??k g??rmek i??in ??zerine ??ift t??klay??n??z.*",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.black),
                    textAlign: TextAlign.center,),
                ),
                SizedBox(height: 10,),
/*
                Text("** A????klaman??z?? daha b??y??k g??rmek i??in ??zerine ??ift t??klay??n??z.**",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.black),
                  textAlign: TextAlign.center,),
                SizedBox(height: 10,),
*/
                Text("*** Cevaplama i??leminin tek bir y??kleme ile tamamlanmas?? tavsiye edilir. Bir soru i??in birden fazla y??kleme yapacaksan??z ba??l??k k??sm??nda "
                    "numaraland??rma yapabilir ve bunu a????klama k??sm??nda belirtebilirsiniz.***",
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
                    TextSpan(text: "*??nemli bilgilendirmeleri g??rmek i??in ",
                        style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
                    TextSpan(text: " Buraya t??klay??n??z. ", style: TextStyle(color: Colors.indigo,
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
        title: Text("Cevab??n?? Y??kle", style: TextStyle(color: Colors.green),
        ),
        content: _uploadImageAlertDialog(),
        actions: [
         Visibility( visible: _imageSelected == null ? false : true,
           child: Container( height: 50, width: 80,
             child: FittedBox(
               child: FloatingActionButton.extended(
                elevation: 0,
                icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                backgroundColor: Colors.white,
                onPressed: () async {
                  if (_imageSelected == null) return;
                  var image = await cropImage(_imageSelected);
                  if (image == null)
                    return;
                  _imageSelected = image;
                  Navigator.of(context, rootNavigator: true).pop("dialog");

                  showDialog(context: context, builder: (_) {
                    return AlertDialog(
                      title: Text("Cevab??n?? Y??kle", style: TextStyle(color: Colors.green),
                      ),
                      content: _uploadImageAlertDialog(),
                      actions: [

                        ElevatedButton(
                          child: Text("Vazge??"),
                          onPressed: () {
                            baslik = null; newaciklama = null;
                            AtaWidget.of(context).formHelper_ogrenci_cevap_baslik = null;
                            AtaWidget.of(context).formHelper_ogrenci_cevap_aciklama = null;
                            Navigator.of(context, rootNavigator: true).pop("dialog");
                          },
                        ),
                        Builder(
                          builder: (context)=> GestureDetector(onDoubleTap: (){},
                            child: ElevatedButton(
                              child: Text("Y??kle"),
                              onPressed: () async {
/*
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
*/
                                String cevaplayan = AtaWidget.of(context).kullaniciadi;
                                List <dynamic> cevapladigi_sorular = [];
                                List <dynamic> dogru_cevaplar = [];
                                String sinavi_cevaplayan;
                                int puan = -1;
                                String sinavi_cevaplayan_id;

                                await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar").where("mail", isEqualTo: AtaWidget.of(context).kullanicimail)
                                    .get().then((value) { value.docs.forEach((element) {
                                  cevapladigi_sorular = element["cevapladigi_sorular"];
                                  dogru_cevaplar = element["dogru_cevaplar"];
                                  sinavi_cevaplayan = element["cevaplayan"];
                                  sinavi_cevaplayan_id = element.id.toString();
//                          setState(() {});
                                });
                                });
                                if(sinavi_cevaplayan == AtaWidget.of(context).kullaniciadi){

                                  cevapladigi_sorular.add(mapSoru["baslik"]);
                                  await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar").doc(sinavi_cevaplayan_id)
                                      .update({"cevapladigi_sorular": cevapladigi_sorular});
                                } else {

                                  cevapladigi_sorular.add(mapSoru["baslik"]);
                                  await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar").add({"cevaplayan": AtaWidget.of(context).kullaniciadi,
                                    "mail": AtaWidget.of(context).kullanicimail, "tarih": DateTime.now().toString(), "puan": -1, "cevapladigi_sorular": cevapladigi_sorular,
                                    "dogru_cevaplar" : dogru_cevaplar,
                                  });
                                }

                                if(_imageSelected != null){
                                  Reference ref = await storageReference.child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                                      .child(mapSoru["baslik"]).child("cevaplayanlarin_gorselleri").child(baslik + "_" + cevaplayan);

                                  await ref.putFile(_imageSelected);
                                  var downloadUrl = await ref.getDownloadURL();
                                  String url = downloadUrl.toString();

                                  DocumentReference _ref = await collectionReference.doc(id_solusturulan).collection("sorular")
                                      .doc(idSoru.toString()).collection("soruyu_cevaplayanlar").add({"gorsel": url, "baslik": baslik, "aciklama": newaciklama,
                                    "tarih": DateTime.now().toString(), "cevaplayan": cevaplayan, "puan" : -1, "dogrumu": false});
                                  soruyu_cevaplayan_id = _ref.id.toString();
                                  url = ""; baslik = ""; newaciklama = "";

                                } else {
                                  await collectionReference.doc(id_solusturulan).collection("sorular")
                                      .doc(idSoru.toString()).collection("soruyu_cevaplayanlar").add({"gorsel": "", "baslik": baslik, "aciklama": newaciklama,
                                    "tarih": DateTime.now().toString(), "cevaplayan": cevaplayan, "puan" : -1, "dogrumu": false});
                                  baslik = ""; newaciklama = "";
                                }

                                baslik = null; newaciklama = null;
                                AtaWidget.of(context).formHelper_ogrenci_cevap_baslik = null;
                                AtaWidget.of(context).formHelper_ogrenci_cevap_aciklama = null;
                                Navigator.of(context, rootNavigator: true).pop("dialog");

                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevap ba??ar??yla g??nderildi."),
                                  action: SnackBarAction(label: "Gizle", onPressed: (){
                                    SnackBarClosedReason.hide;
                                  },),));

                                Navigator.of(context, rootNavigator: true).pop('dialog');
//                  }
                              },
                            ),
                          ),
                        ),

                      ],
                    );
                  });
                }
               ),
             ),
           ),
         ),

          ElevatedButton(
            child: Text("Vazge??"),
            onPressed: () {
              baslik = null; newaciklama = null;
              AtaWidget.of(context).formHelper_ogrenci_cevap_baslik = null;
              AtaWidget.of(context).formHelper_ogrenci_cevap_aciklama = null;
              Navigator.of(context, rootNavigator: true).pop("dialog");
            },
          ),
          Builder(
            builder: (context)=> GestureDetector(onDoubleTap: (){},
              child: ElevatedButton(
                child: Text("Y??kle"),
                onPressed: () async {
/*
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
*/
                    String cevaplayan = AtaWidget.of(context).kullaniciadi;
                    List <dynamic> cevapladigi_sorular = [];
                    List <dynamic> dogru_cevaplar = [];
                    String sinavi_cevaplayan;
                    int puan = -1;
                    String sinavi_cevaplayan_id;

                    await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar").where("mail", isEqualTo: AtaWidget.of(context).kullanicimail)
                        .get().then((value) { value.docs.forEach((element) {
                      cevapladigi_sorular = element["cevapladigi_sorular"];
                      dogru_cevaplar = element["dogru_cevaplar"];
                      sinavi_cevaplayan = element["cevaplayan"];
                      sinavi_cevaplayan_id = element.id.toString();
//                          setState(() {});
                    });
                    });
                    if(sinavi_cevaplayan == AtaWidget.of(context).kullaniciadi){

                      cevapladigi_sorular.add(mapSoru["baslik"]);
                      await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar").doc(sinavi_cevaplayan_id)
                          .update({"cevapladigi_sorular": cevapladigi_sorular});
                    } else {

                      cevapladigi_sorular.add(mapSoru["baslik"]);
                      await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar").add({"cevaplayan": AtaWidget.of(context).kullaniciadi,
                        "mail": AtaWidget.of(context).kullanicimail, "tarih": DateTime.now().toString(), "puan": -1, "cevapladigi_sorular": cevapladigi_sorular,
                        "dogru_cevaplar" : dogru_cevaplar,
                      });
                    }

                    if(_imageSelected != null){
                      Reference ref = await storageReference.child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                          .child(mapSoru["baslik"]).child("cevaplayanlarin_gorselleri").child(baslik + "_" + cevaplayan);

                      await ref.putFile(_imageSelected);
                      var downloadUrl = await ref.getDownloadURL();
                      String url = downloadUrl.toString();

                      DocumentReference _ref = await collectionReference.doc(id_solusturulan).collection("sorular")
                          .doc(idSoru.toString()).collection("soruyu_cevaplayanlar").add({"gorsel": url, "baslik": baslik, "aciklama": newaciklama,
                        "tarih": DateTime.now().toString(), "cevaplayan": cevaplayan, "puan" : -1, "dogrumu": false});
                      soruyu_cevaplayan_id = _ref.id.toString();
                      url = ""; baslik = ""; newaciklama = "";

                    } else {
                      await collectionReference.doc(id_solusturulan).collection("sorular")
                          .doc(idSoru.toString()).collection("soruyu_cevaplayanlar").add({"gorsel": "", "baslik": baslik, "aciklama": newaciklama,
                        "tarih": DateTime.now().toString(), "cevaplayan": cevaplayan, "puan" : -1, "dogrumu": false});
                      baslik = ""; newaciklama = "";
                    }

                    baslik = null; newaciklama = null;
                    AtaWidget.of(context).formHelper_ogrenci_cevap_baslik = null;
                    AtaWidget.of(context).formHelper_ogrenci_cevap_aciklama = null;
                    Navigator.of(context, rootNavigator: true).pop("dialog");

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevap ba??ar??yla g??nderildi."),
                      action: SnackBarAction(label: "Gizle", onPressed: (){
                        SnackBarClosedReason.hide;
                      },),));

                    Navigator.of(context, rootNavigator: true).pop('dialog');
//                  }
                },
              ),
            ),
          ),

        ],
      );
    });
  }

  void metinselCevapEkle(dynamic idSoru, dynamic mapSoru) async {
    TextEditingController _aciklamaci = TextEditingController();
    final _formKey = GlobalKey<FormState>();
/*
    Widget _uploadTextNoteAlertDialog() {
      return Container(
        height: 200, width: 400,
        child: Column(children: [
          ListTile(
              title: Text("Mevcut bilgi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              subtitle: mapSoru["metinsel_cevap"] == null || mapSoru["metinsel_cevap"] == ""
                  ? Text( "Soru i??in metinsel bir ????z??m/cevap girmediniz", style: TextStyle(fontStyle: FontStyle.italic),)
                  : Text(mapSoru["metinsel_cevap"], style: TextStyle(fontWeight: FontWeight.bold),)
          ),
          ListTile(
            title: Text("G??ncellenecek hali:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            subtitle: AtaWidget.of(context).formHelper == null
                ? Text("Yeni bilgi giri??i bulunamad??", style: TextStyle(fontStyle: FontStyle.italic),)
                : Text(AtaWidget.of(context).formHelper, style: TextStyle(fontWeight: FontWeight.bold),)
          ),

          Form(key: _formKey,
              child: Flexible(
                child: ListView(children: [
                  SizedBox(height: 10,),
                  TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _aciklamaci,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Sorunuzun ????z??m??n?? giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "Alan bo?? b??rak??lamaz.";
                        } return null;
                      }),
                ]),
              )),

        ]),
      );}
*/
      showDialog( barrierDismissible: false, context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("????z??m?? Metin Olarak Gir: ", style: TextStyle(color: Colors.orange),),
//            content: _uploadTextNoteAlertDialog(),
            actions: [
              ElevatedButton(child: Text(AtaWidget.of(context).formHelper == null
                  ? mapSoru["metinsel_cevap"] == null || mapSoru["metinsel_cevap"] == ""
                  ? "????z??m Gir" : "????z??m?? De??i??tir" : "????z??m?? De??i??tir"),
                onPressed: () {
                  AtaWidget.of(context).formHelper = null;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "metinsel_cevap",
                    map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                    storageReference: storageReference, mapSoru: mapSoru, idSoru: idSoru,) ));
                  Navigator.of(context, rootNavigator: true).pop("dialog");
                }
              ),
              ElevatedButton(child: Text("Vazge??"),
                onPressed: () {
/*                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                      OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, storageReference: storageReference,
                        collectionReference: collectionReference, grid_gorunum: grid_gorunum,)));
                  Navigator.of(context, rootNavigator: true).pop("dialog");
*/
                AtaWidget.of(context).formHelper = null;
                Navigator.of(context, rootNavigator: true).pop("dialog");
                }
              ),
/*              GestureDetector(onDoubleTap: (){},
                child: ElevatedButton(
                  child: Text("Y??kle"),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      final newaciklama = _aciklamaci.text.trim().toLowerCase();

                      final newaciklama = AtaWidget.of(context).formHelper;
                      await collectionReference.doc(id_solusturulan.toString()).collection("sorular")
                          .doc(idSoru.toString()).update({"gorsel_cevap": "", "metinsel_cevap": newaciklama});

                      try {
                        final Reference ref = await FirebaseStorage.instance.ref().child("users")
                            .child(map_solusturulan["hazirlayan"])
                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                            .child("${mapSoru["baslik"]}").child("${mapSoru["baslik"]} n??n cevab??");
                        await ref.delete();
                      } catch (e) {debugPrint(e.toString());}

//                      setState(() {});

                      AtaWidget.of(context).formHelper = null;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????z??m ba??ar??yla eklendi"),));
                      Navigator.of(context, rootNavigator: true).pop('dialog');
//                    }
                  },
                ),
               ),
*/            ],
          );
        });

  }

  void _galeridenCozumEkle(dynamic idSoru, dynamic mapSoru) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    _imageSelected = image;
//    setState(() {});


    String message0 = "**G??rselin y??klenme s??resi boyutuna ve internet h??z??n??za ba??l?? olarak uzun s??rebilir.**";

    Widget _uploadImageAlertDialog() {
      return Container(height: 300, width: 400,
        child: Column(children: [
          Flexible(
            child: Container(
                child: _imageSelected == null ? Center(
                    child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ))
                    : Image.file(_imageSelected, fit: BoxFit.contain,)),
          ),
          SizedBox(height: 10,),
          Text(message0, textAlign: TextAlign.center, style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange,)
          ),
        ]),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text("????z??m Y??kleme", style: TextStyle(color: Colors.green),
        ),
        content: _uploadImageAlertDialog(),
        actions: [
          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container( height: 80, width: 80,
                child: FittedBox(
                  child: FloatingActionButton.extended(
                    elevation: 0,
                    icon: Icon(Icons.crop, color: Colors.purple, size: 40,),
                    label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      if(_imageSelected == null) return;
                      var image = await cropImage(_imageSelected);
                      if(image==null)
                        return;
                      _imageSelected = image;
                      Navigator.of(context, rootNavigator: true).pop("dialog");

                      showDialog(context: context, builder: (_) {
                        return AlertDialog(
                          title: Text("????z??m Y??kleme", style: TextStyle(color: Colors.green),
                          ),
                          content: _uploadImageAlertDialog(),
                          actions: [
                            GestureDetector(onDoubleTap: (){},
                              child: ElevatedButton(
                                child: Text("Y??kle"),
                                onPressed: () async {

                                  final Reference ref =  await FirebaseStorage.instance.ref().child("users")
                                      .child(map_solusturulan["hazirlayan"]).child("sinavlar").child("olusturulan_sinavlar")
                                      .child(map_solusturulan["baslik"]).child("sorular")
                                      .child("${mapSoru["baslik"]}").child("${mapSoru["baslik"]} n??n cevab??");


                                  await ref.putFile(_imageSelected);
                                  var downloadUrl = await ref.getDownloadURL();
                                  String url = downloadUrl.toString();
                                  await collectionReference.doc(id_solusturulan.toString()).collection("sorular")
                                      .doc(idSoru).update({"gorsel_cevap": url, "metinsel_cevap": ""});

//                setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????z??m ba??ar??yla eklendi"),));
                                  Navigator.of(context, rootNavigator: true).pop('dialog');

                                },
                              ),
                            ),

                          ],
                        );
                      });
                    },
                  ),
                ),
              ),
              SizedBox(width: 150,),
              GestureDetector(onDoubleTap: (){},
                child: ElevatedButton(
                  child: Text("Y??kle"),
                  onPressed: () async {

                    final Reference ref =  await FirebaseStorage.instance.ref().child("users")
                        .child(map_solusturulan["hazirlayan"]).child("sinavlar").child("olusturulan_sinavlar")
                        .child(map_solusturulan["baslik"]).child("sorular")
                        .child("${mapSoru["baslik"]}").child("${mapSoru["baslik"]} n??n cevab??");


                    await ref.putFile(_imageSelected);
                    var downloadUrl = await ref.getDownloadURL();
                    String url = downloadUrl.toString();
                    await collectionReference.doc(id_solusturulan.toString()).collection("sorular")
                        .doc(idSoru).update({"gorsel_cevap": url, "metinsel_cevap": ""});

//                setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????z??m ba??ar??yla eklendi"),));
                    Navigator.of(context, rootNavigator: true).pop('dialog');

                  },
                ),
              ),
            ],
          ),

        ],
      );
    });

  }

  void _kameradanCozumEkle(dynamic idSoru, dynamic mapSoru) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
    _imageSelected = image;

//    setState(() {});

    String message0 = "**G??rselin y??klenme s??resi boyutuna ve internet h??z??n??za ba??l?? olarak uzun s??rebilir.**";

    Widget _uploadImageAlertDialog() {
      return Container(height: 300, width: 400,
        child: Column(children: [
          Flexible(
            child: Container(
                child: _imageSelected == null ? Center(
                    child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ))
                    : Image.file(_imageSelected, fit: BoxFit.contain,)),
          ),
          SizedBox(height: 10,),
          Text(message0, textAlign: TextAlign.center, style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange,)
          ),
        ]),
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text("????z??m Y??kleme", style: TextStyle(color: Colors.green),
        ),
        content: _uploadImageAlertDialog(),
        actions: [
          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container( height: 80, width: 80,
                child: FittedBox(
                  child: FloatingActionButton.extended(
                    elevation: 0,
                    icon: Icon(Icons.crop, color: Colors.purple, size: 40,),
                    label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      if(_imageSelected == null) return;
                      var image = await cropImage(_imageSelected);
                      if(image==null)
                        return;
                      _imageSelected = image;
                      Navigator.of(context, rootNavigator: true).pop("dialog");

                      showDialog(context: context, builder: (_) {
                        return AlertDialog(
                          title: Text("????z??m Y??kleme", style: TextStyle(color: Colors.green),
                          ),
                          content: _uploadImageAlertDialog(),
                          actions: [
                            GestureDetector(onDoubleTap: (){},
                              child: ElevatedButton(
                                child: Text("Y??kle"),
                                onPressed: () async {

                                  final Reference ref =  await FirebaseStorage.instance.ref().child("users")
                                      .child(map_solusturulan["hazirlayan"]).child("sinavlar").child("olusturulan_sinavlar")
                                      .child(map_solusturulan["baslik"]).child("sorular")
                                      .child("${mapSoru["baslik"]}").child("${mapSoru["baslik"]} n??n cevab??");


                                  await ref.putFile(_imageSelected);
                                  var downloadUrl = await ref.getDownloadURL();
                                  String url = downloadUrl.toString();
                                  await collectionReference.doc(id_solusturulan.toString()).collection("sorular")
                                      .doc(idSoru).update({"gorsel_cevap": url, "metinsel_cevap": ""});

//                setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????z??m ba??ar??yla eklendi"),));
                                  Navigator.of(context, rootNavigator: true).pop('dialog');

                                },
                              ),
                            ),

                          ],
                        );
                      });
                    },
                  ),
                ),
              ),
              SizedBox(width: 150,),
              GestureDetector(onDoubleTap: (){},
                child: ElevatedButton(
                  child: Text("Y??kle"),
                  onPressed: () async {

                    final Reference ref =  await FirebaseStorage.instance.ref().child("users")
                        .child(map_solusturulan["hazirlayan"]).child("sinavlar").child("olusturulan_sinavlar")
                        .child(map_solusturulan["baslik"]).child("sorular")
                        .child("${mapSoru["baslik"]}").child("${mapSoru["baslik"]} n??n cevab??");


                    await ref.putFile(_imageSelected);
                    var downloadUrl = await ref.getDownloadURL();
                    String url = downloadUrl.toString();
                    await collectionReference.doc(id_solusturulan.toString()).collection("sorular")
                        .doc(idSoru).update({"gorsel_cevap": url, "metinsel_cevap": ""});

//                setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????z??m ba??ar??yla eklendi"),));
                    Navigator.of(context, rootNavigator: true).pop('dialog');

                  },
                ),
              ),
            ],
          ),
        ],
      );
    });

  }

  void siklariGor(dynamic idSoru, dynamic mapSoru) async {
    String message; Color sik_rengi; String doc_sik;

    await collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).collection("isaretleyenler").where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
        .get().then((QuerySnapshot querySnapshot)=>{
          querySnapshot.docs.forEach((doc) {
        message = "Bu soru i??in ${doc["sik"]} ????kk??n?? i??aretlediniz.";
        sik_rengi = Colors.indigoAccent;
        doc_sik = doc["sik"];
      })
    });

    Widget SiklariGorWidgetAlertDialog() {
      return Container(height: 500, width: 500,
        child: SingleChildScrollView( physics: ClampingScrollPhysics(),
          child: Column( children: [
            Container( height: 350,
              child: GridView.count(
                crossAxisSpacing: 10, mainAxisSpacing: 10, crossAxisCount: 2, children: [
                  GestureDetector(
                    onTap: () async {
                      _sikkiGor(mapSoru, idSoru, mapSoru["A_gorsel"], mapSoru["A_metinsel"], "A", doc_sik);
                    },
                    child: GridTile(
                      header: Container( color: Color(0xAA304030), child: Text("A)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,
                          backgroundColor: doc_sik == "A" ? sik_rengi : Color(0xAA304030) ))),
                      child: Center(child:
                        mapSoru["A_gorsel"] == "" || mapSoru["A_gorsel"] == " " || mapSoru["A_gorsel"] == null ?
                          mapSoru["A_metinsel"] == "" || mapSoru["A_metinsel"] == " " || mapSoru["A_metinsel"] == null ?
                              Text("??IK G??R??LMED?? !!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                              : Container(
                                  child: SingleChildScrollView( physics: ClampingScrollPhysics(),
                                      child: Text(mapSoru["A_metinsel"], style: TextStyle(color: Colors.lightBlueAccent, fontStyle: FontStyle.italic)))) :
                            Image.network(mapSoru["A_gorsel"], fit: BoxFit.contain, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                              return Center(
                                child: Text("??IKKA ULA??ILAMADI", style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic)),
                              );
                            },),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () async {
                    _sikkiGor(mapSoru, idSoru, mapSoru["B_gorsel"], mapSoru["B_metinsel"], "B", doc_sik);
                  },
                    child: GridTile(
                      header: Container( color: Color(0xAA304030), child: Text("B)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,
                          backgroundColor: doc_sik == "B" ? sik_rengi : Color(0xAA304030) ))),
                      child: Center(child:
                        mapSoru["B_gorsel"] == "" || mapSoru["B_gorsel"] == " " || mapSoru["B_gorsel"] == null ?
                          mapSoru["B_metinsel"] == "" || mapSoru["B_metinsel"] == " " || mapSoru["B_metinsel"] == null ?
                            Text("??IK G??R??LMED??", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                              : Container(child: SingleChildScrollView( physics: ClampingScrollPhysics(),
                                  child: Text(mapSoru["B_metinsel"], style: TextStyle(color: Colors.lightBlueAccent, fontStyle: FontStyle.italic)))) :
                          Image.network(mapSoru["B_gorsel"], fit: BoxFit.contain, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                            return Center(
                              child: Text("??IKKA ULA??ILAMADI", style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic)),
                            );
                          },),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () async {
                    _sikkiGor(mapSoru, idSoru, mapSoru["C_gorsel"], mapSoru["C_metinsel"], "C", doc_sik);
                  },
                  child: GridTile(
                    header: Container( color: Color(0xAA304030), child: Text("C)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,
                        backgroundColor: doc_sik == "C" ? sik_rengi : Color(0xAA304030) ))),
                    child: Center(child:
                      mapSoru["C_gorsel"] == "" || mapSoru["C_gorsel"] == " " || mapSoru["C_gorsel"] == null ?
                        mapSoru["C_metinsel"] == "" || mapSoru["C_metinsel"] == " " || mapSoru["C_metinsel"] == null ?
                          Text("??IK G??R??LMED??", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                            : Container(child: SingleChildScrollView( physics: ClampingScrollPhysics(),
                                child: Text(mapSoru["C_metinsel"], style: TextStyle(color: Colors.lightBlueAccent, fontStyle: FontStyle.italic)))) :
                        Image.network(mapSoru["C_gorsel"], fit: BoxFit.contain, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return Center(
                            child: Text("??IKKA ULA??ILAMADI", style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic)),
                          );
                        },),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    _sikkiGor(mapSoru, idSoru, mapSoru["D_gorsel"], mapSoru["D_metinsel"], "D", doc_sik);
                  },
                  child: GridTile(
                    header: Container( color: Color(0xAA304030), child: Text("D)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,
                        backgroundColor: doc_sik == "D" ? sik_rengi : Color(0xAA304030) ))),
                    child: Center(child:
                       mapSoru["D_gorsel"] == "" || mapSoru["D_gorsel"] == " " || mapSoru["D_gorsel"] == null ?
                        mapSoru["D_metinsel"] == "" || mapSoru["D_metinsel"] == " " || mapSoru["D_metinsel"] == null ?
                          Text("??IK G??R??LMED??", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                            : Container(child: SingleChildScrollView(physics: ClampingScrollPhysics(),
                                child: Text(mapSoru["D_metinsel"], style: TextStyle(color: Colors.lightBlueAccent, fontStyle: FontStyle.italic)))) :
                        Image.network(mapSoru["D_gorsel"], fit: BoxFit.contain, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return Center(
                            child: Text("??IKKA ULA??ILAMADI", style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic)),
                          );
                        },),
                    ),
                  ),
                ),
              ],
              ),
            ),
            SizedBox(height: 10,),
            Text( AtaWidget.of(context).kullaniciadi != map_solusturulan["hazirlayan"] ?
                "*Daha b??y??k g??rmek ve i??retlemek i??in ????kka t??klay??n??z. ????aretledi??iniz ????kk?? g??rmek ????klar penceresini kapat??p yeniden a????n??z."
                " Baz?? g??rseller boyutundan dolay?? ge?? gelebilir."
                : "*Daha b??y??k g??rmek, de??i??tirmek yada do??ru olarak se??mek i??in ????kka t??klay??n??z. Baz?? g??rseller boyutundan dolay?? ge?? gelebilir.",
                textAlign: TextAlign.justify, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange,)
            ),
            Visibility(visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false, child: SizedBox(height: 10,)),
            Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
              child: Text("Bu soru i??in ${mapSoru["dogru_sik"]} ????kk??n?? do??ru olarak belirlediniz.", textAlign: TextAlign.justify
                  , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.white)
              ),
            ),
            Visibility( visible: message == null ? false : true ,child: SizedBox(height: 10,)),
            Visibility( visible: message == null ? false : true,
              child: Text(message == null ? "" : message, textAlign: TextAlign.justify
                  , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.white)
              ),
            ),
          ]),
        ),
      );
    }
    showDialog(context: context, builder: (_) {
        return AlertDialog(backgroundColor: Color(0xAA304030),
          title: Text(mapSoru["baslik"] + " n??n ????klar??", style: TextStyle(color: Colors.green),),
          content: SiklariGorWidgetAlertDialog(),
          actions: [
            Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
              child: ElevatedButton(child: Text("????aretlemeler"),
                onPressed: (){
                  AlertDialog alertDialog = new AlertDialog (
                    title: Text("????aretleme Analizi: ", style: TextStyle(color: Colors.green)),
                    content: Text("Bu analiz sadece i??aretlenen ????klar baz al??narak yap??lm????t??r.", style: TextStyle(fontWeight: FontWeight.bold)),
                    actions: [
                      ElevatedButton(child: Text("????aretlemeleri G??r"),
                        onPressed: () async {
                          AtaWidget.of(context).olusturulanSinavSoru_gonderilenCevaplar = false;
                          AtaWidget.of(context).hazirSinav_gonderilenCevaplar = false;
                          AtaWidget.of(context).olusturulanSinav_gonderilenCevaplar = false;
                          AtaWidget.of(context).olusturulanSinavTestSorusu_isaretleyenler = true;

                          List <dynamic> _dogruSiktan_puanCevaplayan = [];

                          await collectionReference.doc(id_solusturulan.toString()).collection("sorular").doc(idSoru.toString())
                              .collection("dogruSik_isaretleyenler").get().then((_dogruSik_isaretleyenler) =>
                              _dogruSik_isaretleyenler.docs.forEach((_dogruSik_isaretleyenlerin) {
                                _dogruSiktan_puanCevaplayan.add(_dogruSik_isaretleyenlerin["cevaplayan"]);
                              }));
                          AtaWidget.of(context).dogruSiktan_puanCevaplayan = _dogruSiktan_puanCevaplayan;

//                          setState(() {});

                          Navigator.of(context, rootNavigator: true).pop("dialog");
                          Navigator.of(context, rootNavigator: true).pop("dialog");
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              GonderilenCevaplarPage(map_cevaplanan: map_solusturulan, id_cevaplanan: id_solusturulan,
                                collectionReference: collectionReference, storageReference: storageReference, mapSoru: mapSoru,
                                idSoru: idSoru,)));
                        },
                      ),
                    ],
                  ); showDialog(context: context, builder: (_) => alertDialog);
                },
              ),
            ),
          ],
        );
      }
    );
    print("message: " + message.toString());
    print("sik_rengi: " + sik_rengi.toString());
    print("doc_sik: " + doc_sik.toString());

  }

  void _sikkiGor(dynamic mapSoru, dynamic idSoru, String mapSoru_sik_gorsel, String mapSoru_sik_metinsel, String sik, String doc_sik) async {

    print(sik);
    Widget SetUpAlertDialogContainer() {
      return Container(
        height: 450, width: 500,
        child: mapSoru_sik_gorsel == "" || mapSoru_sik_gorsel == " " || mapSoru_sik_gorsel == null ?
        mapSoru_sik_metinsel == "" || mapSoru_sik_metinsel == " " ||mapSoru_sik_metinsel == null ?
        Text("??IK G??R??LMED?? !!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
            : Container(
            child: SingleChildScrollView( physics: ClampingScrollPhysics(),
                child: Center(child: Text(mapSoru_sik_metinsel, style: TextStyle(color: Colors.lightBlueAccent, fontStyle: FontStyle.italic))))) :
        Image.network(mapSoru_sik_gorsel, fit: BoxFit.fill, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
          return Center(
            child: Text("??IKKA ULA??ILAMADI", style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic)),
          );
        },),
      );
    }
    showDialog(context: context, builder: (_) {
          return AlertDialog(
            backgroundColor: Color(0xAA304030),
            title: Text(sik + ")", style: TextStyle(color: Colors.white, backgroundColor: doc_sik == sik ? Colors.indigoAccent : Color(0xAA304030)),),
            content: SetUpAlertDialogContainer(),
            actions: [
              Wrap(
                direction: Axis.horizontal, spacing: 4,
                children: [
                  Visibility( visible: mapSoru_sik_gorsel == "" || mapSoru_sik_gorsel == " " || mapSoru_sik_gorsel == null ? false : true,
                    child: ElevatedButton(
                        child: Text("Taray??c??da A??"),
                        onPressed: () {
                          _launchIt(mapSoru_sik_gorsel);
                          Navigator.of(context, rootNavigator: true).pop('dialog');
                        }),
                  ),
                  SizedBox(width: 20,),
                  Visibility( visible: doc_sik == sik ? false : true,
                    child: GestureDetector(onDoubleTap: (){},
                      child: Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? false : true,
                        child: ElevatedButton(
                            child: Text("????aretle"),
                            onPressed: () async {

                               collectionReference.doc(id_solusturulan).collection("sorular")
                                  .doc(idSoru.toString()).collection("isaretleyenler").where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                                  .get().then((QuerySnapshot querySnapshot)=>{
                                querySnapshot.docs.forEach((doc) {

                                  if(doc["sik"] != sik) {
                                    AlertDialog alertDialog = new AlertDialog (
                                      title: Text("??nceden i??aretledi??iniz ${doc["sik"]} ????kk?? $sik ????kk?? ile de??i??tirilecektir. "),
                                      actions: [
                                        ElevatedButton(
                                          child: Text("Onayla"),
                                          onPressed: () async {
                                            Navigator.of(context, rootNavigator: true).pop("dialog");

                                            collectionReference.doc(id_solusturulan).collection("sorular")
                                                .doc(idSoru.toString()).collection("isaretleyenler").doc(doc.id.toString()).delete();

                                              collectionReference.doc(id_solusturulan).collection("sorular")
                                                .doc(idSoru.toString()).collection("${doc["sik"]}_isaretleyenler")
                                                .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                                                .get().then((QuerySnapshot querySnapshot)=>{
                                              querySnapshot.docs.forEach((_doc) {
                                                collectionReference.doc(id_solusturulan).collection("sorular")
                                                    .doc(idSoru.toString()).collection("${doc["sik"]}_isaretleyenler").doc(_doc.id.toString()).delete();
                                              })
                                            });

                                            if(doc["sik"] == mapSoru["dogru_sik"]){

                                               collectionReference.doc(id_solusturulan).collection("sorular")
                                                  .doc(idSoru.toString()).collection("dogruSik_isaretleyenler")
                                                  .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                                                  .get().then((QuerySnapshot querySnapshot)=>{
                                                querySnapshot.docs.forEach((_doc) {
                                                  collectionReference.doc(id_solusturulan).collection("sorular")
                                                      .doc(idSoru.toString()).collection("dogruSik_isaretleyenler").doc(_doc.id.toString()).delete();
                                                })
                                              });
                                            }

                                            Navigator.of(context, rootNavigator: true).pop("dialog");
                                            Navigator.of(context, rootNavigator: true).pop("dialog");

                                          },
                                        ),
                                      ],
                                    ); showDialog(context: context, builder: (_) => alertDialog);
                                  }
                                })
                              });

                                 await collectionReference.doc(id_solusturulan).collection("sorular")
                                     .doc(idSoru.toString()).collection("isaretleyenler")
                                     .add({"cevaplayan" : AtaWidget.of(context).kullaniciadi, "sik": sik, "tarih": DateTime.now().toString()});

                                 await collectionReference.doc(id_solusturulan).collection("sorular")
                                     .doc(idSoru.toString()).collection("${sik}_isaretleyenler")
                                     .add({"cevaplayan" : AtaWidget.of(context).kullaniciadi, "tarih": DateTime.now().toString()});

                                 if(sik == mapSoru["dogru_sik"]){
                                   await collectionReference.doc(id_solusturulan).collection("sorular")
                                       .doc(idSoru.toString()).collection("dogruSik_isaretleyenler")
                                       .add({"cevaplayan" : AtaWidget.of(context).kullaniciadi, "tarih": DateTime.now().toString(), "puan": mapSoru["puan"]});

                                 }


//                              setState(() {});
                              _scaffoldKey.currentState.showSnackBar(SnackBar(duration: Duration(seconds: 7),
                                content: Text(sik + ") ????kk??n?? i??aretlediniz."), action: SnackBarAction(label: "Gizle",
                                    onPressed: (){ SnackBarClosedReason.hide;}),));

                            }),
                      ),
                    ),
                  ),
                  Visibility( visible: doc_sik == sik ? true : false,
                    child: GestureDetector(onDoubleTap: (){},
                      child: ElevatedButton(
                          child: Text("????aret Kald??r"),
                          onPressed: () async {
                            print("????klar?? g??rden gelen doc_sik: " + doc_sik.toString());

                            collectionReference.doc(id_solusturulan).collection("sorular")
                                .doc(idSoru.toString()).collection("isaretleyenler").where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                                .get().then((QuerySnapshot querySnapshot)=>{
                              querySnapshot.docs.forEach((doc) {

                                  AlertDialog alertDialog = new AlertDialog (
                                    title: Text("????areti kald??rarak soruyu bo?? b??rakm???? olacaks??n??z. Bu i??lem g??nderilmi?? ????z??mleri etkilemez."),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Onayla"),
                                        onPressed: () async {
                                          Navigator.of(context, rootNavigator: true).pop("dialog");

                                          collectionReference.doc(id_solusturulan).collection("sorular")
                                              .doc(idSoru.toString()).collection("isaretleyenler").doc(doc.id.toString()).delete();

                                          collectionReference.doc(id_solusturulan).collection("sorular")
                                              .doc(idSoru.toString()).collection("${doc["sik"]}_isaretleyenler")
                                              .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                                              .get().then((QuerySnapshot querySnapshot)=>{
                                            querySnapshot.docs.forEach((_doc) {
                                              collectionReference.doc(id_solusturulan).collection("sorular")
                                                  .doc(idSoru.toString()).collection("${doc["sik"]}_isaretleyenler").doc(_doc.id.toString()).delete();
                                            })
                                          });

                                          if(doc["sik"] == mapSoru["dogru_sik"]){

                                            collectionReference.doc(id_solusturulan).collection("sorular")
                                                .doc(idSoru.toString()).collection("dogruSik_isaretleyenler")
                                                .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
                                                .get().then((QuerySnapshot querySnapshot)=>{
                                              querySnapshot.docs.forEach((_doc) {
                                                collectionReference.doc(id_solusturulan).collection("sorular")
                                                    .doc(idSoru.toString()).collection("dogruSik_isaretleyenler").doc(_doc.id.toString()).delete();
                                              })
                                            });
                                          }

                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          Navigator.of(context, rootNavigator: true).pop("dialog");

                                        },
                                      ),
                                    ],
                                  ); showDialog(context: context, builder: (_) => alertDialog);

                              })
                            });

//                            setState(() {});
                            _scaffoldKey.currentState.showSnackBar(SnackBar(duration: Duration(seconds: 7),
                              content: Text(sik + ") i??aretini kald??rd??n??z."), action: SnackBarAction(label: "Gizle",
                                  onPressed:()=> SnackBarClosedReason.hide ),));

                          }),
                    ),
                  ),
                ],
              ),
              Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                child: Wrap(
                  direction: Axis.horizontal, spacing: 4,
                  children: [
                    Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                      child: GestureDetector(onDoubleTap: (){},
                        child: ElevatedButton(
                            child: Text("????kk?? De??i??tir"),
                            onPressed: () async {
                              String url_sik;

                              AlertDialog alertDialog = new AlertDialog(
                                title: Text("$sik ????kk?? i??in giri?? y??ntemini se??iniz: "),
                                actions: [
                                  ElevatedButton(child: Text("Resim Se??"), onPressed: () async {
                                    Navigator.of(context, rootNavigator: true).pop("dialog");

                                    var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
//                                    setState(() {});

                                    Widget _uploadImageAlertDialog() {
                                      return Container(
                                        height: 500, width: 400,
                                        child: Column(children: [
                                          Flexible(
                                            child: Container(
                                                child: image == null
                                                    ? Center(
                                                    child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                                    ))
                                                    : Image.file(image, fit: BoxFit.contain,
                                                )),
                                          ),
                                          SizedBox(height: 20,),
                                          Text("**Sorunuzun $sik ????kk?? yukar??daki resim olacakt??r**",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                                            textAlign: TextAlign.center,
                                          ),
                                        ]),
                                      );
                                    }

                                    showDialog(context: context, builder: (_) {
                                      return AlertDialog(
                                        title: Text("$sik)", style: TextStyle(color: Colors.green),
                                        ),
                                        content: _uploadImageAlertDialog(),
                                        actions: [
                                          FloatingActionButton.extended(
                                            elevation: 0,
                                            icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                                            label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                                            backgroundColor: Colors.white,
                                            onPressed: ()  async {
                                              var _image = await cropImage(image);
                                              if(_image==null)
                                                return;
                                              image = _image;

                                              Navigator.of(context, rootNavigator: true).pop("dialog");

                                              showDialog(context: context, builder: (_) {
                                                return AlertDialog(
                                                  title: Text("$sik)", style: TextStyle(color: Colors.green),
                                                  ),
                                                  content: _uploadImageAlertDialog(),
                                                  actions: [

                                                    GestureDetector(onDoubleTap: (){},
                                                      child: ElevatedButton(
                                                          child: Text("$sik ????kk??n?? Onayla"),
                                                          onPressed: () async {
                                                            if (image == null) {
                                                              return null;
                                                            } else {
                                                              if(image != null ){
                                                                final Reference ref_sik = await FirebaseStorage.instance.ref().child("users")
                                                                    .child(AtaWidget.of(context).kullaniciadi)
                                                                    .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                                                                    .child(mapSoru["baslik"]).child("????klar").child("${sik}_????kk??");
                                                                await ref_sik.putFile(image);
                                                                var downloadUrl_sik = await ref_sik.getDownloadURL();
                                                                url_sik = downloadUrl_sik.toString();
                                                              } else {
                                                                url_sik = "";
                                                              }
                                                              await collectionReference.doc(id_solusturulan).collection("sorular").doc(idSoru.toString())
                                                                  .update({"${sik}_gorsel": url_sik});
//                                                    setState(() {});

                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??."),));
                                                              Navigator.of(context, rootNavigator: true).pop('dialog');
                                                              Navigator.of(context, rootNavigator: true).pop('dialog');
                                                              Navigator.of(context, rootNavigator: true).pop('dialog');

                                                            }
                                                          }),
                                                    ),
                                                  ],
                                                );
                                              });
                                            }
                                          ),

                                          GestureDetector(onDoubleTap: (){},
                                            child: ElevatedButton(
                                                child: Text("$sik ????kk??n?? Onayla"),
                                                onPressed: () async {
                                                  if (image == null) {
                                                    return null;
                                                  } else {
                                                    if(image != null ){
                                                      final Reference ref_sik = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                          .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                                                          .child(mapSoru["baslik"]).child("????klar").child("${sik}_????kk??");
                                                      await ref_sik.putFile(image);
                                                      var downloadUrl_sik = await ref_sik.getDownloadURL();
                                                      url_sik = downloadUrl_sik.toString();
                                                    } else {
                                                      url_sik = "";
                                                    }
                                                    await collectionReference.doc(id_solusturulan).collection("sorular").doc(idSoru.toString())
                                                        .update({"${sik}_gorsel": url_sik});
//                                                    setState(() {});

                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??."),));
                                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                                    Navigator.of(context, rootNavigator: true).pop('dialog');

                                                  }
                                                }),
                                          ),
                                        ],
                                      );
                                    });

                                  },),
                                  ElevatedButton(child: Text("Foto??raf ??ek"), onPressed: () async {
                                    Navigator.of(context, rootNavigator: true).pop("dialog");

                                    var image =  await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
//                                    setState(() {});

                                    Widget _uploadImageAlertDialog() {
                                      return Container(
                                        height: 500, width: 400,
                                        child: Column(children: [
                                          Flexible(
                                            child: Container(
                                                child: image == null
                                                    ? Center(
                                                    child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                                    ))
                                                    : Image.file(image, fit: BoxFit.contain,
                                                )),
                                          ),
                                          SizedBox(height: 20,),
                                          Text("**Sorunuzun ${sik} ????kk?? yukar??daki resim olacakt??r**",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                                            textAlign: TextAlign.center,
                                          ),
                                        ]),
                                      );
                                    }

                                    showDialog(context: context, builder: (_) {
                                      return AlertDialog(
                                        title: Text("$sik)", style: TextStyle(color: Colors.green),
                                        ),
                                        content: _uploadImageAlertDialog(),
                                        actions: [
                                          FloatingActionButton.extended(
                                              elevation: 0,
                                              icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                                              label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                                              backgroundColor: Colors.white,
                                              onPressed: ()  async {
                                                var _image = await cropImage(image);
                                                if(_image==null)
                                                  return;
                                                image = _image;

                                                Navigator.of(context, rootNavigator: true).pop("dialog");

                                                showDialog(context: context, builder: (_) {
                                                  return AlertDialog(
                                                    title: Text("$sik)", style: TextStyle(color: Colors.green),
                                                    ),
                                                    content: _uploadImageAlertDialog(),
                                                    actions: [

                                                      GestureDetector(onDoubleTap: (){},
                                                        child: ElevatedButton(
                                                            child: Text("$sik ????kk??n?? Onayla"),
                                                            onPressed: () async {
                                                              if (image == null) {
                                                                return null;
                                                              } else {
                                                                if(image != null ){
                                                                  final Reference ref_sik = await FirebaseStorage.instance.ref().child("users")
                                                                      .child(AtaWidget.of(context).kullaniciadi)
                                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                                                                      .child(mapSoru["baslik"]).child("????klar").child("${sik}_????kk??");
                                                                  await ref_sik.putFile(image);
                                                                  var downloadUrl_sik = await ref_sik.getDownloadURL();
                                                                  url_sik = downloadUrl_sik.toString();
                                                                } else {
                                                                  url_sik = "";
                                                                }
                                                                await collectionReference.doc(id_solusturulan).collection("sorular").doc(idSoru.toString())
                                                                    .update({"${sik}_gorsel": url_sik});
//                                                    setState(() {});

                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??."),));
                                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                Navigator.of(context, rootNavigator: true).pop('dialog');

                                                              }
                                                            }),
                                                      ),
                                                    ],
                                                  );
                                                });
                                              }
                                          ),

                                          GestureDetector(onDoubleTap: (){},
                                            child: ElevatedButton(
                                                child: Text("$sik ????kk??n?? Onayla"),
                                                onPressed: () async {
                                                  if (image == null) {
                                                    return null;
                                                  } else {
                                                    if(image != null ){
                                                      final Reference ref_sik = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                          .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                                                          .child(mapSoru["baslik"]).child("????klar").child("${sik}_????kk??");
                                                      await ref_sik.putFile(image);
                                                      var downloadUrl_sik = await ref_sik.getDownloadURL();
                                                      url_sik = downloadUrl_sik.toString();
                                                    } else {
                                                      url_sik = "";
                                                    }
                                                    await collectionReference.doc(id_solusturulan).collection("sorular").doc(idSoru.toString())
                                                        .update({"${sik}_gorsel": url_sik});
//                                                    setState(() {});

                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??."),));
                                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                                    Navigator.of(context, rootNavigator: true).pop('dialog');

                                                  }
                                                }),
                                          ),
                                        ],
                                      );
                                    });

                                  },),

                                  ElevatedButton(child: Text("Metin Gir"), onPressed: (){
                                    Navigator.of(context, rootNavigator: true).pop("dialog");

                                    AtaWidget.of(context).metinsel_sik = sik;

                                    Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "metinsel_sik",
                                      map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                                      storageReference: storageReference, mapSoru: mapSoru, idSoru: idSoru,) ));
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
/*
                                    TextEditingController _sik_sikki_metinci = TextEditingController();
                                    final _formKey = GlobalKey<FormState>();
                                    Widget _uploadTextNoteAlertDialog() {
                                      return Container(
                                        height: 300, width: 400,
                                        child: Column(children: [
                                          Form(key: _formKey,
                                              child: Flexible(
                                                child: ListView(children: [
                                                  SizedBox(height: 10,),
                                                  TextFormField(
                                                      maxLines: null,
                                                      keyboardType: TextInputType.multiline,
                                                      controller: _sik_sikki_metinci,
                                                      decoration: InputDecoration(
                                                          border: OutlineInputBorder(),
                                                          labelText: "????kk??n metnini yaz??n??z."),
                                                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                                      validator: (String PicName) {
                                                        if (PicName.isEmpty) {return "Alan bo?? b??rak??lamaz.";
                                                        } return null;
                                                      }),
                                                ]),
                                              )),
                                        ]),
                                      );
                                    }  showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title:
                                            Text("$sik)", style: TextStyle(color: Colors.orange),
                                            ),
                                            content: _uploadTextNoteAlertDialog(),
                                            actions: [
                                              GestureDetector(onDoubleTap: (){},
                                                child: ElevatedButton(
                                                  child: Text("${sik} ????kk??n?? onayla"),
                                                  onPressed: () async {
                                                    if (_formKey.currentState.validate()) {
                                                      _formKey.currentState.save();
                                                      try {
                                                        final Reference ref_sik = await FirebaseStorage.instance.ref().child("users")
                                                            .child(AtaWidget.of(context).kullaniciadi)
                                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                                                            .child(mapSoru["baslik"]).child("????klar").child("${sik}_????kk??");
                                                        await ref_sik.delete();

                                                      } catch (e) { print(e.toString()); }

                                                      final sik_sikki_metin = _sik_sikki_metinci.text.trim().toLowerCase();
                                                      await collectionReference.doc(id_solusturulan).collection("sorular").doc(idSoru.toString())
                                                          .update({"${sik}_gorsel": "", "${sik}_metinsel": sik_sikki_metin,});
//                                                      setState(() {});

                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??."),));
                                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        });
*/
                                  },),
                                ],
                              );showDialog(context: context, builder: (_) => alertDialog );

                            }),
                      ),
                    ),
                    Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
                      child: GestureDetector(onDoubleTap: (){},
                        child: ElevatedButton(
                            child: Text("Do??ru Olarak Se??"),
                            onPressed: () async {
                              await collectionReference.doc(id_solusturulan).collection("sorular").doc(idSoru.toString()).update({"dogru_sik": sik});
                              _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("????lem ba??ar??l??."),));
                              Navigator.of(context, rootNavigator: true).pop('dialog');
                              Navigator.of(context, rootNavigator: true).pop('dialog');
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

  void _soruMetniGir() {
    TextEditingController _controller = TextEditingController();
    TextEditingController _soru_metinci = TextEditingController();
    TextEditingController _puanci = TextEditingController();

    baslik = AtaWidget.of(context).formHelper_metinselSoru_baslik;
    soru_metni = AtaWidget.of(context).formHelper_metinselSoru_soruMetni;
    puan = AtaWidget.of(context).formHelper_metinselSoru_puan;

    if(baslik == null){
      Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "metinsel_soru",
        map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
        storageReference: storageReference, mapSoru: null, idSoru: null,) ));
    } else {

      final _formKey = GlobalKey<FormState>();
      Widget _uploadTextNoteAlertDialog() {
        return Container(
          height: 300, width: 400,
          child: Column(children: [
            Form(key: _formKey,
                child: Flexible(
                  child: ListView(children: [
                    Visibility( visible: soru_testmi == true ? true : false,
                      child: Text("??oktan se??meli bir test sorusu y??klemeyi tercih ettiniz. Bu sebeple se??ili sorunuz i??in 4 tane ????k girmeniz gerekmektedir. ????klar?? "
                          "telefonunuzun galerisinden resim se??erek, kameras??ndan foto??raf ??ekerek yada metin yazarak girebilirsiniz. Buradan ekleyece??inizi t??m ????klar"
                          " sadece g??rsel yada sadece metinsel olmal??d??r. Ayn?? soru i??in hem g??rsel ????k hem metinsel ????kk?? buradan ekleyemezsiniz. "
                          "Her bir g??rsel y??klemenizde i??lem "
                          "h??z??n??n internet h??z??n??za ve y??kleyece??iniz g??rsellerin boyutuna ba??l?? oldu??unu unutmay??n??z. ????klardan birini do??ru ????k olarak belirlemelisiniz. "
                          "Aksi takdirde soru y??kleme i??leminin sonunda do??ru cevap belirlemedi??inize dair uyar?? alacak ve i??lemi tekrarlamak durumunda kalacaks??n??z. "
                          "????lemin tamamlanmas??n??n ard??ndan s??nav sayfas??nda soruya uzun basarak ????z??m ekleyebilirsiniz.",
                        style: TextStyle( fontStyle: FontStyle.italic, fontSize: 12), textAlign: TextAlign.justify,),
                    ),
                    Visibility( visible: soru_testmi == false ? true : false,
                      child: Text("????lemin tamamlanmas??n??n ard??ndan s??nav sayfas??nda soruya uzun basarak ????z??m ekleyebilirsiniz.",
                        style: TextStyle( fontStyle: FontStyle.italic, fontSize: 12), textAlign: TextAlign.justify,),
                    ),
                    SizedBox(height: 10,),
                    ListTile(
                        title: Text("Ba??l??k:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        subtitle: baslik == null ?
                        Text("Sorunun ba??l??????n?? giriniz.", style: TextStyle(fontStyle: FontStyle.italic),)
                        : Text(baslik, style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    ListTile(
                      title: Text("Soru Metni:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                      subtitle: soru_metni == null ?
                      Text("Sorunun metnini giriniz.", style: TextStyle(fontStyle: FontStyle.italic),)
                          : Text(soru_metni, style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    ListTile(
                      title: Text("Puan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                      subtitle: puan == null ?
                      Text("Sorunun puan??n?? giriniz.", style: TextStyle(fontStyle: FontStyle.italic),)
                          : Text(puan, style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
/*                  TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _controller,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Sorunuz i??in ba??l??k giriniz"),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "ba??l??k girmeniz gerekmektedir.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _soru_metinci,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Soru metninizi yaz??n??z."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "Alan bo?? b??rak??lamaz.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: _puanci,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Sorunun puan??n?? giriniz.",),
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                    validator: (String value){
                      if(value.isEmpty){ return "puan girmeniz gerekmektedir." ;}
                      return null;
                    },
                  ),
*/                  SizedBox(height: 10,),
                    Text(soru_testmi == true ? "Sorunuzuzu ??oktan se??meli olarak belirlediniz.": "Sorunuzu ??oktan se??meli de??il olarak belirlediniz." ,
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),),
                  ]),
                )),
          ]),
        );
      }  showDialog(context: context, builder: (_) {
            return AlertDialog( scrollable: true,
              title: Text("Soru Ekleme ", style: TextStyle(color: Colors.orange),
              ),
              content: _uploadTextNoteAlertDialog(),
              actions: [
                ElevatedButton(
                  child: Text("Vazge??"),
                  onPressed: (){
                    soru_testmi = false; dogru_sik = ""; soru_metni = "";
                    a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; baslik = ""; _puan = -1; puan = "";
                    soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                    a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;

                    AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                    AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                    AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                    AtaWidget.of(context).metinsel_sik = null;
                    AtaWidget.of(context).metinsel_sik_a = null;
                    AtaWidget.of(context).metinsel_sik_b = null;
                    AtaWidget.of(context).metinsel_sik_c = null;
                    AtaWidget.of(context).metinsel_sik_d = null;
                    AtaWidget.of(context).metinsel_soru_bitti = false;
                    AtaWidget.of(context).a_sikki_bitti = false;
                    AtaWidget.of(context).b_sikki_bitti = false;
                    AtaWidget.of(context).c_sikki_bitti = false;
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                        OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                            collectionReference: collectionReference, storageReference: storageReference)));
                  },
                ),
                GestureDetector(onDoubleTap: (){},
                  child: ElevatedButton(
                    child: Text(soru_testmi == true ? "????klar?? Olu??tur": "Soruyu Y??kle"),
                    onPressed: () async {
//                      if (_formKey.currentState.validate()) {_formKey.currentState.save();
                        _puan = int.parse(puan);
                        Navigator.of(context, rootNavigator: true).pop('dialog');

                        if(soru_testmi == true){
                          soru_bitti = true;

                          AlertDialog alertDialog = new AlertDialog (
                            title: Text("Sonradan ekledi??iniz test sorular??nda ????klar??n t??m??n??n sadece g??rsel yada sadece metinsel olabilece??ini unutmay??n??z."),
                            actions: [
                              ElevatedButton(
                                child: Text("Anlad??m"),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop("dialog");
                                  soru_siklariOlustur();
                                },
                              ),
                            ],
                          ); showDialog(context: context, builder: (_) => alertDialog);

                        } else {

                          var subCol_newDoc =  await await collectionReference.doc(id_solusturulan).collection("sorular")
                              .add({"gorsel_soru": "", "baslik": baslik, "gorsel_cevap": "", "metinsel_cevap": "", "metinsel_soru": soru_metni,
                            "soru_testmi": soru_testmi, "tarih": DateTime.now().toString(), "puan": _puan});

                          id_subCol_newDoc = await subCol_newDoc.id;
                          collectionReference_solusturulan_soruyuCevaplayanlar = await collectionReference.doc(id_solusturulan).collection("sorular")
                              .doc(id_subCol_newDoc).collection("soruyu_cevaplayanlar");

                          AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                          AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                          AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                          soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                          baslik = ""; soru_metni = ""; soru_testmi = false; _puan = -1; puan = "";
//                        setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sorunuz ba??ar??yla eklendi"),
                            action: SnackBarAction(label: "Gizle", onPressed: (){
                              SnackBarClosedReason.hide;
                            },),));
                        }

//                      }
                    },
                  ),
                ),
              ],
            );
          });
    }



  }

  void _soruYukle() async {
    bool croped = false;

    TextEditingController _controller = TextEditingController();
    TextEditingController _puanci = TextEditingController();

    baslik = AtaWidget.of(context).formHelper_gorselSoru_baslik;
    puan = AtaWidget.of(context).formHelper_gorselSoru_puan;

    if(baslik == null){
      Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "gorsel_soru",
        map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
        storageReference: storageReference, mapSoru: null, idSoru: null,) ));
    }
    else {
      if (kameradan_resim == true) {
        var image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
        if(image != null){
          _soruSelected = image;
        } else { return null; }
      } else {
        var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
        if(image != null){
          _soruSelected = image;
        } else { return null; }
      }

      Widget _uploadImageAlertDialog() {
        return Container(height: 500, width: 400,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
                children: [
                  Align( alignment: Alignment.centerLeft,
                    child: MaterialButton(
                        child: Text("Bilgilendirme i??in Buraya t??klay??n??z.", style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold)),
                        onPressed: (){
                          AlertDialog alertDialog = new AlertDialog(
                            title: Text("Bilgilendirme"),
                            content: Text( soru_testmi != true ?
                            "Soruyu k??rpmak yada y??klemek i??in ??nce ba??l??k ve puan girmelisiniz. Y??kleme s??resi g??rselin boyutuna ve internet h??z??n??za ba??l??d??r. "
                                "Y??ksek boyutlu g??rsellerin y??klenmesinde s??re uzayabilir. "
                                "Y??kleme tamamland??????nda ba??ar??l??d??r mesaj?? ""alacaks??n??z. ????lemin tamamlanmas??n??n ard??ndan s??nav sayfas??nda soruya uzun "
                                "t??klayarak ????z??m ekleyebilirsiniz." :
                            "Soruyu k??rpmak yada y??klemek i??in ??nce ba??l??k ve puan girmelisiniz. ??oktan se??meli bir test sorusu y??klemeyi tercih ettiniz. "
                                "Bu sebeple se??ili sorunuz i??in 4 tane ????k girmeniz gerekmektedir. "
                                "????klar?? telefonunuzdan resim se??erek, kameras??ndan foto??raf ??ekerek yada metin yazarak girebilirsiniz. Her bir g??rsel "
                                "y??klemenizde i??lem h??z??n??n internet h??z??n??za ve y??kleyece??iniz g??rsellerin boyutuna ba??l?? oldu??unu unutmay??n??z. ????klardan birini "
                                "do??ru ????k olarak belirlemelisiniz. Aksi takdirde soru y??kleme i??leminin sonunda do??ru cevap belirlemedi??inize dair uyar?? alacak "
                                "ve i??lemi tekrarlamak durumunda kalacaks??n??z. ????lemin tamamlanmas??n??n ard??ndan s??nav sayfas??nda soruya uzun t??klayarak ????z??m "
                                "ekleyebilirsiniz.",
                              style: TextStyle( fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          );
                          showDialog(context: context, builder: (_) => alertDialog);
                        }),
                  ),
                  SizedBox(height: 10,),
                  ListTile(
                    title: Text("Ba??l??k:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    subtitle: baslik == null ?
                    Text("Sorunun ba??l??????n?? giriniz.", style: TextStyle(fontStyle: FontStyle.italic),)
                        : Text(baslik, style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    title: Text("Puan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    subtitle: puan == null ?
                    Text("Sorunun puan??n?? giriniz.", style: TextStyle(fontStyle: FontStyle.italic),)
                        : Text(puan, style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
/*
                  Form(
                      key: _formKey_gorselSoru,
                      child: Column(
                        children: [
                          TextFormField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: _controller,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Sorunuz i??in ba??l??k giriniz"),
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                              validator: (String PicName) {
                                if (PicName.isEmpty) {return "ba??l??k girmeniz gerekmektedir.";
                                } return null;
                              }),
                          SizedBox(height: 10,),
                          TextFormField(
                            controller: _puanci,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Sorunun puan??n?? rakamla giriniz.",),
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String value){
                              if(value.isEmpty){ return "puan girmeniz gerekmektedir." ;}
                              return null;
                            },
                          ),
                        ],
                      )
                  ),
*/
                  SizedBox(height: 20,),
                  Container(
                      child: _soruSelected == null ? Center(
                          child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ))
                          : Image.file(_soruSelected, fit: BoxFit.contain,)),
                  SizedBox(height: 15,),
                  Text(soru_testmi == true ? "Sorunuzuzu ??oktan se??meli olarak belirlediniz." : "Sorunuzu ??oktan se??meli de??il olarak belirlediniz." ,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),),

                ]
            ),
          ),

        );
      }

      Widget _uploadImageAlertDialog_croped() {
        return Container(height: 500, width: 400,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
                children: [
                  ListTile(
                    title: Text("Ba??l??k:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    subtitle: baslik == null ?
                    Text("Sorunun ba??l??????n?? giriniz.", style: TextStyle(fontStyle: FontStyle.italic),)
                        : Text(baslik, style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    title: Text("Puan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    subtitle: puan == null ?
                    Text("Sorunun puan??n?? giriniz.", style: TextStyle(fontStyle: FontStyle.italic),)
                        : Text(puan, style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 20,),
                  Container(
                      child: _soruSelected == null ? Center(
                          child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ))
                          : Image.file(_soruSelected, fit: BoxFit.contain,)),
                  SizedBox(height: 15,),
                  Text(soru_testmi == true ? "Sorunuzuzu ??oktan se??meli olarak belirlediniz." : "Sorunuzu ??oktan se??meli de??il olarak belirlediniz." ,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),),

                ]
            ),
          ),

        );
      }

      showDialog(context: context, barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: Text("Soru Ekleme", style: TextStyle(color: Colors.green),),
              content: _uploadImageAlertDialog(),
              actions: [
                ElevatedButton(
                  child: Text("Vazge??"),
                  onPressed: (){
                    soru_testmi = false; dogru_sik = ""; soru_metni = "";
                    a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; baslik = ""; _puan = -1; puan = "";
                    soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                    a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;

                    AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                    AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                    AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                    AtaWidget.of(context).metinsel_sik = null;
                    AtaWidget.of(context).metinsel_sik_a = null;
                    AtaWidget.of(context).metinsel_sik_b = null;
                    AtaWidget.of(context).metinsel_sik_c = null;
                    AtaWidget.of(context).metinsel_sik_d = null;
                    AtaWidget.of(context).metinsel_soru_bitti = false;
                    AtaWidget.of(context).a_sikki_bitti = false;
                    AtaWidget.of(context).b_sikki_bitti = false;
                    AtaWidget.of(context).c_sikki_bitti = false;
                    AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
                    AtaWidget.of(context).formHelper_gorselSoru_puan = null;

                    Navigator.of(context, rootNavigator: true).pop("dialog");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                        OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                            collectionReference: collectionReference, storageReference: storageReference)));
                  },
                ),
                Wrap( direction: Axis.horizontal, spacing: 100,
                  children: [
                    Container( height: 50, width: 80,
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                            elevation: 0,
                            icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                            label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                            backgroundColor: Colors.white,
                            onPressed: () async {
/*                              if (_formKey_gorselSoru.currentState.validate()) {
                                _formKey_gorselSoru.currentState.save();
                                baslik = _controller.text;
                                puan = _puanci.text.trim();
*/
                                _puan = int.parse(puan);

                                if(_soruSelected == null) return;
                                var image = await cropImage(_soruSelected);
                                if(image==null)
                                  return;
                                _soruSelected = image;
                                croped = true;
                                Navigator.of(context, rootNavigator: true).pop("dialog");

                                showDialog(context: context, builder: (_) => AlertDialog(
                                  title: Text("Soru Ekleme: ", style: TextStyle(color: Colors.green),),
                                  content: _uploadImageAlertDialog_croped(),
                                  actions: [
                                    GestureDetector(onDoubleTap: (){},
                                      child: ElevatedButton(
                                        child: Text(soru_testmi == true ? "????klar?? Olu??tur": "Soruyu Y??kle"),
                                        onPressed: () async {

                                          Navigator.of(context, rootNavigator: true).pop('dialog');

                                          if(soru_testmi == true){
                                            soru_bitti = true;

                                            AlertDialog alertDialog = new AlertDialog (
                                              title: Text("Sonradan ekledi??iniz test sorular??nda ????klar??n t??m??n??n sadece g??rsel yada sadece metinsel"
                                                  " olabilece??ini unutmay??n??z."),
                                              actions: [
                                                ElevatedButton(
                                                  child: Text("Anlad??m"),
                                                  onPressed: () {
                                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                                    soru_siklariOlustur();
                                                  },
                                                ),
                                              ],
                                            ); showDialog(context: context, builder: (_) => alertDialog);
                                          }
                                          else {
                                            final Reference ref = await FirebaseStorage.instance.ref().child("users")
                                                .child(AtaWidget.of(context).kullaniciadi).child("sinavlar").child("olusturulan_sinavlar")
                                                .child(map_solusturulan["baslik"]).child("sorular").child(baslik).child(baslik);
                                            await ref.putFile(_soruSelected);
                                            var downloadUrl = await ref.getDownloadURL();
                                            String url = downloadUrl.toString();

                                            var subCol_newDoc =  await collectionReference.doc(id_solusturulan).collection("sorular")
                                                .add({"gorsel_soru": url, "baslik": baslik, "gorsel_cevap": "", "metinsel_cevap": "",
                                              "metinsel_soru": "", "soru_testmi": soru_testmi, "tarih": DateTime.now(), "puan": _puan,});

                                            url = ""; baslik = ""; soru_testmi = false; _puan = -1; puan = "";

                                            id_subCol_newDoc = await subCol_newDoc.id;
                                            AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
                                            AtaWidget.of(context).formHelper_gorselSoru_puan = null;
                                            soru_testmi = false; dogru_sik = ""; soru_metni = "";
                                            a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; baslik = ""; _puan = -1; puan = "";
                                            soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                                            a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;

                                            AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                                            AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                                            AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                                            AtaWidget.of(context).metinsel_sik = null;
                                            AtaWidget.of(context).metinsel_sik_a = null;
                                            AtaWidget.of(context).metinsel_sik_b = null;
                                            AtaWidget.of(context).metinsel_sik_c = null;
                                            AtaWidget.of(context).metinsel_sik_d = null;
                                            AtaWidget.of(context).metinsel_soru_bitti = false;
                                            AtaWidget.of(context).a_sikki_bitti = false;
                                            AtaWidget.of(context).b_sikki_bitti = false;
                                            AtaWidget.of(context).c_sikki_bitti = false;
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Soru ba??ar??yla eklendi."),
                                              action: SnackBarAction(label: "Gizle", onPressed: (){
                                                SnackBarClosedReason.hide;
                                              },),));
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ));

//                              }
                            }
                        ),
                      ),
                    ),
                    GestureDetector(onDoubleTap: (){},
                      child: ElevatedButton(
                        child: Text(soru_testmi == true ? "????klar?? Olu??tur": "Soruyu Y??kle"),
                        onPressed: () async {
/*                          if (_formKey_gorselSoru.currentState.validate()) {
                            _formKey_gorselSoru.currentState.save();
                            baslik = _controller.text;
                            puan = _puanci.text.trim();
*/

                            _puan = int.parse(puan);

                            Navigator.of(context, rootNavigator: true).pop('dialog');
                            if(soru_testmi == true){
                              soru_bitti = true;

                              AlertDialog alertDialog = new AlertDialog (
                                title: Text("Sonradan ekledi??iniz test sorular??nda ????klar??n t??m??n??n sadece g??rsel yada sadece metinsel olabilece??ini unutmay??n??z."),
                                actions: [
                                  ElevatedButton(
                                    child: Text("Anlad??m"),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true).pop("dialog");
                                      soru_siklariOlustur();
                                    },
                                  ),
                                ],
                              ); showDialog(context: context, builder: (_) => alertDialog);
                            }
                            else {
                              final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                  .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                                  .child(baslik).child(baslik);
                              await ref.putFile(_soruSelected);
                              var downloadUrl = await ref.getDownloadURL();
                              String url = downloadUrl.toString();

                              var subCol_newDoc =  await collectionReference.doc(id_solusturulan).collection("sorular")
                                  .add({"gorsel_soru": url, "baslik": baslik, "gorsel_cevap": "", "metinsel_cevap": "", "metinsel_soru": "",
                                "soru_testmi": soru_testmi, "tarih": DateTime.now(), "puan": _puan,});

                              url = ""; baslik = ""; soru_testmi = false; _puan = -1; puan = "";

                              id_subCol_newDoc = await subCol_newDoc.id;
                              soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;

                              soru_testmi = false; dogru_sik = ""; soru_metni = "";
                              a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; baslik = ""; _puan = -1; puan = "";
                              soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                              a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;

                              AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                              AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                              AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                              AtaWidget.of(context).metinsel_sik = null;
                              AtaWidget.of(context).metinsel_sik_a = null;
                              AtaWidget.of(context).metinsel_sik_b = null;
                              AtaWidget.of(context).metinsel_sik_c = null;
                              AtaWidget.of(context).metinsel_sik_d = null;
                              AtaWidget.of(context).metinsel_soru_bitti = false;
                              AtaWidget.of(context).a_sikki_bitti = false;
                              AtaWidget.of(context).b_sikki_bitti = false;
                              AtaWidget.of(context).c_sikki_bitti = false;
                              AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
                              AtaWidget.of(context).formHelper_gorselSoru_puan = null;
//                        setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Soru ba??ar??yla eklendi."),));
                            }
//                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          });
    }

  }

  void soru_siklariOlustur() async {

    AlertDialog alertDialog = new AlertDialog(
      title: Text("A ????kk?? i??in giri?? y??ntemini se??iniz: "),
      actions: [
        ElevatedButton(
          child: Text("Vazge??"),
          onPressed: (){
            soru_testmi = false; dogru_sik = ""; soru_metni = "";
            a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; baslik = ""; _puan = -1; puan = "";
            soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
            a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;

            AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
            AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
            AtaWidget.of(context).formHelper_metinselSoru_puan = null;
            AtaWidget.of(context).metinsel_sik = null;
            AtaWidget.of(context).metinsel_sik_a = null;
            AtaWidget.of(context).metinsel_sik_b = null;
            AtaWidget.of(context).metinsel_sik_c = null;
            AtaWidget.of(context).metinsel_sik_d = null;
            AtaWidget.of(context).metinsel_soru_bitti = false;
            AtaWidget.of(context).a_sikki_bitti = false;
            AtaWidget.of(context).b_sikki_bitti = false;
            AtaWidget.of(context).c_sikki_bitti = false;
            AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
            AtaWidget.of(context).formHelper_gorselSoru_puan = null;
            Navigator.of(context, rootNavigator: true).pop("dialog");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                    collectionReference: collectionReference, storageReference: storageReference)));
          },
        ),
        Wrap ( direction: Axis.horizontal, spacing: 4,
          children: [
            Visibility( visible: AtaWidget.of(context).metinsel_sik_a != null ? false : true,
              child: ElevatedButton(child: Text("Resim Se??"), onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop("dialog");
                var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                a_sikki_gorsel = image;

/*            a_sikki_gorsel = AtaWidget.of(context).a_sikki_gorsel;

            if(a_sikki_gorsel == null){
              var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);

              Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: image, islem: "a_sikki_gorsel",
                map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                storageReference: storageReference, mapSoru: null, idSoru: null,) ));
            }
            else {
*/              Widget _uploadImageAlertDialog() {
                  return Container(
                    height: 500, width: 400,
                    child: Column(children: [
                      Flexible(
                        child: Container(
                            child: a_sikki_gorsel == null
                                ? Center(
                                child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ))
                                : Image.file(a_sikki_gorsel, fit: BoxFit.contain,
                            )),
                      ),
                      SizedBox(height: 20,),
                      Text("**Sorunuzun A ????kk?? yukar??daki resim olacakt??r**",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                    ]),
                  );
                }

                showDialog(context: context, builder: (_) {
                  return AlertDialog(
                    title: Text("A)", style: TextStyle(color: Colors.green),
                    ),
                    content: _uploadImageAlertDialog(),
                    actions: [
                      Center(
                        child: MaterialButton(
                            child: Text("A ????kk??n?? do??ru cevap olarak belirle",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                              textAlign: TextAlign.end,
                            ),
                            onPressed: (){
                              dogru_sik = "A";

//                        setState(() {});
                            }),
                      ),
                      Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        Container( height: 50, width: 80,
                          child: FittedBox(
                            child: FloatingActionButton.extended(
                              elevation: 0,
                              icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                              label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                              backgroundColor: Colors.white,
                              onPressed: () async {
                                if(a_sikki_gorsel == null) return;
                                var image = await cropImage(a_sikki_gorsel);
                                if(image==null)
                                  return;
                                a_sikki_gorsel = image;

                                Navigator.of(context, rootNavigator: true).pop("dialog");

                                showDialog(context: context, builder: (_) {
                                  return AlertDialog(
                                    title: Text("A)", style: TextStyle(color: Colors.green),
                                    ),
                                    content: _uploadImageAlertDialog(),
                                    actions: [
                                      Center(
                                        child: MaterialButton(
                                            child: Text("A ????kk??n?? do??ru cevap olarak belirle",
                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                              textAlign: TextAlign.end,
                                            ),
                                            onPressed: (){
                                              dogru_sik = "A";

//                        setState(() {});
                                            }),
                                      ),
                                      GestureDetector(onDoubleTap: (){},
                                        child: ElevatedButton(
                                            child: Text("A ????kk??n?? Onayla ve B ????kk??na ge??"),
                                            onPressed: () async {
                                              if (a_sikki_gorsel == null) {
                                                return null;
                                              } else {
                                                soru_bitti == false;
                                                a_sikki_bitti = true;

//                            setState(() {});
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),
                                                  action: SnackBarAction(label: "Gizle", onPressed: (){
                                                    SnackBarClosedReason.hide;
                                                  },),));
                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                                b_sikkinaGec();

                                              }
                                            }),
                                      ),

                                    ],
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                        GestureDetector(onDoubleTap: (){},
                          child: Container( height: 50, width: 180,
                            child: FittedBox(
                              child: ElevatedButton(
                                  child: Text("A ????kk??n?? Onayla ve B ????kk??na ge??"),
                                  onPressed: () async {
                                    if (a_sikki_gorsel == null) {
                                      return null;
                                    } else {
                                      soru_bitti == false;
                                      a_sikki_bitti = true;

//                            setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),));
                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                      b_sikkinaGec();

                                    }
                                  }),
                            ),
                          ),
                        ),
                      ],),
                    ],
                  );
                });
//            }
              },),
            ),
            Visibility( visible: AtaWidget.of(context).metinsel_sik_a != null ? false : true,
              child: ElevatedButton(child: Text("Foto??raf ??ek"), onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop("dialog");
                var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                a_sikki_gorsel = image;

                Widget _uploadImageAlertDialog() {
                  return Container(
                    height: 500, width: 400,
                    child: Column(children: [
                      Flexible(
                        child: Container(
                            child: a_sikki_gorsel == null
                                ? Center(
                                child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ))
                                : Image.file(a_sikki_gorsel, fit: BoxFit.contain,
                            )),
                      ),
                      SizedBox(height: 20,),
                      Text("**Sorunuzun A ????kk?? yukar??daki resim olacakt??r**",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                    ]),
                  );
                }

                showDialog(context: context, builder: (_) {
                  return AlertDialog(
                    title: Text("A)", style: TextStyle(color: Colors.green),
                    ),
                    content: _uploadImageAlertDialog(),
                    actions: [
                      Center(
                        child: MaterialButton(
                            child: Text("A ????kk??n?? do??ru cevap olarak belirle",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                              textAlign: TextAlign.end,
                            ),
                            onPressed: (){
                              dogru_sik = "A";

//                        setState(() {});
                            }),
                      ),
                      Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        Container( height: 50, width: 80,
                          child: FittedBox(
                            child: FloatingActionButton.extended(
                              elevation: 0,
                              icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                              label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                              backgroundColor: Colors.white,
                              onPressed: () async {
                                if(a_sikki_gorsel == null) return;
                                var image = await cropImage(a_sikki_gorsel);
                                if(image==null)
                                  return;
                                a_sikki_gorsel = image;

                                Navigator.of(context, rootNavigator: true).pop("dialog");

                                showDialog(context: context, builder: (_) {
                                  return AlertDialog(
                                    title: Text("A)", style: TextStyle(color: Colors.green),
                                    ),
                                    content: _uploadImageAlertDialog(),
                                    actions: [
                                      Center(
                                        child: MaterialButton(
                                            child: Text("A ????kk??n?? do??ru cevap olarak belirle",
                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                              textAlign: TextAlign.end,
                                            ),
                                            onPressed: (){
                                              dogru_sik = "A";

//                        setState(() {});
                                            }),
                                      ),
                                      GestureDetector(onDoubleTap: (){},
                                        child: ElevatedButton(
                                            child: Text("A ????kk??n?? Onayla ve B ????kk??na ge??"),
                                            onPressed: () async {
                                              if (a_sikki_gorsel == null) {
                                                return null;
                                              } else {
                                                soru_bitti == false;
                                                a_sikki_bitti = true;

//                            setState(() {});
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),));
                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                                b_sikkinaGec();

                                              }
                                            }),
                                      ),

                                    ],
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                        GestureDetector(onDoubleTap: (){},
                          child: Container( height: 50, width: 180,
                            child: FittedBox(
                              child: ElevatedButton(
                                  child: Text("A ????kk??n?? Onayla ve B ????kk??na ge??"),
                                  onPressed: () async {
                                    if (a_sikki_gorsel == null) {
                                      return null;
                                    } else {
                                      soru_bitti == false;
                                      a_sikki_bitti = true;

//                            setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),
                                        action: SnackBarAction(label: "Gizle", onPressed: (){
                                          SnackBarClosedReason.hide;
                                        },),));
                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                      b_sikkinaGec();

                                    }
                                  }),
                            ),
                          ),
                        ),
                      ],),
                    ],
                  );
                });

              },),
            ),
            ElevatedButton(child: Text( AtaWidget.of(context).metinsel_sik_a != null ? "A ????kk??n?? G??r" : "Metin Gir"), onPressed: (){
              Navigator.of(context, rootNavigator: true).pop("dialog");
              a_sikki_metin = AtaWidget.of(context).metinsel_sik_a;

              if(a_sikki_metin == null){
                Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "metinsel_sik_a",
                  map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                  storageReference: storageReference, mapSoru: null, idSoru: null,) ));
              } else {

                TextEditingController _a_sikki_metinci = TextEditingController();
                final _formKey = GlobalKey<FormState>();
                Widget _uploadTextNoteAlertDialog() {
                  return Container(
                    height: 300, width: 400,
                    child: ListView(children: [
                      ListTile(
                          title: Text("Formdan Girilen Bilgi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                          subtitle: a_sikki_metin == null
                              ? Text( "Herhangi bir bilgi giri??i yap??lmad??", style: TextStyle(fontStyle: FontStyle.italic),)
                              : Text(a_sikki_metin, style: TextStyle(fontWeight: FontWeight.bold),)
                      ),
/*
                Form(key: _formKey,
                    child: Flexible(
                      child: ListView(children: [
                        SizedBox(height: 10,),
                        TextFormField(
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            controller: _a_sikki_metinci,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "????kk??n metnini yaz??n??z."),
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {return "Alan bo?? b??rak??lamaz.";
                              } return null;
                            }),
                      ]),
                    )),
*/
                    ]),
                  );
                }  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title:
                        Text("A)", style: TextStyle(color: Colors.orange),
                        ),
                        content: _uploadTextNoteAlertDialog(),
                        actions: [
                          Wrap(direction: Axis.vertical, spacing: 2, children: [
                            MaterialButton(
                                child: Text("A ????kk??n?? do??ru cevap olarak belirle",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                  textAlign: TextAlign.end,
                                ),
                                onPressed: (){
                                  dogru_sik = "A";

//                            setState(() {});
                                }),
                            GestureDetector(onDoubleTap: (){},
                              child: ElevatedButton(
                                  child: Text("A ????kk??n?? onayla ve B ????kk??na ge??"),
                                  onPressed: () async {
/*                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              a_sikki_metin = _a_sikki_metinci.text.trim().toLowerCase();
*/
                                    soru_bitti = false;
                                    a_sikki_bitti = true;

//                              setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),
                                      action: SnackBarAction(label: "Gizle", onPressed: (){
                                        SnackBarClosedReason.hide;
                                      },),));
                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                    b_sikkinaGec();
                                  }
//                          },
                              ),
                            ),
                          ],),
                        ],
                      );
                    });

              }

            },),
          ],
        ),

      ],
    );showDialog( barrierDismissible: false,
        context: context, builder: (_) => alertDialog );
  }

  void b_sikkinaGec()async {

    AlertDialog alertDialog = new AlertDialog(
      title: Text("B ????kk?? i??in giri?? y??ntemini se??iniz: "),
      actions: [
        ElevatedButton(
          child: Text("Vazge??"),
          onPressed: (){
            soru_testmi = false; dogru_sik = ""; soru_metni = "";
            a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; baslik = ""; _puan = -1; puan = "";
            soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
            a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;

            AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
            AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
            AtaWidget.of(context).formHelper_metinselSoru_puan = null;
            AtaWidget.of(context).metinsel_sik = null;
            AtaWidget.of(context).metinsel_sik_a = null;
            AtaWidget.of(context).metinsel_sik_b = null;
            AtaWidget.of(context).metinsel_sik_c = null;
            AtaWidget.of(context).metinsel_sik_d = null;
            AtaWidget.of(context).metinsel_soru_bitti = false;
            AtaWidget.of(context).a_sikki_bitti = false;
            AtaWidget.of(context).b_sikki_bitti = false;
            AtaWidget.of(context).c_sikki_bitti = false;
            AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
            AtaWidget.of(context).formHelper_gorselSoru_puan = null;
            Navigator.of(context, rootNavigator: true).pop("dialog");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                    collectionReference: collectionReference, storageReference: storageReference)));
          },
        ),
        Visibility( visible: AtaWidget.of(context).metinsel_sik_b != null || a_sikki_gorsel == null ? false : true,
          child: ElevatedButton(child: Text("Resim Se??"), onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");
            var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
            b_sikki_gorsel = image;

              Widget _uploadImageAlertDialog() {
                return Container(
                  height: 500, width: 400,
                  child: Column(children: [
                    Flexible(
                      child: Container(
                          child: b_sikki_gorsel == null
                              ? Center(
                              child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ))
                              : Image.file(b_sikki_gorsel, fit: BoxFit.contain,
                          )),
                    ),
                    SizedBox(height: 20,),
                    Text("**Sorunuzun B ????kk?? yukar??daki resim olacakt??r**",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                );
              }

              showDialog(context: context, builder: (_) {
                return AlertDialog(
                  title: Text("B)", style: TextStyle(color: Colors.green),
                  ),
                  content: _uploadImageAlertDialog(),
                  actions: [
                    Center(
                      child: MaterialButton(
                          child: Text("B ????kk??n?? do??ru cevap olarak belirle",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                            textAlign: TextAlign.end,
                          ),
                          onPressed: (){
                            dogru_sik = "B";

//                        setState(() {});
                          }),
                    ),
                    Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      Container( height: 50, width: 80,
                        child: FittedBox(
                          child: FloatingActionButton.extended(
                            elevation: 0,
                            icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                            label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                            backgroundColor: Colors.white,
                            onPressed: () async {
                              if(b_sikki_gorsel == null) return;
                              var image = await cropImage(b_sikki_gorsel);
                              if(image==null)
                                return;
                              b_sikki_gorsel = image;

                              Navigator.of(context, rootNavigator: true).pop("dialog");

                              showDialog(context: context, builder: (_) {
                                return AlertDialog(
                                  title: Text("B)", style: TextStyle(color: Colors.green),
                                  ),
                                  content: _uploadImageAlertDialog(),
                                  actions: [
                                    Center(
                                      child: MaterialButton(
                                          child: Text("B ????kk??n?? do??ru cevap olarak belirle",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                            textAlign: TextAlign.end,
                                          ),
                                          onPressed: (){
                                            dogru_sik = "B";

//                        setState(() {});
                                          }),
                                    ),
                                    GestureDetector(onDoubleTap: (){},
                                      child: ElevatedButton(
                                          child: Text("B ????kk??n?? Onayla ve C ????kk??na ge??"),
                                          onPressed: () async {
                                            if (b_sikki_gorsel == null) {
                                              return null;
                                            } else {
                                              soru_bitti == false;
                                              a_sikki_bitti = false;
                                              b_sikki_bitti = true;

//                            setState(() {});
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),
                                                action: SnackBarAction(label: "Gizle", onPressed: (){
                                                  SnackBarClosedReason.hide;
                                                },),));
                                              Navigator.of(context, rootNavigator: true).pop('dialog');
                                              c_sikkinaGec();

                                            }
                                          }),
                                    ),

                                  ],
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      GestureDetector(onDoubleTap: (){},
                        child: Container( height: 50, width: 180,
                          child: FittedBox(
                            child: ElevatedButton(
                                child: Text("B ????kk??n?? Onayla ve C ????kk??na ge??"),
                                onPressed: () async {
                                  if (b_sikki_gorsel == null) {
                                    return null;
                                  } else {
                                    soru_bitti == false;
                                    a_sikki_bitti = false;
                                    b_sikki_bitti = true;

//                            setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),));
                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                    c_sikkinaGec();

                                  }
                                }),
                          ),
                        ),
                      ),
                    ],),
                  ],
                );
              });

          },),
        ),
        Visibility( visible: AtaWidget.of(context).metinsel_sik_b != null || a_sikki_gorsel == null ? false : true,
          child: ElevatedButton(child: Text("Foto??raf ??ek"), onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");
            var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
            b_sikki_gorsel = image;

              Widget _uploadImageAlertDialog() {
                return Container(
                  height: 500, width: 400,
                  child: Column(children: [
                    Flexible(
                      child: Container(
                          child: b_sikki_gorsel == null
                              ? Center(
                              child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ))
                              : Image.file(b_sikki_gorsel, fit: BoxFit.contain,
                          )),
                    ),
                    SizedBox(height: 20,),
                    Text("**Sorunuzun B ????kk?? yukar??daki resim olacakt??r**",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                );
              }

              showDialog(context: context, builder: (_) {
                return AlertDialog(
                  title: Text("B)", style: TextStyle(color: Colors.green),
                  ),
                  content: _uploadImageAlertDialog(),
                  actions: [
                    Center(
                      child: MaterialButton(
                          child: Text("B ????kk??n?? do??ru cevap olarak belirle",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                            textAlign: TextAlign.end,
                          ),
                          onPressed: (){
                            dogru_sik = "B";

//                        setState(() {});
                          }),
                    ),
                    Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      Container( height: 50, width: 80,
                        child: FittedBox(
                          child: FloatingActionButton.extended(
                            elevation: 0,
                            icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                            label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                            backgroundColor: Colors.white,
                            onPressed: () async {
                              if(b_sikki_gorsel == null) return;
                              var image = await cropImage(b_sikki_gorsel);
                              if(image==null)
                                return;
                              b_sikki_gorsel = image;

                              Navigator.of(context, rootNavigator: true).pop("dialog");

                              showDialog(context: context, builder: (_) {
                                return AlertDialog(
                                  title: Text("B)", style: TextStyle(color: Colors.green),
                                  ),
                                  content: _uploadImageAlertDialog(),
                                  actions: [
                                    Center(
                                      child: MaterialButton(
                                          child: Text("B ????kk??n?? do??ru cevap olarak belirle",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                            textAlign: TextAlign.end,
                                          ),
                                          onPressed: (){
                                            dogru_sik = "B";

//                        setState(() {});
                                          }),
                                    ),
                                    GestureDetector(onDoubleTap: (){},
                                      child: ElevatedButton(
                                          child: Text("B ????kk??n?? Onayla ve C ????kk??na ge??"),
                                          onPressed: () async {
                                            if (b_sikki_gorsel == null) {
                                              return null;
                                            } else {
                                              soru_bitti == false;
                                              a_sikki_bitti = false;
                                              b_sikki_bitti = true;

//                            setState(() {});
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),
                                                action: SnackBarAction(label: "Gizle", onPressed: (){
                                                  SnackBarClosedReason.hide;
                                                },),));
                                              Navigator.of(context, rootNavigator: true).pop('dialog');
                                              c_sikkinaGec();

                                            }
                                          }),
                                    ),

                                  ],
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      GestureDetector(onDoubleTap: (){},
                        child: Container( height: 50, width: 180,
                          child: FittedBox(
                            child: ElevatedButton(
                                child: Text("B ????kk??n?? Onayla ve C ????kk??na ge??"),
                                onPressed: () async {
                                  if (b_sikki_gorsel == null) {
                                    return null;
                                  } else {
                                    soru_bitti == false;
                                    a_sikki_bitti = false;
                                    b_sikki_bitti = true;

//                            setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),));
                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                    c_sikkinaGec();

                                  }
                                }),
                          ),
                        ),
                      ),
                    ],),
                  ],
                );
              });

          },),
        ),
        Visibility( visible: a_sikki_gorsel == null ? true : false,
          child: ElevatedButton(child: Text(AtaWidget.of(context).metinsel_sik_b != null ? "B ????kk??n?? G??r" : "Metin Gir"), onPressed: (){
            Navigator.of(context, rootNavigator: true).pop("dialog");
            b_sikki_metin = AtaWidget.of(context).metinsel_sik_b;

            if (b_sikki_metin == null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "metinsel_sik_b",
                map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                storageReference: storageReference, mapSoru: null, idSoru: null,) ));
            }
            else {
              TextEditingController _b_sikki_metinci = TextEditingController();
              final _formKey = GlobalKey<FormState>();
              Widget _uploadTextNoteAlertDialog() {
                return Container(
                  height: 300, width: 400,
                  child: Column(children: [
                    ListTile(
                        title: Text("Formdan Girilen Bilgi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        subtitle: b_sikki_metin == null
                            ? Text( "Herhangi bir bilgi giri??i yap??lmad??", style: TextStyle(fontStyle: FontStyle.italic),)
                            : Text( b_sikki_metin, style: TextStyle(fontWeight: FontWeight.bold),)
                    ),
/*
                  Form(key: _formKey,
                      child: Flexible(
                        child: ListView(children: [
                          SizedBox(height: 10,),
                          TextFormField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: _b_sikki_metinci,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "????kk??n metninizi yaz??n??z."),
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                              validator: (String PicName) {
                                if (PicName.isEmpty) {return "Alan bo?? b??rak??lamaz.";
                                } return null;
                              }),
                        ]),
                      )),
*/
                  ]),
                );
              }  showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title:
                      Text("B)", style: TextStyle(color: Colors.orange),
                      ),
                      content: _uploadTextNoteAlertDialog(),
                      actions: [
                        Wrap(direction: Axis.vertical, spacing: 2, children: [
                          MaterialButton(
                              child: Text("B ????kk??n?? do??ru cevap olarak belirle",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                textAlign: TextAlign.end,
                              ),
                              onPressed: (){
                                dogru_sik = "B";

//                            setState(() {});
                              }),
                          GestureDetector(onDoubleTap: (){},
                            child: ElevatedButton(
                              child: Text("B ????kk??n?? onayla ve C ????kk??na ge??"),
                              onPressed: () async {
/*                            if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();
                                b_sikki_metin = _b_sikki_metinci.text.trim().toLowerCase();
                                b_sikki_bitti = true;
*/
//                              setState(() {});
                                soru_bitti == false;
                                a_sikki_bitti = false;
                                b_sikki_bitti = true;
                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                c_sikkinaGec();
//                            }
                              },
                            ),
                          ),
                        ],),
                      ],
                    );
                  });
            }

          },),
        ),
      ],
    );showDialog( barrierDismissible: false,
        context: context, builder: (_) => alertDialog );
  }

  void c_sikkinaGec() async {
    AlertDialog alertDialog = new AlertDialog(
      title: Text("C ????kk?? i??in giri?? y??ntemini se??iniz: "),
      actions: [
        ElevatedButton(
          child: Text("Vazge??"),
          onPressed: (){
            soru_testmi = false; dogru_sik = ""; soru_metni = "";
            a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; baslik = ""; _puan = -1; puan = "";
            soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
            a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;

            AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
            AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
            AtaWidget.of(context).formHelper_metinselSoru_puan = null;
            AtaWidget.of(context).metinsel_sik = null;
            AtaWidget.of(context).metinsel_sik_a = null;
            AtaWidget.of(context).metinsel_sik_b = null;
            AtaWidget.of(context).metinsel_sik_c = null;
            AtaWidget.of(context).metinsel_sik_d = null;
            AtaWidget.of(context).metinsel_soru_bitti = false;
            AtaWidget.of(context).a_sikki_bitti = false;
            AtaWidget.of(context).b_sikki_bitti = false;
            AtaWidget.of(context).c_sikki_bitti = false;
            AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
            AtaWidget.of(context).formHelper_gorselSoru_puan = null;
            Navigator.of(context, rootNavigator: true).pop("dialog");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                    collectionReference: collectionReference, storageReference: storageReference)));
          },
        ),
        Visibility( visible: AtaWidget.of(context).metinsel_sik_c != null || a_sikki_gorsel == null ? false : true,
          child: ElevatedButton(child: Text("Resim Se??"), onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");

            var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
            c_sikki_gorsel = image;

//          setState(() {});

            Widget _uploadImageAlertDialog() {
              return Container(
                height: 500, width: 400,
                child: Column(children: [
                  Flexible(
                    child: Container(
                        child: c_sikki_gorsel == null
                            ? Center(
                            child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ))
                            : Image.file(c_sikki_gorsel, fit: BoxFit.contain,
                        )),
                  ),
                  SizedBox(height: 20,),
                  Text("**Sorunuzun C ????kk?? yukar??daki resim olacakt??r**",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ]),
              );
            }

            showDialog(context: context, builder: (_) {
              return AlertDialog(
                title: Text("C)", style: TextStyle(color: Colors.green),
                ),
                content: _uploadImageAlertDialog(),
                actions: [
                  Center(
                    child: MaterialButton(
                        child: Text("C ????kk??n?? do??ru cevap olarak belirle",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                          textAlign: TextAlign.end,
                        ),
                        onPressed: (){
                          dogru_sik = "C";

//                        setState(() {});
                        }),
                  ),
                  Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Container( height: 50, width: 80,
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                          elevation: 0,
                          icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                          label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            if(c_sikki_gorsel == null) return;
                            var image = await cropImage(c_sikki_gorsel);
                            if(image==null)
                              return;
                            c_sikki_gorsel = image;

                            Navigator.of(context, rootNavigator: true).pop("dialog");

                            showDialog(context: context, builder: (_) {
                              return AlertDialog(
                                title: Text("C)", style: TextStyle(color: Colors.green),
                                ),
                                content: _uploadImageAlertDialog(),
                                actions: [
                                  Center(
                                    child: MaterialButton(
                                        child: Text("C ????kk??n?? do??ru cevap olarak belirle",
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                          textAlign: TextAlign.end,
                                        ),
                                        onPressed: (){
                                          dogru_sik = "C";

//                        setState(() {});
                                        }),
                                  ),
                                  GestureDetector(onDoubleTap: (){},
                                    child: ElevatedButton(
                                        child: Text("C ????kk??n?? Onayla ve D ????kk??na ge??"),
                                        onPressed: () async {
                                          if (c_sikki_gorsel == null) {
                                            return null;
                                          } else {
                                            soru_bitti == false;
                                            a_sikki_bitti = false;
                                            b_sikki_bitti = false;
                                            c_sikki_bitti = true;

//                            setState(() {});
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),));
                                            Navigator.of(context, rootNavigator: true).pop('dialog');
                                            d_sikkinaGec();

                                          }
                                        }),
                                  ),

                                ],
                              );
                            });
                          },
                        ),
                      ),
                    ),
                    GestureDetector(onDoubleTap: (){},
                      child: Container( height: 50, width: 180,
                        child: FittedBox(
                          child: ElevatedButton(
                              child: Text("C ????kk??n?? Onayla ve D ????kk??na ge??"),
                              onPressed: () async {
                                if (c_sikki_gorsel == null) {
                                  return null;
                                } else {
                                  soru_bitti == false;
                                  a_sikki_bitti = false;
                                  b_sikki_bitti = false;
                                  c_sikki_bitti = true;

//                            setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),));
                                  Navigator.of(context, rootNavigator: true).pop('dialog');
                                  d_sikkinaGec();

                                }
                              }),
                        ),
                      ),
                    ),
                  ],),
                ],
              );
            });

          },),
        ),
        Visibility( visible: AtaWidget.of(context).metinsel_sik_c != null || a_sikki_gorsel == null ? false : true,
          child: ElevatedButton(child: Text("Foto??raf ??ek"), onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");

            var image =  await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
            c_sikki_gorsel = image;

//          setState(() {});

            Widget _uploadImageAlertDialog() {
              return Container(
                height: 500, width: 400,
                child: Column(children: [
                  Flexible(
                    child: Container(
                        child: c_sikki_gorsel == null
                            ? Center(
                            child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ))
                            : Image.file(c_sikki_gorsel, fit: BoxFit.contain,
                        )),
                  ),
                  SizedBox(height: 20,),
                  Text("**Sorunuzun C ????kk?? yukar??daki resim olacakt??r**",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ]),
              );
            }

            showDialog(context: context, builder: (_) {
              return AlertDialog(
                title: Text("C)", style: TextStyle(color: Colors.green),
                ),
                content: _uploadImageAlertDialog(),
                actions: [
                  Center(
                    child: MaterialButton(
                        child: Text("C ????kk??n?? do??ru cevap olarak belirle",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                          textAlign: TextAlign.end,
                        ),
                        onPressed: (){
                          dogru_sik = "C";

//                        setState(() {});
                        }),
                  ),
                  Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Container( height: 50, width: 80,
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                          elevation: 0,
                          icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                          label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            if(c_sikki_gorsel == null) return;
                            var image = await cropImage(c_sikki_gorsel);
                            if(image==null)
                              return;
                            c_sikki_gorsel = image;

                            Navigator.of(context, rootNavigator: true).pop("dialog");

                            showDialog(context: context, builder: (_) {
                              return AlertDialog(
                                title: Text("C)", style: TextStyle(color: Colors.green),
                                ),
                                content: _uploadImageAlertDialog(),
                                actions: [
                                  Center(
                                    child: MaterialButton(
                                        child: Text("C ????kk??n?? do??ru cevap olarak belirle",
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                          textAlign: TextAlign.end,
                                        ),
                                        onPressed: (){
                                          dogru_sik = "C";

//                        setState(() {});
                                        }),
                                  ),
                                  GestureDetector(onDoubleTap: (){},
                                    child: ElevatedButton(
                                        child: Text("C ????kk??n?? Onayla ve D ????kk??na ge??"),
                                        onPressed: () async {
                                          if (c_sikki_gorsel == null) {
                                            return null;
                                          } else {
                                            soru_bitti == false;
                                            a_sikki_bitti = false;
                                            b_sikki_bitti = false;
                                            c_sikki_bitti = true;

//                            setState(() {});
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),));
                                            Navigator.of(context, rootNavigator: true).pop('dialog');
                                            d_sikkinaGec();

                                          }
                                        }),
                                  ),

                                ],
                              );
                            });
                          },
                        ),
                      ),
                    ),
                    GestureDetector(onDoubleTap: (){},
                      child: Container( height: 50, width: 180,
                        child: FittedBox(
                          child: ElevatedButton(
                              child: Text("C ????kk??n?? Onayla ve D ????kk??na ge??"),
                              onPressed: () async {
                                if (c_sikki_gorsel == null) {
                                  return null;
                                } else {
                                  soru_bitti == false;
                                  a_sikki_bitti = false;
                                  b_sikki_bitti = false;
                                  c_sikki_bitti = true;

//                            setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor, L??tfen bekleyiniz."),));
                                  Navigator.of(context, rootNavigator: true).pop('dialog');
                                  d_sikkinaGec();

                                }
                              }),
                        ),
                      ),
                    ),
                  ],),
                ],
              );
            });

          },),
        ),
        Visibility( visible: a_sikki_gorsel == null ? true : false,
          child: ElevatedButton(child: Text(AtaWidget.of(context).metinsel_sik_c != null ? "C ????kk??n?? G??r" : "Metin Gir"), onPressed: (){
            Navigator.of(context, rootNavigator: true).pop("dialog");
            c_sikki_metin = AtaWidget.of(context).metinsel_sik_c;

            if (c_sikki_metin == null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "metinsel_sik_c",
                map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                storageReference: storageReference, mapSoru: null, idSoru: null,) ));
            }
            else {
              TextEditingController _c_sikki_metinci = TextEditingController();
              final _formKey = GlobalKey<FormState>();
              Widget _uploadTextNoteAlertDialog() {
                return Container(
                  height: 300, width: 400,
                  child: Column(children: [
                    ListTile(
                        title: Text("Formdan Girilen Bilgi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        subtitle: c_sikki_metin == null
                            ? Text( "Herhangi bir bilgi giri??i yap??lmad??", style: TextStyle(fontStyle: FontStyle.italic),)
                            : Text(c_sikki_metin, style: TextStyle(fontWeight: FontWeight.bold),)
                    ),
/*
                  Form(key: _formKey,
                      child: Flexible(
                        child: ListView(children: [

                          SizedBox(height: 10,),
                          TextFormField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: _c_sikki_metinci,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "????kk??n metninizi yaz??n??z."),
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                              validator: (String PicName) {
                                if (PicName.isEmpty) {return "Alan bo?? b??rak??lamaz.";
                                } return null;
                              }),
                        ]),
                      )),
*/
                  ]),
                );
              }  showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title:
                      Text("C)", style: TextStyle(color: Colors.orange),
                      ),
                      content: _uploadTextNoteAlertDialog(),
                      actions: [
                        Wrap(direction: Axis.vertical, spacing: 2, children: [
                          MaterialButton(
                              child: Text("C ????kk??n?? do??ru cevap olarak belirle",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                textAlign: TextAlign.end,
                              ),
                              onPressed: (){
                                dogru_sik = "C";

//                            setState(() {});
                              }),
                          GestureDetector(onDoubleTap: (){},
                            child: ElevatedButton(
                              child: Text("C ????kk??n?? onayla ve D ????kk??na ge??"),
                              onPressed: () async {
/*                            if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();
                                c_sikki_metin = _c_sikki_metinci.text.trim().toLowerCase();
*/
                                c_sikki_bitti = true;
                                soru_bitti == false;
                                a_sikki_bitti = false;
                                b_sikki_bitti = false;
//                              setState(() {});
                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                d_sikkinaGec();
//                            }
                              },
                            ),
                          ),
                        ],),

                      ],
                    );
                  });
            }
          },),
        ),
      ],
    );showDialog( barrierDismissible: false,
        context: context, builder: (_) => alertDialog );
  }

  void d_sikkinaGec() async {
    AlertDialog alertDialog = new AlertDialog(
      title: Text("D ????kk?? i??in giri?? y??ntemini se??iniz: "),
      actions: [
        ElevatedButton(
          child: Text("Vazge??"),
          onPressed: (){
            soru_testmi = false; dogru_sik = ""; soru_metni = "";
            a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; baslik = ""; _puan = -1; puan = "";
            soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
            a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;

            AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
            AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
            AtaWidget.of(context).formHelper_metinselSoru_puan = null;
            AtaWidget.of(context).metinsel_sik = null;
            AtaWidget.of(context).metinsel_sik_a = null;
            AtaWidget.of(context).metinsel_sik_b = null;
            AtaWidget.of(context).metinsel_sik_c = null;
            AtaWidget.of(context).metinsel_sik_d = null;
            AtaWidget.of(context).metinsel_soru_bitti = false;
            AtaWidget.of(context).a_sikki_bitti = false;
            AtaWidget.of(context).b_sikki_bitti = false;
            AtaWidget.of(context).c_sikki_bitti = false;
            AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
            AtaWidget.of(context).formHelper_gorselSoru_puan = null;
            Navigator.of(context, rootNavigator: true).pop("dialog");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                    collectionReference: collectionReference, storageReference: storageReference)));
          },
        ),
        Visibility( visible: AtaWidget.of(context).metinsel_sik_d != null || a_sikki_gorsel == null ? false : true,
          child: ElevatedButton(child: Text("Resim Se??"), onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");


            var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
            d_sikki_gorsel = image;

//          setState(() {});

            Widget _uploadImageAlertDialog() {
              return Container(
                height: 500, width: 400,
                child: Column(children: [
                  Flexible(
                    child: Container(
                        child: d_sikki_gorsel == null
                            ? Center(
                            child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ))
                            : Image.file(d_sikki_gorsel, fit: BoxFit.contain,
                        )),
                  ),
                  SizedBox(height: 20,),
                  Text("**Sorunuzun D ????kk?? yukar??daki resim olacakt??r**",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ]),
              );
            }

            showDialog(context: context, builder: (_) {
              return AlertDialog(
                title: Text("D)", style: TextStyle(color: Colors.green),
                ),
                content: _uploadImageAlertDialog(),
                actions: [
                  Center(
                    child: MaterialButton(
                        child: Text("D ????kk??n?? do??ru cevap olarak belirle",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                          textAlign: TextAlign.end,
                        ),
                        onPressed: (){
                          dogru_sik = "D";

//                        setState(() {});
                        }),
                  ),
                  Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Container( height: 50, width: 80,
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                          elevation: 0,
                          icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                          label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            if(d_sikki_gorsel == null) return;
                            var image = await cropImage(d_sikki_gorsel);
                            if(image==null)
                              return;
                            d_sikki_gorsel = image;

                            Navigator.of(context, rootNavigator: true).pop("dilaog");

                            showDialog(context: context, builder: (_) {
                              return AlertDialog(
                                title: Text("D)", style: TextStyle(color: Colors.green),
                                ),
                                content: _uploadImageAlertDialog(),
                                actions: [
                                  Center(
                                    child: MaterialButton(
                                        child: Text("D ????kk??n?? do??ru cevap olarak belirle",
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                          textAlign: TextAlign.end,
                                        ),
                                        onPressed: (){
                                          dogru_sik = "D";

//                        setState(() {});
                                        }),
                                  ),
                                  GestureDetector(onDoubleTap: (){},
                                    child: ElevatedButton(
                                        child: Text("D ????kk??n?? Onayla ve Soruyu y??kle"),
                                        onPressed: () async {
                                          soru_bitti == false;
                                          a_sikki_bitti = false;
                                          b_sikki_bitti = false;
                                          c_sikki_bitti = false;
                                          String url; String url_a; String url_b; String url_c; String url_d;

//                                        print("_soruSelected.path3: " + _soruSelected.path.toString());
                                          try {
                                            if (d_sikki_gorsel == null) {
                                              return null;
                                            } else {
                                              if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                                if (_soruSelected != null){
                                                  final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik).child(baslik);
                                                  await ref.putFile(_soruSelected);
                                                  var downloadUrl = await ref.getDownloadURL();
                                                  url = downloadUrl.toString();
                                                } else {
                                                  url = "";
                                                }

                                                if(a_sikki_gorsel != null ){
                                                  final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                                      .child("????klar").child("A_????kk??");
                                                  await ref_a.putFile(a_sikki_gorsel);
                                                  var downloadUrl_a = await ref_a.getDownloadURL();
                                                  url_a = downloadUrl_a.toString();
                                                } else {
                                                  url_a = "";
                                                }

                                                if(b_sikki_gorsel != null ) {
                                                  final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                                      .child("????klar").child("B_????kk??");
                                                  await ref_b.putFile(b_sikki_gorsel);
                                                  var downloadUrl_b = await ref_b.getDownloadURL();
                                                  url_b = downloadUrl_b.toString();
                                                } else {
                                                  url_b = "";
                                                }

                                                if(c_sikki_gorsel != null ) {
                                                  final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                                      .child("????klar").child("C_????kk??");
                                                  await ref_c.putFile(c_sikki_gorsel);
                                                  var downloadUrl_c = await ref_c.getDownloadURL();
                                                  url_c = downloadUrl_c.toString();
                                                } else {
                                                  url_c = "";
                                                }

                                                if(d_sikki_gorsel != null ) {
                                                  final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                                      .child("????klar").child("D_????kk??");
                                                  await ref_d.putFile(d_sikki_gorsel);
                                                  var downloadUrl_d = await ref_d.getDownloadURL();
                                                  url_d = downloadUrl_d.toString();
                                                }  else {
                                                  url_d = "";
                                                }

                                                var subCol_newDoc =  await collectionReference.doc(id_solusturulan).collection("sorular")
                                                    .add({"gorsel_soru": url, "baslik": baslik, "gorsel_cevap": "", "metinsel_cevap": "", "metinsel_soru": soru_metni
                                                  , "soru_testmi": soru_testmi, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c, "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                                  "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                                  "tarih": DateTime.now(), "puan" : _puan, });

                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("T??m ????klar ve soru ba??ar??yla eklendi."),));

                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Do??ru cevap: " + dogru_sik + ") ????kk?? olarak belirlediniz."),));
                                                id_subCol_newDoc = await subCol_newDoc.id;

                                                soru_testmi = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = ""; baslik = "";
                                                soru_metni = "";a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; _puan = -1;
                                                puan = ""; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                                                soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                                                a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;
//                                setState(() {});

                                                AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                                                AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                                                AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                                                AtaWidget.of(context).metinsel_sik = null;
                                                AtaWidget.of(context).metinsel_sik_a = null;
                                                AtaWidget.of(context).metinsel_sik_b = null;
                                                AtaWidget.of(context).metinsel_sik_c = null;
                                                AtaWidget.of(context).metinsel_sik_d = null;
                                                AtaWidget.of(context).metinsel_soru_bitti = false;
                                                AtaWidget.of(context).a_sikki_bitti = false;
                                                AtaWidget.of(context).b_sikki_bitti = false;
                                                AtaWidget.of(context).c_sikki_bitti = false;
                                                AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
                                                AtaWidget.of(context).formHelper_gorselSoru_puan = null;
                                                Navigator.of(context, rootNavigator: true).pop('dialog');

                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OlusturulanSinavPage(
                                                    map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                                                    collectionReference: collectionReference, storageReference: storageReference
                                                )));
                                              } else {
                                                AlertDialog alertDialog = new AlertDialog (
                                                  title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                                  content: Text("Sorunuz i??in do??ru ????k belirlemediniz. L??tfen ????klar?? tekrar girerek do??ru ????kk?? belirleyiniz."),
                                                );showDialog(context: context, builder: (_) => alertDialog) ;
                                              }
                                            }
                                          } catch (e) { print(e.toString());}


                                        }),
                                  ),


                                ],
                              );
                            });
                          },
                        ),
                      ),
                    ),

                    GestureDetector(onDoubleTap: (){},
                      child: Container( height: 50, width: 180,
                        child: FittedBox(
                          child: ElevatedButton(
                              child: Text("D ????kk??n?? Onayla ve Soruyu y??kle"),
                              onPressed: () async {
                                soru_bitti == false;
                                a_sikki_bitti = false;
                                b_sikki_bitti = false;
                                c_sikki_bitti = false;
                                String url; String url_a; String url_b; String url_c; String url_d;

//                              print("_soruSelected.path3: " + _soruSelected.path.toString());
                                try {
                                  if (d_sikki_gorsel == null) {
                                    return null;
                                  } else {
                                    if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                      if (_soruSelected != null){
                                        final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik).child(baslik);
                                        await ref.putFile(_soruSelected);
                                        var downloadUrl = await ref.getDownloadURL();
                                        url = downloadUrl.toString();
                                      } else {
                                        url = "";
                                      }

                                      if(a_sikki_gorsel != null ){
                                        final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                            .child("????klar").child("A_????kk??");
                                        await ref_a.putFile(a_sikki_gorsel);
                                        var downloadUrl_a = await ref_a.getDownloadURL();
                                        url_a = downloadUrl_a.toString();
                                      } else {
                                        url_a = "";
                                      }

                                      if(b_sikki_gorsel != null ) {
                                        final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                            .child("????klar").child("B_????kk??");
                                        await ref_b.putFile(b_sikki_gorsel);
                                        var downloadUrl_b = await ref_b.getDownloadURL();
                                        url_b = downloadUrl_b.toString();
                                      } else {
                                        url_b = "";
                                      }

                                      if(c_sikki_gorsel != null ) {
                                        final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                            .child("????klar").child("C_????kk??");
                                        await ref_c.putFile(c_sikki_gorsel);
                                        var downloadUrl_c = await ref_c.getDownloadURL();
                                        url_c = downloadUrl_c.toString();
                                      } else {
                                        url_c = "";
                                      }

                                      if(d_sikki_gorsel != null ) {
                                        final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                            .child("????klar").child("D_????kk??");
                                        await ref_d.putFile(d_sikki_gorsel);
                                        var downloadUrl_d = await ref_d.getDownloadURL();
                                        url_d = downloadUrl_d.toString();
                                      }  else {
                                        url_d = "";
                                      }

                                      var subCol_newDoc =  await collectionReference.doc(id_solusturulan).collection("sorular")
                                          .add({"gorsel_soru": url, "baslik": baslik, "gorsel_cevap": "", "metinsel_cevap": "", "metinsel_soru": soru_metni
                                        , "soru_testmi": soru_testmi, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c, "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                        "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                        "tarih": DateTime.now(), "puan" : _puan, });

                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("T??m ????klar ve soru ba??ar??yla eklendi."),));

                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Do??ru cevap: " + dogru_sik + ") ????kk?? olarak belirlediniz."),));
                                      id_subCol_newDoc = await subCol_newDoc.id;

                                      soru_testmi = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = ""; baslik = ""; soru_metni = "";
                                      a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; _puan = -1; puan = "";
                                      a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                                      soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                                      a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;
//                                setState(() {});

                                      AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                                      AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                                      AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                                      AtaWidget.of(context).metinsel_sik = null;
                                      AtaWidget.of(context).metinsel_sik_a = null;
                                      AtaWidget.of(context).metinsel_sik_b = null;
                                      AtaWidget.of(context).metinsel_sik_c = null;
                                      AtaWidget.of(context).metinsel_sik_d = null;
                                      AtaWidget.of(context).metinsel_soru_bitti = false;
                                      AtaWidget.of(context).a_sikki_bitti = false;
                                      AtaWidget.of(context).b_sikki_bitti = false;
                                      AtaWidget.of(context).c_sikki_bitti = false;
                                      AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
                                      AtaWidget.of(context).formHelper_gorselSoru_puan = null;
                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OlusturulanSinavPage(
                                          map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                                          collectionReference: collectionReference, storageReference: storageReference
                                      )));
                                    } else {
                                      AlertDialog alertDialog = new AlertDialog (
                                        title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                        content: Text("Sorunuz i??in do??ru ????k belirlemediniz. L??tfen ????klar?? tekrar girerek do??ru ????kk?? belirleyiniz."),
                                      );showDialog(context: context, builder: (_) => alertDialog) ;
                                    }
                                  }
                                } catch (e) { print(e.toString());}


                              }),
                        ),
                      ),
                    ),
                  ]),


                ],
              );
            });

          },),
        ),
        Visibility( visible: AtaWidget.of(context).metinsel_sik_d != null || a_sikki_gorsel == null ? false : true,
          child: ElevatedButton(child: Text("Foto??raf ??ek"), onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");

            var image =  await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
            d_sikki_gorsel = image;

//          setState(() {});

            Widget _uploadImageAlertDialog() {
              return Container(
                height: 500, width: 400,
                child: Column(children: [
                  Flexible(
                    child: Container(
                        child: d_sikki_gorsel == null
                            ? Center(
                            child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ))
                            : Image.file(d_sikki_gorsel, fit: BoxFit.contain,
                        )),
                  ),
                  SizedBox(height: 20,),
                  Text("**Sorunuzun D ????kk?? yukar??daki resim olacakt??r**",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ]),
              );
            }

            showDialog(context: context, builder: (_) {
              return AlertDialog(
                title: Text("D)", style: TextStyle(color: Colors.green),
                ),
                content: _uploadImageAlertDialog(),
                actions: [
                  Center(
                    child: MaterialButton(
                        child: Text("D ????kk??n?? do??ru cevap olarak belirle",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                          textAlign: TextAlign.end,
                        ),
                        onPressed: (){
                          dogru_sik = "D";

//                        setState(() {});
                        }),
                  ),
                  Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Container( height: 50, width: 80,
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                          elevation: 0,
                          icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                          label: Text("K??rp", style: TextStyle(color: Colors.purple)),
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            if(d_sikki_gorsel == null) return;
                            var image = await cropImage(d_sikki_gorsel);
                            if(image==null)
                              return;
                            d_sikki_gorsel = image;

                            Navigator.of(context, rootNavigator: true).pop("dilaog");

                            showDialog(context: context, builder: (_) {
                              return AlertDialog(
                                title: Text("D)", style: TextStyle(color: Colors.green),
                                ),
                                content: _uploadImageAlertDialog(),
                                actions: [
                                  Center(
                                    child: MaterialButton(
                                        child: Text("D ????kk??n?? do??ru cevap olarak belirle",
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                          textAlign: TextAlign.end,
                                        ),
                                        onPressed: (){
                                          dogru_sik = "D";

//                        setState(() {});
                                        }),
                                  ),
                                  GestureDetector(onDoubleTap: (){},
                                    child: ElevatedButton(
                                        child: Text("D ????kk??n?? Onayla ve Soruyu y??kle"),
                                        onPressed: () async {
                                          soru_bitti == false;
                                          a_sikki_bitti = false;
                                          b_sikki_bitti = false;
                                          c_sikki_bitti = false;
                                          String url; String url_a; String url_b; String url_c; String url_d;

                                          try {
                                            if (d_sikki_gorsel == null) {
                                              return null;
                                            } else {
                                              if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                                if (_soruSelected != null){
                                                  final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik).child(baslik);
                                                  await ref.putFile(_soruSelected);
                                                  var downloadUrl = await ref.getDownloadURL();
                                                  url = downloadUrl.toString();
                                                } else {
                                                  url = "";
                                                }

                                                if(a_sikki_gorsel != null ){
                                                  final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                                      .child("????klar").child("A_????kk??");
                                                  await ref_a.putFile(a_sikki_gorsel);
                                                  var downloadUrl_a = await ref_a.getDownloadURL();
                                                  url_a = downloadUrl_a.toString();
                                                } else {
                                                  url_a = "";
                                                }

                                                if(b_sikki_gorsel != null ) {
                                                  final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                                      .child("????klar").child("B_????kk??");
                                                  await ref_b.putFile(b_sikki_gorsel);
                                                  var downloadUrl_b = await ref_b.getDownloadURL();
                                                  url_b = downloadUrl_b.toString();
                                                } else {
                                                  url_b = "";
                                                }

                                                if(c_sikki_gorsel != null ) {
                                                  final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                                      .child("????klar").child("C_????kk??");
                                                  await ref_c.putFile(c_sikki_gorsel);
                                                  var downloadUrl_c = await ref_c.getDownloadURL();
                                                  url_c = downloadUrl_c.toString();
                                                } else {
                                                  url_c = "";
                                                }

                                                if(d_sikki_gorsel != null ) {
                                                  final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                      .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                                      .child("????klar").child("D_????kk??");
                                                  await ref_d.putFile(d_sikki_gorsel);
                                                  var downloadUrl_d = await ref_d.getDownloadURL();
                                                  url_d = downloadUrl_d.toString();
                                                }  else {
                                                  url_d = "";
                                                }

                                                var subCol_newDoc =  await collectionReference.doc(id_solusturulan).collection("sorular")
                                                    .add({"gorsel_soru": url, "baslik": baslik, "gorsel_cevap": "", "metinsel_cevap": "", "metinsel_soru": soru_metni
                                                  , "soru_testmi": soru_testmi, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c, "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                                  "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                                  "tarih": DateTime.now(), "puan" : _puan, });

                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("T??m ????klar ve soru ba??ar??yla eklendi."),));

                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Do??ru cevap: " + dogru_sik + ") ????kk?? olarak belirlediniz."),));
                                                id_subCol_newDoc = await subCol_newDoc.id;

                                                soru_testmi = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = ""; baslik = ""; soru_metni = "";
                                                a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; _puan = -1; puan = "";
                                                soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                                                a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;
//                                setState(() {});

                                                AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                                                AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                                                AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                                                AtaWidget.of(context).metinsel_sik = null;
                                                AtaWidget.of(context).metinsel_sik_a = null;
                                                AtaWidget.of(context).metinsel_sik_b = null;
                                                AtaWidget.of(context).metinsel_sik_c = null;
                                                AtaWidget.of(context).metinsel_sik_d = null;
                                                AtaWidget.of(context).metinsel_soru_bitti = false;
                                                AtaWidget.of(context).a_sikki_bitti = false;
                                                AtaWidget.of(context).b_sikki_bitti = false;
                                                AtaWidget.of(context).c_sikki_bitti = false;
                                                AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
                                                AtaWidget.of(context).formHelper_gorselSoru_puan = null;
                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OlusturulanSinavPage(
                                                    map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                                                    collectionReference: collectionReference, storageReference: storageReference
                                                )));
                                              } else {
                                                AlertDialog alertDialog = new AlertDialog (
                                                  title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                                  content: Text("Sorunuz i??in do??ru ????k belirlemediniz. L??tfen ????klar?? tekrar girerek do??ru ????kk?? belirleyiniz."),
                                                );showDialog(context: context, builder: (_) => alertDialog) ;
                                              }
                                            }
                                          } catch (e) { print(e.toString());}


                                        }),
                                  ),


                                ],
                              );
                            });
                          },
                        ),
                      ),
                    ),

                    GestureDetector(onDoubleTap: (){},
                      child: Container( height: 50, width: 180,
                        child: FittedBox(
                          child: ElevatedButton(
                              child: Text("D ????kk??n?? Onayla ve Soruyu y??kle"),
                              onPressed: () async {
                                soru_bitti == false;
                                a_sikki_bitti = false;
                                b_sikki_bitti = false;
                                c_sikki_bitti = false;
                                String url; String url_a; String url_b; String url_c; String url_d;

                                try {
                                  if (d_sikki_gorsel == null) {
                                    return null;
                                  } else {
                                    if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                      if (_soruSelected != null){
                                        final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik).child(baslik);
                                        await ref.putFile(_soruSelected);
                                        var downloadUrl = await ref.getDownloadURL();
                                        url = downloadUrl.toString();
                                      } else {
                                        url = "";
                                      }

                                      if(a_sikki_gorsel != null ){
                                        final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                            .child("????klar").child("A_????kk??");
                                        await ref_a.putFile(a_sikki_gorsel);
                                        var downloadUrl_a = await ref_a.getDownloadURL();
                                        url_a = downloadUrl_a.toString();
                                      } else {
                                        url_a = "";
                                      }

                                      if(b_sikki_gorsel != null ) {
                                        final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                            .child("????klar").child("B_????kk??");
                                        await ref_b.putFile(b_sikki_gorsel);
                                        var downloadUrl_b = await ref_b.getDownloadURL();
                                        url_b = downloadUrl_b.toString();
                                      } else {
                                        url_b = "";
                                      }

                                      if(c_sikki_gorsel != null ) {
                                        final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                            .child("????klar").child("C_????kk??");
                                        await ref_c.putFile(c_sikki_gorsel);
                                        var downloadUrl_c = await ref_c.getDownloadURL();
                                        url_c = downloadUrl_c.toString();
                                      } else {
                                        url_c = "";
                                      }

                                      if(d_sikki_gorsel != null ) {
                                        final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                            .child("????klar").child("D_????kk??");
                                        await ref_d.putFile(d_sikki_gorsel);
                                        var downloadUrl_d = await ref_d.getDownloadURL();
                                        url_d = downloadUrl_d.toString();
                                      }  else {
                                        url_d = "";
                                      }

                                      var subCol_newDoc =  await collectionReference.doc(id_solusturulan).collection("sorular")
                                          .add({"gorsel_soru": url, "baslik": baslik, "gorsel_cevap": "", "metinsel_cevap": "", "metinsel_soru": soru_metni
                                        , "soru_testmi": soru_testmi, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c, "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                        "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                        "tarih": DateTime.now(), "puan" : _puan, });

                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("T??m ????klar ve soru ba??ar??yla eklendi."),));

                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Do??ru cevap: " + dogru_sik + ") ????kk?? olarak belirlediniz."),));
                                      id_subCol_newDoc = await subCol_newDoc.id;

                                      soru_testmi = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = ""; baslik = ""; soru_metni = "";
                                      a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; _puan = -1; puan = "";
                                      soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                                      a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;
//                                setState(() {});

                                      AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                                      AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                                      AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                                      AtaWidget.of(context).metinsel_sik = null;
                                      AtaWidget.of(context).metinsel_sik_a = null;
                                      AtaWidget.of(context).metinsel_sik_b = null;
                                      AtaWidget.of(context).metinsel_sik_c = null;
                                      AtaWidget.of(context).metinsel_sik_d = null;
                                      AtaWidget.of(context).metinsel_soru_bitti = false;
                                      AtaWidget.of(context).a_sikki_bitti = false;
                                      AtaWidget.of(context).b_sikki_bitti = false;
                                      AtaWidget.of(context).c_sikki_bitti = false;
                                      AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
                                      AtaWidget.of(context).formHelper_gorselSoru_puan = null;
                                      Navigator.of(context, rootNavigator: true).pop('dialog');
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OlusturulanSinavPage(
                                          map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                                          collectionReference: collectionReference, storageReference: storageReference
                                      )));
                                    } else {
                                      AlertDialog alertDialog = new AlertDialog (
                                        title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                        content: Text("Sorunuz i??in do??ru ????k belirlemediniz. L??tfen ????klar?? tekrar girerek do??ru ????kk?? belirleyiniz."),
                                      );showDialog(context: context, builder: (_) => alertDialog) ;
                                    }
                                  }
                                } catch (e) { print(e.toString());}


                              }),
                        ),
                      ),
                    ),
                  ]),


                ],
              );
            });

          },),
        ),
        Visibility( visible: a_sikki_gorsel == null ? true : false,
          child: ElevatedButton(child: Text(AtaWidget.of(context).metinsel_sik_d != null ? "D ????kk??n?? G??r" : "Metin Gir"), onPressed: (){
            Navigator.of(context, rootNavigator: true).pop("dialog");
            d_sikki_metin = AtaWidget.of(context).metinsel_sik_d;

            if (d_sikki_metin == null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "metinsel_sik_d",
                map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
                storageReference: storageReference, mapSoru: null, idSoru: null,) ));
            }
            else {
              TextEditingController _d_sikki_metinci = TextEditingController();
              final _formKey = GlobalKey<FormState>();
              Widget _uploadTextNoteAlertDialog() {
                return Container(
                  height: 300, width: 400,
                  child: Column(children: [
                    ListTile(
                        title: Text("Formdan Girilen Bilgi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        subtitle: d_sikki_metin == null
                            ? Text( "Herhangi bir bilgi giri??i yap??lmad??", style: TextStyle(fontStyle: FontStyle.italic),)
                            : Text(d_sikki_metin, style: TextStyle(fontWeight: FontWeight.bold),)
                    ),
/*
                  Form(key: _formKey,
                      child: Flexible(
                        child: ListView(children: [
                          SizedBox(height: 10,),
                          TextFormField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: _d_sikki_metinci,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "????kk??n metninizi yaz??n??z."),
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                              validator: (String PicName) {
                                if (PicName.isEmpty) {return "Alan bo?? b??rak??lamaz.";
                                } return null;
                              }),
                        ]),
                      )),
*/
                  ]),
                );
              }  showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title:
                      Text("D)", style: TextStyle(color: Colors.orange),
                      ),
                      content: _uploadTextNoteAlertDialog(),
                      actions: [
                        Wrap(direction: Axis.vertical, spacing: 2, children: [
                          MaterialButton(
                              child: Text("D ????kk??n?? do??ru cevap olarak belirle",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                                textAlign: TextAlign.end,
                              ),
                              onPressed: (){
                                dogru_sik = "D";

//                            setState(() {});
                              }),
                          GestureDetector(onDoubleTap: (){},
                            child: ElevatedButton(
                              child: Text("D ????kk??n?? onayla ve soruyu y??kle"),
                              onPressed: () async {
/*                            if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();
                                d_sikki_metin = _d_sikki_metinci.text.trim().toLowerCase();
*/

                                  String url; String url_a; String url_b; String url_c; String url_d;

                                  soru_bitti == false;
                                  a_sikki_bitti = false;
                                  b_sikki_bitti = false;
                                  c_sikki_bitti = false;

                                  if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                  if (_soruSelected != null){
                                    final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                        .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik).child(baslik);
                                    await ref.putFile(_soruSelected);
                                    var downloadUrl = await ref.getDownloadURL();
                                    url = downloadUrl.toString();

                                  } else {
                                    url = "";
                                  }

                                  if(a_sikki_gorsel != null ){
                                    final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                        .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                        .child("????klar").child("A_????kk??");
                                    await ref_a.putFile(a_sikki_gorsel);
                                    var downloadUrl_a = await ref_a.getDownloadURL();
                                    url_a = downloadUrl_a.toString();
                                  } else {
                                    url_a = "";
                                  }

                                  if(b_sikki_gorsel != null ) {
                                    final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                        .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                        .child("????klar").child("B_????kk??");
                                    await ref_b.putFile(b_sikki_gorsel);
                                    var downloadUrl_b = await ref_b.getDownloadURL();
                                    url_b = downloadUrl_b.toString();
                                  } else {
                                    url_b = "";
                                  }

                                  if(c_sikki_gorsel != null ) {
                                    final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                        .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                        .child("????klar").child("C_????kk??");
                                    await ref_c.putFile(c_sikki_gorsel);
                                    var downloadUrl_c = await ref_c.getDownloadURL();
                                    url_c = downloadUrl_c.toString();
                                  } else {
                                    url_c = "";
                                  }

                                  if(d_sikki_gorsel != null ) {
                                    final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                        .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(baslik)
                                        .child("????klar").child("D_????kk??");
                                    await ref_d.putFile(d_sikki_gorsel);
                                    var downloadUrl_d = await ref_d.getDownloadURL();
                                    url_d = downloadUrl_d.toString();
                                  }  else {
                                    url_d = "";
                                  }

                                  var subCol_newDoc =  await collectionReference.doc(id_solusturulan).collection("sorular")
                                      .add({"gorsel_soru": url, "baslik": baslik, "gorsel_cevap": "", "metinsel_cevap": "", "metinsel_soru": soru_metni
                                    ,"soru_testmi": soru_testmi, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c, "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                    "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                    "tarih": DateTime.now(), "puan" : _puan,});

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("T??m ????klar ve soru ba??ar??yla eklendi."),));

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Do??ru cevap: " + dogru_sik + ") ????kk?? olarak belirlediniz."),));
                                  id_subCol_newDoc = await subCol_newDoc.id;

                                  soru_testmi = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = ""; soru_metni = "";
                                  a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; baslik = ""; _puan = -1; puan = "";
                                  soru_bitti = false; a_sikki_bitti = false; b_sikki_bitti = false; c_sikki_bitti = false; d_sikki_bitti = false;
                                  a_sikki_gorsel = null; b_sikki_gorsel = null; c_sikki_gorsel = null; d_sikki_gorsel = null;
//                                setState(() {});

                                  AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                                  AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                                  AtaWidget.of(context).formHelper_metinselSoru_puan = null;
                                  AtaWidget.of(context).metinsel_sik = null;
                                  AtaWidget.of(context).metinsel_sik_a = null;
                                  AtaWidget.of(context).metinsel_sik_b = null;
                                  AtaWidget.of(context).metinsel_sik_c = null;
                                  AtaWidget.of(context).metinsel_sik_d = null;
                                  AtaWidget.of(context).metinsel_soru_bitti = false;
                                  AtaWidget.of(context).a_sikki_bitti = false;
                                  AtaWidget.of(context).b_sikki_bitti = false;
                                  AtaWidget.of(context).c_sikki_bitti = false;
                                    AtaWidget.of(context).formHelper_gorselSoru_baslik = null;
                                    AtaWidget.of(context).formHelper_gorselSoru_puan = null;
                                  Navigator.of(context, rootNavigator: true).pop('dialog');
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OlusturulanSinavPage(
                                      map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                                      collectionReference: collectionReference, storageReference: storageReference
                                  )));
                                } else {
                                  AlertDialog alertDialog = new AlertDialog (
                                    title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                    content: Text("Sorunuz i??in do??r?? ????k belirlemediniz. L??tfen ????klar?? tekrar girerek do??ru ????kk?? belirleyiniz."),
                                  );showDialog(context: context, builder: (_) => alertDialog) ;
                                }
//                            }
                              },
                            ),
                          ),
                        ],),
                      ],
                    );
                  });
            }
          },),
        ),
      ],
    );showDialog( barrierDismissible: false,
        context: context, builder: (_) => alertDialog );
  }

  void _soruyuSil(dynamic idSoru, dynamic mapSoru) async {

    try {
    collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).collection("soruyu_cevaplayanlar")
        .get().then((snapshot) {for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
    });
    collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).collection("A_isaretleyenler")
        .get().then((snapshot) {for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();}
    });
    collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).collection("B_isaretleyenler")
        .get().then((snapshot) {for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();}
    });
    collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).collection("C_isaretleyenler")
        .get().then((snapshot) {for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();}
    });
    collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).collection("D_isaretleyenler")
        .get().then((snapshot) {for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();}
    });
    collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).collection("dogruSik_isaretleyenler")
        .get().then((snapshot) {for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();}
    });
    collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).collection("isaretleyenler")
        .get().then((snapshot) {for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();}
    });
    collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).delete();


    await FirebaseStorage.instance.ref().child("users").child(map_solusturulan["hazirlayan"])
          .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(mapSoru["baslik"])
          .child("cevaplayanlarin_gorselleri").listAll().then((value) => value.items.forEach((element) {element.delete();}));

    await FirebaseStorage.instance.ref().child("users").child(map_solusturulan["hazirlayan"])
          .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular").child(mapSoru["baslik"])
          .child("????klar").listAll().then((value) => value.items.forEach((element) {element.delete();}));

    await FirebaseStorage.instance.ref().child("users").child(map_solusturulan["hazirlayan"])
          .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
          .child(mapSoru["baslik"]).listAll().then((value) => value.items.forEach((element) {element.delete();}));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Soru ba??ar??yla silindi."),));
    Navigator.of(context, rootNavigator: true).pop("dialog");
    }
    catch (e) {print(e.toString());}
  }

  void _gonderilenCevaplariGor_soru(dynamic map_solusturulan, dynamic id_solusturulan, CollectionReference collectionReference
      , Reference storageReference, dynamic mapSoru, dynamic idSoru, QuerySnapshot querySnapshot, int sira) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        GonderilenCevaplarPage(map_cevaplanan: map_solusturulan, id_cevaplanan: id_solusturulan,
            collectionReference: collectionReference, storageReference: storageReference, mapSoru: mapSoru,
            idSoru: idSoru,)));
  }

  void _cevaplayanCozumSil (dynamic idSoru, dynamic mapSoru) async {

    collectionReference.doc(id_solusturulan).collection("sorular")
        .doc(idSoru.toString()).collection("soruyu_cevaplayanlar")
        .where("cevaplayan", isEqualTo: AtaWidget.of(context).kullaniciadi)
        .get().then((QuerySnapshot querySnapshot)=>{
      querySnapshot.docs.forEach((_doc) async {

        collectionReference.doc(id_solusturulan).collection("sorular")
            .doc(idSoru.toString()).collection("soruyu_cevaplayanlar").doc(_doc.id.toString()).delete();

        List <dynamic> cevapladigi_sorular = [];
        List <dynamic> dogru_cevaplar = [];
        String sinavi_cevaplayan;
        int puan = -1;
        String sinavi_cevaplayan_id;
        List <dynamic> cevapladigiSorular_kalanKontrol = [];

        await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar")
            .where("mail", isEqualTo: AtaWidget.of(context).kullanicimail)
            .get().then((value) { value.docs.forEach((element) {
          cevapladigi_sorular = element["cevapladigi_sorular"];
          dogru_cevaplar = element["dogru_cevaplar"];
          sinavi_cevaplayan = element["cevaplayan"];
          sinavi_cevaplayan_id = element.id.toString();
//          if (cevapladigi_sorular.length == 0){element.reference.delete();}
//          setState(() {});
        });
        });

        if(sinavi_cevaplayan == AtaWidget.of(context).kullaniciadi){

          cevapladigi_sorular.remove(mapSoru["baslik"]);
          await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar").doc(sinavi_cevaplayan_id)
              .update({"cevapladigi_sorular": cevapladigi_sorular});

          if(dogru_cevaplar.contains(mapSoru["baslik"])){
            dogru_cevaplar.remove(mapSoru["baslik"]);
            await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar").doc(sinavi_cevaplayan_id)
                .update({"dogru_cevaplar": dogru_cevaplar});
          }
        }

        await collectionReference.doc(id_solusturulan).collection("sinavi_cevaplayanlar")
            .where("mail", isEqualTo: AtaWidget.of(context).kullanicimail)
            .get().then((value) { value.docs.forEach((element) {
          cevapladigiSorular_kalanKontrol = element["cevapladigi_sorular"];
          print(cevapladigiSorular_kalanKontrol);
          if (cevapladigiSorular_kalanKontrol.length == 0){element.reference.delete();}
//          setState(() {});
        });
        });

        try{
          final Reference ref = await FirebaseStorage.instance.ref().child("users").child(map_solusturulan["hazirlayan"])
              .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
              .child(mapSoru["baslik"]).child("cevaplayanlarin_gorselleri")
              .child(_doc["baslik"] + "_" + AtaWidget.of(context).kullaniciadi);
          await ref.delete();
        } catch (e) { print(e.toString());}

        ScaffoldMessenger.of(context).showSnackBar((SnackBar(content: Text("????lem ba??ar??l??"), action: SnackBarAction(label: "Gizle",
            onPressed: () => SnackBarClosedReason.hide),)));
        Navigator.of(context, rootNavigator: true).pop("dialog");
      })
    });

  }

  void _aciklamayiGor() {
    AlertDialog alertDialog = new AlertDialog(
      title: Text(map_solusturulan["aciklama"], style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),),
      actions: [
        Visibility( visible: AtaWidget.of(context).kullaniciadi == map_solusturulan["hazirlayan"] ? true : false,
          child: ElevatedButton(
            child: Text("A????klamay?? De??i??tir"),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop("dialog");
              _aciklamaGir();

            }
          ),
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog );
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
            toolbarTitle: 'RESM?? KIRP',
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

  void cikti_metinEkle() async {

    if(ustbilgi == true){
      Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "ustbilgi",
        map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
        storageReference: storageReference, mapSoru: null, idSoru: null,) ));
    }
    if(altbilgi == true){
      Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "altbilgi",
        map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
        storageReference: storageReference, mapSoru: null, idSoru: null,) ));
    }
    if(yazili == true){
      Navigator.push(context, MaterialPageRoute(builder: (context) => FormHelper(imageSelected: null, islem: "yazili",
        map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, collectionReference: collectionReference,
        storageReference: storageReference, mapSoru: null, idSoru: null,) ));
    }
/*
    GlobalKey<FormState> _formKey_ciktiMetni = GlobalKey<FormState>();
    TextEditingController ciktiMetni_controller = TextEditingController();
    TextEditingController ciktiMetni_punto_controller = TextEditingController();
    GlobalKey<FormState> _formKey_ciktiMetni_punto = GlobalKey<FormState>();
    bool _bold_altbilgi = map_solusturulan["altbilgi_kalin"];
    bool _italic_altbilgi = map_solusturulan["altbilgi_italic"];
    String _punto_altbilgi = map_solusturulan["altbilgi_punto"];
    bool _bold_ustbilgi = map_solusturulan["ustbilgi_kalin"];
    bool _italic_ustbilgi = map_solusturulan["ustbilgi_italic"];
    String _punto_ustbilgi = map_solusturulan["ustbilgi_punto"];

    Widget AltUstbilgi_YaziliAlertDialog() {
      return Container( height: 300, width: 400,
        child: ListView(
          children: [
            Form( key: _formKey_ciktiMetni,
              child: TextFormField( controller: ciktiMetni_controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: ustbilgi == true ? "??stbilgiyi giriniz."
                        : altbilgi == true ? map_solusturulan["altbilgi"] == null ? "Altbilgiyi giriniz" : map_solusturulan["altbilgi"]
                        : "Yaz??l?? ba??l??????n?? giriniz"),
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                validator: (String bilgi) {
                  if(bilgi.isEmpty) { return "Yeni bilgi girilmedi.";}
                  return null;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
            Visibility( visible: yazili == true ? false : true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("A??a????da, girdi??iniz bilgilerin g??r??n??m??n?? d??zenleyebilece??iniz ara??lar mevcuttur. Herhangi bir i??lem yapmazsan??z ilk giri?? ise "
                    "altbilgi ve ??stbilgileriniz standart g??r??n??mde de??ilse bir ??nceki g??r??n??mde g??r??nt??lenir.",
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
              ),
            ),
            Visibility( visible: yazili == true ? false : true,
              child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container( width: 80,
                    child: Form( key: _formKey_ciktiMetni_punto,
                      child: TextFormField( controller: ciktiMetni_punto_controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "punto", hintText: "say?? giriniz"),
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                        validator: (String punto) {
                          if(punto.isEmpty) { return "Punto girilmedi"; }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.format_bold), onPressed: (){
                    if(ustbilgi == true){
                      _bold_ustbilgi == false || _bold_ustbilgi == null ?
                      _bold_ustbilgi = true : _bold_ustbilgi = false;
                    }
                    else if(altbilgi == true){
                      _bold_altbilgi == false || _bold_altbilgi == null ?
                      _bold_altbilgi = true : _bold_altbilgi = false;
                    }
                  }),
                  IconButton(icon: Icon(Icons.format_italic_sharp), onPressed: (){
                    if(ustbilgi == true){
                      _italic_ustbilgi == false || _italic_ustbilgi == null ?
                      _italic_ustbilgi = true : _italic_ustbilgi = false ;
                    }
                    else if(altbilgi == true){
                      _italic_altbilgi == false || _italic_altbilgi == null ?
                      _italic_altbilgi = true : _italic_altbilgi = false ;
                    }
                  }),
                ],
              ),
            ),
          ]
        ),
      );
    }

    AlertDialog alertDialog = new AlertDialog (
      title: Text(
        ustbilgi == true ?
          "S??nav??n??z??n ????kt?? g??r??n??m??nde en ??stte g??r??nmesini istedi??iniz notunuzu yaz??n??z. Yaz??l?? ba??l?????? haz??rlamak i??in *Yaz??l??* "
          "butonunu kullanabilirsiniz. S??nav ????kt??s?? i??in varsa yaz??l?? giri??iniz iptal edilecektir. Halihaz??rdaki ??stbilgiyi kald??rmak i??in ise ??stbilgi alan??na "
          "bo??luk b??rak??p onaylaman??z yeterlidir. En iyi g??r??n??m i??in puntoyu en fazla 16 se??menizi tavsiye ederiz."
            : altbilgi == true ? "Daha ??nceden giri?? yap??ld??ysa mevcut altbilgi, altbilgi alan??nda g??sterilmektedir. De??i??tirmek i??in yeni altbilgiyi girerek, "
            " kald??rmak i??in ise bo??luk b??rakarak onaylaman??z yeterlidir."
            : "S??nav??n??z??n ????kt??s??n?? yaz??l?? format??nda g??r??nt??lemeyi tercih ettiniz. Yaz??l??n??z??n ba??l??????n?? giriniz. Ba??l??k alt??nda Ad-Soyad, S??n??f/No ve "
            "Puan alan?? otomatik olarak gelecektir. Daha ??nce girdi??iniz ??stbilgi ve ayarlar?? silinecektir.",
          textAlign: TextAlign.justify, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      content: AltUstbilgi_YaziliAlertDialog(),
      actions: [
        MaterialButton(child: Text("Onayla", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
            onPressed: () async {

          if(ustbilgi == true){
            if(_formKey_ciktiMetni.currentState.validate()){
              _formKey_ciktiMetni.currentState.save();
              _formKey_ciktiMetni_punto.currentState.save();
              final newmetin = ciktiMetni_controller.text.trim();

              await collectionReference.doc(id_solusturulan).update({"ustbilgi": newmetin, "yazili_girildi": false, "yazili_baslik": "",
              });
            }

            if(_formKey_ciktiMetni_punto.currentState.validate()){
              _formKey_ciktiMetni_punto.currentState.save();
              String new_punto_ustbilgi = ciktiMetni_punto_controller.text.trim();
              await collectionReference.doc(id_solusturulan).update({"ustbilgi_punto": new_punto_ustbilgi,
              });
            }

            await collectionReference.doc(id_solusturulan).update({"ustbilgi_kalin": _bold_ustbilgi, "ustbilgi_italic": _italic_ustbilgi,});


            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
              action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
            Navigator.of(context, rootNavigator: true).pop("dialog");

            Navigator.pop(context);
          }
          if(altbilgi == true) {
            if(_formKey_ciktiMetni.currentState.validate()){
              _formKey_ciktiMetni.currentState.save();
              _formKey_ciktiMetni_punto.currentState.save();
              final newmetin = ciktiMetni_controller.text.trim();

              await collectionReference.doc(id_solusturulan).update({"altbilgi": newmetin,});
            }

            if(_formKey_ciktiMetni_punto.currentState.validate()){
              _formKey_ciktiMetni_punto.currentState.save();
              String new_punto_altbilgi = ciktiMetni_punto_controller.text.trim();

              await collectionReference.doc(id_solusturulan).update({"altbilgi_punto": new_punto_altbilgi,});
            }

            await collectionReference.doc(id_solusturulan).update({"altbilgi_kalin": _bold_altbilgi, "altbilgi_italic": _italic_altbilgi,});


            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
              action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
            Navigator.of(context, rootNavigator: true).pop("dialog");

            Navigator.pop(context);
          }
          if(yazili == true){
            if(_formKey_ciktiMetni.currentState.validate()){
              _formKey_ciktiMetni.currentState.save();
              final newmetin = ciktiMetni_controller.text.trim();

              if(yazili == true){
                await collectionReference.doc(id_solusturulan).update({"yazili_girildi": true, "yazili_baslik" : newmetin,
                  "ustbilgi": "", "ustbilgi_punto": "", "ustbilgi_italic": false, "ustbilgi_kalin" : false,});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                Navigator.of(context, rootNavigator: true).pop("dialog");

                Navigator.pop(context);
              }
            }
          }
        }
        ),
      ],
    );showDialog(context: context, builder: (_) => alertDialog);
*/
/*
    AlertDialog alertDialog = new AlertDialog (
      title: Text("A??a????dakilerden birini se??erek girece??iniz metnin yerini ve format??n?? belirleyiniz. Buraya yazd??????n??z metin sadece ????kt?? "
          "g??r??n??m??nde ve s??nav??n payla????ld?????? herkeste g??r??n??r. ??stbilgi ve yaz??l?? giri??i ayn?? s??nav i??in kullan??lamaz. Altbilgi giri??i ise ??stbilgi veya yaz??l?? "
          "giri??inden ba????ms??zd??r.", textAlign: TextAlign.justify,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text("Ekran boyutlar?? telefondan telefona farkl?? oldu??undan baz?? telefonlarda girilen altbilgi ????kt?? modunda g??r??nmeyebilir. Buradaki Ekran G??r??nt??s?? "
            "Alma butonu ile Telefonunuzun ekran g??r??nt??s??n?? ald????n??zda altbilgi g??r??necektir.", textAlign: TextAlign.justify,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey)),
      ),
      actions: [
        MaterialButton(
          child: Text("??stbilgi", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
          onPressed: () {
          _reklam.showInterad();

          ustbilgi = true; altbilgi = false; yazili = false;
          Navigator.of(context, rootNavigator: true).pop("dialog");

          AlertDialog alertDialog = new AlertDialog (
            title: Text("S??nav??n??z??n ????kt?? g??r??n??m??nde en ??stte g??r??nmesini istedi??iniz notunuzu yaz??n??z. Yaz??l?? ba??l?????? haz??rlamak i??in *Yaz??l??* "
                "butonunu kullanabilirsiniz. S??nav ????kt??s?? i??in varsa yaz??l?? giri??iniz iptal edilecektir. Halihaz??rdaki ??stbilgiyi kald??rmak i??in ise ??stbilgi alan??na "
                "bo??luk b??rak??p onaylaman??z yeterlidir.",
                textAlign: TextAlign.justify, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            content: AltUstbilgi_YaziliAlertDialog(),
            actions: [
              MaterialButton(child: Text("Onayla", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
                  onPressed: () async {
                    if(_formKey_ciktiMetni.currentState.validate()){
                      _formKey_ciktiMetni.currentState.save();
                      _formKey_ciktiMetni_punto.currentState.save();
                      final newmetin = ciktiMetni_controller.text.trim();

                        await collectionReference.doc(id_solusturulan).update({"ustbilgi": newmetin, "yazili_girildi": false, "yazili_baslik": "",
                        });
                    }

                    if(_formKey_ciktiMetni_punto.currentState.validate()){
                      _formKey_ciktiMetni_punto.currentState.save();
                      String new_punto_ustbilgi = ciktiMetni_punto_controller.text.trim();
                        await collectionReference.doc(id_solusturulan).update({"ustbilgi_punto": new_punto_ustbilgi,
                        });
                    }

                    await collectionReference.doc(id_solusturulan).update({"ustbilgi_kalin": _bold_ustbilgi, "ustbilgi_italic": _italic_ustbilgi,});


                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
                      action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                    Navigator.of(context, rootNavigator: true).pop("dialog");

                    Navigator.pop(context);

                  }
              ),
            ],
          );showDialog(context: context, builder: (_) => alertDialog);

        },),
        MaterialButton(
          child: Text("Altbilgi", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
          onPressed: () {
          _reklam.showInterad();

          Navigator.of(context, rootNavigator: true).pop("dialog");
          altbilgi = true; ustbilgi = false; yazili = false;

          print("altbilgi: " + altbilgi.toString());

          AlertDialog alertDialog = new AlertDialog (
            title: Text("S??nav??n??z??n ????kt?? g??r??n??m??nde en altta g??r??nmesini istedi??iniz notunuzu yaz??n??z. Halihaz??rdaki altbilgiyi kald??rmak i??in altbilgi alan??na "
                "bo??luk b??rak??p onaylaman??z yeterlidir.", textAlign: TextAlign.justify,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            content: AltUstbilgi_YaziliAlertDialog(),
            actions: [
              MaterialButton(child: Text("Onayla", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
                  onPressed: () async {
                    if(_formKey_ciktiMetni.currentState.validate()){
                      _formKey_ciktiMetni.currentState.save();
                      _formKey_ciktiMetni_punto.currentState.save();
                      final newmetin = ciktiMetni_controller.text.trim();

                      await collectionReference.doc(id_solusturulan).update({"altbilgi": newmetin,});
                    }

                    if(_formKey_ciktiMetni_punto.currentState.validate()){
                      _formKey_ciktiMetni_punto.currentState.save();
                      String new_punto_altbilgi = ciktiMetni_punto_controller.text.trim();

                      await collectionReference.doc(id_solusturulan).update({"altbilgi_punto": new_punto_altbilgi,});
                    }

                    await collectionReference.doc(id_solusturulan).update({"altbilgi_kalin": _bold_altbilgi, "altbilgi_italic": _italic_altbilgi,});


                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
                      action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                    Navigator.of(context, rootNavigator: true).pop("dialog");

                    Navigator.pop(context);
                  }
              ),
            ],
          );showDialog(context: context, builder: (_) => alertDialog);
        },),
        MaterialButton(
          child: Text("Yaz??l??", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)), onPressed: () {
          _reklam.showInterad();

          Navigator.of(context, rootNavigator: true).pop("dialog");
          altbilgi = false; ustbilgi = false; yazili = true;

          AlertDialog alertDialog = new AlertDialog (
            title: Text("S??nav??n??z??n ????kt??s??n?? yaz??l?? format??nda g??r??nt??lemeyi tercih ettiniz. Yaz??l??n??z??n ba??l??????n?? giriniz. Ba??l??k alt??nda Ad-Soyad, S??n??f/No ve "
                "Puan alan?? otomatik olarak gelecektir. Daha ??nce girdi??iniz ??stbilgi ve ayarlar?? silinecektir.", textAlign: TextAlign.justify,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            content: AltUstbilgi_YaziliAlertDialog(),
            actions: [
              MaterialButton(child: Text("Onayla", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
                  onPressed: () async {
                    if(_formKey_ciktiMetni.currentState.validate()){
                      _formKey_ciktiMetni.currentState.save();
                      final newmetin = ciktiMetni_controller.text.trim();

                      if(yazili == true){
                        await collectionReference.doc(id_solusturulan).update({"yazili_girildi": true, "yazili_baslik" : newmetin,
                          "ustbilgi": "", "ustbilgi_punto": "", "ustbilgi_italic": false, "ustbilgi_kalin" : false,});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
                          action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                        Navigator.of(context, rootNavigator: true).pop("dialog");

                        Navigator.pop(context);
                      }
                    }
                  }
              ),
            ],
          );showDialog(context: context, builder: (_) => alertDialog);
        },),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);
*/
  }

  void _takeScreenshot() async {
    final image = await _screenshotController.capture(delay: Duration(microseconds: 10));
    if (image == null ) return;

    await [Permission.storage].request();
    final time = DateTime.now().toIso8601String().replaceAll(".", "-").replaceAll(":", "-");
    final name = "screenshot_$time";
    final result = await ImageGallerySaver.saveImage(image, name: name);
    return result["filepath"];

  }

  void _a4Ayarla() async {

    int sutun_sayisi = AtaWidget.of(context).sutun_sayisi;
    double sorular_arasi_mesafe = AtaWidget.of(context).sorular_arasi_mesafe;
    double soru_ici_bosluk = AtaWidget.of(context).soru_ici_bosluk;
    double sorularin_boyutu = AtaWidget.of(context).sorularin_boyutu;
    String bosluk_txt = AtaWidget.of(context).bosluk_txt;
    String boyut_txt = AtaWidget.of(context).boyut_txt;

    Widget a4AyarlaAlertDialogContent() {
      return Container( height: 400, width: 400,
        child: ListView(
            children: [

              SizedBox(height: 10,),
              ListTile(
                title: Text("S??tun Say??s??"),
                subtitle: Text("Yandaki butonu kullanarak s??tun say??s?? se??ebilirsiniz.",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),),
                trailing: IconButton(icon: Icon(Icons.table_chart), onPressed: (){
                  AlertDialog alertDialog = new AlertDialog (
                    actions: [
                      MaterialButton( child: Text("1", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),), onPressed: (){
                        sutun_sayisi = 1;
                      },),
                      MaterialButton( child: Text("2", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),), onPressed: (){
                        sutun_sayisi = 2;
                      },),
                      MaterialButton( child: Text("3", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),), onPressed: (){
                        sutun_sayisi = 3;
                      },),
                      MaterialButton( child: Text("4", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),), onPressed: (){
                        sutun_sayisi = 4;
                      },),
                    ],
                  );showDialog(context: context, builder: (_) => alertDialog);
                }),
              ),
              SizedBox(height: 5,),
              ListTile(
                title: Text("Sorular Aras?? Mesafe"),
                subtitle: Text("Yandaki butonu kullanarak sorular aras?? mesafeyi se??ebilirsiniz.",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),),
                trailing: IconButton(icon: Icon(Icons.space_bar), onPressed: (){
                  AlertDialog alertDialog = new AlertDialog (
                    actions: [
                      Wrap(direction: Axis.horizontal, children: [
                        MaterialButton( child: Text("10", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorular_arasi_mesafe = 10;
                        },),
                        MaterialButton( child: Text("20", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorular_arasi_mesafe = 20;
                        },),
                        MaterialButton( child: Text("30", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorular_arasi_mesafe = 30;
                        },),
                        MaterialButton( child: Text("40", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorular_arasi_mesafe = 40;
                        },),
                        MaterialButton( child: Text("50", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorular_arasi_mesafe = 50;
                        },),
                      ]),
                    ],
                  );showDialog(context: context, builder: (_) => alertDialog);
                }),
              ),
              SizedBox(height: 5,),
              ListTile(
                title: Text("Soru ????i Bo??luk"),
                subtitle: Text("Yandaki butonu kullanarak soru i??i bo??luk se??ebilirsiniz.",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),),
                trailing: IconButton(icon: Icon(Icons.crop_square), onPressed: (){
                  AlertDialog alertDialog = new AlertDialog (
                    actions: [
                      Wrap(direction: Axis.horizontal, children: [
                        MaterialButton( child: Text("10", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          soru_ici_bosluk = 30;   bosluk_txt = "10";
                        },),
                        MaterialButton( child: Text("15", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          soru_ici_bosluk = 25;   bosluk_txt = "15";
                        },),
                        MaterialButton( child: Text("20", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          soru_ici_bosluk = 20;   bosluk_txt = "20";
                        },),
                        MaterialButton( child: Text("25", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          soru_ici_bosluk = 15;   bosluk_txt = "25";
                        },),
                        MaterialButton( child: Text("30", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          soru_ici_bosluk = 10;   bosluk_txt = "30";
                        },),
                      ]),
                    ],
                  );showDialog(context: context, builder: (_) => alertDialog);
                }),
              ),
              SizedBox(height: 5,),
              ListTile(
                title: Text("Sorular??n B??y??kl??????"),
                subtitle: Text("Yandaki butonu kullanarak sorular??n b??y??kl??????n?? se??ebilirsiniz.",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),),
                trailing: IconButton(icon: Icon(Icons.photo_size_select_large_rounded), onPressed: (){
                  AlertDialog alertDialog = new AlertDialog (
                    actions: [
                      Wrap(direction: Axis.horizontal, children: [
                        MaterialButton( child: Text("10", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorularin_boyutu = 50;  boyut_txt = "10";
                        },),
                        MaterialButton( child: Text("20", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorularin_boyutu = 40;  boyut_txt = "20";
                        },),
                        MaterialButton( child: Text("30", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorularin_boyutu = 30;  boyut_txt = "30";
                        },),
                        MaterialButton( child: Text("40", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorularin_boyutu = 20;  boyut_txt = "40";
                        },),
                        MaterialButton( child: Text("50", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),), onPressed: (){
                          sorularin_boyutu = 10;  boyut_txt = "50";
                        },),
                      ]),
                    ],
                  );showDialog(context: context, builder: (_) => alertDialog);
                }),
              ),
              SizedBox(height: 10,),
            ]
        ),
      );
    }

    AlertDialog alertDialog = new AlertDialog (
      title: ListTile(
        title: Column(children: [
          Text("Bilgilendirme: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
          Text("A4 format?? ayarland??. Bu formatta ekran g??r??nt??s?? yatayda ve dikeyde b??y??t??lm????t??r. Onayla tu??una basarak de??i??iklikleri uygulayabilirsiniz.",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center,),
        ] ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("Dilerseniz sorular??n yan yana ka??l?? dizilece??ini ayarlayabilir, sorular aras?? mesafeyi, soru i??i bo??lu??u ve sorunun b??y??kl??????n?? artt??r??p, "
              "azaltabilirsiniz. Herhangi bir de??i??iklik yapmazsan??z s??nav??n??z A4 ka????da ekrandaki gibi yans??t??l??r.",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
      content: a4AyarlaAlertDialogContent(),
      actions: [

        MaterialButton(child: Text("Onayla", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.black,
        )),
          onPressed: () {
            AtaWidget.of(context).sutun_sayisi = sutun_sayisi;
            AtaWidget.of(context).sorular_arasi_mesafe = sorular_arasi_mesafe;
            AtaWidget.of(context).soru_ici_bosluk = soru_ici_bosluk;
            AtaWidget.of(context).sorularin_boyutu = sorularin_boyutu;
            AtaWidget.of(context).bosluk_txt = bosluk_txt;
            AtaWidget.of(context).boyut_txt = boyut_txt;

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("s??tun say??s??: ${AtaWidget.of(context).sutun_sayisi}, "
                "sorular aras?? mesafe: ${AtaWidget.of(context).sorular_arasi_mesafe},  soru i??i bo??luk: ${AtaWidget.of(context).bosluk_txt}, "
                "sorular??n b??y??kl??????: ${AtaWidget.of(context).boyut_txt}"),
              action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
            Navigator.of(context, rootNavigator: true).pop("dialog");

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OlusturulanSinavPage(
                map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: grid_gorunum,
                collectionReference: collectionReference, storageReference: storageReference
            )));
          },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);
  }

}
