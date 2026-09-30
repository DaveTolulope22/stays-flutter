import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _screen(BuildContext context, GoRouterState state) => const SizedBox();

GoRoute _route(String path) => GoRoute(path: path, builder: _screen);

FeatureModule _module(
  String id, {
  AccessArea area = AccessArea.guest,
  String? basePath,
  List<RouteBase>? routes,
  NavTab? tab,
  bool Function(Capabilities)? requires,
}) {
  final base = basePath ?? '/$id';
  return FeatureModule(
    id: id,
    area: area,
    basePath: base,
    routes: routes ?? [_route(base)],
    tab: tab,
    requires: requires,
  );
}

const _guest = Capabilities(area: AccessArea.guest);
const _host = Capabilities(area: AccessArea.host);

void main() {
  group('owns', () {
    final module = _module('saved');

    test('its base path and paths below it', () {
      expect(module.owns('/saved'), isTrue);
      expect(module.owns('/saved/'), isTrue);
      expect(module.owns('/saved/42'), isTrue);
      expect(module.owns('/saved/42/details'), isTrue);
    });

    test('a query string does not matter', () {
      expect(module.owns('/saved?sort=new'), isTrue);
      expect(module.owns('/saved/42?x=1&y=2'), isTrue);
    });

    test('not a sibling that merely starts with the same letters', () {
      expect(module.owns('/saved-items'), isFalse);
      expect(module.owns('/savedX'), isFalse);
    });

    test('not another section, the root, or a parent', () {
      expect(module.owns('/browse'), isFalse);
      expect(module.owns('/'), isFalse);
      expect(_module('a', basePath: '/a/b').owns('/a'), isFalse);
    });

    test('a query string containing the path does not fool it', () {
      expect(module.owns('/browse?next=/saved'), isFalse);
    });
  });

  group('isAllowedFor', () {
    test('only for the module\'s own area', () {
      final guestModule = _module('browse');
      final hostModule = _module('host', area: AccessArea.host);
      final publicModule = _module('sign-in', area: AccessArea.none);

      expect(guestModule.isAllowedFor(_guest), isTrue);
      expect(guestModule.isAllowedFor(_host), isFalse);
      expect(guestModule.isAllowedFor(Capabilities.none), isFalse);

      expect(hostModule.isAllowedFor(_host), isTrue);
      expect(hostModule.isAllowedFor(_guest), isFalse);
      expect(hostModule.isAllowedFor(Capabilities.none), isFalse);

      // "none" means reachable only while signed out.
      expect(publicModule.isAllowedFor(Capabilities.none), isTrue);
      expect(publicModule.isAllowedFor(_guest), isFalse);
      expect(publicModule.isAllowedFor(_host), isFalse);
    });

    test('an extra requirement must pass as well', () {
      final module = _module('saved', requires: (c) => c.canSaveListings);

      expect(module.isAllowedFor(_guest), isFalse);
      expect(
        module.isAllowedFor(
          const Capabilities(area: AccessArea.guest, canSaveListings: true),
        ),
        isTrue,
      );
    });

    test('the requirement cannot widen the area', () {
      final module = _module('saved', requires: (_) => true);

      expect(module.isAllowedFor(_host), isFalse);
    });
  });

  group('construction', () {
    test('a base path must start with a slash', () {
      expect(
        () => _module('saved', basePath: 'saved', routes: []),
        throwsAssertionError,
      );
    });

    test('a base path of just "/" is rejected', () {
      expect(
        () => _module('root', basePath: '/', routes: []),
        throwsAssertionError,
      );
    });

    test('a route outside the base path is rejected', () {
      expect(
        () => _module('saved', routes: [_route('/saved'), _route('/other')]),
        throwsAssertionError,
      );
    });

    test('a sibling-looking route is rejected', () {
      expect(
        () => _module('saved', routes: [_route('/saved-items')]),
        throwsAssertionError,
      );
    });

    test('routes at and below the base path are accepted', () {
      final module = _module(
        'saved',
        routes: [_route('/saved'), _route('/saved/archive')],
      );

      expect(module.routes, hasLength(2));
    });

    test('carries its tab', () {
      final module = _module(
        'saved',
        tab: NavTab(label: (_) => 'Saved', icon: Icons.favorite),
      );

      expect(module.tab?.icon, Icons.favorite);
    });
  });

  group('validateModules', () {
    test('accepts distinct modules', () {
      validateModules([_module('browse'), _module('saved'), _module('host')]);
    });

    test('accepts an empty set', () {
      validateModules(const []);
    });

    test('rejects a duplicate id', () {
      expect(
        () => validateModules([
          _module('saved'),
          _module('saved', basePath: '/other'),
        ]),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('saved'),
          ),
        ),
      );
    });

    test('rejects a module nested inside another\'s path', () {
      expect(
        () => validateModules([
          _module('host', area: AccessArea.host),
          _module(
            'calendar',
            area: AccessArea.host,
            basePath: '/host/calendar',
          ),
        ]),
        throwsStateError,
      );
    });

    test('rejects nesting in either order', () {
      expect(
        () => validateModules([
          _module(
            'calendar',
            area: AccessArea.host,
            basePath: '/host/calendar',
          ),
          _module('host', area: AccessArea.host),
        ]),
        throwsStateError,
      );
    });

    test('rejects two modules with the same path', () {
      expect(
        () => validateModules([
          _module('a', basePath: '/same'),
          _module('b', basePath: '/same'),
        ]),
        throwsStateError,
      );
    });

    test('siblings that share a prefix are fine', () {
      validateModules([
        _module('saved'),
        _module('saved-items', basePath: '/saved-items'),
      ]);
    });
  });
}
