SELECT *
FROM [Portfolio Project - COVID19]..CovidVaccinations$
WHERE continent IS NOT NULL
ORDER BY 3, 4

--Select Data that we are going to be using
SELECT country, date, total_vaccinations, new_vaccinations, total_tests
FROM [Portfolio Project - COVID19]..CovidVaccinations$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Look at Total Vaccinations vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country
SELECT country, date, total_vaccinations, new_vaccinations, NULLIF(((CAST(total_tests AS INT)/CAST(total_vaccinations AS INT)))*100,0) AS DeathPercentage
FROM [Portfolio Project - COVID19]..CovidVaccinations$
WHERE country LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at the Total Vaccinations vs Population 
--Shows what percentage of population got a Vaccination
SELECT vac.continent, vac.country, vac.date, (MAX(CAST(vac.people_fully_vaccinated AS FLOAT))/dea.population)*100 AS PercentPopulationInfected
FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
	ON vac.country = dea.country
	AND vac.date = dea.date
WHERE vac.people_fully_vaccinated IS NOT NULL
GROUP BY vac.continent, vac.country, vac.date, dea.population
ORDER BY 1,2;


--COUNTRY Numbers
--Looking at Fully Vaccinated Count by Country
SELECT vac.Country, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS RollingFullyVacsTotal,
    MAX(dea.population) AS Total_Population
FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
    ON vac.country = dea.country
   AND vac.date = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.Country;

--Looking at Fully Vaccinated Percentage by Country
SELECT Country, RollingFullyVacsTotal, Total_Population, (RollingFullyVacsTotal/Total_Population)* 100 AS PercentPopulationVaccinated
FROM (
    SELECT vac.country AS Country, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS RollingFullyVacsTotal,
        MAX(dea.population) AS Total_Population
    FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
    JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
        ON vac.country = dea.country
       AND vac.date = dea.date
    WHERE vac.continent IS NOT NULL
    GROUP BY vac.country
) t;

--GLOBAL NUMBERS (Fully Vaccinated)
SELECT SUM(rolling_fully_vacs_total) AS RollingFullyVacsTotal, SUM(total_pop) AS Total_Population
, (SUM(rolling_fully_vacs_total) / SUM(total_pop)) * 100 AS VacPercentage
FROM (
	SELECT
		vac.continent, MAX(CAST(vac.total_vaccinations AS DECIMAL(20,2))) AS total_vacs, MAX(dea.population) AS total_pop
		, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS rolling_fully_vacs_total
	FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
	JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
		ON vac.country = dea.country
		AND vac.date = dea.date
	WHERE vac.continent IS NOT NULL
	GROUP BY vac.continent
	
) t;

--Looking at Fully Vaccinated Count by Continent
SELECT Continent, SUM(rolling_fully_vacs_total) AS RollingFullyVacsTotal, SUM(total_pop) AS Total_Population
FROM (
	SELECT
		vac.continent, MAX(CAST(vac.total_vaccinations AS DECIMAL(20,2))) AS total_vacs, MAX(dea.population) AS total_pop
		, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS rolling_fully_vacs_total
	FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
	JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
		ON vac.country = dea.country
		AND vac.date = dea.date
	WHERE vac.continent IS NOT NULL
	GROUP BY vac.continent
	
) t
GROUP BY Continent
ORDER BY Continent;

