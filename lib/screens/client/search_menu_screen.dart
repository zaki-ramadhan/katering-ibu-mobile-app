import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katering_ibu_m_flutter/constants/index.dart';
import 'package:katering_ibu_m_flutter/models/menu_model.dart';
import 'package:katering_ibu_m_flutter/services/menu_service.dart';
import 'package:katering_ibu_m_flutter/widgets/custom_app_bar.dart';
import 'package:katering_ibu_m_flutter/widgets/menu_card.dart';
import 'package:logger/logger.dart';

class SearchMenuScreen extends StatefulWidget {
  final String searchMenuName;

  const SearchMenuScreen({super.key, required this.searchMenuName});

  @override
  State<SearchMenuScreen> createState() => _SearchMenuScreenState();
}

class _SearchMenuScreenState extends State<SearchMenuScreen> {
  List<Menu> _searchResults = [];
  bool _isLoading = true;
  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _searchMenus(widget.searchMenuName);
  }

  Future<void> _searchMenus(String searchMenuName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final menus = await MenuService().getMenus();
      final results =
          menus
              .where(
                (menu) => menu.namaMenu.toLowerCase().contains(
                  searchMenuName.toLowerCase(),
                ),
              )
              .toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      logger.e('Error searching menus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleAppBar: 'Hasil Pencarian (${_searchResults.length})',
        isIconShow: true,
        isLogoutIconShow: false,
        isNavigableByBottomBar: true,
      ),
      backgroundColor: white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                'Anda mencari : ${widget.searchMenuName}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                    ? Center(
                      child: Text(
                        'Tidak ada hasil untuk "${widget.searchMenuName}"',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16),
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 24,
                          ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return MenuCard(menu: _searchResults[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
