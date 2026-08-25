import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const SensorApp());

class SensorApp extends StatelessWidget {
  const SensorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
    home: const SensorScreen(),
  );
}

class SensorScreen extends StatefulWidget{  const SensorScreen({super.key});
  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final String piIP = "10.0.0.156";
  double temperature = 0, humidity = 0;
  String imageUrl = "";
  Timer? timer;

  int risk = 0;
  String level = "LOW";
  Color levelColor = Colors.green;
  List<String> hazards = [];

  @override
  void initState() {
    super.initState();
    imageUrl = "http://$piIP/images/latest.jpg";
    readSensor();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => readSensor());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void calculateRisk() {
    int score = 0;
    hazards.clear();

    if (temperature >= 40) { score += 40; hazards.add("🔥 Extreme Heat");}
    else if (temperature >= 35){ score += 30; hazards.add("🌡 High Temperature");}
    else if (temperature >= 30){ score += 20; hazards.add("Warm Conditions");}
    else if (temperature >= 25){ score += 10;}

    if (humidity <= 15){ score += 40; hazards.add("💧 Very Low Humidity");}
    else if (humidity <= 25){ score += 30; hazards.add("Low Humidity");}
    else if (humidity <= 40){ score += 20;}
    else if (humidity <= 60){ score += 10;}

    // Placeholder for future AI image analysis.
    bool smokeDetected = false;
    bool flamesDetected = false;
    bool dryVegetation = false;

    if (smokeDetected){ score += 25; hazards.add("🌫 Smoke Detected");}
    if (flamesDetected){ score += 50; hazards.add("🔥 Flames Detected");}
    if (dryVegetation){ score += 15; hazards.add("🌲 Dry Vegetation");}

    score = score.clamp(0,100);
    risk = score;

    if(score>=80){level="EXTREME";levelColor=Colors.red;}
    else if(score>=55){level="HIGH";levelColor=Colors.orange;}
    else if(score>=30){level="MODERATE";levelColor=Colors.amber;}
    else {level="LOW";levelColor=Colors.green;}

    if(score>=55 && !hazards.contains("🚨 Elevated Wildfire Potential")){
      hazards.add("🚨 Elevated Wildfire Potential");
    }
  }

  Future<void> readSensor() async {
    try{
      final r=await http.get(Uri.parse("http://$piIP:5000/sensor"));
      final d=jsonDecode(r.body);
      setState(() {
        temperature=double.parse(d["temperature"].toString());
        humidity=double.parse(d["humidity"].toString());
        imageUrl="http://$piIP/images/latest.jpg?${DateTime.now().millisecondsSinceEpoch}";
        calculateRisk();
      });
    }catch(_){}
  }

  Widget infoCard(IconData icon,String title,String value)=>Card(
    child:Padding(
      padding:const EdgeInsets.all(16),
      child:Column(children:[
        Icon(icon,size:36),
        Text(title),
        Text(value,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold))
      ]),
    ));

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:const Text("🔥 Wildfire Monitor"),centerTitle:true),
      body:SingleChildScrollView(
        padding:const EdgeInsets.all(16),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Card(color:levelColor.withOpacity(.15),
            child:Padding(
              padding:const EdgeInsets.all(20),
              child:Column(children:[
                Text(level,style:TextStyle(fontSize:34,fontWeight:FontWeight.bold,color:levelColor)),
                const SizedBox(height:8),
                LinearProgressIndicator(value:risk/100,minHeight:12),
                const SizedBox(height:8),
                Text("Risk Score: $risk/100")
              ]),
            ),
          ),
          const SizedBox(height:12),
          Row(children:[
            Expanded(child:infoCard(Icons.thermostat,"Temperature","${temperature.toStringAsFixed(1)} °C")),
            const SizedBox(width:12),
            Expanded(child:infoCard(Icons.water_drop,"Humidity","${humidity.toStringAsFixed(1)} %")),
          ]),
          const SizedBox(height:12),
          Card(child:Padding(
            padding:const EdgeInsets.all(16),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              const Text("⚠ Hazards",style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
              if(hazards.isEmpty) const Text("No immediate hazards.")
              else ...hazards.map((e)=>Padding(
                padding:const EdgeInsets.symmetric(vertical:2),
                child:Text("• "+e)))
            ]),
          )),
          const SizedBox(height:12),
          const Text("📷 Live Camera",style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
          const SizedBox(height:8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 250,
                child: Center(
                  child: Text("Waiting for camera...")
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
