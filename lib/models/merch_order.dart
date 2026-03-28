class MerchItem {
  final String skuId;
  final String displayName;
  final String? size;
  final bool distributed;

  MerchItem({
    required this.skuId,
    required this.displayName,
    this.size,
    required this.distributed,
  });

  factory MerchItem.fromJson(Map<String, dynamic> json) {
    return MerchItem(
      skuId: json['skuId'] as String,
      displayName: json['displayName'] as String,
      size: json['size'] as String?,
      distributed: json['distributed'] as bool? ?? false,
    );
  }
}

class MerchOrder {
  final bool booked;
  final String? otp;
  final List<MerchItem> items;

  MerchOrder({required this.booked, this.otp, required this.items});

  factory MerchOrder.fromJson(Map<String, dynamic> json) {
    return MerchOrder(
      booked: json['booked'] as bool? ?? false,
      otp: json['otp'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => MerchItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get allDistributed => items.every((item) => item.distributed);
  int get distributedCount => items.where((item) => item.distributed).length;
}
