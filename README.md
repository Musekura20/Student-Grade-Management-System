PROJECT TITLE: Student grade management system using PL/SQL collections, records and GOTO

1. Problem identification
   
A school wants a simple PL/SQL program that can:

-store student names and their grades

-calculate each student's averages

-decide who passed and who failed

-skip invalid data when found

2.To achieve this my program is going to use:

-Collections: to store multiple grades from the grades table

-Records: to hold each student’s information

-GOTO: to jump past a student if invalid data is detected

At the end the program will give output showing: student Id, student name, average grade and pass/fail


3. what's inside the repository
   
-student-grade-management.sql:contains table creation, sample data and PL/SQL program

4. Ways in which this program works
   
-Each student is registered in students table

-Their grades (5 per student) are saved in the student_grades table

-The PL/SQL code loads their 5 grades into a collection

-It checks for missing or invalid grades (like <0 or >100)

-If invalid, the program uses GOTO to skip to the next student

-Otherwise, it makes averages and decides:

  -pass if average >= 50;
  
  -fail if average < 50




