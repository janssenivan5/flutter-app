import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Pesanan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF064E3B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Image.asset(
            'assets/images/surprise_bag.jpg',
            width: double.infinity,
            height: 350,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Surprise Bag - Bintang 5',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp 35.000',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF064E3B)
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Isi tas ini adalah kejutan dari chef kami berdasarkan hidangan prasmanan terbaik hari ini. Dijamin segar dan berkualitas tinggi.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}