import 'dart:html';

import 'maze.dart';
import 'maze_renderer.dart';

Maze maze;
MazeRenderer renderer;
CanvasElement canvas;

void main() {
  maze = new Maze(10, 6);
  canvas = querySelector("canvas#maze");
  Element newGame = querySelector("#newGame");
  renderer = new MazeRenderer(canvas);
  renderer.loadSprites("images/maze/sprites64.png", 64).then((_) {
    newGame.onClick.listen((_) {
      newGameClick();
    });
    newGameClick();
  });
}

void newGameClick() {
  maze.reset();
  var stats = maze.buildDiagonal(0.5);
  print(stats);
  canvas.height = canvas.height;
  renderer.renderMaze(maze);
  renderer.player_type = MazeRenderer.PLAYER_MOUSE;
  renderer.renderPlayer(0, 0);
  renderer.renderGoal(maze.cols - 1, maze.rows - 1);
}
