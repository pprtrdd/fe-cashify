import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/widgets/primary_app_bar.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:cashify/features/frequent/domain/entities/frequent_transaction_entity.dart';
import 'package:cashify/features/frequent/presentation/pages/frequent_form_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/frequent/presentation/providers/frequent_transaction_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:cashify/features/frequent/presentation/widgets/frequent_dialogs.dart';
import 'package:cashify/features/shared/widgets/base_compact_item_row.dart';
import 'package:cashify/features/shared/widgets/transaction_filter_bottom_sheet.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FrequentTransactionsScreen extends StatefulWidget {
  const FrequentTransactionsScreen({super.key});

  @override
  State<FrequentTransactionsScreen> createState() =>
      _FrequentTransactionsScreenState();
}

class _FrequentTransactionsScreenState
    extends State<FrequentTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FrequentTransactionProvider>().loadFrequent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: "Frecuentes",
        showAddButton: true,
        onAddPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FrequentFormScreen()),
        ),
        actions: [
          Consumer<FrequentTransactionProvider>(
            builder: (context, provider, child) {
              final hasFilters =
                  provider.filterCategoryId != null ||
                  provider.filterType != null ||
                  provider.filterStatus != null ||
                  provider.filterFrequency != null;

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
                        builder: (context) {
                          final transactionProv = context
                              .read<TransactionProvider>();
                          return TransactionFilterBottomSheet(
                            categories: transactionProv.categories,
                            paymentMethods: null,
                            initialCategoryId: provider.filterCategoryId,
                            initialPaymentMethodId: null,
                            initialType: provider.filterType,
                            initialFrequency: provider.filterFrequency,
                            showFrequencyFilter: true,
                            initialIsCompleted:
                                provider.filterStatus ==
                                    FrequentStatus.completed
                                ? true
                                : provider.filterStatus ==
                                      FrequentStatus.pending
                                ? false
                                : null,
                            onApply:
                                ({
                                  categoryId,
                                  paymentMethodId,
                                  type,
                                  isCompleted,
                                  frequency,
                                }) {
                                  FrequentStatus? status;
                                  if (isCompleted == true) {
                                    status = FrequentStatus.completed;
                                  } else if (isCompleted == false) {
                                    status = FrequentStatus.pending;
                                  }
                                  provider.setFilters(
                                    categoryId: categoryId,
                                    type: type,
                                    status: status,
                                    frequency: frequency,
                                  );
                                },
                          );
                        },
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
            child: Consumer<FrequentTransactionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.frequents.isEmpty) {
                  return const Center(
                    child: Text("No tienes movimientos frecuentes aún."),
                  );
                }

                final items = _buildListItems(context, provider);

                if (items.isEmpty) {
                  return const Center(
                    child: Text("No se encontraron resultados."),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  children: items,
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
          context.read<FrequentTransactionProvider>().setSearchQuery(value);
        },
      ),
    );
  }

  List<Widget> _buildListItems(
    BuildContext context,
    FrequentTransactionProvider provider,
  ) {
    final billingPeriodProv = context.watch<BillingPeriodProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final transactionProv = context.watch<TransactionProvider>();
    final selectedBillingPeriodId = billingPeriodProv.selectedBillingPeriodId;
    final list = provider.frequents.map((f) {
      final status = provider.getStatus(
        f,
        selectedBillingPeriodId,
        settingsProv.settings.startDay,
        transactionProv.transactions,
      );
      final billingPeriodsAway = provider.getBillingPeriodsAway(
        f,
        selectedBillingPeriodId,
      );
      final noHistory = provider.lastMovePeriodByFrequent[f.id] == null;

      int priority = 100;

      if (status == FrequentStatus.completed) {
        priority = 10;
      } else if (status == FrequentStatus.pending ||
          status == FrequentStatus.overdue) {
        priority = 20;
      } else if (!noHistory) {
        priority = 30;
      } else {
        priority = 40;
      }

      return {
        'frequent': f,
        'status': status,
        'billingPeriodsAway': billingPeriodsAway,
        'noHistory': noHistory,
        'priority': priority,
      };
    }).toList();

    list.sort((a, b) {
      final int pA = a['priority'] as int;
      final int pB = b['priority'] as int;
      if (pA != pB) return pA.compareTo(pB);

      final FrequentTransactionEntity fA =
          a['frequent'] as FrequentTransactionEntity;
      final FrequentTransactionEntity fB =
          b['frequent'] as FrequentTransactionEntity;
      return fA.description.compareTo(fB.description);
    });

    final filteredList = list.where((item) {
      final freq = item['frequent'] as FrequentTransactionEntity;
      final status = item['status'] as FrequentStatus;

      final queryLower = provider.searchQuery.toLowerCase();
      final matchesSearch =
          freq.description.toLowerCase().contains(queryLower) ||
          freq.source.toLowerCase().contains(queryLower) ||
          freq.amount.toString().contains(queryLower);

      final matchesCategory =
          provider.filterCategoryId == null ||
          freq.categoryId == provider.filterCategoryId;

      bool matchesType = true;
      if (provider.filterType == 'income') {
        matchesType = transactionProv.incomeCategoryIds.contains(
          freq.categoryId,
        );
      } else if (provider.filterType == 'expense') {
        matchesType = !transactionProv.incomeCategoryIds.contains(
          freq.categoryId,
        );
      }

      bool matchesStatus = true;
      if (provider.filterStatus != null) {
        if (provider.filterStatus == FrequentStatus.pending) {
          matchesStatus =
              status == FrequentStatus.pending ||
              status == FrequentStatus.overdue;
        } else {
          matchesStatus = status == provider.filterStatus;
        }
      }

      bool matchesFrequency = true;
      if (provider.filterFrequency != null) {
        matchesFrequency = freq.frequency == provider.filterFrequency;
      }

      return matchesSearch &&
          matchesCategory &&
          matchesType &&
          matchesStatus &&
          matchesFrequency;
    }).toList();

    return filteredList.map((item) {
      return _FrequentItemRow(
        frequent: item['frequent'] as FrequentTransactionEntity,
        status: item['status'] as FrequentStatus,
        billingPeriodsAway: item['billingPeriodsAway'] as int?,
        noHistory: item['noHistory'] as bool,
      );
    }).toList();
  }
}

