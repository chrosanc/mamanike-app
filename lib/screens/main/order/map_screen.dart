import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamanike/screens/main/order/searchaddress_screen.dart';

class MapScreen extends StatefulWidget {
  final Function(String) address;
  final Function(Map<String, dynamic>) pinpoint;
  const MapScreen({Key? key, required this.address, required this.pinpoint}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(-6.923073, 107.633750);
  String _address = 'Loading address...';
  String subLocality = '';
  bool _mapCreated = false;
  late Placemark place;
  String? _previousAddress;
  String? _previousSubLocality;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _mapCreated = true;
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _center = position.target;
    });
  }

  void _onCameraIdle() async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(_center.latitude, _center.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      setState(() {
        _address =
            "${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
        subLocality = "${place.subLocality}";
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(_center));
    });

    _onCameraIdle();
  }

  Future<void> _navigateAndSelectAddress() async {
    _previousAddress = _address;
    _previousSubLocality = subLocality;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchaddressScreen(
          onAddressSelected: (String address) async {
            List<Location> locations = await locationFromAddress(address);
            if (locations.isNotEmpty) {
              Location location = locations[0];
              LatLng newCenter = LatLng(location.latitude, location.longitude);
              setState(() {
                _center = newCenter;
                _address = address;
              });
              mapController.animateCamera(CameraUpdate.newLatLng(newCenter));
            }
          },
        ),
      ),
    );
  }

  void _undoAddressSelection() {
    if (_previousAddress != null && _previousSubLocality != null) {
      setState(() {
        _address = _previousAddress!;
        subLocality = _previousSubLocality!;
      });
    }
  }
  void _savePinPointLocation() {
    widget.address(_address);
    widget.pinpoint({
      'latitude': _center.latitude,
      'longitude': _center.longitude,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 76,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          'Tentukan Pinpoint Lokasi',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFB113),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            mapType: MapType.normal,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
          ),
          Center(
            child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLocationButton(
                          icon: Icons.gps_fixed,
                          label: 'Gunakan Lokasi Saat Ini',
                          onTap: _useCurrentLocation),
                      _buildLocationButton(
                          icon: Icons.search,
                          label: 'Cari Alamat',
                          onTap: _navigateAndSelectAddress),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '$subLocality \n',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: _address,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: const BorderSide(
                                color: Color(0xFFFFB113),
                              ),
                            ),
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.white,
                            elevation: 0,
                          ),
                          onPressed: _savePinPointLocation,
                          child: Text(
                            "Pilih Lokasi & Lanjut isi alamat",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFB113),
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
