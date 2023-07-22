import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../api/device.dart';
import '../utils/colors.dart';
import '../utils/sizes.dart';
import '../widgets/app_card.dart';
import '../widgets/icon_card.dart';

class Heading extends StatelessWidget {
  const Heading({
    Key? key,
    required this.setDevicesFunc,
  }) : super(key: key);

  final Function setDevicesFunc;

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
                setDevicesFunc();
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
                "Light Bulb",
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
              Icons.light,
              color: secondaryFg,
              size: sqrt(screen_.height + screen_.width) / 1.23, // 28
            ),
          ),
        ],
      ),
    );
  }
}

class SlidersAndSwitch extends StatefulWidget {
  const SlidersAndSwitch({
    Key? key,
  }) : super(key: key);

  @override
  State<SlidersAndSwitch> createState() => _SlidersAndSwitchState();
}

class _SlidersAndSwitchState extends State<SlidersAndSwitch> {
  double energy = 0.0;
  String device = 'lights';
  Duration duration = const Duration(seconds: 0);
  bool deviceSwitch = false;
  String connected = "Loading...";
  Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) {});
  int brightness = 0;
  int temp = 2200;
  double hue = 0.0;
  PageController pageController = PageController();
  int index = 0;

  Future<Map<String, dynamic>> getInfo() async {
    final Device deviceObject = Device(device: device);
    final List<dynamic> information = await Future.wait([
      deviceObject.energy(),
      deviceObject.getLightsInfo(),
    ]);

    return {
      "energy": information[0],
      "info": information[1]["info"],
      "brightness": information[1]["brightness"],
      "temp": information[1]["temp"],
      "hue": information[1]["hue"],
    };
  }

  @override
  void initState() {
    super.initState();

    getInfo().then((info) {
      setState(() {
        energy = info["energy"];
        deviceSwitch = info["info"]["value"] == "on" ? true : false;
        connected = deviceSwitch ? "Connected" : "Disconnected";
        brightness = info["brightness"];
        temp = info["temp"];
        hue = info["hue"].toDouble();

        if (deviceSwitch) {
          final dateTimeNow = DateTime.now();
          var adjustment = 0;
          if (dateTimeNow.timeZoneName == 'BST') adjustment = 3600;

          String timestamp = info['info']['timestamp']
              .replaceAll("T", " ")
              .replaceAll("Z", "");
          timestamp = timestamp.substring(0, timestamp.length - 1);
          final DateTime timestampDate = DateTime.parse(timestamp);

          int secondsElapsed =
              dateTimeNow.difference(timestampDate).inSeconds - adjustment;
          // refer to device.dart/Device.energy comments

          if (secondsElapsed < 0 || energy < 0) {
            secondsElapsed = 0;
            energy = 0;
          }

          duration = Duration(seconds: secondsElapsed);
          startTimer();
        }
      });
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), updateTime);
  }

  void updateTime(Timer timer) {
    setState(() {
      duration = duration + const Duration(seconds: 1);

      final energyPerHour = energyMap["lights"];
      final energyPerSecond = energyPerHour! / 3600;

      energy = energy + energyPerSecond;
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

    return "$hoursString$minutesString$secondsString";
  }

  String formatEnergy() {
    if (energy == 0.0) return "0";
    return energy.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                if (index > 0) {
                  index--;
                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.decelerate,
                  );
                }
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: secondaryFg,
              ),
            ),
            SizedBox(
              height: 250,
              width: 275,
              child: PageView(
                controller: pageController,
                onPageChanged: (value) {
                  setState(() {
                    index = value;
                  });
                },
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
                      max: 101,
                      initialValue: brightness.toDouble(),
                      onChangeEnd: (value) {
                        const Device(device: "lights")
                            .changeBrightness(value.toInt());
                        setState(() {
                          if (!deviceSwitch) {
                            deviceSwitch = true;
                            connected = "Connected";
                            startTimer();
                          }
                          if (value.toInt() == 0) {
                            deviceSwitch = false;
                            connected = "Disconnected";
                            energy = 0;
                            timer.cancel();
                            duration = const Duration(seconds: 0);
                          }
                          brightness = value.toInt();
                        });
                      },
                      appearance: CircularSliderAppearance(
                        animationEnabled: false,
                        infoProperties: InfoProperties(
                          modifier: (value) {
                            return "${value.toInt().toString()}%";
                          },
                          bottomLabelText: 'Brightness',
                          mainLabelStyle: const TextStyle(
                            color: secondaryFg,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                          bottomLabelStyle: const TextStyle(
                            color: secondaryFg,
                            fontSize: 18,
                            letterSpacing: 0.2,
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
                          dotColor: deviceSwitch ? secondaryFg : subtext,
                          progressBarColor: deviceSwitch ? fg : Colors.white12,
                          trackColor: inactiveTrack,
                          hideShadow: true,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: secondaryBg,
                        width: 15,
                      ),
                    ),
                    child: SleekCircularSlider(
                      min: 2200,
                      max: 9007,
                      initialValue: temp.toInt().toDouble(),
                      onChangeEnd: (value) {
                        const Device(device: "lights")
                            .changeTemp(value.toInt());

                        setState(() {
                          if (!deviceSwitch) {
                            deviceSwitch = true;
                            connected = "Connected";
                            startTimer();
                          }

                          temp = value.toInt();
                        });
                      },
                      appearance: CircularSliderAppearance(
                        animationEnabled: false,
                        infoProperties: InfoProperties(
                          modifier: (value) {
                            return "${value.toInt().toString()}K";
                          },
                          bottomLabelText: 'Temp.',
                          mainLabelStyle: const TextStyle(
                            color: secondaryFg,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                          bottomLabelStyle: const TextStyle(
                            color: secondaryFg,
                            fontSize: 18,
                            letterSpacing: 0.2,
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
                          dotColor: deviceSwitch ? secondaryFg : subtext,
                          progressBarColor: deviceSwitch ? fg : Colors.white12,
                          trackColor: inactiveTrack,
                          hideShadow: true,
                        ),
                      ),
                    ),
                  ),
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
                      max: 101,
                      initialValue: hue,
                      onChangeEnd: (value) {
                        const Device(device: "lights")
                            .changeColor(value.toInt());

                        setState(() {
                          if (!deviceSwitch) {
                            deviceSwitch = true;
                            connected = "Connected";
                            startTimer();
                          }
                        });

                        hue = value;
                      },
                      appearance: CircularSliderAppearance(
                        animationEnabled: false,
                        infoProperties: InfoProperties(
                          modifier: (value) {
                            return value.toInt().toString();
                          },
                          bottomLabelText: 'Hue',
                          mainLabelStyle: const TextStyle(
                            color: secondaryFg,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                          bottomLabelStyle: const TextStyle(
                            color: secondaryFg,
                            fontSize: 18,
                            letterSpacing: 0.2,
                          ),
                        ),
                        customWidths: CustomSliderWidths(
                          progressBarWidth: 33,
                          trackWidth: 33,
                          handlerSize: 18,
                        ),
                        size: screen_.width / 1.785,
                        startAngle: 0,
                        angleRange: 360,
                        customColors: CustomSliderColors(
                          dotColor: deviceSwitch ? secondaryFg : subtext,
                          hideShadow: true,
                          trackColors: [
                            const Color.fromARGB(255, 255, 0, 0),
                            const Color.fromARGB(255, 255, 128, 0),
                            const Color.fromARGB(255, 255, 255, 0),
                            const Color.fromARGB(255, 128, 255, 0),
                            const Color.fromARGB(255, 0, 255, 0),
                            const Color.fromARGB(255, 0, 255, 128),
                            const Color.fromARGB(255, 0, 255, 255),
                            const Color.fromARGB(255, 0, 128, 255),
                            const Color.fromARGB(255, 0, 0, 255),
                            const Color.fromARGB(255, 127, 0, 255),
                            const Color.fromARGB(255, 255, 0, 255),
                            const Color.fromARGB(255, 255, 0, 127),
                            const Color.fromARGB(255, 255, 0, 0),
                          ],
                          trackGradientStartAngle: 0,
                          trackGradientEndAngle: 360,
                          progressBarColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                if (index < 2) {
                  index++;
                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.decelerate,
                  );
                }
              },
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: secondaryFg,
              ),
            ),
          ],
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
                    "Meross Light Bulb",
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
                    Device(device: device).toggle(value ? "on" : "off");
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
                    "${formatEnergy()} Watts in ${formatDuration()}",
                    style: TextStyle(
                      color: duration.inSeconds == 0 ? subtext : secondaryFg,
                      fontSize: screen_.width / 21.851,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(top: screen_.height / 26.76)),
        AppCard(
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
                  sceneName: "Night",
                  icon: CupertinoIcons.moon,
                  onClick: () {
                    executeScene("Night");
                    setState(() {
                      brightness = 1;
                      temp = 2200;
                    });
                  },
                ),
                ShortCutButton(
                  sceneName: "Eco",
                  icon: Icons.eco_outlined,
                  onClick: () {
                    executeScene("Eco");
                    setState(() {
                      brightness = 10;
                      temp = 4000;
                    });
                  },
                ),
                ShortCutButton(
                  sceneName: "Work",
                  icon: Icons.computer_outlined,
                  onClick: () {
                    executeScene("Work");
                    setState(() {
                      brightness = 60;
                      temp = 6000;
                    });
                  },
                ),
                ShortCutButton(
                  sceneName: "Max",
                  icon: CupertinoIcons.brightness,
                  onClick: () {
                    executeScene("Max");
                    setState(() {
                      brightness = 100;
                      temp = 9000;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ShortCutButton extends StatelessWidget {
  const ShortCutButton({
    Key? key,
    required this.sceneName,
    required this.icon,
    this.onClick,
  }) : super(key: key);

  final String sceneName;
  final IconData icon;
  final Function()? onClick;

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Column(
      children: [
        IconButton(
          onPressed: onClick,
          icon: Icon(
            icon,
            color: secondaryFg,
            size: sqrt(screen_.height + screen_.width) / 1.23,
          ),
        ),
        Text(
          sceneName,
          style: TextStyle(
            color: secondaryFg,
            fontWeight: FontWeight.w400,
            fontSize: screen_.width / 26.1818,
          ),
        )
      ],
    );
  }
}

class LightsControlPage extends StatefulWidget {
  const LightsControlPage({
    Key? key,
    required this.setDevicesFunc,
  }) : super(key: key);
  final Function setDevicesFunc;

  @override
  State<LightsControlPage> createState() => _LightsControlPageState();
}

class _LightsControlPageState extends State<LightsControlPage> {
  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Heading(setDevicesFunc: widget.setDevicesFunc),
            Padding(padding: EdgeInsets.only(top: screen_.height / 26.76)),
            const SlidersAndSwitch(),
          ],
        ),
      ),
    );
  }
}
