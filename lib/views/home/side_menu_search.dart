import 'dart:async';

import 'package:analysis_tool/constants/keys.dart';
import 'package:analysis_tool/constants/routes.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:flutter/material.dart';

class SideMenuSearch extends StatefulWidget {
  const SideMenuSearch({Key? key}) : super(key: key);

  @override
  State<SideMenuSearch> createState() => _SideMenuSearchState();
}

class _SideMenuSearchState extends State<SideMenuSearch> {
  final _projectService = ProjectService();
  StreamSubscription<TextSearchResult>? _searchResultSubscription;
  final List<TextSearchResult> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _searchResultSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Wyszukaj',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _results.clear();
                      });
                    } else {
                      _search(value);
                    }
                  },
                ),
              ),
              if (_searching)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final result = _results[index];
              return ListTile(
                dense: true,
                leading: Text(
                  '${result.file.name}:${result.line}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  result.file.textLines[result.line].substring(result.start),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                  ),
                ),
                onTap: () {
                  mainViewNavigatorKey.currentState!.pushReplacementNamed(
                    MainViewRoutes.textEditor,
                    arguments: <dynamic>[result.file, result.line],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _search(String text) {
    _searchResultSubscription?.cancel();
    setState(() {
      _results.clear();
      _searching = true;
    });
    final result = _projectService.searchText(text);
    _searchResultSubscription = result.listen(
      (event) {
        setState(() {
          _results.add(event);
        });
      },
      onDone: () {
        setState(() {
          _searching = false;
        });
      },
    );
  }
}
