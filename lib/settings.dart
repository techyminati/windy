import 'package:flutter/material.dart';
import 'package:windy/main.dart';

class SettingsPage extends StatefulWidget {
  final MyHomePageState homePageState;
  final VoidCallback onSettingsChanged;

  SettingsPage({required this.homePageState, required this.onSettingsChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
                    ListTile(
            title: Text('Enable Hourly Weather Alerts'),
            trailing: Switch(
              value: widget.homePageState.isHourlyNotificationEnabled,
              onChanged: (value) {
                setState(() {
                  widget.homePageState.isHourlyNotificationEnabled = value;
                  widget.onSettingsChanged();
                  widget.homePageState.savePreferences();
                });
              },
              activeColor: Colors.white, // Change the active color
              activeTrackColor: Colors.white.withOpacity(0.7), // Change the active track color
              inactiveThumbColor: Colors.grey, // Change the inactive thumb color
              inactiveTrackColor: Colors.grey.withOpacity(0.7), // Change the inactive track color
            ),
          ),
          ListTile(
            title: Text('Temperature'),
            subtitle: DropdownButton<String>(
              value: widget.homePageState.isCelsius ? 'Celsius' : 'Fahrenheit',
              items: <String>['Celsius', 'Fahrenheit']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  widget.homePageState.isCelsius = newValue == 'Celsius';
                  widget.onSettingsChanged();
                  widget.homePageState.savePreferences();
                });
              },
            ),
          ),
          ListTile(
            title: Text('Wind Speed'),
            subtitle: DropdownButton<String>(
              value: widget.homePageState.isKilometersPerHour
                  ? 'Kilometers per hour'
                  : 'Miles per hour',
              items: <String>['Kilometers per hour', 'Miles per hour']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  widget.homePageState.isKilometersPerHour =
                      newValue == 'Kilometers per hour';
                  widget.onSettingsChanged();
                  widget.homePageState.savePreferences();
                });
              },
            ),
          ),
          ListTile(
            title: Text('Pressure'),
            subtitle: DropdownButton<String>(
              value: widget.homePageState.isMillibars
                  ? 'Millibars'
                  : 'Inches of mercury',
              items: <String>['Millibars', 'Inches of mercury']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  widget.homePageState.isMillibars = newValue == 'Millibars';
                  widget.onSettingsChanged();
                  widget.homePageState.savePreferences();
                });
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(16),
            child: Text(
              'Powered by OpenWeatherMap API',
              style: Theme.of(context).textTheme.caption,
            ),
          )
        ],
      ),
    );
  }
}
