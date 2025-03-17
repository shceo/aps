import 'package:aps/src/ui/screens/market_screen/components/categories.dart';
import 'package:aps/src/ui/screens/market_screen/components/discount_banner.dart';
import 'package:aps/src/ui/screens/market_screen/components/market_header.dart';
import 'package:aps/src/ui/screens/market_screen/components/popular_product.dart';
import 'package:aps/src/ui/screens/market_screen/components/special_offers.dart';
import 'package:flutter/material.dart';



class MarketScreen extends StatelessWidget {
  const MarketScreen({
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
   return const Scaffold(
    backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              MarketHeader(),
              DiscountBanner(),
              Categories(),
              SpecialOffers(),
              SizedBox(height: 20),
              PopularProducts(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
    }
}
