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
5. What are the most optimal skills to learn to land a role in Data Analytics (high paying, high demand skills)?<br><br>The dataset for this project is sourced from "Luke Barousse's SQL Data Analysis Course". The original dataset is limited to the year 2023, which is updated to 30th June, 2025 with the purchase of supporter resources. [Go to source](https://www.lukebarousse.com/sql)

<br><br>

# Tools I used
- **PostgreSQL:** This Database Management System (DBMS) is open source, and able to handle large datasets.
- **Visual Studio Code:** For connecting to Postgres, writing and executing SQL queries.
- **Git and Github:** Git For version control, and Github for sharing my work online with others to collaborate and track changes.

<br><br>

# Analysis
<br>

##  1. What are the top paying jobs in Data Analytics?
To answer this question, we will look at Data Analyst jobs that:
- Were **Junior / Entry** level,
- **Did not** require a degree, and
- Had a **salary value** mentioned in the posting

The above mentioned filters will be used throughtout this project, as we are focusing specifically on those jobs where the barrier to entry is the lowest.

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
- **Half of the jobs are in the US:** &nbsp;50 % of the jobs are from US based companies, while the rest are from around the world.
- **On-site jobs dominate:** &nbsp; 8 out of the 10 jobs require the person to be in-office, while the remaining 2 are remote.
- **Full-time commitment is required:** &nbsp; All jobs require you to be present in the office, full-time. One job's schedule is not prorperly laid out, mentioning "Full-time, part-time, and Contractor" which needs to be mentioned properly in the job posting.
- **Wide salary range:** Jobs range in salary from 85k - 163k dollars, which shows that job location plays an important role in the pay you can expect for a certain role.

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
- **Excel** is the next most popular skill, appearing in 5 jobs.
- **Python** completes the top 3, appearing in only 2 jobs. 
- Out of the 2 most popular Data visualization tools (Tableau and Power BI), only *Tableau* is mentioned, appearing in only 1 job.

<br>

## 3. What are the most in-demand skills for Data Analytic roles?
To answer this, we need to see how many times a skill appears in job postings. We also will only be focusing on the top 5 skills so that job seekers know exactly what to tackle first.

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
| Excel     | 2227      |
| SQL       | 2096      |
| Python    | 1412      |
| Power BI  | 1084      |
| Tableau   | 822       |
<br>

- **Excel** is still very much relevant for entry level jobs as it tops the list
- **SQL** is the bread and butter of data analysts, so it's no surprise that entry level jobs demand it.
- **Python** also makes it to the top 5 as it can be used 
for Exploratory Data Analysis and one can further upskill and add **Machine Learning** as one gets proficient in python.
- **Data visualization tools** like Tableau and Power BI
are also in high demand.

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
| Skill       | Average Yearly Salary (USD) |
|-------------|-----------------------------|
| Spark       | 163,782                     |
| AWS         | 101,261                     |
| HTML        | 95,000                      |
| CSS         | 95,000                      |
| PHP         | 95,000                      |
| Snowflake   | 77,500                      |
| MATLAB      | 73,333                      |
| NoSQL       | 73,333                      |
| BigQuery    | 72,500                      |
| MySQL       | 70,000                      |
| Redshift    | 70,000                      |
| Bash        | 70,000                      |
| Kubernetes  | 70,000                      |
| Unify       | 70,000                      |
| PostgreSQL  | 70,000                      |
| Kafka       | 70,000                      |
| Airflow     | 70,000                      |
| Azure       | 68,750                      |
| SQL         | 68,618                      |
| Excel       | 68,504                      |
| Spring      | 68,000                      |
| Hadoop      | 66,250                      |
| Word        | 65,175                      |
| Python      | 64,528                      |
| R           | 64,508                      |

<br>
These results show that:

- **Shift in job requirements:** Although SQL and Excel still make it to the top 25, there is a visible shift from traditional data analytical skills (Excel, SQL, Visualization tools) to more end-to-end skills, as several of the skills mentioned (Kubernetes, Spark, Hadoop, Kafka, Airflow) are more geared towards data engineering, with Spark paying much more than others.
- **Cloud skills are a must**: General cloud skills (AWS, Azure) as well as specialized cloud data warehouse skills (Snowflake, BigQuery, Redshift) are highly paid.
- **Microsoft SQL Server did not make the list**: PostgreSQL and mySQL are equally paid, though.

<br>

## 5. What are the most optimal skills to learn to land a role in data analytics (high paying, high demand)?
To answer this, we have to combine the results of queries 3 and 4 and SELECT only those skills that are common to both results. This query will use multiple CTE's.
#### Note: We will have to remove the LIMIT clause from both queries to get all the skills. We will also include only those skills with a demand count of atleast 2.
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
| Skill       | Demand Count | Average Yearly Salary (USD) |
|-------------|--------------|------------------------------|
| SQL         | 40           | 68,618                       |
| Python      | 28           | 64,528                       |
| Excel       | 18           | 68,504                       |
| R           | 13           | 64,508                       |
| Tableau     | 13           | 59,738                       |
| Power BI    | 7            | 59,443                       |
| MATLAB      | 6            | 73,333                       |
| NoSQL       | 6            | 73,333                       |
| Word        | 4            | 65,175                       |
| Looker      | 4            | 53,879                       |
| AWS         | 3            | 101,261                      |
| SQL Server  | 3            | 56,458                       |
| VBA         | 3            | 50,858                       |
| PowerPoint  | 3            | 49,400                       |
| PostgreSQL  | 2            | 70,000                       |
| Azure       | 2            | 68,750                       |
| Spring      | 2            | 68,000                       |
| Hadoop      | 2            | 66,250                       |
| Linux       | 2            | 63,750                       |
| Pandas      | 2            | 58,350                       |
| Alteryx     | 2            | 49,950                       |
<br>

When sorting by average_yearly_salary first, the result comes:
| Skill       | Demand Count | Average Yearly Salary (USD) |
|-------------|--------------|------------------------------|
| AWS         | 3            | 101,261                      |
| MATLAB      | 6            | 73,333                       |
| NoSQL       | 6            | 73,333                       |
| PostgreSQL  | 2            | 70,000                       |
| Azure       | 2            | 68,750                       |
| SQL         | 40           | 68,618                       |
| Excel       | 18           | 68,504                       |
| Spring      | 2            | 68,000                       |
| Hadoop      | 2            | 66,250                       |
| Word        | 4            | 65,175                       |
| Python      | 28           | 64,528                       |
| R           | 13           | 64,508                       |
| Linux       | 2            | 63,750                       |
| SAS         | 2            | 60,000                       |
| Tableau     | 13           | 59,738                       |
| Power BI    | 7            | 59,443                       |
| Pandas      | 2            | 58,350                       |
| SQL Server  | 3            | 56,458                       |
| Looker      | 4            | 53,879                       |
| VBA         | 3            | 50,858                       |
| Alteryx     | 2            | 49,950                       |
| PowerPoint  | 3            | 49,400                       |

<br>

From both these result sets, we gather:
- **SQL** is the only skill that is both high demand and highly paid, as it is the most in-demand skill for Entry level roles, and also ranks in the top 5 in terms of pay.
- **Programming languages:** *MATLAB* is the second highest paid skill, but is limited to certain niche roles, such as legacy systems. Both *Python* and *R* are  in high demand, with average pay.
- **Excel is still very much relevant** as it is highly in demand, and it is also paid better than both *Python* and *R*.
- **Cloud skills, such as AWS and Azure** are the highly paid., niche role skills.
- **Database management systems:** *PostgreSQL* is paid much better than *SQL Server*, both are in equal demand, and *MySQL* did not make the list.
 
- **Visualization tools**: *Tableau* is more in-demand than *Power BI*, and both are paid similarly.

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
1. **Top paying Data Analyst jobs:** Both remote and on-site jobs are available, and there is a wide gap in the salaries offered, based on the location, with 50 percent jobs being located in the United States.
2. **Skills for top paying jobs:** SQL is the most sought-after skill in these jobs, followed by Excel and then Python. Some niche roles require cloud skills (e.g AWS) and data engineering / ETL skills (Spark) and are highly paid.
3. **Top in-demand skills:** Excel, SQL, Python and visualization tools (Tableau and Power BI) are the top 5 most in-demand skills.
4. **Top paying skills:** Both general cloud skills and specialized cloud data warehousing skills are highly paid. Jobs with additional data engineering skills are also highly paid, representing the need for learning how to execute end-to-end projects, from data sourcing to ETL to analytics.
5. **Most optimal skills:** *SQL* again emerges as the most essential skill, as it is the most in-demand and also ranks in the top 5 in terms of compensation.It should be combined with *Excel*, a programming languange like *Python* or *R*, a visualization tool (preferably *Tableau*) and a cloud platform, (preferably *AWS*) . 

### Closing thoughts:
In the world of Data Analytics, competition is fierce and if one aspires to enter this field, he / she should know exactly what to learn and how to position themselves so that they stand distinguished among the crowd. Learning high-impact, high paying skills is essential not only to land a job, but also to test whether this field will be a good fit for them or not. Learning a skill is only part of the problem, showcasing it is another thing and that's where projects come from. I, among many others, have done this project to showcase my skills, so that one day, I might get a job, but whether I get the job or not, even if one person lands a role in Data after seeing my work, I would consider this a big achievement on my part. 
