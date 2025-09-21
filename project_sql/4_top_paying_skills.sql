/* What are the top 25 highest paid skills for Junior / Entry 
level Data Analyst jobs that don't require a degree?
- Find the average yearly salary of all skills.
- Filter for above mentioned conditions.
*/

SELECT
    skills.skills AS skill,
    ROUND(AVG(jobs_fact.salary_year_avg), 0) as average_yearly_salary
FROM
    job_postings_fact AS jobs_fact
INNER JOIN
    skills_job_dim AS jobs_skills
    ON
    jobs_fact.job_id = jobs_skills.job_id
INNER JOIN
    skills_dim AS skills
    ON
    jobs_skills.skill_id = skills.skill_id
WHERE
    jobs_fact.salary_year_avg IS NOT NULL
    AND
    jobs_fact.job_title_short = 'Data Analyst'
    AND
    jobs_fact.job_no_degree_mention = TRUE
    AND
    (jobs_fact.job_title ILIKE '%Junior%' OR 
    jobs_fact.job_title ILIKE '%Entry%')
    AND
    (jobs_fact.job_title NOT ILIKE '%Web%' OR
    jobs_fact.job_title NOT ILIKE '%Dev%' OR
    jobs_fact.job_title NOT ILIKE '%Engineer%')
GROUP BY
    skill
ORDER BY
    average_yearly_salary DESC
LIMIT 25; 

/* From these results, we gather that:
- Jobs requiring Cloud skills (e.g AWS) and Data processing
 skills (Spark) pay substantially more than other jobs.
- Front-end programming languages (HTML, CSS) are paid more than
core data analytical skills (SQL, Pyton etc.) which is odd, since 
these are not the core data analytics skills.
SQL and Excel are positined pretty close together, which
shows how relevant Excel still is for Data Analytics, especially
when it comes to entry level jobs.
- */
