
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
            heroTag: "bildirim_msj", elevation: 20, backgroundColor: Colors.indigo, tooltip: "Okunmam???? bildirim(ler)iniz var...",
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
                    TextSpan(text: "  Ho??geldiniz  ",
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
                    TextSpan(text: AtaWidget.of(context).kullaniciadi, style: TextStyle(color: Colors.indigo,
                        fontSize: 25, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                  ]
              )),
              Text("  *Profilinize gitmek i??in T??klay??n??z", style: TextStyle(fontSize: 10, color: Colors.white)),
            ]
          ),
          onTap: (){
 //*********PROF??L SAYFASINA G??D??LECEK*******
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilPage(doc_id: doc_id,)));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
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
                          MaterialButton(child: Text("Haz??rlad??????m S??navlar??m asistan video i??in T??klay??n.", style: TextStyle(color: Colors.green),
                            textAlign: TextAlign.center,),
                            onPressed: (){
                              _launchIt("https://drive.google.com/file/d/1QG5Cdfr-7ob8jki1b54ZlrqB3M5MCp9j/view?usp=sharing");
                            },),
                          MaterialButton(child: Text("G??nderilen S??navlar asistan video i??in T??klay??n.", style: TextStyle(color: Colors.green),
                            textAlign: TextAlign.center,),
                            onPressed: (){
                              _launchIt("https://drive.google.com/file/d/1Q5GUj_mVKNrDaN5J2RAeZsfXJvl1fKSV/view?usp=sharing");
                            },),
                          MaterialButton(child: Text("Ki??ilerim asistan video i??in T??klay??n.", style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                            onPressed: (){
                              _launchIt("https://drive.google.com/file/d/1QLqFqcey17jNQcu_KdgyknpNLNBLFkGr/view?usp=sharing");
                            },),
                          Center(
                            child: Text("* ??sminize t??klayarak profil sayfan??za gidebilirsiniz.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text("* Sayfada HAZIRLADI??IM SINAVLARIM, G??NDER??LEN SINAVLAR ve K??????LER??M olmak ??zere ???? kart bulunmaktad??r. Kartlarda yap??labilecek "
                                " i??lemler hakk??nda detayl?? bilgi alabilmek i??in karta ait duyuru ikonuna bas??n??z.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text("* Her karta ??zel gruplar olu??turabilirsiniz. Olu??turdu??unuz bu gruplara karta ait ki??i/s??nav ekledi??inizde ileride bu elemanlar?? "
                                "bulman??z daha kolay olacakt??r. Grup olu??turmak i??in kartlar??n alt??nda bulunan *Grup Ekle* butonuna bas??n??z. Olu??turulan gruplar "
                                "kart??n kendi sayfas??nda g??r??nt??lenir.",
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
                tooltip: "????k???? Yap",
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
                content: Text("Ba??ar??yla ????k???? yap??ld??"),
              ));
            }),
          )
        ],
      ),
      body: ListView(
        children: [
          Padding( padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Text("**Bu sayfada son s??navlar??n??z ve t??m ki??ileriniz g??r??nt??lenir. Sizinle payla????lan veya Herkese A????k"
                " s??navlar?? g??rmek i??in S??navlar Kart??n?? sa??a kayd??r??n??z.**",
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
                                      Text("Haz??rlad??????m S??navlar??m", style: TextStyle( fontFamily: "Cormorant Garamond",
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
                                                      TextSpan(text: "S??navlar sondan ba??a do??ru s??ralanm????t??r. Haz??rlad??????n??z t??m s??navlar?? veya s??nav "
                                                          "gruplar??n??z?? g??rmek i??in ",
                                                        style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,
                                                          fontSize: 12,),),
                                                      TextSpan(text: "  *Buraya T??klay??n??z.*",
                                                          style: TextStyle(color: Colors.indigo, fontSize: 18, fontStyle: FontStyle.italic,
                                                              fontWeight: FontWeight.bold)),
                                                    ]
                                                    ), textAlign: TextAlign.justify,),
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Flexible(
                                                    child: querySnapshot.size == 0 ? Center(
                                                      child: Text("G??sterilecek herhangi bir s??nav bulunamad??.",
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
                                                                            "ba??l??kl?? s??nav??n *a????klama, *konu, *biti?? tarihi, *ders, *grup ad?? alanlar??n?? buradan "
                                                                                "d??zenleyebilirsiniz. ""S??nav??n??z??n di??er alanlar??n?? d??zenlemek yada soru eklemek "
                                                                                "i??in s??nava "
                                                                                "t??klay??n??z. ""S??nav??n??z?? payla??mak i??in *S??nav?? Payla??* butonunu kullan??n??z." :
                                                                            "ba??l??kl?? s??nav??n *a????klama, *konu, *biti?? tarihi, *ders, *grup ad?? alanlar??n?? g??ncellemek, "
                                                                                "s??nav??n??za *cevap eklemek/de??i??tirmek i??in *S??nav?? D??zenle* butonuna, ki??ileriniz ile "
                                                                                "s??nav??n??z?? "
                                                                                "payla??mak i??in *S??nav?? Payla??* butonu bas??n??z."
                                                                              ,style: TextStyle(color: Colors.black), textAlign: TextAlign.justify,),
                                                                            actions: [
                                                                              Wrap( spacing: 8,
                                                                                children: [
                                                                                  MaterialButton( color: Colors.amber,
                                                                                      child: Text("S??nav?? Sil"),

                                                                                      onPressed: () async {
                                                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
                                                                                        Text("????leminiz yap??l??yor..."),
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
                                                                                      child: Text("S??nav?? D??zenle"),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
                                                                                        Text("????leminiz yap??l??yor..."),
                                                                                          action: SnackBarAction(label: "Gizle", onPressed: () =>
                                                                                          SnackBarClosedReason.hide ),));
                                                                                        _sinaviDuzenle(map_sinav, id_sinav);
                                                                                      }),
                                                                                ],
                                                                              ),
                                                                              ElevatedButton(
                                                                                  child: RichText(text: TextSpan(
                                                                                    children: <TextSpan>[
                                                                                      TextSpan(text: "S??nav?? Payla??", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                      TextSpan(text: " / ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                                                                                          color: Colors.black )),
                                                                                      TextSpan(text: "Payla????m?? Kald??r", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                                                                        title: Text("Hi?? ki??iniz bulunamam????t??r. ??nce hesab??n??za ki??i ekleyiniz.",
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
                                                title: Text("B??LG??LEND??RME"),
                                                content: Container( height: 400,
                                                  child: SingleChildScrollView(
                                                    physics: ClampingScrollPhysics(),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        MaterialButton(child: Text("Haz??rlad??????m S??navlar??m asistan video i??in T??klay??n.",
                                                          style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                          onPressed: (){
                                                            _launchIt("https://drive.google.com/file/d/1QG5Cdfr-7ob8jki1b54ZlrqB3M5MCp9j/view?usp=sharing");
                                                          },),
                                                        Center(
                                                          child: Text("*S??navlar??n payla????ld?????? ki??iler s??navlar?? g??rebilir ve ????zebilir. S??nav sadece haz??rlay??c??s?? taraf??ndan "
                                                              "d??zenlenip, silinebilir. S??nav??n??z?? d??zenlemek, silmek, cevap eklemek/cevab?? g??ncellemek/kald??rmak veya ki??ileriniz "
                                                              "ile payla??mak i??in uzun bas??n??z. S??nava ??ift t??klad??????n??zda resim format??nda ????z??m d??k??man?? eklediyseniz bu d??k??man "
                                                              "taray??c??da g??sterilir. Belge format??ndaki ????z??mler ise taray??c??dan indirilir.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Center(
                                                          child: Text("*Herkes uygulama ??zerinden s??nav haz??rlay??p ki??ileri ile payla??abilir. Dilerseniz s??nav??n??z?? veya "
                                                              "ki??ilerinizi grupland??rabilirsiniz. S??nav??n??z herkese a????k olarak g??sterilmez.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Visibility(
                                                          child: Center(
                                                            child: Text("*Haz??r S??nav Ekleme se??ene??inde pdf, word yada resim olarak bir seferde tek bir d??k??man eklenebilir. "
                                                                "D??k??man??n ka?? sayfadan olu??tu??u ??nemli de??ildir. Her bir d??k??man i??in tek bir ????z??m/cevap ekleyebilirsiniz. "
                                                                "Birden fazla d??k??man ekleyecekseniz S??nav Olu??tur se??ene??ini kullanmal??s??n??z. ",
                                                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Visibility(
                                                          child: Center(
                                                            child: Text("*S??nav Olu??tur se??ene??inde istedi??iniz say??da soru yada s??nav?? telefonunuzun dosyalar??m klas??r??nden "
                                                                "yada kameras??ndan resim olarak ekleyebilece??iniz gibi uygulama i??inden metin olarak da girebilirsiniz. S??nav Olu??turma esnas??nda "
                                                                "dilerseniz kendi test sorunuzu da olu??turabilir ve bunu s??nav??n??za ekleyebilirsiniz.",
                                                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Visibility(
                                                          child: Center(
                                                            child: Text("Mutlu S??navlar...",
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
                                                heroTag: "s??navEkle",
                                                onPressed: () {
                                                  _reklam.createInterad();

                                                  AlertDialog alertDialog = new AlertDialog(
                                                    actions: [
                                                      RaisedButton(
                                                          color: Colors.green,
                                                          child: Text("Haz??r S??nav Ekle"),
                                                          onPressed: () async {

                                                            Navigator.of(context,rootNavigator: true).pop('dialog');
                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor"),
                                                              action: SnackBarAction(label: "Gizle", onPressed: (){
                                                                SnackBarClosedReason.hide;
                                                              }),));

                                                            await _sinavEkle();
                                                          }),
                                                      RaisedButton(
                                                          color: Colors.blue,
                                                          child: Text("S??nav Olu??tur"),
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
                                                      MaterialButton(child: Text("Haz??r S??nav Ekle asistan video i??in T??klay??n.",
                                                        style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                        onPressed: (){
                                                          _launchIt("https://drive.google.com/file/d/1QG5Cdfr-7ob8jki1b54ZlrqB3M5MCp9j/view?usp=sharing");
                                                        },),
                                                      MaterialButton(child: Text("S??nav Olu??tur asistan video i??in T??klay??n.",
                                                        style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                        onPressed: (){
                                                          _launchIt("https://drive.google.com/file/d/1QEVw8_M9vPHrxcHDRTUo1aL-ZHKHAdNW/view?usp=sharing");
                                                        },),
                                                      Text("* S??nav??n??z?? tek resim yada tek belge olarak telefonunuzdan haz??r ekleyebilir yada buradan s??nav olu??turabilirsiniz. ",
                                                        style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Text("* Al????t??rmalar??n cevap/????z??m linkini buradan girebilirsiniz. Uzun a????klamaya sahip yada g??rsel "
                                                          "cevap/????z??m eklerinizi daha sonra cevap ekleme butonundan da ekleyebilirsiniz.",
                                                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                                      ),
                                                      SizedBox(height: 20,),
                                                      Text("* A??a????daki alanlardan birini se??erek i??leme devam edebilirsiniz.",
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
                                                label: Text("S??nav Ekle", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),),
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
                                    Text("G??nderilen S??navlar", style: TextStyle( fontFamily: "Cormorant Garamond",
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
                                            label: Text("G??nderen Se??", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo)),
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
                                                    TextSpan(text: "S??navlar sondan ba??a do??ru s??ralanm????t??r. T??m s??navlar??/gruplar?? g??rmek i??in",
                                                      style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),),
                                                    TextSpan(text: "  *Buraya T??klay??n??z.*",
                                                        style: TextStyle(color: Colors.indigo, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                                  ]
                                                  ), textAlign: TextAlign.justify,),
                                                ),
                                                SizedBox(height: 10,),
                                                Flexible(
                                                  child: querySnapshot.size == 0 ? Center(
                                                    child: Text("G??sterilecek herhangi bir veri bulunamad??.",
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
                                                                    title: Text("*Hata: S??nav??n cevaplar?? kilitlidir, g??r??lemez", style: TextStyle(color: Colors.red)),
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
                                              title: Text("B??LG??LEND??RME"),
                                              content: Container( height: 400,
                                                child: SingleChildScrollView(
                                                  physics: ClampingScrollPhysics(),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      MaterialButton(child: Text("G??nderilen S??navlar asistan video i??in T??klay??n.",
                                                        style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                        onPressed: (){
                                                          _launchIt("https://drive.google.com/file/d/1Q5GUj_mVKNrDaN5J2RAeZsfXJvl1fKSV/view?usp=sharing");
                                                        },),
                                                      Center(
                                                        child: Text("* Bu kartta ki??ilerinizin sizinle payla??t?????? t??m s??navlar g??sterilmektedir. S??nav?? g??rmek, "
                                                            "????zmek, ????z??m??n??z?? silmek i??in ??zerine t??klay??n??z. S??nav??n ????z??m??n?? g??rmek i??in ??ift t??klay??n??z. Cevap kilidi "
                                                            "a????lm???? s??navlar??n ????z??mleri resim format??nda ise taray??c?? ??zerinden g??r??lebilir, belge format??nda ise taray??c?? "
                                                            "??zerinden indirilebilir. Haz??rlayan taraf??ndan cevap kilidi a????lmam???? s??navlar??n ????z??mleri g??sterilmez.",
                                                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Center(
                                                        child: Text("* S??nav??n??z??n ??zerine uzun basarak onu grupland??rabiliriniz. S??nav?? grupland??rmak ileride daha kolay bulman??za "
                                                            "yard??mc?? olacakt??r. ",
                                                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Cevap ka????d?? kilitli s??navlara kendi cevap/????z??m??n??z?? g??nerebilirisiniz ama s??nav??n cevap ka????d??n?? "
                                                              "g??remezsiniz. Bu kilidi a??ma-kapama yetkisi sadece s??nav?? haz??rlayana aittir. Cevap kilidi a????lan s??navlar??n cevap "
                                                              "ka????d?? g??r??lebilir ama cevaplayanlar art??k s??nava cevap g??nderemezler.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Tek resim olarak y??klenen s??navlar uygulama ??zerinden g??r??lebilir. Baz?? s??navlar ise pdf, word format??nda "
                                                              "haz??rlanm???? olabilir o s??navlar uygulama ??zerinden g??r??lemezler. S??nava t??klad??????n??zda taray??c??n??zdan s??nav?? indirerek "
                                                              "telefonunuzdaki ilgili uygulamada s??nav?? g??rebilirsiniz. ????z??m??n??z?? yine uygulama ??zerinden g??nderebilirsiniz.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Baz?? s??navlar birden fazla g??rsel yada metinsel soru y??klenerek olu??turulmu??tur. Bu formatta olu??turulan "
                                                              "s??navlara tek bir cevap y??klemesi yap??lamaz. Her soru i??in ayr?? ayr?? cevap/????z??m y??klemesi yapmal??s??n??z. Ayr??ca "
                                                              "??oktan se??meli test sorular?? i??in ????kk??n i??aretlenmesi ve ????z??m??n??n g??nderilmesi ayr?? i??lemlerdir.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* SINAVCIM uygulamas?? ile herkes kolayca s??nav haz??rlayabilir. Sadece s??nav ????zen olarak kalmay??n, "
                                                              "kendi s??nav??n??z?? haz??rlay??n ve ki??ileriniz ile payla????n. ",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("Mutlu S??navlar...",
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
                                              label: Text("Alan?? Temizle", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),),
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
                                      Text("Herkese A????k S??navlar", style: TextStyle( fontFamily: "Cormorant Garamond",
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
                                          child: Text("A??a????daki butonlar?? kullanarak t??m s??navlar?? yada filtrelenmi?? s??navlar?? getirebilirsiniz.",
                                            style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                        Container( height: 70, color: Colors.blue.shade100,
                                          child: MaterialButton( color: Colors.blue.shade100,
                                            child: Text("T??m S??navlar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                                child: Text("Ba??l??k", style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () {
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
                                                child: Text("Biti?? Tarihi", style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () {
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
                                              title: Text("B??LG??LEND??RME"),
                                              content: Container( height: 400,
                                                child: SingleChildScrollView(
                                                  physics: ClampingScrollPhysics(),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      MaterialButton(child: Text("Herkese A????k S??navlar asistan video i??in T??klay??n.",
                                                        style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                                                        onPressed: (){
                                                          _launchIt("");
                                                        },),
                                                      Center(
                                                        child: Text("* Bu kartta g??r??len s??navlar haz??rlayanlar?? taraf??ndan S??navc??m' ?? kullanan herkese a????lm????"
                                                            "s??navlard??r.",
                                                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Center(
                                                        child: Text("* T??m s??navlar g??r??nt??lenebilir fakat sadece haz??rlayan?? taraf??ndan ????z??m izni verilmi?? s??navlar "
                                                            "i??in haz??rlayana ????z??m g??nderilebilir.",
                                                          style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Sadece ileti??im izni verilen s??navlar??n haz??rlayan ad/soyad ve E-mail bilgileri "
                                                              "eri??ime a????kt??r.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("* Herkese A????k S??navlar ile m??mk??n oldu??unca fazla miktarda s??nav veya soruyu m??mk??n oldu??unca "
                                                              "fazla ki??iye ula??t??rmak ama??lanm????t??r.",
                                                            style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Visibility(
                                                        child: Center(
                                                          child: Text("Mutlu S??navlar...",
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
                                                heroTag: "herkeseA????kSinav_GrupEkle",
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
                                              heroTag: "has_alan??Temizle",
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
                                              label: Text("Alan?? Temizle", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),),
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
                          Text("Ki??ilerim", textAlign: TextAlign.center, style: TextStyle( fontFamily: "Cormorant Garamond",
                              color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 30),
                          ),

                          IconButton(icon: Icon(Icons.outgoing_mail, size: 30, color: Colors.indigo,), tooltip: "Mesaj G??nder",
                            onPressed: (){
                              AlertDialog alertdialog = new AlertDialog(
                                title: Text("Buradan t??m ki??ilerinize yada tek bir ki??inize mesaj g??nderebilirsiniz. Ki??ilerim sayfan??zdan "
                                    "ayr??ca grup mesaj?? da g??nderebilirsiniz. Mesajlar al??c??da bildirim ??eklinde g??r??nt??lenir."
                                    " Teknik_destek/Yorum butonunu kullanarak oylama ve yorum g??nderme "
                                    "penceresini a??abilir ve bize mesaj g??nderebilirsiniz.", textAlign: TextAlign.justify,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                content: Text("A??a????dakilerden birini se??erek i??leme devam edebilirsiniz.", textAlign: TextAlign.center,
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
                                  ElevatedButton(child: Text("Ki??ilerime Mesaj"), onPressed: (){
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
                                        TextSpan(text: "Ki??ileriniz harf s??ralamas??na g??re g??sterilmektedir. T??m ki??ilerinizi/ki??i gruplar??n??z?? g??rmek i??in ",
                                          style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),),
                                    TextSpan(text: "  *Buraya T??klay??n??z.*",
                                        style: TextStyle(color: Colors.indigo, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                                  ]
                                  ), textAlign: TextAlign.justify,),
                                ),
                                SizedBox(height: 10,),
                                Flexible(
                                  child: querySnapshot.size == 0 ? Center(
                                    child: Text("Hesab??n??za ekli hi?? ki??iniz yok.",
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

                                                    title: Text("Yapaca????n??z i??lemi se??iniz: "),
                                                    content: Text("Ki??i silme i??leminde silinen ile yeni payla????m yapamazs??n??z. Ki??i silme i??leminin ard??ndan varsa "
                                                        "onunla payla??t??????n??z s??navlar?? g??remez, s??navlar??n??za/sorular??n??za cevap g??nderemez. Siline ki??i ile yap??lan "
                                                        "eski payla????mlar silme i??leminden etkilenmez.", style: TextStyle(fontStyle: FontStyle.italic),
                                                      textAlign: TextAlign.justify,),
                                                    actions: [
                                                      ElevatedButton(
                                                        child: Text("Ki??iyi Grupland??r/ Gruptan Kald??r"),
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
                                                          child: Text("Ki??iyi Sil"),
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

                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ki??i ba??ar??yla kald??r??ld??")));
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
                                    title: Text("B??LG??LEND??RME"),
                                    content: Container( height: 400,
                                      child: SingleChildScrollView(
                                        physics: ClampingScrollPhysics(),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            MaterialButton(child: Text("Ki??ilerim asistan video i??in T??klay??n.", style: TextStyle(color: Colors.green),
                                              textAlign: TextAlign.center,),
                                              onPressed: (){
                                                _launchIt("https://drive.google.com/file/d/1QLqFqcey17jNQcu_KdgyknpNLNBLFkGr/view?usp=sharing");
                                              },),
                                            Center(
                                              child: Text("* Ki??inin ??zerine t??klayarak ki??inin g??r??lmesine izin verdi??i bilgilerine ula??abilirsiniz.",
                                                style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                                            ),
                                            SizedBox(height: 10,),
                                            Center(
                                              child: Text("* Ki??inin ??zerine uzun t??klad??????n??zda *Ki??iyi Sil* botonuna basarak ki??iyi hesab??n??zdan kald??rabilir, "
                                                  "*Ki??iyi Grupland??r* butonuna basarak herhangi bir ki??i grubunuza ekleyebilirsiniz yada ekli grubundan kald??rabilirsiniz.",
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
                                    label: Text("Ki??i Ekle", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),),
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
        title: Text("Hata: Sayfa G??r??nt??lenemiyor.", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
        content: Text("??nternet ba??lant??n??z kesilmi?? yada sayfan??n linki hatal?? girilmi?? olabilir."
          , style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,),
      ); showDialog(context: context, builder: (_) => alertDialog);
    }
  }

  _sinavEkle() async {
    AlertDialog alertDialog = new AlertDialog(title: Text("D??KKAT: "),
      content: Wrap( spacing: 4, children: [
        Text("1. Resim format??ndaki s??navlar?? tek bir g??rsel olarak ekleyiniz. Birden fazla g??rseli "
            "tek bir s??nav i??in kullanacaksan??z *S??nav Olu??tur* se??ene??ini kullan??n??z. "),
        SizedBox(height: 10,),
        Text("2. Resimden farkl?? t??rde ekledi??iniz (word, pdf gibi) s??navlar uygulama ??zerinden g??sterilmez. "
            "S??nav payla????ld?????? ki??i s??nava t??klayarak telefonuna indirebilir."),
        SizedBox(height: 10,),
        Text("3. Haz??r S??navlar i??in bir defada en fazla 10, olu??turulan s??navlardaki her bir soru i??in en fazla 5 mb b??y??kl??????nde d??k??man ekleyebilirsiniz."),
        SizedBox(height: 10,),
        Text("4. Haz??r S??navlar i??in .jpg, .jpeg, .png, .doc, .docx, .pdf uzant??l?? dosyalar??; Olu??turulan s??navlar i??in ise .jpg, .jpeg, .png uzant??l?? dosyalar?? "
            "y??kleyebilirsiniz."),
        ],
      ),
      actions: [
      ElevatedButton(
          child: Text("S??nav Ekle"),onPressed: () async {
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
                                labelText: "S??nav??n??za ba??l??k giriniz."),
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {
                                return "ba??l??k girmeniz gerekmektedir.";
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
                                labelText: "S??nav??n??z??n konusunu giriniz."),
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
                                labelText: "S??nav??n??z??n dersini giriniz."),
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
                                labelText: "S??nav??n??z??n puan??n?? giriniz."),
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
                                labelText: "S??nav??n??z??n bitis tarihini giriniz."),
                            style: TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {
                                return "biti?? tarihi girmeniz gerekmektedir.";
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
                                  labelText: "S??nav??n??za cevap linkini yada metnini girebilirsiniz."),
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
                                  labelText: "S??nav??n??z i??in a????klama girebilirsiniz."),
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 15),
                              validator: (String PicName) {
                                if (PicName.isEmpty) {
                                  return "A????klama girilmeyecektir.";
                                }
                                return null;
                              }),
                        ),
                      ]),
                    )),
                SizedBox(height: 10,),
                Text(
                  "**D??k??man??n y??klenme s??resi boyutuna ve internet h??z??n??za ba??l??d??r.**",
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
                  " isimli dosya y??klenecektir."),
              content: _uploadImageAlertDialog(),
              actions: [
                GestureDetector(onDoubleTap: () {},
                  child: ElevatedButton(
                    child: Text("Y??kle"),
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
                            .child("sinavlar").child("hazir_sinavlar").child(imageFileName).child("s??nav_gorseli  " + imageFileName);

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
                          content: Text("S??nav ba??ar??yla eklendi"),
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
          title: Text("Dosya ??ok b??y??k. En fazla 10 mb b??y??kl??????nde dosya se??iniz.", style: TextStyle(color: Colors.red,
                  fontSize: 20, fontWeight: FontWeight.bold)),
        );
        showDialog(context: context, builder: (_) => alertDialog);
      }
    } else {
      AlertDialog alertDialog = new AlertDialog (
        title: Text("Yanl???? uzant??l?? bir dosya se??tiniz. L??tfen .jpg, .jpeg, .png, .doc, .docx, .pdf uzant??ya sahip bir dosya se??iniz.",
            style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
      );
      showDialog(context: context, builder: (_) => alertDialog);
    }
    } else {
      // User canceled the picker
    }
  }

  //**** SINAVA G??RSEL CEVAP GET??RME****
  Future imageFromGallery(dynamic map_sinav, dynamic id_sinav) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    _imageSelected = image;
//    setState(() {});
    uploadImage(map_sinav, id_sinav);

  }

  //**** SINAVA G??RSEL CEVAP EKLEME****
  void uploadImage(dynamic map_sinav,dynamic id_sinav) async {

    Widget _uploadImageAlertDialog() {
      return Container(
        height: 500, width: 400,
        child: Column(children: [
          Flexible(
            child: Container(
                child: _imageSelected == null
                    ? Center(
                    child: Text("Resim se??ilmedi. Y??kleme yap??lmas?? yeniden resim se??imi yap??lmal??d??r.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ))
                    : Image.file(_imageSelected, fit: BoxFit.contain,
                )),
          ),
          SizedBox(height: 20,),
          Text("**Resmin y??klenme s??resi boyutuna ve internet h??z??n??za ba??l??d??r.**",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.orange),
            textAlign: TextAlign.center,
          ),
        ]),
      );
    }

    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text("Resim Y??kleme", style: TextStyle(color: Colors.green),
        ),
        content: _uploadImageAlertDialog(),
        actions: [
          GestureDetector(onDoubleTap: (){},
            child: ElevatedButton(
              child: Text("Y??kle"),
              onPressed: () async {
                if (_imageSelected == null) {return null;
                } else {
                    if(map_sinav["olusturulanmi"] == true) {
                      final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                          .child("sinavlar").child("olusturulan_sinavlar").child(map_sinav["baslik"]).child("s??nav??n cevap gorseli_"+map_sinav["baslik"]);

                      await ref.putFile(_imageSelected);
                      var downloadUrl = await ref.getDownloadURL();
                      String url = downloadUrl.toString();

                      await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                          .update({"gorsel_cevap": url, "metinsel_cevap": ""});
                    }
                    else {
                      final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                          .child("sinavlar").child("hazir_sinavlar").child(map_sinav["baslik"]).child("s??nav??n cevap gorseli_"+map_sinav["baslik"]);

                      await ref.putFile(_imageSelected);
                      var downloadUrl = await ref.getDownloadURL();
                      String url = downloadUrl.toString();

                      await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                          .update({"gorsel_cevap": url, "metinsel_cevap": ""});
                    }


                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevap ba??ar??yla eklendi"), action: SnackBarAction(
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
                  Text("Bu s??navda her hangi bir g??rsel bulunamam????t??r. Resim format??nda olmayan s??navlar uygulamada g??sterilmez. *S??nava Git* butonu ile taray??c??n??z "
                      "ile s??nav?? indirip ????zebilir, *Cevab??n?? G??nder* butonunu kullanarak ????z??m??n??z?? g??nderebilirsiniz.",
                      style: TextStyle(color: Colors.lightBlue, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 20,),
                  Text("*S??nava Git* butonu ile herhangi bir indirme olmuyorsa s??nav sisteme y??klenmemi?? yada ba??ka bir sorun ya??anm???? olabilir.",
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
                        TextSpan(text: "Ba??l??k:  "),
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
                  tooltip: map_sinav["kilitli"] == true ? "Cevap kilitlidir." : "Cevap kilidi a????lm????t??r.",
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
                        content: Text(" ????lemi yapmaya yetkiniz yok."),);
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
                        child: Text("S??nava Git"),
                        onPressed: () {
                          _launchIt(map_sinav["gorsel"]);

                          Navigator.of(context, rootNavigator: true).pop('dialog');
                        }),
                Visibility(visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? true : false, child: SizedBox(width: 20,)),
                Visibility( visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? true : false,
                  child: ElevatedButton(
                      child: Text("G??nderilen Cevaplar"),
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
                      child: Text("Cevab?? G??r"),
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
                          child: Text("Cevab??n?? G??nder"),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????leminiz yap??l??yor..."),
                              action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                            ogrenci_cevapEkle(id_sinav, map_sinav);
                          }),
                        ),
                  ),
                ),
                Visibility( visible: AtaWidget.of(context).kullaniciadi == map_sinav["hazirlayan"] ? false : true,
                  child: Visibility( visible: _doc_baslik != null ? true : false,
                    child: ElevatedButton(
                        child: Text("Kendi Cevab??n?? G??r"),
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
            child: Text("*S??nav??n ????z??m?? link olarak verilmi??se taray??c??da da a??abilirsiniz.",
              style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic, fontSize: 15),
              textAlign: TextAlign.justify,
            )),
        content: map_sinav["gorsel_cevap"] == "" && map_sinav["metinsel_cevap"] == "" ? Text("CEVAP DAHA EKLENMEM????T??R !",
          style: TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.bold),)
            : SetUpAlertDialogContainer(),
        actions: [
          ElevatedButton(child: Text("Taray??c??da A??"),
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
                          child: Text("De??i??mesini istedi??iniz alanlara yeni verileri yaz??n??z ve onay butonuna"
                              " t??klay??n??z. Yeni veri girmedi??iniz alanlar aynen kalacakt??r. S??nav??n ba??l?????? "
                              "de??i??tirilemez. D??zenleme i??lemeini sonlandrmak i??in *Onay* butonuna bas??n??z.",
                            style: TextStyle(color: Colors.red, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                          SizedBox(height: 10,),
                          Form(key: _formKey_ders,
                            child: TextFormField(
                                controller: _dersci,
                                decoration: InputDecoration(border: OutlineInputBorder(),
                                    labelText: "S??nav??n??z??n dersini giriniz."),
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                validator: (String PicName) {
                                  if (PicName.isEmpty) {return "Alan de??i??meyecektir.";
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
                                    labelText: "S??nav??n??z??n konusunu giriniz."),
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                validator: (String PicName) {
                                  if (PicName.isEmpty) {return "Alan de??i??meyecektir.";
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
                                    labelText: "S??nav??n??za a????klama giriniz."),
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                validator: (String PicName) {
                                  if (PicName.isEmpty) {return "Alan de??i??meyecektir.";
                                  } return null;
                                }),
                          ),
                          SizedBox(height: 10,),
                          Form(key: _formKey_bitis_tarihi,
                            child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _bitis_tarihci,
                                decoration: InputDecoration(border: OutlineInputBorder(),
                                    labelText: "S??nav??n??z??n biti?? tarihini giriniz."),
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                validator: (String PicName) {
                                  if (PicName.isEmpty) {return "Alan de??i??meyecektir.";
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
                                    if (PicName.isEmpty) {return "Alan de??i??meyecektir.";
                                    } return null;
                                  }),
                            ),
                          ),
                          SizedBox(height: 15,),
                          GestureDetector(
                            child: Text(" Cevab?? anahtar??n?? resim olarak eklemek i??in t??klay??n??z.",
                              style: TextStyle(fontStyle: FontStyle.italic,
                                  color: Colors.blueGrey),),
                            onTap: (){
                              imageFromGallery(map_sinav, id_sinav);
                            },),
                          SizedBox(height: 15,),
                          GestureDetector(
                            child: Text(" Cevab?? anahtar??n?? belge olarak eklemek i??in t??klay??n??z.",
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
                                      title: Text(map_sinav["baslik"] + " i??in a??a????daki belge cevap olarak "
                                          "y??klenecektir.", style: TextStyle( color: Colors.lightGreen,
                                          fontSize: 15, fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),),
                                      content: Text(_file.name+"."+ _file.extension),
                                      actions: [
                                        ElevatedButton(
                                          child: Text("Y??kle"),
                                          onPressed: () async {
                                            if (map_sinav["olusturulanmi"] == true) {
                                              final Reference ref = await FirebaseStorage.instance.ref()
                                                  .child("users").child(AtaWidget.of(context).kullaniciadi)
                                                  .child("sinavlar").child("olusturulan_sinavlar").child(map_sinav["baslik"])
                                                  .child("S??nav??n cevap_belgesi "+map_sinav["baslik"]);

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
                                      title: Text("Dosya ??ok b??y??k. En fazla 10 mb b??y??kl??????nde dosya se??iniz.", style: TextStyle(color: Colors.red,
                                          fontSize: 20, fontWeight: FontWeight.bold)),
                                    );
                                    showDialog(context: context, builder: (_) => alertDialog);
                                  }
                                } else {
                                  AlertDialog alertDialog = new AlertDialog (
                                    title: Text("Yanl???? uzant??l?? bir dosya se??tiniz. L??tfen .jpg, .jpeg, .png, .doc, .docx, .pdf uzant??ya sahip bir dosya se??iniz.",
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
          child: Text("${map_sinav["baslik"]} D??zenleme",
            style: TextStyle(color: Colors.green),
          ),
        ),
        content: _uploadImageAlertDialog(),
        actions: [
          MaterialButton(
            child: Text("S??nav?? Grupland??r/ Gruptan Kald??r", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,
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

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("De??i??iklikler kaydedilmi??tir."),));
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
      content: Text("*Anlad??m* butonuna bast??????n??zda otomatik olarak galerinizden resim se??meye y??nlendirileceksiniz. Resim se??meden ????z??m??n??z?? sadece metin girerek "
          "a????klamay?? tercih edebilirsiniz. Matematik gibi i??lemlerin oldu??u dersler i??in ????z??m??n??z??n resmini eklemenizi ??neririz. Test sorular??nda ????kk?? i??aretlemek "
          "i??in *????klar?? G??r* butonunu t??klay??n??z"
        , textAlign: TextAlign.justify,),
      actions: [
        MaterialButton(
            child: Text("Anlad??m", style: TextStyle(color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.bold,
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
                      child: Text("Resim se??ilmedi. Cevab??n??za g??rsel eklenmeyecektir.",
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
                Text("** A????klaman??z?? daha b??y??k g??rmek i??in ??zerine ??ift t??klay??n??z.**",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.black),
                  textAlign: TextAlign.center,),
                SizedBox(height: 10,),
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
          Builder(
            builder: (context)=> GestureDetector(onDoubleTap: (){},
              child: RaisedButton(
                child: Text("Y??kle"), color: Colors.green,
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevab??n??z ba??ar??yla g??nderildi"),
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
                return Center(child: Text("????z??m??n??ze ait her hangi bir g??rsele ula????lamam????t??r.",
                  style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),),);},),
          )
      );
    }
    showDialog(context: context, builder: (_) {
      return AlertDialog(backgroundColor: Color(0xAA304030),
        title: Center(
            child: Text(map_sinav["baslik"] + " i??in ????z??m??n??z: ", textAlign: TextAlign.center,
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
          Visibility( visible: map_sinav["kilitli"] == true ? false : _doc_puan == null || _doc_puan == -1 ? false : true,
            child: RichText(text: TextSpan(
              style: TextStyle(), children: <TextSpan> [
                TextSpan(text: "Puan??n??z: ", style: TextStyle(color: Colors.lightBlueAccent, fontSize: 13)),
                TextSpan(text: _doc_puan.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ]
            ),),
          ),
          SizedBox(width: 20,),
          Visibility( visible: _doc_gorsel == "" || _doc_gorsel == " " || _doc_gorsel == null ? false: true,
            child: RaisedButton(color: Colors.blueAccent, child: Text("G??rseli A??"),
                onPressed: () {_launchIt(_doc_gorsel);
                }),
          ),
          ElevatedButton(
            child: Text("Cevab??n?? Sil"),
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

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),));
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
                                    title: Text("S??nav zaten ki??i ile payla????lm????. Silmek i??in ki??iyi yana kayd??r??n.",
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                  ); showDialog(context: context, builder: (_) => alertDialog);
                                } else {

                                  if (kisi_pasif == true) {
                                    AlertDialog alertdialog = new AlertDialog(
                                      title: Text("Bu kullan??c?? hesab??n?? pasifle??tirdi??i i??in onunla herhangi bir payla????mda bulunamazs??n??z.",
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

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("S??nav ba??ar??yla payla????ld??")));
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
              Text("S??nav?? Payla??", style: TextStyle(color: Colors.green),),
              Wrap(
                children: [
                  Text("* T??m ki??ileriniz g??sterilmektedir. Halihaz??rda s??nav??n payla????ld?????? ki??iler yan??nda i??aretli gelmi??tir. Bu ki??iler ile payla????m?? sonland??rmak "
                      "i??in yana kayd??r??n??z. Di??er ki??iler ile payla????m yapmak i??in ??zerine t??klaman??z yeterlidir. Listeyi g??ncellemek i??in yenile butonuna bas??n??z.",
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  Divider(thickness: 5, color: Colors.white,),
                  Text("** T??M K??????LER??M sayfas??ndan gruplar?? getirerek s??nav??n??z?? se??ti??inizi grup ile de payla??abilirsiniz.",
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  Divider(thickness: 5, color: Colors.white,),
                  Text("*** HerkeseA????k butonuna basarak s??nav??n??z?? herkese a??abilirsiniz. Herkese A????k s??navlar uygulama ??zerinden herkes??e g??r??nt??leyebilir, "
                      "indirilebilir yada izninize ba??l?? olarak ????z??m g??nderebilir. Herkese a????k s??navlar listenizde olmayan ki??iler taraf??ndan tan??nman??z a????s??ndan "
                      "??nemlidir.",
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ]),
        content: setupAlertDialogContainer(),
        actions: [
          Container( width: 120,
            child: ElevatedButton( child: Text( map_sinav["herkeseAcik"] == true ? "Herkese A??ma" : "HerkeseA??"), onPressed: () async {
              has_ayarlama(map_sinav, id_sinav);
            },),
          ),
          Container( width: 120,
            child: ElevatedButton( child: Text("T??mKi??ilerim/Gruplar??m"), onPressed: () {
              AlertDialog alertdialog = new AlertDialog (
                title: Text("Dikkat: "),
                content: Text("S??nav??n t??m ki??iler yada belli bir ki??i grubu ile payla????labilme i??lemi *T??m Ki??ilerim sayfas??ndan yap??labilmektedir.",
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("S??nav??n herkese a????k ??zelli??i kapat??ld??. S??nav??n??z sadece ki??ilerim listenizden "
          "payla??t??klar??n??z i??in g??r??lebilir."), action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
      Navigator.of(context, rootNavigator: true).pop("dialog");
    } else {
      Navigator.of(context, rootNavigator: true).pop("dialog");
      AlertDialog alertdialog = new AlertDialog(
        title: Scrollbar(
          child: Container(height: 250,
            child: SingleChildScrollView( physics: ClampingScrollPhysics(),
              child: Column(children: [
                Text("D??KKAT: "),
                SizedBox(height: 10,),
                Text("* S??nav??n??z?? herkese a??mak i??in a??a????daki izinleri yan??tlaman??z ve Onayla butonuna t??klaman??z gerekmektedir.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                SizedBox(height: 10,),
                Text("1) S??nav??n??z?? herkese a??may?? tercih ettiniz. S??navc??m uygulamas??na sahip herkes ki??i listenizde olmasa da bu s??nav??n??za eri??ebilecektir.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                SizedBox(height: 10,),
                Text("2) Listenizde olmayan bu ki??ilere a??a????daki izinleri vermeniz durumunda size ????z??m g??nderebilecekler veya sizinle ileti??ime "
                    "ge??ebileceklerdir. Aksi takdirde belirtilen i??lemleri yapamazlar. Verilen izinler birbirinden ba????ms??zd??r.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),),
                SizedBox(height: 10,),
                Text("3) ????z??m G??nderme izni verdi??inizde herkesin size ????z??m g??ndermesine izin vermi?? olursunuz. Bu durum s??nav??n??z??n ge??erlili??ini ve "
                    "kalitesini daha geni?? bir kitleden gelen ????z??mler ile ??l??menize olanak verir. S??nav??n??z belli say??da bir grup i??in ??zelle??tirilmi?? "
                    "bir s??nav ise bu se??ene??e izin vermeniz ??nerilmez.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),),
                SizedBox(height: 10,),
                Text("4) ??leti??im izni verdi??inizde s??nav?? g??r??nt??leyen herkes i??in AdSoyad ve Emailiniz de g??r??lebilir olacakt??r. Bu durumda tan??d??????n??zdan "
                    "??ok daha fazla ki??iyle ba??lant??l?? olabilir, yeni f??rsatlar elde edebilirsiniz. Bu izin ile Profil Sayfan??z??n g??r??nt??lenmesi aras??nda "
                    "bir ili??ki yoktur. Profil Sayfan??z ve oradaki bilgilerin gizlili??i ayn?? ??ekilde devam edecektir.",
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
                  title: Text("S??nav??n??za herkes ????z??m g??ndersin mi?", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
                  subtitle: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    MaterialButton(child: Text("EVET", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                        onPressed: () {
                          has_cozum_izin = true;
                          Shas_cozum_izin = "evet";
                        }),
                    MaterialButton(child: Text("HAYIR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                        onPressed: () {
                          has_cozum_izin = false;
                          Shas_cozum_izin = "hay??r";
                        }),
                  ],),
                ),
                ListTile(
                  title: Text("AdSoyad ve Email adresiniz s??navda g??r??ns??n m???", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
                  subtitle: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    MaterialButton(child: Text("EVET", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                        onPressed: () {
                          has_iletisim_izin = true;
                          Shas_iletisim_izin = "evet";
                        }),
                    MaterialButton(child: Text("HAYIR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                        onPressed: () {
                          has_iletisim_izin = false;
                          Shas_iletisim_izin = "hay??r";
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
                title: Text("??zin sorular??ndan en az birini yan??tlamad??n??z", style: TextStyle(color: Colors.red)),
              ); showDialog(context: context, builder: (_) => alertDialog);
            } else {
              await FirebaseFirestore.instance.collection("users").doc(doc_id).collection("sinavlar").doc(id_sinav.toString())
                  .update({"herkeseAcik" : true, "mail": AtaWidget.of(context).kullanicimail, "id_sinav": id_sinav, "id_hazirlayan" : doc_id,
                "has_cozum_izin": has_cozum_izin, "has_iletisim_izin": has_iletisim_izin, "has_gruplar": has_gruplar,
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("S??nav??n??z herkese a????ld??. S??nav??n??z??n ????z??mm izni "
                  "*${Shas_cozum_izin.toUpperCase()} ve iletisim izni *${Shas_iletisim_izin.toUpperCase()} olarak ayarland??."),
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
                  child: Text("Hesab??n??za ekli hi?? ki??iniz bulunamad??. ??nce ki??i ekleyiniz.",
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
                                    content: Text("isimli g??ndereni se??tiniz."),
                                    actions: [
                                      MaterialButton(
                                        child: Text("S??navlar??n?? Getir", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 20)),
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
                Text("G??nderen Se??", style: TextStyle(color: Colors.green),),
                Text("T??m ki??ileriniz g??sterilmektedir. Se??ti??iniz g??nderenin sizinle payla??t?????? s??navlar?? g??receksiniz. G??nderen se??mek i??in ??zerine t??klay??n??z.",
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
                          labelText: "Ki??inin kullaniciadini giriniz."),
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
                          labelText: "Ki??inin Email adresini giriniz."),
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
       title: Text("Ki??ilerime Ekle"),
       content: __kisiEkleAlertDialog(),
       actions: [
         ElevatedButton(
           child: Text("Ki??iyi Ekle"),
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
                         print("kar????da ki??i var");
                         karsida_kisi_var = true;
                       }
                     }));
                   }));

               if(kisiKontrol_kullaniciadi != kullaniciadi){
                 AlertDialog alertDialog = new AlertDialog(
                   title: Text("Girilen bilgilerle sisteme kay??tl?? ki??i bulunamad??.",
                     style: TextStyle(color: Colors.red),),
                   content: Text("Ki??inin uygulamaya kaydoldu??undan yada girdi??iniz bilgilerin do??rulu??undan emin olunuz. Sistem b??y??k k??????k harf ve bo??luklara duyarl??d??r."),
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
                     title: Text("Bu mail adresi ile ki??ilerinize kay??tl?? bir kullan??c?? mevcuttur. Bilgilerin do??rulu??undan emin olunuz.",
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

                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(kullaniciadi + " ki??ilerinize ba??ar??yla eklenmi??tir."),
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
                          labelText: "Grup ad??n?? giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String value) {
                        if (value.isEmpty) {return "Alan bo?? b??rak??lamaz.";
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
                            labelText: "Grup a????klamas?? girebilirsiniz."),
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                        validator: (String value) {
                          if (value.isEmpty) {return "Grubunuz i??in a????klama girilmemi??tir.";
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
          Text("A????klama alan?? zorunlu de??ildir.", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),),
        ]),
        content: __grupEkleAlertDialog(),
        actions: [
          ElevatedButton(
            child: Text("Grubu olu??tur"),
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
                    title: Text("Ayn?? isimle olu??turulmu?? bir grup mevcuttur. L??tfen farkl?? bir isim ile grubu yeniden olu??turunuz.", style: TextStyle(color: Colors.red),),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                  }
                  else{
                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("kisilerim")
                        .add({"grup_adi": grupAdi, "grupAciklamasi": grupAciklamasi, "tarih": DateTime.now().toString(), "kullaniciadi": "", "mail": ""});

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz ba??ar??yla olu??turulmu??tur")));
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
                    title: Text("Ayn?? isimle olu??turulmu?? bir grup mevcuttur. L??tfen farkl?? bir isim ile grubu yeniden olu??turunuz.", style: TextStyle(color: Colors.red),),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                  }
                  else{
                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("sinavlar")
                        .add({"grup_adi": grupAdi, "grupAciklamasi": grupAciklamasi, "tarih": DateTime.now().toString(), "baslik": "", "konu": ""});

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz ba??ar??yla olu??turulmu??tur")));
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
                    title: Text("Ayn?? isimle olu??turulmu?? bir grup mevcuttur. L??tfen farkl?? bir isim ile grubu yeniden olu??turunuz.", style: TextStyle(color: Colors.red),),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                  }
                  else{
                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("paylasilan_sinavlar_gruplari")
                        .add({"grup_adi": grupAdi, "grupAciklamasi": grupAciklamasi, "tarih": DateTime.now().toString(), });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz ba??ar??yla olu??turulmu??tur")));
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
                    title: Text("Ayn?? isimle olu??turulmu?? bir grup mevcuttur. L??tfen farkl?? bir isim ile grubu yeniden olu??turunuz.", style: TextStyle(color: Colors.red),),
                  ); showDialog(context: context, builder: (_) => alertDialog);
                  }
                  else{
                    await FirebaseFirestore.instance.collection("users").doc(doc_id.toString()).collection("herkeseAcik_sinavlar_gruplari")
                        .add({"grup_adi": grupAdi, "grupAciklamasi": grupAciklamasi, "tarih": DateTime.now().toString(), });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Grubunuz ba??ar??yla olu??turulmu??tur")));
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
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
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
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
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
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                Navigator.of(context, rootNavigator: true).pop("dialog");

                              }
                              else if (has_gruplandir == true) {
                                if(has_gruplar.contains(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi)){
                                  has_gruplar.remove(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                  await collectionReference_has.doc(id_gruplandir).update({"has_gruplar": has_gruplar});

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                  Navigator.of(context, rootNavigator: true).pop("dialog");
                                }
                                else {
                                  has_gruplar.add(map_gruplar["grup_adi"] + "/" + AtaWidget.of(context).kullaniciadi);
                                  await collectionReference_has.doc(id_gruplandir).update({"has_gruplar": has_gruplar});

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("????lem ba??ar??l??"),
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
                Text("Listelene S??navlar??n??z i??in olu??turdu??unuz t??m gruplar??n??z g??sterilmektedir. Hali haz??rda se??ili s??nav ekledi??iniz grup varsa yan??nda tik i??areti "
                    "ile belirtilmi??tir. S??nav?? bir gruba eklemek yada ekli gruptan kald??rmak i??in grubun ??zerine t??klaman??z yeterlidir. "
                    "Bu i??lem i??in ayr?? bir onay istenmeyecektir.",
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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("S??nav ba??ar??yla silindi"),));
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
            .child(map_sinav["baslik"]).child("sorular").child(sorular[i]).child("????klar").listAll().then((value) => value.items.forEach((element) {element.delete();}));

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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("S??nav ba??ar??yla silindi"),));
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
              TextSpan(text: "S??navlar sondan ba??a do??ru s??ralanm????t??r. T??m s??navlar??/gruplar?? g??rmek i??in",
                style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),),
              TextSpan(text: "  *Buraya T??klay??n??z.*",
                  style: TextStyle(color: Colors.indigo, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
            ]
            ), textAlign: TextAlign.justify,),
          ),
          SizedBox(height: 10,),
          Flexible(
            child: AtaWidget.of(context).herkeseAcik_sinavlar.length == 0 ? Center(
              child: Text("G??sterilecek herhangi bir veri bulunamad??.",
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
                              title: Text("*Hata: S??nav??n cevaplar?? kilitlidir, g??r??lemez", style: TextStyle(color: Colors.red)),
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
      title: Text("Herkese a????k olarak payla????lan t??m s??navlar hi?? bir filtreye u??ramadan g??sterilecektir. ??zel bir arama "
          "i??in a??a????daki filterleri kullanman??z ??nerilir.",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),
      actions: [
        ElevatedButton(child: Text("T??m S??navlar?? Getir"), onPressed: () async {
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
      title: Text("Arama yapmak istedi??iniz dersin yada alan??n ad??n?? giriniz. Alan b??y??k-k??????k harf veya bo??luklara "
          "duyarl??d??r.",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: has_controller,
          decoration: InputDecoration(
            labelText: filtre == "baslik" ? "Ba??l?????? giriniz" : filtre == "konu" ? "konuyu giriniz"
                : filtre == "bitis_tarihi" ? "Biti?? tarihini giriniz" : "Ders/Alan ad??n?? giriniz",
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
              filtre == "baslik" ? "Ba??l?????? * ${has_controller.text.trim()}* olan herkese a????k s??navlar getirilecektir. "
                  : filtre == "konu" ?  "Konusu * ${has_controller.text.trim()}* olan herkese a????k s??navlar getirilecektir. "
                  : filtre == "bitis_tarihi" ? "Biti?? tarihi * ${has_controller.text.trim()}* olan herkese a????k s??navlar getirilecektir. "
                  : "Ders/Alan ad?? * ${has_controller.text.trim()}* olan herkese a????k s??navlar getirilecektir. " ,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),
            actions: [
              ElevatedButton(child: Text("S??navlar?? Getir"), onPressed: () async {
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
                child: Text("G??R????LER??N??Z B??Z??M ??????N DE??ERL??D??R...", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold,
                    fontSize: 15, decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.green),),
              ),
              SizedBox(height: 10,),
              ListTile(
                title: Text("G??nderdi??iniz her geri bildirimi kendimizi geli??tirmek i??in bir f??rsat olarak g??r??yoruz. Bize Google Play Store "
                    "??zerinden puan verebilir ve yorum yazabilirsiniz. Dilerseniz uygulama ??zerinden sadece bizim g??rece??imiz geri bildiriminizi "
                    "g??nderebilirsiniz.",
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
                        title: Text("Play Store' da geri bildirim vererek geli??memize katk??da bulundu??unuz i??in te??ekk??r ederiz.",
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
                  child: Text("Bize uygulama ile ilgili deneyimlerinizi, g??r????, ele??tiri ve ??nerilerinizi i??eren geri bildirim g??nderebiliriniz: ",
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
                        labelText: "Yorumunuzu buraya yaz??n??z.",
                        hintText: "Buraya yaz??d??????n??z yorumunuz gizlidir, sadece bizim taraf??m??zdan g??r??nt??lenir.",
                        hintStyle: TextStyle(fontSize: 10),
                        border: OutlineInputBorder()
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    validator: (value) {
                      if(value.isEmpty){ return "Yorum yaz??lmad??."; }
                      else { return null; }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: FloatingActionButton.extended( elevation: 20,
                  label: Text("Yorumunu Bize G??nder"), icon: Icon(Icons.send, color: Colors.greenAccent,), heroTag: "oylamayiGonder_buton",
                  onPressed: () async {
                    if(_formKey_oylama.currentState.validate()){
                      _formKey_oylama.currentState.save();
                      List<dynamic> alicilar_mail = ["yoneticikullanici1@gmail.com"];
                      List<dynamic> alicilar_ad = ["Y??netici Kullan??c??"];
                      List<dynamic> okuyanlar = [];

                      await FirebaseFirestore.instance.collection("bildirimler").add({ "tarih": DateTime.now().toString(), "alicilar_mail" : alicilar_mail,
                        "gonderen_adi" : AtaWidget.of(context).kullaniciadi, "gonderen_mail" : AtaWidget.of(context).kullanicimail, "alicilar_ad" : alicilar_ad,
                        "konu" : "${AtaWidget.of(context).kullaniciadi}' n??n geri bildirimi_${giris_sayisi}", "mesaj" : _controller_oylama.text.trim(),
                        "okuyanlar" : okuyanlar,
                      });
                      Navigator.of(context, rootNavigator: true).pop("dialog");
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                          SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: gonderen_secildi,)));
                      AlertDialog alertDialog = new AlertDialog(
                        content: ListTile(
                          leading: Icon(Icons.check_circle, color: Colors.blue, size: 30,),
                          title: Text("Geri bildiriminiz i??in te??ekk??r ederiz. Geri Bildiriminize g??nderilen mesajlar b??l??m??nden ula??abilirsiniz. Bildiriminiz incelenerek "
                              "size en yak??n zamanda d??n???? sa??layaca????z. Google Play Store ??zerinden de oylamay?? ve yorum yazmay?? unutmay??n.",
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
                        child: MaterialButton( child: Text("Bir daha G??sterme", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 20,
                          fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.red, decorationThickness: 3,),),
                          onPressed: (){
                            FirebaseFirestore.instance.collection("users").doc(id).update({"oylama_gosterme" : true});

                            Navigator.of(context, rootNavigator: true).pop("dialog");
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
                            AlertDialog alertDialog = new AlertDialog(
                              content: ListTile(
                                leading: Icon(Icons.info, color: Colors.blue, size: 30,),
                                title: Text("Bu pencereyi bir daha g??rmeyeceksin. Geri bildirim g??ndermek yada her hangi bir sorunda bizimle "
                                    "ileti??ime ge??mek istersen *K??????LER??M alan??ndan *MESAJ_G??NDER ikonuna t??klad??ktan sonra *TEKN??K_DESTEK/YORUM se??ene??ini se??erek bize "
                                    "mesaj atabilir yada E-mail adresimize mail atabilirsin.",
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                              ),
                            ); showDialog(context: context, builder: (_) => alertDialog);
                          },
                        ),
                      ),
                    ),
                    Align( alignment: Alignment.centerRight,
                      child: MaterialButton( child: Text("??imdi De??il", style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic, fontSize: 20,
                        fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.orange, decorationThickness: 3,),),
                        onPressed: (){
                          Navigator.of(context, rootNavigator: true).pop("dialog");
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                              SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
                          AlertDialog alertDialog = new AlertDialog(
                            content: ListTile(
                              leading: Icon(Icons.info, color: Colors.blue, size: 30,),
                              title: Text("Bu pencereyi ileri bir tarihte bir daha g??receksin. O zaman gelinceye kadar geri bildirim g??ndermek yada her hangi bir "
                                  "sorunda bizimle ileti??ime ge??mek istersen *K??????LER??M alan??ndan *MESAJ_G??NDER ikonuna t??klad??ktan sonra *TEKN??K_DESTEK/YORUM "
                                  "se??ene??ini se??erek bize mesaj atabilirsin.",
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
                            Text("g??nderen: ", style: TextStyle(fontStyle: FontStyle.italic,)),
                            Text(okunmayan_bildirimler[index]["gonderen_adi"], style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),

                          ] ),
                      onTap: () async {
                        await FirebaseFirestore.instance.collection("bildirimler").doc(okunmayan_bildirimler_id[index]).get()
                            .then((bildirim) {
                              bildirimi_okuyanlar = bildirim.get("okuyanlar");
                              if(bildirimi_okuyanlar.contains(AtaWidget.of(context).kullanicimail)){
                                print("bildirim zaten okundu olarak i??aretlendi");
                              } else {
                                bildirimi_okuyanlar.add(AtaWidget.of(context).kullanicimail);
                                bildirim.reference.update({"okuyanlar" : bildirimi_okuyanlar});
                              }

                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bildirim okundu olarak i??aretlenmi??tir."),
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
       title: Text("Okunmayan bildirimleriniz g??r??nt??lenmektedir.", style: TextStyle(color: Colors.blue.shade100, fontWeight: FontWeight.bold,
           fontSize: 16,), textAlign: TextAlign.center,),
       subtitle: Padding(
         padding: const EdgeInsets.only( top: 15.0),
         child: Center(child: Text("Bildirimler sondan ba??a do??ru s??ralanm????t??r. G??rmek istedi??iniz bildirimin ??zerine t??klay??n??z.",
             style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 12), textAlign: TextAlign.justify,)),
       ),
     ),
     content: okunmayanBildirimler_Widget(),
     actions: [
       MaterialButton(
         child: Text("T??m??n?? G??r", style: TextStyle(color: Colors.blue.shade100, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline,
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
                Text("g??nderen: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline)),
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
        Visibility( visible: AtaWidget.of(context).kullaniciadi == "Y??netici Kullan??c??" ? true : false,
          child: FloatingActionButton.extended( heroTag: "yanitla", backgroundColor: Colors.indigo, elevation: 50, icon: Icon(Icons.arrow_back_rounded),
              onPressed: (){
                yanitla(okunmayan_bildirimler[index]);
              },
              label: Text("Yan??tla", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
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
                Text("${map_bildirimler["konu"].toString().toUpperCase()} i??in yan??t", style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.indigo, fontSize: 15, decoration: TextDecoration.underline),),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0,),
              child: Wrap(
                children: [
                  Text("Al??c?? kullan??c?? ad??: ",
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
                  Text("Al??c?? E-mail: ",
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
                  labelText: "Yan??t??n??z?? buraya yaz??n??z."),
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
              validator: (String yanit) {
                if (yanit.isEmpty) {return "Alan bo?? b??rak??lamaz.";
                } return null;
              }
          )),
      actions: [
        ElevatedButton(
          child: Text("G??nder"),
          onPressed: () async {
            if(formKey_yanitla.currentState.validate()){
              formKey_yanitla.currentState.save();

              await FirebaseFirestore.instance.collection("bildirimler").add({ "tarih": DateTime.now().toString(),
                "alicilar_mail" : [map_bildirimler["gonderen_mail"]], "alicilar_ad" : [map_bildirimler["gonderen_adi"]],
                "gonderen_adi" : AtaWidget.of(context).kullaniciadi, "gonderen_mail" : AtaWidget.of(context).kullanicimail,
                "konu" : "${map_bildirimler["konu"].toString().toUpperCase()} i??in yan??t", "mesaj" : yanitlayici.text.trim(), "okuyanlar" : okuyanlar,
              });
              Navigator.of(context, rootNavigator: true).pop("dilaog");
              Navigator.of(context, rootNavigator: true).pop("dilaog");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Yan??t??n??z ba??ar??yla g??nderilmi??tir."),
                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
            }

          },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);
  }


  void pasifeOtomatikMail(String kisi_mail) async {
//*******************************************************PAS??FE OTOMAT??K MA??L G??NDER??LECEK MA??LER KULLANILACAK**************

    String username = "yoneticikullanici1@gmail.com";
    String password = "Hjnxfg236:)";
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username)
      ..recipients.add(kisi_mail)
      ..subject = "S??nav payla????m??  ${DateTime.now()}"
      ..text = "Hesab??n??z pasif durumda oldu??u i??in sizinle payla????lmak istenen s??nav?? alamad??n??z. S??navlar?? almak i??in S??navc??m hesab??n??z?? aktif hale getiriniz.";

      final sendReport = await send(message, smtpServer);


  }


}