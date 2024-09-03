import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Etkinlikler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EtkinlikListScreen(),
    );
  }
}

class EtkinlikListScreen extends StatefulWidget {
  @override
  _EtkinlikListScreenState createState() => _EtkinlikListScreenState();
}

class _EtkinlikListScreenState extends State<EtkinlikListScreen> {
  late Future<List<Etkinlik>> futureEtkinlikler;

  @override
  void initState() {
    super.initState();
    futureEtkinlikler = ApiService().fetchEtkinlikler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etkinlikler'),
      ),
      body: FutureBuilder<List<Etkinlik>>(
        future: futureEtkinlikler,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Etkinlik etkinlik = snapshot.data![index];
                return Card(
                  child: ListTile(
                    leading: Image.network(etkinlik.resim),
                    title: Text(etkinlik.ad),
                    subtitle: Text(
                        '${etkinlik.aciklama}\nKatılan: ${etkinlik.katilanSayisi} / ${etkinlik.toplamKontenjan}\nTarih: ${etkinlik.tarih}\nYer: ${etkinlik.yer}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  KayitFormScreen(etkinlikId: etkinlik.id)),
                        );
                      },
                      child: Text('Kayıt Ol'),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class KayitFormScreen extends StatelessWidget {
  final int etkinlikId;

  KayitFormScreen({required this.etkinlikId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Formu'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'İsim'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Soyisim'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Telefon'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Doğum Tarihi'),
              ),
              ListTile(
                title: const Text('Cinsiyet'),
                trailing: DropdownButton<String>(
                  items: <String>['Erkek', 'Kadın'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle form submission
                },
                child: Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Etkinlik {
  final int id;
  final String ad;
  final String resim;
  final int katilanSayisi;
  final int toplamKontenjan;
  final String aciklama;
  final String yer;
  final String tarih;

  Etkinlik({
    required this.id,
    required this.ad,
    required this.resim,
    required this.katilanSayisi,
    required this.toplamKontenjan,
    required this.aciklama,
    required this.yer,
    required this.tarih,
  });

  factory Etkinlik.fromJson(Map<String, dynamic> json) {
    return Etkinlik(
      id: json['id'],
      ad: json['ad'],
      resim: json['resim'],
      katilanSayisi: json['katilan_sayisi'],
      toplamKontenjan: json['toplam_kontenjan'],
      aciklama: json['aciklama'],
      yer: json['yer'],
      tarih: json['tarih'],
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://192.168.1.111:8000/api';

  Future<List<Etkinlik>> fetchEtkinlikler() async {
    final response = await http.get(Uri.parse('$baseUrl/etkinlikler/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((etkinlik) => Etkinlik.fromJson(etkinlik))
          .toList();
    } else {
      throw Exception('Failed to load etkinlikler');
    }
  }
}
