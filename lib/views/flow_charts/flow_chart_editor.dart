import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter/material.dart';
import 'package:qdamono/helpers/element_setting_menu.dart';
import 'package:qdamono/helpers/text_menu.dart';
import 'package:qdamono/services/project/project_service_exceptions.dart';
import 'package:star_menu/star_menu.dart';
import 'package:qdamono/helpers/desktop_saver.dart'
    if (dart.library.html) 'package:qdamono/helpers/web_saver.dart' as saver;

class FlowchartEditorView extends StatefulWidget {
  const FlowchartEditorView({
    Key? key,
  }) : super(key: key);

  @override
  State<FlowchartEditorView> createState() => _FlowchartEditorViewState();
}

class _FlowchartEditorViewState extends State<FlowchartEditorView> {
  Dashboard dashboard = Dashboard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: FlowChart(
        dashboard: dashboard,
        onDashboardTapped: (context, position) {
          if (kDebugMode) {
            print('onDashboardTapped, $position');
          }
          _displayDashboardMenu(context, position);
        },
        onDashboardLongtTapped: (context, position) {
          if (kDebugMode) {
            print('onDashboardLongtTapped, $position');
          }
        },
        onElementLongPressed: (context, position, element) {
          if (kDebugMode) {
            print('onElementLongPressed, $position');
          }
        },
        onElementPressed: (context, position, element) {
          if (kDebugMode) {
            print('onElementPressed, $position');
          }
          _displayElementMenu(context, position, element);
        },
        onHandlerPressed: (context, position, handler, element) {
          if (kDebugMode) {
            print('onHandlerPressed, $position');
          }
          _displayHandlerMenu(position, handler, element);
        },
        onHandlerLongPressed: (context, position, handler, element) {
          if (kDebugMode) {
            print('onHandlerLongPressed, $position');
          }
        },
      ),
    );
  }

  _displayHandlerMenu(
    Offset position,
    Handler handler,
    FlowElement element,
  ) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            space: 10,
          ),
          onHoverScale: 1.1,
          useTouchAsCenter: true,
          centerOffset: position -
              Offset(
                dashboard.dashboardSize.width / 2,
                dashboard.dashboardSize.height / 2,
              ),
        ),
        onItemTapped: (index, controller) => controller.closeMenu!(),
        items: [
          FloatingActionButton(
            child: const Icon(Icons.delete),
            onPressed: () =>
                dashboard.removeElementConnection(element, handler),
          )
        ],
        parentContext: context,
      ),
    );
  }

  _displayElementMenu(
    BuildContext context,
    Offset position,
    FlowElement element,
  ) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            alignment: LinearAlignment.left,
            space: 10,
          ),
          onHoverScale: 1.1,
          centerOffset: position - const Offset(50, 0),
          backgroundParams: const BackgroundParams(
            backgroundColor: Colors.transparent,
          ),
          boundaryBackground: BoundaryBackground(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
              boxShadow: kElevationToShadow[6],
            ),
          ),
        ),
        onItemTapped: (index, controller) {
          if (!(index == 5 || index == 2)) {
            controller.closeMenu!();
          }
        },
        items: [
          Text(
            element.text,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          InkWell(
            onTap: () => dashboard.removeElement(element),
            child: const Text('Delete'),
          ),
          TextMenu(element: element),
          InkWell(
            onTap: () {
              dashboard.removeElementConnections(element);
            },
            child: const Text('Remove all connections'),
          ),
          InkWell(
            onTap: () {
              dashboard.setElementResizable(element, true);
            },
            child: const Text('Resize'),
          ),
          ElementSettingsMenu(
            element: element,
          ),
        ],
        parentContext: context,
      ),
    );
  }

  _displayDashboardMenu(BuildContext context, Offset position) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            alignment: LinearAlignment.left,
            space: 10,
          ),
          // calculate the offset from the dashboard center
          centerOffset: position -
              Offset(
                dashboard.dashboardSize.width / 2,
                dashboard.dashboardSize.height / 2,
              ),
        ),
        onItemTapped: (index, controller) => controller.closeMenu!(),
        parentContext: context,
        items: [
          ActionChip(
              label: const Text('Add diamond'),
              onPressed: () {
                dashboard.addElement(FlowElement(
                    position: position - const Offset(40, 40),
                    size: const Size(80, 80),
                    text: '${dashboard.elements.length}',
                    kind: ElementKind.diamond,
                    handlers: [
                      Handler.bottomCenter,
                      Handler.topCenter,
                      Handler.leftCenter,
                      Handler.rightCenter,
                    ]));
              }),
          ActionChip(
              label: const Text('Add rect'),
              onPressed: () {
                dashboard.addElement(FlowElement(
                    position: position - const Offset(50, 25),
                    size: const Size(100, 50),
                    text: '${dashboard.elements.length}',
                    kind: ElementKind.rectangle,
                    handlers: [
                      Handler.bottomCenter,
                      Handler.topCenter,
                      Handler.leftCenter,
                      Handler.rightCenter,
                    ]));
              }),
          ActionChip(
              label: const Text('Add oval'),
              onPressed: () {
                dashboard.addElement(FlowElement(
                    position: position - const Offset(50, 25),
                    size: const Size(100, 50),
                    text: '${dashboard.elements.length}',
                    kind: ElementKind.oval,
                    handlers: [
                      Handler.bottomCenter,
                      Handler.topCenter,
                      Handler.leftCenter,
                      Handler.rightCenter,
                    ]));
              }),
          ActionChip(
              label: const Text('Add parallelogram'),
              onPressed: () {
                dashboard.addElement(FlowElement(
                    position: position - const Offset(50, 25),
                    size: const Size(100, 50),
                    text: '${dashboard.elements.length}',
                    kind: ElementKind.parallelogram,
                    handlers: [
                      Handler.bottomCenter,
                      Handler.topCenter,
                    ]));
              }),
          ActionChip(
              label: const Text('Remove all'),
              onPressed: () {
                dashboard.removeAllElements();
              }),
          ActionChip(
              label: const Text('Save flowchart'),
              onPressed: () async {
                saveFlowchart();
                // Directory appDocDir =
                //     await path.getApplicationDocumentsDirectory();
                // dashboard.saveDashboard('${appDocDir.path}/FLOWCHART.json');
              }),
          ActionChip(
              label: const Text('Load flowchart'),
              onPressed: () async {
                loadFlowchart();
                // Directory appDocDir =
                //     await path.getApplicationDocumentsDirectory();
                // dashboard.loadDashboard('${appDocDir.path}/FLOWCHART.json');
              }),
        ],
      ),
    );
  }

  Future<bool> saveFlowchart() async {
    if (kIsWeb) {
      await saver.save(
        'flowchart.json',
        dashboard.toJson(),
      );
      return true;
    }

    final path = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (path != null) {
      await saver.save(path, dashboard.toJson());
      return true;
    }

    return false;
  }

  Future<bool> loadFlowchart() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.first.path != null) {
      try {
        dashboard.loadDashboard(result.files.first.path!);
        return true;
      } catch (e) {
        if (kDebugMode) {
          print('Open flowchart: $e');
        }
        throw InvalidFileError();
      }
    }

    return false;
  }
}
