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
  Directions _info;

  @override
  void dispose() {
    // TODO: implement dispose
    _mapController.dispose();
    super.dispose();
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
              if (_destination != null) _destination
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
            onLongPress: _addMarker,
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
}
