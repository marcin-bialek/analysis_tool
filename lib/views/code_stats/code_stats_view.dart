import 'package:analysis_tool/models/code.dart';
import 'package:analysis_tool/models/text_coding_version.dart';
import 'package:analysis_tool/models/text_file.dart';
import 'package:analysis_tool/services/project/project_service.dart';
import 'package:flutter/material.dart';

class CodeStatsView extends StatefulWidget {
  const CodeStatsView({Key? key}) : super(key: key);

  @override
  State<CodeStatsView> createState() => _CodeStatsViewState();
}

class _CodeStatsViewState extends State<CodeStatsView> {
  final projectService = ProjectService();
  bool groupAdjacentLines = true;

  @override
  Widget build(BuildContext context) {
    final project = projectService.project.value;
    if (project == null) {
      return Container();
    }
    return Column(
      children: [
        Container(
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              const Spacer(),
              Checkbox(
                value: groupAdjacentLines,
                onChanged: (value) {
                  setState(() {
                    groupAdjacentLines = value ?? true;
                  });
                },
              ),
              Text(
                'Grupuj kody w przyległych liniach',
                style: Theme.of(context).primaryTextTheme.bodyText2,
              ),
              const SizedBox(width: 20.0),
              TextButton.icon(
                icon: const Icon(Icons.analytics, size: 20.0),
                label: const Text('Eksportuj do pliku CSV'),
                onPressed: () async {
                  await projectService.saveCodeStatsAsCSV(
                    groupAdjacentLines: groupAdjacentLines,
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<
              Map<Code,
                  Map<TextFile, Map<TextCodingVersion, List<CodeStats>>>>>(
            future: projectService.getGroupedCodeStats(
              groupAdjacentLines: groupAdjacentLines,
            ),
            initialData: const {},
            builder: (context, snap) {
              switch (snap.connectionState) {
                case ConnectionState.done:
                  final stats = snap.data;
                  if (stats != null) {
                    return _makeCodeStatsList(stats);
                  }
                  return Container();
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _makeCodeStatsList(
      Map<Code, Map<TextFile, Map<TextCodingVersion, List<CodeStats>>>> stats) {
    return ListView.builder(
      itemCount: stats.keys.length,
      itemBuilder: (context, index) {
        final code = stats.keys.elementAt(index);
        final fileStats = stats.values.elementAt(index);
        return ExpansionTile(
          leading: code.color.observe((color) {
            return Icon(
              Icons.circle,
              color: color,
              size: 20.0,
            );
          }),
          title: code.name.observe((name) {
            return Text(
              '$name (liczba plików: ${fileStats.length})',
              style: Theme.of(context).primaryTextTheme.bodyText2,
            );
          }),
          initiallyExpanded: true,
          children: [
            Container(
              color: Theme.of(context).canvasColor,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: const [
                  SizedBox(
                    width: 100.0,
                    child: Text(
                      'Plik',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 100.0,
                    child: Text(
                      'Kodowanie',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 50.0,
                    child: Text(
                      'Linia',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Tekst',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            ...fileStats
                .map((textFile, versionStats) {
                  final w = ListTileTheme(
                    tileColor: Theme.of(context).primaryColor,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    dense: true,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                          '${textFile.name.value} (Liczba wersji: ${versionStats.length})'),
                      backgroundColor: Theme.of(context).canvasColor,
                      collapsedBackgroundColor: Theme.of(context).canvasColor,
                      children: versionStats
                          .map((version, lines) {
                            final w = ExpansionTile(
                              initiallyExpanded: true,
                              leading: Text(textFile.name.value),
                              title: Text(
                                  '${version.name.value} (Liczba wystąpień: ${lines.length})'),
                              children: lines.map((s) {
                                return Container(
                                  color: Theme.of(context).canvasColor,
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 100.0,
                                        child: Text(s.textFile.name.value),
                                      ),
                                      SizedBox(
                                        width: 100.0,
                                        child: Text(s.codingVersion.name.value),
                                      ),
                                      if (s.startLine == s.endLine)
                                        SizedBox(
                                          width: 50.0,
                                          child: Text('${s.startLine + 1}'),
                                        ),
                                      if (s.startLine != s.endLine)
                                        SizedBox(
                                          width: 50.0,
                                          child: Text(
                                            '${s.startLine + 1}-${s.endLine + 1}',
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(s.text),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                            return MapEntry(version, w);
                          })
                          .values
                          .toList(),
                    ),
                  );
                  return MapEntry(textFile, w);
                })
                .values
                .toList(),
          ],
        );
      },
    );
  }
}
