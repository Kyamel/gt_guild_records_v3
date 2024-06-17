import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Future<Database> openDB(String folderPath, String name) async {
    String dbPath = join(folderPath, '$name.db');
    var databaseFactory = databaseFactoryFfi;
    return await databaseFactory.openDatabase(dbPath);
  }

  static Future<void> closeDB(Database db) async {
    await db.close();
  }
}

class DatabaseTable {
  String _tableName;
  final List<String> _columns;

  DatabaseTable(this._tableName, this._columns);

  Future<void> createTable(Database db) async {
    // Monta a query SQL para criar a tabela
    final columnsString = _columns.join(', ');
    final query = 'CREATE TABLE IF NOT EXISTS $_tableName ($columnsString)';
    // Executa a query no banco de dados
    await db.execute(query);
  }

  Future<void> dropTable(Database db) async{
    final query = 'DROP TABLE IF EXISTS $_tableName';
    await db.execute(query);
  }

  Future<void> renameTable(Database db, String newName) async{
    await db.transaction((txn) async {
      try {
        await txn.execute('ALTER TABLE $_tableName RENAME TO $newName');
        _tableName = newName;
      } catch (e) {
        debugPrint('ERROR:RENAME:TABLE: $e');
        rethrow; 
      }
    });
  }

  Future<String> getAllTableData(Database db) async {
    final query = 'SELECT * FROM $_tableName';
    final List<Map<String, dynamic>> rows = await db.rawQuery(query);
  
    // Imprime os nomes das colunas
    final List<String> columnNames = rows.isNotEmpty ? rows.first.keys.toList() : [];
    final StringBuffer tableStringBuffer = StringBuffer();

    tableStringBuffer.writeln(columnNames.join(' | '));

    // Imprime os dados
    for (final row in rows) {
      final List<String> rowValues = columnNames.map((colName) => '${row[colName]}').toList();
      tableStringBuffer.writeln(rowValues.join(' | '));
    }

    return tableStringBuffer.toString();
  }

  Future<int> getID(Database db, String key, String nameOfColumn, String name) async {
    final query = 'SELECT $key FROM $_tableName WHERE $nameOfColumn = ?';
    final List<Map<String, dynamic>> result = await db.rawQuery(query, [name]);
    if (result.isNotEmpty) {
      return result.first[key];
    } else {
      return -1;
    }
  }

  List<String> getColumnNames(List<String> columns) {
    List<String> columnNames = [];
    for (String column in columns) {
      // Divide a string da coluna usando um espaço em branco como delimitador
      List<String> parts = column.split(' ');
      // O primeiro elemento da lista é o nome da coluna
      columnNames.add(parts.first);
    }
    return columnNames;
  }

  Future<void> addData(Database db, List<int> index, List<String> args) async {
    if (index.length != args.length) {
      throw ArgumentError('Index and args lists must have the same length.');
    }
    final List<String> columns = [];
    final List<String> placeholders = [];
    List columnNames = getColumnNames(_columns);
    for (int i in index) {
      if (i < 0 || i >= _columns.length) {
        throw ArgumentError('Index $i is out of range.');
      }
      columns.add(columnNames[i]);
      placeholders.add('?');
    }
    final String insert = columns.join(', ');
    final String values = placeholders.join(', ');
    final String query = 'INSERT INTO $_tableName ($insert) VALUES ($values)';

    try {
      await db.transaction((txn) async {
        await txn.rawInsert(query, args);
      });
    } catch (e) {
      debugPrint('Error inserting data: $e');
      rethrow;
    }
  }
  Future<void> removeData(Database db, List<int> ids) async {
    List<Map<String, dynamic>> result = await db.rawQuery('PRAGMA table_info($_tableName)');
    List<String> primaryKeys = [];
    for (Map<String, dynamic> row in result) {
      if (row['pk'] == 1) {
        primaryKeys.add(row['name']);
      }
    }
    if (ids.length % primaryKeys.length != 0) {
      throw ArgumentError('Number of primary key values must be a multiple of the number of primary keys.');
    }
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];
    for (int i = 0; i < ids.length; i += primaryKeys.length) {
      if (ids.length - i < primaryKeys.length) {
        throw ArgumentError('Not enough primary key values provided.');
      }
      final List<String> condition = [];
      for (int j = 0; j < primaryKeys.length; j++) {
        condition.add('${primaryKeys[j]} = ?');
        whereArgs.add(ids[i + j]);
      }
      whereConditions.add('(${condition.join(' AND ')})');
    }
    final String whereClause = whereConditions.join(' OR ');
    final String query = 'DELETE FROM $_tableName WHERE $whereClause';
    try {
      await db.transaction((txn) async {
        await txn.rawDelete(query, whereArgs);
      });
    } catch (e) {
      debugPrint('Error removing data: $e');
      rethrow;
    }
  }

  Future<List<List<String>>> getData(Database db)async{
    final columnNames = getColumnNames(_columns);

    List<Map<String, dynamic>> queryResult = await db.query(_tableName);
    List<List<String>> dataList = [];
      for (var row in queryResult) {
        List<String> rowData = [];
        for (var columnName in columnNames) {
          rowData.add(row[columnName].toString());
        }
        dataList.add(rowData);
      }
      return dataList;
  }
}

