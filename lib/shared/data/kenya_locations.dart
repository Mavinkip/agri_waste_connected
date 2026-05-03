import '../../features/admin/data/models/location_models.dart';

class KenyaLocations {
  static List<County> getDefaultCounties() {
    return [
      County(
        id: 'nakuru', name: 'Nakuru', lastUpdated: DateTime.now(),
        subCounties: [
          SubCounty(name: 'Naivasha', wards: ['Mai Mahiu', 'Maiella', 'Naivasha East', 'Longonot']),
          SubCounty(name: 'Gilgil', wards: ['Gilgil Town', 'Elementaita', 'Mbaruk', 'Kiambogo']),
          SubCounty(name: 'Nakuru Town East', wards: ['Flamingo', 'Lake View', 'Menengai', 'Section 58']),
          SubCounty(name: 'Nakuru Town West', wards: ['Kaptembwo', 'Shabaab', 'London', 'Rhonda']),
          SubCounty(name: 'Njoro', wards: ['Njoro Town', 'Mau Narok', 'Mauche', 'Likia']),
          SubCounty(name: 'Molo', wards: ['Molo Town', 'Elburgon', 'Turi', 'Sachangwan']),
          SubCounty(name: 'Rongai', wards: ['Rongai Town', 'Menengai West', 'Solai', 'Waseges']),
          SubCounty(name: 'Subukia', wards: ['Subukia Town', 'Kabazi', 'Munanda', 'Mbaruk East']),
          SubCounty(name: 'Bahati', wards: ['Bahati Town', 'Dundori', 'Lanet', 'Mwireri']),
        ],
      ),
      County(
        id: 'kiambu', name: 'Kiambu', lastUpdated: DateTime.now(),
        subCounties: [
          SubCounty(name: 'Thika', wards: ['Thika Town', 'Makongeni', 'Kisii', 'Madaraka']),
          SubCounty(name: 'Ruiru', wards: ['Ruiru Town', 'Kihunguro', 'Mwiki', 'Githurai']),
          SubCounty(name: 'Limuru', wards: ['Limuru Town', 'Tigoni', 'Ndeiya', 'Kamirithu']),
          SubCounty(name: 'Kikuyu', wards: ['Kikuyu Town', 'Kinoo', 'Muguga', 'Kabete']),
        ],
      ),
      County(
        id: 'nairobi', name: 'Nairobi', lastUpdated: DateTime.now(),
        subCounties: [
          SubCounty(name: 'Westlands', wards: ['Kitisuru', 'Parklands', 'Highridge', 'Kangemi']),
          SubCounty(name: 'Langata', wards: ['Karen', 'Nairobi West', 'South C', 'Mugumoini']),
          SubCounty(name: 'Kasarani', wards: ['Clay City', 'Mwiki', 'Zimmerman', 'Roysambu']),
        ],
      ),
    ];
  }

  static List<String> getCountyNames() => getDefaultCounties().map((c) => c.name).toList();

  static List<String> getSubCountyNames(String countyName) {
    final county = getDefaultCounties().where((c) => c.name == countyName).firstOrNull;
    return county?.subCounties.map((s) => s.name).toList() ?? [];
  }

  static List<String> getWardNames(String countyName, String subCountyName) {
    final county = getDefaultCounties().where((c) => c.name == countyName).firstOrNull;
    final subCounty = county?.subCounties.where((s) => s.name == subCountyName).firstOrNull;
    return subCounty?.wards ?? [];
  }
}
