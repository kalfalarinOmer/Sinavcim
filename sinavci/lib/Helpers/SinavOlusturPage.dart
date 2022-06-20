
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

class SinavOlusturPage extends StatefulWidget {
  final collectionreference; final storageReference;
  const SinavOlusturPage({Key key, this.collectionreference, this.storageReference}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SinavOlusturPageState(this.collectionreference, this.storageReference);
  }
}

class SinavOlusturPageState extends State {

  final collectionreference; final storageReference;
  SinavOlusturPageState(this.collectionreference, this.storageReference);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey_gorselSoru = GlobalKey<FormState>();
  File _soruSelected;
  File _cevapSelected;
  String idnewDoc; String sinav_baslik; String baslik;
  int sayi = 0; //sayi = 1 ise sınav başlangıcı oluşturuldu görsele soru ekleme yapılmaya hazır!!
  String harf;  // harf = a olduğunda soru görseli eklenmiştir ve cevap eklenebilir durumuna gelinmmiştir.
  String id_subCol_newDoc;
  bool metinsel_soru; bool gorsel_soru; bool soru_testmi;
  bool test_mesaji = false;
  bool a_sikki_bitti; bool b_sikki_bitti; bool c_sikki_bitti; bool d_sikki_bitti;
  File a_sikki_gorsel; File b_sikki_gorsel; File c_sikki_gorsel; File d_sikki_gorsel;
  String a_sikki_metin; String b_sikki_metin; String c_sikki_metin; String d_sikki_metin;
  String dogru_sik;

  String soru_metni = "Yukarıdakilerden birini seçerek soru giriniz.";
  String puan; int _puan;


