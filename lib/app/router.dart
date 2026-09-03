import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/activity/presentation/activity_screen.dart';
import '../features/analytics/presentation/insights_screen.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/expenses/presentation/add_expense_screen.dart';
import '../features/expenses/presentation/settle_up_screen.dart';
import '../features/groups/presentation/create_group_screen.dart';
import '../features/groups/presentation/group_detail_screen.dart';
import '../features/groups/presentation/groups_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/salary/presentation/salary_screen.dart';
import 'home_shell.dart';

/// Route paths in one place so screens can navigate by name without magic
/// strings scattered around.
abstract final class AppRoutes {
  static const groups = '/groups';
  static const insights = '/insights';
  static const budgets = '/insights/budgets';
  static const salary = '/insights/salary';
  static const activity = '/activity';
  static const profile = '/profile';
  static const newGroup = '/groups/new';

  static String groupDetail(String groupId) => '/groups/$groupId';
  static String addExpense(String groupId) => '/groups/$groupId/add-expense';
  static String settleUp(String groupId) => '/groups/$groupId/settle';
}

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.groups,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellKey,
            routes: [
              GoRoute(
                path: AppRoutes.groups,
                builder: (context, state) => const GroupsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const CreateGroupScreen(),
                  ),
                  GoRoute(
                    path: ':groupId',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => GroupDetailScreen(
                      groupId: state.pathParameters['groupId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'add-expense',
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => AddExpenseScreen(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'settle',
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => SettleUpScreen(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.insights,
                builder: (context, state) => const InsightsScreen(),
                routes: [
                  GoRoute(
                    path: 'budgets',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const BudgetsScreen(),
                  ),
                  GoRoute(
                    path: 'salary',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const SalaryScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.activity,
                builder: (context, state) => const ActivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
