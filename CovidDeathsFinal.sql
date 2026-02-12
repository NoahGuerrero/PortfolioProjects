SELECT *
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3, 4

--Select Data that we are going to be using
SELECT country, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Look at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country
SELECT country, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 AS DeathPercentage
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE country LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at the Total Cases vs Population 
--Shows what percentage of population got COVID
Select country, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT country, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY country, Population, date
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT country, population, MAX(cast(total_deaths AS INT)) AS TotalDeathCount, MAX((total_deaths/population)*100) AS PercentPopulationDeaths
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent is not null
GROUP BY country, Population
ORDER BY TotalDeathCount DESC

--Showing Countries with Highest Death Count per Population
SELECT country, population, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NULL
GROUP BY country, population
ORDER BY TotalDeathCount DESC

--Verifying North America is adding all countries 
SELECT SUM(total_deaths) AS all_countries_total_deaths
FROM (
SELECT MAX(CAST(total_deaths AS INT)) AS total_deaths
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE country LIKE '%states%'
	OR country LIKE '%canada%'
	OR country LIKE '%mexico%'
	GROUP BY country
	)t;

-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing Continent with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS (Deaths)
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project - COVID19]..CovidDeaths$ dea
JOIN [Portfolio Project - COVID19]..CovidVaccinations$ vac
	ON dea.country = vac.country
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Looking at Total Population vs Vaccinations (Rolling Count)
-- Keeping the decimal place for the amount of New Vaccinations
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS DECIMAL(18,2))) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project - COVID19]..CovidDeaths$ dea
JOIN [Portfolio Project - COVID19]..CovidVaccinations$ vac
	ON dea.country = vac.country
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 DESC

-- Rounding up the amount of New Vaccinations (Removing NULLs)
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project - COVID19]..CovidDeaths$ dea
JOIN [Portfolio Project - COVID19]..CovidVaccinations$ vac
	ON dea.country = vac.country
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
Order By 2,3

-- Use CTE
WITH PopvsVac (Continent, Country, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project - COVID19]..CovidDeaths$ dea
JOIN [Portfolio Project - COVID19]..CovidVaccinations$ vac
	ON dea.country = vac.country
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingVaccinatedbyPopulation
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Country nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project - COVID19]..CovidDeaths$ dea
JOIN [Portfolio Project - COVID19]..CovidVaccinations$ vac
	ON dea.country = vac.country
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingVaccinatedbyPopulation
FROM #PercentPopulationVaccinated

--VIEWS FOR TABLEU VISUALIZATIONS for Covid Deaths (4 Views are saved in CovidVaccination)
--View #1: Global Covid Death Numbers
CREATE VIEW GlobalCovidDeaths AS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NOT NULL

--View #2: Total Infection by Country
CREATE VIEW TotalInfectionByCountry AS
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent

--View #3: Total Death Count per Continent
CREATE VIEW TotalDeathCountByContinent AS
SELECT continent, population, MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent

--View #4: Percent Population Infected
CREATE VIEW PrecentPopulationInfected AS
SELECT Country, Population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM [Portfolio Project - COVID19]..CovidDeaths$
WHERE Continent IS NOT NULL
GROUP BY Country, Population, date


--Optional Views:
--View #5: Total Population vs Vaccinations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project - COVID19]..CovidDeaths$ dea
JOIN [Portfolio Project - COVID19]..CovidVaccinations$ vac
	ON dea.country = vac.country
	AND dea.date = vac.date
Where dea.continent is not null
