import 'package:expense_app/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  int expenseSum(Box expensesBox) {
    int total = 0;

    for (var i = 0; i < expensesBox.length; i++) {
      var expense = expensesBox.getAt(i) as Expense;
      total += expense.amount;
    }
    return total;
  }

  void addExpense(Expense expense) {
    final expenseBox = Hive.box('expenses');
    expenseBox.add(expense);
  }

  void deleteExpense(int id) {
    final expenseBox = Hive.box('expenses');
    expenseBox.deleteAt(id);
  }

  @override
  Widget build(BuildContext context) {
    final expensesBox = Hive.box('expenses');
    final formatCurrency = new NumberFormat.simpleCurrency(locale: 'IDR');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: ElevatedButton(
        child: Icon(
          Icons.add,
          size: 30,
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(18),
          shape: CircleBorder(),
        ),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                    height: MediaQuery.of(context).size.height / 2,
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Card(
                          child: TextFormField(
                            decoration: InputDecoration(hintText: 'Title'),
                            controller: _titleController,
                          ),
                        ),
                        Card(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: 'Amount'),
                            controller: _amountController,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              addExpense(Expense(
                                  id: '0',
                                  title: _titleController.text,
                                  amount: int.parse(_amountController.text),
                                  createdAt: DateTime.now()));
                              _titleController.text = '';
                              _amountController.text = '';
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            width: double.infinity,
                            height: 50,
                            child: Center(
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
        },
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Expense',
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Expense:',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                Text(
                                  '${formatCurrency.format(expenseSum(expensesBox))}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            )
                          ]),
                    ),
                  )),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  flex: 2,
                  child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.white,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.white
                          ],
                          stops: [0.0, 0.05, 0.95, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstOut,
                      child: _buildExpenseList())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    final expensesBox = Hive.box('expenses');
    final formatCurrency = new NumberFormat.simpleCurrency(locale: 'IDR');
    return ListView.builder(
        itemCount: expensesBox.length,
        itemBuilder: (context, index) {
          final expense = expensesBox.getAt(index) as Expense;
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            background: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      size: 30,
                      color: Colors.grey[800],
                    ))),
            onDismissed: (_) {
              setState(() {
                deleteExpense(index);
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Expense Deleted!')));
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(50)),
                  child: Center(
                    child: Text(
                      '${formatCurrency.format(expense.amount)}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // trailing: IconButton(
                //   onPressed: () {
                //     setState(() {
                //       deleteExpense(index);
                //     });
                //   },
                //   icon: Icon(Icons.delete),
                //   iconSize: 25,
                //   color: Colors.grey,
                // ),
                subtitle: Text(DateFormat.yMEd().format(expense.createdAt)),
                title: Text(
                  expense.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        });
  }
}
