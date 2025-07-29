import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:bm25/bm25.dart';
import 'dart:async';

/// Main entry point for the MCP server
void main(List<String> arguments) async {
  if (arguments.length != 1) {
    print('Usage: dart run purplestack_mcp.dart <content-zip-path>');
    exit(1);
  }

  final contentZipPath = arguments[0];
  final server = PurpleStackMcpServer(contentZipPath);

  try {
    await server.initialize();
    server.start();
  } catch (e) {
    stderr.writeln('Failed to initialize server: $e');
    exit(1);
  }
}

/// MCP server that serves recipes and API documentation
class PurpleStackMcpServer {
  final String contentZipPath;
  late McpServer _server;

  // Content storage - now using full paths as keys
  final Map<String, String> _recipes = {};
  final Map<String, String> _docs = {};

  // Search indexes
  BM25? _recipeSearchIndex;
  BM25? _docSearchIndex;
  List<String> _recipePaths = [];
  List<String> _docPaths = [];

  PurpleStackMcpServer(this.contentZipPath);

  /// Initialize the server and load content
  Future<void> initialize() async {
    // Create MCP server
    _server = McpServer(
      name: 'Purplestack Context Server',
      version: '1.0.0',
      instructions:
          'A server providing Purplestack recipes and API documentation for AI-powered development assistance.',
    );

    // Load content from zip file
    await _loadContent();

    // Build search indexes
    await _buildSearchIndexes();

    // Register tools
    _registerTools();
  }

  /// Start the MCP server
  void start() {
    _server.start();
  }

  /// Load content from the zip file
  Future<void> _loadContent() async {
    final file = File(contentZipPath);
    if (!file.existsSync()) {
      throw Exception('Content zip file not found: $contentZipPath');
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      if (file.isFile &&
          (file.name.endsWith('.md') || file.name.endsWith('.html'))) {
        final content = utf8.decode(file.content as List<int>);

        if (file.name.startsWith('recipes/')) {
          // Use full path as key, removing only the 'recipes/' prefix
          final recipePath = file.name.substring('recipes/'.length);
          _recipes[recipePath] = content;
        } else if (file.name.startsWith('api-docs/')) {
          // Use full path as key, removing only the 'api-docs/' prefix
          final docPath = file.name.substring('api-docs/'.length);
          _docs[docPath] = content;
        }
      }
    }
  }

  /// Build search indexes for recipes and docs
  Future<void> _buildSearchIndexes() async {
    if (_recipes.isNotEmpty) {
      // Build recipe search index
      _recipePaths = _recipes.keys.toList();
      final recipeDocuments = _recipes.entries.map((entry) {
        return '${entry.key} ${entry.value}';
      }).toList();
      _recipeSearchIndex = await BM25.build(recipeDocuments);
    }

    if (_docs.isNotEmpty) {
      // Build docs search index
      _docPaths = _docs.keys.toList();
      final docDocuments = _docs.entries.map((entry) {
        return '${entry.key} ${entry.value}';
      }).toList();
      _docSearchIndex = await BM25.build(docDocuments);
    }
  }

  /// Register all tools with the MCP server
  void _registerTools() {
    // List recipes tool
    _server.registerTool(
      McpTool(
        name: 'list_recipes',
        description: 'List all available recipes',
        inputSchema: {'type': 'object', 'properties': {}},
        handler: _listRecipes,
      ),
    );

    // Read recipe tool
    _server.registerTool(
      McpTool(
        name: 'read_recipe',
        description: 'Read a specific recipe by name',
        inputSchema: {
          'type': 'object',
          'properties': {
            'name': {
              'type': 'string',
              'description': 'Name of the recipe to read',
            },
          },
          'required': ['name'],
        },
        handler: _readRecipe,
      ),
    );

    // Search recipes tool
    _server.registerTool(
      McpTool(
        name: 'search_recipes',
        description: 'Search recipes by query',
        inputSchema: {
          'type': 'object',
          'properties': {
            'query': {
              'type': 'string',
              'description': 'Search query for recipes',
            },
          },
          'required': ['query'],
        },
        handler: _searchRecipes,
      ),
    );

    // List docs tool
    _server.registerTool(
      McpTool(
        name: 'list_docs',
        description: 'List all available documentation',
        inputSchema: {'type': 'object', 'properties': {}},
        handler: _listDocs,
      ),
    );

    // Read doc tool
    _server.registerTool(
      McpTool(
        name: 'read_doc',
        description: 'Read a specific document by name',
        inputSchema: {
          'type': 'object',
          'properties': {
            'name': {
              'type': 'string',
              'description': 'Name of the document to read',
            },
          },
          'required': ['name'],
        },
        handler: _readDoc,
      ),
    );

    // Search docs tool
    _server.registerTool(
      McpTool(
        name: 'search_docs',
        description: 'Search documentation by query',
        inputSchema: {
          'type': 'object',
          'properties': {
            'query': {
              'type': 'string',
              'description': 'Search query for documentation',
            },
          },
          'required': ['query'],
        },
        handler: _searchDocs,
      ),
    );
  }

