import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

          return Container(
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
                child: GridView.builder(
                  padding: EdgeInsets.only(top: 24.h, bottom: 40.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['name'] as String? ?? '';
                    final imageUrl = data['imageUrl'] as String? ?? '';
                    return _SponsorCell(sponsorName: name, imageUrl: imageUrl);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SponsorCell extends StatelessWidget {
  final String sponsorName;
  final String imageUrl;

  const _SponsorCell({required this.sponsorName, required this.imageUrl});

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C).withOpacity(0.4),
                borderRadius: BorderRadius.circular(12.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Icon(Icons.broken_image, color: Colors.grey, size: 30.sp),
                    )
                  : Icon(Icons.image, color: Colors.grey, size: 30.sp),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            sponsorName,
            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
