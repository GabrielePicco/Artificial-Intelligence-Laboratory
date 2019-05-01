import subprocess
import pandas as pd


def generate_excel_from_solution(list_solution, file_name):
    writer = pd.ExcelWriter("{}.xlsx".format(file_name), engine="xlsxwriter")
    df = pd.DataFrame(index=range(len(list_solution)), columns=['Classe', 'Giorno', 'Ora', 'Aula', 'Doc', 'Materia'])
    for ind, s in enumerate(list_solution):
        row = s[s.index('(') + 1:-1].split(',')
        if len(row) == 4:
            row.append("")
            row.append("")
        df.loc[ind] = row
    for classe in df['Classe'].unique():
        df.Giorno = df.Giorno.astype("category")
        df.Giorno.cat.set_categories(['lun', 'mar', 'merc', 'giov', 'ven'], inplace=True)
        df.Ora = df.Ora.astype("category")
        df.Ora.cat.set_categories(['prima_ora', 'seconda_ora', 'terza_ora', 'quarta_ora', 'quinta_ora', 'sesta_ora', 'settima_ora', 'ottava_ora', 'nona_ora'], inplace=True)
        df[df['Classe'] == classe].sort_values(by=['Giorno', 'Ora']).to_excel(writer, sheet_name=classe, index=False)
    writer.save()


num_solution = input("Numero Soluzioni: ")
asp_calendar_path = "./calendario_lezioni.cl"
runthis = "/Applications/clingo-5.3.0-macos-x86_64/clingo --verbose=0 --warn=no-global-variable {} {}".format(asp_calendar_path, num_solution)
osstdout = subprocess.Popen(runthis, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
solution = osstdout.communicate()[0].strip()
return_code = osstdout.returncode
solution = solution.decode("utf-8").replace("\nSATISFIABLE", "")

all_solutions = solution.split("\n")

for i, s in enumerate(all_solutions):
    list_solution = s.split(" ")
    generate_excel_from_solution(list_solution, "Orario (Soluzione: {})".format(i+1))






