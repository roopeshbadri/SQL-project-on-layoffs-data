-- Data Cleaning

SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data-spellings or smthng like that 
-- 3. Null values or blank values
-- 4. Remove any unnecessary columns

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- Removing Duplicates
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off ,`date`)
as row_num
FROM layoffs_staging where row_num>1;

WITH duplicate_cte as
(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off ,`date`,stage,country,funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT * from duplicate_cte
where row_num>1;

SELECT * FROM layoffs_staging 
WHERE company='Casper';

WITH duplicate_cte as
(
SELECT *, 
ROW_NUMBER() OVER
(PARTITION BY company,location,
industry,total_laid_off,percentage_laid_off ,`date`,
stage,country,funds_raised_millions) as row_num
FROM layoffs_staging
)
DELETE from duplicate_cte
where row_num>1;

DROP TABLE layoffs_staging_2;
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging_2
SELECT *, 
ROW_NUMBER() OVER
(
	PARTITION BY company,location,
    industry,total_laid_off,percentage_laid_off ,
    `date`,stage,country,funds_raised_millions) as row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging_2
where row_num>1;

DELETE from layoffs_staging_2
where row_num>1;

UPDATE layoffs_staging_2
set `date`=str_to_date(`date`,'%m/%d/%Y');

SELECT `date`
from layoffs_staging_2;

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

SELECT distinct industry from layoffs_staging_2 order by industry;

SELECT * from layoffs_staging_2
WHERE total_laid_off is null
AND percentage_laid_off is null;

SELECT *
from layoffs_staging_2
where company='Airbnb';

SELECT t1.industry,t2.industry
FROM layoffs_staging_2 t1
JOIN layoffs_staging_2 t2 
	ON t1.company=t2.company
    AND t1.location=t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging_2
SET industry=null where industry = '';

UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
ON t1.company=t2.company 
SET t1.industry=t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT distinct industry from layoffs_staging_2 order by 1;

SELECT * from layoffs_staging_2
WHERE total_laid_off is null
AND percentage_laid_off is null;

delete from layoffs_staging_2
WHERE total_laid_off is null
AND percentage_laid_off is null;

SELECT * from layoffs_staging_2;

ALTER TABLE layoffs_staging_2
DROP COLUMN row_num;


