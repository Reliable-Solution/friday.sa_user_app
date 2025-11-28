class PromotionalBanner {
  PromotionalBanner({
    this.basicSectionNearbyFullUrl,
    this.bottomSectionBannerFullUrl,
  });

  PromotionalBanner.fromJson(Map<String, dynamic> json) {
    basicSectionNearbyFullUrl = json['basic_section_nearby_full_url'];
    bottomSectionBannerFullUrl = json['bottom_section_banner_full_url'];
  }
  String? basicSectionNearbyFullUrl;
  String? bottomSectionBannerFullUrl;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['basic_section_nearby_full_url'] = basicSectionNearbyFullUrl;
    data['bottom_section_banner_full_url'] = bottomSectionBannerFullUrl;
    return data;
  }
}
