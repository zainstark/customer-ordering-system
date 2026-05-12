import 'package:frontend/Core/network/dio_client.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register DioClient as a singleton
  getIt.registerSingleton<DioClient>(DioClient());
}
