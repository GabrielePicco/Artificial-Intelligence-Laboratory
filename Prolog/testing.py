import os
import subprocess
import time


def execute_prolog_program(files):
    concat = '\n'.join([open(f).read() for f in files])
    tmp_file_pl = './tmp_single_prolog.pl'
    with open(tmp_file_pl, "w") as f:
        f.write(concat)
    start = time.time()
    runthis = "swipl --quiet -s \"{}\"  -g \"program.\" -t halt".format(tmp_file_pl)
    osstdout = subprocess.Popen(runthis, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
    theInfo = osstdout.communicate()[0].strip()
    print(theInfo, osstdout.returncode)
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
soluzione, execution_time_a_star = execute_prolog_program(a_star_files + [os.path.join(labirinti_dir, "labirinto_{}x{}.pl".format(20, 20))])
print(soluzione)
