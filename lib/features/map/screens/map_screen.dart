import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/map_bloc.dart';
import '../../../shared/widgets/glass_container.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => MapBloc(),
      child: const MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: state.center,
                  zoom: state.zoom,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  context.read<MapBloc>().add(MapInitialized(controller));
                },
                onCameraMove: (position) {
                  context.read<MapBloc>().add(MapZoomChanged(position.zoom));
                },
                onCameraIdle: () {
                  // Debounced bounds update
                  Future.delayed(const Duration(milliseconds: 600), () {
                    if (_mapController != null && mounted) {
                      _mapController!.getVisibleRegion().then((bounds) {
                        context.read<MapBloc>().add(MapCameraMoved(bounds, bounds.center));
                      });
                    }
                  });
                },
                markers: state.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                padding: const EdgeInsets.only(bottom: 100), // Padding for navigation bar
              ),
              // Overlay controls
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                child: GlassContainer(
                  height: 60,
                  opacity: 0.9,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search for dishes or vendors...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Search action
                        },
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                  ),
                ),
              ),
              // Zoom controls
              Positioned(
                right: 16,
                bottom: 120,
                child: GlassContainer(
                  width: 48,
                  height: 96,
                  opacity: 0.9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          _mapController?.animateCamera(CameraUpdate.zoomIn());
                        },
                        icon: const Icon(Icons.add),
                        iconSize: 20,
                      ),
                      const Divider(height: 1),
                      IconButton(
                        onPressed: () {
                          _mapController?.animateCamera(CameraUpdate.zoomOut());
                        },
                        icon: const Icon(Icons.remove),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ),
              // Loading indicator
              if (state.isLoading)
                const Positioned(
                  top: 120,
                  left: 16,
                  child: GlassContainer(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Loading nearby dishes...'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}