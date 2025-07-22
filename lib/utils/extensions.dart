import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:models/models.dart';

extension ContextExt on WidgetRef {
  StorageNotifier get storage => read(storageNotifierProvider.notifier);
}
