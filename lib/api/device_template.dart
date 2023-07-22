import 'dart:convert';

import 'package:http/http.dart' as http;

Map<String, String> devices = {
  "plug": "-------", // Main Chargers
  "monitor": "-------",
  "strip": "-------", // LED Strip
  "usb": "-------", //
  "power": "-------", // Power Strip
  "lights": "-------", // Smart Bulb
};

Map<String, String> headers = {
  "Accept": "application/vnd.smartthings+json;v=1",
  "Authorization": "Bearer ---",
  "Content-Type": "application/json",
};

Map<String, String> aliases = {
  "main chargers": "plug",
  "monitor": "monitor",
  "light strip": "strip",
  "usb": "usb",
  "power strip": "power",
  "light bulb": "lights",
};

Map<String, int> energyMap = {
  "plug": 65,
  "monitor": 10,
  "strip": 8,
  "usb": 5,
  "lights": 3,
};

Map<String, String> scenes = {
  "Night": "-------",
  "Eco": "-------",
  "Work": "-------",
  "Max": "-------",
};

class Devices {
  final String value;
  final DateTime timestamp;

  const Devices({
    required this.value,
    required this.timestamp,
  });

  factory Devices.fromJson(Map<String, dynamic> json) {
    String timestamp =
        json['switch']['timestamp'].replaceAll("T", " ").replaceAll("Z", "");
    timestamp = timestamp.substring(0, timestamp.length - 1);

    DateTime dateTime = DateTime.parse(timestamp);

    return Devices(
      value: json['switch']['value'],
      timestamp: dateTime,
    );
  }
}

Future<Devices> getDeviceInfo(String device) async {
  final http.Response response = await http.get(
      Uri.parse(
        'https://api.smartthings.com/v1/devices/${devices[device]}/components/main/capabilities/switch/status',
      ),
      headers: headers);
  return Devices.fromJson(jsonDecode(response.body));
}

class Device {
  const Device({
    required this.device,
  });

  final String device;

  Future<Devices> info() async {
    return getDeviceInfo(device);
  }

  void toggle(String method) async {
    await http.post(
        Uri.parse(
            'https://api.smartthings.com/v1/devices/${devices[device]}/commands'),
        headers: headers,
        body: '{commands:[{"capability": "switch","command": "$method"}]}');
  }

  void changeBrightness(int brightness) async {
    if (brightness > 100) brightness = 100;

    await http.post(
      Uri.parse(
          'https://api.smartthings.com/v1/devices/${devices[device]}/commands'),
      headers: headers,
      body:
          '{"commands": [{"capability": "switchLevel", "command": "setLevel","arguments": [$brightness]}]}',
    );
  }

  void changeTemp(int temp) async {
    if (temp > 9000) temp = 9000;
    if (temp < 2200) temp = 2200;

    await http.post(
      Uri.parse(
          'https://api.smartthings.com/v1/devices/${devices[device]}/commands'),
      headers: headers,
      body:
          '{"commands": [{"capability": "colorTemperature", "command": "setColorTemperature","arguments": [$temp]}]}',
    );
  }

  void changeColor(int hue) async {
    if (hue < 0) hue = 0;
    if (hue > 99) hue = 99;

    await http.post(
      Uri.parse(
          'https://api.smartthings.com/v1/devices/${devices[device]}/commands'),
      headers: headers,
      body:
          '{"commands": [{"capability": "colorControl", "command": "setColor","arguments": [{"hue": $hue, "saturation": 100}]}]}',
    );
  }

  Future<Map<String, dynamic>> getLightsInfo() async {
    final resp = await http.get(
      Uri.parse(
          'https://api.smartthings.com/v1/devices/${devices[device]}/status'),
      headers: headers,
    );

    final data = jsonDecode(resp.body)["components"]["main"];

    final info = {
      "info": data["switch"]["switch"],
      "brightness": data["switchLevel"]["level"]["value"],
      "temp": data["colorTemperature"]["colorTemperature"]["value"],
      "hue": data["colorControl"]["hue"]["value"],
    };

    return info;
  }

  Future<double> energy() async {
    var info_ = await info();

    if (info_.value == 'off') {
      return 0.0;
    }

    final DateTime dateTimeNow = DateTime.now();
    int adjustment = 0;
    if (dateTimeNow.timeZoneName == 'BST') adjustment = 3600;

    int secondsElapsed = dateTimeNow.difference(info_.timestamp).inSeconds -
        adjustment; // dart thinks smartthings returns a timestamp of BST but it's actually UTC. In summer, have -3600, and in winter have -0

    double calculate(int watts) => (watts * (secondsElapsed / 3600));

    switch (device) {
      case "plug":
        return calculate(65);

      case "monitor":
        return calculate(10);

      case "strip":
        return calculate(8);

      case "usb":
        return calculate(5);

      case "lights":
        return calculate(3);

      case "power":
        final devices = await getAllDevicesInfo();

        double energy_ = 0.0;
        devices.forEach((key, value) {
          if (value.value == 'on' && key != 'lights') {
            var secondsElapsed_ =
                dateTimeNow.difference(value.timestamp).inSeconds - 3600;

            double calculate_(int watts) => (watts * (secondsElapsed_ / 3600));

            var deviceEnergyUsage =
                calculate_(energyMap[key]?.toInt() ?? 696969);
            energy_ += deviceEnergyUsage;
          }
        });

        return energy_;

      default:
        return 6969;
    }
  }
}

Future<Map<String, dynamic>> getAllDevicesInfo() async {
  final devices = await Future.wait([
    const Device(device: "plug").info(),
    const Device(device: "monitor").info(),
    const Device(device: "strip").info(),
    const Device(device: "usb").info(),
    const Device(device: "lights").info(),
  ]);

  return {
    "plug": devices[0],
    "monitor": devices[1],
    "strip": devices[2],
    "usb": devices[3],
    "lights": devices[4],
  };
}

executeScene(String scene) async {
  await http.post(
    Uri.parse("https://api.smartthings.com/v1/scenes/${scenes[scene]}/execute"),
    headers: headers,
  );
}