  Reklam _reklam = new Reklam();
  @override
  void initState() {
    _reklam.createInterad();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("SINAV OLUŞTUR"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(icon: Icon(Icons.campaign), iconSize: 30,
              onPressed: (){
                AlertDialog alertDialog = new AlertDialog(
                  title: Text("BİLGİLENDİRME"),
                  content: Container( height: 400,
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MaterialButton(child: Text("Sınav Oluştur asistan video için Tıklayın.",
                            style: TextStyle(color: Colors.green), textAlign: TextAlign.center,),
                            onPressed: (){
                              _launchIt("https://drive.google.com/file/d/1QEVw8_M9vPHrxcHDRTUo1aL-ZHKHAdNW/view?usp=sharing");
                            },),
                          Center(
                            child: Text("* Sınavınızı farklı formatlardaki istediğiniz miktarda soruyla bu sayfada oluşturabilirsiniz.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text("* Sınavınıza telefonunuzun galerisinden resim seçerek yada kamerasından fotoğraf çekerek görsel soru, uygulama "
                                "içerisinden metin girerek metinsel soru ekleyebilirsiniz. Sorularınız dört şıklı çoktan seçmeli bir test sorusu yada açık uçlu "
                                "klasik soru olabilir.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text("* Oluşturulan sınavınız tek tip sorulardan oluşabileceği gibi farklı tiplerdeki sorulardan oluşan karma bir sınav olabilir."
                                "ÇOKTAN SEÇMELİ GÖRSEL SORU, AÇIK UÇLU GÖRSEL SORU, ÇOKTAN SEÇMELİ METİNSEL SORU ve AÇIK UÇLU METİNSEL SORU olmak üzere dört soru "
                                "tipi mevcuttur.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text("* Oluşturulan sınavlar için SINAV ANALİZİ, KİŞİ ANALİZİ ve 2 farklı SORU ANALİZİ 4 sınav analiz tanımlanmıştır. SORU ANALİZLERİ "
                                "sadece oluşturulan sınavlar için tanımlanmıştır. Soruda gönderilen çözümlere verdiğiniz puanları baz alan soru analizi tüm sorular için "
                                "tanımlanmıştır. Test soruları için ayrıca bir de işaretlemelerin baz alındığı analiz tanımlanmıştır. Burada sorunun çözümleri için "
                                "verdiğiniz puanların bir etkisi yoktur. Doğru işaretlemeler için tam puan, yanlış işaretlemeler için 0 puan verilir.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text("* Dilerseniz sınava sonra sınavın kendi sayfasından soru ekleyebilirsiniz.",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                          ),
                        ],
                      ),
                    ),
                  ),
                );showDialog(context: context, builder: (_) => alertDialog);
              },),
          ),
        ],
      ),
      body: ListView(
        children: [
          Visibility(
            child: GestureDetector(
              onTap: (){
                _reklam.showInterad();

                _sinavOlustur();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10),
                child: RichText(text: TextSpan(
                    style: TextStyle(),
                    children: <TextSpan>[
                      TextSpan(text: "*Sınav oluşturmaya başlamak için ",
                          style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.w600)),
                      TextSpan(text: " Buraya tıklayınız. ", style: TextStyle(color: Colors.indigo,
                          fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                    ]
                )),
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Visibility(visible: AtaWidget.of(context).sayi_sinavOlustur == "1" ? true : false,
                        child: ElevatedButton(
                            child: Text(AtaWidget.of(context).harf_sinavOlustur == "a" ? "Soru Ekle" : "Soru Görseli Ekle",
                              textAlign: TextAlign.center,),
                            onPressed: ()async{
                              _reklam.showInterad();

                              if(AtaWidget.of(context).harf_sinavOlustur == "a"){
                                AtaWidget.of(context).gorsel_soru_sinavOlustur = false;
                                AtaWidget.of(context).metinsel_soru_sinavOlustur = true;
                                AtaWidget.of(context).harf_sinavOlustur = null;
                                AtaWidget.of(context).soruSelected_sinavOlustur = null;
                                AtaWidget.of(context).cevapSelected_sinavOlustur = null;
                                AtaWidget.of(context).soru_metni_sinavOlustur =
                                "Yukarıdakilerden birini seçerek sınavınıza soru ekleyiniz.";

                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                    SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                setState(() {});
                              } else {
                                AlertDialog alertDialog = new AlertDialog(
                                  title: Text("Soru Ekleme", style: TextStyle(color: Colors.green),),
                                  content: Container(
                                    child: SingleChildScrollView(
                                      physics: ClampingScrollPhysics(),
                                      child: Column( children: [
                                        Text("1. Önceki adımda sınavınızı oluşturdunuz. Sırada sınavınıza soru eklemelisiniz. Sınavınızın görülmesi için en az bir soruyu şu an "
                                            "eklemeniz gerekmektedir. Hiç soru eklenmeyen sınavlar gösterilmez."),
                                        SizedBox(height: 10,),
                                        Text("2. Soru eklemeye sorunuzun çoktan seçmeli olup olmadığını belirterek başlamanız gerekir . Buradaki tercihinize "
                                            "göre sorunuza şık ekleme ve doğru şıkkı seçme işlemi yapabileceksiniz."),
                                        SizedBox(height: 10,),
                                        Text("3. Sorularınızı dilerseniz telefonunuzdan resim olarak ekleyebiir, dilerseniz metin olarak "
                                            "girebilirsiniz. Test sorularına şık eklemelisiniz. Şıklar ve sorular aynı anda yüklenecektir."),
                                        SizedBox(height: 10,),
                                        Text("4. Sorularınızı yükledikten sonra dilerseniz benzer şekilde her soru için resim yada metin formatlarında çözüm yüklemesi "
                                            "yapabilrisniz. Sorunun çözümünü daha sonra da ekleyebilirsiniz. "),
                                        SizedBox(height: 15,),
                                        Text("Sorunuz çoktan seçmeli mi?", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),)
                                      ],

                                      ),
                                    ),
                                  ),
                                  actions: [
                                    MaterialButton(
                                        onPressed: (){
                                          AtaWidget.of(context).harf_sinavOlustur = "";
                                          AtaWidget.of(context).test_mesaji_sinavOlustur = true;
                                          AtaWidget.of(context).soru_testmi_sinavOlustur = true;

//                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
//                                              SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                          setState(() {});
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          AlertDialog alertDialog = new AlertDialog(
                                            title: Text("Soru görselini ekleyeceğiniz yöntemi seçiniz:  "),
                                            actions: [
                                              Container( height: 50, width: 120,
                                                child: FittedBox(
                                                  child: ElevatedButton(
                                                    child: Text("Telefondan soru seç"),
                                                    onPressed: ()async{
                                                      Navigator.of(context,rootNavigator: true).pop('dialog');
                                                      var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                                                      AtaWidget.of(context).gorsel_soru_sinavOlustur = true;
                                                      AtaWidget.of(context).metinsel_soru_sinavOlustur = false;
                                                      AtaWidget.of(context).soruSelected_sinavOlustur = image;

                                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                                          SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

                                                      print("AtaWidget.of(context).gorsel_soru_sinavOlustur: " + AtaWidget.of(context).gorsel_soru_sinavOlustur.toString());
                                                      print("AtaWidget.of(context).metinsel_soru_sinavOlustur: " + AtaWidget.of(context).metinsel_soru_sinavOlustur.toString());
                                                      print("AtaWidget.of(context).soruSelected_sinavOlustur: " + AtaWidget.of(context).soruSelected_sinavOlustur.toString());
//                                                  setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Container( height: 50, width: 120,
                                                child: FittedBox(
                                                  child: ElevatedButton(
                                                      child: Text("Kameradan soru çek"),
                                                      onPressed: () async {
                                                        Navigator.of(context,rootNavigator: true).pop('dialog');
                                                        var image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
                                                        AtaWidget.of(context).gorsel_soru_sinavOlustur = true;
                                                        AtaWidget.of(context).metinsel_soru_sinavOlustur = false;
                                                        AtaWidget.of(context).soruSelected_sinavOlustur = image;

                                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                                            SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                                    setState(() {});
                                                      }),
                                                ),
                                              ),
                                            ],
                                          );
                                          showDialog(context: context, builder: (_) => alertDialog);
                                        },
                                        child: Text("EVET", style: TextStyle(color: Colors.indigo, fontSize: 20),)),
                                    MaterialButton(
                                        onPressed: (){
                                          AtaWidget.of(context).harf_sinavOlustur = "";
                                          AtaWidget.of(context).test_mesaji_sinavOlustur = true;
                                          AtaWidget.of(context).soru_testmi_sinavOlustur = false;

//                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
//                                              SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                          setState(() {});
                                          Navigator.of(context, rootNavigator: true).pop("dialog");
                                          AlertDialog alertDialog = new AlertDialog(
                                            title: Text("Soru görselini ekleyeceğiniz yöntemi seçiniz:  "),
                                            actions: [
                                              Container( height: 50, width: 120,
                                                child: FittedBox(
                                                  child: ElevatedButton(
                                                    child: Text("Telefondan soru seç"),
                                                    onPressed: ()async{
                                                      Navigator.of(context,rootNavigator: true).pop('dialog');
                                                      var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                                                      AtaWidget.of(context).gorsel_soru_sinavOlustur = true;
                                                      AtaWidget.of(context).metinsel_soru_sinavOlustur = false;
                                                      AtaWidget.of(context).soruSelected_sinavOlustur = image;

                                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                                          SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                                  setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Container( height: 50, width: 120,
                                                child: FittedBox(
                                                  child: ElevatedButton(
                                                      child: Text("Kameradan soru çek"),
                                                      onPressed: ()async{
                                                        Navigator.of(context,rootNavigator: true).pop('dialog');
                                                        var image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);

                                                        AtaWidget.of(context).gorsel_soru_sinavOlustur = true;
                                                        AtaWidget.of(context).metinsel_soru_sinavOlustur = false;
                                                        AtaWidget.of(context).soruSelected_sinavOlustur = image;

                                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                                            SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                                    setState(() {});
                                                      }),
                                                ),
                                              ),
                                            ],
                                          );
                                          showDialog(context: context, builder: (_) => alertDialog);
                                        },
                                        child: Text("HAYIR", style: TextStyle(color: Colors.indigo, fontSize: 20),)),
                                  ],
                                ); showDialog(context: context, builder: (_)=> alertDialog);
                              }

                            }
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(child: AtaWidget.of(context).sayi_sinavOlustur == "1" &&
                        AtaWidget.of(context).soruSelected_sinavOlustur == null ?
                      Visibility(
                        child: ElevatedButton(
                            child: Text("Soru Metni Gir",textAlign: TextAlign.center,),
                            onPressed: (){
                              AlertDialog alertDialog = new AlertDialog(
                                title: Text("Soru Ekleme", style: TextStyle(color: Colors.green),),
                                content: Container(
                                  child: SingleChildScrollView(
                                    physics: ClampingScrollPhysics(),
                                    child: Column( children: [
                                      Text("1. Önceki adımda sınavınızı oluşturdunuz. Sırada sınavınıza soru eklemelisiniz. Sınavınızın görülmesi için en az bir soruyu şu an "
                                          "eklemeniz gerekmektedir. Hiç soru eklenmeyen sınavlar gösterilmez."),
                                      SizedBox(height: 10,),
                                      Text("2. Soru eklemeye sorunuzun çoktan seçmeli olup olmadığını belirterek başlayabilirsiniz. Buradaki tercihinize "
                                          "göre sorunuza şık ekleme ve doğru şıkkı seçme işlemi yapabileceksiniz."),
                                      SizedBox(height: 10,),
                                      Text("3. Sorularınızı dilerseniz telefonunuzdan resim olarak ekleyebiir, dilerseniz metin olarak "
                                          "girebilirsiniz. Test sorularına şık eklemelisiniz. Şık eklemesi soru ekleme işleminin en sonunda soru eklemeye benzer şekilde "
                                          "yapılır."),
                                      SizedBox(height: 10,),
                                      Text("4. Sorularınızı yükledikten sonra dilerseniz benzer şekilde her soru için resim yada metin formatlarında çözüm yüklemesi "
                                          "yapabilrisniz. Sorunun çözümünü daha sonra da ekleyebilirsiniz. "),
                                      SizedBox(height: 15,),
                                      Text("Sorunuz çoktan seçmeli mi?", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),)
                                    ],

                                    ),
                                  ),
                                ),
                                actions: [
                                  MaterialButton(
                                      onPressed: (){
                                        AtaWidget.of(context).harf_sinavOlustur = "";
                                        AtaWidget.of(context).test_mesaji_sinavOlustur = true;
                                        AtaWidget.of(context).soru_testmi_sinavOlustur = true;


//                                        setState(() {});
                                        Navigator.of(context, rootNavigator: true).pop("dialog");
                                        _soruMetniGir();
                                      },
                                      child: Text("EVET", style: TextStyle(color: Colors.indigo, fontSize: 20),)),
                                  MaterialButton(
                                      onPressed: (){
                                        AtaWidget.of(context).harf_sinavOlustur = "";
                                        AtaWidget.of(context).test_mesaji_sinavOlustur = true;
                                        AtaWidget.of(context).soru_testmi_sinavOlustur = false;


                                        setState(() {});
                                        Navigator.of(context, rootNavigator: true).pop("dialog");
                                        _soruMetniGir();
                                      },
                                      child: Text("HAYIR", style: TextStyle(color: Colors.indigo, fontSize: 20),)),
                                ],
                              ); showDialog(context: context, builder: (_)=> alertDialog);

                              AtaWidget.of(context).baslik_sinavOlustur = "";
                              AtaWidget.of(context).gorsel_soru_sinavOlustur = false;
                              AtaWidget.of(context).metinsel_soru_sinavOlustur = true;


//                              setState(() {});
                            }),)
                      :
                      Visibility(visible:  AtaWidget.of(context).soruSelected_sinavOlustur == null ? false : true,
                        child: ElevatedButton(
                            child: Text( AtaWidget.of(context).soru_testmi_sinavOlustur == true ? "Şıkları Oluştur ve Soruyu Yükle"
                                : "Soruyu Yükle",textAlign: TextAlign.center,),
                            onPressed: (){
                              if( AtaWidget.of(context).soruSelected_sinavOlustur != null) {
                                AtaWidget.of(context).baslik_sinavOlustur = "";


//                                setState(() {});
                                _soruYukle();
                              }
                              else {AlertDialog alertDialog = new AlertDialog(title: Text("Hata: "),
                                content: Text("Soru görseli bulunamadı!!"),);
                              showDialog(context: context, builder: (_) => alertDialog);}

                            }),
                      ),
                    )
                  ],
                ),
              )

          ),
          Visibility(visible: AtaWidget.of(context).sayi_sinavOlustur == "1" ? true : false,
            child: GestureDetector( onDoubleTap: (){
              Widget SetUpAlertDialogContainer() {
                return Container(height: 400, width: 400,
                  child: Center(
                      child: AtaWidget.of(context).soruSelected_sinavOlustur == null
                          ? AtaWidget.of(context).gorsel_soru_sinavOlustur == true ? Text("soru görseli seçilmedi!!",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)
                          : Padding(padding: const EdgeInsets.all(15.0),
                        child: Text("${ AtaWidget.of(context).soru_metni_sinavOlustur}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      )
                          : SingleChildScrollView( physics: ClampingScrollPhysics(),
                            child: Image.file(AtaWidget.of(context).soruSelected_sinavOlustur, fit: BoxFit.fill,
                      ),
                          )),
                );
              }showDialog(context: context, builder: (_) {
                return AlertDialog( backgroundColor: Colors.lightBlue.shade100,
                  title: Text("Soru: "),
                  content: SetUpAlertDialogContainer(),
                  actions: [
                    Container( height: 50, width: 80,
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                            elevation: 0,
                            icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                            label: Text("Kırp", style: TextStyle(color: Colors.purple)),
                            backgroundColor: Colors.white,

                            onPressed: () async {
                              if(AtaWidget.of(context).soruSelected_sinavOlustur == null) return;
                              var image = await cropImage(AtaWidget.of(context).soruSelected_sinavOlustur);
                              if(image==null)
                                return;
                              AtaWidget.of(context).soruSelected_sinavOlustur = image;

                              showDialog(context: context, builder: (_) => AlertDialog(
                                title: Wrap(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                    SizedBox(width: 10, height: 5),
                                    Text("İşlemi iptal etmek için kırpma penceresinden çıktıktan sonra yeniden görsel getirilmelidir. Aksi takdirde ekranda "
                                        "görmeseniz dahi kırpma işlemini gerçekleştirdiğiniz için sisteme kırpılmış soru yüklenecektir. ",
                                        style: TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.justify),
                                  ]
                                ),
                                content: SetUpAlertDialogContainer(),
                                actions: [
                                  ElevatedButton(child: Text("Onayla"),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true).pop("dialog");
                                      Navigator.of(context, rootNavigator: true).pop("dialog");
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                          SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));
                                    }
                                  ),
                                ],
                              ));
                            }
                        ),
                      ),
                    ),
                  ],
                );
              });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: AtaWidget.of(context).soruSelected_sinavOlustur == null ? 300 : 500,
                  child: Center(
                      child:  AtaWidget.of(context).soruSelected_sinavOlustur == null
                          ?  AtaWidget.of(context).gorsel_soru_sinavOlustur == true ? Text("soru görseli seçilmedi!!",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)
                          : Padding(padding: const EdgeInsets.all(10.0),
                            child: Text(AtaWidget.of(context).soru_metni_sinavOlustur == null ? soru_metni
                                : "${AtaWidget.of(context).soru_metni_sinavOlustur}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),)
                          : Wrap(children: [
                            Center(child: Text("Soruyu kırpmak için görsele çift tıklayınız.", style: TextStyle(fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold
                            ))),
                            Container(height: 500,
                              child: SingleChildScrollView( physics: ClampingScrollPhysics(),
                                  child: Image.file( AtaWidget.of(context).soruSelected_sinavOlustur, fit: BoxFit.cover,)),
                            ),
                      ] )
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                padding: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Visibility(visible:  AtaWidget.of(context).metinsel_soru_sinavOlustur == true ?  AtaWidget.of(context).harf_sinavOlustur == "a" ? true : false
                            : AtaWidget.of(context).soruSelected_sinavOlustur == null ? false : true,
                          child: ElevatedButton(
                              child: Text("Cevap Ekle",textAlign: TextAlign.center,),
                              onPressed: ()async{
                                if ( AtaWidget.of(context).harf_sinavOlustur == "a") {
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Sorunun cevabını görsel ya da metinsel olarak girebilirsiniz. "),
                                    actions: [
                                      RaisedButton(
                                        color: Colors.blue,
                                        child: Text("Cevabı Metin Olarak Gir"),
                                        onPressed: () async{
                                          Navigator.of(context,rootNavigator: true).pop('dialog');
                                          metinselCevapEkle();
                                        },
                                      ),
                                      Wrap(direction: Axis.horizontal, spacing: 4, children: [
                                        RaisedButton(
                                          color: Colors.green,
                                          child: Text("Telefondan cevap seç"),
                                          onPressed: ()async{
                                            Navigator.of(context,rootNavigator: true).pop('dialog');
                                            var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                                            AtaWidget.of(context).cevapSelected_sinavOlustur = image;

                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                                SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                          setState(() {});
                                          },
                                        ),
                                        RaisedButton(
                                            color: Colors.green,
                                            child: Text("Kameradan cevap çek"),
                                            onPressed: ()async{
                                              Navigator.of(context,rootNavigator: true).pop('dialog');
                                              var image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
                                              AtaWidget.of(context).cevapSelected_sinavOlustur = image;

                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                                  SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                            setState(() {});
                                            }),
                                      ],),

                                    ],
                                  );
                                  showDialog(context: context, builder: (_) => alertDialog);

                                } else {
                                  AlertDialog alertDialog = new AlertDialog(
                                    title: Text("Hata: "),
                                    content: Text(" Önce soruyu yüklemeniz gerekmektedir."),
                                  );
                                  showDialog(context: context, builder: (_) => alertDialog);
                                }
                              }
                          ),
                        ),
                      ),
                      SizedBox(width: 20,),
                      Expanded(
                        child: Visibility(visible:  AtaWidget.of(context).cevapSelected_sinavOlustur == null ? false : true,
                          child: ElevatedButton(
                              child: Text("Cevabı Yükle",textAlign: TextAlign.center,),
                              onPressed: ()async{
                                if( AtaWidget.of(context).harf_sinavOlustur == "a") {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor..."),
                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                                  _gorselCevapYukle();
                                }
                                else {AlertDialog alertDialog = new AlertDialog(title: Text("Hata: "),
                                  content: Text("Cevap görseli bulunamadı!!"),);
                                showDialog(context: context, builder: (_) => alertDialog);}
                              }),
                        ),
                      )
                    ],
                  ),
                )

            ),
          ),
          Visibility(visible:  AtaWidget.of(context).harf_sinavOlustur == "a" ? true : false,
            child: GestureDetector( onDoubleTap: (){
              Widget SetUpAlertDialogContainer() {
                return Container(height: 500, width: 400,
                  child: Center(
                      child:  AtaWidget.of(context).cevapSelected_sinavOlustur == null ? Text("cevap görseli eklenmedi !!",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)
                          : SingleChildScrollView( physics: ClampingScrollPhysics(),
                            child: Image.file( AtaWidget.of(context).cevapSelected_sinavOlustur, fit: BoxFit.cover,
                      ),
                          )),
                );
              }showDialog(context: context, builder: (_) {
                return AlertDialog( backgroundColor: Colors.lightBlue.shade100,
                  title: Text("Cevap/Çözüm: "),
                  content: SetUpAlertDialogContainer(),
                  actions: [
                    Container( height: 50, width: 80,
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                            elevation: 0,
                            icon: Icon(Icons.crop, color: Colors.purple, size: 30,),
                            label: Text("Kırp", style: TextStyle(color: Colors.purple)),
                            backgroundColor: Colors.white,

                            onPressed: () async {
                              if(AtaWidget.of(context).cevapSelected_sinavOlustur == null) return;
                              var image = await cropImage(AtaWidget.of(context).cevapSelected_sinavOlustur);
                              if(image==null)
                                return;
                              AtaWidget.of(context).cevapSelected_sinavOlustur = image;

                              showDialog(context: context, builder: (_) => AlertDialog(
                                title: Wrap(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                      SizedBox(width: 10, height: 5),
                                      Text("İşlemi iptal etmek için kırpma penceresinden çıktıktan sonra yeniden görsel getirilmelidir. Aksi takdirde ekranda "
                                          "görmeseniz dahi kırpma işlemini gerçekleştirdiğiniz için sisteme kırpılmış soru yüklenecektir. ",
                                          style: TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.justify),
                                    ]
                                ),
                                content: SetUpAlertDialogContainer(),
                                actions: [
                                  ElevatedButton(child: Text("Onayla"),
                                      onPressed: () {
                                        Navigator.of(context, rootNavigator: true).pop("dialog");
                                        Navigator.of(context, rootNavigator: true).pop("dialog");
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                            SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));
                                      }
                                  ),
                                ],
                              ));
                            }
                        ),
                      ),
                    ),
                  ],
                );
              });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: AtaWidget.of(context).cevapSelected_sinavOlustur == null ? 300 : 500,
                  child: SingleChildScrollView( physics: ClampingScrollPhysics(),
                    child: Center(
                        child:  AtaWidget.of(context).cevapSelected_sinavOlustur == null ? Text("cevap görseli eklenmedi !!",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)
                            : Wrap( children: [
                              Center(child: Text("Cevabı kırpmak için görsele çift tıklayınız.", style: TextStyle(fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold
                              ))),
                              Image.file( AtaWidget.of(context).cevapSelected_sinavOlustur, fit: BoxFit.contain,),
                        ],)
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),),

    );
  }

  void _soruYukle() async {
    TextEditingController _controller = TextEditingController();
    TextEditingController _puanci = TextEditingController();
    Widget _uploadImageAlertDialog() {
      return Container(height: 400, width: 400,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
              children: [
                Text(  AtaWidget.of(context).soru_testmi_sinavOlustur != true ?
                    "Yükleme süresi görselin boyutuna ve internet hızınıza bağlı olarak biraz zamana alabilir. Yükleme tamamlandığında başarılıdır mesajı alacaksınız. "
                    "Sonrasında sorunuza cevap görseli ekleyebilir yada yeni soruya ekleme işlemine geçebilirsiniz." :
                    "Çoktan seçmeli bir test sorusu yüklemeyi tercih ettiniz. Bu sebeple seçili sorunuz için 4 tane şık girmeniz gerekmektedir. Şıkları telefonunuzun "
                        "dosyalarım klasöründen resim seçerek, kamerasından fotoğraf çekerek yada metin yazarak girebilirsiniz. Her bir görsel yüklemenizde işlem hızının "
                        "internet hızınıza ve yükleyeceğiniz görsellerin boyutuna bağlı olduğunu unutmayınız. Şıklardan birini doğru şık olarak belirlemelisiniz. Aksi "
                        "takdirde soru yükleme işleminin sonunda doğru cevap belirlemediğinize dair uyarı alacak ve işlemi tekrarlamak durumunda kalacaksınız.",
                  style: TextStyle( fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
                SizedBox(height: 20,),
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
                                labelText: "Sorunuz için başlık giriniz"),
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {return "başlık girmeniz gerekmektedir.";
                              } return null;
                            }),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: _puanci,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Sorunun puanını rakamla giriniz.",),
                          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                          validator: (String value){
                            if(value.isEmpty){ return "puan girmeniz gerekmektedir." ;}
                            return null;
                          },
                        ),
                      ],
                    )
                ),
                SizedBox(height: 15,),
                Text( AtaWidget.of(context).soru_testmi_sinavOlustur == true ? "Sorunuzuzu çoktan seçmeli olarak belirlediniz." : "Sorunuzu çoktan seçmeli değil olarak "
                    "belirlediniz." ,
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),),

              ]
          ),
        ),

      );
    }

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Soru Ekleme", style: TextStyle(color: Colors.green),),
            content: _uploadImageAlertDialog(),
            actions: [
              GestureDetector(onDoubleTap: (){},
                child: ElevatedButton(
                  child: Text( AtaWidget.of(context).soru_testmi_sinavOlustur == true ? "Şıkları Oluştur": "Soruyu Yükle"),
                  onPressed: () async {
                    if (_formKey_gorselSoru.currentState.validate()) {
                      _formKey_gorselSoru.currentState.save();
                      AtaWidget.of(context).baslik_sinavOlustur = _controller.text.trim();
                      puan = _puanci.text.trim();
                      _puan = int.parse(puan);

                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      if( AtaWidget.of(context).soru_testmi_sinavOlustur == true){
                        soru_siklariGetir();
                      } else {

                        final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                            .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                            .child(AtaWidget.of(context).baslik_sinavOlustur).child(AtaWidget.of(context).baslik_sinavOlustur);
                        await ref.putFile( AtaWidget.of(context).soruSelected_sinavOlustur);
                        var downloadUrl = await ref.getDownloadURL();
                        String url = downloadUrl.toString();

                        await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).update({"soru_yuklendi": true});
                        var subCol_newDoc =  await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).collection("sorular")
                            .add({"gorsel_soru": url, "baslik": AtaWidget.of(context).baslik_sinavOlustur, "gorsel_cevap": "", "metinsel_cevap": "", "metinsel_soru": "",
                          "soru_testmi":  AtaWidget.of(context).soru_testmi_sinavOlustur, "puan" : _puan, "tarih": DateTime.now().toString()});

                        AtaWidget.of(context).id_subCol_newDoc_sinavOlustur = await subCol_newDoc.id;
                        AtaWidget.of(context).harf_sinavOlustur = "a";

                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                            SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Soru başarıyla eklendi."),
                          action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                      }
                    }
                  },
                ),
              ),
            ],
          );
        });
  }

  void _gorselCevapYukle() async {

    Widget _uploadImageAlertDialog() {
      return Container(height: 200, width: 400,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
              children: [
                Text("Yükleme süresi görselin boyutuna ve internet hızınıza bağlı olarak biraz zamana alabilir. "
                    "Yükleme tamamlandığında başarılıdır mesajı alacak ve yeni soruya yönlendirileceksiniz.", textAlign: TextAlign.justify,),
                SizedBox(height: 20,),
              ]
          ),
        ),

      );
    }

    showDialog(context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Cevap Ekleme", style: TextStyle(color: Colors.green),),
            content: _uploadImageAlertDialog(),
            actions: [
              GestureDetector(onDoubleTap: (){},
                child: ElevatedButton(
                  child: Text("Cevabı Yükle"),
                  onPressed: () async {
                    final Reference ref_cevap = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                        .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                        .child(AtaWidget.of(context).baslik_sinavOlustur).child(AtaWidget.of(context).baslik_sinavOlustur + " nın cevabı");

                    await ref_cevap.putFile( AtaWidget.of(context).cevapSelected_sinavOlustur);
                    var downloadUrl_cevap = await ref_cevap.getDownloadURL();
                    String url_cevap = downloadUrl_cevap.toString();

                    await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).collection("sorular")
                        .doc(AtaWidget.of(context).id_subCol_newDoc_sinavOlustur).update({"gorsel_cevap": url_cevap, "metinsel_cevap": ""});

                    AtaWidget.of(context).gorsel_soru_sinavOlustur = false;
                    AtaWidget.of(context).metinsel_soru_sinavOlustur = true;
                    AtaWidget.of(context).harf_sinavOlustur = null;
                    AtaWidget.of(context).soruSelected_sinavOlustur = null;
                    AtaWidget.of(context).cevapSelected_sinavOlustur = null;
                    AtaWidget.of(context).soru_metni_sinavOlustur = "Yukarıdakilerden birini seçerek sınavınıza soru ekleyiniz.";

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                        SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevabınız başarıyla eklendi"),
                      action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                    Navigator.of(context, rootNavigator: true).pop('dialog');

                  },
                ),
              ),
            ],
          );
        });
  }

  void metinselCevapEkle() async {
    TextEditingController _metinsel_cevapci = TextEditingController();
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
                      controller: _metinsel_cevapci,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Cevap metninizi yazınız."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "Alan boş bırakılamaz.";
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
            Text("Cevabı Metin Olarak Gir: ", style: TextStyle(color: Colors.orange),
            ),
            content: _uploadTextNoteAlertDialog(),
            actions: [
              GestureDetector(onDoubleTap: (){},
                child: ElevatedButton(
                  child: Text("Cevabı Yükle"),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      final newmetinselCevap = _metinsel_cevapci.text.trim().toLowerCase();

                      await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).collection("sorular")
                          .doc(AtaWidget.of(context).id_subCol_newDoc_sinavOlustur).update({"metinsel_cevap": newmetinselCevap, "gorsel_cevap": "",});

                      AtaWidget.of(context).gorsel_soru_sinavOlustur = false;
                      AtaWidget.of(context).metinsel_soru_sinavOlustur = true;
                      AtaWidget.of(context).harf_sinavOlustur = null;
                      AtaWidget.of(context).soruSelected_sinavOlustur = null;
                      AtaWidget.of(context).cevapSelected_sinavOlustur = null;
                      AtaWidget.of(context).soru_metni_sinavOlustur ="Yukarıdakilerden birini seçerek sınavınıza soru ekleyiniz.";

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                          SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cevabınız başarıyla eklendi"),
                        action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    }
                  },
                ),
              ),
            ],
          );
        });

  }

  void _sinavOlustur() async {
    TextEditingController _baslikci = TextEditingController();
    TextEditingController _konucu = TextEditingController();
    TextEditingController _cevapci = TextEditingController();
    TextEditingController _dersci = TextEditingController();
    TextEditingController _aciklamaci = TextEditingController();
    TextEditingController _bitis_tarihci = TextEditingController();



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
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "başlık girmeniz gerekmektedir.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _konucu,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Sınavınızın konusunu giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "konu girmeniz gerekmektedir.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  TextFormField(
                      controller: _dersci,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Sınavınızın dersini giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "ders girmeniz gerekmektedir.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _bitis_tarihci,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Sınavınızın bitis tarihini giriniz."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "konu girmeniz gerekmektedir.";
                        } return null;
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
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                        validator: (String PicName) {
                          if (PicName.isEmpty) {return "Cevap linki/metni girilmeyecektir.";
                          } return null;
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
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                        validator: (String PicName) {
                          if (PicName.isEmpty) {return "Açıklama girilmeyecektir.";
                          } return null;
                        }),
                  ),
                ]),
              )),
          SizedBox(height: 10,),

        ]),
      );
    }

    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text("SINAV OLUŞTUR"),
        content: _uploadImageAlertDialog(),
        actions: [
          GestureDetector(onDoubleTap: (){},
            child: ElevatedButton(
              child: Text("Oluştur"),
              onPressed: () async {

                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    _formKey_cevap.currentState.save();
                    _formKey_aciklama.currentState.save();

                    final newbaslik = _baslikci.text.trim();
                    final newkonu = _konucu.text.trim();
                    final newcevap = _cevapci.text.trim();
                    final newaciklama = _aciklamaci.text;
                    final new_bitis_tarihi = _bitis_tarihci.text.trim();
                    final newders = _dersci.text.trim();
                    List <String> paylasilanlar = [];
                    List <String> paylasilan_gruplar = [];

                    final newDoc = await collectionreference.add({"olusturulanmi": true, "aciklama": newaciklama, "bitis_tarihi": new_bitis_tarihi, "gorsel": "",
                      "konu": newkonu, "tarih": DateTime.now().toString(), "gorsel_cevap": "", "soru_yuklendi": false, "grup_adi": "", "grupAciklamasi": "",
                      "baslik": newbaslik,  "cevap": newcevap, "kilitli": true, "ders": newders, "hazirlayan": AtaWidget.of(context).kullaniciadi, "eklendigi_grup": "",
                      "paylasilanlar": paylasilanlar,  "paylasilan_gruplar": paylasilan_gruplar, "altbilgi": "", "ustbilgi": "", "yazili_baslik": "",
                      "yazili_girildi" : false,
                    });

                    final _idnewDoc = newDoc.id;
                    AtaWidget.of(context).idnewDoc_sinavOlustur = _idnewDoc;

                    final newDoc_newCol =  await newDoc.collection("sorular");

                    AtaWidget.of(context).sayi_sinavOlustur = "1";
                    AtaWidget.of(context).sinav_baslik_sinavOlustur = _baslikci.text.trim();
                    AtaWidget.of(context).gorsel_soru_sinavOlustur = false;
                    AtaWidget.of(context).metinsel_soru_sinavOlustur = true;
                    AtaWidget.of(context).sayi_sinavOlustur = "1";
                    AtaWidget.of(context).gorsel_soru_sinavOlustur = false;
                    AtaWidget.of(context).metinsel_soru_sinavOlustur = true;
                    print("ATAWİDGET SAYİ:" + AtaWidget.of(context).sayi_sinavOlustur);

//                    setState(() {});

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                        SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

                    Navigator.of(context, rootNavigator: true).pop('dialog');

                  } else {}

              },
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

    final _formKey = GlobalKey<FormState>();
    Widget _uploadTextNoteAlertDialog() {
      return Container(
        height: 300, width: 400,
        child: Column(children: [
          Form(key: _formKey,
              child: Flexible(
                child: ListView(children: [
                  Visibility( visible: AtaWidget.of(context).soru_testmi_sinavOlustur == true ? true : false,
                    child: Text("Çoktan seçmeli bir test sorusu yüklemeyi tercih ettiniz. Bu sebeple seçili sorunuz için 4 tane şık girmeniz gerekmektedir. Şıkları "
                        "telefonunuzdan resim seçerek, kamerasından fotoğraf çekerek yada metin yazarak girebilirsiniz. Her bir görsel yüklemenizde işlem "
                        "hızının internet hızınıza ve yükleyeceğiniz görsellerin boyutuna bağlı olduğunu unutmayınız. Şıklardan birini doğru şık olarak belirlemelisiniz. "
                        "Aksi takdirde soru yükleme işleminin sonunda doğru cevap belirlemediğinize dair uyarı alacak ve işlemi tekrarlamak durumunda kalacaksınız.",
                      style: TextStyle( fontStyle: FontStyle.italic, fontSize: 12), textAlign: TextAlign.justify,),
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _controller,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Sorunuz için başlık giriniz"),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "başlık girmeniz gerekmektedir.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _soru_metinci,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Soru metninizi yazınız."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String PicName) {
                        if (PicName.isEmpty) {return "Alan boş bırakılamaz.";
                        } return null;
                      }),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: _puanci,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Sorunun puanını giriniz.",),
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                    validator: (String value){
                      if(value.isEmpty){ return "puan girmeniz gerekmektedir." ;}
                      return null;
                    },
                  ),
                  SizedBox(height: 10,),
                  Text(AtaWidget.of(context).soru_testmi_sinavOlustur == true ? "Sorunuzuzu çoktan seçmeli olarak belirlediniz.": "Sorunuzu çoktan seçmeli değil olarak "
                      "belirlediniz." ,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),),
                ]),
              )),
        ]),
      );
    }  showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Soru Ekleme ", style: TextStyle(color: Colors.orange),
            ),
            content: _uploadTextNoteAlertDialog(),
            actions: [
              GestureDetector(onDoubleTap: (){},
                child: ElevatedButton(
                  child: Text(AtaWidget.of(context).soru_testmi_sinavOlustur == true ? "Şıkları Oluştur": "Soruyu Yükle"),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      AtaWidget.of(context).baslik_sinavOlustur = _controller.text.trim();
                      AtaWidget.of(context).soru_metni_sinavOlustur = _soru_metinci.text.trim();
                      puan = _puanci.text.trim();
                      _puan = int.parse(puan);

                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      if(AtaWidget.of(context).soru_testmi_sinavOlustur == true){
                        soru_siklariGetir();

                      } else {

                        await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).update({"soru_yuklendi": true});
                        var subCol_newDoc =  await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).collection("sorular")
                            .add({"gorsel_soru": "", "baslik": AtaWidget.of(context).baslik_sinavOlustur, "gorsel_cevap": "", "metinsel_cevap": "",
                          "metinsel_soru": AtaWidget.of(context).soru_metni_sinavOlustur,
                          "soru_testmi": AtaWidget.of(context).soru_testmi_sinavOlustur, "puan": _puan, "tarih": DateTime.now().toString()});

                        AtaWidget.of(context).id_subCol_newDoc_sinavOlustur = await subCol_newDoc.id;
                        AtaWidget.of(context).harf_sinavOlustur = "a";

                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                            SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sorunuz başarıyla eklendi"),
                          action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                      }

                    }
                  },
                ),
              ),
            ],
          );
        });
  }

  void soru_siklariGetir() async {
    AlertDialog alertDialog = new AlertDialog(
      title: Text("A şıkkı için giriş yöntemini seçiniz: "),
      actions: [
        ElevatedButton(child: Text("Resim Seç"), onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop("dialog");

            var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
            a_sikki_gorsel = image;

//            setState(() {});

            Widget _uploadImageAlertDialog() {
              return Container(
                height: 500, width: 400,
                child: Column(children: [
                  Flexible(
                    child: Container(
                        child: a_sikki_gorsel == null
                            ? Center(
                            child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ))
                            : Image.file(a_sikki_gorsel, fit: BoxFit.contain,
                        )),
                  ),
                  SizedBox(height: 20,),
                  Text("**Sorunuzun A şıkkı yukarıdaki resim olacaktır**",
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
                      child: Text("A şıkkını doğru cevap olarak belirle",
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
                        label: Text("Kırp", style: TextStyle(color: Colors.purple)),
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
                                      child: Text("A şıkkını doğru cevap olarak belirle",
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
                                      child: Text("A şıkkını Onayla ve B şıkkına geç"),
                                      onPressed: () async {
                                        if (a_sikki_gorsel == null) {
                                          return null;
                                        } else {
                                          a_sikki_bitti = true;

//                            setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                            action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
                            child: Text("A şıkkını Onayla ve B şıkkına geç"),
                            onPressed: () async {
                              if (a_sikki_gorsel == null) {
                                return null;
                              } else {
                                a_sikki_bitti = true;

//                            setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
        ElevatedButton(child: Text("Fotoğraf Çek"), onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop("dialog");

          var image =  await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
          a_sikki_gorsel = image;

//          setState(() {});

          Widget _uploadImageAlertDialog() {
            return Container(
              height: 500, width: 400,
              child: Column(children: [
                Flexible(
                  child: Container(
                      child: a_sikki_gorsel == null
                          ? Center(
                          child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ))
                          : Image.file(a_sikki_gorsel, fit: BoxFit.contain,
                      )),
                ),
                SizedBox(height: 20,),
                Text("**Sorunuzun A şıkkı yukarıdaki resim olacaktır**",
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
                      child: Text("A şıkkını doğru cevap olarak belirle",
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
                        label: Text("Kırp", style: TextStyle(color: Colors.purple)),
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
                                      child: Text("A şıkkını doğru cevap olarak belirle",
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
                                      child: Text("A şıkkını Onayla ve B şıkkına geç"),
                                      onPressed: () async {
                                        if (a_sikki_gorsel == null) {
                                          return null;
                                        } else {
                                          a_sikki_bitti = true;

//                            setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                            action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
                            child: Text("A şıkkını Onayla ve B şıkkına geç"),
                            onPressed: () async {
                              if (a_sikki_gorsel == null) {
                                return null;
                              } else {
                                a_sikki_bitti = true;

//                            setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
        ElevatedButton(child: Text("Metin Gir"), onPressed: (){
          Navigator.of(context, rootNavigator: true).pop("dialog");

          TextEditingController _a_sikki_metinci = TextEditingController();
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
                            controller: _a_sikki_metinci,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Şıkkın metnini yazınız."),
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {return "Alan boş bırakılamaz.";
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
                  Text("A)", style: TextStyle(color: Colors.orange),
                  ),
                  content: _uploadTextNoteAlertDialog(),
                  actions: [
                    Wrap(direction: Axis.vertical, spacing: 2, children: [
                      MaterialButton(
                          child: Text("A şıkkını doğru cevap olarak belirle",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                            textAlign: TextAlign.end,
                          ),
                          onPressed: (){
                            dogru_sik = "A";

//                            setState(() {});
                          }),
                      GestureDetector(onDoubleTap: (){},
                        child: ElevatedButton(
                          child: Text("A şıkkını onayla ve B şıkkına geç"),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              a_sikki_metin = _a_sikki_metinci.text.trim().toLowerCase();
                              a_sikki_bitti = true;

//                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                              Navigator.of(context, rootNavigator: true).pop('dialog');
                              b_sikkinaGec();
                            }
                          },
                        ),
                      ),
                    ],),
                  ],
                );
              });
        },),
      ],
    );showDialog(context: context, builder: (_) => alertDialog );
  }

  void b_sikkinaGec()async {
    AlertDialog alertDialog = new AlertDialog(
      title: Text("B şıkkı için giriş yöntemini seçiniz: "),
      actions: [
        ElevatedButton(child: Text("Resim Seç"), onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop("dialog");

          var image =  await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 30);
          b_sikki_gorsel = image;

//          setState(() {});

          Widget _uploadImageAlertDialog() {
            return Container(
              height: 500, width: 400,
              child: Column(children: [
                Flexible(
                  child: Container(
                      child: b_sikki_gorsel == null
                          ? Center(
                          child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ))
                          : Image.file(b_sikki_gorsel, fit: BoxFit.contain,
                      )),
                ),
                SizedBox(height: 20,),
                Text("**Sorunuzun B şıkkı yukarıdaki resim olacaktır**",
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
                      child: Text("B şıkkını doğru cevap olarak belirle",
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
                        label: Text("Kırp", style: TextStyle(color: Colors.purple)),
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
                                      child: Text("B şıkkını doğru cevap olarak belirle",
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
                                      child: Text("B şıkkını Onayla ve C şıkkına geç"),
                                      onPressed: () async {
                                        if (b_sikki_gorsel == null) {
                                          return null;
                                        } else {
                                          b_sikki_bitti = true;

//                            setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                            action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
                            child: Text("B şıkkını Onayla ve C şıkkına geç"),
                            onPressed: () async {
                              if (b_sikki_gorsel == null) {
                                return null;
                              } else {
                                b_sikki_bitti = true;

//                            setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
        ElevatedButton(child: Text("Fotoğraf Çek"), onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop("dialog");

          var image =  await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 30);
          b_sikki_gorsel = image;

//          setState(() {});

          Widget _uploadImageAlertDialog() {
            return Container(
              height: 500, width: 400,
              child: Column(children: [
                Flexible(
                  child: Container(
                      child: b_sikki_gorsel == null
                          ? Center(
                          child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ))
                          : Image.file(b_sikki_gorsel, fit: BoxFit.contain,
                      )),
                ),
                SizedBox(height: 20,),
                Text("**Sorunuzun B şıkkı yukarıdaki resim olacaktır**",
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
                      child: Text("B şıkkını doğru cevap olarak belirle",
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
                        label: Text("Kırp", style: TextStyle(color: Colors.purple)),
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
                                      child: Text("B şıkkını doğru cevap olarak belirle",
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
                                      child: Text("B şıkkını Onayla ve C şıkkına geç"),
                                      onPressed: () async {
                                        if (b_sikki_gorsel == null) {
                                          return null;
                                        } else {
                                          b_sikki_bitti = true;

//                            setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                            action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
                            child: Text("B şıkkını Onayla ve C şıkkına geç"),
                            onPressed: () async {
                              if (b_sikki_gorsel == null) {
                                return null;
                              } else {
                                b_sikki_bitti = true;

//                            setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
        ElevatedButton(child: Text("Metin Gir"), onPressed: (){
          Navigator.of(context, rootNavigator: true).pop("dialog");

          TextEditingController _b_sikki_metinci = TextEditingController();
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
                            controller: _b_sikki_metinci,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Şıkkın metninizi yazınız."),
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {return "Alan boş bırakılamaz.";
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
                  Text("B)", style: TextStyle(color: Colors.orange),
                  ),
                  content: _uploadTextNoteAlertDialog(),
                  actions: [
                    Wrap(direction: Axis.vertical, spacing: 2, children: [
                      MaterialButton(
                          child: Text("B şıkkını doğru cevap olarak belirle",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                            textAlign: TextAlign.end,
                          ),
                          onPressed: (){
                            dogru_sik = "B";

//                            setState(() {});
                          }),
                      GestureDetector(onDoubleTap: (){},
                        child: ElevatedButton(
                          child: Text("B şıkkını onayla ve C şıkkına geç"),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              b_sikki_metin = _b_sikki_metinci.text.trim().toLowerCase();
                              b_sikki_bitti = true;

//                              setState(() {});
                              Navigator.of(context, rootNavigator: true).pop('dialog');
                              c_sikkinaGec();
                            }
                          },
                        ),
                      ),
                    ],),
                  ],
                );
              });
        },),
      ],
    );showDialog(context: context, builder: (_) => alertDialog );
  }

  void c_sikkinaGec() async {
    AlertDialog alertDialog = new AlertDialog(
      title: Text("C şıkkı için giriş yöntemini seçiniz: "),
      actions: [
        ElevatedButton(child: Text("Resim Seç"), onPressed: () async {
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
                          child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ))
                          : Image.file(c_sikki_gorsel, fit: BoxFit.contain,
                      )),
                ),
                SizedBox(height: 20,),
                Text("**Sorunuzun C şıkkı yukarıdaki resim olacaktır**",
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
                      child: Text("C şıkkını doğru cevap olarak belirle",
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
                        label: Text("Kırp", style: TextStyle(color: Colors.purple)),
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
                                      child: Text("C şıkkını doğru cevap olarak belirle",
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
                                      child: Text("C şıkkını Onayla ve D şıkkına geç"),
                                      onPressed: () async {
                                        if (c_sikki_gorsel == null) {
                                          return null;
                                        } else {
                                          c_sikki_bitti = true;

//                            setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                            action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
                            child: Text("C şıkkını Onayla ve D şıkkına geç"),
                            onPressed: () async {
                              if (c_sikki_gorsel == null) {
                                return null;
                              } else {
                                c_sikki_bitti = true;

//                            setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
        ElevatedButton(child: Text("Fotoğraf Çek"), onPressed: () async {
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
                          child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ))
                          : Image.file(c_sikki_gorsel, fit: BoxFit.contain,
                      )),
                ),
                SizedBox(height: 20,),
                Text("**Sorunuzun C şıkkı yukarıdaki resim olacaktır**",
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
                      child: Text("C şıkkını doğru cevap olarak belirle",
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
                        label: Text("Kırp", style: TextStyle(color: Colors.purple)),
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
                                      child: Text("C şıkkını doğru cevap olarak belirle",
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
                                      child: Text("C şıkkını Onayla ve D şıkkına geç"),
                                      onPressed: () async {
                                        if (c_sikki_gorsel == null) {
                                          return null;
                                        } else {
                                          c_sikki_bitti = true;

//                            setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                            action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
                            child: Text("C şıkkını Onayla ve D şıkkına geç"),
                            onPressed: () async {
                              if (c_sikki_gorsel == null) {
                                return null;
                              } else {
                                c_sikki_bitti = true;

//                            setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşleminiz yapılıyor, Lütfen bekleyiniz."),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
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
        ElevatedButton(child: Text("Metin Gir"), onPressed: (){
          Navigator.of(context, rootNavigator: true).pop("dialog");

          TextEditingController _c_sikki_metinci = TextEditingController();
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
                            controller: _c_sikki_metinci,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Şıkkın metninizi yazınız."),
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {return "Alan boş bırakılamaz.";
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
                  Text("C)", style: TextStyle(color: Colors.orange),
                  ),
                  content: _uploadTextNoteAlertDialog(),
                  actions: [
                    Wrap(direction: Axis.vertical, spacing: 2, children: [
                      MaterialButton(
                          child: Text("C şıkkını doğru cevap olarak belirle",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                            textAlign: TextAlign.end,
                          ),
                          onPressed: (){
                            dogru_sik = "C";

//                            setState(() {});
                          }),
                      GestureDetector(onDoubleTap: (){},
                        child: ElevatedButton(
                          child: Text("C şıkkını onayla ve D şıkkına geç"),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              c_sikki_metin = _c_sikki_metinci.text.trim().toLowerCase();
                              c_sikki_bitti = true;

//                              setState(() {});
                              Navigator.of(context, rootNavigator: true).pop('dialog');
                              d_sikkinaGec();
                            }
                          },
                        ),
                      ),
                    ],),

                  ],
                );
              });
        },),
      ],
    );showDialog(context: context, builder: (_) => alertDialog );
  }

  void d_sikkinaGec() async {
    AlertDialog alertDialog = new AlertDialog(
      title: Text("D şıkkı için giriş yöntemini seçiniz: "),
      actions: [

        ElevatedButton(child: Text("Resim Seç"), onPressed: () async {
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
                          child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ))
                          : Image.file(d_sikki_gorsel, fit: BoxFit.contain,
                      )),
                ),
                SizedBox(height: 20,),
                Text("**Sorunuzun D şıkkı yukarıdaki resim olacaktır**",
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
                      child: Text("D şıkkını doğru cevap olarak belirle",
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
                        label: Text("Kırp", style: TextStyle(color: Colors.purple)),
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
                                      child: Text("D şıkkını doğru cevap olarak belirle",
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
                                      child: Text("D şıkkını Onayla ve Soruyu yükle"),
                                      onPressed: () async {
                                        String url; String url_a; String url_b; String url_c; String url_d;

                                        try {
                                          if (d_sikki_gorsel == null) {
                                            return null;
                                          } else {
                                            if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                              if (AtaWidget.of(context).soruSelected_sinavOlustur != null){
                                                final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child(AtaWidget.of(context).baslik_sinavOlustur);
                                                await ref.putFile(AtaWidget.of(context).soruSelected_sinavOlustur);
                                                var downloadUrl = await ref.getDownloadURL();
                                                url = downloadUrl.toString();
                                              } else {
                                                url = "";
                                              }

                                              if(a_sikki_gorsel != null ){
                                                final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("A_şıkkı");
                                                await ref_a.putFile(a_sikki_gorsel);
                                                var downloadUrl_a = await ref_a.getDownloadURL();
                                                url_a = downloadUrl_a.toString();
                                              } else {
                                                url_a = "";
                                              }

                                              if(b_sikki_gorsel != null ) {
                                                final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("B_şıkkı");
                                                await ref_b.putFile(b_sikki_gorsel);
                                                var downloadUrl_b = await ref_b.getDownloadURL();
                                                url_b = downloadUrl_b.toString();
                                              } else {
                                                url_b = "";
                                              }

                                              if(c_sikki_gorsel != null ) {
                                                final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("C_şıkkı");
                                                await ref_c.putFile(c_sikki_gorsel);
                                                var downloadUrl_c = await ref_c.getDownloadURL();
                                                url_c = downloadUrl_c.toString();
                                              } else {
                                                url_c = "";
                                              }

                                              if(d_sikki_gorsel != null ) {
                                                final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("D_şıkkı");
                                                await ref_d.putFile(d_sikki_gorsel);
                                                var downloadUrl_d = await ref_d.getDownloadURL();
                                                url_d = downloadUrl_d.toString();
                                              }  else {
                                                url_d = "";
                                              }

                                              await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).update({"soru_yuklendi": true});
                                              var subCol_newDoc =  await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).collection("sorular")
                                                  .add({"gorsel_soru": url, "baslik": AtaWidget.of(context).baslik_sinavOlustur, "gorsel_cevap": "", "metinsel_cevap": "",
                                                "metinsel_soru": AtaWidget.of(context).soru_metni_sinavOlustur,
                                                "soru_testmi": AtaWidget.of(context).soru_testmi_sinavOlustur, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c,
                                                "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                                "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                                "puan": _puan, "tarih": DateTime.now().toString()});

                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tüm şıklar ve soru başarıyla eklendi."),
                                                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Doğru cevap: " + dogru_sik + ") şıkkı olarak belirlediniz."),
                                                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                                              AtaWidget.of(context).id_subCol_newDoc_sinavOlustur = await subCol_newDoc.id;
                                              AtaWidget.of(context).harf_sinavOlustur = "a";
                                              AtaWidget.of(context).soru_testmi_sinavOlustur = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = "";
                                              a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; puan = ""; _puan = -1;
                                              url = "";

                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                                  SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                setState(() {});

                                              Navigator.of(context, rootNavigator: true).pop('dialog');
                                            } else {
                                              AlertDialog alertDialog = new AlertDialog (
                                                title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                                content: Text("Sorunuz için doğrı şık belirlemediniz. Lütfen şıkları tekrar girerek doğru şıkkı belirleyiniz."),
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
                            child: Text("D şıkkını Onayla ve Soruyu yükle"),
                            onPressed: () async {
                              String url; String url_a; String url_b; String url_c; String url_d;

                              try {
                                if (d_sikki_gorsel == null) {
                                  return null;
                                } else {
                                  if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                    if (AtaWidget.of(context).soruSelected_sinavOlustur != null){
                                      final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child(AtaWidget.of(context).baslik_sinavOlustur);
                                      await ref.putFile(AtaWidget.of(context).soruSelected_sinavOlustur);
                                      var downloadUrl = await ref.getDownloadURL();
                                      url = downloadUrl.toString();
                                    } else {
                                      url = "";
                                    }

                                    if(a_sikki_gorsel != null ){
                                      final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("A_şıkkı");
                                      await ref_a.putFile(a_sikki_gorsel);
                                      var downloadUrl_a = await ref_a.getDownloadURL();
                                      url_a = downloadUrl_a.toString();
                                    } else {
                                      url_a = "";
                                    }

                                    if(b_sikki_gorsel != null ) {
                                      final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("B_şıkkı");
                                      await ref_b.putFile(b_sikki_gorsel);
                                      var downloadUrl_b = await ref_b.getDownloadURL();
                                      url_b = downloadUrl_b.toString();
                                    } else {
                                      url_b = "";
                                    }

                                    if(c_sikki_gorsel != null ) {
                                      final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("C_şıkkı");
                                      await ref_c.putFile(c_sikki_gorsel);
                                      var downloadUrl_c = await ref_c.getDownloadURL();
                                      url_c = downloadUrl_c.toString();
                                    } else {
                                      url_c = "";
                                    }

                                    if(d_sikki_gorsel != null ) {
                                      final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("D_şıkkı");
                                      await ref_d.putFile(d_sikki_gorsel);
                                      var downloadUrl_d = await ref_d.getDownloadURL();
                                      url_d = downloadUrl_d.toString();
                                    }  else {
                                      url_d = "";
                                    }

                                    await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).update({"soru_yuklendi": true});
                                    var subCol_newDoc =  await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).collection("sorular")
                                        .add({"gorsel_soru": url, "baslik": AtaWidget.of(context).baslik_sinavOlustur, "gorsel_cevap": "", "metinsel_cevap": "",
                                      "metinsel_soru": AtaWidget.of(context).soru_metni_sinavOlustur,
                                      "soru_testmi": AtaWidget.of(context).soru_testmi_sinavOlustur, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c,
                                      "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                      "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                      "puan": _puan, "tarih": DateTime.now().toString()});

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tüm şıklar ve soru başarıyla eklendi."),
                                      action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Doğru cevap: " + dogru_sik + ") şıkkı olarak belirlediniz."),
                                      action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                                    AtaWidget.of(context).id_subCol_newDoc_sinavOlustur = await subCol_newDoc.id;
                                    AtaWidget.of(context).harf_sinavOlustur = "a";
                                    AtaWidget.of(context).soru_testmi_sinavOlustur = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = "";
                                    a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; puan = ""; _puan = -1;
                                    url = "";

                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                        SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                setState(() {});

                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                  } else {
                                    AlertDialog alertDialog = new AlertDialog (
                                      title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                      content: Text("Sorunuz için doğrı şık belirlemediniz. Lütfen şıkları tekrar girerek doğru şıkkı belirleyiniz."),
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
        ElevatedButton(child: Text("Fotoğraf Çek"), onPressed: () async {
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
                          child: Text("Resim seçilmedi. Yükleme yapılması yeniden resim seçimi yapılmalıdır.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ))
                          : Image.file(d_sikki_gorsel, fit: BoxFit.contain,
                      )),
                ),
                SizedBox(height: 20,),
                Text("**Sorunuzun D şıkkı yukarıdaki resim olacaktır**",
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
                      child: Text("D şıkkını doğru cevap olarak belirle",
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
                        label: Text("Kırp", style: TextStyle(color: Colors.purple)),
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
                                      child: Text("D şıkkını doğru cevap olarak belirle",
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
                                      child: Text("D şıkkını Onayla ve Soruyu yükle"),
                                      onPressed: () async {
                                        String url; String url_a; String url_b; String url_c; String url_d;

                                        try {
                                          if (d_sikki_gorsel == null) {
                                            return null;
                                          } else {
                                            if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                              if (AtaWidget.of(context).soruSelected_sinavOlustur != null){
                                                final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child(AtaWidget.of(context).baslik_sinavOlustur);
                                                await ref.putFile(AtaWidget.of(context).soruSelected_sinavOlustur);
                                                var downloadUrl = await ref.getDownloadURL();
                                                url = downloadUrl.toString();
                                              } else {
                                                url = "";
                                              }

                                              if(a_sikki_gorsel != null ){
                                                final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("A_şıkkı");
                                                await ref_a.putFile(a_sikki_gorsel);
                                                var downloadUrl_a = await ref_a.getDownloadURL();
                                                url_a = downloadUrl_a.toString();
                                              } else {
                                                url_a = "";
                                              }

                                              if(b_sikki_gorsel != null ) {
                                                final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("B_şıkkı");
                                                await ref_b.putFile(b_sikki_gorsel);
                                                var downloadUrl_b = await ref_b.getDownloadURL();
                                                url_b = downloadUrl_b.toString();
                                              } else {
                                                url_b = "";
                                              }

                                              if(c_sikki_gorsel != null ) {
                                                final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("C_şıkkı");
                                                await ref_c.putFile(c_sikki_gorsel);
                                                var downloadUrl_c = await ref_c.getDownloadURL();
                                                url_c = downloadUrl_c.toString();
                                              } else {
                                                url_c = "";
                                              }

                                              if(d_sikki_gorsel != null ) {
                                                final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                                    .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                                    .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("D_şıkkı");
                                                await ref_d.putFile(d_sikki_gorsel);
                                                var downloadUrl_d = await ref_d.getDownloadURL();
                                                url_d = downloadUrl_d.toString();
                                              }  else {
                                                url_d = "";
                                              }

                                              await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).update({"soru_yuklendi": true});
                                              var subCol_newDoc =  await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).collection("sorular")
                                                  .add({"gorsel_soru": url, "baslik": AtaWidget.of(context).baslik_sinavOlustur, "gorsel_cevap": "", "metinsel_cevap": "",
                                                "metinsel_soru": AtaWidget.of(context).soru_metni_sinavOlustur,
                                                "soru_testmi": AtaWidget.of(context).soru_testmi_sinavOlustur, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c,
                                                "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                                "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                                "puan": _puan, "tarih": DateTime.now().toString()});

                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tüm şıklar ve soru başarıyla eklendi."),
                                                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Doğru cevap: " + dogru_sik + ") şıkkı olarak belirlediniz."),
                                                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                                              AtaWidget.of(context).id_subCol_newDoc_sinavOlustur = await subCol_newDoc.id;
                                              AtaWidget.of(context).harf_sinavOlustur = "a";
                                              AtaWidget.of(context).soru_testmi_sinavOlustur = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = "";
                                              a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; puan = ""; _puan = -1;
                                              url = "";

                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                                  SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                setState(() {});

                                              Navigator.of(context, rootNavigator: true).pop('dialog');
                                            } else {
                                              AlertDialog alertDialog = new AlertDialog (
                                                title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                                content: Text("Sorunuz için doğrı şık belirlemediniz. Lütfen şıkları tekrar girerek doğru şıkkı belirleyiniz."),
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
                            child: Text("D şıkkını Onayla ve Soruyu yükle"),
                            onPressed: () async {
                              String url; String url_a; String url_b; String url_c; String url_d;

                              try {
                                if (d_sikki_gorsel == null) {
                                  return null;
                                } else {
                                  if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                    if (AtaWidget.of(context).soruSelected_sinavOlustur != null){
                                      final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child(AtaWidget.of(context).baslik_sinavOlustur);
                                      await ref.putFile(AtaWidget.of(context).soruSelected_sinavOlustur);
                                      var downloadUrl = await ref.getDownloadURL();
                                      url = downloadUrl.toString();
                                    } else {
                                      url = "";
                                    }

                                    if(a_sikki_gorsel != null ){
                                      final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("A_şıkkı");
                                      await ref_a.putFile(a_sikki_gorsel);
                                      var downloadUrl_a = await ref_a.getDownloadURL();
                                      url_a = downloadUrl_a.toString();
                                    } else {
                                      url_a = "";
                                    }

                                    if(b_sikki_gorsel != null ) {
                                      final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("B_şıkkı");
                                      await ref_b.putFile(b_sikki_gorsel);
                                      var downloadUrl_b = await ref_b.getDownloadURL();
                                      url_b = downloadUrl_b.toString();
                                    } else {
                                      url_b = "";
                                    }

                                    if(c_sikki_gorsel != null ) {
                                      final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("C_şıkkı");
                                      await ref_c.putFile(c_sikki_gorsel);
                                      var downloadUrl_c = await ref_c.getDownloadURL();
                                      url_c = downloadUrl_c.toString();
                                    } else {
                                      url_c = "";
                                    }

                                    if(d_sikki_gorsel != null ) {
                                      final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                          .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                          .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("D_şıkkı");
                                      await ref_d.putFile(d_sikki_gorsel);
                                      var downloadUrl_d = await ref_d.getDownloadURL();
                                      url_d = downloadUrl_d.toString();
                                    }  else {
                                      url_d = "";
                                    }

                                    await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).update({"soru_yuklendi": true});
                                    var subCol_newDoc =  await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).collection("sorular")
                                        .add({"gorsel_soru": url, "baslik": AtaWidget.of(context).baslik_sinavOlustur, "gorsel_cevap": "", "metinsel_cevap": "",
                                      "metinsel_soru": AtaWidget.of(context).soru_metni_sinavOlustur,
                                      "soru_testmi": AtaWidget.of(context).soru_testmi_sinavOlustur, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c,
                                      "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                      "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                      "puan": _puan, "tarih": DateTime.now().toString()});

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tüm şıklar ve soru başarıyla eklendi."),
                                      action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Doğru cevap: " + dogru_sik + ") şıkkı olarak belirlediniz."),
                                      action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                                    AtaWidget.of(context).id_subCol_newDoc_sinavOlustur = await subCol_newDoc.id;
                                    AtaWidget.of(context).harf_sinavOlustur = "a";
                                    AtaWidget.of(context).soru_testmi_sinavOlustur = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = "";
                                    a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; puan = ""; _puan = -1;
                                    url = "";

                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                        SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                setState(() {});

                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                  } else {
                                    AlertDialog alertDialog = new AlertDialog (
                                      title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                      content: Text("Sorunuz için doğrı şık belirlemediniz. Lütfen şıkları tekrar girerek doğru şıkkı belirleyiniz."),
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
        ElevatedButton(child: Text("Metin Gir"), onPressed: (){
          Navigator.of(context, rootNavigator: true).pop("dialog");

          TextEditingController _d_sikki_metinci = TextEditingController();
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
                            controller: _d_sikki_metinci,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Şıkkın metninizi yazınız."),
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                            validator: (String PicName) {
                              if (PicName.isEmpty) {return "Alan boş bırakılamaz.";
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
                  Text("D)", style: TextStyle(color: Colors.orange),
                  ),
                  content: _uploadTextNoteAlertDialog(),
                  actions: [
                    Wrap(direction: Axis.vertical, spacing: 2, children: [
                      MaterialButton(
                          child: Text("D şıkkını doğru cevap olarak belirle",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueAccent),
                            textAlign: TextAlign.end,
                          ),
                          onPressed: (){
                            dogru_sik = "D";

//                            setState(() {});
                          }),
                      GestureDetector(onDoubleTap: (){},
                        child: ElevatedButton(
                          child: Text("D şıkkını onayla ve soruyu yükle"),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              d_sikki_metin = _d_sikki_metinci.text.trim();
                              String url; String url_a; String url_b; String url_c; String url_d;

                              if(dogru_sik == "A" || dogru_sik == "B" || dogru_sik == "C" || dogru_sik == "D" ){

                                if (AtaWidget.of(context).soruSelected_sinavOlustur != null){
                                  final Reference ref = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                      .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                      .child(AtaWidget.of(context).baslik_sinavOlustur).child(AtaWidget.of(context).baslik_sinavOlustur);
                                  await ref.putFile(AtaWidget.of(context).soruSelected_sinavOlustur);
                                  var downloadUrl = await ref.getDownloadURL();
                                  url = downloadUrl.toString();
                                } else {
                                  url = "";
                                }

                                if(a_sikki_gorsel != null ){
                                  final Reference ref_a = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                      .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                      .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("A_şıkkı");
                                  await ref_a.putFile(a_sikki_gorsel);
                                  var downloadUrl_a = await ref_a.getDownloadURL();
                                  url_a = downloadUrl_a.toString();
                                } else {
                                  url_a = "";
                                }

                                if(b_sikki_gorsel != null ) {
                                  final Reference ref_b = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                      .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                      .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("B_şıkkı");
                                  await ref_b.putFile(b_sikki_gorsel);
                                  var downloadUrl_b = await ref_b.getDownloadURL();
                                  url_b = downloadUrl_b.toString();
                                } else {
                                  url_b = "";
                                }

                                if(c_sikki_gorsel != null ) {
                                  final Reference ref_c = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                      .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                      .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("C_şıkkı");
                                  await ref_c.putFile(c_sikki_gorsel);
                                  var downloadUrl_c = await ref_c.getDownloadURL();
                                  url_c = downloadUrl_c.toString();
                                } else {
                                  url_c = "";
                                }

                                if(d_sikki_gorsel != null ) {
                                  final Reference ref_d = await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi)
                                      .child("sinavlar").child("olusturulan_sinavlar").child(AtaWidget.of(context).sinav_baslik_sinavOlustur).child("sorular")
                                      .child(AtaWidget.of(context).baslik_sinavOlustur).child("şıklar").child("D_şıkkı");
                                  await ref_d.putFile(d_sikki_gorsel);
                                  var downloadUrl_d = await ref_d.getDownloadURL();
                                  url_d = downloadUrl_d.toString();
                                }  else {
                                  url_d = "";
                                }

                                await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).update({"soru_yuklendi": true});
                                var subCol_newDoc =  await collectionreference.doc(AtaWidget.of(context).idnewDoc_sinavOlustur).collection("sorular")
                                    .add({"gorsel_soru": url, "baslik": AtaWidget.of(context).baslik_sinavOlustur, "gorsel_cevap": "", "metinsel_cevap": "",
                                  "metinsel_soru": AtaWidget.of(context).soru_metni_sinavOlustur,
                                  "soru_testmi": AtaWidget.of(context).soru_testmi_sinavOlustur, "A_gorsel": url_a, "B_gorsel": url_b, "C_gorsel": url_c,
                                  "D_gorsel": url_d, "dogru_sik" : dogru_sik,
                                  "A_metinsel": a_sikki_metin, "B_metinsel": b_sikki_metin, "C_metinsel": c_sikki_metin, "D_metinsel": d_sikki_metin,
                                  "puan": _puan, "tarih": DateTime.now().toString()});

                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tüm şıklar ve soru başarıyla eklendi."),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));

                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Doğru cevap: " + dogru_sik + ") şıkkı olarak belirlediniz."),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide ),));
                                AtaWidget.of(context).id_subCol_newDoc_sinavOlustur = await subCol_newDoc.id;
                                AtaWidget.of(context).harf_sinavOlustur = "a";
                                AtaWidget.of(context).soru_testmi_sinavOlustur = false; url = ""; url_a = "" ; url_b = "" ; url_c = "" ; url_d = "" ; dogru_sik = "";
                                a_sikki_metin = "" ;  b_sikki_metin = "" ;  c_sikki_metin = "" ;  d_sikki_metin = "" ; puan = ""; _puan = -1;
                                url = "";

                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                    SinavOlusturPage(collectionreference: collectionreference, storageReference: storageReference,)));

//                                setState(() {});

                                Navigator.of(context, rootNavigator: true).pop('dialog');
                              } else {
                                AlertDialog alertDialog = new AlertDialog (
                                  title: Text("HATA: ", style: TextStyle(color: Colors.red)),
                                  content: Text("Sorunuz için doğrı şık belirlemediniz. Lütfen şıkları tekrar girerek doğru şıkkı belirleyiniz."),
                                );showDialog(context: context, builder: (_) => alertDialog) ;
                              }
                            }
                          },
                        ),
                      ),
                    ],),
                  ],
                );
              });
        },),
      ],
    );showDialog(context: context, builder: (_) => alertDialog );
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
            toolbarTitle: 'Görseli Kırp',
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
