import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/ListelerDetaylarPages/OlusturulanSinavPage.dart';

class FormHelper extends StatefulWidget{
  final imageSelected; final islem; final map_solusturulan; final id_solusturulan; final collectionReference; final storageReference; final mapSoru; final idSoru;
  const FormHelper({Key key, this.imageSelected, this.islem, this.map_solusturulan, this.id_solusturulan, this.collectionReference, this.storageReference,
    this.mapSoru, this.idSoru})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {

    return FormHelperState(this.imageSelected, this.islem, this.map_solusturulan, this.id_solusturulan, this.collectionReference, this.storageReference,
        this.mapSoru, this.idSoru);
  }

}

class FormHelperState extends State<FormHelper> {
  File imageSelected; String islem; final map_solusturulan; final id_solusturulan; final collectionReference; final storageReference; final mapSoru; final idSoru;
  FormHelperState(this.imageSelected, this.islem, this.map_solusturulan, this.id_solusturulan, this.collectionReference, this.storageReference,
      this.mapSoru, this.idSoru);

  GlobalKey<FormState> _formKey_1 = GlobalKey<FormState>();
  GlobalKey<FormState> _formKey_2 = GlobalKey<FormState>();
  GlobalKey<FormState> _formKey_3 = GlobalKey<FormState>();
  GlobalKey<FormState> _formKey_4 = GlobalKey<FormState>();
  TextEditingController _controller_1 = TextEditingController();
  TextEditingController _controller_2 = TextEditingController();
  TextEditingController _controller_3 = TextEditingController();
  TextEditingController _controller_4 = TextEditingController();

