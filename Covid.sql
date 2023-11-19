Select * From Learningproject..['CovidDeath'] 
WHERE continent IS NOT NULL
ORDER BY 3,4


Select * From Learningproject..['CovidVaccination'] 
ORDER BY 3,4

--Select Data will be using
Select location, date, total_cases, new_cases, total_deaths, population From Learningproject..['CovidDeath'] 
ORDER BY 1,2

--Looking at total_case vs total_deaht
Select location, date, total_cases, total_deaths, ((CONVERT(float,total_deaths)/CONVERT(float,total_cases,0)))*100 AS PCT_dthWcase From Learningproject..['CovidDeath'] 
WHERE location like '%Ne%'
ORDER BY 1,2

--Looking at total_case vs population
--Show percentage of total_case vs pupulation
Select location, date, total_cases, population, ((CONVERT(float,total_cases)/CONVERT(float,population,0)))*100 AS CasesPoplPRCT From Learningproject..['CovidDeath'] 
WHERE location like '%Viet%'
ORDER BY 1,2
--Country have highest infected rate vs population
Select location, population, MAX(CAST(total_cases AS INT)) AS HighestInflectionCount ,MAX((total_cases/population)*100) AS HighestCasesPoplPRCT 
From Learningproject..['CovidDeath'] 
GROUP BY location, population
ORDER BY HighestCasesPoplPRCT DESC

--Including continent
Select location, MAX(CONVERT(float,total_deaths)) AS TotalDeathsCount 
From Learningproject..['CovidDeath'] WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TOTALDeathsCount DESC

--Country with highest deaths count per population
Select location, population, MAX(CAST(total_deaths as INT)) AS HighestDeathsCount ,MAX((total_deaths/population)*100) AS HighestDeathsPoplPRCT 
From Learningproject..['CovidDeath'] WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathsCount DESC

--Showing contient with highest deaths count per population
Select location, MAX(CAST(total_deaths as INT)) AS HighestDeathsCount ,MAX((total_deaths/population)*100) AS HighestDeathsPoplPRCT 
From Learningproject..['CovidDeath'] WHERE (continent IS NOT NULL and Continent = 'North America')
GROUP BY location
ORDER BY HighestDeathsCount DESC

--Global Number of death rate per population for new cases
Select MAX(date), MAX(CAST(total_deaths AS INT)) AS GLOBAL_DEATHS, MAX((Cast(new_deaths as INT)/(CAST(population AS Float))*100)) AS PCT_dthWcase 
From Learningproject..['CovidDeath'] 
WHERE continent IS NOT NULL
ORDER BY 1,2
--Youbute intrustion
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_newDths, 
SUM(Cast(new_deaths as int))/SUM(NULLIF(new_cases,0)) *100 AS DeathPCT 
From Learningproject..['CovidDeath']
WHERE continent IS NOT NULL
ORDER BY 1,2

--JOIN - ON
-- Total population vs VAccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Learningproject..['CovidDeath'] dea
JOIN Learningproject..['CovidVaccination'] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY DATE, CAST(vac.new_vaccinations AS INT) DESC

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Total_newVAC,
From Learningproject..['CovidDeath'] dea
JOIN Learningproject..['CovidVaccination'] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTR 
WITH PopvsVac (continent, location, date, population, new_vaccinations, Total_newVAC)
AS (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Total_newVAC
--(Total_newVAC/population)
From Learningproject..['CovidDeath'] dea
JOIN Learningproject..['CovidVaccination'] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, Total_newVac/population*100 AS VAC_per_Person FROM PopvsVAc

--USE TEMP TABLE
DROP TABLE if exists PerPopVac 
CREATE TABLE PerPopVac
(
Continet NVARCHAR(225),
Location NVARCHAR(225),
DATE datetime,
Population numeric,
New_vaccinations numeric,
Total_newVAC numeric
)
INSERT INTO PerPopVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Total_newVAC
--(Total_newVAC/population)
From Learningproject..['CovidDeath'] dea
JOIN Learningproject..['CovidVaccination'] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, Total_newVac/population*100 AS VAC_per_Person FROM PerPopVac

-- Creating VIEW to store data for later visualizations

CREATE VIEW VAC_per_Person AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Total_newVAC
--(Total_newVAC/population)
From Learningproject..['CovidDeath'] dea
JOIN Learningproject..['CovidVaccination'] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
