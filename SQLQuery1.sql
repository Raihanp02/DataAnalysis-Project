SELECT * FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4;

--SELECT * FROM PortfolioProject.dbo.CovidVaccination
--WHERE continent is not NULL
--ORDER BY 3,4;





--Select the data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;





--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (cast(total_deaths AS FLOAT)/cast(total_cases AS FLOAT))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;





--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population, (cast(total_cases AS FLOAT)/cast(population AS FLOAT))*100 AS PercentPopulationInfection
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;





--looking at countries with Highest infection rate compared to population
SELECT location, MAX(CAST(total_cases AS FLOAT)) as HighestInfectionCount, population, (MAX(CAST(total_cases AS FLOAT))/CAST(population AS FLOAT))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;






--Showing countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Lets break things down by continent
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--other ways to break by continent
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;







--Showing continent with the highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;








--Global Numbers per Date
SELECT date, SUM(new_cases) AS Total_cases,SUM(new_deaths) AS Total_deaths, SUM(new_deaths)/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Global Numbers over all time
SELECT SUM(new_cases) AS Total_cases,SUM(new_deaths) AS Total_deaths, SUM(new_deaths)/sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;






--Joining table
SELECT * 
FROM PortfolioProject..CovidVaccination vac
JOIN PortfolioProject..CovidDeaths dea 
	ON dea.location = vac.location 
	AND dea.date = vac.date;





--looking at total population vs vaccination
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations 
FROM PortfolioProject..CovidVaccination vac
JOIN PortfolioProject..CovidDeaths dea 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3;







-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, cumulativevaccinations) AS
(
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations 
FROM PortfolioProject..CovidVaccination vac
JOIN PortfolioProject..CovidDeaths dea 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, cumulativevaccinations/population*100
FROM PopvsVac
ORDER BY 2,3







--TEMP table
DROP TABLE #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativevaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations 
FROM PortfolioProject..CovidVaccination vac
JOIN PortfolioProject..CovidDeaths dea 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL;

SELECT *, cumulativevaccinations/population*100
FROM #PercentPopulationVaccinated
ORDER BY 2,3






--Create view to store data for later visualization
DROP VIEW PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations 
FROM PortfolioProject..CovidVaccination vac
JOIN PortfolioProject..CovidDeaths dea 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL;




SELECT *
FROM PercentPopulationVaccinated



