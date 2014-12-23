import 'dart:html';

import 'maze.dart';
import 'maze_renderer.dart';

Maze maze;
MazeRenderer renderer;
CanvasElement canvas;
int playerX;
int playerY;

void main() {
  maze = new Maze(10, 6);
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
  renderer.player_type = MazeRenderer.PLAYER_MOUSE;
  renderer.renderPlayer(playerX, playerY);
  renderer.renderGoal(maze.cols - 1, maze.rows - 1);
  canvas.focus();
}


void keyDown(KeyboardEvent event) {
  switch (event.keyCode) {
    case 40: // down
      playerY++;
      renderer.renderPlayer(playerX, playerY);
      event.preventDefault();
      break;
    case 38: // up
      playerY--;
      renderer.renderPlayer(playerX, playerY);
      event.preventDefault();
      break;
    case 37: // left
      playerX--;
      renderer.renderPlayer(playerX, playerY);
      event.preventDefault();
      break;
    case 39: // right
      playerX++;
      renderer.renderPlayer(playerX, playerY);
      event.preventDefault();
      break;
  }
}
