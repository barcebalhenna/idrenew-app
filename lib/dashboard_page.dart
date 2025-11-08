import 'package:flutter/material.dart';
import 'search_page.dart';
import 'main.dart';
import 'scan_details_page.dart';
import 'category_page.dart';
import 'dispose_details_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12), // rounded rectangle
              ),
              child: const Icon(Icons.recycling, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              "IDRenew",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroSection(),
            SizedBox(height: 20),
            ScanCard(),
            SizedBox(height: 20),
            RecentScans(),
            SizedBox(height: 20),
            CategoryGrid(),
          ],
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          Text(
            "Turn Waste into Worth",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Discover if your device parts can be reused or find the best disposal locations",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------- ScanCard ----------------
class ScanCard extends StatelessWidget {
  const ScanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 32,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Scan Your Device",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "Take a photo or search for device parts to check reusability",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // ✅ Navigate to ScanPage
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () {
                mainPageKey.currentState?.navigateTo(1); // Go to Scan tab
              },
              label: const Text(
                "Take Photo",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Navigate to SearchPage
            ElevatedButton.icon(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              label: const Text(
                "Search Parts",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentScans extends StatelessWidget {
  const RecentScans({super.key});

  @override
  Widget build(BuildContext context) {
    final scans = [
      {
        "title": "Phone Battery",
        "status": "✓ Reusable - 3 options found",
        "statusColor": const Color(0xFF10B981),
        "icon": Icons.battery_full,
      },
      {
        "title": "RAM Module",
        "status": "⚠ Dispose - 2 centers nearby",
        "statusColor": Colors.red,
        "icon": Icons.memory,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Scans",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  mainPageKey.currentState?.navigateTo(2); // Switch to History tab
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ✅ Scan cards
        Column(
          children: scans.map((scan) {
            return InkWell(
              onTap: () {
                if (scan["statusColor"] == const Color(0xFF10B981)) {
                  // ✅ Reusable → go to ScanDetailsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanDetailsPage(
                        partName: scan["title"] as String,
                        status: scan["status"] as String,
                        statusColor: scan["statusColor"] as Color,
                        icon: scan["icon"] as IconData,
                      ),
                    ),
                  );
                } else {
                  // ❌ Disposable → go to DisposeDetailsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisposeDetailsPage(
                        partName: scan["title"] as String,
                        status: scan["status"] as String,
                        icon: scan["icon"] as IconData,
                      ),
                    ),
                  );
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                color: const Color(0xFFF9FAFB),
                child: ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (scan["statusColor"] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      scan["icon"] as IconData,
                      color: scan["statusColor"] as Color,
                    ),
                  ),
                  title: Text(scan["title"] as String),
                  subtitle: Text(
                    scan["status"] as String,
                    style: TextStyle(color: scan["statusColor"] as Color),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        "title": "Phone Parts",
        "desc": "Batteries, screens, cases",
        "icon": Icons.phone_iphone,
      },
      {
        "title": "Laptop Parts",
        "desc": "RAM, drives, keyboards",
        "icon": Icons.laptop,
      },
      {
        "title": "Components",
        "desc": "Chips, circuits, cables",
        "icon": Icons.memory,
      },
      {
        "title": "Accessories",
        "desc": "Chargers, adapters",
        "icon": Icons.cable,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Browse by Category",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];

            // Decide gradient based on column (0 = left, 1 = right)
            final isLeftColumn = index % 2 == 0;
            final gradientColors = isLeftColumn
                ? [Color(0xFFDCFCE7), Colors.white]
                : [Color(0xFFDBEAFE), Colors.white];

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryPage(title: cat["title"] as String),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isLeftColumn
                            ? Colors.green
                            : Colors.blue,
                        child: Icon(
                          cat["icon"] as IconData,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        cat["title"] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat["desc"] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
