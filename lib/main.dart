import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gmaps/DirectionServices.dart';
import 'package:gmaps/Directions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({Key key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // Variables
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(22.3569, 91.7832), zoom: 13);

  GoogleMapController _mapController;
  Marker _origin;
  Marker _destination;
  Marker _tap1;
  Marker _tap2;
  Marker _tap3;
  Marker _tap4;
  Directions _info;

  List<LatLng> polygonItems = [];

  Set<Polygon> _polygons = HashSet<Polygon>();
  var _polygonTapCounter = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    _mapController.dispose();
    super.dispose();
  }

  void _setPolygons() {
    _polygons.add(Polygon(
        polygonId: PolygonId("polygonId-1"),
        points: polygonItems,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.grey.withOpacity(0.2)));
  }

  void _getPolygonPoint(LatLng point) async {
    if (_polygonTapCounter <= 3) {
      polygonItems.add(point);
      setState(() {
        _addPolygonMarker(point);
      });
      if (_polygonTapCounter == 3) {
        setState(() {
          _setPolygons();
        });
      }

      _polygonTapCounter++;
    } else {
      setState(() {
        _polygonTapCounter = 0;
        polygonItems.clear();
        _clearPolygonMarkers();
        _polygons.clear();
      });
    }
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
            markerId: MarkerId("origin"),
            infoWindow: InfoWindow(title: "Origin"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);
        _destination = null;
        _info = null;
      });
    } else {
      setState(() {
        _destination = Marker(
            markerId: MarkerId("destination"),
            infoWindow: InfoWindow(title: 'Destination'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos);
      });

      final direction = await DirectionsRepository()
          .getDirections(origin: _origin.position, destination: pos);
      setState(() {
        _info = direction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Mappy"),
        actions: [
          if (_origin != null)
            TextButton(
                onPressed: () => _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                          target: _origin.position, zoom: 15, tilt: 50.0)),
                    ),
                style: TextButton.styleFrom(
                    primary: Colors.black,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                child: Text('Origin')),
          if (_destination != null)
            TextButton(
                onPressed: () => _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                          target: _destination.position, zoom: 15, tilt: 50.0)),
                    ),
                style: TextButton.styleFrom(
                    primary: Colors.black,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                child: Text('Destination')),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              if (_origin != null) _origin,
              if (_destination != null) _destination,
              if (_tap1 != null) _tap1,
              if (_tap2 != null) _tap2,
              if (_tap3 != null) _tap3,
              if (_tap4 != null) _tap4,
            },
            polylines: {
              if (_info != null)
                Polyline(
                    polylineId: PolylineId('polyline_id'),
                    color: Colors.red,
                    width: 5,
                    points: _info.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList()),
            },
            polygons: _polygons,
            onLongPress: _addMarker,
            onTap: _getPolygonPoint,
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info.totalDistance}, ${_info.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.black,
        child: const Icon(Icons.center_focus_weak_sharp),
        onPressed: () => _mapController.animateCamera(_info != null
            ? CameraUpdate.newLatLngBounds(_info.bounds, 100)
            : CameraUpdate.newCameraPosition(_initialCameraPosition)),
      ),
    );
  }

  void _addPolygonMarker(LatLng point) {
    switch (_polygonTapCounter) {
      case 0:
        _tap1 = Marker(
            markerId: MarkerId("tap1"),
            infoWindow: InfoWindow(title: "First Polygon Marker"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            position: point);
        break;
      case 1:
        _tap2 = Marker(
            markerId: MarkerId("tap2"),
            infoWindow: InfoWindow(title: "Second Polygon Marker"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            position: point);
        break;
      case 2:
        _tap3 = Marker(
            markerId: MarkerId("tap3"),
            infoWindow: InfoWindow(title: "Third Polygon Marker"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            position: point);
        break;
      case 3:
        _tap4 = Marker(
            markerId: MarkerId("tap4"),
            infoWindow: InfoWindow(title: "Fouth Polygon Marker"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            position: point);
        break;
    }
  }

  void _clearPolygonMarkers() {
    _tap1 = null;
    _tap2 = null;
    _tap3 = null;
    _tap4 = null;
  }
}
