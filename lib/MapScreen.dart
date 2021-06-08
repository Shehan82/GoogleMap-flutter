import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_on_flutter/directions_model.dart';
import 'package:map_on_flutter/directions_repo.dart';

class MapScreen extends StatefulWidget {
  LatLng dest;
  MapScreen({this.dest});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static LatLng currentPostion;
  Marker _origin;
  Marker _destination;
  // Marker _currentPos = Marker(
  //     markerId: const MarkerId('current'),
  //     infoWindow: const InfoWindow(title: 'Your location'),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //     position:
  //         currentPostion != null ? currentPostion : LatLng(7.8731, 80.7718));
  Directions _info;

  void initState() {
    print(widget.dest.latitude);
    super.initState();
    getCurrentLocation(widget.dest);
  }

  GoogleMapController _googleMapController;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  getCurrentLocation(LatLng pos) async {
    final geoPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    setState(() {
      currentPostion = LatLng(geoPosition.latitude, geoPosition.longitude);
    });

    _loadDirection(currentPostion, pos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Google Maps'),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.green,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('ORIGIN'),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('DEST'),
            )
        ],
      ),
      body: currentPostion == null
          ? Container()
          : Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  initialCameraPosition:
                      CameraPosition(target: currentPostion, zoom: 15),
                  onMapCreated: (controller) =>
                      _googleMapController = controller,
                  markers: {
                    if (_origin != null) _origin,
                    if (_destination != null) _destination,
                    // if (_currentPos != null) _currentPos
                  },
                  polylines: {
                    if (_info != null)
                      Polyline(
                        polylineId: const PolylineId('overview_polyline'),
                        color: Colors.red,
                        width: 5,
                        points: _info.polylinePoints
                            .map((e) => LatLng(e.latitude, e.longitude))
                            .toList(),
                      ),
                  },
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
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentPostion, zoom: 15),
          ),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  // void _addMarker(LatLng pos) async {
  //   // Origin is not set OR Origin/Destination are both set
  //   // Set origin
  //   setState(() {
  //     _origin = Marker(
  //       markerId: const MarkerId('origin'),
  //       infoWindow: const InfoWindow(title: 'Origin'),
  //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //       position: pos,
  //     );
  //     // Reset destination
  //     _destination = null;

  //     _info = null;

  //     _destination = Marker(
  //       markerId: const MarkerId('destination'),
  //       infoWindow: const InfoWindow(title: 'Destination'),
  //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //       position: pos,
  //     );

  //     // Reset info
  //     // _info = null;
  //   });

  //   // Origin is already set
  //   // Set destination
  //   setState(() {});

  //   // Get directions
  //   final directions = await DirectionsRepository()
  //       .getDirections(origin: _origin.position, destination: pos);
  //   setState(() => _info = directions);
  // }

  void _loadDirection(LatLng origin, LatLng destination) async {
    print("blaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    print(destination);
    setState(() {
      _origin = Marker(
        markerId: const MarkerId('origin'),
        infoWindow: const InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: origin,
      );

      _destination = null;

      _info = null;
    });
    print("boooooooooooooooooooooooooooooooo");

    setState(() {
      _destination = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: destination,
      );
    });

    // Get directions
    final directions = await DirectionsRepository()
        .getDirections(origin: origin, destination: destination);
    setState(() => _info = directions);
  }
}
