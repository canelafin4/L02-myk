Aluno: 
Procedure excluir_aluno: Exclui um aluno e suas matrículas no banco com base no ID. 
Exemplo:
BEGIN 
    excluir_aluno(4);
END;
Cursor alunos_maiores_18: Lista os alunos maiores de 18 anos exibindo nome e data de nascimento.
Cursor alunos_por_curso: Lista os nomes dos alunos matriculados em um curso específico informado pelo ID.

Disciplina:
Procedure cadastrar_disciplina: Cadastra uma nova disciplina com nome, descrição, e carga horária.
Exemplo: 
BEGIN
    cadastrar_disciplina(
        p_nome => 'PROGRAMARIA',
        p_descricao => 'aq voce aprende a fezer programação',
        p_carga_horaria => 6553895325
    );
END;
Cursor c_disciplina_alunos: Lista disciplinas com mais de 10 alunos matriculados, mostrando o total de alunos.
Cursor alunos_matriculados (Média de Idade): Calcula a média de idade dos alunos matriculados em uma disciplina específica.
Procedure listar_alunos_disciplina: Lista os nomes dos alunos ativos matriculados em uma disciplina.

Professor
Cursor c_professor_turmas: Lista os professores que lecionam em mais de uma turma, exibindo o total de turmas.
Function total_turmas_professor: Retorna o total de turmas associadas a um professor específico.
Function nome_professor_disciplina: Retorna o nome do professor responsável por uma disciplina específica.
