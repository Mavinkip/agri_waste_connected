import '../../features/admin/data/models/location_models.dart';

class KenyaLocations {
  // Ward coordinates for accurate navigation
  static final Map<String, LatLng> _wardCoordinates = {
    // Nakuru County
    'Mai Mahiu': const LatLng(-0.9650, 36.3850),
    'Maiella': const LatLng(-0.9000, 36.4000),
    'Naivasha East': const LatLng(-0.7170, 36.4320),
    'Longonot': const LatLng(-0.9500, 36.4500),
    'Gilgil Town': const LatLng(-0.5042, 36.3300),
    'Elementaita': const LatLng(-0.5167, 36.2833),
    'Mbaruk': const LatLng(-0.4833, 36.3500),
    'Flamingo': const LatLng(-0.2950, 36.0700),
    'Lake View': const LatLng(-0.2900, 36.0800),
    'Menengai': const LatLng(-0.3031, 36.0800),
    'Kaptembwo': const LatLng(-0.2800, 36.0500),
    'Shabaab': const LatLng(-0.2900, 36.0600),
    'London': const LatLng(-0.3100, 36.0900),
    'Njoro Town': const LatLng(-0.3333, 35.9500),
    'Mau Narok': const LatLng(-0.3667, 35.8833),
    'Likia': const LatLng(-0.3167, 35.9167),
    'Molo Town': const LatLng(-0.2500, 35.7333),
    'Elburgon': const LatLng(-0.2333, 35.7500),
    'Turi': const LatLng(-0.2000, 35.7333),
    'Rongai Town': const LatLng(-0.1667, 36.0000),
    'Menengai West': const LatLng(-0.1833, 36.0167),
    'Solai': const LatLng(-0.1167, 36.0833),
    'Subukia Town': const LatLng(-0.0833, 36.1667),
    'Kabazi': const LatLng(-0.1000, 36.2000),
    'Munanda': const LatLng(-0.0667, 36.2167),
    'Bahati Town': const LatLng(-0.2000, 36.1500),
    'Dundori': const LatLng(-0.1667, 36.0833),
    'Lanet': const LatLng(-0.2333, 36.0833),

    // Uasin Gishu County
    'Eldoret Central': const LatLng(0.5143, 35.2698),
    'Langas': const LatLng(0.5400, 35.2800),
    'Huruma': const LatLng(0.5200, 35.2750),
    'Kapsoya': const LatLng(0.5500, 35.2900),
    'Ainabkoi': const LatLng(0.4833, 35.2500),
    'Kapcheno': const LatLng(0.5000, 35.2333),
    'Kaptagat': const LatLng(0.4500, 35.2000),
    'Kesses': const LatLng(0.5333, 35.3500),
    'Tulwet': const LatLng(0.5500, 35.3667),
    'Chuiyat': const LatLng(0.5667, 35.3333),
    'Moiben': const LatLng(0.5833, 35.2667),
    'Karuna': const LatLng(0.6000, 35.2500),
    'Kimumu': const LatLng(0.5667, 35.3000),
    'Soy': const LatLng(0.6333, 35.1667),
    'Ziwa': const LatLng(0.6167, 35.1333),
    'Kipsomba': const LatLng(0.6500, 35.1833),
    'Turbo': const LatLng(0.7000, 35.0333),
    'Tapsagoi': const LatLng(0.7167, 35.0500),
    'Ngenyilel': const LatLng(0.6833, 35.0167),

    // Trans Nzoia County
    'Kitale Central': const LatLng(1.0167, 35.0000),
    'Milimani': const LatLng(1.0200, 35.0100),
    'Bondeni': const LatLng(1.0100, 35.0200),
    'Kiminini': const LatLng(0.9667, 34.9500),
    'Sikhendu': const LatLng(0.9500, 34.9333),
    'Nabiswa': const LatLng(0.9333, 34.9667),
    'Saboti': const LatLng(0.9000, 35.0000),
    'Machewa': const LatLng(0.8833, 35.0333),
    'Kitalale': const LatLng(0.9167, 35.0500),
    'Endebess': const LatLng(0.8333, 34.9000),
    'Chepchoina': const LatLng(0.8500, 34.8833),
    'Mwanza': const LatLng(0.8167, 34.8667),

    // Nandi County
    'Kapsabet Town': const LatLng(0.2000, 35.1000),
    'Kilibwoni': const LatLng(0.2167, 35.1167),
    'Chepkunyuk': const LatLng(0.2333, 35.1333),
    'Nandi Hills Town': const LatLng(0.1000, 35.1667),
    'Chepterwai': const LatLng(0.1167, 35.1500),
    'Kaptel': const LatLng(0.0833, 35.1833),
    'Kaptumo': const LatLng(0.1500, 35.0500),
    'Koyo': const LatLng(0.1667, 35.0333),
    'Ndurio': const LatLng(0.1333, 35.0667),

    // Kericho County
    'Kericho Central': const LatLng(-0.3677, 35.2831),
    'Kapsoit': const LatLng(-0.3500, 35.3000),
    'Chepseon': const LatLng(-0.3333, 35.3167),
    'Londiani': const LatLng(-0.1667, 35.5833),
    'Kedowa': const LatLng(-0.1833, 35.6000),
    'Litein': const LatLng(-0.5833, 35.1833),
    'Kapkatet': const LatLng(-0.5667, 35.2000),
    'Cheplanget': const LatLng(-0.6000, 35.1667),

    // Baringo County
    'Kabarnet Town': const LatLng(0.4667, 35.9667),
    'Kapropita': const LatLng(0.4833, 35.9833),
    'Ewalel': const LatLng(0.4500, 35.9500),
    'Eldama Ravine': const LatLng(0.0500, 35.7167),
    'Lembus': const LatLng(0.0333, 35.7000),
    'Esageri': const LatLng(0.0167, 35.7333),
    'Marigat': const LatLng(0.4667, 35.9833),
    'Mochongoi': const LatLng(0.5000, 36.0000),
    'Sandai': const LatLng(0.4333, 35.9667),

    // Kiambu County
    'Thika Town': const LatLng(-1.0333, 37.0833),
    'Makongeni': const LatLng(-1.0333, 37.1000),
    'Bendor': const LatLng(-1.0500, 37.0667),
    'Ruiru Town': const LatLng(-1.1500, 36.9667),
    'Githurai': const LatLng(-1.1667, 36.9500),
    'Kamakis': const LatLng(-1.1333, 36.9833),
    'Limuru Town': const LatLng(-1.1167, 36.6500),
    'Tigoni': const LatLng(-1.1000, 36.6333),
    'Ndeiya': const LatLng(-1.0833, 36.6167),

    // Nairobi County
    'Kitisuru': const LatLng(-1.2500, 36.7833),
    'Parklands': const LatLng(-1.2667, 36.8000),
    'Kangemi': const LatLng(-1.2833, 36.7667),
    'Karen': const LatLng(-1.3333, 36.7167),
    'Nairobi West': const LatLng(-1.3000, 36.8000),
    'South C': const LatLng(-1.3167, 36.8167),
    'Clay City': const LatLng(-1.2167, 36.9167),
    'Mwiki': const LatLng(-1.2000, 36.9333),
    'Zimmerman': const LatLng(-1.1833, 36.9000),
  };

