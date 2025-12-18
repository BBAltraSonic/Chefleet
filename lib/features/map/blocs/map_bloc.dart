import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/blocs/base_bloc.dart';
import '../../../core/constants/app_constants.dart';

class MapEvent extends AppEvent {
  const MapEvent();
}

class MapInitialized extends MapEvent {
  const MapInitialized(this.controller);

  final GoogleMapController controller;

  @override
  List<Object?> get props => [controller];
}

class MapCameraMoved extends MapEvent {
  const MapCameraMoved(this.bounds, this.center);

  final LatLngBounds bounds;
  final LatLng center;

  @override
  List<Object?> get props => [bounds, center];
}

class MapZoomChanged extends MapEvent {
  const MapZoomChanged(this.zoom);

  final double zoom;

  @override
  List<Object?> get props => [zoom];
}

class MapMarkersUpdated extends MapEvent {
  const MapMarkersUpdated(this.markers);

  final Set<Marker> markers;

  @override
  List<Object?> get props => [markers];
}

class MapState extends AppState {
  const MapState({
    this.controller,
    this.bounds,
    this.center = AppConstants.defaultLocationSouthAfrica, // Johannesburg, South Africa default
    this.zoom = 14.0,
    this.markers = const {},
    this.isLoading = false,
  });

  final GoogleMapController? controller;
  final LatLngBounds? bounds;
  final LatLng center;
  final double zoom;
  final Set<Marker> markers;
  final bool isLoading;

  MapState copyWith({
    GoogleMapController? controller,
    LatLngBounds? bounds,
    LatLng? center,
    double? zoom,
    Set<Marker>? markers,
    bool? isLoading,
  }) {
    return MapState(
      controller: controller ?? this.controller,
      bounds: bounds ?? this.bounds,
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [controller, bounds, center, zoom, markers, isLoading];
}

class MapBloc extends AppBloc<MapEvent, MapState> {
  MapBloc() : super(const MapState()) {
    on<MapInitialized>(_onMapInitialized);
    on<MapCameraMoved>(_onCameraMoved);
    on<MapZoomChanged>(_onZoomChanged);
    on<MapMarkersUpdated>(_onMarkersUpdated);
  }

  void _onMapInitialized(MapInitialized event, Emitter<MapState> emit) {
    emit(state.copyWith(controller: event.controller));
  }

  void _onCameraMoved(MapCameraMoved event, Emitter<MapState> emit) {
    emit(state.copyWith(
      bounds: event.bounds,
      center: event.center,
    ));
  }

  void _onZoomChanged(MapZoomChanged event, Emitter<MapState> emit) {
    emit(state.copyWith(zoom: event.zoom));
  }

  void _onMarkersUpdated(MapMarkersUpdated event, Emitter<MapState> emit) {
    emit(state.copyWith(markers: event.markers));
  }

  void moveCamera(LatLng target, {double? zoom}) {
    if (state.controller != null) {
      state.controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: zoom ?? state.zoom,
          ),
        ),
      );
    }
  }

  void addMarker(Marker marker) {
    final updatedMarkers = Set<Marker>.from(state.markers)..add(marker);
    add(MapMarkersUpdated(updatedMarkers));
  }

  void removeMarker(String markerId) {
    final updatedMarkers = Set<Marker>.from(state.markers)
      ..removeWhere((marker) => marker.markerId.value == markerId);
    add(MapMarkersUpdated(updatedMarkers));
  }

  void clearMarkers() {
    add(const MapMarkersUpdated({}));
  }
}