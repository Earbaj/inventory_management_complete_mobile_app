import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmerView extends StatelessWidget {
  final bool isAdmin;

  const DashboardShimmerView({super.key, this.isAdmin = true});

  // ছোট শিমার বক্স তৈরির সহজ হেল্পার
  Widget _box({double? width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // স্ট্যাট কার্ড শিমার
  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _box(width: 75, height: 12),
              _box(width: 32, height: 32, radius: 8),
            ],
          ),
          const Spacer(),
          _box(width: 80, height: 18),
          const SizedBox(height: 6),
          _box(width: 50, height: 10),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _box(width: 30, height: 20),
          _box(width: 70, height: 20),
        ],
      ),
    );
  }

  // চার্ট ও লিস্ট সেকশনের জন্য শিমার কার্ড
  Widget _buildCard({required double height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _box(width: 130, height: 14),
              _box(width: 50, height: 14),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _box(width: double.infinity, height: double.infinity, radius: 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ১. কুইক অ্যাকশন বাটনস
            if (isAdmin)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 16),
                      child: _buildQuickActionCard( height: 38,width: 130),
                    ),
                  ),
                ),
              ),

            // ২. স্ট্যাট কার্ডস গ্রিড (৬টি কার্ড)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.28,
              ),
              itemBuilder: (context, index) => _buildStatCard(),
            ),

            const SizedBox(height: 20),

            // ৩. সেলস চার্ট
            _buildCard(height: 260),

            // ৪. প্রফিট চার্ট (অ্যাডমিন)
            if (isAdmin) ...[
              const SizedBox(height: 16),
              _buildCard(height: 240),
            ],

            const SizedBox(height: 20),

            // ৫. টপ সেলিং ও রিসেন্ট ট্রানজ্যাকশন
            _buildCard(height: 180),
            const SizedBox(height: 16),
            _buildCard(height: 180),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
