import 'dart:html';

import 'maze.dart';
import 'maze_renderer.dart';

Maze maze;
MazeRenderer renderer;
CanvasElement canvas;
Room player;
//int playerX;
//int playerY;
List<int> pets = [MazeRenderer.PLAYER_CAT, MazeRenderer.PLAYER_DOG, MazeRenderer.PLAYER_MONEKY, MazeRenderer.PLAYER_MOUSE];
int pet = 0;

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
    canvas.onMouseMove.listen(mouseMove);
  });
}

void newGameClick() {
  maze.reset();
  var stats = maze.buildDiagonal(0.5);
  print(stats);
  player = new Room(maze.start.x, maze.start.y);
  canvas.height = canvas.height;
  pet = (++pet) % pets.length;
  renderer.setPet(pets[pet]);
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
