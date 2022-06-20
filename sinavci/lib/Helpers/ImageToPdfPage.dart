import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sinavci/Helpers/Reklam.dart';

class ImageToPdfPage extends StatefulWidget {
  final images;
  const ImageToPdfPage({Key key, this.images}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ImageToPdfPageState(this.images);
  }
}

class ImageToPdfPageState extends State {
  List<File> images = [];
  ImageToPdfPageState(this.images);

  final picker = ImagePicker();
  final pdf = pw.Document();


  Reklam _reklam = new Reklam();

  @override
  void initState() {
    _reklam.createInterad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("PDFe DÖNÜŞTÜR"),
        actions: [
          IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: () {
                _reklam.showInterad();
                createPDF();
                savePDF();
                Navigator.pop(context);
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          _reklam.showInterad();
          getImageFromGallery();
        }
      ),
      body: images.isNotEmpty
          ? ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) => Column(
                children: [
                  Card(elevation: 20, color: Colors.blue.shade100, shadowColor: Colors.black,
                    child: Container(padding: EdgeInsets.all(8),
//                      height: 500, width: 1000,
                      margin: EdgeInsets.all(8),
                      child: SingleChildScrollView(physics: ClampingScrollPhysics(),
                          child: GestureDetector(
                            onLongPress: () {
                              AlertDialog alertDialog = new AlertDialog(
                                title: Text("Resim kaldırılsın mı?",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        images.removeAt(index);
                                        setState(() {});
                                        Navigator.of(context, rootNavigator: true).pop("dialog");
                                      },
                                      child: Text("Kaldır"))
                                ],
                              );
                              showDialog(context: context, builder: (_) => alertDialog);
                            },
                            child: Image.file(images[index], height: 500,),
                          )),
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            )
          : Center(
        child: Text("Sorularınızın çıktısı burada görüldüğü gibi olacaktır.",
          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,),),

      bottomNavigationBar: Visibility(
          child: Container( height: 50, child: AdWidget(ad: Reklam.getBannerAd()..load(), key: UniqueKey(),),)),
    );
  }

  getImageFromGallery() async {
    List<File> _image = images;
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image.add(File(pickedFile.path));
    } else {
      print('No image selected');
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ImageToPdfPage(images: _image,)));
//    setState(() {});
  }

  createPDF() async {
    for (var img in images) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(left: 20, right: 20),
          build: (pw.Context contex) {
            return pw.Container(
                child: pw.Image(image)
            );
          }));
    }
  }

  savePDF() async {
    try {
      final dir = await getExternalStorageDirectory();
      final file = File('${dir.path}/${DateTime.now().toString()}.pdf');
      await file.writeAsBytes(await pdf.save());
      showPrintedMessage('başarılı',
          'PDF belgelerinize tarih ve saat adıyla olarak kaydedilmiştir. Telefonun senkronizasyonunu beklememek için ${dir.path}/${DateTime.now().toString()} '
              'yolunu izleyerek çıktıya ulaşabilirsiniz.');
    } catch (e) {
      showPrintedMessage('error', e.toString());
    }
  }

  showPrintedMessage(String title, String msg) {
    Flushbar(
      title: title,
      message: msg,
      duration: Duration(seconds: 7),
      icon: Icon(
        Icons.info,
        color: Colors.blue,
      ),
    )..show(context);
  }
}
