
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sinavci/Helpers/AtaWidget.dart';
import 'package:sinavci/Helpers/Reklam.dart';
import 'package:sinavci/SinavlarKisilerPage.dart';
import 'package:sinavci/main.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:sinavci/Helpers/SignInProvider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

class GirisPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GirisPageState();
  }
}

class GirisPageState extends State<GirisPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _success;
  String _message;

  List<dynamic> okunan_bildirimler = [];
  List<dynamic> okunan_bildirimler_id = [];
  List<dynamic> okunmayan_bildirimler = [];
  List<dynamic> okunmayan_bildirimler_id = [];

  TextEditingController _controller_oylama = TextEditingController();
  final _formKey_oylama = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 36.0, right: 36),
              child: ListView(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Visibility(child: SizedBox(height: 30,)),
                  Visibility( visible: true,
                    child: ListTile(
                      title: Text("Kolayca çevrimiçi sınav hazırlamak, paylaşmak veya sizinle paylaşılan sınavları çözmek için uygulamaya ",
                        style: TextStyle(color: Colors.green, fontSize: 20, fontFamily: "Castoro"), textAlign: TextAlign.justify,),
                      subtitle: Text("  giriş yapınız.", style: TextStyle( color: Colors.blueAccent, fontSize: 30, ), textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                  Divider( thickness: 1, color: Colors.black,
                  ),
                  SizedBox(height: 40,),

                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide( color: Colors.purple, width: 2,),
                        ),
                        labelText: "Ad-Soyad",
                        labelStyle: TextStyle(color: Colors.purple),
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value.isEmpty) {return "Kullanıcı adınızı girmeniz gerekmektedir!";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {},
                  ),
                  SizedBox(height: 20,),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple, width: 2,),
                        ),
                        labelText: "E-mail",
                        labelStyle: TextStyle(color: Colors.purple),
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value.isEmpty) {return "Kullanıcı E-mailinizi girmeniz gerekmektedir!";
                      } else {return null;
                      }
                    },
                    onSaved: (value) {},
                  ),
                  SizedBox(height: 20,),

                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple, width: 2,),
                        ),
                        labelText: "Şifre",
                        labelStyle: TextStyle(color: Colors.purple),
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value.isEmpty) {return "Şifrenizi girmeniz gerekmektedir!";
                      } else {return null;
                      }
                    },
                    onSaved: (value) {},
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      MaterialButton(
                          child: Text("KAYDOL",
                            style: TextStyle(fontSize: 17, color: Colors.green),),
                          onPressed: () {
                            AlertDialog alertDialog = new AlertDialog(
                              title: Text("BİLGİLENDİRME: "),
                              content: Container( height: 500,
                                child: SingleChildScrollView( physics: ClampingScrollPhysics(),
                                  child: Column(
                                    children: [
                                      Text("1) Uygulamada Google AdMob reklam sağlayıcısı tarafından otomatik gönderilen reklamlar gösterilmektedir. Google' ın kendi "
                                          "uyumlulaştırma algoritması ile otomatik gönderilen bu reklamlara hiç bir müdahale imkanımızın olmadığını, dolayısıyla "
                                          "uygulama içi gösterilen hiç bir reklam ile ilişkilendirilemeyeceğimizi,", textAlign: TextAlign.justify,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),),
                                      SizedBox(height: 8,),
                                      Text("2) Uygulamada paylaşılan her türlü gönderinin tamamen paylaşan kullanıcının sorumluluğunda olduğunu,",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),),
                                      SizedBox(height: 8,),
                                      Text("3) Verilerinizin gizliliği bizim için önemlidir. Uygulamayı kullanmak için Ad-Soyad ve E-mail adresiniz yetelidir. Profil "
                                          "sayfanızda gireceğiniz tüm bilgiler isteğe bağlıdır. Hiç bir kişisel bilginizin/gönderinizin siz izin vermedikçe uygulama "
                                          "içerisinde başkası tarafından görülemeyeceğini,", textAlign: TextAlign.justify,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),),
                                      SizedBox(height: 8,),
                                      Text("4) Her bölümün kendi duyurular kısmında ilgili alanı daha hızlı ve etkili kullanabileceğinizi anlatan videoların bulunduğunu,",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                                      ),
                                      SizedBox(height: 8,),
                                      Text("5) Bu sayfanın sağ üst tarafında yer alan duyurular ikonuna basarak Uygulama Detay Sayfasını görüntüleyebileceğinizi,",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),),
                                      SizedBox(height: 8,),
                                      Text("6) Google Play Store Sınavcım uygulama sayfasında Gizlilik Politikamıza erişebileceğinizi,", textAlign: TextAlign.justify,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),),
                                      SizedBox(height: 8,),
                                      Text("önemle belirtmek isteriz. Sınavcım Mobil Uygulamasını tercih ettiğiniz teşekkür ederiz. Puan ve Yorumlarınızı "
                                          "heyecanla bekliyoruz. ", textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: Colors.blue),),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                MaterialButton(
                                  child: Text("Kaydol",textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline,
                                      decorationThickness: 3, decorationColor: Colors.black,),), onPressed: () {
                                    Navigator.of(context, rootNavigator: true).pop("dialog");
                                  _register();
                                },
                                ),
                              ],
                            ); showDialog(context: context, builder: (_) => alertDialog);

                          }),
                      MaterialButton(
                          color: Colors.blue,
                          child: Text("GİRİŞ", style: TextStyle(fontSize: 17),),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              _signIn();
                            }
                          }),
                    ],
                  ),
                  SizedBox(height: 10,),

                  Align( alignment: Alignment.centerRight,
                    child: GestureDetector(
                      child: Text("Şifremi Unuttum",style: TextStyle(color: Colors.blueGrey, fontSize: 15, fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.black,),
                        textAlign: TextAlign.right,),
                      onTap: () async {
                        print(_usernameController.text.trim());
                        Widget setupAlertDialogContainer() {
                          return Container(
                            height: 200, width: 300,
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance.collection("users").where("kullaniciadi", isEqualTo: _usernameController.text.trim()).snapshots(),
                                builder: (context, snapshot){
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator(),);
                                  } else if (snapshot.hasError) {
                                    return Center(child: Icon(Icons.error, size: 40),);
                                  } else if (snapshot.data == null) {
                                    return Center(child: CircularProgressIndicator(),);
                                  }
                                  final querySnapshot = snapshot.data;
                                  return Container(
                                    child: querySnapshot.size == 0 ? Center(
                                      child: ListTile(
                                        leading: Icon(Icons.warning, color: Colors.red,),
                                        title: Text("Kullanıcı adı bulunamadı. Kullanıcı Adı Formuna girdiğiniz Ad/Soyadınızı kontrol ediniz.",
                                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                      ),
                                    ):
                                    ListView.builder(
                                        itemCount: querySnapshot.size,
                                        itemBuilder: (BuildContext context, int index){
                                          final map = querySnapshot.docs[index].data();
                                          final id = querySnapshot.docs[index].id;
                                          return Column(
                                              children: [
                                                ListTile(
                                                  title: Text(_usernameController.text.trim(),
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                                  onTap: ()async{
                                                    Navigator.of(context, rootNavigator: true).pop("dialog");

                                                    _sifremi_sifirla(_usernameController.text.trim(), map, id);

                                                  },),
                                                Divider(thickness: 1,),]);
                                        }),
                                  );

                                }),
                          );
                        }
                        showDialog(context: context, builder: (_) {
                          return AlertDialog(
                            title: Column(children: [
                              Text("ŞİFREMİ SIFIRLA "),
                              SizedBox(height: 10,),
                              Text("Kullanıcı adınıza tıklayarak şifre sıfırlama işleminizi başlatabilirsiniz.",
                                style: TextStyle(color: Colors.orange, fontSize: 15, ),),
                            ]),
                            content: setupAlertDialogContainer(),
                          );
                        });
                      },
                    ),
                  ),
                  MaterialButton(child: Text("Kayıt/Giriş asistan videosu için Tıklayın.", textAlign: TextAlign.center,),
                    onPressed: (){
                      _launchIt("https://drive.google.com/file/d/1P7bc_Ql4KZLTig3dLsiloNkBZI2YT9W5/view?usp=sharing");
                    },),

