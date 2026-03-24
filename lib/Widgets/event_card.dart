import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventCard extends StatefulWidget {
  final String image;
  final String category;
  final String title;
  final String date;

  const EventCard({
    super.key,
    required this.image,
    required this.category,
    required this.title,
    required this.date,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 280.w,
        height: 269.h,
        decoration: BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                ClipRRect(
                    borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16.r)
                    ),
                    child: Image.asset(
                        widget.image,
                        height: 130.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                    )
                ),
                Padding(
                    padding: EdgeInsetsGeometry.all(12.w),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                                widget.category,
                                style: TextStyle(
                                    color: Color(0xFFFF7A1A),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                ),
                            ),
                            SizedBox(height: 6.h,),
                            Text(
                                widget.title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                            SizedBox(height: 6.h,),
                            Row(
                                children: [
                                    Icon(Icons.calendar_today, size: 14.sp,),
                                    SizedBox(width: 6.w,),
                                    Text(
                                        widget.date,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12.sp,
                                        ),
                                    )
                                ],
                            )
                        ],
                    ),
                ),
            ],
        ),
    );
  }
}
