import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:smart_home/api/device.dart';
import 'package:smart_home/utils/colors.dart';
import 'package:smart_home/utils/sizes.dart';
import 'package:smart_home/widgets/app_card.dart';
import 'package:smart_home/widgets/icon_card.dart';

class Heading extends StatelessWidget {
  const Heading({
    Key? key,
    required this.deviceName,
    required this.icon,
    required this.setDevicesFunc,
    this.refreshDevices,
  }) : super(key: key);

  final String deviceName;
  final IconData icon;
  final Function setDevicesFunc;
  final bool? refreshDevices;

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconCard(
            iconCardColour: secondaryBg,
            child: IconButton(
              splashRadius: sqrt(screen_.height + screen_.width) / 4.23,
              onPressed: () {
                Navigator.pop(context);
                if (refreshDevices == null) setDevicesFunc();
              },
              icon: Icon(
                Icons.arrow_back_rounded,
                color: secondaryFg,
                size: sqrt(screen_.height + screen_.width) / 1.23, // 28
              ),
            ),
          ),
          Column(
            children: [
              Padding(padding: EdgeInsets.only(top: screen_.height / 35.11)),
              Text(
                deviceName,
                style: TextStyle(
                  color: secondaryFg,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  fontSize: screen_.width / 17.851,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screen_.height / 114.701),
              ),
              Text(
                "Bedroom",
                style: TextStyle(
                  color: subtext,
                  fontSize: screen_.width / 26.1818,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          IconCard(
            iconCardColour: fg,
            child: Icon(
              icon,
              color: secondaryFg,
              size: sqrt(screen_.height + screen_.width) / 1.23, // 28
            ),
          ),
        ],
      ),
    );
  }
}

class SliderAndSwitch extends StatefulWidget {
  const SliderAndSwitch({
    Key? key,
    required this.deviceName,
    required this.deviceDifferentName,
  }) : super(key: key);

  final String deviceName;
  final String deviceDifferentName;

  @override
  State<SliderAndSwitch> createState() => _SliderAndSwitchState();
}

class _SliderAndSwitchState extends State<SliderAndSwitch> {
  double energy = 0.0;
  String device = '';
  Duration duration = const Duration(seconds: 0);
  bool deviceSwitch = false;
  String connected = "Loading...";
  Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) {});

  Future<Map<String, dynamic>> getInfo() async {
    device = aliases[widget.deviceName.toLowerCase()] ?? "null";
    final deviceObject = Device(device: device);
    final information = await Future.wait([
      deviceObject.energy(),
      deviceObject.info(),
    ]);

    return {
      "energy": information[0],
      "info": information[1],
    };
  }

  @override
  void initState() {
    super.initState();

    getInfo().then(
      (Map info) {
        setState(
          () {
            energy = info["energy"];
            deviceSwitch = info["info"].value == "on" ? true : false;
            connected = deviceSwitch ? "Connected" : "Disconnected";

            if (deviceSwitch) {
              final DateTime dateTimeNow = DateTime.now();
              int adjustment = 0;
              if (dateTimeNow.timeZoneName == 'BST') adjustment = 3600;

              int secondsElapsed =
                  dateTimeNow.difference(info["info"].timestamp).inSeconds -
                      adjustment;
              // refer to device.dart/Device.energy comments

              if (secondsElapsed < 0 || energy < 0) {
                secondsElapsed = 0;
                energy = 0;
              }

              duration = Duration(seconds: secondsElapsed);
              startTimer();
            }
          },
        );
      },
    );
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), updateTime);
  }

  void updateTime(Timer timer) {
    setState(() {
      duration = duration + const Duration(seconds: 1);

      if (widget.deviceName != "Power Strip") {
        final energyPerHour =
            energyMap[aliases[widget.deviceName.toLowerCase()]];
        final energyPerSecond = energyPerHour! / 3600;

        energy = energy + energyPerSecond;
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String formatDuration() {
    int hours = duration.inHours;
    String hoursString = "${hours.toString().padLeft(2, '0')}h ";
    if (hours == 0) hoursString = "";

    int minutes = duration.inMinutes.remainder(60);
    String minutesString = "${minutes.toString().padLeft(2, '0')}m ";
    if (minutes == 0 && hours == 0) minutesString = "";

    int seconds = duration.inSeconds.remainder(60);
    String secondsString = "${seconds.toString().padLeft(2, '0')}s";

    return "$hoursString$minutesString$secondsString elapsed";
  }

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: secondaryBg,
              width: 15,
            ),
          ),
          child: SleekCircularSlider(
            min: 0,
            max: widget.deviceName == 'Power Strip' ? 400 : 200,
            initialValue: energy + 0.1,
            appearance: CircularSliderAppearance(
              animationEnabled: false,
              infoProperties: InfoProperties(
                modifier: (value) {
                  if (value == 0.0) return "0";
                  return value.toStringAsFixed(1);
                },
                bottomLabelText: 'Watts',
                mainLabelStyle: const TextStyle(
                  color: secondaryFg,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
                bottomLabelStyle: const TextStyle(
                  color: secondaryFg,
                  fontSize: 18,
                ),
              ),
              customWidths: CustomSliderWidths(
                progressBarWidth: 33,
                trackWidth: 33,
                handlerSize: 18,
              ),
              size: screen_.width / 1.785,
              startAngle: 90,
              angleRange: 360,
              customColors: CustomSliderColors(
                dotColor: secondaryFg,
                progressBarColor: fg,
                trackColor: inactiveTrack,
                hideShadow: true,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: screen_.width / 13.090909,
              right: screen_.width / 13.090909,
              top: screen_.height / 23.76),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.deviceDifferentName,
                    style: TextStyle(
                      color: secondaryFg,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      fontSize: screen_.width / 17.851,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screen_.height / 140.701),
                  ),
                  Text(
                    connected,
                    style: TextStyle(
                      color: subtext,
                      fontSize: screen_.width / 26.1818,
                      letterSpacing: 0.2,
                    ),
                  )
                ],
              ),
              Transform.scale(
                scale: sqrt(screen_.height + screen_.width) / 23.954,
                child: Switch(
                  value: deviceSwitch,
                  onChanged: (value) {
                    setState(
                      () {
                        energy = 0;
                        deviceSwitch = value;
                        connected = value ? "Connected" : "Disconnected";
                        duration = const Duration(seconds: 0);
                        if (!value) {
                          timer.cancel();
                        } else {
                          startTimer();
                        }
                      },
                    );
                    Device(device: device).toggle(value ? "on" : "off");
                  },
                  inactiveTrackColor: inactiveTrack,
                  activeTrackColor: fg,
                  thumbColor: MaterialStateProperty.all<Color>(secondaryFg),
                ),
              ),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(top: screen_.height / 26.76)),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(screen_.width / 13.0924242424),
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: screen_.height / 160.5819,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: duration.inSeconds == 0 ? bg : fg,
                        width: screen_.height / 321.164,
                      ),
                    ),
                  ),
                  child: Text(
                    formatDuration(),
                    style: TextStyle(
                      color: duration.inSeconds == 0 ? subtext : secondaryFg,
                      fontSize: screen_.width / 19.851,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShortCutButton extends StatelessWidget {
  const ShortCutButton({
    Key? key,
    required this.deviceName,
    required this.icon,
    required this.deviceDifferentName,
    required this.setDevicesFunc,
    required this.deviceShortName,
    required this.active,
  }) : super(key: key);

  final String deviceName;
  final IconData icon;
  final String deviceDifferentName;
  final Function setDevicesFunc;
  final String deviceShortName;
  final bool active;

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Column(
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return DeviceControlsPage(
                    deviceName: deviceName,
                    icon: icon,
                    deviceDifferentName: deviceDifferentName,
                    setDevicesFunc: setDevicesFunc,
                    refreshDevices: false,
                  );
                },
              ),
            );
          },
          icon: Icon(
            icon,
            color: active ? secondaryFg : subtext,
            size: sqrt(screen_.height + screen_.width) / 1.23,
          ),
        ),
        Text(
          deviceShortName,
          style: TextStyle(
            color: active ? secondaryFg : subtext,
            fontWeight: FontWeight.w400,
            fontSize: screen_.width / 26.1818,
          ),
        )
      ],
    );
  }
}

