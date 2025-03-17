import 'package:aps/src/ui/screens/market_screen/components/section_title.dart';
import 'package:aps/src/ui/screens/market_screen/models/demoproducts.dart';
import 'package:aps/src/ui/screens/market_screen/product_card.dart';
import 'package:flutter/material.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Popular Products",
            press: () {},
            // press: () {
            //   Navigator.pushNamed(context, ProductsScreen.routeName);
            // },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(demoProducts.length, (index) {
                if (demoProducts[index].isPopular) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ProductCard(
                      product: demoProducts[index],
                      onPress: () {},
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }
}
