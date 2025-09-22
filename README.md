# Introduction
Welcome to this SQL project! In this project, we take the role of a job seeker and analyze the data job market, focusing on **Data Analyst** roles, where we will be looking at:
- Top paying jobs.
- Top in-demand skills.
- Optimal skills (high paying and high demand)<br><br>
You can check out the SQL queries here: [Project SQL queries](/project_sql/)

<br><br>

# Background 
A career in Data Analytics can be incredibly rewarding financially, and the tools and methods used are easily transferable to any domain, be it finance, manufacturing, healthcare or any other. However, the Data job market is evolving rapidly, and it is becoming increasingly difficult to land even an entry level role in this field. A big part of that problem results from job seekers not knowing what they're getting themselves into beforehand.
This small project will enable them to analyze not only the skills required, but also what salary to expect for a particular role.<br>
With this project, we will be answering these 5 questions:
1. What are the top paying jobs in Data Analytics?
2. What skills are required for these top paying jobs?
3. What are the most in-demand skills for Data Analytic roles?
4. What are the highest paid skills in Data Analytics?
5. What are the most optimal skills to learn to land a role in Data Analytics (high paying, high demand skills)?<br><br>The dataset for this project is sourced from "Luke Barousse's SQL Data Analysis Course". [Go to source](https://www.lukebarousse.com/sql)

<br><br>

# Tools I used
- **PostgreSQL:** This Database Management System (DBMS) is open source, and able to handle large datasets.
- **Visual Studio Code:** For connecting to Postgres, writing and executing SQL queries.
- **Git and Github:** Git For version control, and Github for sharing my work online with others to collaborate and track changes.

<br><br>

# Analysis
<br>

##  1. What are the top paying jobs in Data Analytics?
To answer this question, I looked at Data Analyst jobs that:
- Were **Junior / Entry** level,
- **Did not** require a degree, and
- Had a **salary value** mentioned in the posting

The above mentioned filters will be used throughtout this project, as I am focusing specifically on those jobs where the barrier to entry is the lowest.

```sql
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
```
![Alt text](/Images/Query_1.png)
What I gathered from the result set:
- **US dominates in entry level jobs:** &nbsp;With the exeption of one job, all the top 10 jobs are US based.
- **On-site presence is mandatory:** &nbsp; None of the filtered jobs has a **work from home** option.
- **Full-time commitment is required:** &nbsp; All jobs require you to be present in the office, full-time.
- **Unusually high salary in Austria:** This needs to be further investigated as to why the job in Vienna, Austria is paying higher than all other jobs.

<br>

## 2. What skills are required for these top paying jobs?

```sql
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
        (job_title ILIKE '%Junior%' OR job_title ILIKE
    '%Entry%')
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
```
The result:

![Alt text](/Images/Query_2.png)
- **SQL** is the top skill, appearing in 8 jobs.
- **NoSQL, Matlab, Python and R** are also popular, each appearing in 5 jobs. 
- **Excel** is not as popular as SQL for top 10 jobs, appearing in only 3 jobs.
- Data visualization tools, such as **Tableau, Power BI** are not essential for top 10 jobs.
- **Mystery solved:** The job in Vienna, Austria listed AWS and Spark as essential skills. AWS comes under **cloud skills**, whereas Spark comes under **Data Processing / ETL skills**, both of which offer much **higher pay** than pure data analyst jobs.
<br>

## 3. What are the most in-demand skills for Data Analytic roles?
To answer this, I needed to see how many times a skill appears in job postings. I also only focused on the top 5 skills so that job seekers know exactly what to tackle first.

```sql
SELECT
    skills.skills AS skill,
    COUNT(jobs_fact.job_id) AS job_count
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
    (jobs_fact.job_title ILIKE '%Junior%' OR 
    jobs_fact.job_title ILIKE '%Entry%')
GROUP BY
    skill
ORDER BY
    job_count DESC
LIMIT 5;
```
The result:
| Skill     | Job Count |
|-----------|-----------|
| Excel     | 1084      |
| SQL       | 1051      |
| Python    | 631       |
| Power BI  | 515       |
| Tableau   | 378       |

<br>

- **Excel** is still very much relevant for entry level jobs as it tops the list
- **SQL** is the bread and butter of data analysts, so it's no surprise that entry level jobs demand it.
- **Data visualization tools** like Tableau and Power BI
are also in high demnand.
- **Python** also makes it to the top 5 as it can be used 
for Exploratory Data Analysis and one can further upskill and add **Machine Learning** as one gets proficient in python.

<br>

## 4. What are the top paying skills for Data Analyst roles?
The query structure is mostly identical to the 3rd query, but here, I am aggregating on the average yearly salary per skill.

```sql
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
GROUP BY
    skill
ORDER BY
    average_yearly_salary DESC
LIMIT 25; 
```
<br>

The result:
| Skill         | Average Yearly Salary (USD) |
|---------------|-----------------------------|
| AWS           | 163,782                     |
| Spark         | 163,782                     |
| HTML          | 95,000                      |
| PHP           | 95,000                      |
| CSS           | 95,000                      |
| NoSQL         | 73,333                      |
| MATLAB        | 73,333                      |
| SQL           | 71,370                      |
| Excel         | 70,143                      |
| R             | 65,290                      |
| Python        | 62,637                      |
| VBA           | 60,000                      |
| Windows       | 57,500                      |
| Linux         | 57,500                      |
| Alteryx       | 56,700                      |
| Pandas        | 56,700                      |
| Scikit-learn  | 56,700                      |
| Looker        | 55,257                      |
| Power BI      | 55,200                      |
| Tableau       | 53,554                      |
| Go            | 51,500                      |
| Dplyr         | 50,400                      |
| Jupyter       | 50,400                      |


<br>
These results show that:

- Jobs requiring **Cloud skills** (e.g AWS) and **Data processing skills** (Spark) pay substantially more than other jobs.
- **Front-end programming languages** (HTML, CSS) are paid more than
core data analytical skills (SQL, Pyton etc.) which is odd, since 
these are not the core data analytics skills.
- **SQL and Excel** are positined pretty close together, which
shows how relevant Excel still is for Data Analytics, especially
when it comes to entry level jobs.

<br>

## 5. What are the most optimal skills to learn to land a role in data analytics (high paying, high demand)?
To answer this, we have to combine the results of queries 3 and 4 and SELECT only those skills that are common to both results. This query will use multiple CTE's.
#### Note: We will have to remove the LIMIT clause from both queries to get all the skills.
<br>

```sql
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
        (jobs_fact.job_title ILIKE '%Junior%' OR 
        jobs_fact.job_title ILIKE '%Entry%')
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
        (jobs_fact.job_title ILIKE '%Junior%' OR 
        jobs_fact.job_title ILIKE '%Entry%')
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
```
<br>
This will bring out 2 different results, one where the values are sorted first by demand_count followed by average_yearly_salary, and the other in which the sorting order is reversed.

<br>

When sorting by demand_count first, this is the result:
| Skill     | Demand Count | Average Yearly Salary (USD) |
|-----------|--------------|------------------------------|
| SQL       | 19           | 71,370                       |
| Python    | 12           | 62,637                       |
| R         | 10           | 65,290                       |
| Excel     | 7            | 70,143                       |
| MATLAB    | 6            | 73,333                       |
| NoSQL     | 6            | 73,333                       |
| Tableau   | 4            | 53,554                       |
| Looker    | 2            | 55,257                       |
| Power BI  | 2            | 55,200                       |

<br>

When sorting by average_yearly_salary first, the result comes:
| Skill     | Demand Count | Average Yearly Salary (USD) |
|-----------|--------------|------------------------------|
| NoSQL     | 6            | 73,333                       |
| MATLAB    | 6            | 73,333                       |
| SQL       | 19           | 71,370                       |
| Excel     | 7            | 70,143                       |
| R         | 10           | 65,290                       |
| Python    | 12           | 62,637                       |
| Looker    | 2            | 55,257                       |
| Power BI  | 2            | 55,200                       |
| Tableau   | 4            | 53,554                       |


<br>

From both these result sets, we gather:
- **SQL** is the most in-demand skill for Entry level roles.
It also ranks in the top 3 most paid skills.
- **NoSQL** is the highest paid skill for entry level
jobs, but it is not in much demand.
- **Excel** is still very much relevant
as it comes in the top 5 skills, with resepct to
both the demand and the compensation.
- **Visualization tools** (Looker, Tableau, Power BI)
consistently rank at the bottom of the result in both
aspects.

<br><br>

# What I learned
Throughout this project, I utilized multiple different features of SQL to craft queries, such as:
- **Aggregations** by using the COUNT, AVG and **GROUP BY**
- **Common table queries (CTE's)** to write complex, reusable queries.
- Filtering the data using the **WHERE** clause, also using priority filtering with parantheses ().
- **ORDER BY** and **LIMIT** to sort the data, making sure the job seekr focuses on the things that matter the most.

I also fully grasped the analytical thought process, of how to write queries that get the desired results in an efficient way, and how to answer key questions using Data and SQL

<br><br>

# Conclusion

### Key Insights:
1. **Top paying Data Analyst jobs:** Most of the jobs are located in the US, are full-time and on-site.
2. **Skills for top paying jobs:** SQL is the most sought-after skill in these jobs, followed by programming languages like Python, R, Matlab, noSQL, and then Excel. Some niche roles require cloud skills (e.g AWS) and data engineering / ETL skills (Spark) and are highly paid.
3. **Top in-demand skills:** Excel and SQL are very close to each other and rank above all other skills.
4. **Top paying skills:** Cloud skills are highly paid. Jobs with additional data engineering skills are also highly paid, representing the need for learning how to execute end-to-end projects, from source to analytics, in these niche roles.
Core data analytics skills (SQL, Excel, Python etc.) are in the middle of the pack when it comes to salary.
5. **Most optimal skills:** SQL again emerges as the most 
essential skill, as it is the most in-demand and also ranks in the top 3 in terms of compensation, whereas noSQL is highly paid in some niche roles. Excel, again, is a very desirable skill, both in terms of demand and salary.

### Closing thoughts:
In the world of Data Analytics, competition is fierce and if one aspires to enter this field, he / she should know exactly what to learn and how to position themselves so that they stand distinguished among the crowd. Learning high-impact, high paying skills is essential not only to land a job, but also to test whether this field will be a good fit for them or not. Learning a skill is only part of the problem, showcasing it is another thing and that's where projects come from. I, among many others, have done this project to showcase my skills, so that one day, I might get a job, but whether I get the job or not, even if one person lands a role in Data after seeing my work, I would consider this a big achievement on my part. 