/*  TODO: TELEFON İLE GİRİŞ
                  Visibility( visible: false, child: SizedBox(height: 50,)),

                  Visibility( visible: false,
                    child: FloatingActionButton.extended(
                        icon: Icon(Icons.phone_rounded, color: Colors.black,), backgroundColor: Colors.indigoAccent,
                        label: Text("Telefon ile giriş yap", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {

                          TextEditingController _mailci = TextEditingController();
                          final _formKey_mail = GlobalKey<FormState>();

                          Widget _mailSorguAlertDialog() {
                            return Container(
                              height: 100, width: 200,
                              child: Column(children: [
                                Form(key: _formKey_mail,
                                    child: Flexible(
                                      child: ListView(children: [
                                        SizedBox(height: 10,),
                                        TextFormField(
                                            controller: _mailci,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "E-mail adresinizi giriniz."),
                                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                                            validator: (String value) {
                                              if (value.isEmpty) {return "Alan boş bırakılamaz.";
                                              } return null;
                                            }),
                                        SizedBox(height: 10,),
                                      ]),
                                    )),
                              ]),
                            );
                          }
                          showDialog(context: context, builder: (_) {
                            return AlertDialog(
                              title: Text("E-mail adresinizi yazarak hesabınıza kayıtlı telefon numarası ile giriş yapabileceksiniz. E-mail adresinizi doğru yazdığınızdan"
                                  " emin olunuz. Sistem büyük, küçük harfe duyarlıdır.",
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                              content: _mailSorguAlertDialog(),
                              actions: [
                                ElevatedButton(child: Text("Giriş Yap"),
                                  onPressed: () async {
                                  if (_formKey_mail.currentState.validate()) {
                                    _formKey_mail.currentState.save();
                                    final mail = _mailci.text.trim();

                                    await FirebaseFirestore.instance.collection("users").where("mail", isEqualTo: mail).limit(1).get()
                                        .then((_kullanicilar) => _kullanicilar.docs.forEach((_kullanici) {
                                          final isim = _kullanici["kullaniciadi"];
                                          final no = _kullanici["tel"];
                                          final doc_id = _kullanici.id;
                                          final map = _kullanici;
                                          final doc_avatar = _kullanici["avatar"];
                                          _signInWithPhone(no, isim, mail, doc_id, map, doc_avatar);
                                    }));
                                  }
                                  },
                                ),
                              ],
                            );
                          });

                        }),
                  ),

*/

