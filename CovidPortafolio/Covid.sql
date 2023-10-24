Use Covid
Select *
From Covid..covidDeaths
order by 3,4

--Select *
--From Covid..covidVaccinations
--order by 3,4

-- Select Data that we are going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From Covid..covidDeaths
order by 1,2

-- looking at total cases vs total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid..covidDeaths
order by 1,2;

-- Change the data type of total_cases to int (FLOAT)
ALTER TABLE Covid..covidDeaths
ALTER COLUMN total_cases FLOAT;

-- Change the data type of total_deaths to int (FLOAT)
ALTER TABLE Covid..covidDeaths
ALTER COLUMN total_deaths FLOAT;

-- Cases in Colombia
SELECT 
	Location, 
	date, 
	total_cases, 
	total_deaths, ROUND(((total_deaths/total_cases)*100),3) as DeathPercentage
FROM Covid..covidDeaths
Where Location = 'Colombia'
ORDER BY 1, 2;

-- Total cases vs population
SELECT 
	Location, 
	date, 
	total_cases, 
	Population, 
	ROUND(((total_cases/ population)*100),3) as Death_P_Polutation
FROM Covid..covidDeaths
Where continent is not Null
ORDER BY 1, 2;


-- Contries with the highest infection rate, using the population
SELECT 
	Location,
	MAX(total_cases) as Highest_Infection, 
	Population, 
	ROUND((MAX((total_cases/ population)*100)),3) as Percent_Polutation_infected
FROM Covid..covidDeaths
Where continent is not Null
Group by Location, Population
ORDER BY Percent_Polutation_infected desc;

-- Countries with the highest death count per population

SELECT Location,MAX(total_deaths) as Total_Deaths
FROM Covid..covidDeaths
Where continent is not Null
Group by Location
ORDER BY Total_Deaths desc;

--by continent

-- Countries with the highest death count per population

SELECT 
	location,
	MAX(total_deaths) as Total_Deaths
FROM Covid..covidDeaths
WHERE continent is Null and location != 'High income' and location != 'Upper middle income'
	and location != 'Lower middle income'and location != 'Low income'
GROUP BY location
ORDER BY Total_Deaths desc;


--Global Numbers

SELECT
    date,
    SUM(new_cases) as Total_Cases,
    SUM(new_deaths) as Total_Deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0  -- Avoid division by zero
        ELSE ROUND(((SUM(new_deaths) / SUM(new_cases)) * 100), 3)
    END as DeathPercentageWorld
FROM Covid..covidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total population vs total Vaccinations
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
	Continent varChar(255),
	Location varChar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinnated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) as Rolling_Vaccination
	--(Rolling_Vaccination/population)*100
FROM Covid..covidDeaths dea
JOIN Covid..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date= vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinnated/Population)*100
FROM #PercentPopulationVaccinated
--WHERE Location='Colombia'
ORDER BY 2,3


--Creating view for data visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT
    date,
    SUM(new_cases) as Total_Cases,
    SUM(new_deaths) as Total_Deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0  -- Avoid division by zero
        ELSE ROUND(((SUM(new_deaths) / SUM(new_cases)) * 100), 3)
    END as DeathPercentageWorld
FROM Covid..covidDeaths
WHERE continent IS NOT NULL
GROUP BY date
