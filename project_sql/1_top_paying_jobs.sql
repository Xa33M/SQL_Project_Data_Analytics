/*
Question: What are the top paying data analyst roles?
- Identify top 10 Data Analyst jobs that are Junior / Entry level and also
don't require a degree.
- What are the actual job titles for these jobs?
- Where are these jobs located?
- Do these jobs offer remote work option?
- Are these jobs full-time, part-time or contract?
- When were the jobs posted?
- Also mention the companies offering these jobs.
- Focus on those job postings that mention a salary.
Reason? Many people entering data analytics come from non-tech
backgrounds. This result set will allow them to explore their options.
*/

SELECT
    companies.name AS "Company Name",
    jobs_fact.job_title AS "Job Title",
    jobs_fact.job_location AS "Location",
    jobs_fact.job_work_from_home AS "Remote option available",
    jobs_fact.job_schedule_type AS "Schedule Type",
    jobs_fact.salary_year_avg AS "Average Yearly Salary",
    jobs_fact.job_posted_date::DATE AS "Posting Date"
FROM
    job_postings_fact AS jobs_fact
LEFT JOIN
    company_dim AS companies
    ON 
    jobs_fact.company_id = companies.company_id
WHERE
    salary_year_avg IS NOT NULL
    AND 
    job_title_short = 'Data Analyst'
    AND
    (job_title ILIKE '%Junior%' OR job_title ILIKE
    '%Entry%')
    AND 
    job_no_degree_mention = TRUE
ORDER BY
    salary_year_avg DESC
LIMIT 10;