  // Sub-county coordinates (fallback if ward not found)
  static final Map<String, LatLng> _subCountyCoordinates = {
    'Naivasha': const LatLng(-0.7173, 36.4322),
    'Gilgil': const LatLng(-0.5042, 36.3300),
    'Nakuru Town East': const LatLng(-0.3031, 36.0800),
    'Nakuru Town West': const LatLng(-0.2900, 36.0600),
    'Njoro': const LatLng(-0.3333, 35.9500),
    'Molo': const LatLng(-0.2500, 35.7333),
    'Rongai': const LatLng(-0.1667, 36.0000),
    'Subukia': const LatLng(-0.0833, 36.1667),
    'Bahati': const LatLng(-0.2000, 36.1500),
    'Eldoret Town': const LatLng(0.5143, 35.2698),
    'Ainabkoi': const LatLng(0.4833, 35.2500),
    'Kesses': const LatLng(0.5333, 35.3500),
    'Moiben': const LatLng(0.5833, 35.2667),
    'Soy': const LatLng(0.6333, 35.1667),
    'Turbo': const LatLng(0.7000, 35.0333),
    'Kitale Town': const LatLng(1.0167, 35.0000),
    'Kiminini': const LatLng(0.9667, 34.9500),
    'Saboti': const LatLng(0.9000, 35.0000),
    'Endebess': const LatLng(0.8333, 34.9000),
    'Kapsabet': const LatLng(0.2000, 35.1000),
    'Nandi Hills': const LatLng(0.1000, 35.1667),
    'Aldai': const LatLng(0.1500, 35.0500),
    'Kericho Town': const LatLng(-0.3677, 35.2831),
    'Londiani': const LatLng(-0.1667, 35.5833),
    'Bureti': const LatLng(-0.5833, 35.1833),
    'Kabarnet': const LatLng(0.4667, 35.9667),
    'Eldama Ravine': const LatLng(0.0500, 35.7167),
    'Marigat': const LatLng(0.4667, 35.9833),
    'Thika': const LatLng(-1.0333, 37.0833),
    'Ruiru': const LatLng(-1.1500, 36.9667),
    'Limuru': const LatLng(-1.1167, 36.6500),
    'Westlands': const LatLng(-1.2667, 36.8000),
    'Langata': const LatLng(-1.3333, 36.7167),
    'Kasarani': const LatLng(-1.2167, 36.9167),
  };

