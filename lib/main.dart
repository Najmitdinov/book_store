import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'data/local/local_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/store_repositories.dart';
import 'state/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final storage = await LocalStorage.create();
  final auth = AuthProvider(
    authRepository: AuthRepository(),
    storage: storage,
  );
  final api = ApiClient(tokenProvider: auth.validToken);
  final services = AppServices(
    storage: storage,
    books: BookRepository(api),
    wishlist: WishlistRepository(api),
    orders: OrderRepository(api),
    profile: ProfileRepository(api),
    shelves: ShelfRepository(api),
    reviews: ReviewRepository(api),
    promo: PromoRepository(api),
  );
  auth.profileRepository = services.profile;

  runApp(BookStoreApp(auth: auth, services: services));
}