  Reklam _reklam = new Reklam();
  @override
  void initState() {
    _reklam.createInterad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool _bold_altbilgi = map_solusturulan["altbilgi_kalin"];
    bool _italic_altbilgi = map_solusturulan["altbilgi_italic"];
    String _punto_altbilgi = map_solusturulan["altbilgi_punto"];
    bool _bold_ustbilgi = map_solusturulan["ustbilgi_kalin"];
    bool _italic_ustbilgi = map_solusturulan["ustbilgi_italic"];
    String _punto_ustbilgi = map_solusturulan["ustbilgi_punto"];

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("FORMu DOLDUR")),automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(height: 10,),
            Center(child: ListTile( leading: Icon(Icons.looks_one_rounded, color: Colors.orange,),
              title: Text("ONAYLA butonuna bastığınızda buradan girdiğiniz yeni bilgi yapmak istediğiniz işleme aktarılır. Aynı işlemi tekrar "
                "açtığınızda girdiğiniz yeni bilgiyi yüklemeye hazır olarak görürsünüz.", textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),)),
            SizedBox(height: 10,),
            Center(child: ListTile( leading: Icon(Icons.looks_two, color: Colors.orange,),
              title: Text("YÜKLE butonuna bastığınızda yüklemeniz doğrudan bu sayfadan yapılır, ayrıca önceki sayfada işlemi tekrarlamanıza gerek yoktur.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),)),
            SizedBox(height: 10,),
            Center(child: ListTile( leading: Icon(Icons.looks_3, color: Colors.orange,),
              title: Text("VAZGEÇ butonuna bastığınızda işlem sonlandırılır. Bilgi girişi yaptıysanız giriş sıfırlanır.", textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),)),
            SizedBox(height: 10,),
            Center(child: ListTile( leading: Icon(Icons.looks_4, color: Colors.orange,),
              title: Text("Lütfen işleminizi sonlandırmak ve sayfadan ayrılmak için aşağıdaki butonları kullanınız.", textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),)),
            SizedBox(height: 20,),

            Visibility( visible: imageSelected != null ? true : false,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 20,
                  child: Container(height: 600,
                    child: imageSelected == null ? Center(child: Text("Resim bulunamadı."),)
                        : Image.file(imageSelected, fit: BoxFit.contain, ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Form(key: _formKey_1,
                child: TextFormField(
                    controller: _controller_1,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: islem == "aciklama" ? "Açıklamanızı giriniz." : islem == "metinsel_cevap" ? "Cevap/Çözüm giriniz."
                            : islem == "metinsel_sik" || islem == "metinsel_sik_a" || islem == "metinsel_sik_b" || islem == "metinsel_sik_c"
                              || islem == "metinsel_sik_d" ? "Şıkkı giriniz."
                            : islem == "metinsel_soru" || islem == "gorsel_soru" ? "Soru başlığını giriniz."
                            : islem == "ogrenci_cevap" ? "Cevabınız için başlık giriniz."
                            : islem == "altbilgi" ? "Altbilgiyi giriniz." : islem == "ustbilgi" ? "üstbilgiyi giriniz" : islem == "yazili" ? "Yazılı başlığını giriniz."
                        : "Alan bilgi girişini buraya yapınız."),
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                    validator: (String bilgi) {
                      if (bilgi.isEmpty) {return "Alan boş bırakılamaz.";
                      } return null;
                    }
                ),
              ),
            ),
            Visibility( visible: islem == "a_sikki_gorsel" || islem == "b_sikki_gorsel" || islem == "c_sikki_gorsel" || islem == "d_sikki_gorsel"
                || islem == "ustbilgi" || islem == "altbilgi"? false : true,
                child: SizedBox(height: 20,)),
            Visibility( visible: islem == "aciklama" || islem == "metinsel_cevap" || islem == "metinsel_sik_a" || islem == "metinsel_sik_b"
                || islem == "metinsel_sik_c" || islem == "metinsel_sik_d" || islem == "a_sikki_gorsel" || islem == "b_sikki_gorsel" || islem == "c_sikki_gorsel"
                || islem == "d_sikki_gorsel" || islem == "gorsel_soru" || islem == "metinsel_sik" || islem == "ustbilgi" || islem == "altbilgi"
                || islem == "yazili" ? false : true,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: Form(key: _formKey_2,
                  child: TextFormField(
                      controller: _controller_2,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: islem == "metinsel_soru" ? "Soru metnini giriniz."
                              : islem == "ogrenci_cevap" ? "Cevabınız için açıklama giriniz."
                              : "Alan bilgi girişini buraya yapınız."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String bilgi) {
                        if (bilgi.isEmpty) {return "Alan boş bırakılamaz.";
                        } return null;
                      }
                  ),
                ),
              ),
            ),
            Visibility( visible: islem == "aciklama" || islem == "metinsel_cevap" || islem == "metinsel_sik_a" || islem == "metinsel_sik_b"
                || islem == "metinsel_sik_c" || islem == "metinsel_sik_d" || islem == "a_sikki_gorsel" || islem == "b_sikki_gorsel" || islem == "c_sikki_gorsel"
                || islem == "d_sikki_gorsel" || islem == "gorsel_soru" || islem == "metinsel_sik" || islem == "ustbilgi" || islem == "altbilgi"
                || islem == "yazili" ? false : true,
                child: SizedBox(height: 20,)),
            Visibility( visible: islem == "aciklama" || islem == "metinsel_cevap" || islem == "metinsel_sik_a" || islem == "metinsel_sik_b"
                || islem == "metinsel_sik_c" || islem == "metinsel_sik_d" || islem == "a_sikki_gorsel" || islem == "b_sikki_gorsel" || islem == "c_sikki_gorsel"
                || islem == "d_sikki_gorsel" || islem == "metinsel_sik" || islem == "ogrenci_cevap" || islem == "ustbilgi" || islem == "altbilgi"
                || islem == "yazili" ? false : true,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: Form(key: _formKey_3,
                  child: TextFormField(
                      controller: _controller_3,
                      maxLines: null,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Sayı girmeniz gerekmektedir",
                          labelText: islem == "metinsel_soru" || islem == "gorsel_soru" ? "Sorunun puanını giriniz."
                          : "Alan bilgi girişini buraya yapınız."),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      validator: (String bilgi) {
                        if (bilgi.isEmpty) {return "Alan boş bırakılamaz.";
                        } return null;
                      }
                  ),
                ),
              ),
            ),
            Visibility( visible: islem == "aciklama" || islem == "metinsel_cevap" || islem == "metinsel_sik_a" || islem == "metinsel_sik_b"
                || islem == "metinsel_sik_c" || islem == "metinsel_sik_d" || islem == "a_sikki_gorsel" || islem == "b_sikki_gorsel" || islem == "c_sikki_gorsel"
                || islem == "d_sikki_gorsel" || islem == "metinsel_sik" || islem == "ogrenci_cevap" || islem == "ustbilgi" || islem == "altbilgi"
                || islem == "yazili" ? false : true,
                child: SizedBox(height: 20,)),
            Visibility( visible: islem == "aciklama" || islem == "metinsel_cevap" || islem == "metinsel_sik_a" || islem == "metinsel_sik_b"
                || islem == "metinsel_sik_c" || islem == "metinsel_sik_d" || islem == "a_sikki_gorsel" || islem == "b_sikki_gorsel" || islem == "c_sikki_gorsel"
                || islem == "d_sikki_gorsel" || islem == "metinsel_sik" || islem == "ogrenci_cevap" || islem == "yazili" || islem == "metinsel_soru"
                || islem == "gorsel_soru" ? false : true,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Aşağıda, girdiğiniz bilgilerin görünümünü düzenleyebileceğiniz araçlar mevcuttur. Herhangi bir işlem yapmazsanız ilk giriş ise "
                    "altbilgi ve üstbilgileriniz standart görünümde değilse bir önceki görünümde görüntülenir.",
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic), textAlign: TextAlign.justify,),
              ),
            ),
            Visibility( visible:  islem == "aciklama" || islem == "metinsel_cevap" || islem == "metinsel_sik_a" || islem == "metinsel_sik_b"
                || islem == "metinsel_sik_c" || islem == "metinsel_sik_d" || islem == "a_sikki_gorsel" || islem == "b_sikki_gorsel" || islem == "c_sikki_gorsel"
                || islem == "d_sikki_gorsel" || islem == "metinsel_sik" || islem == "ogrenci_cevap" || islem == "yazili" || islem == "metinsel_soru"
                || islem == "gorsel_soru" ? false : true,
              child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container( width: 80,
                    child: Form( key: _formKey_4,
                      child: TextFormField( controller: _controller_4,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "punto", hintText: "sayı giriniz"),
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
                    if( islem == "ustbilgi" ){
                      _bold_ustbilgi == false || _bold_ustbilgi == null ?
                      _bold_ustbilgi = true : _bold_ustbilgi = false;
                    }
                    else if( islem == "altbilgi" ){
                      _bold_altbilgi == false || _bold_altbilgi == null ?
                      _bold_altbilgi = true : _bold_altbilgi = false;
                    }
                  }),
                  IconButton(icon: Icon(Icons.format_italic_sharp), onPressed: (){
                    if( islem == "ustbilgi" ){
                      _italic_ustbilgi == false || _italic_ustbilgi == null ?
                      _italic_ustbilgi = true : _italic_ustbilgi = false ;
                    }
                    else if( islem == "altbilgi" ){
                      _italic_altbilgi == false || _italic_altbilgi == null ?
                      _italic_altbilgi = true : _italic_altbilgi = false ;
                    }
                  }),
                ],
              ),
            ),
            Visibility( visible: islem == "aciklama" || islem == "metinsel_cevap" || islem == "metinsel_sik_a" || islem == "metinsel_sik_b"
                || islem == "metinsel_sik_c" || islem == "metinsel_sik_d" || islem == "a_sikki_gorsel" || islem == "b_sikki_gorsel" || islem == "c_sikki_gorsel"
                || islem == "d_sikki_gorsel" || islem == "metinsel_sik" || islem == "ogrenci_cevap" ? false : true,
                child: SizedBox(height: 20,)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(icon: Icon(Icons.check_circle, color: Colors.greenAccent,),label: Text(
                    islem == "metinsel_soru" || islem == "gorsel_soru" || islem == "metinsel_sik_a" || islem == "metinsel_sik_b" || islem == "metinsel_sik_c"
                        || islem == "metinsel_sik_d" || islem == "ogrenci_cevap" ? "Onayla"
                        : "Yükle"),
                  elevation: 20, heroTag: "formu_OnaylaYukle",
                  onPressed: () async {
                    _reklam.showInterad();

                  if ( islem == "aciklama" ) {
                    if(_formKey_1.currentState.validate()){
                      _formKey_1.currentState.save();

                      final newaciklama = _controller_1.text.trim();
                      await collectionReference.doc(id_solusturulan).update({"aciklama": newaciklama});

//                    setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Açıklama başarıyla güncellendi, sayfayı yenilediğinizde değişiklikler "
                          "uygulanacaktır."),
                        action: SnackBarAction(label: "Gizle", onPressed: (){
                          SnackBarClosedReason.hide;
                        },),));

                      AtaWidget.of(context).formHelper = null;
//                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      Navigator.pop(context);

//                      Navigator.pop(context);
                    }
                  }

                  if ( islem == "metinsel_cevap" ) {
                    final newaciklama = _controller_1.text.trim();
                    await collectionReference.doc(id_solusturulan.toString()).collection("sorular")
                        .doc(idSoru.toString()).update({"gorsel_cevap": "", "metinsel_cevap": newaciklama});

                    try {
                      final Reference ref = await FirebaseStorage.instance.ref().child("users")
                          .child(map_solusturulan["hazirlayan"])
                          .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                          .child("${mapSoru["baslik"]}").child("${mapSoru["baslik"]} nın cevabı");
                      await ref.delete();
                    } catch (e) {debugPrint(e.toString());}

//                      setState(() {});

                    AtaWidget.of(context).formHelper = null;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Çözüm başarıyla eklendi.",),
                      action: SnackBarAction(label: "Gizle", onPressed: (){
                      SnackBarClosedReason.hide;
                    },),));
                    Navigator.pop(context);
                  }

                  if ( islem == "metinsel_soru" ) {
                    if(_formKey_1.currentState.validate() && _formKey_2.currentState.validate() && _formKey_3.currentState.validate() ) {
                      _formKey_1.currentState.save();
                      _formKey_2.currentState.save();
                      _formKey_3.currentState.save();

                      AtaWidget.of(context).formHelper_metinselSoru_baslik = _controller_1.text.trim();
                      AtaWidget.of(context).formHelper_metinselSoru_soruMetni = _controller_2.text.trim();
                      AtaWidget.of(context).formHelper_metinselSoru_puan = _controller_3.text.trim();
                      AtaWidget.of(context).metinsel_soru_bitti = true;
                      Navigator.pop(context);
                      AlertDialog alertdialog = new AlertDialog(
                        title: Text("Form sayfasında girdiğiniz veriler hafızaya kaydedilmiştir. Değişkliklerin uygulanması için aynı şekilde *Soru Ekle butonunu kullanarak "
                            "metinsel soru ekleme işlemini tekrarlayınız ve sorunuzun yüklenmesi için *Soruyu Yükle butonuna basınız."),
                      ); showDialog(context: context, builder: (_) => alertdialog);
                    }
                  }

                  if ( islem == "metinsel_sik_a") {
                    if(_formKey_1.currentState.validate()){
                      _formKey_1.currentState.save();
                      AtaWidget.of(context).metinsel_sik_a = _controller_1.text.trim();
                      Navigator.pop(context);
                      AlertDialog alertdialog = new AlertDialog(
                        title: Text("Form sayfasında girdiğiniz veriler hafızaya kaydedilmiştir. Değişkliklerin uygulanması ve kaldığınız yerden devam etmek için "
                            "sağ alttaki *DevamEt butonuna basınız."),
                      ); showDialog(context: context, builder: (_) => alertdialog);
                    }
                  }
                  if ( islem == "metinsel_sik_b") {
                    if(_formKey_1.currentState.validate()){
                      _formKey_1.currentState.save();
                      AtaWidget.of(context).metinsel_sik_b = _controller_1.text.trim();
                      Navigator.pop(context);
                      AlertDialog alertdialog = new AlertDialog(
                        title: Text("Form sayfasında girdiğiniz veriler hafızaya kaydedilmiştir. Değişkliklerin uygulanması ve kaldığınız yerden devam etmek için "
                            "sağ alttaki *DevamEt butonuna basınız."),
                      ); showDialog(context: context, builder: (_) => alertdialog);
                    }
                  }
                  if ( islem == "metinsel_sik_c") {
                    if(_formKey_1.currentState.validate()){
                      _formKey_1.currentState.save();
                      AtaWidget.of(context).metinsel_sik_c = _controller_1.text.trim();
                      Navigator.pop(context);
                      AlertDialog alertdialog = new AlertDialog(
                        title: Text("Form sayfasında girdiğiniz veriler hafızaya kaydedilmiştir. Değişkliklerin uygulanması ve kaldığınız yerden devam etmek için "
                            "sağ alttaki *DevamEt butonuna basınız."),
                      ); showDialog(context: context, builder: (_) => alertdialog);
                    }
                  }
                  if ( islem == "metinsel_sik_d") {
                    if(_formKey_1.currentState.validate()){
                      _formKey_1.currentState.save();
                      AtaWidget.of(context).metinsel_sik_d = _controller_1.text.trim();
                      Navigator.pop(context);
                      AlertDialog alertdialog = new AlertDialog(
                        title: Text("Form sayfasında girdiğiniz veriler hafızaya kaydedilmiştir. Değişkliklerin uygulanması ve kaldığınız yerden devam etmek için "
                            "sağ alttaki *DevamEt butonuna basınız."),
                      ); showDialog(context: context, builder: (_) => alertdialog);
                    }
                  }
