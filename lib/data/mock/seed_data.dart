import '../../features/auth/domain/entities/app_user.dart';
import '../../features/budgets/domain/entities/budget.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/domain/entities/expense_category.dart';
import '../../features/expenses/domain/entities/settlement.dart';
import '../../features/expenses/domain/entities/split_type.dart';
import '../../features/groups/domain/entities/group.dart';
import '../../features/groups/domain/personal_group.dart';
import '../../features/salary/domain/entities/salary_cycle.dart';

/// Demo users. `alice` is the default signed-in user.
const seedUsers = <AppUser>[
  AppUser(
    id: 'u_alice',
    name: 'Alice Nguyen',
    email: 'alice@demo.app',
    avatarColor: 0xFF6C5CE7,
  ),
  AppUser(
    id: 'u_bob',
    name: 'Bob Martins',
    email: 'bob@demo.app',
    avatarColor: 0xFF00B894,
  ),
  AppUser(
    id: 'u_carol',
    name: 'Carol Diaz',
    email: 'carol@demo.app',
    avatarColor: 0xFFE17055,
  ),
  AppUser(
    id: 'u_dave',
    name: 'Dave Okafor',
    email: 'dave@demo.app',
    avatarColor: 0xFF0984E3,
  ),
];

final seedGroups = <Group>[
  Group(
    id: 'g_apartment',
    name: 'Apartment',
    emoji: '🏠',
    memberIds: const ['u_alice', 'u_bob', 'u_carol'],
    currencyCode: 'USD',
    createdAt: DateTime(2026, 8, 1),
  ),
  Group(
    id: 'g_kyoto',
    name: 'Kyoto Trip',
    emoji: '✈️',
    memberIds: const ['u_alice', 'u_bob', 'u_dave'],
    currencyCode: 'USD',
    createdAt: DateTime(2026, 8, 20),
  ),
  // Alice's personal ledger (solo expenses).
  Group(
    id: 'g_personal_u_alice',
    name: PersonalGroup.name,
    emoji: PersonalGroup.emoji,
    memberIds: const ['u_alice'],
    currencyCode: 'USD',
    createdAt: DateTime(2026, 8, 1),
  ),
];

