-- Workforce Employment Analysis

-- Create database if not exists and use it
CREATE DATABASE IF NOT EXISTS WorkforceData;
USE WorkforceData;

-- Total rows and distinct areas
SELECT COUNT(*) AS total_records
FROM indianworkforce;

SELECT COUNT(DISTINCT area_name) AS distinct_areas
FROM indianworkforce;

-- Summary by Rural/Urban with ordering
SELECT total_rural_urban,
       SUM(total_population) AS total_population,
       SUM(total_main_workers) AS sum_main_workers,
       SUM(total_marginal_workers) AS sum_marginal_workers,
       SUM(total_non_workers) AS sum_non_workers
FROM indianworkforce
GROUP BY total_rural_urban
ORDER BY total_rural_urban;

-- Create or replace view with employment_rate and age_sort_order
CREATE OR REPLACE VIEW indianworkforce_enhanced AS
SELECT
    total_rural_urban,
    area_name,
    religious_community,
    age_group,
    total_population,
    total_main_workers,
    total_marginal_workers,
    total_non_workers,
    (total_main_workers + total_marginal_workers) AS total_workers,
    ROUND(
      (total_main_workers + total_marginal_workers) / NULLIF(total_population, 0)
      , 4) AS employment_rate,
    CASE age_group
        WHEN '5-9' THEN 1
        WHEN '10-14' THEN 2
        WHEN '15-19' THEN 3
        WHEN '20-24' THEN 4
        WHEN '25-29' THEN 5
        WHEN '30-34' THEN 6
        WHEN '35-39' THEN 7
        WHEN '40-49' THEN 8
        WHEN '50-59' THEN 9
        WHEN '60-69' THEN 10
        WHEN '70-79' THEN 11
        WHEN '80+' THEN 12
        WHEN 'Age not stated' THEN 13
        WHEN '15-59' THEN 14
        WHEN '60+' THEN 15
        WHEN 'Total' THEN 16
        ELSE 100
    END AS age_sort_order
FROM indianworkforce;

-- Employment rate by area name
SELECT area_name, ROUND(AVG(employment_rate) * 100, 2) AS avg_employment_rate_percent
FROM indianworkforce_enhanced
GROUP BY area_name
ORDER BY avg_employment_rate_percent DESC;

-- Employment rate by rural/urban classification
SELECT total_rural_urban, ROUND(AVG(employment_rate) * 100, 2) AS avg_employment_rate_percent
FROM indianworkforce_enhanced
GROUP BY total_rural_urban
ORDER BY total_rural_urban;

-- Employment rate by religious community
SELECT religious_community, ROUND(AVG(employment_rate) * 100, 2) AS avg_employment_rate_percent
FROM indianworkforce_enhanced
WHERE religious_community NOT IN ('All Religious Communities')
GROUP BY religious_community
ORDER BY avg_employment_rate_percent DESC;

-- Employment rate by age group
SELECT age_group, ROUND(AVG(employment_rate) * 100, 2) AS avg_employment_rate_percent
FROM indianworkforce_enhanced
WHERE age_group NOT IN ('15-59', '60+', 'Age not stated', 'Total')
GROUP BY age_group, age_sort_order
ORDER BY age_sort_order;
