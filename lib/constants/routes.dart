class InvalidRouteException implements Exception {
  String path;

  InvalidRouteException(this.path);
}

class SideMenuRoutePaths {
  static const files = '/side-menu/files';
  static const search = '/side-menu/search';
  static const codes = '/side-menu/codes';
  static const notes = '/side-menu/notes';
  static const collaboration = '/side-menu/collaboration';
}

enum SideMenuRoute {
  files,
  search,
  codes,
  notes,
  collaboration;

  factory SideMenuRoute.fromString(String path) {
    switch (path) {
      case SideMenuRoutePaths.files:
        return SideMenuRoute.files;
      case SideMenuRoutePaths.search:
        return SideMenuRoute.files;
      case SideMenuRoutePaths.codes:
        return SideMenuRoute.files;
      case SideMenuRoutePaths.notes:
        return SideMenuRoute.files;
      case SideMenuRoutePaths.collaboration:
        return SideMenuRoute.files;
      default:
        throw InvalidRouteException(path);
    }
  }
}

extension SideMenuRoutePath on SideMenuRoute {
  String get path {
    switch (this) {
      case SideMenuRoute.files:
        return SideMenuRoutePaths.files;
      case SideMenuRoute.search:
        return SideMenuRoutePaths.search;
      case SideMenuRoute.codes:
        return SideMenuRoutePaths.codes;
      case SideMenuRoute.notes:
        return SideMenuRoutePaths.notes;
      case SideMenuRoute.collaboration:
        return SideMenuRoutePaths.collaboration;
    }
  }
}

class MainViewRoutePaths {
  static const none = '/main-view/none';
  static const start = '/main-view/start';
  static const settings = '/main-view/settings';
  static const textEditor = '/main-view/text-editor';
  static const codingEditor = '/main-view/coding-editor';
  static const codingCompare = '/main-view/coding-compare';
  static const codeStats = '/main-view/code-stats';
  static const codeGraph = '/main-view/code-graph';
  static const note = '/main-view/note';
}

enum MainViewRoute {
  none,
  start,
  settings,
  textEditor,
  codingEditor,
  codingCompare,
  codeStats,
  codeGraph,
  note;

  factory MainViewRoute.fromString(String path) {
    switch (path) {
      case MainViewRoutePaths.none:
        return MainViewRoute.none;
      case MainViewRoutePaths.start:
        return MainViewRoute.start;
      case MainViewRoutePaths.settings:
        return MainViewRoute.settings;
      case MainViewRoutePaths.textEditor:
        return MainViewRoute.textEditor;
      case MainViewRoutePaths.codingEditor:
        return MainViewRoute.codingEditor;
      case MainViewRoutePaths.codingCompare:
        return MainViewRoute.codingCompare;
      case MainViewRoutePaths.codeStats:
        return MainViewRoute.codeStats;
      case MainViewRoutePaths.codeGraph:
        return MainViewRoute.codeGraph;
      case MainViewRoutePaths.note:
        return MainViewRoute.note;
      default:
        throw InvalidRouteException(path);
    }
  }
}

extension MainViewRoutePath on MainViewRoute {
  String get path {
    switch (this) {
      case MainViewRoute.none:
        return MainViewRoutePaths.none;
      case MainViewRoute.start:
        return MainViewRoutePaths.start;
      case MainViewRoute.settings:
        return MainViewRoutePaths.settings;
      case MainViewRoute.textEditor:
        return MainViewRoutePaths.textEditor;
      case MainViewRoute.codingEditor:
        return MainViewRoutePaths.codingEditor;
      case MainViewRoute.codingCompare:
        return MainViewRoutePaths.codingCompare;
      case MainViewRoute.codeStats:
        return MainViewRoutePaths.codeStats;
      case MainViewRoute.codeGraph:
        return MainViewRoutePaths.codeGraph;
      case MainViewRoute.note:
        return MainViewRoutePaths.note;
    }
  }
}
