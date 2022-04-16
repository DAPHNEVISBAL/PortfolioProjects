SELECT *
FROM Project1..CovidDeaths
--WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM Project1..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Showcases the likelihood of dying from COVID-19 in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Project1..CovidDeaths
WHERE location = 'Canada'AND continent IS NOT NULL
ORDER BY 1,2

--Looking at total cases vs population. What percentage of the population is infected.
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
FROM Project1..CovidDeaths
WHERE location = 'Canada'AND continent IS NOT NULL
ORDER BY 1,2

--Countries with the highest infection rates per their population
SELECT location, population, MAX(total_cases) as HighestInfecionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM Project1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRate DESC

--Countries with the highest mortality rate
SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population))*100 AS MortalityRate
FROM Project1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MortalityRate DESC

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM Project1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with the highest mortality rate
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM Project1..CovidDeaths
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathRate
FROM Project1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

------------------------------------------------------------------------------------------------------------------------------------
--Total amount of people vaccinated
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccionations, VaccinationsByTime) AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationsByTime
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3)
)
SELECT *, (VaccinationsByTime/population)*100 AS VaccinationPerPopulation
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentageOfVaccinatedPop
CREATE TABLE #PercentageOfVaccinatedPop
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccionations numeric, VaccinationsByTime numeric)
INSERT INTO #PercentageOfVaccinatedPop
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationsByTime
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3)
SELECT *, (VaccinationsByTime/population)*100 AS VaccinationPerPopulation
FROM #PercentageOfVaccinatedPop

--Creating view to store data
GO
CREATE VIEW RateOfVaccinatedPop
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationsByTime
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM RateOfVaccinatedPop