/*
                  FittedBox(
                    child: Container( width: 200,
                      child: SignInProvider(
                        infoText: "Google ile giriş yap",
                        buttonType: Buttons.Google,
                        signInMethod: () async {

                          _signInWithGoogle();
                        } , // TODO: Google ile giriş
                      ),
                    ),
                  ),
*/
                  Container(
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Center(
                          child: Text(_success == null ? '' : _message ?? '',
                            style: TextStyle(backgroundColor: Colors.yellow, fontWeight: FontWeight.bold,
                                fontSize: 17, color: Colors.black),
                            textAlign: TextAlign.center,),
                        ),
                      )
                  ),

                  Visibility( visible: _success == null ? true : false,
                    child: Container( height: 250, decoration: BoxDecoration(
                       boxShadow: [
                         BoxShadow(
                           color: Colors.grey, spreadRadius: 1, blurRadius: 20, offset: Offset(20.0, 20.0),
                         ),
                       ]
                     ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset("assets/sinavcimLogo.png", fit: BoxFit.fitWidth,),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  Align( alignment: Alignment(0, 1),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Wrap( direction: Axis.vertical, spacing: 4, children: [
                          Wrap(direction: Axis.horizontal, spacing: 4, children: [
                            Icon(Icons.copyright, size: 30, color: Colors.green),
                            Text("ÖMER KALFA - 2021", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),),
                          ]),
                          Text("Matematik Öğretmeni", style: TextStyle(color: Colors.green, fontSize: 13),),
                          Center(child: Text("iletişim: omerkalfa1@gmail.com", style: TextStyle(color: Colors.blueGrey, fontSize: 12),)),
                        ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            )),
      );

  }

  @override
  void dispose() {
    //! Widget kapatıldığında controllerları temizler
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    dynamic map;
    String soru; String cevap; String doc_kullaniciadi; String doc_mail; String doc_sifre; String doc_id;
    String doc_soru;  String doc_cevap;
    String userName = _usernameController.text.trim();
    String userMail = _emailController.text.trim();

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      AlertDialog alertDialog = new AlertDialog(
        title: Text("Dikkat: ", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
        content: Text("Ad Soyad ve E-mail adresi kısımları uygulama üzerinden değiştirilemez. Şifrenizi unuttuğunuzda şifre hatırlatma linkini bu E-mail adresinize "
            "göndereceğiz. Bu yüzden ve ileride güncelleme ile Gmail hesabı ile giriş, Email gönderme gibi özellikler getirmeyi planladığımız için sık kullandığınız "
            "ve tercihen Gmail hesap adresinizi girmenizi önemle tavsiye ederiz.",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), textAlign: TextAlign.justify,),
        actions: [
          MaterialButton(
            child: Text("Anladım",textAlign: TextAlign.center,
              style: TextStyle(color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline,
                decorationThickness: 3, decorationColor: Colors.black,),
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Navigator.of(context, rootNavigator: true).pop("dialog");

                await FirebaseFirestore.instance.collection("users").where("mail", isEqualTo: userMail )
                    .get().then((QuerySnapshot querySnapshot)=>{
                  querySnapshot.docs.forEach((doc) {
                    doc_sifre = doc["sifre"];
                    doc_kullaniciadi = doc["kullaniciadi"];
                    doc_id = doc.id;
                    doc_mail = doc["mail"];
                    doc_soru = doc["soru"];
                    doc_cevap = doc["cevap"];
                    map = doc.data();
                  })
                });

                if(doc_kullaniciadi == userName && doc_sifre != ""){
                  setState(() {
                    _message = "Kayıt zaten mevcuttur. Lütfen giriş yapınız.";
                    _success = false;
                  });
                }
                else {

                  try {
                    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim());
                    final User user = userCredential.user;

                    if (user != null) {
                      setState(() {
                        AtaWidget.of(context).kullanicimail = _emailController.text.trim();
                        AtaWidget.of(context).kullaniciadi = _usernameController.text.trim();
                        _message = "Merhaba ${AtaWidget.of(context).kullaniciadi}";
                        _success = true;
                      });

                      DocumentReference _ref = await FirebaseFirestore.instance.collection("users")
                          .add({"kullaniciadi": AtaWidget.of(context).kullaniciadi, "mail": AtaWidget.of(context).kullanicimail, "gorevYeri": "",
                        "hakkinda": "", "sifre": _passwordController.text.trim(), "soru": soru, "cevap": cevap, "tel": "", "avatar": "", "meslek": "",
                        "sosyal_facebook": "", "sosyal_instagram": "", "sosyal_twitter": "", "avatar_gizlilik" : [], "gorevYeri_gizlilik" : [],
                        "hakkinda_gizlilik": [], "meslek_gizlilik": [], "sosyal_gizlilik": [], "tel_gizlilik": [],
                      });
                      doc_id = _ref.id.toString();

                      await FirebaseFirestore.instance.collection("users").doc("Q7blX1noNsF4fzFvLHSD").collection("kisilerim")
                          .add({"kullaniciadi": AtaWidget.of(context).kullaniciadi, "mail": AtaWidget.of(context).kullanicimail,
                        "grup_adi": "", "grupAciklamasi": "", "eklendigi_grup": ""});

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Merhaba ${AtaWidget.of(context).kullaniciadi}")));

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                          SinavlarKisilerPage(doc_id: doc_id)));

/*
                      final _formKey_sifirlama = GlobalKey<FormState>();
                      TextEditingController _soru = TextEditingController();
                      TextEditingController _cevap = TextEditingController();
                      Widget setupAlertDialogContainer() {
                        return Container(
                          height: 200, width: 300,
                          child: Form(key: _formKey_sifirlama,
                            child: ListView(
                              children: [
                                TextFormField(
                                  controller: _soru,
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.purple,
                                          width: 2,
                                        ),
                                      ),
                                      labelText: "Güvenlik sorunuzu giriniz.",
                                      labelStyle: TextStyle(color: Colors.purple),
                                      border: OutlineInputBorder()),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Lütfen güvenlik sorusu yazınız";
                                    } else {return null;}
                                  },
                                  onSaved: (value) {},
                                ),
                                SizedBox(height: 20,),
                                TextFormField(
                                  controller: _cevap,
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.purple, width: 2,
                                        ),
                                      ),
                                      labelText: "Cevabı giriniz.",
                                      labelStyle: TextStyle(color: Colors.purple),
                                      border: OutlineInputBorder()),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Lütfen cevap giriniz.";
                                    } else {return null;}
                                  },
                                  onSaved: (value) {},
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      showDialog(context: context, builder: (_) {
                        return AlertDialog(
                          title: Column(children: [
                            Text("SON BİR ADIM DAHA: ",
                              style: TextStyle(color: Colors.green),),
                            SizedBox(height: 10,),
                            Text("Şifrenizi güncellemek istediğnizde aşağıdaki güvenlik sorusu ve cevabını girerek şifrenizi sıfırlayabilirsiniz. Güvenlik sorusu ve cevabının "
                                "sizin kolay hatırlayabileceğiniz fakat başkalarının zor tahmin edeceği şekilde belirlemeniz hesabınızın güvenliği açısından önemlidir. Bununla birlikte"
                                " güvenlik sorusu ve cevabını kullanıcı adı, mail adresi ve şifrenizden farklı bir yerde saklamanızı tavsiye ederiz."
                                "Güvenlik sorusu ve cevabı boşluk, büyük/küçük harfe duyarlı olacaktır. Giriş kısmında *Şifremi Unuttum* butonuna bastığınızda bu bilgiler "
                                "sizden istenecektir. Onayladığınızda kayıt işleminiz tamamlanacaktır.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),),
                          ]
                          ),
                          content: setupAlertDialogContainer(),
                          actions: [
                            Builder(
                              builder: (context) => RaisedButton(color: Colors.green, child: Text("Onayla"), onPressed: () async{
                                if(_formKey_sifirlama.currentState.validate()){

                                  _formKey_sifirlama.currentState.save();
                                  soru = _soru.text.trim();
                                  cevap = _cevap.text.trim();
                                  List <dynamic> doc_avatar_gizlilik = [];
                                  List <dynamic> doc_gorevYeri_gizlilik = [];
                                  List <dynamic> doc_hakkinda_gizlilik = [];
                                  List <dynamic> doc_meslek_gizlilik = [];
                                  List <dynamic> doc_sosyal_gizlilik = [];
                                  List <dynamic> doc_tel_gizlilik = [];

                                  setState(() {
                                    AtaWidget.of(context).kullanicimail = _emailController.text.trim();
                                    AtaWidget.of(context).kullaniciadi = _usernameController.text.trim();
                                    _message = "Merhaba ${AtaWidget.of(context).kullaniciadi}";
                                    _success = true;
                                  });

                                  DocumentReference _ref = await FirebaseFirestore.instance.collection("users")
                                      .add({"kullaniciadi": AtaWidget.of(context).kullaniciadi, "mail": AtaWidget.of(context).kullanicimail, "gorevYeri": "",
                                    "hakkinda": "", "sifre": _passwordController.text.trim(), "soru": soru, "cevap": cevap, "tel": "", "avatar": "", "meslek": "",
                                    "sosyal_facebook": "", "sosyal_instagram": "", "sosyal_twitter": "", "avatar_gizlilik" : [], "gorevYeri_gizlilik" : [],
                                    "hakkinda_gizlilik": [], "meslek_gizlilik": [], "sosyal_gizlilik": [], "tel_gizlilik": []
                                  });
                                  doc_id = _ref.id.toString();

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Merhaba ${AtaWidget.of(context).kullaniciadi}")));

                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                                      SinavlarKisilerPage(doc_id: doc_id)));
                                }
                              },
                              ),
                            ),
                          ],
                        );
                      });

*/
                    } else {
                      setState(() {
                        _message = "hata gerçekleşti";
                        _success = false;
                      });
                    }
                  } on FirebaseAuthException catch (er) {
                    setState(() {
                      _message = er.message;
                      _success = false;
                    });

                  } catch (e) {
                    setState(() {
                      _message = e.message;
                      _success = false;
                    });
                    print(e.toString());
                  }

                }
              }
            },
          )
        ],
      ); showDialog(context: context, builder: (_) => alertDialog);
    }
  }

  void _signIn() async {

    dynamic map; bool oylama_yapildi; int giris_sayisi; bool oylama_gosterme;
    String doc_kullaniciadi; String doc_mail; String doc_sifre; String doc_id;  String doc_soru;  String doc_cevap;
    String doc_avatar;
    bool pasiflestirildi; var pasiflesitirme_tarihi;  var sonPasifTarih;  final simdi = DateTime.now();
    String userName = _usernameController.text.trim();
    String userMail = _emailController.text.trim();
    List <dynamic> _bildirimler = [];
    List <dynamic> _bildirimler_id = [];

        await FirebaseFirestore.instance.collection("users").where("mail", isEqualTo: userMail)
            .get().then((QuerySnapshot querySnapshot)=>{
          querySnapshot.docs.forEach((doc) {
            doc_sifre = doc["sifre"];
            doc_kullaniciadi = doc["kullaniciadi"];
            doc_id = doc.id;
            doc_mail = doc["mail"];
            doc_soru = doc["soru"];
            doc_cevap = doc["cevap"];
            doc_avatar = doc["avatar"];
            map = doc;

            try {
              oylama_yapildi = doc["oylama_yapildi"];
            } catch (e) {
              print(e.toString().toUpperCase());
              oylama_yapildi = null;
            }

            try {
              giris_sayisi = doc["giris_sayisi"];
            } catch (e) {
              print(e.toString().toUpperCase());
              giris_sayisi = 0;
            }

            try {
              oylama_gosterme = doc["oylama_gosterme"];
            } catch (e) {
              print(e.toString().toUpperCase());
              oylama_gosterme = null;
            }

            try {
              pasiflestirildi = doc["pasiflestirildi"];
            } catch (e) {
              print(e.toString().toUpperCase());
              pasiflestirildi = false;
            }

            try {
              pasiflesitirme_tarihi = doc["pasiflestirme_tarihi"].toDate();
            } catch (e) {
              print(e.toString().toUpperCase());
              pasiflestirildi = null;
            }

            try {
              sonPasifTarih = doc["sonPasifTarih"].toDate();
            } catch (e) {
              print(e.toString().toUpperCase());
              sonPasifTarih = null;
            }
          })
        });
/*        if(doc_kullaniciadi != userName || doc_sifre != _passwordController.text.trim()){
          setState(() {
            _message = "*HATA: kullanıcı adı, mail adresi veya şifre birbiri ile uyuşmuyor. Lütfen girdiğiniz bilgilerin doğruluğundan emin olunuz. Bir yanlışlık olduğunu "
                "düşünüyorsanız *Şifremi Unuttum* butonunu kullanarak şifrenizi güncelleyebilirsiniz.";
            _success = false;
          });
        } else{
*/
          try {

          final UserCredential userCredential = await _auth
              .signInWithEmailAndPassword(
              email: _emailController.text.trim(), password: _passwordController.text.trim());
          final User user = userCredential.user;

          if (user != null){

            setState(() {
              AtaWidget.of(context).kullanicimail = _emailController.text.trim();
              AtaWidget.of(context).kullaniciadi = doc_kullaniciadi;
              giris_sayisi = giris_sayisi +1;
            });

            if (pasiflestirildi == true) {
              if (sonPasifTarih == null || simdi.isBefore(sonPasifTarih)) {

                Dialog dialog = new Dialog (
                  backgroundColor: Colors.blue.shade100, elevation: 100, insetAnimationDuration: Duration(seconds: 7),
                  child: Container( width: 500, height: 500,
                      child: Center(
                        child: Padding( padding: EdgeInsets.only(left: 20, right: 20),
                          child: Text("Güvenlik ve hatalı işleme tedbir olarak belirlenen 90 günlük pasifizasyon süresinin dolacağı tarih olan "
                              " *${sonPasifTarih.toString().substring(0, 10)}* den önce uygulamaya giriş yaparak hesabınızı ""yeniden aktif hale getirdiğiniz için teşekkür "
                              "ederiz. Sizi yeniden SINAVCIM ailesinin bir üyesi olarak görmek mutluluk verici.",
                            style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 25, fontFamily: "Beau Rivage"),),
                        ),
                      )
                  ),
                ); showDialog(context: context, builder: (_) => dialog);

                oyla_dialog(map, doc_id, oylama_yapildi, giris_sayisi, doc_avatar, oylama_gosterme);

                FirebaseFirestore.instance.collection("users").doc(doc_id).update({"giris_sayisi" : giris_sayisi, "pasiflestirildi": false, "sonPasifTarih": simdi});

              } else {

                AlertDialog alertDialog = new AlertDialog(
                  title: Text("Pasifizasyon süreniz dolmuştur.", style: TextStyle(color: Colors.orange),),
                  content: Text("Güvenlik ve hatalı işleme tedbir olarak belirlenen 90 günlük pasifizasyon süreniz dolmuştur. Lütfen aşağıdakilerden birini seçerek işleme "
                      "devam ediniz: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                  actions: [
                    Container( width: 150, height: 70,
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                          label: Text("Hesabımı Aktive Et", style: TextStyle(fontWeight: FontWeight.bold),),
                          icon: Icon(Icons.emoji_emotions_rounded),
                          onPressed: () async {
                            Navigator.of(context, rootNavigator: true).pop("dialog");

                            Dialog dialog = new Dialog (
                              backgroundColor: Colors.blue.shade100, elevation: 100, insetAnimationDuration: Duration(seconds: 7),
                              child: Container( width: 300, height: 500,
                                  child: Center(
                                    child: Padding( padding: EdgeInsets.only(left: 20, right: 20),
                                      child: Text("Hesabınızı ""yeniden aktif hale getirdiğiniz için teşekkür ederiz. Sizi yeniden SINAVCIM ailesinin bir üyesi "
                                          "olarak görmek mutluluk verici.",
                                        style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 25, fontFamily: "Beau Rivage"),),
                                    ),
                                  )
                              ),
                            ); showDialog(context: context, builder: (_) => dialog);

                            oyla_dialog(map, doc_id, oylama_yapildi, giris_sayisi, doc_avatar, oylama_gosterme);

                            FirebaseFirestore.instance.collection("users").doc(doc_id).update({"giris_sayisi" : giris_sayisi, "pasiflestirildi": false, "sonPasifTarih": simdi});
                          },
                        ),
                      ),
                    ),
                    MaterialButton(child: Text("Hesabımı Sil", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic,
                        fontSize: 15, decoration: TextDecoration.underline),),
                      onPressed: () async {

                        hesapSil(doc_id);


                      },)
                  ],
                ); showDialog(context: context, builder: (_) => alertDialog);
              }
            } else {

              oyla_dialog(map, doc_id, oylama_yapildi, giris_sayisi, doc_avatar, oylama_gosterme, );

              FirebaseFirestore.instance.collection("users").doc(doc_id).update({"giris_sayisi" : giris_sayisi});
            }
