import 'package:frontend/Core/network/dio_client.dart';
import 'package:frontend/Core/storage/token_storage.dart';
import 'package:frontend/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:frontend/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:frontend/features/cart/domain/repositories/cart_repository.dart';
import 'package:frontend/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:frontend/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:frontend/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:frontend/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:frontend/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:frontend/features/menu/domain/repositories/menu_repository.dart';
import 'package:frontend/features/menu/domain/usecases/get_menu_categories_usecase.dart';
import 'package:frontend/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:frontend/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:frontend/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:frontend/features/orders/domain/repositories/orders_repository.dart';
import 'package:frontend/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:frontend/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:frontend/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:frontend/features/authentication/domain/usecases/login_usecase.dart';
import 'package:frontend/features/authentication/domain/usecases/register_usecase.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:frontend/features/notifications/data/datasources/notification_remote_data_source_impl.dart';
import 'package:frontend/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:frontend/features/notifications/domain/repositories/notification_repository.dart';
import 'package:frontend/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:frontend/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:frontend/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:frontend/features/notifications/domain/usecases/mark_all_as_read_usecase.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Core
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt<TokenStorage>()));

  // Authentication
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>(), getIt<TokenStorage>()),
  );


  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  getIt.registerLazySingleton<RegisterUsecase>(
    () => RegisterUsecase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      getIt<RegisterUsecase>(),
      getIt<LoginUsecase>(),
      getIt<AuthRepository>(),
    ),
  );

  getIt<DioClient>().onSessionExpired = () {
    getIt<AuthCubit>().logout();
  };

  // Menu
  getIt.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<GetMenuCategoriesUseCase>(
    () => GetMenuCategoriesUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetCartItemsUseCase>(
    () => GetCartItemsUseCase(getIt()),
  );

  getIt.registerLazySingleton<UpdateCartItemQuantityUseCase>(
    () => UpdateCartItemQuantityUseCase(getIt()),
  );

  getIt.registerLazySingleton<RemoveCartItemUseCase>(
    () => RemoveCartItemUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(getIt()),
  );

  getIt.registerFactory<MenuCubit>(
    () => MenuCubit(getIt()),
  );

  getIt.registerFactory<CartCubit>(
    () => CartCubit(
      getIt(),
      getIt(),
      getIt(),
    ),
  );

  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(getIt()),
  );

  // Notifications
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt<NotificationRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerLazySingleton<GetUnreadCountUseCase>(
    () => GetUnreadCountUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerLazySingleton<MarkNotificationAsReadUseCase>(
    () => MarkNotificationAsReadUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerLazySingleton<MarkAllAsReadUseCase>(
    () => MarkAllAsReadUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(
      getIt<GetNotificationsUseCase>(),
      getIt<MarkNotificationAsReadUseCase>(),
      getIt<MarkAllAsReadUseCase>(),
    ),
  );

  getIt.registerFactory<NotificationBadgeCubit>(
    () => NotificationBadgeCubit(getIt<GetUnreadCountUseCase>()),
  );
}
