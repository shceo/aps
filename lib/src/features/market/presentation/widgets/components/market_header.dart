import 'package:aps/src/features/market/presentation/widgets/components/iconbtn.dart';
import 'package:aps/src/features/market/presentation/widgets/components/search_field.dart';
import 'package:flutter/material.dart';

class MarketHeader extends StatelessWidget {
  const MarketHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: SearchField()),
          const SizedBox(width: 16),
          IconBtnWithCounter(
            svgSrc: "assets/icons/Cart Icon.svg", press: () {  },
            // press: () => Navigator.pushNamed(context, CartScreen.routeName),
          ),
          const SizedBox(width: 8),
          IconBtnWithCounter(
            svgSrc: "assets/icons/Bell.svg",
            numOfitem: 3,
            press: () {},
          ),
        ],
      ),
    );
  }
}