/*
                  if(islem == "a_sikki_gorsel") {
                    AtaWidget.of(context).a_sikki_gorsel = imageSelected;
                    AtaWidget.of(context).metinsel_soru_bitti = true;
                    Navigator.pop(context);
                    AlertDialog alertdialog = new AlertDialog(
                      title: Text("Resim hafızaya kaydedilmiştir. Değişkliklerin uygulanması ve kaldığınız yerden devam etmek için "
                          "sağ alttaki *DevamEt butonuna basınız."),
                    ); showDialog(context: context, builder: (_) => alertdialog);
                  }
                  if(islem == "b_sikki_gorsel") {
                    AtaWidget.of(context).b_sikki_gorsel = imageSelected;
                    AtaWidget.of(context).metinsel_soru_bitti = false;
                    AtaWidget.of(context).a_sikki_bitti = false;
                    Navigator.pop(context);
                    AlertDialog alertdialog = new AlertDialog(
                      title: Text("Resim hafızaya kaydedilmiştir. Değişkliklerin uygulanması ve kaldığınız yerden devam etmek için "
                          "sağ alttaki *DevamEt butonuna basınız."),
                    ); showDialog(context: context, builder: (_) => alertdialog);
                  }
                  if(islem == "c_sikki_gorsel") {
                    AtaWidget.of(context).c_sikki_gorsel = imageSelected;
                    AtaWidget.of(context).metinsel_soru_bitti = false;
                    AtaWidget.of(context).a_sikki_bitti = false;
                    AtaWidget.of(context).b_sikki_bitti = false;
                    Navigator.pop(context);
                    AlertDialog alertdialog = new AlertDialog(
                      title: Text("Resim hafızaya kaydedilmiştir. Değişkliklerin uygulanması ve kaldığınız yerden devam etmek için "
                          "sağ alttaki *DevamEt butonuna basınız."),
                    ); showDialog(context: context, builder: (_) => alertdialog);
                  }
                  if(islem == "d_sikki_gorsel") {
                    AtaWidget.of(context).d_sikki_gorsel = imageSelected;
                    AtaWidget.of(context).metinsel_soru_bitti = false;
                    AtaWidget.of(context).a_sikki_bitti = false;
                    AtaWidget.of(context).b_sikki_bitti = false;
                    AtaWidget.of(context).c_sikki_bitti = false;
                    Navigator.pop(context);
                    AlertDialog alertdialog = new AlertDialog(
                      title: Text("Resim hafızaya kaydedilmiştir. Değişkliklerin uygulanması ve kaldığınız yerden devam etmek için "
                          "sağ alttaki *DevamEt butonuna basınız."),
                    ); showDialog(context: context, builder: (_) => alertdialog);
                  }
*/
                  if ( islem == "gorsel_soru" ) {
                    if(_formKey_1.currentState.validate() && _formKey_3.currentState.validate() ) {
                      _formKey_1.currentState.save();
                      _formKey_3.currentState.save();

                      AtaWidget.of(context).formHelper_gorselSoru_baslik = _controller_1.text.trim();
                      AtaWidget.of(context).formHelper_gorselSoru_puan = _controller_3.text.trim();
                      Navigator.pop(context);
                      AlertDialog alertdialog = new AlertDialog(
                        title: Text("Form sayfasında girdiğiniz veriler hafızaya kaydedilmiştir. Değişkliklerin uygulanması için aynı şekilde *Soru Ekle butonunu kullanarak "
                            "metinsel soru ekleme işlemini tekrarlayınız ve sorunuzun yüklenmesi için *Soruyu Yükle butonuna basınız."),
                      ); showDialog(context: context, builder: (_) => alertdialog);
                    }
                  }

                  if ( islem == "metinsel_sik" ) {
                    if(_formKey_1.currentState.validate()){
                      _formKey_1.currentState.save();

                      try {
                        final Reference ref_sik = await FirebaseStorage.instance.ref().child("users")
                            .child(AtaWidget.of(context).kullaniciadi)
                            .child("sinavlar").child("olusturulan_sinavlar").child(map_solusturulan["baslik"]).child("sorular")
                            .child(mapSoru["baslik"]).child("şıklar").child("${AtaWidget.of(context).metinsel_sik}_şıkkı");
                        await ref_sik.delete();

                      } catch (e) { print(e.toString()); }

                      final sik_sikki_metin = _controller_1.text.trim();
                      await collectionReference.doc(id_solusturulan).collection("sorular").doc(idSoru.toString())
                          .update({"${AtaWidget.of(context).metinsel_sik}_gorsel": "", "${AtaWidget.of(context).metinsel_sik}_metinsel": sik_sikki_metin,});

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Şık başarıyla güncellendi, sayfayı yenilediğinizde değişiklikler "
                          "uygulanacaktır."),
                        action: SnackBarAction(label: "Gizle", onPressed: (){
                          SnackBarClosedReason.hide;
                        },),));

                      AtaWidget.of(context).formHelper = null;
                      AtaWidget.of(context).metinsel_sik = null;