class Logger {
  static void log(String message) {
    if(Platform.isWindows) {
      try {
      final File file = File('log.txt');
      file.writeAsStringSync('$message\n', mode: FileMode.append);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao gravar no arquivo de log: $e');
      }
    }
    }
  }
}

class DatabaseManager {
  late Database _database;
  String _folderPath = 'undefined';
  String _name = 'GTGuildRecords';
  late DatabaseTable _members;
  late DatabaseTable _raids;
  late DatabaseTable _membersInRaid;
  bool isOpen = false;
  // Singleton instance
  static final DatabaseManager _instance = DatabaseManager._internal();
  // Private constructor
  DatabaseManager._internal() {
    sqfliteFfiInit();
  }
  // Getter for the singleton instance
  factory DatabaseManager(String path) {
    _instance._folderPath = path;
    return _instance;
  }
  Database getDatabase(){
    return _database;
  }
  String getPath(){
    return _folderPath;
  }
  String getName(){
    return _name;
  }
  void setPath(String path) {
    _folderPath = path;
  } 
  void setName(String name){
    _name = name;
  }
  Future<void> moveFileToPermanentLocation(String temporaryFilePath) async {
    //Directory documentsDirectory = 'storage/emulated/0/Documents';
    String permanentDirectoryPath = 'storage/emulated/0/Documents';

    // Obtenha o nome do arquivo a partir do caminho temporário
    List<String> pathParts = temporaryFilePath.split('/');
    String fileName = pathParts.last;

    // Crie o caminho para o novo local permanente
    String permanentFilePath = '$permanentDirectoryPath/$fileName';

    // Mova o arquivo para o novo local
    File temporaryFile = File(temporaryFilePath);
    await temporaryFile.copy(permanentFilePath);
  }
  Future<int> moveDatabaseToExternalFolder() async {
  try {
    final path = await FilePicker.platform.getDirectoryPath() ?? 'undefined';
    if(path != 'undefined'){
      final newPath = '$path/$_name';
      await File('$_folderPath/$_name').copy(newPath);
      debugPrint('Database successfully moved to: $newPath');
      return 0;
    }
    return 1;
  } catch (e) {
    debugPrint('Error moving database to external folder: $e');
    return -1;
  }
}