class Shortcuts extends StatelessWidget {
  const Shortcuts({
    Key? key,
    required this.setDevicesFunc,
    required this.deviceName,
  }) : super(key: key);

  final Function setDevicesFunc;
  final String deviceName;

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);
    return AppCard(
      child: Padding(
        padding: EdgeInsets.only(
          top: screen_.height / 80.2,
          bottom: screen_.height / 40.1,
          left: screen_.width / 78.54,
          right: screen_.width / 78.54,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ShortCutButton(
              deviceName: "Main Chargers",
              icon: Icons.power_outlined,
              deviceDifferentName: "Huawei Charger",
              setDevicesFunc: setDevicesFunc,
              deviceShortName: "Plug",
              active: deviceName == "Main Chargers",
            ),
            ShortCutButton(
              deviceName: "Monitor",
              icon: CupertinoIcons.tv,
              deviceDifferentName: "Dell Monitor",
              setDevicesFunc: setDevicesFunc,
              deviceShortName: "Monitor",
              active: deviceName == "Monitor",
            ),
            ShortCutButton(
              deviceName: "Light Strip",
              icon: CupertinoIcons.lightbulb,
              deviceDifferentName: "Govee LED Strip",
              setDevicesFunc: setDevicesFunc,
              deviceShortName: "LEDs",
              active: deviceName == "Light Strip",
            ),
            ShortCutButton(
              deviceName: "USB",
              icon: Icons.usb_outlined,
              deviceDifferentName: "Lenovo Charger",
              setDevicesFunc: setDevicesFunc,
              deviceShortName: "USB",
              active: deviceName == "USB",
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceControlsPage extends StatefulWidget {
  const DeviceControlsPage({
    Key? key,
    required this.deviceName,
    required this.icon,
    required this.deviceDifferentName,
    required this.setDevicesFunc,
    this.refreshDevices,
  }) : super(key: key);

  @override
  State<DeviceControlsPage> createState() => _DeviceControlsPageState();

  final String deviceName;
  final IconData icon;
  final String deviceDifferentName;
  final Function setDevicesFunc;
  final bool? refreshDevices;
}

class _DeviceControlsPageState extends State<DeviceControlsPage> {
  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Heading(
              deviceName: widget.deviceName,
              icon: widget.icon,
              setDevicesFunc: widget.setDevicesFunc,
              refreshDevices: widget.refreshDevices,
            ),
            Padding(padding: EdgeInsets.only(top: screen_.height / 26.76)),
            SliderAndSwitch(
              deviceName: widget.deviceName,
              deviceDifferentName: widget.deviceDifferentName,
            ),
            Padding(padding: EdgeInsets.only(top: screen_.height / 26.76)),
            Shortcuts(
              setDevicesFunc: widget.setDevicesFunc,
              deviceName: widget.deviceName,
            ),
          ],
        ),
      ),
    );
  }
}