//                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      Navigator.pop(context);

//                      Navigator.pop(context);
                    }
                  }

                  if ( islem == "ogrenci_cevap" ) {
                    if(_formKey_1.currentState.validate() && _formKey_2.currentState.validate() ) {
                      _formKey_1.currentState.save();
                      _formKey_2.currentState.save();

                      AtaWidget.of(context).formHelper_ogrenci_cevap_baslik = _controller_1.text.trim();
                      AtaWidget.of(context).formHelper_ogrenci_cevap_aciklama = _controller_2.text.trim();
                      Navigator.pop(context);
                      AlertDialog alertdialog = new AlertDialog(
                        title: Text("Form sayfasında girdiğiniz veriler hafızaya kaydedilmiştir. Çözüm ekleme işlemini tekrarladığınızda değişkillikler "
                            "sayfada görülecektir."),
                      ); showDialog(context: context, builder: (_) => alertdialog);
                    }
                  }

                  if ( islem == "ustbilgi" || islem == "altbilgi" || islem == "yazili" ) {
                    AlertDialog alertDialog = new AlertDialog (
                      title: Text(
                          islem == "ustbilgi" ?
                          "Sınavınızın çıktı görünümünde en üstte görünmesini istediğiniz notunuzu yazınız. Yazılı başlığı hazırlamak için *Yazılı* "
                              "butonunu kullanabilirsiniz. Sınav çıktısı için varsa yazılı girişiniz iptal edilecektir. Halihazırdaki üstbilgiyi kaldırmak için ise "
                              "üstbilgi alanına boşluk bırakıp onaylamanız yeterlidir. En iyi görünüm için puntoyu en fazla 16 seçmenizi tavsiye ederiz."
                              : islem == "altbilgi" ? "Daha önceden giriş yapıldıysa mevcut altbilgi, altbilgi alanında gösterilmektedir. Değiştirmek için yeni "
                              "altbilgiyi girerek, kaldırmak için ise boşluk bırakarak onaylamanız yeterlidir."
                              : "Sınavınızın çıktısını yazılı formatında görüntülemeyi tercih ettiniz. Yazılınızın başlığını giriniz. Başlık altında Ad-Soyad, Sınıf/No ve "
                              "Puan alanı otomatik olarak gelecektir. Daha önce girdiğiniz üstbilgi ve ayarları silinecektir.",
                          textAlign: TextAlign.justify, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      actions: [
                        MaterialButton(child: Text("Onayla", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 3, fontSize: 18)),
                            onPressed: () async {

                              if(islem == "ustbilgi"){
                                if(_formKey_1.currentState.validate()){
                                  _formKey_1.currentState.save();
                                  _formKey_4.currentState.save();
                                  final newmetin = _controller_1.text.trim();

                                  await collectionReference.doc(id_solusturulan).update({"ustbilgi": newmetin, "yazili_girildi": false, "yazili_baslik": "",
                                  });
                                }

                                if(_formKey_4.currentState.validate()){
                                  _formKey_4.currentState.save();
                                  String new_punto_ustbilgi = _controller_4.text.trim();
                                  await collectionReference.doc(id_solusturulan).update({"ustbilgi_punto": new_punto_ustbilgi,
                                  });
                                }

                                await collectionReference.doc(id_solusturulan).update({"ustbilgi_kalin": _bold_ustbilgi, "ustbilgi_italic": _italic_ustbilgi,});


                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                Navigator.of(context, rootNavigator: true).pop("dialog");

                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                    OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: true,
                                        collectionReference: collectionReference, storageReference: storageReference)));
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                              if(islem == "altbilgi") {
                                if(_formKey_1.currentState.validate()){
                                  _formKey_1.currentState.save();
                                  _formKey_4.currentState.save();
                                  final newmetin = _controller_1.text.trim();

                                  await collectionReference.doc(id_solusturulan).update({"altbilgi": newmetin,});
                                }

                                if(_formKey_4.currentState.validate()){
                                  _formKey_4.currentState.save();
                                  String new_punto_altbilgi = _controller_4.text.trim();

                                  await collectionReference.doc(id_solusturulan).update({"altbilgi_punto": new_punto_altbilgi,});
                                }

                                await collectionReference.doc(id_solusturulan).update({"altbilgi_kalin": _bold_altbilgi, "altbilgi_italic": _italic_altbilgi,});


                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                  action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                Navigator.of(context, rootNavigator: true).pop("dialog");

                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                    OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: true,
                                        collectionReference: collectionReference, storageReference: storageReference)));
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                              if(islem == "yazili"){
                                if(_formKey_1.currentState.validate()){
                                  _formKey_1.currentState.save();
                                  final newmetin = _controller_1.text.trim();

                                  await collectionReference.doc(id_solusturulan).update({"yazili_girildi": true, "yazili_baslik" : newmetin,
                                    "ustbilgi": "", "ustbilgi_punto": "", "ustbilgi_italic": false, "ustbilgi_kalin" : false,});
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İşlem başarılı"),
                                    action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                  Navigator.of(context, rootNavigator: true).pop("dialog");

                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                      OlusturulanSinavPage(map_solusturulan: map_solusturulan, id_solusturulan: id_solusturulan, grid_gorunum: true,
                                          collectionReference: collectionReference, storageReference: storageReference)));
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              }
                            }
                        ),
                      ],
                    );showDialog(context: context, builder: (_) => alertDialog);
                  }

                  }
                ),


                FloatingActionButton.extended(icon: Icon(Icons.cancel_rounded, color: Colors.orangeAccent,),label: Text("Vazgeç"),
                  elevation: 20,  heroTag: "formu_vazgec",
                  onPressed: (){
                    _reklam.showInterad();

                    AtaWidget.of(context).formHelper = null;
                    AtaWidget.of(context).formHelper_metinselSoru_baslik = null;
                    AtaWidget.of(context).formHelper_metinselSoru_soruMetni = null;
                    AtaWidget.of(context).formHelper_metinselSoru_puan = null;
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
                    AtaWidget.of(context).metinsel_sik = null;
                    AtaWidget.of(context).formHelper_ogrenci_cevap_baslik = null;
                    AtaWidget.of(context).formHelper_ogrenci_cevap_aciklama = null;

                    Navigator.pop(context);
                  },),
              ],
            ),
            SizedBox(height: 20,),
/*            ListTile(
              leading: Icon(Icons.warning, color: Colors.redAccent,),
              title: Text("İşlemi sonlandırmak için yukarıdaki ONAYLA yada VAZGEÇ butonlarını kullanınız.", textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                ),
            )
*/          ],
        ),
      ),
      bottomNavigationBar: Visibility(
          child: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),)),
    );
  }

}