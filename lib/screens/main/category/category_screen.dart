import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mamanike/viewmodel/main/category/category_viewmodel.dart';
import 'package:mamanike/viewmodel/main/category/product_viewmodel.dart';
import 'package:mamanike/widget/category_card.dart';
import 'package:mamanike/screens/main/category/productlist_screen.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends HookWidget {
  const CategoryScreen({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CategoryViewModel>(context);
    final productViewModel = Provider.of<ProductViewModel>(context);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.fetchCategories();
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/svg/carticon.svg',
              height: 32,
              width: 32,
            ),
          ),
          const SizedBox(width: 20),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kategori",
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: const Color(0xFFFFB113),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                "Kategori Sewa Barang",
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.normal),
              )
            ],
          ),
        ),
      ),
      body: Consumer<CategoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.categories.isEmpty) {
            return Center(
              child: Text("Kategori tidak Ditemukan"),
            );
          }

          return ListView(
            children: viewModel.categories.map((document) {
              Map<String, dynamic> itemData =
              document.data() as Map<String, dynamic>;

              return CategoryCard(
                data: itemData,
                onTap: () {
                  viewModel.selectedCategory = itemData;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductlistScreen(data: viewModel.selectedCategory!,),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
