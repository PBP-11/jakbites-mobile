import 'package:flutter/material.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enaknya makan apa ya?'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'Enaknya makan apa ya?',
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Calorie lovers, langsung cari aja disini!',
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // Responsive font size
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Search Section
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showSearch(
                          context: context, 
                          delegate: CustomSearch(),
                        );
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Nom..nom..nomm',
                            hintStyle: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey.shade800,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.015,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  IconButton(
                    icon: Icon(Icons.search, size: screenWidth * 0.07),
                    onPressed: () {
                      showSearch(
                        context: context, 
                        delegate: CustomSearch(),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // Info Section
              LayoutBuilder(
                builder: (context, constraints) {
                  // Menyesuaikan jumlah kolom berdasarkan lebar layar
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
                  return Wrap(
                    spacing: screenWidth * 0.04,
                    runSpacing: screenHeight * 0.02,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      _buildInfoCard('Pilih dari', '209', 'Restoran', screenWidth),
                      _buildInfoCard('Dengan total', '133', 'Kategori', screenWidth),
                      _buildInfoCard('Lebih dari', '7524', 'Makanan', screenWidth),
                    ],
                  );
                },
              ),

              SizedBox(height: screenHeight * 0.05),

              // Features Section
              _buildFeatureCard(
                title: 'Resto',
                description: 'Banyak pilihan, banyak rasa, monggo dipilih!!',
                screenWidth: screenWidth,
              ),
              _buildFeatureCard(
                title: 'Eats',
                description:
                    'Ke pasar beli lemper, tidak lupa beli bolu. Daripada laper, ayo dicari dulu. Eak.',
                screenWidth: screenWidth,
              ),
              _buildFeatureCard(
                title: 'Re-Bites',
                description:
                    'Abis nyoba resto/makanan tapi ga enak? Taro disini aja, kita mah orangnya jujur!',
                screenWidth: screenWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String count, String subtitle, double screenWidth) {
    return Container(
      width: screenWidth * 0.25, // Responsive width
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey.shade700),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            count,
            style: TextStyle(
              fontSize: screenWidth * 0.075,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            subtitle,
            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required double screenWidth,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            description,
            style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class SearchItem {
  final String title;
  final String description;
  final String category;

  SearchItem({
    required this.title, 
    required this.description, 
    required this.category
  });
}

class CustomSearch extends SearchDelegate {
  // Expanded dummy data with more comprehensive search items
  final List<SearchItem> searchItems = [
    SearchItem(
      title: 'Resto', 
      description: 'Banyak pilihan, banyak rasa, monggo dipilih!!', 
      category: 'Feature'
    ),
    SearchItem(
      title: 'Eats', 
      description: 'Ke pasar beli lemper, tidak lupa beli bolu. Daripada laper, ayo dicari dulu. Eak.', 
      category: 'Feature'
    ),
    SearchItem(
      title: 'Re-Bites', 
      description: 'Abis nyoba resto/makanan tapi ga enak? Taro disini aja, kita mah orangnya jujur!', 
      category: 'Feature'
    ),
    SearchItem(
      title: 'Pilih dari', 
      description: '209 Restoran', 
      category: 'Info'
    ),
    SearchItem(
      title: 'Dengan total', 
      description: '133 Kategori', 
      category: 'Info'
    ),
    SearchItem(
      title: 'Lebih dari', 
      description: '7524 Makanan', 
      category: 'Info'
    ),
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = searchItems.where((item) => 
      item.title.toLowerCase().contains(query.toLowerCase()) ||
      item.description.toLowerCase().contains(query.toLowerCase()) ||
      item.category.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.description),
          trailing: Text(item.category, 
            style: TextStyle(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic
            )
          ),
          onTap: () {
            // You can add specific navigation or action here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: ${item.title}'))
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = searchItems.where((item) => 
      item.title.toLowerCase().contains(query.toLowerCase()) ||
      item.description.toLowerCase().contains(query.toLowerCase()) ||
      item.category.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.description),
          trailing: Text(item.category, 
            style: TextStyle(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic
            )
          ),
          onTap: () {
            query = item.title;
            showResults(context);
          },
        );
      },
    );
  }
}