/*
            await FirebaseFirestore.instance.collection("bildirimler").where("alicilar", arrayContains: user.email).get()
                .then((bildirimler) => bildirimler.docs.forEach((bildirim) {
                  _bildirimler.add(bildirim.data());
                  _bildirimler_id.add(bildirim.id);
            }));
*/
          }
/*
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
          setState(() {
            AtaWidget.of(context).okunmayan_bildirimler = okunmayan_bildirimler;
            AtaWidget.of(context).okunan_bildirimler = okunan_bildirimler;
          });
          print(AtaWidget.of(context).okunmayan_bildirimler.toString().toUpperCase());
*/

/*        } on FirebaseAuthException catch (e) {
          setState(() {
            _message = e.toString();
            _success = false;
          });
*/
          } catch (e) {
            setState(() {
              _message = e.toString();
              _success = false;
            });
          }

//        }

  }


  void _sifremi_sifirla(String kullaniciadi, dynamic map, dynamic id)  async {
    String doc_soru = map["soru"];
    String doc_cevap = map["cevap"];
    String id_kayit = id.toString();
    String soru;
    String cevap;
    String mail = map["mail"];

      final _formKey_sifirlama = GlobalKey<FormState>();
      TextEditingController _kullaniciadi = TextEditingController();
      TextEditingController _soru = TextEditingController();
      TextEditingController _cevap = TextEditingController();
/*
      Widget setupAlertDialogContainer() {
        return Container(
          height: 200, width: 300,
          child: Form(key: _formKey_sifirlama,
            child: ListView(
              children: [
                ListTile(
                  title: Text(kullaniciadi, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                  subtitle: Text("için güvenlik sorusu ve cevabını giriniz."),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _soru,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.purple,
                          width: 2,
                        ),
                      ),
                      labelText: "Güvenlik sorunuzu giriniz.",
                      labelStyle: TextStyle(color: Colors.purple),
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Lütfen güvenlik sorunuzu giriniz.";
                    } else {return null;}
                  },
                  onSaved: (value) {},
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _cevap,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.purple, width: 2,
                        ),
                      ),
                      labelText: "Cevabınızı giriniz.",
                      labelStyle: TextStyle(color: Colors.purple),
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Lütfen cevabınızı giriniz.";
                    } else {return null;}
                  },
                  onSaved: (value) {},
                ),
              ],
            ),
          ),
        );
      }
*/
      showDialog(context: context, builder: (_) {

        return AlertDialog(
          title: Column(children: [
            Text("Kayıt Bilgilerini Sıfırlama: ",
              style: TextStyle(color: Colors.black),),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Onayla tuşuna bastığınızda sistemde kayıtly mail adresinize bir şifre sıfırlama linki göndereceğiz. "
                  "Linke tıklayarak şifrenizi sıfırlayabilirsiniz.",
//              "Aşağıdaki alanlara kayıt aşamasında girdiğiniz güvenlik sorusu ve cevabınızı aynen girmelisiniz.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),),
            ),
          ]
          ),
//          content: setupAlertDialogContainer(),
          actions: [
              RaisedButton(color: Colors.green, child: Text("Onayla"), onPressed: () async{
                print(doc_soru.toString() + doc_cevap.toString());
/*
                if(_formKey_sifirlama.currentState.validate()){
                  _formKey_sifirlama.currentState.save();
                  soru = _soru.text.trim();
                  cevap = _cevap.text.trim();
*/

//                  if(doc_soru == soru && doc_cevap == cevap){
//                    await FirebaseFirestore.instance.collection("users").doc(id_kayit).update({"sifre":""});
                    await _auth.sendPasswordResetEmail(email: mail);

                    Navigator.of(context, rootNavigator: true).pop("dialog");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));

                    Dialog dialog = new Dialog(
                      backgroundColor: Colors.blueGrey.shade200, elevation: 100, insetAnimationDuration: Duration(seconds: 7),
                      child: Container( width: 300, height: 100,
                          child: ListTile(
                            leading: Icon(Icons.check_circle, color: Colors.blue,),
                            title: Text("Başarılı: ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),),
                            subtitle: Text("Sisteme kayıtlı mail adresinize gönderdiğimiz linke tıklayarak şifrenizi sıfırlayabilirsiniz.",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                          )
                      ),
                    ); showDialog(context: context, builder: (_) => dialog);

/*
                  } else { AlertDialog alertDialog = new AlertDialog(
                    title: Text("Soru veya cevabınız sistemdeki bilgiler ile uyuşmamaktadır. Girdiğiniz bilgilerin doğruluğundan emin olunuz. Alanlar küçük/büyük harf "
                        "veya işaretlere duyarlıdır."),
                  ); showDialog(context: context, builder: (_) =>alertDialog);
                  }
*/
//                }
              },
              ),
          ],
        );
      });


  }

