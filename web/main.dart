import 'dart:html';

import 'maze.dart';
import 'maze_renderer.dart';

Maze maze;
MazeRenderer renderer;
CanvasElement canvas;
Room player;
int petId = 0;

void main() {
  maze = new Maze(9, 7);
  canvas = querySelector("#maze canvas");
  renderer = new MazeRenderer(canvas);
  renderer.loadSprites("images/maze/sprites64.png", 64).then((_) {
    newGameClick();
    canvas.onKeyDown.listen(keyDown);
    canvas.onMouseMove.listen(mouseMove);
  });
}

void newGameClick() {
  maze.reset();
  var stats = maze.buildDiagonal(0.5);
  print(stats);
  player = new Room(maze.start.x, maze.start.y);
  canvas.height = canvas.height;
  petId = (++petId) % MazeRenderer.pets.length;
  renderer.setPet(petId);
  renderer.renderMaze(maze);
  renderer.renderPlayer(player);
  renderer.renderGoal(maze.end);
  canvas.focus();
  window.console.log(maze.path);
}


void keyDown(KeyboardEvent event) {
  switch (event.keyCode) {
    case 40: // down
      if (maze.isRoomOpen(player, Dir.DOWN)) {
        moveTo(player.on(Dir.DOWN));
      }
      event.preventDefault();
      break;
    case 38: // up
      if (maze.isRoomOpen(player, Dir.UP)) {
        moveTo(player.on(Dir.UP));
      }
      event.preventDefault();
      break;
    case 37: // left
      if (maze.isRoomOpen(player, Dir.LEFT)) {
        moveTo(player.on(Dir.LEFT));
      }
      event.preventDefault();
      break;
    case 39: // right
      if (maze.isRoomOpen(player, Dir.RIGHT)) {
        moveTo(player.on(Dir.RIGHT));
      }
      event.preventDefault();
      break;
    case 32: // space
      newGameClick();
      event.preventDefault();
      break;
  }
  // for keys 0..9 set petId 0..9
  if (event.keyCode >= 48 && event.keyCode <= 57) {
    renderer.setPet(event.keyCode - 48);
  }
}

void moveTo(Room room) {
  player = room;
  renderer.renderPlayer(player);
  if (player == maze.end) {
    querySelector('#player').classes.add("happy");
  } else {
    querySelector('#player').classes.remove("happy");
  }
}

void mouseMove(MouseEvent event) {
  Room here = renderer.pixel2Room(event.layer);
  if (here.distanceTo(player)==1) {
//    print(here);
    moveTo(here);
  }
}
