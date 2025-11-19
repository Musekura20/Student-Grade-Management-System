-- STUDENTS TABLE (basic student info)
CREATE TABLE students (
    student_id NUMBER PRIMARY KEY,
    student_name VARCHAR2(100)
);

-- GRADES TABLE (each student has 5 grades)
CREATE TABLE student_grades (
    student_id NUMBER,
    grade_number NUMBER,
    grade_value NUMBER,
    CONSTRAINT fk_student FOREIGN KEY (student_id)
        REFERENCES students(student_id)
);
-- Students
INSERT INTO students VALUES (1, 'Alice M');
INSERT INTO students VALUES (2, 'Brian K');
INSERT INTO students VALUES (3, 'Celine T');

-- Grades (valid grades for Alice)
INSERT INTO student_grades VALUES (1, 1, 80);
INSERT INTO student_grades VALUES (1, 2, 75);
INSERT INTO student_grades VALUES (1, 3, 90);
INSERT INTO student_grades VALUES (1, 4, 85);
INSERT INTO student_grades VALUES (1, 5, 88);

-- Grades for Brian (poor performance)
INSERT INTO student_grades VALUES (2, 1, 40);
INSERT INTO student_grades VALUES (2, 2, 42);
INSERT INTO student_grades VALUES (2, 3, 35);
INSERT INTO student_grades VALUES (2, 4, 48);
INSERT INTO student_grades VALUES (2, 5, 30);

-- Celine has invalid/missing grade (used to trigger GOTO)
INSERT INTO student_grades VALUES (3, 1, 70);
INSERT INTO student_grades VALUES (3, 2, NULL);   -- missing
INSERT INTO student_grades VALUES (3, 3, 82);
INSERT INTO student_grades VALUES (3, 4, 88);
INSERT INTO student_grades VALUES (3, 5, 91);

COMMIT;
CREATE TABLE report_results (
    student_id NUMBER,
    student_name VARCHAR2(100),
    average_grade NUMBER(5,2),
    result VARCHAR2(20),
    remark VARCHAR2(100)
);
DECLARE
    -- Collection (varray) to store 5 grades
    TYPE grade_list IS VARRAY(5) OF NUMBER;

    -- Record to store student info + average
    TYPE student_rec IS RECORD (
        id   students.student_id%TYPE,
        name students.student_name%TYPE,
        avg  NUMBER
    );

    v_grades grade_list := grade_list();  -- empty collection
    v_student student_rec;

    CURSOR c_students IS
        SELECT student_id, student_name FROM students;

    v_invalid BOOLEAN := FALSE;
BEGIN
    DELETE FROM report_results;

    FOR s IN c_students LOOP
        -- put student info inside record
        v_student.id := s.student_id;
        v_student.name := s.student_name;
        v_invalid := FALSE;

        -- Get 5 grades
        v_grades.DELETE;
        FOR g IN 1..5 LOOP
            SELECT grade_value INTO v_grades.EXTEND RETURNING grade_number, grade_value
            FROM student_grades
            WHERE student_id = s.student_id AND grade_number = g;

            -- check invalid
            IF v_grades(g) IS NULL OR v_grades(g) < 0 OR v_grades(g) > 100 THEN
                v_invalid := TRUE;
                GOTO skip_student;  -- jump to skip section
            END IF;
        END LOOP;

        -- compute average
        v_student.avg := (v_grades(1) + v_grades(2) + v_grades(3) + v_grades(4) + v_grades(5)) / 5;

        -- save result
        INSERT INTO report_results VALUES (
            v_student.id,
            v_student.name,
            v_student.avg,
            CASE WHEN v_student.avg >= 50 THEN 'PASS' ELSE 'FAIL' END,
            'Processed successfully'
        );
        CONTINUE;

        <<skip_student>>
        INSERT INTO report_results VALUES (
            v_student.id,
            v_student.name,
            NULL,
            'SKIPPED',
            'Invalid or missing grade detected'
        );
    END LOOP;

    COMMIT;
END;
/
