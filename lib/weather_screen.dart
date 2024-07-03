import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_app/weather_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
const WeatherScreen({ super.key });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
   double temp = 0; 
   bool isLoading = true;
  @override
void initState(){
  super.initState();
  getCurrentWeather();
  
}

Future<Map<String , dynamic>>  getCurrentWeather() async {
  try {
    setState( () {
      isLoading = true;
    } );
    String cityName = 'London';
    final res = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$OpenWeatherApiKey'
        )
      );

     final data = jsonDecode(res.body);

    if(int.parse(data['cod']) != 200){
      throw  data['message'];
    }
   return data;
  } 
  catch(e){
    throw e.toString();
  }
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App',
        style: TextStyle(
          fontWeight: FontWeight.bold
          )
        ),
        centerTitle:true,
        actions: [
         IconButton(
          onPressed:() {
            setState((){

            });
          },
          icon: const Icon(Icons.refresh),
         )
        ]
      ),
      body:  
        FutureBuilder(
          future: getCurrentWeather() ,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child:  CircularProgressIndicator.adaptive(),
                );
            }

            if(snapshot.hasError) {
              return  Text(snapshot.error.toString());
            }

            final data  = snapshot.data! ;
            final currentWeatherData = data['list'][0];

            final currentTemp = currentWeatherData['main']['temp'];

            final currentSky =  currentWeatherData['weather'][0]['main'];
            final currentPressure = currentWeatherData['main']['pressure'];
            final currentWindSpeed = currentWeatherData['wind']['speed'];
            final currentHumidity = currentWeatherData['main']['humidity'];
           
            return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children:[
                // main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child:   Padding(
                          padding:  EdgeInsets.all(16.0),
                          child: Column(
                            children:[
                              Text(
                                "$currentTemp K",
                                style:TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 16),
                          
                             Icon(
                                currentSky == 'Clouds' ||  currentSky == 'Rain' ? Icons.cloud : Icons.sunny,
                                size: 64,
                              ),
                              
                            const  SizedBox(height: 16),
                              Text(
                                "Rain",
                                style:const TextStyle(
                                fontSize:20,
                                ),
                              ),
                            ],
                          ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Weather Forecast",
                  style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 20),
             
              /* SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                  [
                    for(int i = 0; i <38;i++ )
                     SizedBox(
                        width: 100,
                        child:HourlyForecastItm(
                          time:  data['list'][i+1]['dt'].toString(),
                          temprature:  data['list'][i+1] ['main']['temp'].toString(),
                          icon:  data['list'][i+1]['weather'][0]['main'] == 'Clouds' ||  data['list'][i+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
                        ),
                      ),
                  ],
                ),
            ),
              */
       
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:8 ,
                  itemBuilder: (context , index){
                  final hourlyForecast = data['list'][index+1];
                  final hourlySky = data['list'][index+1]['weather'][0]['main'];
                  final hourlyTemp = hourlyForecast['main']['temp'].toString();
                  final time = DateTime.parse(hourlyForecast['dt_txt']);
                
                    return HourlyForecastItm(
                      time:  DateFormat.Hm().format(time),
                      temprature:  hourlyTemp,
                      icon:  hourlySky == 'Clouds' ||  data['list'][index+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
                    );
                
                },
                ),
              ),
              // weather forecast cards
             
              const SizedBox(height: 20),
              // additional information 
            
            const Align(
              alignment: Alignment.centerLeft,
                child: const Text(
                  'Additional Information',
                  style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                  ),
                ),
            ),
            const SizedBox(height: 12),
            Row (
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: 
              [
                AdditionalInfoItem(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: currentHumidity.toString(),
                ),
                AdditionalInfoItem(
                  icon:Icons.air,
                  label: 'Wind Speed',
                  value: currentWindSpeed.toString(),
                ),
                AdditionalInfoItem(
                  icon: Icons.beach_access,
                  label: 'Pressure',
                  value: currentPressure.toString(),
                ),
                   
              ],
            )
            ],
          ),
               );
          },
       )
    );
  }
}


