library maze_renderer;

import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'maze.dart';

class Sprite {
  int x;
  int y;
  String name;
  Sprite(this.x, this.y, [this.name]);
}

class Pet extends Sprite {
  Sprite food;
  Pet(int x, int y, String name, this.food) : super(x, y, name) ;
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
  Element player;
  Element goal;
  static List<Pet> pets = buildPets();
  Pet pet;

  static List<Pet> buildPets() {
    return [
            new Pet(0, 4, 'cat',
                new Sprite(0,5, 'bowl')),
            new Pet(1, 4, 'dog',
                new Sprite(1,5, 'bone')),
            new Pet(2, 4, 'mouse',
                new Sprite(2,5, 'cheese')),
            new Pet(3, 4, 'monkey',
                new Sprite(3,5, 'banana')),
            new Pet(0, 6, 'goat',
                new Sprite(0,7, 'grass')),
            new Pet(1, 6, 'penguin',
                new Sprite(1,7, 'fish')),
            new Pet(2, 6, 'giraffe',
                new Sprite(2,7, 'grass')),
            new Pet(3, 6, 'elephant',
                new Sprite(3,7, 'banana')),
            new Pet(1, 7, 'fish',
                new Sprite(0,7, 'grass')),
            new Pet(0, 4, 'cat',
                new Sprite(2,4, 'mouse')),
    ];
  }

  MazeRenderer(this.canvas) {
    ctx = canvas.context2D;
    pet = pets[0];
    canvasOffset = canvas.offset;
  }

  Room pixel2Room(Point<int> canvasPixel) {
    return new Room(
        (canvasPixel.x - margin - canvasOffset.left) ~/ size,
        (canvasPixel.y - margin - canvasOffset.top) ~/ size);
  }
  
  void setPet(int petId) {
    pet = pets[petId];
    print('set pet to ${pet.name}, x=${pet.x}, y=${pet.y}');
    _setPosNow(player, -pet.x * size, -pet.y * size);
    _setPosNow(goal, -pet.food.x * size, -pet.food.y * size);
  }
  
  /** set sprite without transition */
  void _setPosNow(Element el, int px, int py) {
    var tmp = el.style.transition;
    el.style.transition = "0ms";
    el.style.backgroundPositionX = "${px}px";
    el.style.backgroundPositionY = "${py}px";
    var transitionHack = el.offsetLeft;  // needed pause to avoid transition
    el.style.transition = tmp;
  }

  renderMaze(Maze maze, [resizeCanvas=true]) {
    if (!img.complete) {
      throw "Cannot render maze. Sprites not loaded.";
    }
    if (resizeCanvas) {
      canvas.width = 2 * margin + maze.cols * size;
      canvas.height = 2 * margin + maze.rows * size;
      canvasOffset = canvas.offset;
    }
    ctx.save();
    ctx.fillStyle = "#333";
    ctx.translate(margin, margin);
    ctx.fillRect(-margin, -margin, maze.cols * size + 2 * margin, maze.rows * size + 2 * margin);
    ctx.rect(-margin, -margin, maze.cols * size + 2 * margin, maze.rows * size + 2 * margin);
    ctx.clip();
    Point sprite;
    for (int y = 0; y < maze.rows; y++) {
      for (int x = 0; x < maze.cols; x++) {
        int val = maze.getValue(x, y);
        sprite = sprites[val];
        ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, x * size, y * size, size, size);
      }
    }
    sprite = sprites[Dir.UP | Dir.DOWN];
    for (int x = 0; x < maze.cols; x++) {
      ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, x * size, -1 * size, size, size);
      ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, x * size, maze.rows * size, size, size);
    }
    sprite = sprites[Dir.RIGHT | Dir.LEFT];
    for (int y = 0; y < maze.rows; y++) {
      ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, -1 * size, y * size, size, size);
      ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, maze.cols * size, y * size, size, size);
    }
    sprite = sprites[Dir.UP | Dir.LEFT];
    ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, -1 * size, -1 * size, size, size);
    sprite = sprites[Dir.UP | Dir.RIGHT];
    ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, maze.cols * size, -1 * size, size, size);
    sprite = sprites[Dir.DOWN | Dir.LEFT];
    ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, -1 * size, maze.rows * size, size, size);
    sprite = sprites[Dir.DOWN | Dir.RIGHT];
    ctx.drawImageScaledFromSource(img, sprite.x, sprite.y, size, size, maze.cols * size, maze.rows * size, size, size);
    ctx.restore();
  }

  void renderPlayer(Room room) {
    //ctx.drawImageScaledFromSource(img, player_type * size, PLAYER_Y * size, size, size, x * size, y * size, size, size);
    player.style.display = "inline-block";
    player.style.left = "${canvasOffset.left + margin + room.x * size}px";
    player.style.top = "${canvasOffset.top + margin + room.y * size}px";
  }

  void renderGoal(Room room) {
    //ctx.drawImageScaledFromSource(img, player_type * size, GOAL_Y * size, size, size, x * size, y * size, size, size);
    goal.style.display = "inline-block";
    goal.style.left = "${canvasOffset.left + margin + room.x * size}px";
    goal.style.top = "${canvasOffset.top + margin + room.y * size}px";
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
      player.style.backgroundPositionX = "${-pet.x * size}px";
      player.style.backgroundPositionY = "${-pet.y * size}px";
      player.style.transition = "150ms";
      goal = querySelector("#maze #goal");
      goal.style.backgroundImage = "url(${spriteUrl})";
      goal.style.width = "${size}px";
      goal.style.height = "${size}px";
      goal.style.position = "absolute";
      goal.style.backgroundPositionX = "${-pet.food.x * size}px";
      goal.style.backgroundPositionY = "${-pet.food.y * size}px";
      goal.style.transition = "150ms";
    });
    img.src = spriteUrl;
    return ret;
  }

}
