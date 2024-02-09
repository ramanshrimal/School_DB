use [SchoolDB]
go


/***************************************************************************
Name	: code for schoolDB
Author  : Raman shrimal
Date	: sept 01, 2023

purpose : This script will create db and few table in it to store info about
school
***************************************************************************/


--Q1 - List the course wise no.of student enrolled.provide the information only for student
--of forgin origin and only if total exceeds 3.
--ANS : 
Select * From StudentMaster
Select * From CourseMaster
Select * From ENROLL_MASTER


--Subquery :
		Select C.CID,C.NAME as CourseName,Count(*) as NoOfEnrollments
		From  ENROLL_MASTER as A Join StudentMaster as B on A. SID=B.SID 
		Join CourseMaster as C on A.CID= C.CID
		Where Origin = 'F' 
		Group By C.CID,C.NAME
		Having Count(*) > 3
		go

--Q2 . list the Name of students who have not enrolled for Java Course .
		
		Select * 
		From StudentMaster
		Where SID Not in (
		Select Distinct C.SID
		From ENROLL_MASTER as A Join CourseMaster as B on A.CID = B.CID
		Join StudentMaster as C on A.SID = C.SID
		Where B.NAME = 'JAVA')
		go

--Q3 . List the ame of advanced course where the Enrollment by forgin student is the highest .

		--Using Rank
		select * 
		From
		(Select B.CID as CourseID ,B.Name as CoursName , Count (*) as Cnt ,
		Rank() Over (Order by Count (*) DESC) as Rno  
		From ENROLL_MASTER as A Join CourseMaster as B on A.CID = B.CID
		Join StudentMaster as C on A.SID = C.SID
		Where Origin = 'F' and CATEGORY = 'A'
		Group By B.CID ,B.Name
		)as k
		Where Rno = 1
		go

--	4 . List the names of the students who have enrolled for atleast one basic course in the current month.

		SELECT DISTINCT S.Name
		FROM StudentMaster as S
		INNER JOIN ENROLL_MASTER as E ON S.SID = E.SID
		INNER JOIN CourseMaster as C ON E.CID = C.CID
		WHERE MONTH(E.DOENROOL) = MONTH(GETDATE()) 
		AND C.CATEGORY = 'Basic'
		go

--5 . List the names of the Undergraduate , local students who have got a “C” grade in any basic course. 
		
		SELECT DISTINCT S.NAME
		FROM StudentMaster  as S
		INNER JOIN ENROLL_MASTER as E ON S.SID = E.SID
		INNER JOIN CourseMaster as C ON E.CID = C.CID
		WHERE S.TYPE = 'UG'
		AND S.ORIGIN = 'Local' 
		AND C.CATEGORY = 'Basic' 
		AND E.GRADE = 'C'
		go

--6 . List the names of the courses for which no student has enrolled in the month of May 2006 .

		SELECT DISTINCT C.NAME
		FROM CourseMaster as C
		WHERE C.CID NOT IN (
		SELECT E.CID
		FROM ENROLL_MASTER as E
		WHERE MONTH(e.DOENROOL) = 5
		AND YEAR(e.DOENROOL) = 2006
		)
		go


--7 . List name, Number of Enrollmennts and Popularity for all Courses. Popularity has to be displayed 
--as “High” if number of enrollments is higher than 50, “Medium” if greater than or equal to 20 and less than 
--50 , and “Low” if the no. Is less than 20 . 

		SELECT 
		C.NAME ,
			COUNT(E.CID) AS NumberOfEnrollments,
			CASE 
				WHEN COUNT(E.CID) > 50 THEN 'High'
				WHEN COUNT(E.CID) >= 20 AND COUNT(E.CID) <= 50 THEN 'Medium'
				ELSE 'Low'
			END AS Popularity
		FROM 
			CourseMaster as  C
		LEFT JOIN 
			ENROLL_MASTER as E ON C.CID = E.CID
		GROUP BY 
			C.NAME


--8 . List the most recent enrollment details with information on Student Name, 
--Course name and age of enrollment in days. 

		SELECT 
			S.NAME,
			C.NAME,
			DATEDIFF(DAY, E.DOENROOL, GETDATE()) AS AgeOfEnrollmentInDays
		FROM 
			ENROLL_MASTER as E
		JOIN 
			StudentMaster as S ON E.SID = S.SID
		JOIN 
			CourseMaster as C ON E.CID = C.CID
		WHERE 
			E.DOENROOL = (
				SELECT MAX(DOENROOL)
				FROM ENROLL_MASTER
				WHERE SID = E.SID
			)
			go


--9 . List the names of the Local students who have enrolled for exactly 3 basic courses.

		SELECT S.NAME
		FROM StudentMaster as S
		INNER JOIN ENROLL_MASTER as E ON S.SID = E.SID
		INNER JOIN CourseMaster as C ON E.CID = C.CID
		WHERE S.ORIGIN = 'Local' 
		AND C.CATEGORY = 'Basic' 
		GROUP BY S.SID, S.NAME
		HAVING COUNT(DISTINCT C.CID) = 3
	    go


--10 . List the names of the Courses enrolled by all (every) students . 

		SELECT C.NAME
		FROM CourseMaster as C
		WHERE NOT EXISTS (
				SELECT DISTINCT S.SID
				FROM StudentMaster as S
				WHERE NOT EXISTS (
					SELECT 1
					FROM ENROLL_MASTER as E
					Where E.SID = S.SID
					AND E.CID =C.CID )
				)



--11 . For those enrollments for which fee have been waived , provide the nanes of students who have got "0" Grade.

		SELECT DISTINCT S.SID
		FROM StudentMaster as S
		JOIN ENROLL_MASTER as E On S.SID = E.SID
		JOIN CourseMaster as C On E.CID = C.CID     
		WHERE E.FREEWAIVERFIAG = 1                                       
		AND E.Grade = 'O'


--12.List the names of the foreign , undergraduate students who have got grade ‘C ’ in any basic course . 

		SELECT DISTINCT S.NAME
		FROM StudentMaster as S
		JOIN ENROLL_MASTER as E on S.SID = E.SID
		JOIN CourseMaster as C On E.CID = C.CID
		WHERE S.TYPE = 'UG'
		AND S.ORIGIN = 'F'
		AND C.CATEGORY = 'B'
		AND E.Grade = 'C'


--13.List the course name, total no. of enrollments in the Current Month .


		Select C.NAME ,Count (*) as TotalEnrollments
		From CourseMaster as C
		Join ENROLL_MASTER as E ON C.CID = E.CID
		Where MONTH(E.DOENROOL) = MONTH(GetDate())
		And YEAR (E.DOENROOL) = YEAR (GetDate())
		Group By C.NAME

