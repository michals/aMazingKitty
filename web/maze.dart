library maze;

import 'dart:typed_data';
import 'dart:math';

class _Rnd {
  static Random random = new Random();

  static int randomInt(max) {
    return random.nextInt(max);
  }
}

// Direction
class Dir {
  static const int UP = 1;
  static const int RIGHT = 2;
  static const int DOWN = 4;
  static const int LEFT = 8;

  // all directions as a List
  static const List<int> allAsList = const [UP, RIGHT, DOWN, LEFT];

  // all drections as a int bitmap
  static const int allAsBitmap = UP | RIGHT | DOWN | LEFT;

  // random direction of given as direction bitmap
  static int randomDir(dirsBitmap) {
    List<int> list = Dir.allAsList.where((dir) => (dir & dirsBitmap) != 0).toList();
    return list[_Rnd.randomInt(list.length)];
  }

  static opposite(int direction) {
    switch (direction) {
      case UP:
        return DOWN;
      case RIGHT:
        return LEFT;
      case DOWN:
        return UP;
      case LEFT:
        return RIGHT;
    }
    throw "wrong direction";
  }
}

class Room extends Point {
  Room(int x, int y) : super(x, y);

  Room on(int dir) {
    switch (dir) {
      case Dir.UP:
        return new Room(x, y - 1);
      case Dir.RIGHT:
        return new Room(x + 1, y);
      case Dir.DOWN:
        return new Room(x, y + 1);
      case Dir.LEFT:
        return new Room(x - 1, y);
    }
    throw "incorrect direction";
  }
}

/** room connecting two diggers paths */
class Bridge extends Room {
  /** length of the connected paths */
  final int length;
  /** door direction from one path to another */
  final int direction;
  Bridge(int x, int y, this.length, this.direction) : super(x, y);
}

/** returned by maze builder methods */
class MazeStats {
  final int shortests;
  final int picked;
  final int longest;
  final int options;
  final Bridge bridge;
  MazeStats(this.shortests, this.picked, this.longest, this.options, this.bridge);
  String toString() => "MazeStats{shortests: $shortests, picked: $picked, max: $longest, options: $options}";
}

class Digger {
  final Maze maze;
  Room room;
  final int id;
  List<Room> potentialNextStart;

  Digger(this.maze, Room start, this.id) {
    room = start;
    potentialNextStart = [start];
  }

  /** open door and enter new room. Return new room location */
  Room openAndEnter(int direction) {
    var newRoom = room.on(direction);
    maze.openDoor(room, direction, id);
    maze.openDoor(newRoom, Dir.opposite(direction), id);
    maze.updateDist(newRoom, room);
    room = newRoom;
    return room;
  }

  int whereCanDigg(Room from) {
    int dirs = 0; // directions bitmap (no direction)
    int unvisited = Dir.allAsBitmap;
    int x = from.x;
    int y = from.y;
    if (y > 0 && maze.getValue(x, y - 1) == unvisited) {
      dirs |= Dir.UP;
    }
    if (x + 1 < maze.cols && maze.getValue(x + 1, y) == unvisited) {
      dirs |= Dir.RIGHT;
    }
    if (y + 1 < maze.rows && maze.getValue(x, y + 1) == unvisited) {
      dirs |= Dir.DOWN;
    }
    if (x > 0 && maze.getValue(x - 1, y) == unvisited) {
      dirs |= Dir.LEFT;
    }
    return dirs;
  }
  
  /** find next starting room. Retirn null if none */
  Room nextStart() {
    Room room;
    while (!potentialNextStart.isEmpty) {
      room = potentialNextStart.removeLast();
      if (whereCanDigg(room) > 0) {
        return room;
      }
    }
    return null;
  }
  
  void digg(int maxSteps) {
    int dirs;
    int dir;
    Room prev;
    room = nextStart();
    if (room == null) {
      return;
    }
    while ((dirs = whereCanDigg(room)) != 0 && maxSteps-- > 0) {
      dir = Dir.randomDir(dirs);
      prev = room;
      openAndEnter(dir);
      if (whereCanDigg(room) & ~dir != 0) {
        potentialNextStart.add(room);
      }
      if (dirs & ~dir != 0) {
        potentialNextStart.add(prev);
      }
    }
  }
}

class Maze {
  final int rows, cols;

  /** number of already visited rooms */
  int visited;

  /** Kitty starting point */
  Room start;

  /** possibe ends of maze (only one is correct) */
  List<Room> ends;

  /** correct maze end. The correct one of this.ends */
  Room end;

