# Random Maze Generator using Depth-first Search
# http://en.wikipedia.org/wiki/Maze_generation_algorithm
import random
import os
from PIL import Image


class MazeGenerator:

    def __init__(self, image_scale=500):
        self.image_scale = image_scale
        # RGB colors of the maze (WALL, EMPTY, GOAL, START)
        self.colors = [(36, 137, 191), (255, 255, 255), (0, 154, 22), (249, 105, 40)]

    def maze_to_prolog(self, maze):
        prolog_kb = ["num_righe({}).".format(len(maze)), "num_colonne({}).".format(len(maze[0]))]
        for r in range(row):
            for c in range(column):
                if maze[r][c] == 0:
                    prolog_kb.append("occupata(pos({},{})).".format(r+1, c+1))
                if maze[r][c] == 2:
                    prolog_kb.append("finale(pos({},{})).".format(r+1, c+1))
                if maze[r][c] == 3:
                    prolog_kb.append("iniziale(pos({},{})).".format(r+1, c+1))
        prolog_kb.sort()
        return '\n'.join(prolog_kb)

    def generate_maze(self, row, column, difficulty=1):
        image_size_y = int(row / row) * self.image_scale
        image_size_x = int(column / row) * self.image_scale
        image = Image.new("RGB", (image_size_x, image_size_y))
        pixels = image.load()
        maze = [[0 for _ in range(column)] for _ in range(row)]
        dx = [0, 1, 0, -1]
        dy = [-1, 0, 1, 0]  # 4 directions to move in the maze
        # start the maze from a random cell
        cx = random.randint(0, column - 1)
        cy = random.randint(0, row - 1)
        start = cx
        maze[cy][cx] = 1
        stack = [(cx, cy, 0)]  # stack element: (x, y, direction)
        while len(stack) > 0:
            (cx, cy, cd) = stack[-1]
            # to prevent zigzags:
            # if changed direction in the last move then cannot change again
            if len(stack) > 2:
                if cd != stack[-2][2]:
                    dir_range = [cd]
                else:
                    dir_range = range(4)
            else:
                dir_range = range(4)
            # find a new cell to add
            nlst = []  # list of available neighbors
            for i in dir_range:
                nx = cx + dx[i]
                ny = cy + dy[i]
                if 0 <= nx < column and 0 <= ny < row:
                    if maze[ny][nx] == 0:
                        ctr = 0  # of occupied neighbors must be 1
                        for j in range(4):
                            ex = nx + dx[j]
                            ey = ny + dy[j]
                            if 0 <= ex < column and 0 <= ey < row:
                                if maze[ey][ex] == 1:
                                    ctr += 1
                        if ctr == 1:
                            nlst.append(i)
            # if 1 or more neighbors available then randomly select one and move
            if len(nlst) > 0:
                ir = nlst[random.randint(0, len(nlst) - 1)]
                cx += dx[ir]
                cy += dy[ir]
                maze[cy][cx] = 1
                stack.append((cx, cy, ir))
            else:
                stack.pop()
        maze[cy][cx] = 2
        maze[dx[ir]][dy[ir]] = 3

        # simplify the maze if needed and add starting point
        for r in range(row):
            for c in range(column):
                if maze[r][c] == 0 and random.uniform(0, 1) > difficulty:
                    maze[r][c] = 1
        # paint the maze
        for ky in range(image_size_y):
            for kx in range(image_size_x):
                if kx % (image_size_x // column) == 0:
                    pixels[kx, ky] = (0, 0, 0)
                elif ky % (image_size_y // row) == 0:
                    pixels[kx, ky] = (0, 0, 0)
                else:
                    pixels[kx, ky] = self.colors[maze[row * ky // image_size_y][column * kx // image_size_x]]
        return maze, image


labirinti_dir = "./labirinti"
os.makedirs(labirinti_dir, exist_ok=True)
row = 10
column = 10
maze_generator = MazeGenerator()
maze, image = maze_generator.generate_maze(row, column, difficulty=1)
image.save(os.path.join(labirinti_dir, "labirinto_{}x{}.png".format(row, column)), "PNG")
f = open(os.path.join(labirinti_dir, "labirinto_{}x{}.pl".format(row, column)), "w")
f.write(maze_generator.maze_to_prolog(maze))
f.close()
