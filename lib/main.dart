import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:models/models.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:purplebase/purplebase.dart';
import 'package:purplestack/router.dart';
import 'package:purplestack/theme.dart';

void main() {
  runZonedGuarded(() {
    runApp(
      ProviderScope(
        overrides: [
          storageNotifierProvider.overrideWith(
            (ref) => PurplebaseStorageNotifier(ref),
          ),
        ],
        child: const PurplestackApp(),
      ),
    );
  }, errorHandler);

  FlutterError.onError = (details) {
    // Prevents debugger stopping multiple times
    FlutterError.dumpErrorToConsole(details);
    errorHandler(details.exception, details.stack);
  };
}

class PurplestackApp extends ConsumerWidget {
  const PurplestackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = 'Purplestack';
    final theme = ref.watch(themeProvider);

    return switch (ref.watch(appInitializationProvider)) {
      AsyncLoading() => MaterialApp(
        title: title,
        theme: theme,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      ),
      AsyncError(:final error) => MaterialApp(
        title: title,
        theme: theme,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Initialization Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
      _ => MaterialApp.router(
        title: title,
        theme: theme,
        routerConfig: ref.watch(routerProvider),
        debugShowCheckedModeBanner: false,
        builder: (_, child) => child!,
      ),
    };
  }
}

class PurplestackHome extends StatelessWidget {
  const PurplestackHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rocket_launch,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Purplestack',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Nostr-enabled Flutter development stack',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void errorHandler(Object exception, StackTrace? stack) {
  // TODO: Implement proper error handling
  debugPrint('Error: $exception');
  debugPrint('Stack trace: $stack');
}

final appInitializationProvider = FutureProvider<void>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  await ref.read(
    initializationProvider(
      StorageConfiguration(
        databasePath: path.join(dir.path, 'purplestack.db'),
        relayGroups: {
          'default': {
            'wss://relay.damus.io',
            'wss://relay.primal.net',
            'wss://nos.lol',
          },
        },
        defaultRelayGroup: 'default',
      ),
    ).future,
  );
});
