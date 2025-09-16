import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:toml/toml.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.')
    ..addOption(
      'input',
      abbr: 'i',
      help: 'Path to the TOML configuration file.',
    )
    ..addOption(
      'output',
      abbr: 'o',
      help:
          'Path to the output directory where the electron project will be created.',
      defaultsTo: 'dist/electron_app',
    )
    ..addOption(
      'template',
      abbr: 't',
      help: 'Path to the electron app template directory.',
      defaultsTo: 'electron_app_template',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart kids_standalone_website.dart <flags> [arguments]');
  print(argParser.usage);
}

/// Copies a directory recursively to a destination path
Future<void> copyDirectory(Directory source, Directory destination) async {
  if (!await destination.exists()) {
    await destination.create(recursive: true);
  }

  await for (final entity in source.list(recursive: false)) {
    final String newPath = path.join(
      destination.path,
      path.relative(entity.path, from: source.path),
    );

    if (entity is File) {
      final newFile = File(newPath);
      await newFile.create(recursive: true);
      await entity.copy(newPath);
    } else if (entity is Directory) {
      final newDirectory = Directory(newPath);
      await newDirectory.create(recursive: true);
      await copyDirectory(entity, newDirectory);
    }
  }
}

/// Replaces placeholders in the index.js file with values from the TOML file
Future<void> updateIndexJs(
  File indexJsFile,
  Map<String, dynamic> tomlData,
) async {
  String content = await indexJsFile.readAsString();

  // Set initial URL from TOML file (default to editor.construct.net if not specified)
  content = content.replaceAll(
    'INITIAL_URL_TO_BE_PLACED_HERE',
    tomlData['start']?['url'] as String? ?? 'https://editor.construct.net',
  );

  // Replace navigate allow list
  final navigateList =
      (tomlData['whitelist']?['navigate'] as List<dynamic>?) ?? [];
  final navigateRegexes = navigateList
      .map((pattern) => "  /$pattern/,")
      .join('\n');
  content = content.replaceAll(
    '// NAVIGATE_ALLOW_TO_BE_PLACED_HERE',
    navigateRegexes,
  );

  // Replace embed allow list
  final embedListExplicit =
      (tomlData['whitelist']?['embed'] as List<dynamic>?) ?? [];
  // Automatically prepend navigate list to embed list.
  final embedList = [...navigateList, ...embedListExplicit];
  final embedRegexes = embedList.map((pattern) => "  /$pattern/,").join('\n');
  content = content.replaceAll(
    '// EMBED_ALLOW_TO_BE_PLACED_HERE',
    embedRegexes,
  );

  await indexJsFile.writeAsString(content);
}

/// Copies the Windows icon file from the source to the destination
/// The icon path in the TOML file is relative to the TOML file location
/// If the icon path is not provided, use the default icon from the template
/// If the icon path is provided but the file doesn't exist, show an error
Future<void> copyWindowsIcon(
  String inputPath,
  String outputPath,
  Map<String, dynamic> tomlData,
  bool verbose,
) async {
  final String? iconPathFromToml =
      tomlData['build']?['win']?['icon'] as String?;

  // Create the destination directory if it doesn't exist
  final Directory buildDir = Directory(path.join(outputPath, 'build'));
  if (!await buildDir.exists()) {
    await buildDir.create(recursive: true);
  }

  final File destIconFile = File(path.join(outputPath, 'build', 'icon.ico'));

  // If no icon path is provided in TOML, use the default from template
  if (iconPathFromToml == null) {
    if (verbose) {
      print('[VERBOSE] No Windows icon specified in TOML, using default icon');
    }
    // The default icon is already copied as part of the template directory
    return;
  }

  // Resolve the icon path relative to the TOML file
  final String tomlDir = path.dirname(inputPath);
  final String resolvedIconPath = path.join(tomlDir, iconPathFromToml);
  final File sourceIconFile = File(resolvedIconPath);

  // Check if the source icon file exists
  if (!await sourceIconFile.exists()) {
    print('Error: Windows icon file not found: $resolvedIconPath');
    throw Exception('Windows icon file not found: $resolvedIconPath');
  }

  // Copy the icon file to the destination
  await sourceIconFile.copy(destIconFile.path);

  if (verbose) {
    print(
      '[VERBOSE] Copied Windows icon from $resolvedIconPath to ${destIconFile.path}',
    );
  }
}

