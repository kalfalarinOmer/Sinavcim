import 'dart:io';

import 'package:flutter/material.dart';

class AtaWidget extends InheritedWidget{
  String kullaniciadi;
  String kullanicimail;
  String sifre;
  bool hazirSinav_gonderilenCevaplar;
  bool olusturulanSinav_gonderilenCevaplar;
  bool olusturulanSinavSoru_gonderilenCevaplar;
  bool AllList_kisilerimden;
  bool AllList_hazirladigimSinavlarimdan;
  bool AllList_gonderilenSinavlarimdan;
  String sinavGonderen_kullaniciadi;
  String sinavGonderen_id;
  List <dynamic> dogruSiktan_puanCevaplayan;
  bool olusturulanSinavTestSorusu_isaretleyenler;
  File soruSelected_sinavOlustur;
  File cevapSelected_sinavOlustur;
  String sayi_sinavOlustur;
  String harf_sinavOlustur;
  String soru_metni_sinavOlustur;
  bool metinsel_soru_sinavOlustur;
  bool gorsel_soru_sinavOlustur;
  bool soru_testmi_sinavOlustur;
  bool test_mesaji_sinavOlustur;
  String sinav_baslik_sinavOlustur;
  String baslik_sinavOlustur;
  String idnewDoc_sinavOlustur;
  String id_subCol_newDoc_sinavOlustur;
  String grupAdi_AllList;
  bool yazili_olusturulanSinav;
  bool ustbilgi_olusturulanSinav;
  bool altbilgi_olusturulanSinav;
  int sutun_sayisi;
  double sorular_arasi_mesafe;
  double soru_ici_bosluk;
  double sorularin_boyutu;
  String bosluk_txt;
  String boyut_txt;
  bool a4;
  String formHelper;
  String formHelper_metinselSoru_baslik;
  String formHelper_metinselSoru_soruMetni;
  String formHelper_metinselSoru_puan;
  String metinsel_sik;
  String metinsel_sik_a;
  String metinsel_sik_b;
  String metinsel_sik_c;
  String metinsel_sik_d;
  File a_sikki_gorsel;
  File b_sikki_gorsel;
  File c_sikki_gorsel;
  File d_sikki_gorsel;
  bool metinsel_soru_bitti;
  bool a_sikki_bitti;
  bool b_sikki_bitti;
  bool c_sikki_bitti;
  bool d_sikki_bitti;
  String formHelper_gorselSoru_baslik;
  String formHelper_gorselSoru_puan;
  String formHelper_ogrenci_cevap_baslik;
  String formHelper_ogrenci_cevap_aciklama;
  bool has_filtreSecildi;
  String has_filtre;
  List<dynamic> herkeseAcik_sinavlar = [];
  List<dynamic> herkeseAcik_sinavlar_id = [];
  List<dynamic> has_grup_liste = [];
  List<dynamic> has_grup_liste_id = [];
  List <dynamic> has_gruptakiler = [];
  bool AllList_herkeseAcikSinavlarimdan;
  String has_grup_adi;
  List <dynamic> bildirimler = [];
  List <dynamic> bildirimler_id = [];
  List<dynamic> okunan_bildirimler = [];
  List<dynamic> okunmayan_bildirimler = [];

  AtaWidget ({
    Key key,
    @required Widget child,
    this.sifre,
    this.kullaniciadi,
    this.kullanicimail,
    this.hazirSinav_gonderilenCevaplar,
    this.AllList_kisilerimden,
    this.AllList_hazirladigimSinavlarimdan,
    this.AllList_gonderilenSinavlarimdan,
    this.sinavGonderen_kullaniciadi,
    this.sinavGonderen_id,
    this.olusturulanSinav_gonderilenCevaplar,
    this.olusturulanSinavSoru_gonderilenCevaplar,
    this.dogruSiktan_puanCevaplayan,
    this.olusturulanSinavTestSorusu_isaretleyenler,
    this.cevapSelected_sinavOlustur,
    this.soruSelected_sinavOlustur,
    this.harf_sinavOlustur,
    this.sayi_sinavOlustur,
    this.soru_metni_sinavOlustur,
    this.gorsel_soru_sinavOlustur,
    this.metinsel_soru_sinavOlustur,
    this.soru_testmi_sinavOlustur,
    this.test_mesaji_sinavOlustur,
    this.baslik_sinavOlustur,
    this.sinav_baslik_sinavOlustur,
    this.idnewDoc_sinavOlustur,
    this.id_subCol_newDoc_sinavOlustur,
    this.grupAdi_AllList,
    this.altbilgi_olusturulanSinav,
    this.ustbilgi_olusturulanSinav,
    this.yazili_olusturulanSinav,
    this.soru_ici_bosluk,
    this.sorular_arasi_mesafe,
    this.sutun_sayisi,
    this.sorularin_boyutu,
    this.boyut_txt,
    this.bosluk_txt,
    this.a4,
    this.formHelper,
    this.formHelper_metinselSoru_baslik,
    this.formHelper_metinselSoru_soruMetni,
    this.formHelper_metinselSoru_puan,
    this.metinsel_sik,
    this.metinsel_sik_a,
    this.metinsel_sik_b,
    this.metinsel_sik_c,
    this.metinsel_sik_d,
    this.a_sikki_gorsel,
    this.b_sikki_gorsel,
    this.c_sikki_gorsel,
    this.d_sikki_gorsel,
    this.metinsel_soru_bitti,
    this.a_sikki_bitti,
    this.b_sikki_bitti,
    this.c_sikki_bitti,
    this.d_sikki_bitti,
    this.formHelper_gorselSoru_baslik,
    this.formHelper_gorselSoru_puan,
    this.formHelper_ogrenci_cevap_baslik,
    this.formHelper_ogrenci_cevap_aciklama,
    this.has_filtreSecildi,
    this.has_filtre,
    this.herkeseAcik_sinavlar,
    this.herkeseAcik_sinavlar_id,
    this.AllList_herkeseAcikSinavlarimdan,
    this.has_grup_liste,
    this.has_grup_liste_id,
    this.has_gruptakiler,
    this.has_grup_adi,
    this.bildirimler,
    this.bildirimler_id,
    this.okunmayan_bildirimler,
    this.okunan_bildirimler,

  }) : super (key : key, child: child);

  static AtaWidget of (BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<AtaWidget>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}