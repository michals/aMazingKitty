import 'dart:html';

import 'maze.dart';
import 'maze_renderer.dart';

Maze maze;
MazeRenderer renderer;
CanvasElement canvas;
int playerX;
int playerY;

void main() {
  maze = new Maze(8, 6);
  canvas = querySelector("#maze canvas");
  Element newGame = querySelector("#newGame");
  renderer = new MazeRenderer(canvas);
  renderer.loadSprites("images/maze/sprites64.png", 64).then((_) {
    newGame.onClick.listen((_) {
      newGameClick();
    });
    newGameClick();
    canvas.onKeyDown.listen(keyDown);
  });
}

void newGameClick() {
  maze.reset();
  var stats = maze.buildDiagonal(0.5);
  print(stats);
  playerX = maze.start.x;
  playerY = maze.start.y;
  canvas.height = canvas.height;
  renderer.renderMaze(maze);
  renderer.renderPlayer(playerX, playerY);
  renderer.renderGoal(maze.cols - 1, maze.rows - 1);
  canvas.focus();
}


void keyDown(KeyboardEvent event) {
  switch (event.keyCode) {
    case 40: // down
      if (maze.isRoomOpenXY(playerX, playerY, Dir.DOWN)) {
        playerY++;
        renderer.renderPlayer(playerX, playerY);
      }
      event.preventDefault();
      break;
    case 38: // up
      if (maze.isRoomOpenXY(playerX, playerY, Dir.UP)) {
        playerY--;
        renderer.renderPlayer(playerX, playerY);
      }
      event.preventDefault();
      break;
    case 37: // left
      if (maze.isRoomOpenXY(playerX, playerY, Dir.LEFT)) {
        playerX--;
        renderer.renderPlayer(playerX, playerY);
      }
      event.preventDefault();
      break;
    case 39: // right
      if (maze.isRoomOpenXY(playerX, playerY, Dir.RIGHT)) {
        playerX++;
        renderer.renderPlayer(playerX, playerY);
      }
      event.preventDefault();
      break;
  }
  if (playerX == maze.cols - 1 && playerY == maze.rows - 1) {
    querySelector('#player').classes.add("happy");
  } else {
    querySelector('#player').classes.remove("happy");
  }
}