/// Replaces placeholders in the package.json file with values from the TOML file
Future<void> updatePackageJson(
  File packageJsonFile,
  Map<String, dynamic> tomlData,
) async {
  String content = await packageJsonFile.readAsString();

  // Replace basic info
  content = content.replaceAll(
    // This must come before 'name_to_be_placed_here', otherwise
    // the latter part of this placeholder is substituted for the name.
    'product_name_to_be_placed_here',
    tomlData['productName'] as String? ??
        tomlData['name'] as String? ??
        'Electron App',
  );

  content = content.replaceAll(
    'name_to_be_placed_here',
    tomlData['name'] as String? ?? 'electron-app',
  );

  content = content.replaceAll(
    'version_to_be_placed_here',
    tomlData['version'] as String? ?? '1.0.0',
  );

  content = content.replaceAll(
    'description_to_be_placed_here',
    tomlData['description'] as String? ?? 'Electron application',
  );

  content = content.replaceAll(
    'author_to_be_placed_here',
    tomlData['author'] as String? ?? 'Unknown',
  );

  // Replace build info
  content = content.replaceAll(
    'appid_to_be_placed_here',
    tomlData['build']?['appId'] as String? ?? 'com.example.app',
  );

  // Replace build resources directory
  content = content.replaceAll(
    'directories_buildResources_to_be_placed_here',
    tomlData['directories']?['buildResources'] as String? ?? 'build',
  );

  await packageJsonFile.writeAsString(content);
}

Future<void> main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      print('kids_standalone_website version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    final String? inputPath = results['input'] as String?;
    final String outputPath = results['output'] as String;
    final String templatePath = results['template'] as String;

    // Check if input file is provided
    if (inputPath == null || inputPath.isEmpty) {
      print(
        'Error: No input file provided. Use --input to specify a TOML configuration file.',
      );
      printUsage(argParser);
      return;
    }

    // Validate input file exists
    final File inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      print('Error: Input TOML file not found: $inputPath');
      return;
    }

    // Validate template directory exists
    final Directory templateDir = Directory(templatePath);
    if (!await templateDir.exists()) {
      print('Error: Template directory not found: $templatePath');
      return;
    }

    if (verbose) {
      print('[VERBOSE] Input TOML file: $inputPath');
      print('[VERBOSE] Output directory: $outputPath');
      print('[VERBOSE] Template directory: $templatePath');
    }

    // Parse TOML file
    try {
      final String tomlContent = await inputFile.readAsString();
      final Map<String, dynamic> tomlData = TomlDocument.parse(
        tomlContent,
      ).toMap();

      if (verbose) {
        print('[VERBOSE] Successfully parsed TOML file');
      }

      // Create output directory
      final Directory outputDir = Directory(outputPath);
      if (await outputDir.exists()) {
        print(
          'Warning: Output directory already exists. Files may be overwritten.',
        );
      }

      // Copy template directory to output directory
      await copyDirectory(templateDir, outputDir);

      if (verbose) {
        print('[VERBOSE] Copied template directory to output directory');
      }

      // Update index.js
      final File indexJsFile = File(path.join(outputPath, 'index.js'));
      await updateIndexJs(indexJsFile, tomlData);

      if (verbose) {
        print('[VERBOSE] Updated index.js with values from TOML file');
      }

      // Copy Windows icon if specified in TOML
      try {
        await copyWindowsIcon(inputPath, outputPath, tomlData, verbose);
        if (verbose) {
          print('[VERBOSE] Processed Windows icon');
        }
      } catch (e) {
        print('Error processing Windows icon: $e');
        return;
      }

      // Update package.json
      final File packageJsonFile = File(path.join(outputPath, 'package.json'));
      await updatePackageJson(packageJsonFile, tomlData);

      if (verbose) {
        print('[VERBOSE] Updated package.json with values from TOML file');
      }

      print('Successfully created electron project at: $outputPath');

      // Print recommended next steps
      print('\nRecommended next steps:');
      print('  cd $outputPath');
      print('  npm install');
      print('  npm start    # To run the application');
      print('  npm run build    # To build the application');
    } catch (e) {
      print('Error processing TOML file: $e');
      return;
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
