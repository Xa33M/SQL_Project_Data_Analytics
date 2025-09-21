/* What are the skills required for top 10
Entry level Data Analyst jobs that don't require 
a degree?
- Reference the first query in this project.
- Find out the skills required for these jobs.
- Reason? Job seekers, by using this query, can get
a glimpse of what skills are required in order to secure these
high paying, entry level jobs.
*/

WITH DataAnalyst_EntryLevel_Top10 AS(
    SELECT
        jobs_fact.job_id,
        companies.name AS company_name,
        jobs_fact.job_title AS job_title,
        jobs_fact.salary_year_avg AS average_yearly_salary
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
        ((job_title ILIKE '%Junior%' OR job_title ILIKE
        '%Entry%') AND (job_title NOT ILIKE '%Consultant%'))
        AND 
        job_no_degree_mention = TRUE
    ORDER BY
        jobs_fact.salary_year_avg DESC
    LIMIT 10
)

SELECT
    DataAnalyst_EntryLevel_Top10.*,
    skills.skills AS skill
FROM
    DataAnalyst_EntryLevel_Top10
INNER JOIN
    skills_job_dim AS jobs_skills
    ON
    DataAnalyst_EntryLevel_Top10.job_id = jobs_skills.job_id
INNER JOIN
    skills_dim AS skills
    ON 
    jobs_skills.skill_id = skills.skill_id
