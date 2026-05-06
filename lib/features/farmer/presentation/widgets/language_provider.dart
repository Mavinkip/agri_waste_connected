import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends ChangeNotifier {
  static final LanguageNotifier _instance = LanguageNotifier._();
  factory LanguageNotifier() => _instance;
  LanguageNotifier._() { _loadSavedLanguage(); }

  String _lang = 'en';
  String get lang => _lang;
  bool get isSwahili => _lang == 'sw';

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'en';
    notifyListeners();
  }

  Future<void> toggle() async {
    _lang = _lang == 'en' ? 'sw' : 'en';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _lang);
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _lang = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _lang);
    notifyListeners();
  }

  String t(String key) {
    if (_lang == 'sw') return _swahili[key] ?? key;
    return key;
  }

  static String translate(String key, {String? lang}) {
    if (lang == 'sw') return _swahili[key] ?? key;
    return key;
  }

  // ─── COMPLETE SWAHILI DICTIONARY ───
  static const Map<String, String> _swahili = {
    // Dashboard
    'Dashboard': 'Dashibodi',
    'Welcome': 'Karibu',
    'Loading...': 'Inapakia...',
    'Monthly Earnings': 'Mapato ya Mwezi',
    'transactions this month': 'muamala mwezi huu',
    'Open Orders': 'Maagizo Yaliyofunguliwa',
    'Sold': 'Imeuzwa',
    'Collections': 'Makusanyo',
    'My Rating': 'Ukadiriaji Wangu',
    'Quick Actions': 'Vitendo vya Haraka',
    'Sell': 'Uza',
    'Earnings': 'Mapato',
    'Schedule': 'Ratiba',
    'Recent Activity': 'Shughuli za Hivi Karibuni',
    'No earnings yet': 'Hakuna mapato bado',
    'Start selling to see your earnings': 'Anza kuuza ili kuona mapato',
    'No activity yet': 'Hakuna shughuli bado',
    'Pull down to refresh': 'Vuta chini kusasisha',

    // Sell Waste
    'Sell Waste': 'Uza Taka',
    'What type of waste do you have?': 'Una taka ya aina gani?',
    'Select one to continue': 'Chagua moja kuendelea',
    'Select': 'Chagua',
    'Crop Residue': 'Mabaki ya Mazao',
    'Maize stalks, wheat straw, rice straw': 'Mabua ya mahindi, ngano, mpunga',
    'Vegetable Waste': 'Taka za Mboga',
    'Kales, cabbage, tomato rejects': 'Sukuma wiki, kabichi, nyanya',
    'Fruit Waste': 'Taka za Matunda',
    'Mango, banana, avocado waste': 'Embe, ndizi, parachichi',
    'Livestock Manure': 'Samadi ya Mifugo',
    'Cow, goat, chicken manure': 'Ng\'ombe, mbuzi, kuku',
    'Coffee Husks': 'Maganda ya Kahawa',
    'Coffee processing waste': 'Taka za kusindika kahawa',
    'Rice Hulls': 'Maganda ya Mpunga',
    'Rice milling byproduct': 'Taka za kusaga mpunga',
    'Corn Stover': 'Mabaki ya Mahindi',
    'Maize stalks after harvest': 'Mabua ya mahindi baada ya mavuno',
    'Other Waste': 'Taka Nyingine',
    'Any other agricultural waste': 'Taka nyingine yoyote ya kilimo',

    // Quantity
    'Quantity': 'Kiasi',
    'How much waste do you have?': 'Una kiasi gani cha taka?',
    'Estimate the quantity in kilograms': 'Kadiria kiasi kwa kilogramu',
    'Small': 'Kidogo',
    'Medium': 'Kati',
    'Large': 'Kubwa',
    'Truckload': 'Lori',
    'About 1-5 bags': 'Karibu magunia 1-5',
    'About 6-20 bags': 'Karibu magunia 6-20',
    'About 21-50 bags': 'Karibu magunia 21-50',
    '51+ bags': 'Magunia 51+',
    'Or enter exact quantity:': 'Au weka kiasi halisi:',

    // Photo
    'Add Photo': 'Ongeza Picha',
    'Take a photo of your waste': 'Piga picha ya taka yako',
    'Optional but helps the driver': 'Si lazima lakini inamsaidia dereva',
    'Tap to add photo': 'Gusa kuongeza picha',
    'Camera or Gallery': 'Kamera au Ghala',
    'Camera': 'Kamera',
    'Gallery': 'Ghala',
    'Take Photo': 'Piga Picha',
    'Use your camera': 'Tumia kamera yako',
    'Choose from Gallery': 'Chagua kutoka Ghala',
    'Select existing photo': 'Chagua picha iliyopo',
    'Remove Photo': 'Ondoa Picha',
    'Good lighting, show full pile, no plastic bags': 'Mwanga mzuri, onyesha rundo lote, hakuna mifuko ya plastiki',
    'Back': 'Nyuma',
    'Continue': 'Endelea',
    'Skip': 'Ruka',
    'Skip Photo': 'Ruka Picha',

    // Location
    'Location': 'Mahali',
    'Where is your farm?': 'Shamba lako liko wapi?',
    'GPS auto-detects your location': 'GPS inatambua mahali ulipo',
    'GPS Location': 'Mahali pa GPS',
    'GPS Location Set': 'Mahali pa GPS Imewekwa',
    'GPS not available': 'GPS haipatikani',
    'Detect': 'Tambua',
    'GPS error:': 'Hitilafu ya GPS:',
    'Or select manually:': 'Au chagua mwenyewe:',
    'Or Select Manually': 'Au Chagua Mwenyewe',
    'County': 'Kaunti',
    'Sub-County': 'Kaunti Ndogo',
    'Ward': 'Kata',
    'Village (optional)': 'Kijiji (si lazima)',
    'Set Manual Location': 'Weka Mahali Mwenyewe',
    'Select County and Sub-County first': 'Chagua Kaunti na Kaunti Ndogo kwanza',
    'Pickup Type': 'Aina ya Kuchukua',
    'Routine': 'Kawaida',
    'Regular collection': 'Ukusanyaji wa kawaida',
    'Manual': 'Mwongozo',
    'One-time request': 'Ombi la mara moja',
    'Notes for driver (optional)': 'Maelezo kwa dereva (si lazima)',
    'Submit Order': 'Wasilisha Agizo',
    'Set location first': 'Weka mahali kwanza',
    'Select pickup type above': 'Chagua aina ya kuchukua hapo juu',
    'Set location & pickup type': 'Weka mahali na aina ya kuchukua',
    'GPS is off. Enable location or use manual selection.': 'GPS imezimwa. Washa mahali au tumia uteuzi wa mwenyewe.',
    'Location permission denied. Use manual selection.': 'Ruhusa ya mahali imekataliwa. Tumia uteuzi wa mwenyewe.',
    'GPS location set! Select pickup type below.': 'Mahali pa GPS yamewekwa! Chagua aina ya kuchukua hapo chini.',
    'Location set! Select pickup type below.': 'Mahali yamewekwa! Chagua aina ya kuchukua hapo chini.',

    // Success
    'Success': 'Imefanikiwa',
    'Order Placed!': 'Agizo Limesafirishwa!',
    'A driver will come to collect your waste': 'Dereva atakuja kuchukua taka yako',
    'Ticket #': 'Tiketi #',
    'Status': 'Hali',
    'Pending': 'Inasubiri',
    'Pickup': 'Kuchukua',
    'Within 48 hours': 'Ndani ya masaa 48',
    'You will receive an SMS when the driver is on the way': 'Utapokea SMS wakati dereva yuko njiani',
    'Back to Dashboard': 'Rudi kwenye Dashibodi',

    // Schedule
    'Collection Schedule': 'Ratiba ya Kukusanya',
    'How It Works': 'Jinsi Inavyofanya Kazi',
    'Set your collection days below. A driver will come automatically on those days. No need to create manual listings!': 'Weka siku zako za kukusanya hapo chini. Dereva atakuja moja kwa moja siku hizo. Hakuna haja ya kuunda maagizo ya mwongozo!',
    'Your Collection Days': 'Siku Zako za Kukusanya',
    'No schedule set': 'Hakuna ratiba iliyowekwa',
    'Tap button below to add collection days': 'Gusa kitufe hapo chini kuongeza siku za kukusanya',
    'Update Schedule': 'Sasisha Ratiba',
    'Enable Collection': 'Wezesha Ukusanyaji',
    'Day': 'Siku',
    'Time': 'Wakati',
    'Save': 'Hifadhi',
    'Schedule updated!': 'Ratiba imesasishwa!',
    'Flexible': 'Muda Wowote',

    // Profile
    'Profile': 'Wasifu',
    'My Profile': 'Wasifu Wangu',
    'Tap to change photo': 'Gusa kubadilisha picha',
    'Full Name': 'Jina Kamili',
    'Phone Number': 'Nambari ya Simu',
    'Edit Profile': 'Hariri Wasifu',
    'Profile saved!': 'Wasifu umehifadhiwa!',
    'Role': 'Jukumu',
    'Farmer': 'Mkulima',
    'Member Since': 'Mwanachama Tangu',
    'Total Collections': 'Jumla ya Makusanyo',
    'Rating': 'Ukadiriaji',
    'Logout': 'Ondoka',

    // Notifications
    'Notifications': 'Arifa',
    'No notifications yet': 'Hakuna arifa bado',
    'Updates about your listings will appear here': 'Taarifa kuhusu maagizo yako zitaonekana hapa',

    // Help
    'Help': 'Msaada',
    'Help & Support': 'Msaada na Usaidizi',
    'Contact Us': 'Wasiliana Nasi',
    'Call Support': 'Piga Simu Kwa Usaidizi',
    'WhatsApp': 'WhatsApp',
    'Chat with us on WhatsApp': 'Ongea nasi kwenye WhatsApp',
    'Set Location': 'Weka Mahali',
    'Get Paid': 'Pata Malipo',
    'Choose the type of agricultural waste you have': 'Chagua aina ya taka ya kilimo uliyonayo',
    'Tell us where to pick up your waste': 'Tuambie wapi pa kuchukua taka yako',
    'Receive payment via M-Pesa after collection': 'Pokea malipo kupitia M-Pesa baada ya kukusanya',
    'How Payments Work': 'Jinsi Malipo Yanavyofanya Kazi',
    'M-Pesa Payments': 'Malipo ya M-Pesa',
    'Payment sent after driver verifies your waste': 'Malipo hutumwa baada ya dereva kuthibitisha taka yako',
    'Arrives within 24 hours after collection': 'Hufika ndani ya masaa 24 baada ya kukusanya',
    'Check your M-Pesa messages for confirmation': 'Angalia ujumbe wako wa M-Pesa kwa uthibitisho',
    'Frequently Asked Questions': 'Maswali Yanayoulizwa Mara kwa Mara',

    // Auth
    'Login': 'Ingia',
    'Register': 'Jiandikishe',
    'Forgot Password?': 'Umesahau Nenosiri?',
    'Welcome Back!': 'Karibu Tena!',
    'Login to your account': 'Ingia kwenye akaunti yako',
    'Password': 'Nenosiri',
    'Enter valid phone number': 'Weka nambari sahihi ya simu',
    'Login with OTP instead': 'Ingia kwa OTP badala yake',
    'Login with password': 'Ingia kwa nenosiri',
    'Create Account': 'Fungua Akaunti',
    'Join as a farmer': 'Jiunge kama mkulima',
    'Already have an account? Login': 'Tayari una akaunti? Ingia',

    // Offline
    'Online': 'Mtandaoni',
    'You are offline': 'Hauko mtandaoni',
    'Changes will sync when connected': 'Mabadiliko yatasawazishwa ukishaunganishwa',
    'No internet connection': 'Hakuna muunganisho wa intaneti',
    'Retry': 'Jaribu Tena',
    'Network error': 'Hitilafu ya mtandao',
  };
}
