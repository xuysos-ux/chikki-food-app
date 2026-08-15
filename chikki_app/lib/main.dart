import 'package:flutter/material.dart';

void main() {
  runApp(const ChikkiFoodApp());
}

class User {
  final String name;
  final String role;

  User({required this.name, required this.role});
}

class SalaryDebt {
  final String employeeName;
  final double amount;
  final DateTime dueDate;
  bool isPaid;

  SalaryDebt({
    required this.employeeName,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
  });
}

class AppState {
  static List<User> users = [
    User(name: "Anis", role: "admin"),
    User(name: "Мухаммад", role: "employee"),
    User(name: "Али", role: "employee"),
  ];

  static Map<String, double> salesByEmployee = {
    "Мухаммад": 0.0,
    "Али": 0.0,
  };

  static int totalOrdersCount = 0;
  static double totalRevenue = 0.0;

  static Map<String, double> consumedStock = {
    "Чикен филе": 0.0,
    "Крылышки": 0.0,
    "Табака": 0.0,
    "Окорочка": 0.0,
    "Котлет": 0.0,
  };

  static double expensesStock = 0.0;
  static double expensesSalaries = 0.0;
  static double expensesLunches = 0.0;
  static double expensesOther = 0.0;

  static List<SalaryDebt> salaryDebts = [];
  static List<String> logs = [];

  static Map<String, double> prices = {
    "Чикен филе": 50000,
    "Крылышки": 45000,
    "Табака": 48000,
    "Окорочка": 42000,
    "Котлет": 40000,
  };

  static Map<String, double> stock = {
    "Чикен филе": 50.0,
    "Крылышки": 30.0,
    "Табака": 20.0,
    "Окорочка": 25.0,
    "Котлет": 40.0,
  };
}