  // Tool handlers

  Future<String> _listRecipes(Map<String, dynamic> arguments) async {
    if (_recipes.isEmpty) {
      return 'No recipes available.';
    }

    final recipeList = _recipes.keys.toList()..sort();
    return 'Available recipes:\n${recipeList.map((path) => '- $path').join('\n')}';
  }

  Future<String> _readRecipe(Map<String, dynamic> arguments) async {
    final name = arguments['name'] as String?;
    if (name == null) {
      return 'Error: Recipe name is required';
    }

    // Try exact match first
    var recipe = _recipes[name];
    if (recipe != null) {
      return recipe;
    }

    // Try partial match for backwards compatibility
    final matchingKeys = _recipes.keys
        .where(
          (key) =>
              key.toLowerCase().contains(name.toLowerCase()) ||
              path.basenameWithoutExtension(key).toLowerCase() ==
                  name.toLowerCase(),
        )
        .toList();

    if (matchingKeys.length == 1) {
      return _recipes[matchingKeys.first]!;
    } else if (matchingKeys.length > 1) {
      return 'Multiple recipes found. Please be more specific:\n${matchingKeys.map((key) => '- $key').join('\n')}';
    }

    final suggestions = _findSimilarKeys(name, _recipes.keys.toList());
    final suggestionText = suggestions.isNotEmpty
        ? '\n\nDid you mean: ${suggestions.join(', ')}?'
        : '';
    return 'Recipe "$name" not found.$suggestionText';
  }

  Future<String> _searchRecipes(Map<String, dynamic> arguments) async {
    final query = arguments['query'] as String?;
    if (query == null || query.isEmpty) {
      return 'Error: Search query is required';
    }

    if (_recipeSearchIndex == null) {
      return 'Search index not available';
    }

    final results = await _recipeSearchIndex!.search(query);
    if (results.isEmpty) {
      return 'No recipes found for query: "$query"';
    }

    // Build documents list for index lookup
    final recipeDocuments = _recipes.entries.map((entry) {
      return '${entry.key} ${entry.value}';
    }).toList();

    final resultText = StringBuffer('Search results for "$query":\n\n');
    for (final result in results.take(5)) {
      final index = recipeDocuments.indexOf(result.doc.text);
      if (index != -1) {
        final recipePath = _recipePaths[index];
        final score = result.score.toStringAsFixed(2);
        resultText.writeln('$recipePath ($score)');
      }
    }

    return resultText.toString().trim();
  }

  Future<String> _listDocs(Map<String, dynamic> arguments) async {
    if (_docs.isEmpty) {
      return 'No documentation available.';
    }

    final docList = _docs.keys.toList()..sort();
    return 'Available documentation:\n${docList.map((path) => '- $path').join('\n')}';
  }

  Future<String> _readDoc(Map<String, dynamic> arguments) async {
    final name = arguments['name'] as String?;
    if (name == null) {
      return 'Error: Document name is required';
    }

    // Try exact match first
    var doc = _docs[name];
    if (doc != null) {
      return doc;
    }

    // Try partial match for backwards compatibility
    final matchingKeys = _docs.keys
        .where(
          (key) =>
              key.toLowerCase().contains(name.toLowerCase()) ||
              path.basenameWithoutExtension(key).toLowerCase() ==
                  name.toLowerCase(),
        )
        .toList();

    if (matchingKeys.length == 1) {
      return _docs[matchingKeys.first]!;
    } else if (matchingKeys.length > 1) {
      return 'Multiple documents found. Please be more specific:\n${matchingKeys.map((key) => '- $key').join('\n')}';
    }

    final suggestions = _findSimilarKeys(name, _docs.keys.toList());
    final suggestionText = suggestions.isNotEmpty
        ? '\n\nDid you mean: ${suggestions.join(', ')}?'
        : '';
    return 'Document "$name" not found.$suggestionText';
  }

  Future<String> _searchDocs(Map<String, dynamic> arguments) async {
    final query = arguments['query'] as String?;
    if (query == null || query.isEmpty) {
      return 'Error: Search query is required';
    }

    if (_docSearchIndex == null) {
      return 'Search index not available';
    }

    final results = await _docSearchIndex!.search(query);
    if (results.isEmpty) {
      return 'No documentation found for query: "$query"';
    }

    // Build documents list for index lookup
    final docDocuments = _docs.entries.map((entry) {
      return '${entry.key} ${entry.value}';
    }).toList();

    final resultText = StringBuffer('Search results for "$query":\n\n');
    for (final result in results.take(5)) {
      final index = docDocuments.indexOf(result.doc.text);
      if (index != -1) {
        final docPath = _docPaths[index];
        final score = result.score.toStringAsFixed(2);
        resultText.writeln('$docPath ($score)');
      }
    }

    return resultText.toString().trim();
  }

