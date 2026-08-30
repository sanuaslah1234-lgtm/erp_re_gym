import 'package:postgres/postgres.dart';

import '../database/postgres_service.dart';
import 'package:erp_software/core/models/customer_model.dart';

class CustomerService {
  final PostgresService postgresService;

  CustomerService(this.postgresService);

  // CREATE
  Future<CustomerModel> createCustomer(
    CustomerModel customer,
  ) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        INSERT INTO customers (
          branch_id,
          name,
          phone,
          email,
          address,
          loyalty_id,
          credit_limit,
          current_balance
        )
        VALUES (
          @branch_id,
          @name,
          @phone,
          @email,
          @address,
          @loyalty_id,
          @credit_limit,
          @current_balance
        )
        RETURNING *
      '''),
      parameters: {
        'branch_id': customer.branchId,
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'loyalty_id': customer.loyaltyId,
        'credit_limit': customer.creditLimit,
        'current_balance': customer.currentBalance,
      },
    );

    return CustomerModel.fromMap(
      result.first.toColumnMap(),
    );
  }

  // GET ALL
  Future<List<CustomerModel>> getCustomers() async {
    final result = await postgresService.connection.execute(
      '''
      SELECT *
      FROM customers
      ORDER BY created_at DESC
      ''',
    );

    return result
        .map(
          (row) => CustomerModel.fromMap(
            row.toColumnMap(),
          ),
        )
        .toList();
  }

  // GET BY ID
  Future<CustomerModel?> getCustomerById(
    String id,
  ) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        SELECT *
        FROM customers
        WHERE id = @id
      '''),
      parameters: {
        'id': id,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return CustomerModel.fromMap(
      result.first.toColumnMap(),
    );
  }

  // UPDATE
  Future<CustomerModel?> updateCustomer(
    String id,
    CustomerModel customer,
  ) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        UPDATE customers
        SET
          branch_id = @branch_id,
          name = @name,
          phone = @phone,
          email = @email,
          address = @address,
          loyalty_id = @loyalty_id,
          credit_limit = @credit_limit,
          current_balance = @current_balance,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'branch_id': customer.branchId,
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'loyalty_id': customer.loyaltyId,
        'credit_limit': customer.creditLimit,
        'current_balance': customer.currentBalance,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    return CustomerModel.fromMap(
      result.first.toColumnMap(),
    );
  }

  // DELETE
  Future<bool> deleteCustomer(
    String id,
  ) async {
    final result = await postgresService.connection.execute(
      Sql.named('''
        DELETE FROM customers
        WHERE id = @id
      '''),
      parameters: {
        'id': id,
      },
    );

    return result.affectedRows > 0;
  }
}
