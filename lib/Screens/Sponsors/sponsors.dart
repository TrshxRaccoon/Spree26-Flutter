import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class Sponsors extends StatelessWidget {
  const Sponsors({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sponsors',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'spree-26',
        ).collection('sponsors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No sponsors found.', style: TextStyle(color: Colors.white)));
          }

          final titleSponsors = docs.where((doc) => doc['tier'] == 'Title').toList();
          final goldSponsors = docs.where((doc) => doc['tier'] == 'Gold').toList();
          final supportingSponsors = docs.where((doc) => doc['tier'] == 'Supporting').toList();

          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h),
                      if (titleSponsors.isNotEmpty) ...[
                        _buildSectionHeader('Title Sponsors', showPremiumTag: true),
                        SizedBox(height: 16.h),
                        ...titleSponsors.map((doc) => Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: TitleSponsorCard(
                            sponsorName: doc['name'] ?? '',
                            imageUrl: doc['imageUrl'] ?? '',
                            websiteUrl: doc['websiteUrl'] ?? '',
                          ),
                        )),
                      ],
                      SizedBox(height: 45.h),
                      if (goldSponsors.isNotEmpty) ...[
                        _buildSectionHeader('Gold Sponsors'),
                        SizedBox(height: 16.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16.h,
                            crossAxisSpacing: 16.w,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: goldSponsors.length,
                          itemBuilder: (context, index) => GoldSponsorCard(
                            sponsorName: goldSponsors[index]['name'] ?? '',
                            imageUrl: goldSponsors[index]['imageUrl'] ?? '',
                          ),
                        ),
                        SizedBox(height: 45.h),
                      ],
                      if (supportingSponsors.isNotEmpty) ...[
                        _buildSectionHeader('Supporting Partners'),
                        SizedBox(height: 16.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16.h,
                            crossAxisSpacing: 16.w,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: supportingSponsors.length,
                          itemBuilder: (context, index) => SupportingPartnerCard(
                            sponsorName: supportingSponsors[index]['name'] ?? '',
                            imageUrl: supportingSponsors[index]['imageUrl'] ?? '',
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showPremiumTag = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        if (showPremiumTag)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.orange.shade800),
            ),
            child: Text('PREMIUM', style: TextStyle(color: Colors.orange.shade400, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
      ],
    );
  }
}

class TitleSponsorCard extends StatelessWidget {
  final String sponsorName;
  final String imageUrl;
  final String websiteUrl;

  const TitleSponsorCard({super.key, required this.sponsorName, required this.imageUrl, required this.websiteUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6), // Transparent card background
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C).withOpacity(0.4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(Icons.broken_image, color: Colors.grey, size: 40.sp),
                )
                    : Icon(Icons.image, color: Colors.grey, size: 50.sp),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TITLE PARTNER', style: TextStyle(color: const Color(0xFFD32F2F), fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                SizedBox(height: 4.h),
                Text(sponsorName, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (websiteUrl.isNotEmpty) {
                        final Uri url = Uri.parse(websiteUrl);
                        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text('Visit Website', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class GoldSponsorCard extends StatelessWidget {
  final String sponsorName;
  final String imageUrl;

  const GoldSponsorCard({super.key, required this.sponsorName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C).withOpacity(0.4),
                borderRadius: BorderRadius.circular(12.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (c, e, s) => Icon(Icons.broken_image, color: Colors.grey, size: 30.sp))
                  : Icon(Icons.image, color: Colors.grey, size: 30.sp),
            ),
          ),
          SizedBox(height: 12.h),
          Text('GOLD', style: TextStyle(color: Colors.white54, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          SizedBox(height: 4.h),
          Text(sponsorName, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class SupportingPartnerCard extends StatelessWidget {
  final String sponsorName;
  final String imageUrl;

  const SupportingPartnerCard({super.key, required this.sponsorName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C).withOpacity(0.4),
                borderRadius: BorderRadius.circular(8.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (c, e, s) => Icon(Icons.broken_image, color: Colors.grey, size: 24.sp))
                  : Icon(Icons.image, color: Colors.grey, size: 24.sp),
            ),
          ),
          SizedBox(height: 8.h),
          Text(sponsorName, style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}