class _FrequentItemRow extends StatelessWidget {
  final FrequentTransactionEntity frequent;
  final FrequentStatus status;
  final int? billingPeriodsAway;
  final bool noHistory;

  const _FrequentItemRow({
    required this.frequent,
    required this.status,
    required this.billingPeriodsAway,
    required this.noHistory,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = _isIncome(context, frequent.categoryId);
    final String categoryName = _getCategoryName(context, frequent.categoryId);
    final Color categoryColor = isIncome ? AppColors.income : AppColors.expense;

    return BaseCompactItemRow(
      title: frequent.description,
      onTap: () => showDialog(
        context: context,
        builder: (_) => FrequentDetailDialog(frequent: frequent),
      ),
      leftStatusIcon: _buildStatusIcon(status, noHistory: noHistory),
      extraTags: [
        if (billingPeriodsAway != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getBillingPeriodsColor(
                billingPeriodsAway!,
              ).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getbillingPeriodsText(billingPeriodsAway!),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
      ],
      subtitle: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: const TextStyle(fontSize: 10.5),
          children: [
            TextSpan(
              text: categoryName.toUpperCase(),
              style: TextStyle(
                color: categoryColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            TextSpan(
              text: " | ",
              style: TextStyle(
                color: AppColors.textLight.withValues(alpha: 0.4),
              ),
            ),
            TextSpan(
              text: frequent.source,
              style: TextStyle(
                color: AppColors.textLight.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      rightWidget: Text(
        Formatters.currencyWithSymbol(frequent.amount),
        textAlign: TextAlign.end,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 15,
          color: categoryColor,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(FrequentStatus status, {bool noHistory = false}) {
    /* 1. Without transactions (gray + plus icon) */
    if (noHistory) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.textLight.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.add_circle_outline,
            size: 18,
            color: AppColors.textLight,
          ),
        ),
      );
    }

    switch (status) {
      /* 2. Pending/Overdue in this billing period (Yellow + Clock) */
      case FrequentStatus.pending:
      case FrequentStatus.overdue:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.iconWarning,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.access_time_filled,
              size: 18,
              color: AppColors.iconOnPrimary,
            ),
          ),
        );

      /* 3. Already entered this billing period (Green + Check) */
      case FrequentStatus.completed:
        return const Icon(
          Icons.check_circle,
          color: AppColors.iconSuccess,
          size: 32,
        );

      /* 4. No requires entry this month (Blue + Three dots) */
      case FrequentStatus.none:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.iconIdle,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.more_horiz,
              color: AppColors.iconOnPrimary,
              size: 20,
            ),
          ),
        );
    }
  }

  Color _getBillingPeriodsColor(int billingPeriodsAway) {
    if (billingPeriodsAway > 3) {
      return AppColors.iconSuccess;
    } else if (billingPeriodsAway > 1) {
      return AppColors.warning;
    } else {
      return Colors.orange;
    }
  }

  String _getbillingPeriodsText(int billingPeriodsAway) {
    if (billingPeriodsAway == 1) {
      return "PRÓXIMO PERÍODO";
    } else {
      return "EN $billingPeriodsAway PERÍODOS";
    }
  }

  String _getCategoryName(BuildContext context, String catId) {
    try {
      final transactionProv = context.read<TransactionProvider>();
      return transactionProv.categories.firstWhere((c) => c.id == catId).name;
    } catch (_) {
      return "Sin Categoría";
    }
  }

  bool _isIncome(BuildContext context, String catId) {
    try {
      final transactionProv = context.read<TransactionProvider>();
      return transactionProv.incomeCategoryIds.contains(catId);
    } catch (_) {
      return false;
    }
  }
}
