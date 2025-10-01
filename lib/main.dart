import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado com sucesso!');
  } catch (e) {
    print('Erro ao inicializar Firebase: $e');
  }

    // Inicialize o Supabase
  try {
    // Substitua pelas suas credenciais do Supabase
    await Supabase.initialize(
      url: 'https://fvhzkbqcvgkglvoqqbge.supabase.co', // Seu Project URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2aHprYnFjdmdrZ2x2b3FxYmdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyNzU1MzEsImV4cCI6MjA3NDg1MTUzMX0.DsbcGJDMD9abYA3CRknZtAVx0zLp0M8RIse-ymSXKBE', // Sua anon key
    );
    print('Supabase inicializado com sucesso!');
  } catch (e) {
    print('Erro ao inicializar Supabase: $e');
  }

  if (kIsWeb) {
    try {
      databaseFactory = databaseFactoryFfiWeb;
    } catch (e) {
      print('Erro ao configurar databaseFactoryFfiWeb: $e');
    }
  }

  runApp(const MyApp());
}

// MyApp agora é StatefulWidget para gerenciar tema global
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {});
  }

  Future<void> _toggleTheme() async {
    final newMode = !_isDarkMode;
    setState(() {
      _isDarkMode = newMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Armazenamento',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onToggleTheme: _toggleTheme),
    );
  }
}

// Tela principal com botões para todas as funcionalidades
class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sistema de Armazenamento')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ThemeToggleScreen(onToggleTheme: onToggleTheme),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Alternar Tema (SharedPreferences)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TokenStorageScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Armazenar Token (Secure Storage)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskListScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Gerenciar Tarefas (SQLite CRUD)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserRegistrationScreen(),
                    ), // A tela agora faz cadastro e listagem
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Usuários (Cadastrar/Listar - Firebase)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Listar Produtos (Supabase)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ComparisonScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Comparação Local vs Nuvem'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DataFlowDiagramScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Diagrama de Fluxo de Dados'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tela de tema (agora usa callback do MyApp)
class ThemeToggleScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const ThemeToggleScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tema Escuro Global')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Theme.of(context).brightness == Brightness.dark
                  ? 'Tema Escuro Ativado'
                  : 'Tema Claro Ativado',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onToggleTheme,
              child: Text(
                Theme.of(context).brightness == Brightness.dark
                    ? 'Ativar Tema Claro'
                    : 'Ativar Tema Escuro',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'O tema será aplicado para toda a aplicação!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de token (sem alterações)
class TokenStorageScreen extends StatefulWidget {
  const TokenStorageScreen({super.key});

  @override
  State<TokenStorageScreen> createState() => _TokenStorageScreenState();
}

class _TokenStorageScreenState extends State<TokenStorageScreen> {
  final _storage = const FlutterSecureStorage();
  String _token = '';
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _storage.read(key: 'auth_token') ?? '';
    setState(() {
      _token = token;
      _message = token.isNotEmpty
          ? 'Token carregado com sucesso!'
          : 'Nenhum token armazenado.';
    });
  }

  Future<void> _saveToken() async {
    if (_token.trim().isEmpty) {
      setState(() {
        _message = 'Digite um token válido!';
      });
      return;
    }

    await _storage.write(key: 'auth_token', value: _token);
    setState(() {
      _message = 'Token salvo com sucesso!';
    });
  }

  Future<void> _deleteToken() async {
    await _storage.delete(key: 'auth_token');
    setState(() {
      _token = '';
      _message = 'Token removido!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Armazenar Token com Secure Storage')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Digite seu token',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _token = value;
                });
              },
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar Token'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _deleteToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remover Token'),
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(
                color: _message.contains('sucesso')
                    ? Colors.green
                    : Colors.grey,
                fontSize: 16,
              ),
            ),
            if (_token.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Token: $_token',
                    style: const TextStyle(fontFamily: 'Monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// MODELO DE DADOS PARA TAREFAS
class Task {
  int? id;
  String title;
  String description;
  DateTime? dueDate;

  Task({this.id, required this.title, required this.description, this.dueDate});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
    );
  }
}

