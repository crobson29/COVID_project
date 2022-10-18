SELECT * FROM [COVID Project]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM [COVID Project]..CovidVaccinations
--ORDER BY 3,4

--Selecting the data that we will be looking at
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [COVID Project]..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract COVID in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [COVID Project]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got COVID
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM [COVID Project]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [COVID Project]..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with the highest death count per population
SELECT Location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM [COVID Project]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Break things down by continent

--Showing the continents with the highest death count per population
-- Make View
SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM [COVID Project]..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [COVID Project]..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [COVID Project]..CovidDeaths dea
JOIN [COVID Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [COVID Project]..CovidDeaths dea
JOIN [COVID Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [COVID Project]..CovidDeaths dea
JOIN [COVID Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [COVID Project]..CovidDeaths dea
JOIN [COVID Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating views for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [COVID Project]..CovidDeaths dea
JOIN [COVID Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

