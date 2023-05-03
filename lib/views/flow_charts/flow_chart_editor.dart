import 'package:flutter/foundation.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter/material.dart';

class FlowChartEditorView extends StatefulWidget {
  const FlowChartEditorView({
    Key? key,
  }) : super(key: key);

  @override
  State<FlowChartEditorView> createState() => _FlowChartEditorViewState();
}

class _FlowChartEditorViewState extends State<FlowChartEditorView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Dashboard();

    return Expanded(
      child: FlowChart(
        dashboard: dashboard,
        onDashboardTapped: (context, position) {
          if (kDebugMode) {
            print('TODO: onDashboardTapped');
          }
        },
        onDashboardLongtTapped: (context, position) {
          if (kDebugMode) {
            print('TODO: onDashboardLongtTapped');
          }
        },
        onElementLongPressed: (context, position, element) {
          if (kDebugMode) {
            print('TODO: onElementLongPressed');
          }
        },
        onElementPressed: (context, position, element) {
          if (kDebugMode) {
            print('TODO: onElementPressed');
          }
        },
        onHandlerPressed: (context, position, handler, element) {
          if (kDebugMode) {
            print('TODO: onHandlerPressed');
          }
        },
        onHandlerLongPressed: (context, position, handler, element) {
          if (kDebugMode) {
            print('TODO: onHandlerLongPressed');
          }
        },
      ),
    );
  }
}
