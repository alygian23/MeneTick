import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'dart:math' as math;

void main() {
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _timeString;
  late String _dateString;
  late DateTime _currentTime;
  int _currentIndex = 0;
  late PageController _pageController;

  // Variabile per gestire la lingua selezionata
  String _selectedLanguage = 'Italiano';

  // Variabile e controller per gestire il nome utente
  String _username = '';
  TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentTime = DateTime.now();
    _timeString = _formatDecimalTime(_currentTime);
    _dateString = _formatDate(_currentTime);
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    final DateTime now = tz.TZDateTime.now(tz.getLocation('Europe/Rome'));
    final String formattedTime = _formatDecimalTime(now);
    final String formattedDate = _formatDate(now);
    setState(() {
      _currentTime = now;
      _timeString = formattedTime;
      _dateString = formattedDate;
    });
  }

  String _formatDecimalTime(DateTime dateTime) {
    final int totalSeconds = dateTime.hour * 3600 + dateTime.minute * 60 + dateTime.second;
    final double decimalHours = totalSeconds / 86400 * 10;
    final int decimalHour = decimalHours.floor();
    final int decimalMinutes = ((decimalHours - decimalHour) * 100).floor();
    final int decimalSeconds = ((((decimalHours - decimalHour) * 100) - decimalMinutes) * 100).floor();

    return '${decimalHour.toString().padLeft(2, '0')}:${decimalMinutes.toString().padLeft(2, '0')}:${decimalSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final List<String> revolutionaryMonths = [
      'Vendemmiari', 'Brumari', 'Frimari', 'Nevos', 'Piovos', 'Ventos',
      'Germinal', 'Fioril', 'Pratil', 'Messidòr', 'Thermidòr', 'Fruttidòr'
    ];

    final DateTime startOfRevolutionaryYear = DateTime(dateTime.year, 9, 22);
    int year = dateTime.year - 1792;
    int daysDifference = dateTime.difference(startOfRevolutionaryYear).inDays;

    if (daysDifference < 0) {
      year--;
      daysDifference = dateTime.difference(DateTime(dateTime.year - 1, 9, 22)).inDays;
    }

    final int month = daysDifference ~/ 30;
    final int day = (daysDifference % 30) + 1;

    if (isRevolutionaryLeapYear(year + 1792) && month == 11 && day == 6) {
      return 'Jour de la Révolution $year';
    } else {
      return '$day ${revolutionaryMonths[month]} $year';
    }
  }

  bool isRevolutionaryLeapYear(int year) {
    if (year <= 20) {
      return year == 3 || year == 7 || year == 11 || year == 15 || year == 20;
    } else {
      if (year % 4 == 0) {
        if (year % 100 == 0) {
          return year % 400 == 0;
        }
        return true;
      }
      return false;
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _onLanguageChanged(String? newLanguage) {
    if (newLanguage != null) {
      setState(() {
        _selectedLanguage = newLanguage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2E1C18),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            // Prima scheda
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Text(
                              AppLocalizations.getLocalizedValue('title', _selectedLanguage),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'TrendSansOne',
                              ),
                            ),
                            Text(
                              AppLocalizations.getLocalizedValue('subtitle', _selectedLanguage),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'TrendSansOne',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: AnalogClock(currentTime: _currentTime),
                  ),
                  Column(
                    children: [
                      Text(
                        _timeString,
                        style: TextStyle(
                          color: Color(0xFFEAD38A),
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _dateString,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Seconda scheda
            Center(
              child: Text(
                _username.isNotEmpty
                    ? 'Ciao, $_username!'
                    : AppLocalizations.getLocalizedValue('secondPage', _selectedLanguage),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Terza scheda
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.getLocalizedValue('selectLanguage', _selectedLanguage),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    dropdownColor: Color(0xFF2E1C18),
                    icon: Icon(Icons.arrow_downward, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: _onLanguageChanged,
                    items: <String>['Milanese', 'Italiano', 'Inglese']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Inserisci il tuo nome utente:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Nome utente',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _username = _usernameController.text;
                      });
                    },
                    child: Text('Salva'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFEAD38A),
                      onPrimary: Color(0xFF2E1C18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2E1C18),
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.withOpacity(0.5),
        onTap: _onItemTapped,
        items: [
          _buildBottomNavigationBarItem(Icons.alarm, 0),
          _buildBottomNavigationBarItem(Icons.menu, 1),
          _buildBottomNavigationBarItem(Icons.settings, 2),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          Icon(icon),
          if (_currentIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 3,
              width: 22,
              color: Color(0xFFFADDA6),
            ),
        ],
      ),
      label: '',
    );
  }
}

class AnalogClock extends StatelessWidget {
  final DateTime currentTime;

  AnalogClock({required this.currentTime});

  @override
  Widget build(BuildContext context) {
    final int totalSeconds = currentTime.hour * 3600 + currentTime.minute * 60 + currentTime.second;
    final double decimalHours = totalSeconds / 86400 * 10;
    final double decimalMinutes = (decimalHours - decimalHours.floor()) * 100;

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/clock_face.png',
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          ),
          Transform.rotate(
            angle: 2 * math.pi / 10 * decimalHours,
            alignment: Alignment.center,
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/hour_hand.png',
                width: 15,
                height: 167,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Transform.rotate(
            angle: 2 * math.pi / 100 * decimalMinutes,
            alignment: Alignment.center,
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/minute_hand.png',
                width: 16,
                height: 167,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppLocalizations {
  static Map<String, Map<String, String>> _localizedValues = {
    'Milanese': {
      'title': 'EL MENEGHIN',
      'subtitle': 'BALLABIÒTT',
      'selectLanguage': 'Seleziona la lingua:',
      'secondPage': 'Seconda scheda',
      'thirdPage': 'Terza scheda',
    },
    'Italiano': {
      'title': 'IL MENEGHINO',
      'subtitle': 'BALLERINO',
      'selectLanguage': 'Seleziona la lingua:',
      'secondPage': 'Seconda scheda',
      'thirdPage': 'Terza scheda',
    },
    'Inglese': {
      'title': 'THE MENEGHIN',
      'subtitle': 'DANCER',
      'selectLanguage': 'Select Language:',
      'secondPage': 'Second Page',
      'thirdPage': 'Third Page',
    },
  };

  static String getLocalizedValue(String key, String language) {
    return _localizedValues[language]?[key] ?? '';
  }
}
