import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_poll/features/maps/bloc/map_cubit.dart';
import 'package:location_poll/features/maps/bloc/map_state.dart';
import 'package:location_poll/features/poll/create/bloc/create_cubit.dart';
import 'package:location_poll/global_ui/theme/colors.dart';
import 'package:location_poll/global_ui/theme/input_field_decoration.dart';

class MapPage extends StatelessWidget {
  static const String routeName = '/maps';
  final LatLng position;
  final double radius;

  /*
  Examples for FlutterMap
  https://github.com/fleaflet/flutter_map/tree/master/example/lib/pages
   */
  const MapPage({Key? key, required this.position, required this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MapCubit>.value(
            value: Modular.get<MapCubit>()..mapInit(position, radius)),
        BlocProvider<CreateCubit>.value(value: Modular.get<CreateCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          backgroundColor: ColorTheme.barColorBlue,
        ),
        body: const _MapPageContent(),
      ),
    );
  }
}

// copied from https://github.com/fleaflet/flutter_map/tree/master/example/lib/pages

class _MapPageContent extends StatelessWidget {
  const _MapPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox.expand(
        child: Stack(
          children: const [
            _MapLayer(),
            _ControlLayer(),
          ],
        ),
      ),
    );
  }
}

class ZoomButtonsPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is ZoomButtonsPluginOption) {
      return ZoomButtons(options, mapState, stream);
    }
    throw Exception('Unknown options type for ZoomButtonsPlugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is ZoomButtonsPluginOption;
  }
}

class ZoomButtons extends StatelessWidget {
  final ZoomButtonsPluginOption zoomButtonsOpts;
  final MapState map;
  final Stream<void> stream;
  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(12.0));

  ZoomButtons(this.zoomButtonsOpts, this.map, this.stream)
      : super(key: zoomButtonsOpts.key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: zoomButtonsOpts.alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: zoomButtonsOpts.padding,
                top: zoomButtonsOpts.padding,
                right: zoomButtonsOpts.padding),
            child: FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: zoomButtonsOpts.mini,
              backgroundColor:
                  zoomButtonsOpts.zoomInColor ?? Theme.of(context).primaryColor,
              onPressed: () {
                var bounds = map.getBounds();
                var centerZoom = map.getBoundsCenterZoom(bounds, options);
                var zoom = centerZoom.zoom + 1;
                if (zoom < zoomButtonsOpts.minZoom) {
                  zoom = zoomButtonsOpts.minZoom as double;
                } else {
                  map.move(centerZoom.center, zoom,
                      source: MapEventSource.mapController);
                }
              },
              child: Icon(zoomButtonsOpts.zoomInIcon,
                  color: zoomButtonsOpts.zoomInColorIcon ??
                      IconTheme.of(context).color),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(zoomButtonsOpts.padding),
            child: FloatingActionButton(
              heroTag: 'zoomOutButton',
              mini: zoomButtonsOpts.mini,
              backgroundColor: zoomButtonsOpts.zoomOutColor ??
                  Theme.of(context).primaryColor,
              onPressed: () {
                var bounds = map.getBounds();
                var centerZoom = map.getBoundsCenterZoom(bounds, options);
                var zoom = centerZoom.zoom - 1;
                if (zoom > zoomButtonsOpts.maxZoom) {
                  zoom = zoomButtonsOpts.maxZoom as double;
                } else {
                  map.move(centerZoom.center, zoom,
                      source: MapEventSource.mapController);
                }
              },
              child: Icon(zoomButtonsOpts.zoomOutIcon,
                  color: zoomButtonsOpts.zoomOutColorIcon ??
                      IconTheme.of(context).color),
            ),
          ),
        ],
      ),
    );
  }
}

class ZoomButtonsPluginOption extends LayerOptions {
  final int minZoom;
  final int maxZoom;
  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color? zoomInColor;
  final Color? zoomInColorIcon;
  final Color? zoomOutColor;
  final Color? zoomOutColorIcon;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;

  ZoomButtonsPluginOption({
    Key? key,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.topRight,
    this.zoomInColor,
    this.zoomInColorIcon,
    this.zoomInIcon = Icons.zoom_in,
    this.zoomOutColor,
    this.zoomOutColorIcon,
    this.zoomOutIcon = Icons.zoom_out,
    Stream<Null>? rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class _ControlLayer extends StatelessWidget {
  const _ControlLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              child: TextFormField(
                controller: context.read<MapCubit>().textSearchController,
                decoration: InputFieldDecorations.defaultDecoration(
                  context: context,
                  labelText: 'Search',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      String searchValue =
                          context.read<MapCubit>().textSearchController.text;
                      if (searchValue != "") {
                        context.read<MapCubit>().findLocation(searchValue);
                      }
                    },
                  ),
                ),
              ),
            ),
            BlocBuilder<MapCubit, MapsState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    context.read<MapCubit>().saveLocation(state.marker);
                    context.read<CreateCubit>().locationChange(state.marker);
                    Modular.to.pop();
                  },
                  child: const Text('Save'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLayer extends StatelessWidget {
  const _MapLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapsState>(
      builder: (context, state) {
        return SizedBox.expand(
          child: FlutterMap(
            nonRotatedLayers: [
              ZoomButtonsPluginOption(
                minZoom: 1,
                maxZoom: 19,
                mini: true,
                padding: 10,
                alignment: Alignment.bottomRight,
              ),
            ],
            mapController: context.read<MapCubit>().mapController,
            options: MapOptions(
              center: state.mapCenter,
              onTap: (tabPos, latlng) {
                context.read<MapCubit>().changeMarker(latlng);
              },
              //center: state.mapCenter,
              zoom: 12,
              plugins: [
                ZoomButtonsPlugin(),
              ],
            ),
            layers: [
              CircleLayerOptions(circles: [
                CircleMarker(
                    point: state.marker,
                    color: Colors.blue.withOpacity(0.5),
                    useRadiusInMeter: true,
                    radius: state.radiusInMeter // 2000 meters | 2 km
                    ),
              ]),
              MarkerLayerOptions(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: state.marker,
                    builder: (ctx) => Icon(Icons.room, color: ColorTheme.colorBlack,),
                  ),
                ],
              ),
            ],
            children: <Widget>[
              TileLayerWidget(
                  options: TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'])),
            ],
          ),
        );
      },
    );
  }
}