/*
********TELEFON İLE GİRİŞ AYARLANACAK********
  void _signInWithPhone(String no, String isim, String mail, String doc_id, dynamic map, String doc_avatar) async {
    if (AtaWidget.of(context).kullaniciadi == "" || AtaWidget.of(context).kullaniciadi == " " ||
        AtaWidget.of(context).kullaniciadi == null ) {

      _auth.verifyPhoneNumber(
        phoneNumber: no, timeout: Duration(seconds: 120),
        verificationCompleted: (AuthCredential credential) async {
          final UserCredential userCredential = await _auth.signInWithCredential(credential);
          final User user = userCredential.user;

          setState(() {
            AtaWidget.of(context).kullaniciadi = isim;
          });
          print("AtaWidget.of(context).kullaniciadi: " + AtaWidget.of(context).kullaniciadi + " başarıyla giriş yaptı.");
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
              SinavlarKisilerPage(doc_id: doc_id, map: map, doc_avatar: doc_avatar),));
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _message = e.toString();
            _success = false;
          });
        },
        codeSent: (String verificationId, int resendToken) async {
          // Update the UI - wait for the user to enter the SMS code
          String smsCode = 'xxxx';

          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          await _auth.signInWithCredential(phoneAuthCredential);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
        },
      );
    } else {
      setState(() {
        _message = "*HATA: Önce uygulamadan çıkış yapmalısınız.";
        _success = false;
      });
    }
  }

*/

