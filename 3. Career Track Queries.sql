#Carrer Track Enrollments at Online Education Company
#Andrea Wupuy

#Database
USE sql_and_tableau;

#0. Export CSV
SELECT 
	ctse.student_id,
	ROW_NUMBER() OVER (ORDER BY student_id, track_name DESC) AS student_track_id_count,
	ctse.track_id,
	cti.track_name,
	ctse.date_enrolled,
	ctse.date_completed,
	(CASE WHEN date_completed IS NULL 
	THEN 0
	ELSE 1 
	END) AS track_completed,
	DATEDIFF(ctse.date_completed, ctse.date_enrolled) AS days_for_completion
FROM 
	career_track_student_enrollments AS ctse
LEFT JOIN 
	career_track_info AS cti
ON 
	cti.track_id = ctse.track_id
;


# 1.	What is the number of enrolled students monthly? 
# Which is the month with the most enrollments? Speculate about the reason for the increased numbers.
SELECT 
	MONTH(date_enrolled) AS enrolled_month,
    COUNT(DISTINCT (student_id)) AS total_studen_enrolled
FROM 
	career_track_student_enrollments
GROUP BY 
	enrolled_month
ORDER BY 
	total_studen_enrolled DESC;
# Students can be enrolled in multiple tracks at the same time in that sense to determine the number of monthly enrollments, 
# each student is being uniquely count regardless of the number of tracks enrolled

#2.	Which career track do students enroll most in?
SELECT 
    cti.track_name,
    COUNT(DISTINCT (student_id)) AS total_studen_enrolled
FROM 
	career_track_student_enrollments AS ctse
LEFT JOIN 
	career_track_info AS cti
ON 
	cti.track_id = ctse.track_id
GROUP BY 
	cti.track_name
ORDER BY 
	total_studen_enrolled DESC;
# Data Analyst, with over 5,000 students enrolled in the analyzed timeframe, is the most enrolled track. 
# Followed by Data Scientist and Business Analyst with 3,843 and 1,468 respectively.

#3.	What is the career track completion rate? Can you say if it’s increasing, decreasing, or staying constant with time?

#3.1 Total Track completion rate
SELECT
    SUM(
        CASE WHEN DATEDIFF(ctse.date_completed, ctse.date_enrolled) >= 0
        THEN 1
        ELSE 0
        END
    ) / COUNT(ctse.student_id) AS track_completion,
    COUNT(ctse.student_id) AS total_enrollements,
    SUM(
        CASE WHEN DATEDIFF(ctse.date_completed, ctse.date_enrolled) >= 0
        THEN 1
        ELSE 0
        END
    ) AS total_complition
FROM
    career_track_student_enrollments AS ctse
;
#This online education company has an overall completion rate of 1.18%

#3.2 Monthly Track completion rate
SELECT
	MONTH(ctse.date_enrolled) AS month_,
    SUM(
        CASE WHEN DATEDIFF(ctse.date_completed, ctse.date_enrolled) >= 0
        THEN 1
        ELSE 0
        END
    ) * 1.0 / COUNT(ctse.student_id) AS track_completion,
    COUNT(ctse.student_id),
    SUM(
        CASE WHEN DATEDIFF(ctse.date_completed, ctse.date_enrolled) >= 0
        THEN 1
        ELSE 0
        END
    ) AS complition
FROM
    career_track_student_enrollments AS ctse
GROUP BY month_
ORDER BY month_ ASC
;
# This rate varies monthly with no clear tendency of growth, with August being the month with highest completion rate, 2.3%.

#3.3 Completion rate by track
SELECT
	cti.track_name,
    SUM(
        CASE WHEN DATEDIFF(ctse.date_completed, ctse.date_enrolled) >= 0
        THEN 1
        ELSE 0
        END
    ) * 1.0 / COUNT(ctse.student_id) AS track_completion,
    COUNT(ctse.student_id),
    SUM(
        CASE WHEN DATEDIFF(ctse.date_completed, ctse.date_enrolled) >= 0
        THEN 1
        ELSE 0
        END
    ) AS complition
FROM
    career_track_student_enrollments AS ctse
LEFT JOIN 
	career_track_info AS cti
ON 
	cti.track_id = ctse.track_id
GROUP BY 
	ctse.track_id
ORDER BY 
	ctse.track_id ASC
;
# The highest completion rate is from the Business Analyst track with 2.11%, followed by Data Scientist and Data Analyst with 1.12% and 0.96% respectively. 

#4.	How long does it typically take students to complete a career track? 
#What type of subscription is most suitable for students who aim to complete a career track: monthly, quarterly, or annual?

#4.1 Completion time
SELECT
    AVG(DATEDIFF(ctse.date_completed, ctse.date_enrolled)),
    MAX(DATEDIFF(ctse.date_completed, ctse.date_enrolled)),
    MIN(DATEDIFF(ctse.date_completed, ctse.date_enrolled))
FROM 
	career_track_student_enrollments AS ctse
LEFT JOIN 
	career_track_info AS cti
ON 
	cti.track_id = ctse.track_id
WHERE 
	DATEDIFF(date_completed, date_enrolled)>=0
;
#On average, a student takes 132 days to complete a career track, still this varies among tracks.
#The maximum time for any track to be completed is over 400 days.

#4.2 Completion time by Track name
SELECT
	cti.track_name,
    AVG(DATEDIFF(ctse.date_completed, ctse.date_enrolled)),
    MAX(DATEDIFF(ctse.date_completed, ctse.date_enrolled)),
    MIN(DATEDIFF(ctse.date_completed, ctse.date_enrolled))
FROM 
	career_track_student_enrollments AS ctse
LEFT JOIN 
	career_track_info AS cti
ON 
	cti.track_id = ctse.track_id
WHERE 
	DATEDIFF(date_completed, date_enrolled)>=0
GROUP BY 
	cti.track_name
;
#Data Scientists taking up to 150 days on average to be completed, Data Analyst 133 days and Business Analyst about 104 days. 