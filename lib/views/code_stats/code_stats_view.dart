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

  @override
  Widget build(BuildContext context) {
    final project = projectService.project.value;
    if (project == null) {
      return Container();
    }
    return FutureBuilder<
        Map<Code, Map<TextFile, Map<TextCodingVersion, List<CodeStats>>>>>(
      future: projectService.getGroupedCodeStats(),
      initialData: const {},
      builder: (context, snap) {
        switch (snap.connectionState) {
          case ConnectionState.done:
            final stats = snap.data;
            if (stats != null) {
              return Column(
                children: [
                  Container(
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.analytics, size: 20.0),
                          label: const Text('Eksportuj do pliku CSV'),
                          onPressed: () async {
                            await projectService.saveCodeStatsAsCSV();
                          },
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  Expanded(child: _makeCodeStatsList(stats)),
                ],
              );
            }
            return Container();
          default:
            return const CircularProgressIndicator();
        }
      },
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
              style: const TextStyle(color: Colors.white),
            );
          }),
          children: [
            Container(
              color: const Color.fromARGB(0xff, 0xee, 0xee, 0xee),
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
                    tileColor: Colors.black,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    dense: true,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                          '${textFile.name.value} (Liczba wersji: ${versionStats.length})'),
                      backgroundColor:
                          const Color.fromARGB(0xff, 0xee, 0xee, 0xee),
                      collapsedBackgroundColor:
                          const Color.fromARGB(0xff, 0xee, 0xee, 0xee),
                      children: versionStats
                          .map((version, lines) {
                            final w = ExpansionTile(
                              initiallyExpanded: true,
                              leading: Text(textFile.name.value),
                              title: Text(
                                  '${version.name.value} (Liczba wystąpień: ${lines.length})'),
                              children: lines.map((s) {
                                return Container(
                                  color: const Color.fromARGB(
                                      0xff, 0xee, 0xee, 0xee),
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
                                      SizedBox(
                                        width: 50.0,
                                        child: Text('${s.line + 1}'),
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
