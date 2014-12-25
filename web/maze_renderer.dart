library maze_renderer;

import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'maze.dart';

// not used yet
class Sprite {
  int sheetX; // on sprite sheet, to me multipied by size
  int sheetY; // on sprite sheet, to me multipied by size
  int size; // sprite width and height
  int x; // on board, in rooms, not pixels
  int y; // on board, in rooms, not pixels
  ImageElement image;
  Sprite(String spriteUrl, this.sheetX, this.sheetY, this.size) {
    image = new ImageElement(src: spriteUrl);
    image.style.display = "none";
    image.style.position = "absolute";
    image.style.width = "${size}px";
    image.style.height = "${size}px";
    image.onLoad.first.then((e) {
      image.style.left = "${sheetX * size}px";
      image.style.top = "${sheetY * size}px";
    });
  }
}

class MazeRenderer {
  CanvasElement canvas;
  Rectangle canvasOffset;
  CanvasRenderingContext2D ctx;
  ImageElement img;
  int size;
  int margin;
  List<Point<int>> sprites = new List(16);
  // where particular maze sprite is locaten on the sprite sheet
  static const List<int> _spriteX = const [2, 2, 3, 3, 2, 2, 3, 3, 1, 1, 0, 0, 1, 1, 0, 0];
  static const List<int> _spriteY = const [2, 1, 2, 1, 3, 0, 3, 0, 2, 1, 2, 1, 3, 0, 3, 0];
  // coordinated on sprite sheet
  static const int PLAYER_CAT = 0;
  static const int PLAYER_DOG = 1;
  static const int PLAYER_MOUSE = 2;
  static const int PLAYER_MONEKY = 3;
  int player_type;
  static const int PLAYER_Y = 4;
  static const int GOAL_Y = 5;
  Element player;
  Element goal;

  MazeRenderer(this.canvas) {
    ctx = canvas.context2D;
//    player_type = PLAYER_CAT;
//    player_type = PLAYER_DOG;
//    player_type = PLAYER_MOUSE;
    player_type = PLAYER_MONEKY;
    canvasOffset = canvas.offset;
  }

  renderMaze(Maze maze) {
    if (!img.complete) {
      throw "Cannot render maze. Sprites not loaded.";
    }
    ctx.save();
    ctx.fillStyle = "#333";
    ctx.translate(margin, margin);
    ctx.fillRect(-margin, -margin , maze.cols * size + 2*margin, maze.rows * size+2*margin);
    ctx.rect(-margin, -margin , maze.cols * size + 2*margin, maze.rows * size+2*margin);
    ctx.clip();
    Point sprite;
    for (int y = 0; y < maze.rows; y++) {
      for (int x = 0; x < maze.cols; x++) {
        int val = maze.getValue(x, y);
        sprite = sprites[val];
        ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, x * size, y * size, size, size);
      }
    }
    sprite = sprites[ Dir.UP | Dir.DOWN ];
    for (int x = 0; x < maze.cols; x++) {
      ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, x * size, -1 * size, size, size);
      ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, x * size, maze.rows * size, size, size);
    }
    sprite = sprites[ Dir.RIGHT | Dir.LEFT ];
    for (int y = 0; y < maze.rows; y++) {
      ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, -1 * size, y * size, size, size);
      ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, maze.cols * size, y * size, size, size);
    }
    sprite = sprites[ Dir.UP | Dir.LEFT ];
    ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, -1 * size, -1 * size, size, size);
    sprite = sprites[ Dir.UP | Dir.RIGHT ];
    ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, maze.cols * size, -1 * size, size, size);
    sprite = sprites[ Dir.DOWN | Dir.LEFT ];
    ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, -1 * size, maze.rows * size, size, size);
    sprite = sprites[ Dir.DOWN | Dir.RIGHT ];
    ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, maze.cols * size, maze.rows * size, size, size);
    ctx.restore();
  }

  void renderPlayer(int x, int y) {
    //ctx.drawImageScaledFromSource(img, player_type * size, PLAYER_Y * size, size, size, x * size, y * size, size, size);
    player.style.display = "inline-block";
    player.style.left = "${canvasOffset.left + margin + x * size}px";
    player.style.top = "${canvasOffset.top + margin + y * size}px";
  }

  void renderGoal(int x, int y) {
    //ctx.drawImageScaledFromSource(img, player_type * size, GOAL_Y * size, size, size, x * size, y * size, size, size);
    goal.style.display = "inline-block";
    goal.style.left = "${canvasOffset.left + margin + x * size}px";
    goal.style.top = "${canvasOffset.top + margin + y * size}px";
  }

  Future loadSprites(String spriteUrl, int size) {
    img = new ImageElement();
    this.size = size;
    margin = size ~/ 4;
    for (int i = 0; i < sprites.length; i++) {
      sprites[i] = new Point(_spriteX[i] * size, _spriteY[i] * size);
    }
    var ret = img.onLoad.first.then((e) {
      player = querySelector("#maze #player");
      player.style.backgroundImage = "url(${spriteUrl})";
      player.style.width = "${size}px";
      player.style.height = "${size}px";
      player.style.position = "absolute";
      player.style.backgroundPositionX = "${-player_type * size}px";
      player.style.backgroundPositionY = "${-PLAYER_Y * size}px";
      player.style.transition = "150ms";
      goal = querySelector("#maze #goal");
      goal.style.backgroundImage = "url(${spriteUrl})";
      goal.style.width = "${size}px";
      goal.style.height = "${size}px";
      goal.style.position = "absolute";
      goal.style.backgroundPositionX = "${-player_type * size}px";
      goal.style.backgroundPositionY = "${-GOAL_Y * size}px";
      goal.style.transition = "150ms";
    });
    img.src = spriteUrl;
    return ret;
  }

}
