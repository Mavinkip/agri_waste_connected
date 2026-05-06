import '../../features/admin/data/models/location_models.dart';

class KenyaLocations {
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
}
