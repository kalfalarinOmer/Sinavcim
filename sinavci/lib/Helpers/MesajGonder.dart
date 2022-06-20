import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/ListelerDetaylarPages/GonderilenMesajlar.dart';

class MesajGonder extends StatefulWidget {
  final querySnapshot; final gruptan;
  const MesajGonder({Key key, this.querySnapshot, this.gruptan}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MesajGonderState(this.querySnapshot, this.gruptan);
  }

}

class MesajGonderState extends State<MesajGonder>{
  final querySnapshot; final gruptan;
  MesajGonderState(this.querySnapshot, this.gruptan);

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controller_msj = TextEditingController();
  TextEditingController _controller_konu = TextEditingController();

  Reklam _reklam = new Reklam();
  List <dynamic> alicilar_tumu_mail = [];
  List <dynamic> alicilar_tumu_ad = [];
  List <dynamic> alicilar_secili_mail = [];
  List <dynamic> alicilar_secili_ad = [];

  @override
  void initState() {
    _reklam.createInterad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("MESAJ GÖNDER"),
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Aşağıdaki alanları doldurun ve *Gönder butonuna basın. Mesajınızı gelen listenin tümüne yada liste içerisinden seçtiğiniz kişilere gönderebilirsiniz.",
                style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        controller: _controller_konu,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Mesajınızın konusunu yazınız."),
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                        validator: (String bilgi) {
                          if (bilgi.isEmpty) {return "Alan boş bırakılamaz.";
                          } return null;
                        }
                    ),
                    SizedBox(height: 20,),
                    TextFormField(
                        controller: _controller_msj,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Mesajınızı buraya yazınız."),
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                        validator: (String bilgi) {
                          if (bilgi.isEmpty) {return "Alan boş bırakılamaz.";
                          } return null;
                        }
                    ),
                  ]
                ),
              ),
            ),
            SizedBox(height: 20,),
            Container( alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 20),
              child: FloatingActionButton.extended(icon: Icon(Icons.outgoing_mail, ),label: Text("Gönder"),
                elevation: 20,  heroTag: "msjGönder",
                onPressed: (){
                  _reklam.showInterad();
                  if(_formKey.currentState.validate()){
                    _formKey.currentState.save();
                    msj_gonder();
                  }
                },
              ),
            ),
            SizedBox(height: 20,),
            Align( alignment: Alignment.centerRight,
              child: MaterialButton(child: Text("Gönderilen Mesajlar", style: TextStyle(color: Colors.indigo, fontSize: 18, fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.indigo,),),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GonderilenMesajlar()));
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Visibility(
          child: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),)),
    );
  }

  Widget kisilerimiGetir_Widget() {
    return Container(
      height: 300, width: 300,
      child: querySnapshot.size == 0 ?
      Center( child: Text("Listenizde kişi bulunamadı.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),) :
      ListView.builder(
          itemCount: querySnapshot.size,
          itemBuilder: (BuildContext context, int index){
            final map_kisilerim = querySnapshot.docs[index].data();
            final id_kisilerim = querySnapshot.docs[index].id;

            alicilar_tumu_mail.clear();
            alicilar_tumu_ad.clear();
            for ( index = 0; index < querySnapshot.size; index++) {
              alicilar_tumu_mail.add(querySnapshot.docs[index].data()["mail"]);
              alicilar_tumu_ad.add(querySnapshot.docs[index].data()["kullaniciadi"]);
            }

            return Column(
              children: [
                ListTile(
                  title: Text(map_kisilerim["kullaniciadi"] ),
                  subtitle: Text(map_kisilerim["mail"]),
                  onTap: () async {
                    if(alicilar_secili_mail.contains(map_kisilerim["mail"])){
                      alicilar_secili_mail.remove(map_kisilerim["mail"]);
                      alicilar_secili_ad.remove(map_kisilerim["kullaniciadi"]);
                    } else {
                      alicilar_secili_mail.add(map_kisilerim["mail"]);
                      alicilar_secili_ad.add(map_kisilerim["kullaniciadi"]);
                    }
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                    msj_gonder();
                  },
                  trailing: alicilar_secili_mail.contains(map_kisilerim["mail"]) ? Icon(Icons.check_circle) : SizedBox.shrink(),
                ),
                Visibility(visible: map_kisilerim["kullaniciadi"] == "" ? false : true,
                    child: Divider(thickness: 3, color: Colors.indigo)),
              ],
            );
          }),
    );
  }

  void msj_gonder() async {
    final konu = _controller_konu.text.trim();
    final mesaj = _controller_msj.text.trim();
    List <dynamic> okuyanlar = [];

    AlertDialog alertDialog = new AlertDialog(
      title: Text( gruptan == true ? "Grupta bulunan tüm kişileriniz listelenmiştir. *TÜMÜNE_GÖNDER butonu ile mesajı gruptaki tüm kişilerinize yada listeden kişi "
          "seçtikten sonra *SEÇİLİ_KİŞİLERE_GÖNDER butonu ile seçtiğiniz kişilere gönderebilirsiniz." :
        "Tüm kişileriniz listelenmiştir. *TÜMÜNE_GÖNDER butonu ile mesajı tüm kişilerinize yada listeden kişi seçtikten sonra "
          "*SEÇİLİ_KİŞİLERE_GÖNDER butonu ile seçtiğiniz kişilere gönderebilirsiniz.",
        textAlign: TextAlign.justify,
        style: TextStyle(color: Colors.indigo, fontSize: 15, fontWeight: FontWeight.bold),),
      content: kisilerimiGetir_Widget(),
      actions: [
        ElevatedButton(
          child: Text("Tümüne Gönder"),
          onPressed: () async {
            await FirebaseFirestore.instance.collection("bildirimler").add({ "tarih": DateTime.now().toString(), "alicilar_mail" : alicilar_tumu_mail,
              "gonderen_adi" : AtaWidget.of(context).kullaniciadi, "gonderen_mail" : AtaWidget.of(context).kullanicimail, "alicilar_ad" : alicilar_tumu_ad,
              "konu" : konu, "mesaj" : mesaj, "okuyanlar" : okuyanlar,
            });
            Navigator.of(context, rootNavigator: true).pop("dilaog");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mesajınız başarıyla gönderilmiştir."),
              action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MesajGonder(querySnapshot: querySnapshot, gruptan: gruptan,)));
          },
        ),
        ElevatedButton(
          child: Text("Seçili Kişilere Gönder"),
          onPressed: () async {
            await FirebaseFirestore.instance.collection("bildirimler").add({ "tarih": DateTime.now().toString(), "alicilar_mail" : alicilar_secili_mail,
              "gonderen_adi" : AtaWidget.of(context).kullaniciadi, "gonderen_mail" : AtaWidget.of(context).kullanicimail, "alicilar_ad": alicilar_secili_ad,
              "konu" : konu, "mesaj" : mesaj, "okuyanlar" : okuyanlar,
            });
            Navigator.of(context, rootNavigator: true).pop("dilaog");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mesajınız başarıyla gönderilmiştir."),
              action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MesajGonder(querySnapshot: querySnapshot, gruptan: gruptan,)));
          },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);
  }

}