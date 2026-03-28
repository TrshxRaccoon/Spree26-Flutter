import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontal gallery fed by Firestore `photos/001` field `photos` (list of image URLs).
class HomeGallery extends StatelessWidget {
  const HomeGallery({super.key});

  /// Uses JSON file metadata instead of sqflite ([DefaultCacheManager] on Android/iOS),
  /// avoiding `MissingPluginException` for sqflite after hot restart or partial plugin loads.
  static final CacheManager _galleryCacheManager = CacheManager(
    Config(
      'homeGalleryImageCache',
      repo: JsonCacheInfoRepository(databaseName: 'homeGalleryImageCache'),
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 80,
    ),
  );

  static FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'spree-26',
      );

  static List<String> _parsePhotoUrls(Map<String, dynamic>? data) {
    if (data == null) return [];
    final raw = data['photos'];
    if (raw is! List) return [];
    final out = <String>[];
    for (final e in raw) {
      if (e is String && e.trim().isNotEmpty) out.add(e.trim());
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Memories from Spree '25",
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 128.h,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('photos').doc('001').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 28.w,
                      height: 28.w,
                      child: const CircularProgressIndicator(
                        color: Color(0xFF00BFA5),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Could not load gallery.',
                        style: TextStyle(color: Colors.white54, fontSize: 13.sp),
                      ),
                    ),
                  );
                }

                final urls = _parsePhotoUrls(snapshot.data?.data());
                if (urls.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'No photos yet.',
                        style: TextStyle(color: Colors.white54, fontSize: 13.sp),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 16.w, right: 16.w),
                  itemCount: urls.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final url = urls[index];
                    return SizedBox(
                      width: 200.w,
                      height: 128.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          cacheManager: _galleryCacheManager,
                          imageUrl: url,
                          fit: BoxFit.cover,
                          memCacheWidth:
                              (200.w * MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                          progressIndicatorBuilder: (context, url, progress) {
                            return Container(
                              color: Colors.white.withValues(alpha: 0.06),
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: CircularProgressIndicator(
                                  color: const Color(0xFF00BFA5),
                                  strokeWidth: 2,
                                  value: progress.progress,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withValues(alpha: 0.08),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white38,
                              size: 32.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