/*
  _signInWithGoogle() async {

    if (AtaWidget.of(context).kullaniciadi == "" || AtaWidget.of(context).kullaniciadi == " " ||
        AtaWidget.of(context).kullaniciadi == null ) {

      try {
        final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final GoogleAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken
        );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User user = userCredential.user;

        if (user != null) {

        setState(() {
          AtaWidget.of(context).kullaniciadi = user.displayName;
          AtaWidget.of(context).kullanicimail = user.email;
        });

        print("giriş başarılı");
        print(AtaWidget.of(context).kullaniciadi.toUpperCase());
        print(AtaWidget.of(context).kullanicimail.toUpperCase());

        if (user.email == "yoneticikullanici1@gmail.com"){

          await FirebaseFirestore.instance.collection("users").doc("Q7blX1noNsF4fzFvLHSD").get().then((yonetici) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                SinavlarKisilerPage(
                  doc_id: yonetici.id,
                  map: yonetici.data(),
                  doc_avatar: yonetici.data()["avatar"],
                  gonderen_secildi: false,
                )));
          });

        } else {

          dynamic map; bool oylama_yapildi; int giris_sayisi; bool oylama_gosterme;
          String doc_kullaniciadi; String doc_mail; String doc_sifre; String doc_id;  String doc_soru;  String doc_cevap;
          String doc_avatar;
          bool pasiflestirildi; var pasiflesitirme_tarihi;  var sonPasifTarih;  final simdi = DateTime.now();
          String userName = _usernameController.text.trim();
          String userMail = _emailController.text.trim();
          List <dynamic> _bildirimler = [];
          List <dynamic> _bildirimler_id = [];

          await FirebaseFirestore.instance.collection("users").where("mail", isEqualTo: user.email)
              .get().then((QuerySnapshot querySnapshot)=>{
            querySnapshot.docs.forEach((doc) {
              doc_sifre = doc["sifre"];
              doc_kullaniciadi = doc["kullaniciadi"];
              doc_id = doc.id;
              doc_mail = doc["mail"];
              doc_soru = doc["soru"];
              doc_cevap = doc["cevap"];
              doc_avatar = doc["avatar"];
              map = doc;

              try {
                oylama_yapildi = doc["oylama_yapildi"];
              } catch (e) {
                print(e.toString().toUpperCase());
                oylama_yapildi = null;
              }

              try {
                giris_sayisi = doc["giris_sayisi"];
              } catch (e) {
                print(e.toString().toUpperCase());
                giris_sayisi = 0;
              }

              try {
                oylama_gosterme = doc["oylama_gosterme"];
              } catch (e) {
                print(e.toString().toUpperCase());
                oylama_gosterme = null;
              }

              try {
                pasiflestirildi = doc["pasiflestirildi"];
              } catch (e) {
                print(e.toString().toUpperCase());
                pasiflestirildi = false;
              }

              try {
                pasiflesitirme_tarihi = doc["pasiflestirme_tarihi"].toDate();
              } catch (e) {
                print(e.toString().toUpperCase());
                pasiflestirildi = null;
              }

              try {
                sonPasifTarih = doc["sonPasifTarih"].toDate();
              } catch (e) {
                print(e.toString().toUpperCase());
                sonPasifTarih = null;
              }
            })
          });

/*        if(doc_kullaniciadi != userName || doc_sifre != _passwordController.text.trim()){
          setState(() {
            _message = "*HATA: kullanıcı adı, mail adresi veya şifre birbiri ile uyuşmuyor. Lütfen girdiğiniz bilgilerin doğruluğundan emin olunuz. Bir yanlışlık olduğunu "
                "düşünüyorsanız *Şifremi Unuttum* butonunu kullanarak şifrenizi güncelleyebilirsiniz.";
            _success = false;
          });
        } else{
*/
          try {

              setState(() {
                giris_sayisi = giris_sayisi +1;
              });

              if (pasiflestirildi == true) {
                if (sonPasifTarih == null || simdi.isBefore(sonPasifTarih)) {

                  Dialog dialog = new Dialog (
                    backgroundColor: Colors.blue.shade100, elevation: 100, insetAnimationDuration: Duration(seconds: 7),
                    child: Container( width: 500, height: 500,
                        child: Center(
                          child: Padding( padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text("Güvenlik ve hatalı işleme tedbir olarak belirlenen 90 günlük pasifizasyon süresinin dolacağı tarih olan "
                                " *${sonPasifTarih.toString().substring(0, 10)}* den önce uygulamaya giriş yaparak hesabınızı ""yeniden aktif hale "
                                "getirdiğiniz için teşekkür "
                                "ederiz. Sizi yeniden SINAVCIM ailesinin bir üyesi olarak görmek mutluluk verici.",
                              style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 25, fontFamily: "Beau Rivage"),),
                          ),
                        )
                    ),
                  ); showDialog(context: context, builder: (_) => dialog);

                  oyla_dialog(map, doc_id, oylama_yapildi, giris_sayisi, doc_avatar, oylama_gosterme);

                  FirebaseFirestore.instance.collection("users").doc(doc_id).update({"giris_sayisi" : giris_sayisi, "pasiflestirildi": false, "sonPasifTarih": simdi});

                } else {

                  AlertDialog alertDialog = new AlertDialog(
                    title: Text("Pasifizasyon süreniz dolmuştur.", style: TextStyle(color: Colors.orange),),
                    content: Text("Güvenlik ve hatalı işleme tedbir olarak belirlenen 90 günlük pasifizasyon süreniz dolmuştur. Lütfen aşağıdakilerden birini seçerek işleme "
                        "devam ediniz: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    actions: [
                      Container( width: 150, height: 70,
                        child: FittedBox(
                          child: FloatingActionButton.extended(
                            label: Text("Hesabımı Aktive Et", style: TextStyle(fontWeight: FontWeight.bold),),
                            icon: Icon(Icons.emoji_emotions_rounded),
                            onPressed: () async {
                              Navigator.of(context, rootNavigator: true).pop("dialog");

                              Dialog dialog = new Dialog (
                                backgroundColor: Colors.blue.shade100, elevation: 100, insetAnimationDuration: Duration(seconds: 7),
                                child: Container( width: 300, height: 500,
                                    child: Center(
                                      child: Padding( padding: EdgeInsets.only(left: 20, right: 20),
                                        child: Text("Hesabınızı ""yeniden aktif hale getirdiğiniz için teşekkür ederiz. Sizi yeniden SINAVCIM ailesinin bir üyesi "
                                            "olarak görmek mutluluk verici.",
                                          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 25, fontFamily: "Beau Rivage"),),
                                      ),
                                    )
                                ),
                              ); showDialog(context: context, builder: (_) => dialog);

                              oyla_dialog(map, doc_id, oylama_yapildi, giris_sayisi, doc_avatar, oylama_gosterme);

                              FirebaseFirestore.instance.collection("users").doc(doc_id).update({"giris_sayisi" : giris_sayisi, "pasiflestirildi": false,
                                "sonPasifTarih": simdi});
                            },
                          ),
                        ),
                      ),
                      MaterialButton(child: Text("Hesabımı Sil", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic,
                          fontSize: 15, decoration: TextDecoration.underline),),
                        onPressed: () async {

                          hesapSil(doc_id);


                        },)
                    ],
                  ); showDialog(context: context, builder: (_) => alertDialog);
                }
              } else {

                oyla_dialog(map, doc_id, oylama_yapildi, giris_sayisi, doc_avatar, oylama_gosterme, );

                FirebaseFirestore.instance.collection("users").doc(doc_id).update({"giris_sayisi" : giris_sayisi});
              }
