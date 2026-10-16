import '../data/repositories/coustomer_repository.dart';
import '../network/odooClint.dart';
import '../data/remote/auth_remote_data.dart';
import '../data/remote/sales_remote_data.dart';
import '../data/repositories/sales_repository.dart';
import 'package:mobile_developer_task/core/data/remote/customer_remote_data.dart';

class AppDependencies {
  static late Odooclint odooClient;

  static late SalesRepository salesRepository;
  static late  CustomerRepository customerRepository;

  static void initialize({
    required Odooclint authenticatedClient,
  }) {
    odooClient = authenticatedClient;

    final authRemote = AuthRemoteDataSource(odooClient);

    salesRepository = SalesRepository(
      salesRemoteDataSource: SalesRemoteDataSource(odooClient),
      authRemoteDataSource: authRemote,
    );

    customerRepository = CustomerRepository(
      customerRemoteDataSource: CoustmetRemoteDataSource (odooClient),
    );
  }
}