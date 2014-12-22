import 'dart:html';

import 'maze.dart';
import 'maze_renderer.dart';

void main() {
  Maze maze = new Maze(10, 5);
  CanvasElement canvas = querySelector("canvas#maze");
  MazeRenderer renderer = new MazeRenderer(canvas);
  var stats = maze.buildDiagonal(0.5);
  print(stats);
  renderer.loadSprites("images/maze/sprites64.png", 64).then((_){
    renderer.renderMaze(maze);
  });
  
//  renderMazeOn(maze, ctx);
}

