// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library('csstool');

#import('../../frog/lang.dart', prefix:'lang');
#import('../../frog/file_system.dart');
#import('../../frog/file_system_node.dart');
#import('../../frog/lib/node/node.dart');
#import('css.dart');

FileSystem files;

/** Invokes [callback] and returns how long it took to execute in ms. */
num time(callback()) {
  final watch = new Stopwatch();
  watch.start();
  callback();
  watch.stop();
  return watch.elapsedInMs();
}

printStats(num elapsed, [String filename = '']) {
  print('Parsed\033[32m ${filename}\033[0m in ${elapsed} msec.');
}

/**
 * Run from the `utils/css` directory.
 */
void main() {
  // process.argv[0] == node and process.argv[1] == minfrog
  assert(process.argv.length == 4);

  String sourceFullFn = process.argv[2];
  String outputFullFn = process.argv[3];

  String sourcePath;
  String sourceFilename;
  int idxBeforeFilename = sourceFullFn.lastIndexOf('/');
  if (idxBeforeFilename >= 0) {
    sourcePath = sourceFullFn.substring(0, idxBeforeFilename + 1);
    sourceFilename = sourceFullFn.substring(idxBeforeFilename + 1);
  }

  String outPath;
  idxBeforeFilename = outputFullFn.lastIndexOf('/');
  if (idxBeforeFilename >= 0) {
    outPath = outputFullFn.substring(0, idxBeforeFilename + 1);
  }

  initCssWorld();

  files = new NodeFileSystem();
  if (!files.fileExists(sourceFullFn)) {
    // Display colored error message if file is missing.
    print("\033[31mCSS source file missing - ${sourceFullFn}\033[0m");
  } else {
    String source = files.readAll(sourceFullFn);

    Stylesheet stylesheet;

    final elapsed = time(() {
      Parser parser = new Parser(
          new lang.SourceFile(sourceFullFn, source), 0, files, sourcePath);
      stylesheet = parser.parse();
    });

    printStats(elapsed, sourceFullFn);

    StringBuffer buff = new StringBuffer(
      '/* File generated by SCSS from source ${sourceFilename}\n' +
      ' * Do not edit.\n' +
      ' */\n\n');
    buff.add(stylesheet.toString());

    files.writeString(outputFullFn, buff.toString());
    print("Generated file ${outputFullFn}");

    // Generate CSS.dart file.
    String genDartClassFile = Generate.dartClass(files, outPath, stylesheet,
        sourceFilename);
    print("Generated file ${genDartClassFile}");
  }
}
