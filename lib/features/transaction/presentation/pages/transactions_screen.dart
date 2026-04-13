import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/widgets/primary_app_bar.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:cashify/features/shared/widgets/compact_transaction_row.dart';
import 'package:cashify/features/shared/widgets/transaction_filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String? _lastPeriodSynced;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().clearFilters();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final billingPeriodProv = context.watch<BillingPeriodProvider>();
    final transactionProv = context.read<TransactionProvider>();
    final activeId = billingPeriodProv.selectedBillingPeriodId;

    if (_lastPeriodSynced != activeId) {
      _lastPeriodSynced = activeId;
      Future.microtask(() => transactionProv.loadDataByBillingPeriod(activeId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: "Historial",
        actions: [
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              final hasFilters =
                  provider.filterCategoryId != null ||
                  provider.filterPaymentMethodId != null ||
                  provider.filterType != null ||
                  provider.filterIsCompleted != null;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_alt),
                    tooltip: "Filtros",
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => TransactionFilterBottomSheet(
                          categories: provider.categories,
                          paymentMethods: provider.paymentMethods,
                          initialCategoryId: provider.filterCategoryId,
                          initialPaymentMethodId:
                              provider.filterPaymentMethodId,
                          initialType: provider.filterType,
                          initialIsCompleted: provider.filterIsCompleted,
                          onApply:
                              ({
                                categoryId,
                                paymentMethodId,
                                type,
                                isCompleted,
                                frequency,
                              }) {
                                provider.setFilters(
                                  categoryId: categoryId,
                                  paymentMethodId: paymentMethodId,
                                  type: type,
                                  isCompleted: isCompleted,
                                );
                              },
                        ),
                      );
                    },
                  ),
                  if (hasFilters)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.notification,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final transactions = provider.pagedFilteredTransactions;
                final allFiltered = provider.filteredTransactions;
                final bool hasMore = transactions.length < allFiltered.length;

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text("No se encontraron movimientos"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: transactions.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == transactions.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () => provider.loadNextPage(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Cargar más"),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.05,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final transaction = transactions[index];
                    return CompactTransactionRow(
                      transaction: transaction,
                      provider: provider,
                      showStatusIcon: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Buscar...",
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          context.read<TransactionProvider>().setSearchQuery(value);
        },
      ),
    );
  }
}