// GERENCIADOR DE BANCO DE DADOS
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use getDatabasesPath() da instância do databaseFactory configurado
    final path = join(await getDatabasesPath(), 'tasks.db');
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            due_date TEXT
          )
        ''');
        },
      ),
    );
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<Task?> getTask(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}

// LISTA DE TAREFAS
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper().getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciador de Tarefas')),
      body: _tasks.isEmpty
          ? const Center(child: Text('Nenhuma tarefa cadastrada'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: Key(task.id.toString()),
                  onDismissed: (direction) async {
                    await DatabaseHelper().deleteTask(task.id!);
                    _loadTasks();
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight:
                            task.dueDate != null &&
                                task.dueDate!.isBefore(DateTime.now())
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color:
                            task.dueDate != null &&
                                task.dueDate!.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(task.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskFormScreen(task: task),
                              ),
                            ).then((_) => _loadTasks());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await DatabaseHelper().deleteTask(task.id!);
                            _loadTasks();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskFormScreen()),
          );
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// FORMULÁRIO DE TAREFAS
class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.dueDate;
      if (_selectedDate != null) {
        _dueDateController.text = _selectedDate!.toString();
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dueDateController.text = _selectedDate!.toString();
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final description = _descriptionController.text;
      final dueDate = _selectedDate;

      final task = Task(
        id: widget.task?.id,
        title: title,
        description: description,
        dueDate: dueDate,
      );

      if (widget.task != null) {
        await DatabaseHelper().updateTask(task);
      } else {
        await DatabaseHelper().insertTask(task);
      }
      Navigator.pop(this.context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Editar Tarefa' : 'Nova Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Data de Vencimento',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task != null ? 'Atualizar' : 'Criar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MODELO DE USUÁRIO PARA FIREBASE
class User {
  String? id;
  String name;
  String email;
  DateTime createdAt;

  User({this.id, required this.name, required this.email, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// TELA DE CADASTRO E LISTAGEM DE USUÁRIOS COM FIREBASE
class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _message = '';
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');
  bool _isLoadingUsers = false;

  // Método para buscar usuários do Firestore
  Future<List<User>> _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await usersCollection
          .orderBy('created_at', descending: true)
          .get();
      return querySnapshot.docs.map((doc) {
        // Converter o timestamp do Firestore para DateTime
        var data = doc.data() as Map<String, dynamic>;
        var timestamp = data['created_at'];
        DateTime createdAt = timestamp is Timestamp
            ? timestamp.toDate()
            : (timestamp is DateTime ? timestamp : DateTime.now());
        return User(
          id: doc.id, // ID do documento no Firestore
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          createdAt: createdAt,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar usuários: $e');
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await usersCollection.add({
          'name': _nameController.text,
          'email': _emailController.text,
          'created_at':
              FieldValue.serverTimestamp(), // Usar timestamp do servidor é melhor
        });

        setState(() {
          _message = 'Usuário cadastrado com sucesso!';
          _nameController.clear();
          _emailController.clear();
        });
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
      } catch (e) {
        print(
          'Erro ao cadastrar usuário no Firestore: $e',
        ); // Adicione log para erros específicos
        setState(() {
          _message = 'Erro ao cadastrar usuário: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários (Firebase)')),
      body: Column(
        children: [
          // Formulário de cadastro
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o email';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerUser,
                    child: const Text('Cadastrar Usuário'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _message,
                    style: TextStyle(
                      color: _message.contains('sucesso')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Separador
          const Divider(),

          // Título da lista
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Usuários Cadastrados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(
                      () {},
                    ); // Isso força o FutureBuilder a recarregar os dados
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Atualizar'),
                ),
              ],
            ),
          ),

          // Lista de usuários
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _fetchUsers(), // Chama a função para buscar os dados
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Nenhum usuário cadastrado.'),
                  );
                } else {
                  List<User> users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      User user = users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          title: Text(user.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${user.email}'),
                              Text(
                                'Cadastrado em: ${user.createdAt.toString().split('.').first}',
                              ), // Formata a data
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await usersCollection.doc(user.id).delete();
                              if (mounted) setState(() {}); // Recarrega a lista
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// MODELO DE PRODUTO PARA SUPABASE
class Product {
  int? id;
  String name;
  double price;
  String description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
    );
  }
}

// TELA DE LISTAGEM DE PRODUTOS COM SUPABASE (usando o cliente oficial)
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = false;

  // Método para buscar produtos do Supabase usando o cliente oficial
  Future<List<Product>> _fetchProductsFromSupabase() async {
    try {
      // Obtém a instância do cliente
      final supabase = Supabase.instance.client;

      // Faz a requisição SELECT na tabela 'products'
      final response = await supabase
          .from('products') // Nome da sua tabela
          .select(); // Seleciona todas as colunas

      // Converte a resposta (lista de Maps) para lista de Product
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar produtos do Supabase: $e');
      rethrow; // Relança o erro para ser tratado pelo caller
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return; // Verifica se o widget ainda está montado

    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _fetchProductsFromSupabase();
      if (mounted) { // Verifica novamente antes de atualizar o estado
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _products = []; // Limpa a lista em caso de erro
        });
        // Mostra um SnackBar com a mensagem de erro
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(
                content: Text('Erro ao carregar produtos: $e'),
                backgroundColor: Theme.of(this.context).colorScheme.error,
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos (Supabase)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('Nenhum produto encontrado ou erro ao carregar.'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(product.description),
                        trailing: Text(
                          'R\$ ${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadProducts, // Recarrega a lista ao clicar
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// TELA DE COMPARAÇÃO LOCAL VS NUVEM
class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparação Local vs Nuvem')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Armazenamento Local (SQLite)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildComparisonItem('Prós:', [
              'Dados disponíveis offline',
              'Maior privacidade',
              'Desempenho rápido',
              'Sem custos de hospedagem',
              'Controle total dos dados',
            ]),
            const SizedBox(height: 16),
            _buildComparisonItem('Contras:', [
              'Dados não sincronizados entre dispositivos',
              'Limitado ao dispositivo',
              'Backup manual necessário',
              'Difícil de compartilhar dados',
              'Escalabilidade limitada',
            ]),
            const SizedBox(height: 20),
            const Text(
              'Armazenamento em Nuvem (Firebase/Supabase)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildComparisonItem('Prós:', [
              'Sincronização entre dispositivos',
              'Acesso remoto',
              'Backup automático',
              'Escalabilidade',
              'Compartilhamento de dados fácil',
              'Autenticação integrada',
            ]),
            const SizedBox(height: 16),
            _buildComparisonItem('Contras:', [
              'Requer conexão com internet',
              'Custos de hospedagem',
              'Menor privacidade',
              'Dependência de provedor',
              'Latência de rede',
              'Limitações de uso',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Text('• $item'),
          ),
        ),
      ],
    );
  }
}

// TELA DO DIAGRAMA DE FLUXO DE DADOS
class DataFlowDiagramScreen extends StatelessWidget {
  const DataFlowDiagramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagrama de Fluxo de Dados')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fluxo de Dados do Aplicativo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildFlowStep(
                '1. Tela Principal',
                'Tela inicial com opções de funcionalidades',
              ),
              const SizedBox(height: 10),
              _buildFlowStep(
                '2. SharedPreferences',
                'Armazenamento de preferências locais (tema)',
              ),
              const SizedBox(height: 10),
              _buildFlowStep(
                '3. Secure Storage',
                'Armazenamento seguro de tokens e senhas',
              ),
              const SizedBox(height: 10),
              _buildFlowStep(
                '4. SQLite (Local)',
                'CRUD de tarefas armazenadas localmente',
              ),
              const SizedBox(height: 10),
              _buildFlowStep(
                '5. Firebase Firestore',
                'Cadastro e gerenciamento de usuários na nuvem',
              ),
              const SizedBox(height: 10),
              _buildFlowStep(
                '6. Supabase',
                'Listagem de produtos da base de dados na nuvem',
              ),
              const SizedBox(height: 20),
              const Text(
                'Resumo:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'O aplicativo demonstra diferentes formas de armazenamento de dados, '
                'desde armazenamento local simples (SharedPreferences, SQLite) até '
                'soluções em nuvem (Firebase, Supabase), cada uma com seus casos '
                'de uso específicos e vantagens/desvantagens.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowStep(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
