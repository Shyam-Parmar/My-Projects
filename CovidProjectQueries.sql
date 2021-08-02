/*

Date Dataset Was Latest Updated
07/20/2021

Date Analyzed 
07/22/2021

*/


-- Queries used for COVID-19 Data Analysis and Visualization done in Tableau


-- 1.
-- OVERALL GLOBAL NUMBERS
-- Population, cases, deaths, death%, vaccines, vaccine %
SELECT SUM(distinct dea.population) AS 'World Population', 
SUM(dea.new_cases) AS 'Cases', 
SUM(CAST(dea.new_deaths AS INT)) AS 'Deaths',
SUM(CAST(dea.new_deaths AS INT))/SUM(dea.new_cases)*100 AS 'Death %',
SUM(CONVERT(FLOAT, vac.new_vaccinations)) AS 'Vaccinations',
SUM(CAST(vac.new_vaccinations AS FLOAT))/SUM(distinct dea.population)*100 AS 'Vaccination %'
FROM CovidProject..CovidVaccinations vac
JOIN CovidProject..CovidDeaths dea
ON vac.location = dea.location 
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL


-- Double checking the data since the numbers are extremely close
-- The second one includes "International Locations"
-- SELECT SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths AS INT)) as 'Total Deaths', SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as 'Death Percentage'
-- FROM CovidProject..CovidDeaths
-- WHERE location = 'World'
-- ORDER BY 1,2


-- 2.
-- NUMBER OF CASES
-- Total Cases Per Continent
SELECT continent, location, date, Sum(new_cases) AS 'Cases'
FROM CovidProject..CovidDeaths
WHERE continent IS not NULL
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location, date, continent
ORDER BY 1,2

-- Getting the maximum number of cases for each country of a continent
SELECT continent, location, max(total_cases) as 'Cases'
FROM CovidProject..CovidDeaths
WHERE continent IS not NULL
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location, continent
ORDER BY 1,2

-- 3.
-- NUMBER OF DEATHS
-- Death Count Per Continent
SELECT continent, location, date, SUM(CAST(new_deaths AS INT)) as 'Total Death Count'
FROM CovidProject..CovidDeaths
WHERE continent IS not NULL
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location, date, continent
ORDER BY 'Total Death Count' DESC

-- 4. 
-- NUMBER OF VACCINES
-- Continents Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as 'Rolling People Vaccinated'
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- 5.
-- MAP
SELECT location, population, MAX(total_cases) AS 'Total Cases', MAX(ROUND((total_cases/ population)*100,2)) AS 'Case %'
FROM CovidProject..CovidDeaths
GROUP BY population, location
ORDER BY 'Case %' DESC

-- Queries Originally Written

-- 1.
-- CASES
-- Understanding the number of cases and population for each country and continent
-- Shows the number of cases received from each country overtime
SELECT location, date, total_cases, population, ROUND((total_cases/ population)*100,2) AS 'Cases %'
FROM CovidProject..CovidDeaths
ORDER BY 1,2

-- Shows countries with the total highest cases,
SELECT location, population, MAX(total_cases) AS 'Total Cases', MAX(ROUND((total_cases/ population)*100,2)) AS 'Case %'
FROM CovidProject..CovidDeaths
GROUP BY population, location
ORDER BY 'Case %' DESC

--2. 
-- DEATHS
-- Showing countries with Highest Death Count by population
SELECT location, population, MAX(CAST(total_deaths as int)) as 'Total Death Count'
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 'Total Death Count' DESC

-- 3.
-- CONTINENT
-- Showing continent with the Highest Death Count by population
-- This query shows the actual results
SELECT location, population, MAX(CAST(total_deaths as int)) as 'Total Death Count'
FROM CovidProject..CovidDeaths
WHERE continent is null
GROUP BY location, population
ORDER BY 'Total Death Count' DESC

-- Data is engineered a little different, continents where placed into the location column and therefore this query shows that
SELECT continent, MAX(CAST(total_deaths as int)) as 'Total Death Count'
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 'Total Death Count' DESC

-- 4.
-- GLOBAL NUMBERS
-- Cases, and Deaths each day
SELECT date, SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths AS INT)) as 'Total Deaths', ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100,2) as 'Death %'
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Population, cases, deaths, death%, vaccines, vaccine %
SELECT SUM(dea.population) AS 'Population', 
SUM(dea.new_cases) AS 'Cases', 
SUM(CAST(dea.new_deaths AS INT)) AS 'Deaths',
SUM(CAST(dea.new_deaths AS INT))/SUM(dea.new_cases)*100 AS 'Death %',
SUM(CONVERT(FLOAT, vac.new_vaccinations)) AS 'Population Vaccinated',
SUM(CAST(vac.new_vaccinations as float))/SUM(dea.population)*100 AS 'Vaccination %'
FROM CovidProject..CovidVaccinations vac
JOIN CovidProject..CovidDeaths dea
ON vac.location = dea.location 
AND vac.date = dea.date
WHERE dea.continent IS NOT NULL

-- 5.
-- Looking at Total Population vs Vaccinations each day
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as 'Rolling People Vaccinated'
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null	
ORDER BY 2,3

-- 6.
-- Using a CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 as 'Rolling Vaccination %'
FROM PopVsVac


-- 7.
-- Using a TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPoepleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 as 'Rolling Vaccination %'
FROM #PercentPopulationVaccinated


-- 8.
-- Creating Views to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
