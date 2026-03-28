import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// Loads contacts from Firestore collection `ContactUs` (fields: Name, Position, Club, Contact).
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  static FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'spree-26',
      );

  Future<void> _dial(String raw) async {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: digits);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
          'Contact Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('ContactUs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  'Could not load contacts.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          final docs = List<QueryDocumentSnapshot>.from(
            snapshot.data?.docs ?? [],
          )..sort((a, b) {
              final an = (a.data() as Map<String, dynamic>)['Name']?.toString() ?? '';
              final bn = (b.data() as Map<String, dynamic>)['Name']?.toString() ?? '';
              return an.toLowerCase().compareTo(bn.toLowerCase());
            });

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No contacts yet.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reach out to the team',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Tap a number to call',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['Name']?.toString() ?? '';
                        final position = data['Position']?.toString() ?? '';
                        final club = data['Club']?.toString() ?? '';
                        final contact = data['Contact']?.toString() ?? '';
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _ContactCard(
                            name: name,
                            position: position,
                            club: club,
                            contact: contact,
                            onCall: contact.isNotEmpty ? () => _dial(contact) : null,
                          ),
                        );
                      }),
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
}

class _ContactCard extends StatelessWidget {
  final String name;
  final String position;
  final String club;
  final String contact;
  final VoidCallback? onCall;

  const _ContactCard({
    required this.name,
    required this.position,
    required this.club,
    required this.contact,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (position.isNotEmpty)
            Text(
              position.toUpperCase(),
              style: TextStyle(
                color: const Color(0xFFFF7A1A),
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          if (position.isNotEmpty) SizedBox(height: 6.h),
          Text(
            name.isNotEmpty ? name : '—',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (club.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 18.sp,
                  color: const Color(0xFF94A3B8),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    club,
                    style: TextStyle(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (contact.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCall,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 18.sp,
                        color: const Color(0xFF00BFA5),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          contact,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white54,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
