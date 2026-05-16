import 'package:frontend/Core/network/dio_client.dart';
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
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Authentication
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>()),
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

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      getIt<RegisterUsecase>(),
      getIt<LoginUsecase>(),
      getIt<AuthRepository>(),
    ),
  );

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
    () => MenuCubit(getMenuCategoriesUseCase: getIt()),
  );

  getIt.registerFactory<CartCubit>(
    () => CartCubit(
      getCartItemsUseCase: getIt(),
      updateCartItemQuantityUseCase: getIt(),
      removeCartItemUseCase: getIt(),
    ),
  );

  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(getOrdersUseCase: getIt()),
  );
}