/*
            await FirebaseFirestore.instance.collection("bildirimler").where("alicilar", arrayContains: user.email).get()
                .then((bildirimler) => bildirimler.docs.forEach((bildirim) {
                  _bildirimler.add(bildirim.data());
                  _bildirimler_id.add(bildirim.id);
            }));
*/

/*
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
          setState(() {
            AtaWidget.of(context).okunmayan_bildirimler = okunmayan_bildirimler;
            AtaWidget.of(context).okunan_bildirimler = okunan_bildirimler;
          });
          print(AtaWidget.of(context).okunmayan_bildirimler.toString().toUpperCase());
*/

/*        } on FirebaseAuthException catch (e) {
          setState(() {
            _message = e.toString();
            _success = false;
          });
*/
          } catch (e) {
            setState(() {
              _message = e.toString();
              _success = false;
            });
          }

//        }
        }

        }
      } on FirebaseAuthException catch(e){
        setState(() {
          _message = e.toString();
          _success = false;
          AtaWidget.of(context).kullaniciadi = " ";
        });
      } catch (e) {
        setState(() {
          _message = e.toString();
          _success = false;
          AtaWidget.of(context).kullaniciadi = " ";
        });
      }

    } else {
      setState(() {
        _message = "*HATA: Önce uygulamadan çıkış yapmalısınız.";
        _success = false;
      });
    }
  }

