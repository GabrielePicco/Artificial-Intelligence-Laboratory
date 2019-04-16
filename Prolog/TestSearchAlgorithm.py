import subprocess
import os
import time
import matplotlib.pyplot as plt

from MazeGenerator import MazeGenerator


def execute_prolog_program(files):
    concat = '\n'.join([open(f).read() for f in files])
    tmp_file_pl = './tmp_single_prolog.pl'
    with open(tmp_file_pl, "w") as f:
        f.write(concat)
    start = time.time()
    runthis = "swipl --quiet -s \"{}\"  -g \"program.\" -t halt".format(tmp_file_pl)
    osstdout = subprocess.Popen(runthis, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
    theInfo = osstdout.communicate()[0].strip()
    # print(theInfo, osstdout.returncode)
    end = time.time()
    os.remove(tmp_file_pl)
    with open("soluzione.txt", "r") as f:
        soluzione = f.read()[1:-1].split(",")
    os.remove("./soluzione.txt")
    return soluzione, (end-start)


a_star_files = ['azioni.pl', 'euristica_manhattan.pl', 'a_star.pl', './utils/save_astar.pl']
ida_star_files = ['azioni.pl', 'euristica_manhattan.pl', 'ida_star.pl', './utils/save_ida_star.pl']
iterative_deepening_files = ['azioni.pl', 'euristica_manhattan.pl', 'iterative_deepening.pl', './utils/save_iterative_deepening.pl']

labirinti_dir = "./labirinti"
os.makedirs(labirinti_dir, exist_ok=True)

test_dimension = range(2, 50)
a_star_execution_time, a_star_solution_length = [], []
ida_star_execution_time, ida_star_solution_length = [], []
iterative_deepening_execution_time, iterative_deepening_solution_length = [], []
for i in test_dimension:
    row = i
    column = i
    maze_generator = MazeGenerator()
    maze, image = maze_generator.generate_maze(row, column, difficulty=1)
    image.save(os.path.join(labirinti_dir, "labirinto_{}x{}.png".format(row, column)), "PNG")
    with open(os.path.join(labirinti_dir, "labirinto_{}x{}.pl".format(row, column)), "w") as f:
        f.write(maze_generator.maze_to_prolog(maze))
    soluzione_a_star, execution_time_a_star = execute_prolog_program(a_star_files + [os.path.join(labirinti_dir, "labirinto_{}x{}.pl".format(row, column))])
    a_star_execution_time.append(execution_time_a_star)
    a_star_solution_length.append(len(soluzione_a_star))
    soluzione_ida_star, execution_time_ida_star = execute_prolog_program(ida_star_files + [os.path.join(labirinti_dir, "labirinto_{}x{}.pl".format(row, column))])
    ida_star_execution_time.append(execution_time_ida_star)
    ida_star_solution_length.append(len(soluzione_ida_star))
    soluzione_iterative_deepening, execution_time_iterative_deepening = execute_prolog_program(iterative_deepening_files + [os.path.join(labirinti_dir, "labirinto_{}x{}.pl".format(row, column))])
    iterative_deepening_execution_time.append(execution_time_iterative_deepening)
    iterative_deepening_solution_length.append(len(soluzione_iterative_deepening))

test_dimension = list(test_dimension)

plt.clf()
plt.plot(test_dimension, a_star_execution_time, label='A*')
plt.plot(test_dimension, ida_star_execution_time, label='IDA*')
plt.plot(test_dimension, iterative_deepening_execution_time, label='Iterative Deepening')
plt.legend()
plt.ylabel('Tempo di ricerca della soluzione')
plt.xlabel('Dimensione Labirinto')
plt.title('Confronto dei tempi di ricerca delle soluzioni')
plt.savefig("tempi_ricerca_soluzioni.png", format='png')

plt.clf()
plt.plot(test_dimension, a_star_solution_length, label='A*')
plt.plot(test_dimension, ida_star_solution_length, label='IDA*')
plt.plot(test_dimension, iterative_deepening_solution_length, label='Iterative Deepening')
plt.legend()
plt.ylabel('Lunghezza soluzione')
plt.xlabel('Dimensione Labirinto')
plt.title('Confronto delle soluzioni')
plt.savefig("lunghezza_soluzioni.png", format='png')




