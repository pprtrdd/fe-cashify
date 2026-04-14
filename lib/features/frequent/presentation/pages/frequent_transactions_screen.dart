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
import 'package:cashify/features/shared/widgets/custom_search_bar.dart';
import 'package:cashify/core/utils/formatters.dart';
import 'package:collection/collection.dart';
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
          CustomSearchBar(
            onChanged: (value) {
              context.read<FrequentTransactionProvider>().setSearchQuery(value);
            },
          ),
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

    final groupedItems = groupBy(
      filteredList,
      (item) => item['billingPeriodsAway'] as int?,
    );

    final sortedKeys =
        groupedItems.keys.toList()..sort((a, b) {
          if (a == null) return 1;
          if (b == null) return -1;
          return a.compareTo(b);
        });

    return sortedKeys.map((key) {
      final items = groupedItems[key]!;

      final total = items.fold<int>(
        0,
        (sum, item) =>
            sum + (item['frequent'] as FrequentTransactionEntity).amount,
      );

      return _FrequentGroup(
        name: _getGroupTitle(key),
        total: total,
        backgroundColor: _getUrgencyColor(key ?? 999),
        children:
            items.map((item) {
              return _FrequentItemRow(
                frequent: item['frequent'] as FrequentTransactionEntity,
                status: item['status'] as FrequentStatus,
                billingPeriodsAway: item['billingPeriodsAway'] as int?,
                noHistory: item['noHistory'] as bool,
              );
            }).toList(),
      );
    }).toList();
  }

  String _getGroupTitle(int? billingPeriodsAway) {
    if (billingPeriodsAway == null) {
      return "Pendientes de Inicio";
    }
    if (billingPeriodsAway == 1) {
      return "Próximo Período";
    }
    return "En $billingPeriodsAway Períodos";
  }

  Color _getUrgencyColor(int billingPeriodsAway) {
    if (billingPeriodsAway > 3) {
      return AppColors.iconSuccess;
    } else if (billingPeriodsAway > 1) {
      return AppColors.warning;
    } else {
      return Colors.orange;
    }
  }
}

class _FrequentGroup extends StatefulWidget {
  final String name;
  final int total;
  final Color backgroundColor;
  final List<Widget> children;

  const _FrequentGroup({
    required this.name,
    required this.total,
    required this.backgroundColor,
    required this.children,
  });

  @override
  State<_FrequentGroup> createState() => _FrequentGroupState();
}

class _FrequentGroupState extends State<_FrequentGroup> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    const textColor = AppColors.background;

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.name.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      color: textColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Text(
                  Formatters.currencyWithSymbol(widget.total),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: textColor.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Column(children: widget.children),
          secondChild: const SizedBox(width: double.infinity),
          crossFadeState:
              _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: 12),
      ],
    );
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
      extraTags: null,
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

      case FrequentStatus.completed:
        return const Icon(
          Icons.check_circle,
          color: AppColors.iconSuccess,
          size: 32,
        );

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

  bool _isIncome(BuildContext context, String catId) {
    try {
      final transactionProv = context.read<TransactionProvider>();
      return transactionProv.incomeCategoryIds.contains(catId);
    } catch (_) {
      return false;
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
}
