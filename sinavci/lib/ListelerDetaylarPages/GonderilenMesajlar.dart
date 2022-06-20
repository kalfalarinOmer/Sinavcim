import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/Reklam.dart';

class GonderilenMesajlar extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return GonderilenMesajlarState();
  }

}

class GonderilenMesajlarState extends State<GonderilenMesajlar> {

  Reklam _reklam = new Reklam();

  void initState() {
    _reklam.createInterad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) =>
        [
          SliverAppBar(
            title: Wrap(children: [
              Text("GÖNDERİLEN MESAJLAR"),
              Text("Mesajlar tarihlerine göre sondan başa sıralanmıştır.",
                  style: TextStyle(fontSize: 12, color: Colors.white)),
            ]),
          )
        ],
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("bildirimler").where("gonderen_mail", isEqualTo: AtaWidget.of(context).kullanicimail)
                .orderBy("tarih", descending: true).snapshots(),
            builder: (context, snapshot) {
              final querySnapshot = snapshot.data;
              return Container(
                child: querySnapshot.size == 0 ?
                Center(child: ListTile(
                    title: Text("Hiç mesaj bulunamadı.", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
                    ),),
                ) :
                SingleChildScrollView(child: Column(
                  children: [

                    SingleChildScrollView(physics: ClampingScrollPhysics(),
                      child: Theme(data: Theme.of(context).copyWith(scrollbarTheme: ScrollbarThemeData(thumbColor: MaterialStateProperty.all(Colors.indigo),),),
                          child: Scrollbar(thickness: 10, child: Container(height: 600,
                            child: ListView.builder(
                              itemCount: querySnapshot.size,
                              itemBuilder: (context, index) {
                                final map_mesaj = querySnapshot.docs[index].data();
                                final id_mesaj = querySnapshot.docs[index].id;

                                return Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Card(elevation: 50, color: Colors.blue.shade100,
                                    child: ListTile(
                                      title: RichText(text: TextSpan(style: TextStyle(),
                                          children: <TextSpan>[
                                            TextSpan(text: "konu: ", style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),),
                                            TextSpan(text: map_mesaj["konu"].toString().toUpperCase(), style: TextStyle(color: Colors.black,
                                                fontWeight: FontWeight.bold, fontSize: 13)),
                                          ]),),

                                      subtitle: Padding(padding: const EdgeInsets.only(top: 5.0),
                                        child: RichText(text: TextSpan(style: TextStyle(), children: <TextSpan>[
                                          TextSpan(text: "mesaj: ", style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),),
                                          TextSpan(text: map_mesaj["mesaj"].toString().length < 50 ? map_mesaj["mesaj"]
                                              : map_mesaj["mesaj"].toString().substring(0, 50) + "...", style: TextStyle(color: Colors.black,
                                              fontWeight: FontWeight.w500, fontSize: 13)),
                                        ]),),
                                      ),
                                      trailing: Wrap( direction: Axis.vertical,
                                          children: [
                                            Text("tarih: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline)),
                                            Text(map_mesaj["tarih"].toString().substring(0, 10),
                                                style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                                            Text(map_mesaj["tarih"].toString().substring(11, 16),
                                                style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                                          ] ),
                                      onTap: () async {
                                        _reklam.showInterad();

                                        _bildirimiGor(map_mesaj, id_mesaj);
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
              );
            }
            ),
      ),
      bottomNavigationBar: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),),
    );
  }

  void _bildirimiGor(dynamic map_mesaj, dynamic id_mesaj) {
    List <dynamic> alicilar_mail = map_mesaj["alicilar_mail"];
    List <dynamic> alicilar_ad = map_mesaj["alicilar_ad"];
    List <dynamic> okuyanlar = map_mesaj["okuyanlar"];
    AlertDialog alertdialog = new AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap( direction: Axis.vertical, spacing: 4,
              children: [
                FloatingActionButton.extended( heroTag: "alicilariGor", backgroundColor: Colors.indigo, elevation: 50,
                    onPressed: (){
                      _reklam.showInterad();

                      _alicilariGor(alicilar_mail, alicilar_ad, okuyanlar);
                    },
                    label: Text("Alıcıları Gör", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ] ),
          Wrap( direction: Axis.vertical,
              children: [
                Text("tarih: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline)),
                Text(map_mesaj["tarih"].toString().substring(0, 10),
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                Text(map_mesaj["tarih"].toString().substring(11, 16),
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
              ] ),
        ],
      ),
      content: Container( height: 300, width: 300,
        child: ListView(
          children: [
            ListTile(
              title: Text("konu: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),),
              subtitle: Text(map_mesaj["konu"].toString().toUpperCase(),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            ListTile(
              title: Text("mesaj: ", style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),),
              subtitle: Text(map_mesaj["mesaj"],
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
    ); showDialog(context: context, builder: (_) => alertdialog);
  }

  Widget alicilariGetir_Widget(List<dynamic> alicilar_mail, List<dynamic> alicilar_ad, List<dynamic> okuyanlar) {
    return Container(
      height: 300, width: 300,
      child: alicilar_mail == 0 ?
      Center( child: Text("Alıcı bulunamadı.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),) :
      ListView.builder(
          itemCount: alicilar_mail.length,
          itemBuilder: (BuildContext context, int index){
            return Column( crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(alicilar_ad[index], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18), ),
                      okuyanlar.contains(alicilar_mail[index]) == true ? Icon(  Icons.check_circle,color: Colors.blueGrey,) : SizedBox.shrink(),
                    ]),
                SizedBox(height: 5,),
                Text(alicilar_mail[index], style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: Colors.blueGrey), ),
                Divider(thickness: 3, color: Colors.indigo),
              ],
            );
          }),
    );
  }

  void _alicilariGor(alicilar_mail, alicilar_ad, okuyanlar) {
    AlertDialog alertDialog = new AlertDialog(
      title: Text("Mesajınızı gönderdiğiniz kişiler listelenmiştir. Bildiriminizi görüntüleyenler tik işareti ile belirtilmiştir. ",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16), textAlign: TextAlign.center,
      ),
      content: alicilariGetir_Widget(alicilar_mail, alicilar_ad, okuyanlar),
    ); showDialog(context: context, builder: (_) => alertDialog);
  }

}