--Looking at Fully Vaccinated Percentages by Continent
SELECT Continent, SUM(rolling_fully_vacs_total) AS RollingFullyVacsTotal, SUM(total_pop) AS Total_Population
, (SUM(rolling_fully_vacs_total) / SUM(total_pop)) * 100 AS VacPercentage
FROM (
	SELECT
		vac.continent, MAX(CAST(vac.total_vaccinations AS DECIMAL(20,2))) AS total_vacs, MAX(dea.population) AS total_pop
		, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS rolling_fully_vacs_total
	FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
	JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
		ON vac.country = dea.country
		AND vac.date = dea.date
	WHERE vac.continent IS NOT NULL
	GROUP BY vac.continent
	
) t
GROUP BY Continent
ORDER BY Continent;

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project - COVID19]..CovidDeaths$ dea
Join [Portfolio Project - COVID19]..CovidVaccinations$ vac
	On dea.country = vac.country
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- Looking at Total Population vs Vaccinations (Rolling Count)
SELECT dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS decimal(18,2))) OVER (PARTITION BY dea.country ORDER BY dea.country, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
	ON dea.country = vac.country
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 DESC

-- Looking at Percent of Population Vaccinated
SELECT vac.country, vac.date, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS RollingFullyVacsTotal,
	MAX(CAST(dea.population AS DECIMAL(22,2))) AS Total_Population, 
	MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))/dea.population)*100 AS PercentPopulationVaccinated
FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
    ON vac.country = dea.country
   AND vac.date = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.country, vac.date;

--Creating Views to store data for later visualizations (4 Views are saved in CovidDeaths)
--View #1: Global Fully Vaccinated Numbers
CREATE VIEW GlobalFullyVaccinated AS
SELECT SUM(rolling_fully_vacs_total) AS RollingFullyVacsTotal, SUM(total_pop) AS Total_Population
, (SUM(rolling_fully_vacs_total) / SUM(total_pop)) * 100 AS VacPercentage
FROM (
	SELECT
		vac.continent, MAX(CAST(vac.total_vaccinations AS DECIMAL(20,2))) AS total_vacs, MAX(dea.population) AS total_pop
		, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS rolling_fully_vacs_total
	FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
	JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
		ON vac.country = dea.country
		AND vac.date = dea.date
	WHERE vac.continent IS NOT NULL
	GROUP BY vac.continent
	
) t;


--View #2: Total Fully Vaccinated Count per Continent
CREATE VIEW TotalFullyVaccinatedContinentCount AS
SELECT vac.Continent, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS RollingFullyVacsTotal,
    MAX(dea.population) AS Total_Population
FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
    ON vac.country = dea.country
   AND vac.date = dea.date
WHERE vac.Continent IS NOT NULL
GROUP BY vac.Continent;

--View #3: Total Fully Vaccinated by Country
CREATE VIEW TotalFullyVaccinatedByCountry AS
SELECT Country, RollingFullyVacsTotal, Total_Population, (RollingFullyVacsTotal/Total_Population)* 100 AS PercentPopulationVaccinated
FROM (
    SELECT vac.country AS Country, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS RollingFullyVacsTotal,
        MAX(dea.population) AS Total_Population
    FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
    JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
        ON vac.country = dea.country
       AND vac.date = dea.date
    WHERE vac.continent IS NOT NULL
    GROUP BY vac.country,
) t;

--View #4: Percent Population Vaccinated
CREATE VIEW PopulationVaccinatedPercentage AS
SELECT vac.country, vac.date, MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS RollingFullyVacsTotal,
	MAX(CAST(dea.population AS DECIMAL(22,2))) AS Total_Population, 
	MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))/dea.population)*100 AS PercentPopulationVaccinated
FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
    ON vac.country = dea.country
   AND vac.date = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.country, vac.date;

-- round 2
SELECT 
    vac.country, vac.date, CAST(dea.population AS DECIMAL(22,2)) AS Population,
    MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2))) AS FullyVaccinated,
    MAX(CAST(vac.people_fully_vaccinated AS DECIMAL(22,2)))/CAST(dea.population AS DECIMAL(22,2))*100 
        AS PercentPopulationVaccinated
FROM [Portfolio Project - COVID19]..CovidVaccinations$ vac
JOIN [Portfolio Project - COVID19]..CovidDeaths$ dea
    ON vac.country = dea.country
   AND vac.date = dea.date
WHERE vac.continent IS NOT NULL
GROUP BY vac.country, Population, vac.date;