*/

  void goToMyHomePage() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }

  void goToGirisPage() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => GirisPage()));
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

  void oyla_dialog(dynamic map, dynamic id, bool oylama_yapildi, int giris_sayisi, String doc_avatar, bool oylama_gosterme, ) async {

    double girisSayisi_bolu10 = giris_sayisi/10;
    List <dynamic> _bildirimler = [];
    List <dynamic> _bildirimler_id = [];

    await FirebaseFirestore.instance.collection("bildirimler").where("alicilar_mail", arrayContains: AtaWidget.of(context).kullanicimail)
        .orderBy("tarih", descending: true).get()
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
    setState(() {
      AtaWidget.of(context).okunmayan_bildirimler = okunmayan_bildirimler;
      AtaWidget.of(context).okunan_bildirimler = okunan_bildirimler;
    });
    print(AtaWidget.of(context).okunmayan_bildirimler.toString().toUpperCase());

    if(oylama_yapildi == true || giris_sayisi % 10 != 0 || oylama_gosterme == true ){

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
          SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
    } else {

      Dialog dialog = new Dialog(
        backgroundColor: Colors.white, elevation: 100, insetAnimationDuration: Duration(seconds: 7),
        child: Container( width: 800, height: 500,
            child: ListView( children: [
              SizedBox(height: 10,),
              Center(
                child: Text("GÖRÜŞLERİNİZ BİZİM İÇİN DEĞERLİDİR...", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold,
                    fontSize: 15, decoration: TextDecoration.underline, decorationThickness: 3, decorationColor: Colors.green),),
              ),
              SizedBox(height: 10,),
              ListTile(
                title: Text("Gönderdiğiniz her geri bildirimi kendimizi geliştirmek için bir fırsat olarak görüyoruz. Bize Google Play Store "
                    "üzerinden puan verebilir ve yorum yazabilirsiniz. Dilerseniz uygulama üzerinden sadece bizim göreceğimiz geri bildiriminizi "
                    "gönderebilirsiniz.",
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
                        title: Text("Play Store' da geri bildirim vererek gelişmemize katkıda bulunduğunuz için teşekkür ederiz.",
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
                  child: Text("Bize uygulama ile ilgili deneyimlerinizi, görüş, eleştiri ve önerilerinizi içeren geri bildirim gönderebiliriniz: ",
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
                        labelText: "Yorumunuzu buraya yazınız.",
                        hintText: "Buraya yazıdığınız yorumunuz gizlidir, sadece bizim tarafımızdan görüntülenir.",
                        hintStyle: TextStyle(fontSize: 10),
                        border: OutlineInputBorder()
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    validator: (value) {
                      if(value.isEmpty){ return "Yorum yazılmadı."; }
                      else { return null; }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: FloatingActionButton.extended( elevation: 20,
                  label: Text("Yorumunu Bize Gönder"), icon: Icon(Icons.send, color: Colors.greenAccent,), heroTag: "oylamayiGonder_buton",
                  onPressed: () async {
                  if(_formKey_oylama.currentState.validate()){
                    _formKey_oylama.currentState.save();
                    List<dynamic> alicilar_mail = ["yoneticikullanici1@gmail.com"];
                    List<dynamic> alicilar_ad = ["Yönetici Kullanıcı"];
                    List<dynamic> okuyanlar = [];

                    await FirebaseFirestore.instance.collection("bildirimler").add({ "tarih": DateTime.now().toString(), "alicilar_mail" : alicilar_mail,
                      "gonderen_adi" : AtaWidget.of(context).kullaniciadi, "gonderen_mail" : AtaWidget.of(context).kullanicimail, "alicilar_ad" : alicilar_ad,
                      "konu" : "${AtaWidget.of(context).kullaniciadi}' nın geri bildirimi_${giris_sayisi}", "mesaj" : _controller_oylama.text.trim(),
                      "okuyanlar" : okuyanlar,
                    });
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                        SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
                    AlertDialog alertDialog = new AlertDialog(
                      content: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.blue, size: 30,),
                        title: Text("Geri bildiriminiz için teşekkür ederiz. Geri Bildiriminize gönderilen mesajlar bölümünden ulaşabilirsiniz. Bildiriminiz incelenerek "
                            "size en yakın zamanda dönüş sağlayacağız. Google Play Store üzerinden de oylamayı ve yorum yazmayı unutmayın.",
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
                      child: MaterialButton( child: Text("Bir daha Gösterme", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 20,
                        fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.red, decorationThickness: 3,),),
                        onPressed: (){
                          FirebaseFirestore.instance.collection("users").doc(id).update({"oylama_gosterme" : true});

                          Navigator.of(context, rootNavigator: true).pop("dialog");
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                              SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
                          AlertDialog alertDialog = new AlertDialog(
                            content: ListTile(
                              leading: Icon(Icons.info, color: Colors.blue, size: 30,),
                              title: Text("Bu pencereyi bir daha görmeyeceksin. Geri bildirim göndermek yada her hangi bir sorunda bizimle "
                                  "iletişime geçmek istersen *KİŞİLERİM alanından *MESAJ_GÖNDER ikonuna tıkladıktan sonra *TEKNİK_DESTEK/YORUM seçeneğini seçerek bize "
                                  "mesaj atabilir yada E-mail adresimize mail atabilirsin.",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                            ),
                          ); showDialog(context: context, builder: (_) => alertDialog);
                        },
                      ),
                    ),
                  ),
                  Align( alignment: Alignment.centerRight,
                    child: MaterialButton( child: Text("Şimdi Değil", style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic, fontSize: 20,
                      fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.orange, decorationThickness: 3,),),
                      onPressed: (){
                        Navigator.of(context, rootNavigator: true).pop("dialog");
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                            SinavlarKisilerPage(doc_id: id, map: map, doc_avatar: doc_avatar, gonderen_secildi: false,)));
                        AlertDialog alertDialog = new AlertDialog(
                          content: ListTile(
                            leading: Icon(Icons.info, color: Colors.blue, size: 30,),
                            title: Text("Bu pencereyi ileri bir tarihte bir daha göreceksin. O zaman gelinceye kadar geri bildirim göndermek yada her hangi bir sorunda bizimle "
                                "iletişime geçmek istersen *KİŞİLERİM alanından *MESAJ_GÖNDER ikonuna tıkladıktan sonra *TEKNİK_DESTEK/YORUM seçeneğini seçerek bize "
                                "mesaj atabilirsin.",
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
      ); showDialog( barrierDismissible: false,
          context: context, builder: (_) => dialog);
    }

  }

  void hesapSil(dynamic doc_id) async {

    AlertDialog alertDialog = new AlertDialog(
      title: Text("Dikkat: ", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline),),
      content: Text("İşlemi onayladığınızda profil sayfanızda yer alan tüm kişisel bilgileriniz silinecektir. Bu işlem geri alınamaz."),
      actions: [
        MaterialButton(child: Text("Onaylıyorum", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline),),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop("dialog");

            try {
              await FirebaseStorage.instance.ref().child("users").child(AtaWidget.of(context).kullaniciadi).child("avatar").delete();
            } catch (e) {}

            try {

              await FirebaseFirestore.instance.collection("users").doc(doc_id).get().then((kisi) {
                kisi.reference.collection("herkeseAcik_sinavlar_gruplari").get().then((liste) =>
                    liste.docs.forEach((nesne)=>nesne.reference.delete()));

                kisi.reference.collection("paylasilan_sinavlar_gruplari").get().then((liste) =>
                    liste.docs.forEach((nesne)=>nesne.reference.delete()));

                kisi.reference.collection("kisilerim").get().then((liste) => liste.docs.forEach((nesne)=>nesne.reference.delete()));

                kisi.reference.collection("sinavlar").get().then((liste) => liste.docs.forEach((nesne) {
                  nesne.reference.collection("sinavi_cevaplayanlar").get().then((altliste) => altliste.docs.forEach((altnesne) {
                    altnesne.reference.delete();
                  }));
                  nesne.reference.collection("paylasilanlar").get().then((altliste) => altliste.docs.forEach((altnesne) {
                    altnesne.reference.delete();
                  }));

                  nesne.reference.collection("sorular").get().then((altliste) => altliste.docs.forEach((altnesne) {
                    altnesne.reference.collection("A_isaretleyenler").get().then((A_isaretleyenler) => A_isaretleyenler.docs.forEach((A_isaretleyen) {
                      A_isaretleyen.reference.delete();}));
                    altnesne.reference.collection("B_isaretleyenler").get().then((B_isaretleyenler) => B_isaretleyenler.docs.forEach((B_isaretleyen) {
                      B_isaretleyen.reference.delete();}));
                    altnesne.reference.collection("C_isaretleyenler").get().then((C_isaretleyenler) => C_isaretleyenler.docs.forEach((C_isaretleyen) {
                      C_isaretleyen.reference.delete();}));
                    altnesne.reference.collection("D_isaretleyenler").get().then((D_isaretleyenler) => D_isaretleyenler.docs.forEach((D_isaretleyen) {
                      D_isaretleyen.reference.delete();}));
                    altnesne.reference.collection("dogruSik_isaretleyenler").get().then((dogruSik_isaretleyenler) => dogruSik_isaretleyenler.docs
                        .forEach((dogruSik_isaretleyen) {
                      dogruSik_isaretleyen.reference.delete();}));
                    altnesne.reference.collection("isaretleyenler").get().then((isaretleyenler) => isaretleyenler.docs.forEach((isaretleyen) {
                      isaretleyen.reference.delete();}));
                    altnesne.reference.collection("soruyu_cevaplayanlar").get().then((soruyu_cevaplayanlar) => soruyu_cevaplayanlar.docs
                        .forEach((soruyu_cevaplayan) {
                      soruyu_cevaplayan.reference.delete();}));
                  }));

                }));

                kisi.reference.update({
                  "kullaniciadi": null, "mail": null, "gorevYeri": null,
                  "hakkinda": null, "sifre": null, "soru": null, "cevap": null, "tel": null, "avatar": null, "meslek": null,
                  "sosyal_facebook": null, "sosyal_instagram": null, "sosyal_twitter": null, "avatar_gizlilik" : null, "gorevYeri_gizlilik" : null,
                  "hakkinda_gizlilik": null, "meslek_gizlilik": null, "sosyal_gizlilik": null, "tel_gizlilik": null,
                });

              });
              await FirebaseFirestore.instance.collection("users").where("mail", isEqualTo: "yoneticikullanici1@gmail.com").get()
                  .then((yonetici) => yonetici.docs.forEach((_yonetici) {
                _yonetici.reference.collection("kisilerim").where("mail", isEqualTo: AtaWidget.of(context).kullanicimail).get()
                    .then((kisi) => kisi.docs.forEach((_kisi) {
                  _kisi.reference.delete();
                }));
              }));

              await FirebaseAuth.instance.currentUser.delete();

              _usernameController.dispose();
              _emailController.dispose();
              _passwordController.dispose();
              Navigator.of(context, rootNavigator: true).pop("dialog");

            } catch (e) {}

          },
        ),
      ],
    ); showDialog(context: context, builder: (_) => alertDialog);

  }



}