--Aluno:
--1 Procedure de exclusão de aluno
CREATE OR REPLACE PROCEDURE excluir_aluno(p_id_aluno IN NUMBER) AS
BEGIN
    DELETE FROM matricula WHERE id_aluno = p_id_aluno;
    
    DELETE FROM aluno WHERE id_aluno = p_id_aluno;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir aluno: ' || SQLERRM);
END;

BEGIN 
    excluir_aluno(4);
END;

--2 Cursor de listagem de alunos maiores de 18 anos
DECLARE
    CURSOR alunos_maiores_18 IS
        SELECT nome, data_nascimento
        FROM aluno
        WHERE TRUNC(SYSDATE) - data_nascimento > 18 * 365;

    v_nome aluno.nome%TYPE;
    v_data_nascimento aluno.data_nascimento%TYPE;
BEGIN
    OPEN alunos_maiores_18;

    LOOP
        FETCH alunos_maiores_18 INTO v_nome, v_data_nascimento;
        
        EXIT WHEN alunos_maiores_18%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Nome: ' || v_nome || ', Data de Nascimento: ' || TO_CHAR(v_data_nascimento, 'DD-MM-YYYY'));
    END LOOP;
    
    CLOSE alunos_maiores_18;
END;

--3 Cursor com filtro por curso
DECLARE
    CURSOR alunos_por_curso (v_id_curso NUMBER) IS
        SELECT a.NOME AS nome_aluno
        FROM MATRICULA m
        JOIN ALUNO a ON m.ID_ALUNO = a.ID_ALUNO
        JOIN DISCIPLINA d ON m.ID_DISCIPLINA = d.ID_DISCIPLINA
        JOIN CURSO c ON d.ID_CURSO = c.ID_CURSO
        WHERE c.ID_CURSO = v_id_curso;

    v_nome_aluno ALUNO.NOME%TYPE;
BEGIN
    FOR aluno IN alunos_por_curso(1) LOOP -- Substitua "1" pelo ID do curso desejado
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || aluno.nome_aluno);
    END LOOP;
END;
/

--DISCIPLINA

--1 Procedure de cadastro de disciplina
CREATE OR REPLACE PROCEDURE cadastrar_disciplina(
    p_nome IN VARCHAR2,
    p_descricao IN CLOB,
    p_carga_horaria IN NUMBER
) AS
BEGIN
    INSERT INTO disciplina (nome, descricao, carga_horaria)
    VALUES (p_nome, p_descricao, p_carga_horaria);
    DBMS_OUTPUT.PUT_LINE('Disciplina cadastrada com sucesso: ' || p_nome);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro ao cadastrar disciplina: ' || SQLERRM);
END;
BEGIN
    cadastrar_disciplina(
        p_nome => 'PROGRAMARIA',
        p_descricao => 'aq voce aprende a fezer programação',
        p_carga_horaria => 6553895325
    );
END;

--2 Cursor para total de alunos por disciplina
DECLARE
    v_id_disciplina  NUMBER;
    v_nome_disciplina VARCHAR2(100);
    v_total_alunos    NUMBER;

    CURSOR c_disciplina_alunos IS
        SELECT d.id_disciplina, d.nome, COUNT(m.id_aluno) AS total_alunos
        FROM disciplina d
        LEFT JOIN matricula m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.id_disciplina, d.nome
        HAVING COUNT(m.id_aluno) > 10;  

BEGIN
    OPEN c_disciplina_alunos;

    LOOP
        FETCH c_disciplina_alunos INTO v_id_disciplina, v_nome_disciplina, v_total_alunos;

        EXIT WHEN c_disciplina_alunos%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Disciplina: ' || v_nome_disciplina || 
                             ' | Total de Alunos: ' || v_total_alunos);
    END LOOP;

    CLOSE c_disciplina_alunos;

END;
/

--3 Cursor com média de idade por disciplina

DECLARE
    p_id_disciplina NUMBER := 2;

    CURSOR alunos_matriculados(p_id_disciplina IN NUMBER) IS
        SELECT a.data_nascimento
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;

    v_data_nascimento aluno.data_nascimento%TYPE;
    v_media_idade NUMBER(5,2);
    v_total_alunos NUMBER := 0;
    v_soma_idades NUMBER := 0;