  // County coordinates (fallback if sub-county not found)
  static final Map<String, LatLng> _countyCoordinates = {
    'Nakuru': const LatLng(-0.3031, 36.0800),
    'Uasin Gishu': const LatLng(0.5143, 35.2698),
    'Trans Nzoia': const LatLng(1.0167, 35.0000),
    'Nandi': const LatLng(0.2000, 35.1000),
    'Kericho': const LatLng(-0.3677, 35.2831),
    'Baringo': const LatLng(0.4667, 35.9667),
    'Kiambu': const LatLng(-1.1667, 36.8333),
    'Nairobi': const LatLng(-1.286389, 36.817223),
  };

  // Waste processing centers coordinates
  static final Map<String, LatLng> _destinationCoordinates = {
    'Nakuru Waste Processing Center': const LatLng(-0.3031, 36.0800),
    'Eldoret Recycling Plant': const LatLng(0.5143, 35.2698),
    'Kitale Waste Management': const LatLng(1.0167, 35.0000),
    'Nairobi Recycling Hub': const LatLng(-1.286389, 36.817223),
    'Kisumu Waste Treatment': const LatLng(-0.1022, 34.7617),
    'Mombasa Recycling Center': const LatLng(-4.0435, 39.6682),
    'Thika Industrial Waste': const LatLng(-1.0333, 37.0833),
    'Kericho Organic Processing': const LatLng(-0.3677, 35.2831),
    'Nandi Hills Collection Center': const LatLng(0.1000, 35.1667),
    'Baringo Waste Facility': const LatLng(0.4667, 35.9667),
  };

  static List<County> getDefaultCounties() {
    return [
      County(id: 'nakuru', name: 'Nakuru', lastUpdated: DateTime.now(), subCounties: [
        SubCounty(name: 'Naivasha', wards: ['Mai Mahiu', 'Maiella', 'Naivasha East', 'Longonot']),
        SubCounty(name: 'Gilgil', wards: ['Gilgil Town', 'Elementaita', 'Mbaruk']),
        SubCounty(name: 'Nakuru Town East', wards: ['Flamingo', 'Lake View', 'Menengai']),
        SubCounty(name: 'Nakuru Town West', wards: ['Kaptembwo', 'Shabaab', 'London']),
        SubCounty(name: 'Njoro', wards: ['Njoro Town', 'Mau Narok', 'Likia']),
        SubCounty(name: 'Molo', wards: ['Molo Town', 'Elburgon', 'Turi']),
        SubCounty(name: 'Rongai', wards: ['Rongai Town', 'Menengai West', 'Solai']),
        SubCounty(name: 'Subukia', wards: ['Subukia Town', 'Kabazi', 'Munanda']),
        SubCounty(name: 'Bahati', wards: ['Bahati Town', 'Dundori', 'Lanet']),
      ]),
      County(id: 'uasin_gishu', name: 'Uasin Gishu', lastUpdated: DateTime.now(), subCounties: [
        SubCounty(name: 'Eldoret Town', wards: ['Eldoret Central', 'Langas', 'Huruma', 'Kapsoya']),
        SubCounty(name: 'Ainabkoi', wards: ['Ainabkoi', 'Kapcheno', 'Kaptagat']),
        SubCounty(name: 'Kesses', wards: ['Kesses', 'Tulwet', 'Chuiyat']),
        SubCounty(name: 'Moiben', wards: ['Moiben', 'Karuna', 'Kimumu']),
        SubCounty(name: 'Soy', wards: ['Soy', 'Ziwa', 'Kipsomba']),
        SubCounty(name: 'Turbo', wards: ['Turbo', 'Tapsagoi', 'Ngenyilel']),
      ]),
      County(id: 'trans_nzoia', name: 'Trans Nzoia', lastUpdated: DateTime.now(), subCounties: [
        SubCounty(name: 'Kitale Town', wards: ['Kitale Central', 'Milimani', 'Bondeni']),
        SubCounty(name: 'Kiminini', wards: ['Kiminini', 'Sikhendu', 'Nabiswa']),
        SubCounty(name: 'Saboti', wards: ['Saboti', 'Machewa', 'Kitalale']),
        SubCounty(name: 'Endebess', wards: ['Endebess', 'Chepchoina', 'Mwanza']),
      ]),
      County(id: 'nandi', name: 'Nandi', lastUpdated: DateTime.now(), subCounties: [
        SubCounty(name: 'Kapsabet', wards: ['Kapsabet Town', 'Kilibwoni', 'Chepkunyuk']),
        SubCounty(name: 'Nandi Hills', wards: ['Nandi Hills Town', 'Chepterwai', 'Kaptel']),
        SubCounty(name: 'Aldai', wards: ['Kaptumo', 'Koyo', 'Ndurio']),
      ]),
      County(id: 'kericho', name: 'Kericho', lastUpdated: DateTime.now(), subCounties: [
        SubCounty(name: 'Kericho Town', wards: ['Kericho Central', 'Kapsoit', 'Chepseon']),
        SubCounty(name: 'Londiani', wards: ['Londiani', 'Kedowa', 'Chepseon']),
        SubCounty(name: 'Bureti', wards: ['Litein', 'Kapkatet', 'Cheplanget']),
      ]),
      County(id: 'baringo', name: 'Baringo', lastUpdated: DateTime.now(), subCounties: [
        SubCounty(name: 'Kabarnet', wards: ['Kabarnet Town', 'Kapropita', 'Ewalel']),
        SubCounty(name: 'Eldama Ravine', wards: ['Eldama Ravine', 'Lembus', 'Esageri']),
        SubCounty(name: 'Marigat', wards: ['Marigat', 'Mochongoi', 'Sandai']),
      ]),
      County(id: 'kiambu', name: 'Kiambu', lastUpdated: DateTime.now(), subCounties: [
        SubCounty(name: 'Thika', wards: ['Thika Town', 'Makongeni', 'Bendor']),
        SubCounty(name: 'Ruiru', wards: ['Ruiru Town', 'Githurai', 'Kamakis']),
        SubCounty(name: 'Limuru', wards: ['Limuru Town', 'Tigoni', 'Ndeiya']),
      ]),
      County(id: 'nairobi', name: 'Nairobi', lastUpdated: DateTime.now(), subCounties: [
        SubCounty(name: 'Westlands', wards: ['Kitisuru', 'Parklands', 'Kangemi']),
        SubCounty(name: 'Langata', wards: ['Karen', 'Nairobi West', 'South C']),
        SubCounty(name: 'Kasarani', wards: ['Clay City', 'Mwiki', 'Zimmerman']),
      ]),
    ];
  }

