import 'dart:io';

const String _kSvgExt = ".svg";
const String _kVecExt = ".vec";
const String _kSvgVecExt = "$_kSvgExt$_kVecExt";

void main() async {
  final directory = Directory("flags");
  if (!directory.existsSync()) {
    print("Directory does not exist");
    return;
  }

  final files = directory.listSync();

  int counter = 0;
  List<String> filesToOptimize = [];
  for (final file in files) {
    if (file is File && file.path.endsWith(_kSvgExt)) {
      final inputPath = file.path;
      final outputPath = "$inputPath$_kVecExt";

      // Skip if the svg file is already optimized
      if (files.where((e) => e.path.contains(outputPath)).isNotEmpty) {
        counter += 2;
        print("Already optimized: $inputPath");
      } else {
        filesToOptimize.add(inputPath);
      }
    }
  }

  if (filesToOptimize.length > 1) {
    print("${counter ~/ 2} svg files already optimized");
    print("Ready to optimize: ${filesToOptimize.length}");
    if (filesToOptimize.length < 10) {
      print(filesToOptimize);
    }
  } else {
    print("Nothing to optimize");
    exit(0);
  }

  print("\n\n");

  // Resetting counter
  counter = 0;
  if (filesToOptimize.isNotEmpty) {
    files.retainWhere((f) => filesToOptimize.contains(f.path));

    for (final file in files) {
      if (file is File && file.path.endsWith(_kSvgExt)) {
        final inputPath = file.path;
        final outputPath = "$inputPath$_kVecExt";

        print("Ready to optimize: $inputPath to $outputPath");
        final optInit = DateTime.now();
        final result = await Process.run(
          "dart",
          [
            "run",
            "vector_graphics_compiler",
            "-i",
            inputPath,
            "-o",
            outputPath
          ],
        ).timeout(
          const Duration(seconds: 1000),
          onTimeout: () async {
            return ProcessResult(001, 130, "", "Timeout error. Exceeded 1s.");
          },
        );
        final optEnd = DateTime.now();

        // Calculate optimization process time
        final optDiff = optEnd.difference(optInit);
        final optDiffStr = optDiff.inSeconds > 0
            ? "${optDiff.inSeconds}s"
            : "${optDiff.inMilliseconds}ms";

        if (result.exitCode == 0) {
          counter++;
          print("Successfully optimized: in $optDiffStr");
        } else {
          // print("Exit code ${result.exitCode}");
          print("Failed to optimize: in $optDiffStr");
          print(result.stdout);
          print(result.stderr);
          continue;
        }
      }
    }
  }

  if (counter > 1) {
    print("$counter svg files optimized");
  } else {
    print("Nothing to optimize");
  }

  exit(0);
}
