import 'package:flutter/material.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("면담자 상세 정보")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey.withOpacity(0.1),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("이름: 홍길동", style: TextStyle(fontSize: 16)),
                Text("나이: 70세", style: TextStyle(fontSize: 16)),
                Text("다음 약속: 2026-04-25 15:00", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "이전 상담 세션 기록",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("세션 $index"),
                  subtitle: Text("2026-04-${10 + index}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
