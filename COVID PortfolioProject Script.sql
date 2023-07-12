SELECT * 
FROM SQLDataExplorationPortfolioProject1..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM SQLDataExplorationPortfolioProject1..CovidVaccinations
--ORDER BY 3,4


SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM SQLDataExplorationPortfolioProject1..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)
FROM SQLDataExplorationPortfolioProject1..CovidDeaths
WHERE total_cases IS NOT NULL
  AND total_deaths IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs. Population
SELECT Location, Date, Total_Cases, Population, (Total_Cases/Population)*100 AS PercentPopulationInfected
FROM SQLDataExplorationPortfolioProject1..CovidDeaths
--WHERE Location like '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(Total_Cases) AS HighestInfectionCount, MAX((Total_Cases/Population))*100 AS PercentPopulationInfected
FROM SQLDataExplorationPortfolioProject1..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(Total_Deaths AS BIGINT)) AS TotalDeathCount
FROM SQLDataExplorationPortfolioProject1..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

SELECT Location, MAX(CAST(Total_Deaths AS BIGINT)) AS TotalDeathCount
FROM SQLDataExplorationPortfolioProject1..CovidDeaths
WHERE Continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Breaking things down by continent
--Showing continents with the Highest Death Count Per Population
SELECT Continent, MAX(CAST(Total_Deaths AS BIGINT)) AS TotalDeathCount
FROM SQLDataExplorationPortfolioProject1..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC



--Total Population vs. Vaccination
SELECT Death.Continent, Death.Location, Death.Date, Death.Population, Vacc.New_Vaccinations,
   SUM(CONVERT(BIGINT, Vacc.New_Vaccinations)) OVER (PARTITION BY Death.Location ORDER BY Death.Location, Death.Date) AS RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/Population)*100
FROM SQLDataExplorationPortfolioProject1..CovidDeaths AS Death
JOIN SQLDataExplorationPortfolioProject1..CovidVaccinations As Vacc
	ON Death.Location = Vacc.Location
	AND Death.Date = Vacc.Date
WHERE Death.Continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
With PopVsVacc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Death.Continent, Death.Location, Death.Date, Death.Population, Vacc.New_Vaccinations,
   SUM(CONVERT(BIGINT, Vacc.New_Vaccinations)) OVER (PARTITION BY Death.Location ORDER BY Death.Location, Death.Date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM SQLDataExplorationPortfolioProject1..CovidDeaths AS Death
JOIN SQLDataExplorationPortfolioProject1..CovidVaccinations As Vacc
	ON Death.Location = Vacc.Location
	AND Death.Date = Vacc.Date
WHERE Death.Continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVacc




--Temp Table
DROP TABLE IF EXISTS #PercentPopVacc
CREATE TABLE #PercentPopVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopVacc
SELECT Death.Continent, Death.Location, Death.Date, Death.Population, Vacc.New_Vaccinations,
   SUM(CONVERT(BIGINT, Vacc.New_Vaccinations)) OVER (PARTITION BY Death.Location ORDER BY Death.Location, Death.Date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM SQLDataExplorationPortfolioProject1..CovidDeaths AS Death
JOIN SQLDataExplorationPortfolioProject1..CovidVaccinations As Vacc
	ON Death.Location = Vacc.Location
	AND Death.Date = Vacc.Date
WHERE Death.Continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopVacc



--Creating View to store data for later visualizations
CREATE VIEW PercentPopVaccinated AS
SELECT Death.Continent, Death.Location, Death.Date, Death.Population, Vacc.New_Vaccinations,
   SUM(CONVERT(BIGINT, Vacc.New_Vaccinations)) OVER (PARTITION BY Death.Location ORDER BY Death.Location, Death.Date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM SQLDataExplorationPortfolioProject1..CovidDeaths AS Death
JOIN SQLDataExplorationPortfolioProject1..CovidVaccinations As Vacc
	ON Death.Location = Vacc.Location
	AND Death.Date = Vacc.Date
WHERE Death.Continent IS NOT NULL
