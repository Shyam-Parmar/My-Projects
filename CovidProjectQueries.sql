/*

Date Dataset Was Latest Updated
07/20/2021

Date Analyzed 
07/22/2021

*/


-- Queries used for COVID-19 Data Analysis and Visualization done in Tableau


-- 1.
-- Overall Global Numbers
-- Total cases, deaths, and death percentage globally
SELECT SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths AS INT)) as 'Total Deaths', SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as 'Death Percentage'
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Double checking the data since the numbers are extremely close
-- The second one includes "International Locations"

--SELECT SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths AS INT)) as 'Total Deaths', SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as 'Death Percentage'
--FROM CovidProject..CovidDeaths
--WHERE location = 'World'
--ORDER BY 1,2



-- 2.
-- Taking these out as they are not included in the above queries
-- European Union is part of Europe
SELECT location, SUM(CAST(new_deaths AS INT)) as 'Total Death Count'
FROM CovidProject..CovidDeaths
WHERE continent is null
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY 'Total Death Count' DESC



-- 3.
-- Looking at countries with the Highest Cases by Population
SELECT location, population, MAX(total_cases) as 'Total Cases', MAX(ROUND((total_cases/ population)*100,2)) as 'Case Percentage'
FROM CovidProject..CovidDeaths
GROUP BY population, location
ORDER BY 'Case Percentage' DESC



-- 4.
-- Same query as number 3, this one however includes the Date
SELECT location, population, date, MAX(total_cases) as 'Total Cases', MAX(ROUND((total_cases/ population)*100,2)) as 'Case Percentage'
FROM CovidProject..CovidDeaths
GROUP BY population, location, date
ORDER BY 'Case Percentage' DESC



-- Queries originally written

-- 1.
-- Looking at Total Cases vs Total Deaths
-- Shows the percentage of Deaths from COVID
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases)*100,2) as 'Death %'
FROM CovidProject..CovidDeaths
ORDER BY 1,2


-- 2.
-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT location, date, total_cases, population, ROUND((total_cases/ population)*100,2) as 'Cases %'
FROM CovidProject..CovidDeaths
ORDER BY 1,2


-- 3.
-- Looking at countries with the Highest Cases by Population
SELECT location, population, MAX(total_cases) as 'Total Cases', MAX(ROUND((total_cases/ population)*100,2)) as 'Case Percentage'
FROM CovidProject..CovidDeaths
GROUP BY population, location
ORDER BY 'Case Percentage' DESC


-- 4.
-- Showing countries with Highest Death Count by population
SELECT location, population, MAX(CAST(total_deaths as int)) as 'Total Death Count'
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 'Total Death Count' DESC


-- 5.
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


-- 6.
-- GLOBAL NUMBERS
-- Included with date
SELECT date, SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths AS INT)) as 'Total Deaths', ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100,2) as 'Death %'
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Same query as above, just removed the Date
-- Overall global numbers
SELECT SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths AS INT)) as 'Total Deaths', ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100,2) as 'Death %'
FROM CovidProject..CovidDeaths
WHERE continent is not null

-- 7.
-- Vaccinations
-- Looking at the countries that have the Highest Vaccinations
SELECT location, MAX(CAST(new_vaccinations as int)) as 'Total Vaccines'
FROM CovidProject..CovidVaccinations
WHERE continent is not null
GROUP BY location
ORDER BY 'Total Vaccines' DESC

-- 8.
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as 'Rolling People Vaccinated'
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null	
ORDER BY 2,3


-- 9.
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


-- 10.
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


-- 11.
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
