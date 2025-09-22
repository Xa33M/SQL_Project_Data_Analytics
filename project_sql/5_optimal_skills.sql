/*
Identify the most optimal skills for Entry / Junior level
Data Analyst jobs that don't require a degree.
- Criteria for skill to be optimal:
    - It should be high paying.
    - It should be in high demand.
*/

/* 
Method 1: Using CTE's
- Get the most in-demand as well as highest 
paid skills.
for Data Analyst jobs from queries 3 and 4 and create 2 
CTE's with the names "top_paying_skills" and "top_
in_demand_skills".
- Join these 2 CTE's on the "skill_id" column, filter out
the skills with low demand and ORDER the results by job count and average yearly salary
in descending order.
- In ORDER BY, order the skills first by job count (in descending
order), then followed by average yearly salary
 (in descending order) to get the 
most in-demand skills first.
*/

WITH top_paying_skills AS(
    SELECT
        skills.skill_id AS skill_id,
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
        (job_title ILIKE '%Junior%' OR job_title ILIKE
    '%Entry%')
    GROUP BY
        skills.skill_id,
        skill
    ), 

top_in_demand_skills AS(
    SELECT
        skills.skill_id AS skill_id,
        skills.skills AS skill,
        COUNT(jobs_fact.job_id) AS demand_count
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
        jobs_fact.salary_year_avg IS NOT NULL
        AND
        jobs_fact.job_title_short = 'Data Analyst'
        AND
        jobs_fact.job_no_degree_mention = TRUE
        AND
        (job_title ILIKE '%Junior%' OR job_title ILIKE
    '%Entry%')
    GROUP BY
        skills.skill_id,
        skill
)

SELECT
    top_paying_skills.skill,
    top_in_demand_skills.demand_count,
    top_paying_skills.average_yearly_salary
FROM
    top_paying_skills
INNER JOIN
    top_in_demand_skills
    ON
    top_paying_skills.skill_id = top_in_demand_skills.skill_id
WHERE
    top_in_demand_skills.demand_count > 1
ORDER BY
    demand_count DESC,
    average_yearly_salary DESC;


/* 
Method 2: Writing the query without CTE's.
This method combines the skill name, demand count and 
average yearly salary all into a single query,
with: 
-   The addition of "HAVING" clause to filter out skills with
low demand. 
-   Reversing of the ordering sequence in the 
ORDER BY, with average yearly salary coming before
demand count, both again in descending order. This 
gives us the highest paid skills first.
*/

SELECT
    skills.skills AS skill,
    COUNT(jobs_skills.job_id) AS demand_count,
    ROUND(AVG(jobs_fact.salary_year_avg), 0) AS average_yearly_salary
FROM
    job_postings_fact AS jobs_fact
INNER JOIN
    skills_job_dim AS jobs_skills
    ON 
    jobs_fact.job_id = jobs_skills.job_id
INNER JOIN
    skills_dim AS skills
    ON jobs_skills.skill_id = skills.skill_id
WHERE
    jobs_fact.salary_year_avg IS NOT NULL
    AND
    jobs_fact.job_title_short = 'Data Analyst'
    AND
    jobs_fact.job_no_degree_mention = TRUE
    AND
    (job_title ILIKE '%Junior%' OR job_title ILIKE
    '%Entry%')
GROUP BY
    skills.skills
HAVING
    COUNT(jobs_skills.job_id) > 1
ORDER BY
    average_yearly_salary DESC,
    demand_count DESC;

/*
From these results, we gather:
- SQL is the most in-demand skill for Entry level roles.
It also ranks in the top 3 most paid skills.
- NoSQL is the highest paid skill for entry level
jobs, but it is not in much demand.
- Excel is still very much relevant
as it comes in the top 5 skills, with resepct to
both the demand and the compensation.
- Visualization tools (Looker, Tableau, Power BI)
consistently rank at the bottom of the result in both
aspects.
*/