  /// Find similar keys for suggestions
  List<String> _findSimilarKeys(String input, List<String> keys) {
    final inputLower = input.toLowerCase();
    return keys
        .where(
          (key) =>
              key.toLowerCase().contains(inputLower) ||
              inputLower.contains(key.toLowerCase()) ||
              path
                  .basenameWithoutExtension(key)
                  .toLowerCase()
                  .contains(inputLower),
        )
        .take(3)
        .toList();
  }
}

/// Minimal MCP framework for stdio-only servers
class McpServer {
  final String name;
  final String version;
  final String? instructions;

  final Map<String, McpTool> _tools = {};
  final StreamController<String> _outputController = StreamController<String>();

  McpServer({required this.name, required this.version, this.instructions});

  /// Register a tool with the server
  void registerTool(McpTool tool) {
    _tools[tool.name] = tool;
  }

  /// Start the MCP server over stdio
  void start() {
    // Set up output stream to stdout
    _outputController.stream.listen((response) {
      stdout.writeln(response);
      stdout.flush();
    });

    // Listen to stdin for JSON-RPC requests
    stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.trim().isNotEmpty)
        .listen(
          _handleRequestLine,
          onError: (error) {
            stderr.writeln('Error reading stdin: $error');
          },
        );
  }

  /// Handle incoming JSON-RPC request line
  void _handleRequestLine(String line) async {
    try {
      final requestJson = jsonDecode(line) as Map<String, dynamic>;
      await _handleRequest(requestJson);
    } catch (e) {
      stderr.writeln('Error parsing JSON: $e');
      _sendError(null, -32700, 'Parse error', null);
    }
  }

  /// Handle a JSON-RPC request
  Future<void> _handleRequest(Map<String, dynamic> request) async {
    final method = request['method'] as String?;
    final params = request['params'] as Map<String, dynamic>?;
    final id = request['id'];

    if (method == null) {
      _sendError(id, -32600, 'Invalid Request', null);
      return;
    }

    try {
      Map<String, dynamic>? result;

      switch (method) {
        case 'initialize':
          result = _handleInitialize(params);
          break;
        case 'initialized':
          // No response needed for notification
          return;
        case 'ping':
          result = {};
          break;
        case 'tools/list':
          result = _handleToolsList();
          break;
        case 'tools/call':
          result = await _handleToolCall(params);
          break;
        default:
          _sendError(id, -32601, 'Method not found', {'method': method});
          return;
      }

      _sendResult(id, result);
    } catch (e) {
      _sendError(id, -32603, 'Internal error', {'error': e.toString()});
    }
  }

  /// Handle initialize request
  Map<String, dynamic> _handleInitialize(Map<String, dynamic>? params) {
    return {
      'protocolVersion': '2024-11-05',
      'capabilities': {
        'tools': {'listChanged': true},
      },
      'serverInfo': {'name': name, 'version': version},
      if (instructions != null) 'instructions': instructions,
    };
  }

  /// Handle tools/list request
  Map<String, dynamic> _handleToolsList() {
    return {
      'tools': _tools.values
          .map(
            (tool) => {
              'name': tool.name,
              'description': tool.description,
              'inputSchema': tool.inputSchema,
            },
          )
          .toList(),
    };
  }

  /// Handle tools/call request
  Future<Map<String, dynamic>> _handleToolCall(
    Map<String, dynamic>? params,
  ) async {
    if (params == null) {
      throw Exception('Missing parameters for tools/call');
    }

    final toolName = params['name'] as String?;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};

    if (toolName == null) {
      throw Exception('Missing tool name');
    }

    final tool = _tools[toolName];
    if (tool == null) {
      throw Exception('Tool not found: $toolName');
    }

    try {
      final result = await tool.handler(arguments);
      return {
        'content': [
          {'type': 'text', 'text': result},
        ],
      };
    } catch (e) {
      return {
        'content': [
          {'type': 'text', 'text': 'Error: $e'},
        ],
        'isError': true,
      };
    }
  }

  /// Send successful result
  void _sendResult(dynamic id, Map<String, dynamic>? result) {
    final response = {'jsonrpc': '2.0', 'id': id, 'result': result};
    _outputController.add(jsonEncode(response));
  }

  /// Send error response
  void _sendError(dynamic id, int code, String message, dynamic data) {
    final response = {
      'jsonrpc': '2.0',
      'id': id,
      'error': {
        'code': code,
        'message': message,
        if (data != null) 'data': data,
      },
    };
    _outputController.add(jsonEncode(response));
  }
}

/// Represents an MCP tool
class McpTool {
  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;
  final Future<String> Function(Map<String, dynamic> arguments) handler;

  McpTool({
    required this.name,
    required this.description,
    required this.inputSchema,
    required this.handler,
  });
}
