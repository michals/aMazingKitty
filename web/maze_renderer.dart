library maze_renderer;

import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'maze.dart';

class MazeRenderer {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  ImageElement img;
  int size;
  List<Point<int>> sprites = new List(16);
  // where particular maze sprite is locaten on the sprite sheet
  static const List<int> _spriteX = const [2, 2, 3, 3, 2, 2, 3, 3, 1, 1, 0, 0, 1, 1, 0, 0];
  static const List<int> _spriteY = const [2, 1, 2, 1, 3, 0, 3, 0, 2, 1, 2, 1, 3, 0, 3, 0];

  MazeRenderer(this.canvas) {
    ctx = canvas.context2D;
  }

  renderMaze(Maze maze) {
    if (!img.complete) {
      throw "Cannot render maze. Sprites not loaded.";
    }
    Point sprite;
    for (int y = 0; y < maze.rows; y++) {
      for (int x = 0; x < maze.cols; x++) {
        int val = maze.getValue(x, y);
        sprite = sprites[val];
        ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, x * size, y * size, size, size);
      }
    }
  }

  Future loadSprites(String spriteUrl, int size) {
    img = new ImageElement();
    this.size = size;
    for (int i=0; i<sprites.length; i++) {
      sprites[i] = new Point(_spriteX[i] * size, _spriteY[i] * size);
    }
    var ret = img.onLoad.first;
    img.src = spriteUrl;
    return ret;
  }

}
