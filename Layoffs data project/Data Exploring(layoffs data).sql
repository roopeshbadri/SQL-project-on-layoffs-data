SELECT * From layoffs_staging_2;

SELECT MAX(total_laid_off), max(percentage_laid_off)
from layoffs_staging_2;

SELECT * FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company,sum(total_laid_off) From layoffs_staging_2
group by company
order by 2 desc;

SELECT min(`date`),max(`date`) From layoffs_staging_2;

SELECT country,sum(total_laid_off) From layoffs_staging_2
group by country
order by 2 desc;

SELECT YEAR(`date`),sum(total_laid_off) From layoffs_staging_2
group by YEAR(`date`);

SELECT stage,sum(total_laid_off) From layoffs_staging_2
group by stage
order by 2 desc;

-- rolling sum of total layoffs
SELECT substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging_2
where substring(`date`,1,7) is not null
group by `month`
order by 1;

WITH rolling_total AS
(
SELECT substring(`date`,1,7) as `month`, sum(total_laid_off) as total_laid_off
from layoffs_staging_2
where substring(`date`,1,7) is not null
group by `month`
order by 1
)
SELECT `month`, total_laid_off
,sum(total_laid_off) over(order by `month`) as rolling_total
from rolling_total; 

WITH company_per_year(company, years,total_laid_off) as
(
SELECT company,YEAR(`date`),sum(total_laid_off) as total_laid_off From layoffs_staging_2
group by company,YEAR(`date`)
order by 2 desc
), Company_year_rank as
(
SELECT *, dense_rank() OVER(partition by years order by total_laid_off desc) as rank_layoffs
from company_per_year
where years is not null
)
SELECT * from company_year_rank
where rank_layoffs<=5;

