select * from fec_ads;

-- Top states by Independent Political Ad Spending

select can_office_state, round(sum(expenditure_amount)) from fec_ads
where can_office_state IS NOT NULL
group by can_office_state
order by round(sum(expenditure_amount)) DESC
LIMIT 5;

-- How much a state spends on an expenditure on average

select can_office_state, round(avg(expenditure_amount)) from fec_ads
where can_office_state NOT LIKE '0'
group by can_office_state
order by round(avg(expenditure_amount)) DESC;

-- Total Spending Each Year

select report_year, sum(expenditure_amount) as total_spent from fec_ads
group by report_year
order by report_year;

-- Top 10 Spending Committees (Super PACs)

select sum(expenditure_amount), committee_name as total_spent from fec_ads
group by committee_name
order by sum(expenditure_amount) DESC
LIMIT 10;


-- Support vs Oppose Analysis
-- Are ads more negative (oppose) or positive (support)?

select support_oppose_indicator, sum(expenditure_amount) as total_spent from fec_ads
where support_oppose_indicator IN ('S', 'O')
group by support_oppose_indicator;

-- Which committees specialize in attack ads?

SELECT
    committee_name,
    SUM(CASE WHEN support_oppose_indicator = 'O' THEN expenditure_amount ELSE 0 END) AS oppose_spending,
    SUM(expenditure_amount) AS total_spending,
	ROUND(100.0 * SUM(CASE WHEN support_oppose_indicator = 'O' THEN expenditure_amount ELSE 0 END) / SUM(expenditure_amount),2) AS negative_ratio
FROM fec_ads
WHERE support_oppose_indicator IN ('S','O')
GROUP BY committee_name
ORDER BY oppose_spending DESC;

-- Top 10 Most Targeted Candidates

SELECT
    CASE 
        WHEN candidate_last_name ILIKE '%TRUMP%' THEN 'TRUMP'
        WHEN candidate_last_name ILIKE '%CLINTON%' THEN 'CLINTON'
        ELSE UPPER(candidate_last_name)
    END AS standardized_last_name,
    SUM(expenditure_amount) AS total_spent
FROM fec_ads
WHERE candidate_last_name IS NOT NULL
GROUP BY standardized_last_name
ORDER BY total_spent DESC
LIMIT 10;

-- Senate vs House vs President - Elections - Spending Comparison

SELECT
    CASE 
        WHEN candidate_office = 'S' THEN 'Senate'
        WHEN candidate_office = 'H' THEN 'House'
        WHEN candidate_office = 'P' THEN 'President'
        ELSE 'Other'
    END AS office_type,
    SUM(expenditure_amount) AS total_spent
FROM fec_ads
WHERE candidate_office IS NOT NULL
GROUP BY office_type
ORDER BY total_spent DESC;

-- Expenditure Types (Categorization Spending)

SELECT
    CASE
        WHEN expenditure_description IS NULL 
            OR TRIM(expenditure_description) = '' 
        THEN 'Other'

        WHEN UPPER(expenditure_description) LIKE '%MEDIA%'
          OR UPPER(expenditure_description) LIKE '%TV%'
          OR UPPER(expenditure_description) LIKE '%RADIO%'
          OR UPPER(expenditure_description) LIKE '%DIGITAL%'
          OR UPPER(expenditure_description) LIKE '%ONLINE%'
          OR UPPER(expenditure_description) LIKE '%SOCIAL%'
          OR UPPER(expenditure_description) LIKE '%TEXT%'
		  OR UPPER(expenditure_description) LIKE '%AD%'
		  OR UPPER(expenditure_description) LIKE '%ADVERTISING%'
        THEN 'Media & Digital Advertising'

		WHEN UPPER(expenditure_description) LIKE '%MAIL%'
		THEN 'Mail'

        WHEN UPPER(expenditure_description) LIKE '%FIELD%'
          OR UPPER(expenditure_description) LIKE '%CANVASS%'
          OR UPPER(expenditure_description) LIKE '%VOTER%'
        THEN 'Field Operations'

        WHEN UPPER(expenditure_description) LIKE '%CONSULT%'
          OR UPPER(expenditure_description) LIKE '%POLL%'
          OR UPPER(expenditure_description) LIKE '%RESEARCH%'
          OR UPPER(expenditure_description) LIKE '%DATA%'
        THEN 'Consulting & Research'

        ELSE 'Other'
    END AS expenditure_category,
    SUM(expenditure_amount) AS total_spent

FROM fec_ads
GROUP BY expenditure_category
ORDER BY total_spent DESC;