import 'package:flutter/material.dart';
import 'scan_details_page.dart';
import 'dispose_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String _query = "";

  // 🔹 Shared parts list (same structure as history/category)
  final List<Map<String, dynamic>> _parts = [
    {
      "title": "Phone Battery",
      "status": "✓ Reusable - 3 options found",
      "statusType": "reusable",
      "icon": Icons.battery_full,
    },
    {
      "title": "RAM Module",
      "status": "⚠ Dispose - 2 centers nearby",
      "statusType": "dispose",
      "icon": Icons.memory,
    },
    {
      "title": "Hard Drive",
      "status": "⚠ Dispose - 4 centers nearby",
      "statusType": "dispose",
      "icon": Icons.storage,
    },
    {
      "title": "Laptop Keyboard",
      "status": "✓ Reusable - 4 options found",
      "statusType": "reusable",
      "icon": Icons.keyboard,
    },
    {
      "title": "Screen Display",
      "status": "⚠ Dispose - cracked",
      "statusType": "dispose",
      "icon": Icons.phone_android,
    },
    {
      "title": "Charging Cable",
      "status": "✓ Reusable - 5 options found",
      "statusType": "reusable",
      "icon": Icons.cable,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter results based on query
    final results = _parts
        .where((item) =>
        item["title"].toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Search Parts",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: "Search for device parts...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📌 Suggestions / Results
          Expanded(
            child: _query.isEmpty
                ? _buildSuggestions()
                : _buildResults(results),
          ),
        ],
      ),
    );
  }

  // 🟢 Suggestion List
  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text("Suggestions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _parts.map((item) {
            return ActionChip(
              backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
              label: Text(item["title"],
                  style: const TextStyle(color: Color(0xFF10B981))),
              onPressed: () {
                _openDetails(item);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 🔎 Search Results
  Widget _buildResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text("No results found",
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final isReusable = item["statusType"] == "reusable";

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                (isReusable ? const Color(0xFF10B981) : Colors.red)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item["icon"],
                  color: isReusable ? const Color(0xFF10B981) : Colors.red),
            ),
            title: Text(item["title"]),
            subtitle: const Text("Tap to view details"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _openDetails(item);
            },
          ),
        );
      },
    );
  }

  // 🟡 Navigate to details page depending on type
  void _openDetails(Map<String, dynamic> item) {
    if (item["statusType"] == "reusable") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanDetailsPage(
            partName: item["title"],
            status: item["status"],
            statusColor: const Color(0xFF10B981),
            icon: item["icon"],
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisposeDetailsPage(
            partName: item["title"],
            status: item["status"],
            icon: item["icon"],
          ),
        ),
      );
    }
  }
}