BEGIN
    v_soma_idades := 0;
    v_total_alunos := 0;

    OPEN alunos_matriculados(p_id_disciplina);

    LOOP
        FETCH alunos_matriculados INTO v_data_nascimento;

        EXIT WHEN alunos_matriculados%NOTFOUND;

        v_soma_idades := v_soma_idades + FLOOR(MONTHS_BETWEEN(SYSDATE, v_data_nascimento) / 12);

        v_total_alunos := v_total_alunos + 1;
    END LOOP;

    IF v_total_alunos > 0 THEN
        v_media_idade := v_soma_idades / v_total_alunos;
        DBMS_OUTPUT.PUT_LINE('Média de idade dos alunos matriculados na disciplina ' || p_id_disciplina || ' : ' || v_media_idade);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nenhum aluno matriculado na disciplina ' || p_id_disciplina);
    END IF;

    CLOSE alunos_matriculados;
END;

--4 Procedure para listar alunos de uma disciplina
CREATE OR REPLACE PROCEDURE listar_alunos_disciplina(p_id_disciplina IN NUMBER) IS
    v_nome_aluno aluno.nome%TYPE;

    CURSOR c_alunos IS
        SELECT a.nome
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina AND m.status = 'Ativo';  

BEGIN
    OPEN c_alunos;

    IF c_alunos%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum aluno matriculado nesta disciplina.');
    ELSE
        LOOP
            FETCH c_alunos INTO v_nome_aluno;
            EXIT WHEN c_alunos%NOTFOUND;

           
            DBMS_OUTPUT.PUT_LINE('Aluno: ' || v_nome_aluno);
        END LOOP;
    END IF;

    CLOSE c_alunos;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao listar alunos: ' || SQLERRM);
END listar_alunos_disciplina;
/

EXEC listar_alunos_disciplina(1);

--Professor

--1 Cursor para total de turmas por professor
DECLARE
    CURSOR c_professor_turmas IS
        SELECT 
            p.nome AS nome_professor,
            COUNT(t.id_turma) AS total_turmas
        FROM 
            professor p
        JOIN 
            turma t ON p.id_professor = t.id_professor
        GROUP BY 
            p.nome
        HAVING 
            COUNT(t.id_turma) > 1; 

    v_nome_professor professor.nome%TYPE;
    v_total_turmas NUMBER;
BEGIN
    OPEN c_professor_turmas;

    LOOP
        FETCH c_professor_turmas INTO v_nome_professor, v_total_turmas;
        EXIT WHEN c_professor_turmas%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Professor: ' || v_nome_professor || ' - Total de Turmas: ' || v_total_turmas);
    END LOOP;

    CLOSE c_professor_turmas;
END;
/

--2 Function para total de turmas de um professor
CREATE OR REPLACE FUNCTION total_turmas_professor(p_id_professor IN NUMBER) 
RETURN NUMBER IS
    v_total_turmas NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_turmas
    FROM turma
    WHERE id_professor = p_id_professor;

    RETURN v_total_turmas;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro ao calcular total de turmas: ' || SQLERRM);
END total_turmas_professor;
/

--3 Function para professor de uma disciplin
CREATE OR REPLACE FUNCTION nome_professor_disciplina(p_id_disciplina IN NUMBER) 
RETURN VARCHAR2 IS
    v_nome_professor VARCHAR2(100);
BEGIN
    SELECT p.nome
    INTO v_nome_professor
    FROM professor p
    JOIN turma t ON p.id_professor = t.id_professor
    WHERE t.id_disciplina = p_id_disciplina;

    RETURN v_nome_professor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Nenhum professor encontrado para esta disciplina.';
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erro ao buscar professor: ' || SQLERRM);
END nome_professor_disciplina;
/

DECLARE
    v_nome_professor VARCHAR2(100);
BEGIN
    v_nome_professor := nome_professor_disciplina(1);
    DBMS_OUTPUT.PUT_LINE('O professor responsável pela disciplina é: ' || v_nome_professor);
END;
/