  /**
   * internal room representation as flat table of closed doors in rooms.
   * _data[x + cols * y] == Dir.RIGHT | Dir.UP
   * means that in Room(x,y) RIGHT and UP doors are closed and LEFT and DOWN are open
    */
  Uint8List _data;

  /** what digger owns particular room */
  Uint8List _owner;

  /** distance to the digger starting point */
  Uint8List _dist;
  
  List<Room> path;

  Maze(this.cols, this.rows) {
    visited = 0;
    ends = [];
    path = [];
    _data = new Uint8List(cols * rows);
    _owner = new Uint8List(cols * rows);
    _dist = new Uint8List(cols * rows);
    for (int i = 0; i < _data.length; i++) {
      _data[i] = Dir.allAsBitmap;
    }
  }

  int _xy(int x, int y) {
    return x + cols * y;
  }

  int getValue(int x, int y) => _data[_xy(x, y)];

  void setValue(int x, int y, int value) {
    _data[_xy(x, y)] = value;
  }

  int getOwner(int x, int y) => _owner[_xy(x, y)];

  void setOwner(int x, int y, int value) {
    _owner[_xy(x, y)] = value;
  }

  int getDist(int x, int y) => _dist[_xy(x, y)];

  void setDist(int x, int y, int value) {
    _dist[_xy(x, y)] = value;
  }

  updateDist(Room newRoom, Room prevRoom) {
    setDist(newRoom.x, newRoom.y, getDist(prevRoom.x, prevRoom.y) + 1);
  }

  bool inBounds(Room room) {
    return (room.x >= 0 && room.x < cols && room.y >= 0 && room.y < rows);
  }

  bool isRoomOpen(Room room, int direction) {
    // set direction bit mean door closed
    return getValue(room.x, room.y) & direction == 0;
  }

  void openDoor(Room room, int direction, int owner) {
    int oldVal = getValue(room.x, room.y);
    if (oldVal == Dir.allAsBitmap) { // all doors ware closed
      visited++;
    }
    setValue(room.x, room.y, oldVal & ~direction);
    setOwner(room.x, room.y, owner);
  }

  MazeStats _bridge(double difficulty) {
    if (difficulty < 0 || difficulty >= 1) {
      throw "difficulty must be in range (0.0 .. 1.0]";
    }
    // list of bridges between outer digger paths and inner digger paths
    // each bridge is a start point with direction property
    List<Bridge> bridges = new List();

    // true iff one owner is inner digger and other is outer digger
    // inner digger ids assumed to be: 1,2,...
    // outer digger ids assumed to be: 11,12,...
    bool inOut(int owner1, int owner2) => (owner1 - owner2).abs() > 4;

    int owner; // aka digger id
    // find all possible bridges
    // (adjacent rooms with different owner/digger ids)
    for ( var y = 0; y < rows; y++) {
        for ( var x = 0; x < cols; x++) {
            owner = getOwner(x, y);
            if (x < cols - 1 && inOut(owner, getOwner(x + 1, y))) {
                bridges.add(new Bridge(x, y, 1 + getDist(x, y) + getDist(x + 1, y), Dir.RIGHT));
            }
            if (y < rows - 1 && inOut(owner, getOwner(x, y + 1))) {
                bridges.add(new Bridge(x, y, 1 + getDist(x, y) + getDist(x, y + 1), Dir.DOWN));
            }
        }
    }
    // sort bridges by path length (shortest first)
    bridges.sort((a, b) => a.length - b.length);
    Bridge bridge;
    // in case one digger did all maze
    if (!bridges.isEmpty) {
      bridge = bridges[(bridges.length * difficulty).toInt()];
      openDoor(bridge, bridge.direction, 0);
      openDoor(bridge.on(bridge.direction), Dir.opposite(bridge.direction), 0);
    }

    // find path to correct end
    path = findPath(start, ends);
    // remember correct end
    end = path[path.length - 1];

    return new MazeStats(bridges[0].length, bridge.length, bridges.last.length, bridges.length, bridge);
  }

  void buildCenter(double difficulty) {
    throw "not implemented";
  }

  MazeStats buildDiagonal(double difficulty) {
    start = new Room(0, 0);
    end = new Room(cols - 1, rows - 1);
    ends = [end];
    List<Digger> diggers = [new Digger(this, start, 1), new Digger(this, end, 14)];
    int maxSteps = 5;
    while (visited < rows * cols) {
      diggers[0].digg(maxSteps);
      diggers[1].digg(maxSteps);
    }
    return _bridge(difficulty);
  }

  List<Room> findPath(Room from, List<Room> destinations) {
    return [from, destinations[0]]; // TODO: real implementation
  }

}