  // Method to open the database
  Future<void> openDatabase() async {
    if (_folderPath != 'undefined') {
      debugPrint("Opening database $_name at path: $_folderPath");
      Logger.log("Opening database $_name at path: $_folderPath");
      _database = await DatabaseHelper.openDB(_folderPath, _name);
      isOpen = true;
    }
  }
  // Method to close the database
  Future<void> closeDatabase() async {
    try{
      debugPrint("Closing database $_name at path: $_folderPath");
      Logger.log("Closing database $_name at path: $_folderPath");
      await DatabaseHelper.closeDB(_database);
      isOpen = false;
    }catch(e){
      Logger.log("ERROR::CLOSING::DATABASE::$e");
    }

  }
  Future<String> pickDatabaseFile() async {
    String folderPath = 'undefined';
    String? filePath = await FilePicker.platform.pickFiles(
      type: FileType.any,
    ).then((result) => result?.files.single.path);
    if (filePath != null) {
      var pathParts = filePath.split('/');
      var name = pathParts.last;
      debugPrint('Name: $name');
      setName(name);
      pathParts.removeLast();
      folderPath = pathParts.join('/');
      debugPrint('folder path: $folderPath');
      setPath(folderPath);
      var databaseFactory = databaseFactoryFfi;
       debugPrint('file path: $filePath');
      _database = await databaseFactory.openDatabase(filePath);
    }
    return folderPath;
  }
  void initTables(){
    final List<String> columnsMembers = [
      'member_id INTEGER PRIMARY KEY AUTOINCREMENT',
      'game_name TEXT UNIQUE NOT NULL',
      'discord_name TEXT NOT NULL',
    ];
    final List<String> columnsRaids = [
      'raid_id INTEGER PRIMARY KEY AUTOINCREMENT',
      'title TEXT UNIQUE NOT NULL',
      'date TEXT UNIQUE NOT NULL',
      'season INTEGER UNIQUE NOT NULL CHECK (season >= 0)',
      'ranking INTEGER NOT NULL CHECK (ranking >= 0)',
    ];
    final List<String> columnsMir = [
      'member_id INTEGER',
      'raid_id INTEGER',
      'damage INTEGER NOT NULL CHECK (damage > 0)',
      'participation INTEGER NOT NULL CHECK (participation >= 0 AND participation <= 2121)',
      'PRIMARY KEY (member_id, raid_id)',
      'FOREIGN KEY (member_id) REFERENCES Members(member_id)'
      'FOREIGN KEY (raid_id) REFERENCES Raids(raid_id)',
    ];
    _members = DatabaseTable('Members', columnsMembers);
    _raids = DatabaseTable('Raids', columnsRaids);
    _membersInRaid = DatabaseTable('MembersInRaids', columnsMir);
  }
  void createTables(){
    _members.createTable(_database);
    _raids.createTable(_database);
    _membersInRaid.createTable(_database);
  }
  Future<void> addMember(String gameName, String discordName) async {
    final table = _members._tableName;
    try {
      await _database.transaction((txn) async {
        await txn.execute('INSERT INTO $table (game_name, discord_name) VALUES (?, ?)', [gameName.trim(), discordName.trim()]);
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        // Ignora o erro de violação de restrição única
        debugPrint('Ignoring UNIQUE CONSTRAINT FAILED error: $e');
      } else {
        // Lança a exceção novamente se não for uma violação de restrição única
        rethrow;
      }
    } catch (e) {
      debugPrint('ERROR:ADD:DATA: $e');
      rethrow;
    }
  }
  Future<void> addRaid(String title, String date, int season, int ranking) async{
    final table = _raids._tableName;
    // Expressão regular para verificar o formato MM/DD/YYYY e validar os elementos individualmente
    final RegExp dateRegExp = RegExp(r'^(0[1-9]|1[0-2])/(0[1-9]|[12][0-9]|3[01])/\d{4}$');
    if (!dateRegExp.hasMatch(date)) {
      throw const FormatException('Invalid date format. Please use MM/DD/YYYY format.');
    }

    try {
      await _database.transaction((txn) async {
        await txn.execute('INSERT INTO $table (title, date, season, ranking) VALUES (?, ?, ?, ?)', [title.trim(), date.trim(), season, ranking]);
      });
    } catch (e) {
      debugPrint('ERROR:ADD:DATA: $e');
      rethrow;
    }
  }
  int validateParticipation(String input) {
    int participation;

    // Verifica se a entrada é vazia.
    if (input.isEmpty) {
      debugPrint("ERROR: Empty input.");
      participation = -1;
      return participation;
    }

    try {
      // Converte a entrada para um inteiro.
      int newParticipation = int.parse(input);

      // Extrai os dois primeiros dígitos.
      int yy = newParticipation ~/ 100;
      // Extrai os dois últimos dígitos.
      int xx = newParticipation % 100;

      // Verifica se ambos os dígitos estão dentro dos limites esperados.
      if ((yy < 0 || yy > 21) || (xx < 0 || xx > 21)) {
        debugPrint("ERROR: Both YY and XX must be between 0 and 21.");
        participation = -1;
        return participation;
      }

      // Verifica se todos os dígitos estão dentro dos limites esperados.
      if (newParticipation < 0 || newParticipation > 2121) {
        debugPrint("ERROR: Input must be between 0 and 2121.");
        participation = -1;
        return participation;
      }

      participation = newParticipation;
      return participation;
    } catch (e) {
      debugPrint("ERROR: Invalid input.");
      participation = -1;
      return participation;
    }
  }

  Future<void> addMemberInRaid(String gameName, String title, int damage, String participation) async{
    final table = _membersInRaid._tableName;
    int validatedParticipation = validateParticipation(participation);

    try {
      final int mid = await _members.getID(_database, 'member_id', 'game_name', gameName.trim());
      final int rid = await _raids.getID(_database, 'raid_id', 'title', title.trim());

      await _database.transaction((txn) async {
        await txn.execute(
        'INSERT INTO $table (raid_id, member_id, damage, participation) VALUES (?, ?, ?, ?)',
        [rid, mid, damage, validatedParticipation],
      );
      });
    } catch (e) {
      debugPrint('ERROR:ADD:DATA: $e');
      rethrow;
    }
  }
  Future<void> removeMember(int memberId) async {
    try {
      // Consulta para excluir membros associados na tabela MembersInRaids
      await _database.execute('DELETE FROM MembersInRaids WHERE member_id = ?', [memberId]);
      // Consulta para excluir a entrada da raid na tabela Raids
      await _database.execute('DELETE FROM Members WHERE member_id = ?', [memberId]);
    } catch (e) {
      debugPrint("ERROR: REMOVE MEMBER: $e");
      rethrow;
    }
  }
  Future<void> removeRaid(int raidId) async {
    try {
      // Consulta para excluir membros associados na tabela MembersInRaids
      await _database.execute('DELETE FROM MembersInRaids WHERE raid_id = ?', [raidId]);
      // Consulta para excluir a entrada da raid na tabela Raids
      await _database.execute('DELETE FROM Raids WHERE raid_id = ?', [raidId]);
    } catch (e) {
      debugPrint("ERROR: REMOVE RAID: $e");
      rethrow;
    }
  }
  Future<void> removeMemberInRaid(int keyName, int keyTitle) async{
    final table = _membersInRaid._tableName;
    try {
      await _database.rawDelete(
        'DELETE FROM $table WHERE member_id = ? AND raid_id = ?',
        [keyName, keyTitle]
      );
    } catch (e) {
      debugPrint("ERROR: REMOVE: DATA: $e");
      rethrow;
    }
  }
  Future<void> updateMember(int memberId, {String? newGameName, String? newDiscordName}) async {
    var db = _database;
    var table = _members._tableName;
    Map<String, dynamic> valuesToUpdate = {};
    if (newGameName != null && newGameName.isNotEmpty) {
      valuesToUpdate['game_name'] = newGameName;
    }
    if (newDiscordName != null && newDiscordName.isNotEmpty) {
      valuesToUpdate['discord_name'] = newDiscordName;
    }
    if (valuesToUpdate.isNotEmpty) {
      await db.update(
        table,
        valuesToUpdate,
        where: 'member_id = ?',
        whereArgs: [memberId],
      );
    }
  }

  Future<void> updateRaid(int raidId, {String? newTitle, String? newDate, int? newSeason, int? newRanking}) async {
    var db = _database;
    var table = _raids._tableName;
    Map<String, dynamic> valuesToUpdate = {};
    if (newTitle != null && newTitle.isNotEmpty) {
      valuesToUpdate['title'] = newTitle;
    }
    if (newDate != null && newDate.isNotEmpty) {
      valuesToUpdate['date'] = newDate;
    }
    if (newSeason != null && newSeason >= 0) {
      valuesToUpdate['season'] = newSeason;
    }
    if (newRanking != null && newRanking >= 0) {
      valuesToUpdate['ranking'] = newRanking;
    }
    if (valuesToUpdate.isNotEmpty) {
      await db.update(
        table,
        valuesToUpdate,
        where: 'raid_id = ?',
        whereArgs: [raidId],
      );
    }
  }

  Future<void> updateMemberInRaid(int memberId, int raidId, {int? newDamage, String? newParticipation}) async {
    var db = _database;
    var table = _membersInRaid._tableName;

    // Validar e tratar newParticipation
    int validatedParticipation = validateParticipation(newParticipation ?? 'undefined');

    // Construir o mapa de valores a serem atualizados
    Map<String, dynamic> valuesToUpdate = {};

    // Adicionar damage se for válido
    if (newDamage != null && newDamage > 0) {
      valuesToUpdate['damage'] = newDamage;
    }

    // Adicionar participation se for válido
    if (validatedParticipation >= 0 && validatedParticipation <= 2121) {
      valuesToUpdate['participation'] = validatedParticipation;
    }

    // Verificar se há algo para atualizar
    if (valuesToUpdate.isNotEmpty) {
      await db.update(
        table,
        valuesToUpdate,
        where: 'member_id = ? AND raid_id = ?',
        whereArgs: [memberId, raidId],
      );
    }
  }

  Future<int> getMemberID(String gameName) async{
    return await _members.getID(_database, 'member_id', 'game_name', gameName);
  } 
  Future<int> getRaidID(String title) async{
    return await _raids.getID(_database, 'raid_id', 'title', title);
  }
  Future<List<List<String>>> getMembersData() async {
    var data = await _members.getData(_database);

    // Ordena a lista de membros alfabeticamente pelo segundo elemento (nome), ignorando diferenças de maiúsculas e minúsculas
    data.sort((a, b) => a[1].toLowerCase().compareTo(b[1].toLowerCase()));

    // Obtém o total de membros
    int totalMembers = data.length;
    List<String> totalMembersInfo = ['Total registered members:', totalMembers.toString()];

    // Adiciona a informação total de membros à lista
    data.add(totalMembersInfo);

    return data;
  }
  Future<List<List<String>>>getRaidsData()async{
    var data = await _raids.getData(_database);
    // Ordenar os dados pelo último número de cada linha
    data.sort((b, a) {
      // Obter a coluna 3 de cada linha (season) e ordenar de forma decrescente
      int seasonA = int.parse(a[3]);
      int seasonB = int.parse(b[3]);    
      // Comparar os últimos números e retornar o resultado da comparação
      return seasonA.compareTo(seasonB);
    });
    int totalRaids = data.length;
    List<String> totalRaidsInfo = ['Total registered raids:', totalRaids.toString()];
    data.add(totalRaidsInfo);
    return data;
  }
  Future<List<List<String>>> getMembersInRaidsData() async {
    return await _membersInRaid.getData(_database);
  }
  Future<List<List<String>>> getRaidStats(String title) async {
    var db = _database;
    int raidID = await  _raids.getID(_database, 'raid_id', 'title', title);
    try {
      const String sqlRaids = "SELECT * FROM Raids WHERE raid_id = ?;";
      const String sqlMembersInRaids = "SELECT m.game_name, mi.damage, mi.participation "
          "FROM MembersInRaids mi INNER JOIN Members m ON mi.member_id = m.member_id "
          "WHERE mi.raid_id = ? ORDER BY mi.damage DESC;";

      List<List<String>> raidLog = [];

      // Consulta para a tabela Raids
      List<Map<String, dynamic>> raidResult = await db.rawQuery(sqlRaids, [raidID]);

      for (Map<String, dynamic> row in raidResult) {
        String title = row['title'].toString();
        String date = row['date'].toString();
        int season = row['season'] as int;
        int raidRanking = row['ranking'] as int;
        //double participationRate = row['ParticipationRate'] as double;
        //int overallDamage = row['OverallDamage'] as int;
        DateTime dateDT = DateFormat("MM/dd/yyyy").parse(date);
        // Adicionar 7 dias à data
        DateTime datePlus7Days = dateDT.add(const Duration(days: 6));
        var datePlus7DaysFormated = DateFormat("MM/dd/yyyy").format(datePlus7Days);
        // Header
        raidLog.add([title, '$date - $datePlus7DaysFormated', "S$season", 'R$raidRanking']);
        //raidLog.add(["Participation Rate: ${participationRate.toStringAsFixed(2)}%", "Overall Damage: ${overallDamage.toString()}"]);

        // Consulta para a tabela MembersInRaids
        List<Map<String, dynamic>> membersInRaidsResult = await db.rawQuery(sqlMembersInRaids, [raidID]);

        int index = 1;
        int overallDamage = 0;
        int participationSum = 0;
        int overallParticipation = 0;
        for (Map<String, dynamic> memberRow in membersInRaidsResult) {
          String gameName = memberRow['game_name'].toString();
          int damage = memberRow['damage'] as int;
          int participation = memberRow['participation'] as int;

          int firstTwoDigits = participation ~/ 100;
          int lastTwoDigits = participation % 100;
          String formattedParticipation = "$firstTwoDigits/$lastTwoDigits";
          NumberFormat formatter = NumberFormat("#,###");
          String formatedDamage =formatter.format(damage);

          raidLog.add(["$index.", gameName, formatedDamage, formattedParticipation]);
          index++;
          overallDamage += damage;
          participationSum += firstTwoDigits;
          overallParticipation += lastTwoDigits;
        }
        double participationRate = participationSum/overallParticipation;
        double participationPercent = participationRate*100;
        NumberFormat formatter = NumberFormat('#,###');
        String formatedOverallDamage = formatter.format(overallDamage);
        String formatedParticipationPercent = participationPercent.toStringAsFixed(2);
        raidLog.add(['Participation rate: $formatedParticipationPercent%']);
        raidLog.add(['Overall damage: $formatedOverallDamage']);
      }
      return raidLog;
    } catch (e) {
      debugPrint("ERROR: PRINT RAID LOG: $e");
      rethrow;
    }
  }
  Future<List<List<String>>> getTopDamageRanking({bool filterActive = false}) async {
    try {
      String sqlGetAllMembers;
      if (filterActive) {
        sqlGetAllMembers = """
          SELECT member_id 
          FROM Members 
          WHERE member_id IN (
            SELECT member_id 
            FROM MembersInRaids 
            WHERE raid_id = (
              SELECT raid_id 
              FROM Raids 
              ORDER BY season DESC
              LIMIT 1
            )
          );
        """;
        
      } else {
        sqlGetAllMembers = "SELECT member_id FROM Members;";
      }
      List<Map<String, dynamic>> allMembersResult = await _database.rawQuery(sqlGetAllMembers);
      int top = allMembersResult.length;
      List<List<String>> topDamageRanking = [];
      if(filterActive){
        topDamageRanking.add(['Top $top Best Damages for each active member: ']);
      }
      else{
        topDamageRanking.add(['Top $top Best Damages for each member: ']); 
      }
      
      int ranking = 1;
      // Lista para armazenar temporariamente os resultados antes de ordená-los
      List<Map<String, dynamic>> unsortedRanking = [];

      for (Map<String, dynamic> memberRow in allMembersResult) {
        String memberID = memberRow['member_id'].toString();
        const String sqlMemberRaidStats = "SELECT mi.raid_id, MAX(mi.damage) AS MaxDamage, r.title AS RaidTitle "
            "FROM MembersInRaids mi "
            "INNER JOIN Raids r ON mi.raid_id = r.raid_id "
            "WHERE mi.member_id = ? "
            "GROUP BY mi.member_id;";
        List<Map<String, dynamic>> memberRaidStatsResult = await _database.rawQuery(sqlMemberRaidStats, [memberID]);
        // Se o membro não participou de nenhuma raid, ele não estará incluído no ranking
        if (memberRaidStatsResult.isNotEmpty) {
          int maxDamage = memberRaidStatsResult[0]['MaxDamage'] as int;
          String name = await getMemberName(memberID);
          String raidTitle = memberRaidStatsResult[0]['RaidTitle'] as String;
          unsortedRanking.add({
            'name': name,
            'maxDamage': maxDamage,
            'raidTitle': raidTitle,
          });
        }
      }
      // Ordena os resultados pelo dano máximo em ordem decrescente
      unsortedRanking.sort((a, b) => b['maxDamage'].compareTo(a['maxDamage']));
      // Monta o ranking ordenando-o pelo ranking em ordem crescente
      NumberFormat formatter = NumberFormat("#,###");
      String formatedMaxDamage;
      for (var entry in unsortedRanking) {
        formatedMaxDamage = formatter.format(entry['maxDamage']);
        if (filterActive){
          topDamageRanking.add(['$ranking.', entry['name'], entry['maxDamage'] = formatedMaxDamage]);
        }
        else{
          topDamageRanking.add(['$ranking.', entry['name'], entry['maxDamage'] = formatedMaxDamage, entry['raidTitle']]);
        }   
        ranking += 1;
      }
      return topDamageRanking;
    } catch (e) {
      debugPrint("ERROR: PRINT TOP DAMAGE RANKING: $e");
      rethrow;
    }
  }
  /// This functions get member statistics based on is name.
  ///
  ///Args:
  /// - name: String containing the member name.
  /// 
  /// Returns:
  /// - A list containing: [name, overal_particioation_rate, last_raid_participation, last_raid_title]
  /// Retorna o produto dos números [a] e [b].
  Future<List<List<String>>> getMembersStats(String name, {bool includeRaids = false}) async {
  var db = _database;
  final member = await db.query(
    'Members',
    columns: ['member_id', 'game_name', 'discord_name'],
    where: 'game_name = ?',
    whereArgs: [name],
  );

  if (member.isEmpty) {
    throw Exception('Member not found');
  }

  final memberId = member.first['member_id'] as int;
  final memberName = member.first['game_name'] as String;
  final discordName = member.first['discord_name'] as String?;

  // Consulta para obter as informações de participação do membro em raids
  final memberRaids = await db.query(
    'MembersInRaids',
    columns: ['raid_id', 'damage', 'participation'],
    where: 'member_id = ?',
    whereArgs: [memberId],
  );

  if (memberRaids.isEmpty) {
    throw Exception('No raid participation found for member');
  }

  int totalParticipation = 0;
  int totalPossibleParticipation = 0;
  int totalDamage = 0;
  int raidsCount = memberRaids.length;
  int latestRaidSeason = -1;
  List<List<String>> raidDetails = [];

  for (var raid in memberRaids) {
    // Ignora entradas com raid_id = -1
    final raidId = raid['raid_id'] as int;
    if (raidId == -1) {
      debugPrint('Ignoring raid with raid_id = -1');
      continue;
    }
    final participation = raid['participation'] as int;
    final damage = raid['damage'] as int;
    final participationDone = participation ~/ 100;
    final participationPossible = participation % 100;
    final formatedParticipation = '$participationDone/$participationPossible';

    totalParticipation += participationDone;
    totalPossibleParticipation += participationPossible;
    totalDamage += damage;

    // Consulta para obter o número e título da raid
    final raidInfo = await db.query(
      'Raids',
      columns: ['season', 'title'],
      where: 'raid_id = ?',
      whereArgs: [raidId],
    );

    if (raidInfo.isEmpty) {
      debugPrint('No raid information found for raid_id: $raidId');
      continue;  // Pula para a próxima iteração se não houver informações da raid
    }

    final raidSeason = raidInfo.first['season'] as int;
    final raidTitle = raidInfo.first['title'] as String;

    raidDetails.add([raidSeason.toString(), raidTitle, NumberFormat.decimalPattern().format(damage), formatedParticipation]);

    if (raidSeason > latestRaidSeason) {
      latestRaidSeason = raidSeason;
    }
  }

  // Verificação para garantir que o valor final é lógico
  if (totalPossibleParticipation == 0) {
    throw Exception('Invalid total possible participation');
  }

  // Calcula a taxa de participação
  final overallParticipation = (totalParticipation / totalPossibleParticipation) * 100;

  // Formata o valor de dano com vírgulas a cada três casas
  final formattedTotalDamage = NumberFormat.decimalPattern().format(totalDamage);

  // Formata a participação total acumulada
  final formattedTotalParticipation = '$totalParticipation/$totalPossibleParticipation';

  // Cria a lista de resultados
  List<String> result = [
    memberName,
    discordName ?? 'N/A',
    raidsCount.toString(),
    '${overallParticipation.toStringAsFixed(2)}%', // Adiciona o símbolo de porcentagem
    formattedTotalParticipation,
    formattedTotalDamage,
  ];

  // Adiciona os detalhes das raids se solicitado
  List<List<String>> finalResult = [result];
  if (includeRaids) {
    // Ordena as raids pelo número da temporada em ordem decrescente
    raidDetails.sort((a, b) => int.parse(b[0]).compareTo(int.parse(a[0])));
    finalResult.addAll(raidDetails);
  }

  return finalResult;
}

  Future<List<List<String>>> getParticipationRankings() async {
    var db = _database;

    // Consulta para obter a temporada mais alta
    final latestRaid = await db.query(
      'Raids',
      columns: ['season', 'title'],
      orderBy: 'season DESC',
      limit: 1,
    );

    if (latestRaid.isEmpty) {
      throw Exception('No raids found');
    }

    final latestSeason = latestRaid.first['season'] as int;
    final latestTitle = latestRaid.first['title'] as String;

    // Consulta para obter as participações dos membros na última raid disponível
    final latestRaidParticipations = await db.rawQuery('''
      SELECT m.game_name, mir.participation
      FROM MembersInRaids mir
      JOIN Members m ON mir.member_id = m.member_id
      JOIN Raids r ON mir.raid_id = r.raid_id
      WHERE r.season = ?
    ''', [latestSeason]);

    // Fazer uma cópia mutável dos resultados da consulta
    List<Map<String, dynamic>> latestRaidParticipationsCopy = List.from(latestRaidParticipations);

    // Classifica as participações na última raid
    latestRaidParticipationsCopy.sort((a, b) => ((b['participation'] as int) ~/ 100).compareTo((a['participation'] as int) ~/ 100));

    List<List<String>> latestSeasonRanking = [
      ['Season $latestTitle participation ranking for ${latestRaidParticipationsCopy.length} active members:']
    ];
    for (int i = 0; i < latestRaidParticipationsCopy.length; i++) {
      final participation = latestRaidParticipationsCopy[i]['participation'] as int;
      final participationRealized = participation ~/ 100;
      final participationPossible = participation % 100;
      final percentage = (participationRealized / participationPossible) * 100;
      final gameName = latestRaidParticipationsCopy[i]['game_name'] as String;
      latestSeasonRanking.add([
        '${i + 1}.',
        gameName,
        '$participationRealized/$participationPossible',
        '${percentage.toStringAsFixed(2)}%'
      ]);
    }

    // Consulta para obter as participações gerais dos membros em todas as raids
    final overallParticipations = await db.rawQuery('''
      SELECT m.game_name, SUM(mir.participation) as totalParticipation
      FROM MembersInRaids mir
      JOIN Members m ON mir.member_id = m.member_id
      GROUP BY m.Game_name
    ''');

    // Fazer uma cópia mutável dos resultados da consulta
    List<Map<String, dynamic>> overallParticipationsCopy = List.from(overallParticipations);

    // Classifica as participações gerais
    overallParticipationsCopy.sort((a, b) => ((b['totalParticipation'] as int) ~/ 100).compareTo((a['totalParticipation'] as int) ~/ 100));

    List<List<String>> overallRanking = [
      ['Overall participation ranking for all ${overallParticipationsCopy.length} members:']
    ];
    for (int i = 0; i < overallParticipationsCopy.length; i++) {
      final totalParticipation = overallParticipationsCopy[i]['totalParticipation'] as int;
      final participationRealized = totalParticipation ~/ 100;
      final participationPossible = totalParticipation % 100;
      final percentage = (participationRealized / participationPossible) * 100;
      final gameName = overallParticipationsCopy[i]['game_name'] as String;
      overallRanking.add([
        '${i + 1}.',
        gameName,
        '$participationRealized/$participationPossible',
        '${percentage.toStringAsFixed(2)}%'
      ]);
    }

    // Retorna a lista de listas combinada
    return [
      ...latestSeasonRanking,
      //...overallRanking,
    ];
  }

  Future<List<List<String>>> getAccumulatedDamageRanking() async {
  var db = _database;

  // Consulta para obter o dano acumulado de cada membro
  final accumulatedDamage = await db.rawQuery('''
    SELECT m.game_name, COUNT(mir.raid_id) as raidCount, SUM(mir.damage) as totalDamage
    FROM MembersInRaids mir
    JOIN Members m ON mir.member_id = m.member_id
    GROUP BY m.Game_name
  ''');

  // Fazer uma cópia mutável dos resultados da consulta
  List<Map<String, dynamic>> accumulatedDamageCopy = List.from(accumulatedDamage);

  // Classifica o dano acumulado de forma decrescente
  accumulatedDamageCopy.sort((a, b) => (b['totalDamage'] as int).compareTo(a['totalDamage'] as int));

  // Lista para armazenar o ranking de dano acumulado
  List<List<String>> ranking = [
    ['Acumulated damage ranking for all ${accumulatedDamageCopy.length} members:']
  ];
  for (int i = 0; i < accumulatedDamageCopy.length; i++) {
    final gameName = accumulatedDamageCopy[i]['game_name'] as String;
    final raidCount = accumulatedDamageCopy[i]['raidCount'] as int;
    final totalDamage = accumulatedDamageCopy[i]['totalDamage'] as int;
    ranking.add([
      '${i + 1}.',
      gameName,
      raidCount.toString(),
      NumberFormat.decimalPattern().format(totalDamage),
    ]);
  }

  // Retorna o ranking de dano acumulado
  return ranking;
}


  Future<String> getMemberName(String memberID) async {
    const String sqlGetMemberName = "SELECT game_name FROM Members WHERE member_id = ?;";
    List<Map<String, dynamic>> result = await _database.rawQuery(sqlGetMemberName, [memberID]);

    if (result.isNotEmpty) {
      return result[0]['game_name'].toString();
    } else {
      return 'Unknown';
    }
  }

  Future<List<List<String>>> membersToUpdateBadges({bool onlyBadgesToUpdate = false}) async {
    // Step 1: Get the last season number
    var db = _database;
    const lastSeasonQuery = '''
      SELECT MAX(season) as last_season FROM Raids
    ''';
    final lastSeasonResult = await db.rawQuery(lastSeasonQuery);
    final lastSeason = lastSeasonResult.first['last_season'] as int;

    // Step 2: Get member_id and damage in the last raid
    const lastRaidMembersQuery = '''
      SELECT member_id, damage FROM MembersInRaids 
      JOIN Raids ON MembersInRaids.raid_id = Raids.raid_id
      WHERE Raids.season = ?
    ''';
    final lastRaidMembersResult = await db.rawQuery(lastRaidMembersQuery, [lastSeason]);

    // Step 3: Prepare the list to store members that need badge updates
    List<List<String>> membersToUpdate = [];

    if(onlyBadgesToUpdate){
      //header
      membersToUpdate.add(["Members to update badges: "]);
    }
    else{
      //header
      membersToUpdate.add(["Members that did improve in the last raid: "]);
    }

    // member count
    var memberCount = 0;

    // Step 4: Iterate through each member in the last raid
    for (final member in lastRaidMembersResult) {
      final memberId = member['member_id'] as int;
      final currentDamage = member['damage'] as int;

      // Step 5: Get the highest damage in previous raids for this member
      const highestDamageQuery = '''
        SELECT MAX(damage) as highest_damage FROM MembersInRaids 
        JOIN Raids ON MembersInRaids.raid_id = Raids.raid_id
        WHERE member_id = ? AND Raids.season < ?
      ''';
      final highestDamageResult = await db.rawQuery(highestDamageQuery, [memberId, lastSeason]);
      final highestDamage = (highestDamageResult.first['highest_damage'] ?? 0) as int;

      // Step 6: Compare damages and decide if the badge needs to be updated
      if(onlyBadgesToUpdate){
        // Round down the highest damage to the nearest 100,000,000
        final roundedHighestDamage = (highestDamage ~/ 100000000) * 100000000;
        if (currentDamage - roundedHighestDamage > 100000000) {
          // Get the member's name
          const memberNameQuery = '''
            SELECT game_name FROM Members WHERE member_id = ?
          ''';
          final memberNameResult = await db.rawQuery(memberNameQuery, [memberId]);
          final memberName = memberNameResult.first['game_name'] as String;

          // Format damages with commas
          final formattedHighestDamage = NumberFormat.decimalPattern().format(highestDamage);
          final formattedCurrentDamage = NumberFormat.decimalPattern().format(currentDamage);

          // Add to the list
          membersToUpdate.add([
            memberName,
            formattedHighestDamage.toString(),
            '=>',
            formattedCurrentDamage.toString()
          ]);
          memberCount++;
        }
      }
      else{
        if (currentDamage > highestDamage) {
          // Get the member's name
          const memberNameQuery = '''
            SELECT game_name FROM Members WHERE member_id = ?
          ''';
          final memberNameResult = await db.rawQuery(memberNameQuery, [memberId]);
          final memberName = memberNameResult.first['game_name'] as String;

          // Format damages with commas
          final formattedHighestDamage = NumberFormat.decimalPattern().format(highestDamage);
          final formattedCurrentDamage = NumberFormat.decimalPattern().format(currentDamage);

          // Add to the list
          membersToUpdate.add([
            memberName,
            formattedHighestDamage.toString(),
            '=>',
            formattedCurrentDamage.toString()
          ]);
          memberCount++;
        }
      }
    }
  membersToUpdate.add(["Members count: $memberCount"]);
  // Step 7: Return the list of members to update
  return membersToUpdate;
  }
}