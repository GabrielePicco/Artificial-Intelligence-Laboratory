import subprocess
import pandas as pd


def generate_excel_from_solution(list_solution, file_name):
    writer = pd.ExcelWriter("{}.xlsx".format(file_name), engine="xlsxwriter")
    df = pd.DataFrame(index=range(len(list_solution)), columns=['Classe', 'Giorno', 'Ora', 'Aula', 'Doc', 'Materia'])
    for ind, s in enumerate(list_solution):
        df.loc[ind] = s[s.index('(') + 1:-1].split(',')
    for classe in df['Classe'].unique():
        df[df['Classe'] == classe].to_excel(writer, sheet_name=classe, index=False)
    writer.save()


num_solution = input("Numero Soluzioni: ")
asp_calendar_path = "./calendario_lezioni.cl"
runthis = "/Applications/clingo-5.3.0-macos-x86_64/clingo --verbose=0 {} {}".format(asp_calendar_path, num_solution)
osstdout = subprocess.Popen(runthis, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
solution = osstdout.communicate()[0].strip()
return_code = osstdout.returncode
solution = solution.decode("utf-8").replace("\nSATISFIABLE", "")

all_solutions = solution.split("\n")

for i, s in enumerate(all_solutions):
    list_solution = s.split(" ")
    generate_excel_from_solution(list_solution, "Orario (Soluzione: {})".format(i+1))