  static List<String> getCountyNames() => getDefaultCounties().map((c) => c.name).toList();

  static List<String> getSubCountyNames(String countyName) {
    final county = getDefaultCounties().where((c) => c.name == countyName).firstOrNull;
    return county?.subCounties.map((s) => s.name).toList() ?? [];
  }

  static List<String> getWardNames(String countyName, String subCountyName) {
    final county = getDefaultCounties().where((c) => c.name == countyName).firstOrNull;
    final sc = county?.subCounties.where((s) => s.name == subCountyName).firstOrNull;
    return sc?.wards ?? [];
  }

  // ─── NEW: Get Coordinates Methods ───

  /// Get coordinates for a specific ward
  static LatLng? getWardCoordinates(String wardName) {
    return _wardCoordinates[wardName];
  }

  /// Get coordinates for a specific sub-county (fallback)
  static LatLng? getSubCountyCoordinates(String subCountyName) {
    return _subCountyCoordinates[subCountyName];
  }

  /// Get coordinates for a specific county (fallback)
  static LatLng? getCountyCoordinates(String countyName) {
    return _countyCoordinates[countyName];
  }

  /// Get coordinates for a destination/processing center
  static LatLng? getDestinationCoordinates(String destinationName) {
    return _destinationCoordinates[destinationName];
  }

  /// Get the best available coordinates for a location
  /// Tries: Ward → Sub-County → County
  static LatLng? getLocationCoordinates({
    required String county,
    String? subCounty,
    String? ward,
  }) {
    // Try ward first (most accurate)
    if (ward != null && ward.isNotEmpty) {
      final coords = getWardCoordinates(ward);
      if (coords != null) return coords;
    }

    // Try sub-county next
    if (subCounty != null && subCounty.isNotEmpty) {
      final coords = getSubCountyCoordinates(subCounty);
      if (coords != null) return coords;
    }

    // Fallback to county
    if (county.isNotEmpty) {
      final coords = getCountyCoordinates(county);
      if (coords != null) return coords;
    }

    // Default to Nairobi if nothing found
    return const LatLng(-1.286389, 36.817223);
  }

  /// Get coordinates for a destination
  static LatLng? getDestinationLocation(String destinationName) {
    return getDestinationCoordinates(destinationName);
  }

  /// Get all destination names
  static List<String> getDestinationNames() {
    return _destinationCoordinates.keys.toList();
  }
}

// LatLng class for coordinates (matching latlong2 package)
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}