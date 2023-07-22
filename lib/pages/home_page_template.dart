import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:smart_home/api/weather.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/pages/lights_control_page.dart';
import 'package:smart_home/pages/device_controls_page.dart';

import '../widgets/app_card.dart';
import '../api/device.dart';
import '../widgets/device_card.dart';
import '../utils/colors.dart';
import '../utils/sizes.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: screen_.height / 32.11)),
            Text(
              'Welcome, Name!',
              style: TextStyle(
                color: secondaryFg,
                fontSize: screen_.width / 17.851,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screen_.height / 114.701),
            ),
            Text(
              "Let's manage your smart home",
              style: TextStyle(
                color: subtext,
                fontSize: screen_.width / 26.1818,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        Column(
          children: [
            Padding(padding: EdgeInsets.only(top: screen_.height / 40.145)),
            CircleAvatar(
              backgroundColor: fg,
              maxRadius: screen_.width / 16.3636,
              child: Icon(
                Icons.person,
                color: secondaryFg,
                size: screen_.width / 10.069,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  Widget icon = Padding(
    padding: const EdgeInsets.only(top: 42),
    child: CircularProgressIndicator(
      color: fg,
      strokeWidth: 2.5,
    ),
  );

  late Future<Weather> weather;

  String weatherDesc = 'Clear';

  num temp = 20;

  @override
  void initState() {
    super.initState();

    fetchWeather().then(
      (data) => setState(() {
        icon = Image.network(
          'https://openweathermap.org/img/wn/${data.icon}@2x.png',
          height: MediaQuery.of(context).size.height / 7,
        );
        weatherDesc = data.weather;
        temp = data.temp.toInt();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 7 + 2,
            width: MediaQuery.of(context).size.width / 4 + 22,
            child: Center(
              child: Column(
                children: [icon],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weatherDesc,
                style: TextStyle(
                  color: secondaryFg,
                  fontWeight: FontWeight.bold,
                  fontSize: screen_.width / 15.709,
                  letterSpacing: 0.2,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(bottom: screen_.height / 66.909)),
              Text(
                DateFormat('dd MMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: secondaryFg,
                  fontSize: screen_.width / 30.209,
                  letterSpacing: 0.2,
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: screen_.height / 229.4)),
              Text(
                'City, Country',
                style: TextStyle(
                  color: secondaryFg,
                  fontSize: screen_.width / 30.209,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(right: screen_.width / 13.09)),
          Column(
            children: [
              Text(
                '${temp.toString()}°C',
                style: TextStyle(
                  color: secondaryFg,
                  fontWeight: FontWeight.bold,
                  fontSize: screen_.width / 15.71,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(bottom: screen_.height / 34.909)),
            ],
          ),
          Padding(padding: EdgeInsets.only(right: screen_.width / 30.21)),
        ],
      ),
    );
  }
}

class BedroomText extends StatelessWidget {
  const BedroomText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Row(
      children: [
        Padding(padding: EdgeInsets.only(left: screen_.width / 13.09)),
        Container(
          padding: EdgeInsets.only(
            bottom: screen_.height / 160.5819,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: fg,
                width: screen_.height / 321.164,
              ),
            ),
          ),
          child: Text(
            "Bedroom",
            style: TextStyle(
              color: secondaryFg,
              fontSize: screen_.width / 17.85123,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class DevicesWidget extends StatefulWidget {
  const DevicesWidget({Key? key}) : super(key: key);

  @override
  State<DevicesWidget> createState() => _DevicesWidgetState();
}

class _DevicesWidgetState extends State<DevicesWidget> {
  bool plug = false;
  bool monitor = false;
  bool strip = false;
  bool usb = false;
  bool power = false;
  bool lights = false;

  final QuickActions quickActions = const QuickActions();

  void setDevices() {
    getAllDevicesInfo().then(
      (devices) {
        setState(
          () {
            plug = devices['plug'].value == 'on' ? true : false;
            monitor = devices['monitor'].value == 'on' ? true : false;
            strip = devices['strip'].value == 'on' ? true : false;
            usb = devices['usb'].value == 'on' ? true : false;
            lights = devices['lights'].value == 'on' ? true : false;
            power = false;

            for (var status in devices.values) {
              if (status.value == 'on' && status != devices['lights']) {
                power = true;
                return;
              }
            }
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    quickActions.setShortcutItems([
      const ShortcutItem(
        type: 'lights',
        localizedTitle: "Lights",
        icon: "outline_lightbulb_white_48",
      ),
    ]);

    quickActions.initialize((type) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LightsControlPage(setDevicesFunc: setDevices)));
    });

    setDevices();
  }

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return RefreshIndicator(
      onRefresh: () async {
        setDevices();
      },
      backgroundColor: Colors.transparent,
      color: fg,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: screen_.height / 61.76223)),
            Row(
              children: [
                DeviceCard(
                  deviceName: 'Main Chargers',
                  marginLeft: screen_.width / 19.636,
                  marginRight: screen_.width / 39.272727,
                  icon: Icons.power_outlined,
                  switchValue: plug,
                  switchChange: (value) => setState(() {
                    plug = value;
                    if (value == true) power = true;
                    const Device(device: 'plug').toggle(value ? "on" : "off");
                  }),
                  controlsPage: DeviceControlsPage(
                    deviceName: 'Main Chargers',
                    icon: Icons.power_outlined,
                    deviceDifferentName: "Huawei Charger",
                    setDevicesFunc: setDevices,
                  ),
                ),
                DeviceCard(
                  deviceName: 'Monitor',
                  marginLeft: screen_.width / 39.272727,
                  marginRight: screen_.width / 19.636,
                  icon: CupertinoIcons.tv,
                  switchValue: monitor,
                  switchChange: (value) => setState(() {
                    monitor = value;
                    if (value == true) power = true;
                    const Device(device: 'monitor')
                        .toggle(value ? "on" : "off");
                  }),
                  controlsPage: DeviceControlsPage(
                    deviceName: 'Monitor',
                    icon: CupertinoIcons.tv,
                    deviceDifferentName: "Dell Monitor",
                    setDevicesFunc: setDevices,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: screen_.height / 43.4)),
            Row(
              children: [
                DeviceCard(
                  deviceName: 'Light Strip',
                  marginLeft: screen_.width / 19.636,
                  marginRight: screen_.width / 39.272727,
                  icon: CupertinoIcons.lightbulb,
                  switchValue: strip,
                  switchChange: (value) => setState(() {
                    strip = value;
                    if (value == true) power = true;
                    const Device(device: 'strip').toggle(value ? "on" : "off");
                  }),
                  controlsPage: DeviceControlsPage(
                    deviceName: 'Light Strip',
                    icon: CupertinoIcons.lightbulb,
                    deviceDifferentName: "Govee LED Strip",
                    setDevicesFunc: setDevices,
                  ),
                ),
                DeviceCard(
                  deviceName: 'USB',
                  marginLeft: screen_.width / 39.272727,
                  marginRight: screen_.width / 19.636,
                  icon: Icons.usb_outlined,
                  switchValue: usb,
                  switchChange: (value) => setState(() {
                    usb = value;
                    if (value == true) power = true;
                    const Device(device: 'usb').toggle(value ? "on" : "off");
                  }),
                  controlsPage: DeviceControlsPage(
                    deviceName: 'USB',
                    icon: Icons.usb_outlined,
                    deviceDifferentName: "Lenovo Charger",
                    setDevicesFunc: setDevices,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: screen_.height / 43.4)),
            Row(
              children: [
                DeviceCard(
                  deviceName: 'Power Strip',
                  marginLeft: screen_.width / 19.636,
                  marginRight: screen_.width / 39.272727,
                  icon: CupertinoIcons.power,
                  switchValue: power,
                  switchChange: (value) => setState(() {
                    power = value;
                    plug = value;
                    monitor = value;
                    strip = value;
                    usb = value;
                    const Device(device: 'power').toggle(value ? "on" : "off");
                  }),
                  controlsPage: DeviceControlsPage(
                    deviceName: 'Power Strip',
                    icon: CupertinoIcons.power,
                    deviceDifferentName: "Meross Power Strip",
                    setDevicesFunc: setDevices,
                  ),
                ),
                DeviceCard(
                  deviceName: 'Light Bulb',
                  marginLeft: screen_.width / 39.272727,
                  marginRight: screen_.width / 19.636,
                  icon: Icons.light,
                  switchValue: lights,
                  switchChange: (value) => setState(() {
                    lights = value;
                    const Device(device: 'lights').toggle(value ? "on" : "off");
                  }),
                  controlsPage: LightsControlPage(
                    setDevicesFunc: setDevices,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: screen_.height / 26.7636)),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Column(
      children: [
        const SizedBox(
          width: double.infinity,
          child: Welcome(),
        ),
        Padding(padding: EdgeInsets.only(top: screen_.height / 26.76)),
        const SizedBox(
          width: double.infinity,
          child: WeatherWidget(),
        ),
        Padding(padding: EdgeInsets.only(top: screen_.height / 26.76)),
        const BedroomText(),
        Padding(padding: EdgeInsets.only(top: screen_.height / 47.2299)),
        const Expanded(
          child: DevicesWidget(),
        ),
      ], // root children of Column
    ); // root;
  }
}