/// Amounts are minor units (cents). Mixed split types so balances are
/// non-trivial and every split path is exercised on real data.
final seedExpenses = <Expense>[
  // --- Apartment ---
  Expense(
    id: 'x_rent',
    groupId: 'g_apartment',
    description: 'August rent',
    payerId: 'u_alice',
    amountMinorUnits: 300000, // $3,000.00
    currencyCode: 'USD',
    splitType: SplitType.equal,
    participantIds: const ['u_alice', 'u_bob', 'u_carol'],
    createdAt: DateTime(2026, 8, 1, 9),
    category: ExpenseCategory.rent,
  ),
  Expense(
    id: 'x_groceries',
    groupId: 'g_apartment',
    description: 'Groceries',
    payerId: 'u_bob',
    amountMinorUnits: 8450, // $84.50
    currencyCode: 'USD',
    splitType: SplitType.equal,
    participantIds: const ['u_alice', 'u_bob', 'u_carol'],
    createdAt: DateTime(2026, 8, 24, 18, 30),
    category: ExpenseCategory.groceries,
  ),
  Expense(
    id: 'x_internet',
    groupId: 'g_apartment',
    description: 'Internet bill',
    payerId: 'u_carol',
    amountMinorUnits: 6000, // $60.00
    currencyCode: 'USD',
    splitType: SplitType.exact,
    participantIds: const ['u_alice', 'u_bob', 'u_carol'],
    exactShares: const {'u_alice': 3000, 'u_bob': 1500, 'u_carol': 1500},
    createdAt: DateTime(2026, 8, 28, 12),
    category: ExpenseCategory.utilities,
  ),
  // --- Kyoto Trip ---
  Expense(
    id: 'x_hotel',
    groupId: 'g_kyoto',
    description: 'Ryokan (3 nights)',
    payerId: 'u_alice',
    amountMinorUnits: 45000, // $450.00
    currencyCode: 'USD',
    splitType: SplitType.percent,
    participantIds: const ['u_alice', 'u_bob', 'u_dave'],
    percentShares: const {'u_alice': 4000, 'u_bob': 3000, 'u_dave': 3000},
    createdAt: DateTime(2026, 8, 21, 15),
    category: ExpenseCategory.travel,
  ),
  Expense(
    id: 'x_dinner',
    groupId: 'g_kyoto',
    description: 'Kaiseki dinner',
    payerId: 'u_dave',
    amountMinorUnits: 12000, // $120.00
    currencyCode: 'USD',
    splitType: SplitType.equal,
    participantIds: const ['u_alice', 'u_bob', 'u_dave'],
    createdAt: DateTime(2026, 8, 22, 20),
    category: ExpenseCategory.food,
  ),
  Expense(
    id: 'x_train',
    groupId: 'g_kyoto',
    description: 'Shinkansen tickets',
    payerId: 'u_bob',
    amountMinorUnits: 9000, // $90.00
    currencyCode: 'USD',
    splitType: SplitType.exact,
    participantIds: const ['u_alice', 'u_bob', 'u_dave'],
    exactShares: const {'u_alice': 3000, 'u_bob': 3000, 'u_dave': 3000},
    createdAt: DateTime(2026, 8, 23, 8),
    category: ExpenseCategory.transport,
  ),
  // --- Alice's personal (solo) expenses ---
  Expense(
    id: 'x_p_coffee',
    groupId: 'g_personal_u_alice',
    description: 'Morning coffee',
    payerId: 'u_alice',
    amountMinorUnits: 650, // $6.50
    currencyCode: 'USD',
    splitType: SplitType.equal,
    participantIds: const ['u_alice'],
    createdAt: DateTime(2026, 8, 25, 8),
    category: ExpenseCategory.food,
  ),
  Expense(
    id: 'x_p_gym',
    groupId: 'g_personal_u_alice',
    description: 'Gym membership',
    payerId: 'u_alice',
    amountMinorUnits: 4500, // $45.00
    currencyCode: 'USD',
    splitType: SplitType.equal,
    participantIds: const ['u_alice'],
    createdAt: DateTime(2026, 8, 26, 7),
    category: ExpenseCategory.health,
  ),
  Expense(
    id: 'x_p_books',
    groupId: 'g_personal_u_alice',
    description: 'Books',
    payerId: 'u_alice',
    amountMinorUnits: 3200, // $32.00
    currencyCode: 'USD',
    splitType: SplitType.equal,
    participantIds: const ['u_alice'],
    createdAt: DateTime(2026, 8, 27, 19),
    category: ExpenseCategory.shopping,
  ),
];

/// Alice's active salary cycle (this pay period).
final seedSalaryCycles = <SalaryCycle>[
  SalaryCycle(
    id: 'sc_alice_aug',
    userId: 'u_alice',
    incomeMinorUnits: 400000, // $4,000 salary
    currencyCode: 'USD',
    startedAt: DateTime(2026, 8, 1),
  ),
];

/// Demo monthly budgets for Alice.
final seedBudgets = <Budget>[
  const Budget(
    id: 'b_food',
    userId: 'u_alice',
    category: ExpenseCategory.food,
    monthlyLimitMinorUnits: 20000, // $200
    currencyCode: 'USD',
  ),
  const Budget(
    id: 'b_transport',
    userId: 'u_alice',
    category: ExpenseCategory.transport,
    monthlyLimitMinorUnits: 8000, // $80
    currencyCode: 'USD',
  ),
  const Budget(
    id: 'b_shopping',
    userId: 'u_alice',
    category: ExpenseCategory.shopping,
    monthlyLimitMinorUnits: 15000, // $150
    currencyCode: 'USD',
  ),
];

/// A partial repayment so the "settle up" flow has history to show.
final seedSettlements = <Settlement>[
  Settlement(
    id: 's_bob_alice',
    groupId: 'g_apartment',
    fromUserId: 'u_bob',
    toUserId: 'u_alice',
    amountMinorUnits: 5000, // $50.00
    currencyCode: 'USD',
    createdAt: DateTime(2026, 8, 29, 10),
  ),
];

/// Everyone in the demo is friends with everyone else.
Map<String, Set<String>> buildSeedFriendships() {
  final ids = seedUsers.map((u) => u.id).toList();
  return {for (final id in ids) id: ids.where((other) => other != id).toSet()};
}
