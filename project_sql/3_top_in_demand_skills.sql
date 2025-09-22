/*
What are the top in-demand skills for Junior / Entry level
Data Analysts jobs that don't require a degree?
- Get the skill name and count of how many times a skill 
appears in these jobs.
- Group by the skill name and find the top 5 skills for entry level
jobs.
*/

SELECT
    skills.skills AS skill,
    count(jobs_fact.job_id) AS job_count
FROM
    job_postings_fact AS jobs_fact
INNER JOIN
    skills_job_dim  AS jobs_skills
    ON
    jobs_fact.job_id = jobs_skills.job_id
INNER JOIN
    skills_dim AS skills
    ON
    jobs_skills.skill_id = skills.skill_id
WHERE
    jobs_fact.job_title_short = 'Data Analyst'
    AND
    jobs_fact.job_no_degree_mention = TRUE
    AND
    (job_title ILIKE '%Junior%' OR job_title ILIKE
    '%Entry%')
GROUP BY
    skill
ORDER BY
    job_count DESC
LIMIT 5;


/* While mid and senior level roles in Data Analytics focus 
more on sql and python, Junior / Entry level jobs that don't
require a degree emphasize Excel more than other tools. From 
this observation, we can infer that while Excel is still quite
relevant in other Analytics roles, it is crucial for Entry level
roles.
*/