class ChikkiFoodApp extends StatelessWidget {
  const ChikkiFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chikki Food POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty) return;

    bool isAdmin = (username == 'Anis' && password == 'Anis_0178');

    User? existingUser = AppState.users.cast<User?>().firstWhere(
      (u) => u?.name.toLowerCase() == username.toLowerCase(),
      orElse: () => null,
    );

    if (existingUser == null) {
      User newUser = User(name: username, role: isAdmin ? "admin" : "employee");
      AppState.users.add(newUser);
      if (!isAdmin) {
        AppState.salesByEmployee[username] = 0.0;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(
          isAdmin: isAdmin,
          username: username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Chikki Food", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 10),
            const Text("Система управления филиалом", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Ваше имя (Логин)", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Пароль", border: OutlineInputBorder())),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.amber),
              child: const Text("Войти в систему", style: TextStyle(fontSize: 18, color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final bool isAdmin;
  final String username;

  const MainNavigationScreen({super.key, required this.isAdmin, required this.username});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      HomeScreen(username: widget.username),
      ProfileScreen(username: widget.username, isAdmin: widget.isAdmin),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[900],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Продажи"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Кабинет"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _makeSale(String item, double pricePerKg) {
    TextEditingController weightController = TextEditingController();
    TextEditingController sumController = TextEditingController();
    bool isUpdating = false;

    weightController.addListener(() {
      if (isUpdating) return;
      isUpdating = true;
      double weight = double.tryParse(weightController.text) ?? 0;
      double calculatedSum = weight * pricePerKg;
      sumController.text = weightController.text.isEmpty ? "" : calculatedSum.toStringAsFixed(0);
      isUpdating = false;
    });

    sumController.addListener(() {
      if (isUpdating) return;
      isUpdating = true;
      double sum = double.tryParse(sumController.text) ?? 0;
      double calculatedWeight = pricePerKg > 0 ? sum / pricePerKg : 0;
      weightController.text = sumController.text.isEmpty ? "" : calculatedWeight.toStringAsFixed(3);
      isUpdating = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Продажа: $item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: weightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: "Вес (кг)", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: sumController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Сумма (сум)", border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              double weight = double.tryParse(weightController.text) ?? 0;
              double sum = double.tryParse(sumController.text) ?? 0;

              if (weight > 0 && sum > 0) {
                setState(() {
                  AppState.totalRevenue += sum;
                  AppState.totalOrdersCount += 1;
                  AppState.stock[item] = (AppState.stock[item] ?? 0) - weight;
                  AppState.consumedStock[item] = (AppState.consumedStock[item] ?? 0) + weight;

                  AppState.salesByEmployee[widget.username] = (AppState.salesByEmployee[widget.username] ?? 0) + sum;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Успешно продано на $sum сум!")));
              }
            },
            child: const Text("Оформить заказ", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Касса (Продавец: ${widget.username})"), backgroundColor: Colors.amber),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: AppState.prices.keys.map((item) {
          double price = AppState.prices[item]!;
          double currentStock = AppState.stock[item] ?? 0;

          return Card(
            child: ListTile(
              title: Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text("Цена: ${price.toStringAsFixed(0)} сум/кг | На складе: ${currentStock.toStringAsFixed(2)} кг"),
              trailing: const Icon(Icons.add_shopping_cart, color: Colors.amber, size: 28),
              onTap: () => _makeSale(item, price),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String username;
  final bool isAdmin;

  const ProfileScreen({super.key, required this.username, required this.isAdmin});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  void _showEmployeesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("👥 Список работников"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: AppState.users.where((u) => u.role == "employee").map((user) {
              double sales = AppState.salesByEmployee[user.name] ?? 0.0;
              return ListTile(
                leading: const Icon(Icons.person, color: Colors.amber),
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Продано на: ${sales.toStringAsFixed(0)} сум", style: const TextStyle(color: Colors.green)),
              );
            }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Закрыть"))],
      ),
    );
  }

  void _showSalaryDialog() {
    String? selectedEmployee;
    TextEditingController salaryController = TextEditingController();
    int selectedDays = 1;
    DateTime customDueDate = DateTime.now().add(const Duration(days: 1));

    List<User> employees = AppState.users.where((u) => u.role == "employee").toList();

    String formatDate(DateTime date) {
      return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          List<SalaryDebt> pendingDebts = AppState.salaryDebts.where((d) => !d.isPaid).toList();

          return AlertDialog(
            title: const Text("💵 Выдача и Долги по Зарплате"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pendingDebts.isNotEmpty) ...[
                      const Text("⚠️ Активные долги по ЗП:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 5),
                      ...pendingDebts.map((debt) {
                        int daysLeft = debt.dueDate.difference(DateTime.now()).inDays + 1;
                        return Card(
                          color: Colors.red[50],
                          child: ListTile(
                            dense: true,
                            title: Text("${debt.employeeName}: ${debt.amount.toStringAsFixed(0)} сум", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Оплатить до: ${formatDate(debt.dueDate)} (${daysLeft > 0 ? 'через $daysLeft дн.' : 'просрочено'})"),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 8)),
                              onPressed: () {
                                setState(() {
                                  debt.isPaid = true;
                                  AppState.expensesSalaries += debt.amount;
                                  AppState.logs.insert(0, "Погашен долг ЗП: ${debt.employeeName} — ${debt.amount} сум");
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Документ по долгу ${debt.employeeName} закрыт. Выплачено ${debt.amount} сум.")),
                                );
                              },
                              child: const Text("Выплатить", style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        );
                      }),
                      const Divider(height: 25),
                    ],

                    const Text("➕ Записать новый долг / выдать ЗП:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Выберите работника"),
                      value: selectedEmployee,
                      items: employees.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList(),
                      onChanged: (val) => setDialogState(() => selectedEmployee = val),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: salaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Сумма зарплаты (сум)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),
                    const Text("Срок выдачи (в долг):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        ChoiceChip(
                          label: const Text("Сейчас"),
                          selected: selectedDays == 0,
                          onSelected: (_) => setDialogState(() => selectedDays = 0),
                        ),
                        ChoiceChip(
                          label: const Text("1 день"),
                          selected: selectedDays == 1,
                          onSelected: (_) => setDialogState(() {
                            selectedDays = 1;
                            customDueDate = DateTime.now().add(const Duration(days: 1));
                          }),
                        ),
                        ChoiceChip(
                          label: const Text("2 дня"),
                          selected: selectedDays == 2,
                          onSelected: (_) => setDialogState(() {
                            selectedDays = 2;
                            customDueDate = DateTime.now().add(const Duration(days: 2));
                          }),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.calendar_month, size: 16),
                          label: Text(selectedDays > 2 ? formatDate(customDueDate) : "Выбрать дату"),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: customDueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                customDueDate = picked;
                                selectedDays = picked.difference(DateTime.now()).inDays + 1;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                  double amount = double.tryParse(salaryController.text) ?? 0;
                  if (selectedEmployee != null && amount > 0) {
                    setState(() {
                      if (selectedDays == 0) {
                        AppState.expensesSalaries += amount;
                        AppState.logs.insert(0, "Выдана ЗП: $selectedEmployee — $amount сум");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Выдано $amount сум сотруднику $selectedEmployee")));
                      } else {
                        AppState.salaryDebts.add(SalaryDebt(
                          employeeName: selectedEmployee!,
                          amount: amount,
                          dueDate: customDueDate,
                        ));
                        AppState.logs.insert(0, "Долг по ЗП: $selectedEmployee — $amount сум (До: ${formatDate(customDueDate)})");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Записан долг по ЗП $selectedEmployee до ${formatDate(customDueDate)}")));
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Сохранить", style: TextStyle(color: Colors.black)),
              )
            ],
          );
        },
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("📊 Статистика за день"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Всего заказов: ${AppState.totalOrdersCount}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Общая выручка: ${AppState.totalRevenue.toStringAsFixed(0)} сум", style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
              const Divider(),
              const Text("📦 Расход товаров со склада:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...AppState.consumedStock.keys.map((item) {
                double used = AppState.consumedStock[item] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(item), Text("${used.toStringAsFixed(2)} кг", style: const TextStyle(fontWeight: FontWeight.bold))],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Закрыть"))],
      ),
    );
  }

  void _showKickDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🚫 Выгнать работника"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: AppState.users.where((u) => u.role == "employee").map((user) {
              return ListTile(
                title: Text(user.name),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    setState(() {
                      AppState.users.removeWhere((u) => u.name == user.name);
                      AppState.salesByEmployee.remove(user.name);
                      AppState.logs.insert(0, "Удалён работник: ${user.name}");
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Сотрудник ${user.name} удалён из системы")));
                  },
                  child: const Text("Удалить", style: TextStyle(color: Colors.white)),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Закрыть"))],
      ),
    );
  }

  void _showIncomeDialog() {
    double totalExp = AppState.expensesStock + AppState.expensesSalaries + AppState.expensesLunches + AppState.expensesOther;
    double netProfit = AppState.totalRevenue - totalExp;

    double totalPendingDebts = AppState.salaryDebts.where((d) => !d.isPaid).fold(0, (sum, item) => sum + item.amount);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("💰 Полный Доход и Касса"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Общая выручка:"), Text("${AppState.totalRevenue.toStringAsFixed(0)} сум", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("📦 Закуп товара:"), Text("-${AppState.expensesStock.toStringAsFixed(0)} сум", style: const TextStyle(color: Colors.red))]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("💵 Выплаченная ЗП:"), Text("-${AppState.expensesSalaries.toStringAsFixed(0)} сум", style: const TextStyle(color: Colors.red))]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("🍔 Обеды:"), Text("-${AppState.expensesLunches.toStringAsFixed(0)} сум", style: const TextStyle(color: Colors.red))]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("🛠 Доп. расходы:"), Text("-${AppState.expensesOther.toStringAsFixed(0)} сум", style: const TextStyle(color: Colors.red))]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Всего расходов:"), Text("-${totalExp.toStringAsFixed(0)} сум", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("ЧИСТАЯ ПРИБЫЛЬ:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${netProfit.toStringAsFixed(0)} сум", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: netProfit >= 0 ? Colors.green : Colors.red)),
            ]),
            if (totalPendingDebts > 0) ...[
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("⏳ Долги по ЗП (к выплате):", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                Text("${totalPendingDebts.toStringAsFixed(0)} сум", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ]),
            ]
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Закрыть"))],
      ),
    );
  }

  void _addStockDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("📦 Закуп товара на склад"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Название товара")),
            TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Вес (кг)")),
            TextField(controller: costController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Общая стоимость закупа (сум)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
          ElevatedButton(
            onPressed: () {
              String name = nameController.text.trim();
              double weight = double.tryParse(weightController.text) ?? 0;
              double cost = double.tryParse(costController.text) ?? 0;

              if (name.isNotEmpty && weight > 0) {
                setState(() {
                  AppState.stock[name] = (AppState.stock[name] ?? 0) + weight;
                  AppState.expensesStock += cost;
                  AppState.logs.insert(0, "Закуп: $name (+$weight кг) на $cost сум");
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Добавить"),
          )
        ],
      ),
    );
  }

  void _addOtherExpenseDialog(String type) {
    TextEditingController noteController = TextEditingController();
    TextEditingController costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Записать расход: $type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: noteController, decoration: const InputDecoration(labelText: "Заметка / Описание")),
            TextField(controller: costController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Сумма (сум)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
          ElevatedButton(
            onPressed: () {
              double cost = double.tryParse(costController.text) ?? 0;
              if (cost > 0) {
                setState(() {
                  if (type == "Обед") AppState.expensesLunches += cost;
                  if (type == "Доп.") AppState.expensesOther += cost;
                  AppState.logs.insert(0, "Расход ($type): ${noteController.text} — $cost сум");
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Сохранить"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Кабинет (${widget.username})"), backgroundColor: Colors.amber),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Пользователь: ${widget.username}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Роль: ${widget.isAdmin ? 'Владелец (Admin)' : 'Работник'}", style: const TextStyle(color: Colors.grey)),
            const Divider(height: 30),

            if (widget.isAdmin) ...[
              const Text("👑 МЕНЮ ВЛАДЕЛЬЦА", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
              const SizedBox(height: 15),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.people, color: Colors.blue),
                  title: const Text("Работники", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Список всех зарегистрированных и их продажи"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showEmployeesDialog,
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.green),
                  title: const Text("Зарплата и Долги", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Выдача ЗП, запись долгов на 1-2 дня или календарь"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showSalaryDialog,
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.purple),
                  title: const Text("Статистика", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Заказы за день, выручка и расход товаров"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showStatsDialog,
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_remove, color: Colors.red),
                  title: const Text("Выгнать работника", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Удалить сотрудника из системы"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showKickDialog,
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.orange),
                  title: const Text("Доход (Касса)", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Выручка за вычетом закупа, зарплат и обедов"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showIncomeDialog,
                ),
              ),

              const SizedBox(height: 20),
              const Text("➕ ВНОС РАСХОДОВ И ТОВАРОВ:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(onPressed: _addStockDialog, icon: const Icon(Icons.add), label: const Text("Закуп склада")),
                  ElevatedButton.icon(onPressed: () => _addOtherExpenseDialog("Обед"), icon: const Icon(Icons.fastfood), label: const Text("Обед")),
                  ElevatedButton.icon(onPressed: () => _addOtherExpenseDialog("Доп."), icon: const Icon(Icons.build), label: const Text("Доп. расходы")),
                ],
              ),
              const Divider(height: 30),
            ],

            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              child: const Text("Выйти из аккаунта", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}