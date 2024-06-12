import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Position? positionData;
  List<Marker> markers = [];
  MapController mapController = MapController();
  double zoom = 15;
  Marker? toDelete;

  void createMarker(LatLng position){
    Marker marker = Marker(
        point: position,
        child: GestureDetector(
          onLongPressStart: (details){
            showDialog(context: context, builder: (BuildContext context) {
              return AlertDialog(
                content: Text("${position}"),
              );
            },);
          },
          child: IconButton(
              onPressed: (){
                showDialog(context: context, builder: (BuildContext context) {
                  print("Entered");
                  return AlertDialog(
                    content: Text("Delete Marker?"),
                    actions: [
                      ElevatedButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: Text("No")),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          markers.removeWhere((marker)=> marker.point == position);
                        });
                        Navigator.pop(context);
                      }, child: Text("Yes"))
                    ],
                  );
                });

              }, icon: Icon(CupertinoIcons.location_solid, color: Colors.red,)),
        ));

    setState(() {
      markers.add(marker);
    });
  }

  void getLocation()async{
    await Geolocator.requestPermission();

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(
        locationSettings: locationSettings).listen(
            (Position? position) {
          setState(() {
            positionData = position;
          });
          if( position!=null ){
            createMarker( LatLng(position.latitude, position.longitude) );
          }

          print(position == null ?
          'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: ButtonBar(
          children: [
            IconButton(onPressed: (){
              setState(() {
                zoom = zoom - 0.2;
              });
              mapController.move(mapController.camera.center,
                  zoom);
            }, icon: Icon(CupertinoIcons.minus_circle_fill)),
            IconButton(onPressed: (){
              setState(() {
                zoom = zoom + 0.2;
              });
              mapController.move(mapController.camera.center,
                  zoom);
            }, icon: Icon(CupertinoIcons.add_circled_solid))
          ],
        ),
        body: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onTap: (position, latlong){
                createMarker( latlong );
              },
              initialCenter: LatLng(positionData!.latitude, positionData!.longitude),
              initialZoom: zoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: markers)
            ]),
      ),
    );
  }
}