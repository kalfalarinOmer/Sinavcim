
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/MesajGonder.dart';
import 'package:sinavci/Helpers/Reklam.dart';

class Bildirimler extends StatefulWidget {
  final okunan_bildirimler; final okunan_bildirimler_id; final okunmayan_bildirimler; final okunmayan_bildirimler_id;
  const Bildirimler({Key key, this.okunan_bildirimler, this.okunan_bildirimler_id, this.okunmayan_bildirimler, this.okunmayan_bildirimler_id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BildirimlerState(this.okunan_bildirimler, this.okunan_bildirimler_id, this.okunmayan_bildirimler, this.okunmayan_bildirimler_id);
  }

}

class BildirimlerState extends State<Bildirimler> {
  final okunan_bildirimler; final okunan_bildirimler_id; final okunmayan_bildirimler; final okunmayan_bildirimler_id;
  BildirimlerState(this.okunan_bildirimler, this.okunan_bildirimler_id, this.okunmayan_bildirimler, this.okunmayan_bildirimler_id);

  List <dynamic> _bildirimler = [];
  List <dynamic> _bildirimler_id = [];
  List <dynamic> bildirimi_okuyanlar = [];


  Reklam _reklam = new Reklam();
  void initState() {
    _reklam.createInterad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              title: Wrap(children: [
                Text("TÜM BİLDİRİMLER"),
                Text("Bildirimler tarihlerine göre sondan başa sıralanmıştır.", style: TextStyle(fontSize: 12, color: Colors.white)),
              ]),
            )
          ],
        body: AtaWidget.of(context).bildirimler == null || AtaWidget.of(context).bildirimler.length == 0 ?
        Center(
          child: ListTile(
            title: Text("Hiç bildirim bulunamadı."
              ,style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
            ),),
        ) :
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5,),
              Text("1) Koyu renkli bildirimler okunmamış olanlardır.",
                style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
              SizedBox(height: 5,),
              Text("2) Bildirimleri görüntülemek için tıklayınız. Tıkladığınız bildirimler okundu olarak işaretlenir.",
                style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
              SizedBox(height: 5,),
              Text("3) Sayfayı senkronize etmek veya yaptığınız değişiklikleri uygulamak için sayfayı yenilemeniz gerekebilir.",
                style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), textAlign: TextAlign.center,),


              SingleChildScrollView( physics: ClampingScrollPhysics(),
                child: Theme(data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all(Colors.indigo),
                  ),
                ),
                  child: Scrollbar( thickness: 10,
                    child: Container( height: 600,
                        child: ListView.builder(
                          itemCount: AtaWidget.of(context).bildirimler.length,
                          itemBuilder: (context, index) {
                            final map_bildirimler = AtaWidget.of(context).bildirimler[index];
                            final id_bildirimler = AtaWidget.of(context).bildirimler_id[index];

                            return Padding(padding: EdgeInsets.only(right: 10),
                              child: Card( elevation: 50,
                                color: okunmayan_bildirimler.contains(map_bildirimler) ? Colors.blue.shade100 : Colors.white,
                                child: ListTile(
                                  title: RichText(text: TextSpan(
                                      style: TextStyle(), children:<TextSpan>[
                                    TextSpan(text: "konu: ", style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),),
                                    TextSpan(text: map_bildirimler["konu"].toString().toUpperCase(),
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ]),),

                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(text: TextSpan(
                                              style: TextStyle(), children:<TextSpan>[
                                            TextSpan(text: "mesaj: ", style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),),
                                            TextSpan(text: map_bildirimler["mesaj"].toString().length < 50 ? map_bildirimler["mesaj"]
                                                : map_bildirimler["mesaj"].toString().substring(0, 50) + "...",
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 13)),
                                          ]),),
                                          SizedBox(height: 5,),
                                          Wrap( direction: Axis.horizontal,
                                              children: [
                                                Text("tarih: ", style: TextStyle(fontStyle: FontStyle.italic,)),
                                                Text(map_bildirimler["tarih"].toString().substring(0, 16),
                                                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                                              ] ),
                                        ]
                                    ),
                                  ),

                                  trailing: Wrap( direction: Axis.vertical, spacing: 4,
                                      children: [
                                        Text("gönderen: ", style: TextStyle(fontStyle: FontStyle.italic,)),
                                        Text(map_bildirimler["gonderen_adi"], style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),

                                      ] ),
                                  onTap: () async {
                                    _reklam.showInterad();

                                    _bildirimiGor(map_bildirimler, id_bildirimler);

                                    await FirebaseFirestore.instance.collection("bildirimler").doc(id_bildirimler).get()
                                        .then((bildirim) {
                                      bildirimi_okuyanlar = bildirim.get("okuyanlar");
                                      if(bildirimi_okuyanlar.contains(AtaWidget.of(context).kullanicimail)){
                                        print("bildirim zaten okundu olarak işaretlendi");
                                      } else {
                                        bildirimi_okuyanlar.add(AtaWidget.of(context).kullanicimail);
                                        bildirim.reference.update({"okuyanlar" : bildirimi_okuyanlar});
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bildirim okundu olarak işaretlenmiştir."),
                                          action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
                                      }

                                    });

                                  },
                                ),
                              ),
                            );
                          },
                        ),

                    ),
                  )),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.refresh_sharp, size: 40, color: Colors.white,), tooltip: "Yenile", backgroundColor: Colors.indigo,
          onPressed: () async {
            _reklam.showInterad();

            AtaWidget.of(context).bildirimler.clear();
            AtaWidget.of(context).okunmayan_bildirimler.clear();
            AtaWidget.of(context).okunan_bildirimler.clear();
            _bildirimler_id.clear();
            _bildirimler.clear();
            okunan_bildirimler.clear();
            okunmayan_bildirimler.clear();
            okunan_bildirimler_id.clear();
            okunmayan_bildirimler_id.clear();

            await FirebaseFirestore.instance.collection("bildirimler").where("alicilar_mail", arrayContains: AtaWidget.of(context).kullanicimail).get()
                .then((bildirimler) => bildirimler.docs.forEach((bildirim) {
              _bildirimler.add(bildirim.data());
              _bildirimler_id.add(bildirim.id);
            }));
            AtaWidget.of(context).bildirimler = _bildirimler;
            AtaWidget.of(context).bildirimler_id = _bildirimler_id;

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
            AtaWidget.of(context).okunmayan_bildirimler = okunmayan_bildirimler;
            AtaWidget.of(context).okunan_bildirimler = okunan_bildirimler;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Bildirimler( okunan_bildirimler: okunan_bildirimler,
              okunan_bildirimler_id: okunan_bildirimler_id, okunmayan_bildirimler_id: okunmayan_bildirimler_id, okunmayan_bildirimler: okunmayan_bildirimler,
            )));

          }),
      bottomNavigationBar: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),),
    );
  }

  void _bildirimiGor(dynamic map_bildirimler, dynamic id_bildirimler) {
    AlertDialog alertdialog = new AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap( direction: Axis.vertical, spacing: 4,
              children: [
                Text("gönderen: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline)),
                Text(map_bildirimler["gonderen_adi"], style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
              ] ),
          Wrap( direction: Axis.vertical,
              children: [
                Text("tarih: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline)),
                Text(map_bildirimler["tarih"].toString().substring(0, 10),
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                Text(map_bildirimler["tarih"].toString().substring(11, 16),
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
              ] ),
        ],
      ),
      content: Container( height: 300, width: 300,
        child: ListView(
          children: [
            ListTile(
              title: Text("konu: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),),
              subtitle: Text(map_bildirimler["konu"].toString().toUpperCase(),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            ListTile(
              title: Text("mesaj: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),),
              subtitle: Text(map_bildirimler["mesaj"],
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
      actions: [
        Visibility( visible: AtaWidget.of(context).kullaniciadi == "Yönetici Kullanıcı" ? true : false,
          child: FloatingActionButton.extended( heroTag: "yanitla", backgroundColor: Colors.indigo, elevation: 50, icon: Icon(Icons.arrow_back_rounded),
              onPressed: (){
                yanitla(map_bildirimler, id_bildirimler);
              },
              label: Text("Yanıtla", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertdialog);
  }

  void yanitla(dynamic map_bildirimler, dynamic id_bildirimler) async {
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Yanıtınız başarıyla gönderilmiştir."),
                action: SnackBarAction(label: "Gizle", onPressed: () => SnackBarClosedReason.hide),));
            }

          },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);
  }
}
