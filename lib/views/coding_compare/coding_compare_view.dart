import 'dart:math';

import 'package:qdamono/constants/keys.dart';
import 'package:qdamono/constants/routes.dart';
import 'package:qdamono/helpers/coding_view.dart';
import 'package:qdamono/models/observable.dart';
import 'package:qdamono/models/text_coding.dart';
import 'package:qdamono/models/text_coding_version.dart';
import 'package:qdamono/services/project/project_service.dart';
import 'package:flutter/material.dart';

class CodingCompareView extends StatefulWidget {
  final TextCodingVersion firstVersion;
  final TextCodingVersion secondVersion;

  const CodingCompareView({
    Key? key,
    required this.firstVersion,
    required this.secondVersion,
  }) : super(key: key);

  @override
  State<CodingCompareView> createState() => _CodingCompareViewState();
}

class _CodingCompareViewState extends State<CodingCompareView> {
  final enabledCodingsFactor = Observable<int?>(90);
  final enabledCodingsFirst = <Observable<Set<EnabledCoding>>>[];
  final enabledCodingsSecond = <Observable<Set<EnabledCoding>>>[];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.firstVersion.codingLines.value.length; i++) {
      enabledCodingsFirst.add(Observable({}));
      enabledCodingsSecond.add(Observable({}));
    }
    _enableCodings(enabledCodingsFactor.value! / 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40.0,
          color: Theme.of(context).primaryColorLight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                widget.firstVersion.name.observe((firstName) {
                  return widget.secondVersion.name.observe((secondName) {
                    return Text(
                      'Porównywanie: $firstName z $secondName',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodyText2!
                          .copyWith(fontWeight: FontWeight.bold),
                    );
                  });
                }),
                const SizedBox(width: 20.0),
                TextButton.icon(
                  icon: const Icon(Icons.merge),
                  label: Text(
                    'Połącz',
                    style: Theme.of(context).primaryTextTheme.button,
                  ),
                  onPressed: _merge,
                ),
                const Spacer(),
                Text(
                  'Zaznacz kody:',
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                ),
                const SizedBox(width: 10.0),
                enabledCodingsFactor.observe((value) {
                  return DropdownButton<int>(
                    value: value,
                    hint: const Text('Własne'),
                    style: Theme.of(context).primaryTextTheme.bodyText2,
                    dropdownColor: Theme.of(context).primaryColor,
                    items: [
                      const DropdownMenuItem(
                        value: 0,
                        child: Text('Wszystkie'),
                      ),
                      const DropdownMenuItem(
                        value: 110,
                        child: Text('Żadne'),
                      ),
                      const DropdownMenuItem(
                        value: 100,
                        child: Text('Pokrywające się w 100%'),
                      ),
                      for (int i = 90; i > 0; i -= 10)
                        DropdownMenuItem(
                          value: i,
                          child: Text('Pokrywające się w min. $i%'),
                        ),
                    ],
                    onChanged: (value) {
                      enabledCodingsFactor.value = value;
                      if (value != null) {
                        _enableCodings(value / 100.0);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).canvasColor,
            child: ListView.separated(
              key: UniqueKey(),
              itemCount: widget.firstVersion.codingLines.value.length,
              itemBuilder: (context, index) {
                final first = widget.firstVersion.codingLines.value[index];
                final second = widget.secondVersion.codingLines.value[index];
                return _CodingCompareLine(
                  codingLineFirst: first,
                  enabledCodingsFirst: enabledCodingsFirst[index],
                  codingLineSecond: second,
                  enabledCodingsSecond: enabledCodingsSecond[index],
                  onChange: () {
                    enabledCodingsFactor.value = null;
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
              padding: const EdgeInsets.symmetric(vertical: 10.0),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _enableCodings(double factor) async {
    for (final codings in enabledCodingsFirst) {
      codings.value.clear();
      codings.notify();
    }
    for (final codings in enabledCodingsSecond) {
      codings.value.clear();
      codings.notify();
    }
    if (factor > 1.0) {
      return;
    }
    for (int i = 0; i < widget.firstVersion.codingLines.value.length; i++) {
      final first = widget.firstVersion.codingLines.value[i].codings.value;
      final second = widget.secondVersion.codingLines.value[i].codings.value;
      if (factor == 0.0) {
        enabledCodingsFirst[i].value.addAll(first.map((e) => EnabledCoding(e)));
        enabledCodingsSecond[i]
            .value
            .addAll(second.map((e) => EnabledCoding(e)));
      } else {
        for (final a in first) {
          final intersecting = second.where((c) {
            return a.code == c.code && a.start < c.end && c.start < a.end;
          });
          for (final b in intersecting) {
            final minS = min(a.start, b.start).toDouble();
            final maxS = max(a.start, b.start).toDouble();
            final minE = min(a.end, b.end).toDouble();
            final maxE = max(a.end, b.end).toDouble();
            if ((minE - maxS) / (maxE - minS) >= factor) {
              enabledCodingsFirst[i].value.add(EnabledCoding(a));
              enabledCodingsSecond[i].value.add(EnabledCoding(b));
            }
          }
        }
      }
    }
  }

  Future<void> _merge() async {
    final version = TextCodingVersion.withId(
      name: '${widget.firstVersion.name.value} - '
          '${widget.secondVersion.name.value}',
      file: widget.firstVersion.file,
    );
    for (int i = 0; i < enabledCodingsFirst.length; i++) {
      for (final enabledCoding in enabledCodingsFirst[i].value) {
        ProjectService().addNewCoding(
          version,
          version.codingLines.value[i],
          enabledCoding.coding!.code,
          enabledCoding.coding!.start -
              version.codingLines.value[i].textLine.offset,
          enabledCoding.coding!.length,
          sendToServer: false,
        );
      }
      for (final enabledCoding in enabledCodingsSecond[i].value) {
        ProjectService().addNewCoding(
          version,
          version.codingLines.value[i],
          enabledCoding.coding!.code,
          enabledCoding.coding!.start -
              version.codingLines.value[i].textLine.offset,
          enabledCoding.coding!.length,
          sendToServer: false,
        );
      }
    }
    ProjectService().addCodingVersion(version);
    mainViewNavigatorKey.currentState!
        .pushReplacementNamed(MainViewRoutes.codingEditor, arguments: version);
  }
}

class _CodingCompareLine extends StatefulWidget {
  final TextCodingLine codingLineFirst;
  final Observable<Set<EnabledCoding>> enabledCodingsFirst;
  final TextCodingLine codingLineSecond;
  final Observable<Set<EnabledCoding>> enabledCodingsSecond;
  final void Function()? onChange;

  const _CodingCompareLine({
    Key? key,
    required this.codingLineFirst,
    required this.enabledCodingsFirst,
    required this.codingLineSecond,
    required this.enabledCodingsSecond,
    this.onChange,
  }) : super(key: key);

  @override
  State<_CodingCompareLine> createState() => _CodingCompareLineState();
}

class _CodingCompareLineState extends State<_CodingCompareLine> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              '${widget.codingLineFirst.textLine.index + 1}',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Expanded(
            child: widget.codingLineFirst.codings.observe((codings) {
              return widget.enabledCodingsFirst.observe((enabledCodings) {
                return RichText(
                  text: TextSpan(
                    children: makeTextCodingSpans(
                      widget.codingLineFirst.textLine.text,
                      widget.codingLineFirst.textLine.offset,
                      widget.codingLineFirst.codings.value,
                      enabledCodings,
                    ),
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                );
              });
            }),
          ),
          Container(
            width: 200.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Wrap(
              spacing: 2.0,
              runSpacing: 2.0,
              children: widget.codingLineFirst.codings.value.map((coding) {
                return _CodingButton(
                  coding: coding,
                  enabledCodings: widget.enabledCodingsFirst,
                  onChange: widget.onChange,
                );
              }).toList(),
            ),
          ),
          const VerticalDivider(),
          Container(
            width: 200.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Wrap(
              spacing: 2.0,
              runSpacing: 2.0,
              children: widget.codingLineSecond.codings.value.map((coding) {
                return _CodingButton(
                  coding: coding,
                  enabledCodings: widget.enabledCodingsSecond,
                  onChange: widget.onChange,
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: widget.codingLineSecond.codings.observe((codings) {
              return widget.enabledCodingsSecond.observe((enabledCodings) {
                return RichText(
                  text: TextSpan(
                    children: makeTextCodingSpans(
                      widget.codingLineSecond.textLine.text,
                      widget.codingLineSecond.textLine.offset,
                      codings,
                      enabledCodings,
                    ),
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                );
              });
            }),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _CodingButton extends StatelessWidget {
  final TextCoding coding;
  final Observable<Set<EnabledCoding>> enabledCodings;
  final void Function()? onChange;

  const _CodingButton({
    Key? key,
    required this.coding,
    required this.enabledCodings,
    this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return coding.code.color.observe((color) {
      return enabledCodings.observe((enabledCodings) {
        bool shouldEnable = enabledCodings.any((e) => e.shouldEnable(coding));
        return Container(
          decoration: BoxDecoration(
            color: shouldEnable ? color : Colors.grey,
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: TextButton(
            onPressed: () {
              if (shouldEnable) {
                enabledCodings.remove(EnabledCoding(coding));
                this.enabledCodings.notify();
              } else {
                enabledCodings.add(EnabledCoding(coding));
                this.enabledCodings.notify();
              }
              onChange?.call();
            },
            child: coding.code.name.observe((name) {
              return Text(
                name,
                style: Theme.of(context).textTheme.bodyText2,
                overflow: TextOverflow.ellipsis,
              );
            }),
          ),
        );
      });
    });
  }
}
