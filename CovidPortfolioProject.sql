SELECT *
FROM PortfolioProject.DBO.CovidDeaths
WHERE continent IS NOT NULL


--Select Data that we are going to be using
SELECT 
	continent,
	location,
	Date,
	Total_Cases,
	New_Cases,
	Total_Deaths,
	Population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY location, Date


-- Looking at the total cases vs Total Deaths in Kenya
---Shows likelihood of dying if you contract Covid in Kenya
SELECT 
	continent,
	Location,
	Date,
	Total_Cases,
	Total_Deaths,
	ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%Kenya%'
ORDER BY location, Date

---Looking at Total Cases vs Population
---Shows what percentage of population got Covid 
SELECT 
	continent,
	location,
	Date,
	population,
	Total_Cases,
	(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
---WHERE location LIKE '%Kenya%'
WHERE continent IS NOT NULL
ORDER BY location, Date


--Looking at Countries with highest infection Rate compared to population

SELECT 
	continent,
	Location,
	Population,
	MAX(Total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent, location, population
ORDER BY PercentPopulationInfected DESC


---LET'S BREAK THINGS DOWN BY CONTINENT

--Looking at Continents with highest DeathCount Per Population
SELECT 
	continent,
	MAX(cast(Total_Deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


---GLOBAL NUMBERS  

SELECT 
	---Date,
	SUM(New_Cases) AS Total_Cases,
	SUM(cast(New_Deaths AS int)) AS Total_Deaths,
	SUM(cast(New_Deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
---GROUP BY Date
--ORDER BY Date



--- Looking at Total Population vs Vaccinations

SELECT	
	DEA.continent,
	DEA.location,
	DEA.Date,
	DEA.population,
	VAC.new_vaccinations,
	SUM(cast(VAC.New_Vaccinations AS int)) OVER (Partition BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS DEA
JOIN PortfolioProject.dbo.CovidVaccinations AS VAC
	ON DEA.location = VAC.location 
		AND DEA.Date = VAC.Date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


---USE CTE 

WITH POP AS (
SELECT	
	DEA.continent,
	DEA.location,
	DEA.Date,
	DEA.population,
	VAC.new_vaccinations,
	SUM(cast(VAC.New_Vaccinations AS int)) OVER (Partition BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS DEA
JOIN PortfolioProject.dbo.CovidVaccinations AS VAC
	ON DEA.location = VAC.location 
		AND DEA.Date = VAC.Date
WHERE DEA.continent IS NOT NULL
)

SELECT *,
(RollingPeopleVaccinated/population)*100 AS PercentRollingPeopleVaccinated
FROM POP



---TEMP TABLE  

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT	
	DEA.continent,
	DEA.location,
	DEA.Date,
	DEA.population,
	VAC.new_vaccinations,
	SUM(cast(VAC.New_Vaccinations AS int)) OVER (Partition BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS DEA
JOIN PortfolioProject.dbo.CovidVaccinations AS VAC
	ON DEA.location = VAC.location 
		AND DEA.Date = VAC.Date
---WHERE DEA.continent IS NOT NULL


SELECT *,
(RollingPeopleVaccinated/population)*100 AS PercentRollingPeopleVaccinated
FROM #PercentPopulationVaccinated




--- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
SELECT	
	DEA.continent,
	DEA.location,
	DEA.Date,
	DEA.population,
	VAC.new_vaccinations,
	SUM(cast(VAC.New_Vaccinations AS int)) OVER (Partition BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS DEA
JOIN PortfolioProject.dbo.CovidVaccinations AS VAC
	ON DEA.location = VAC.location 
		AND DEA.Date = VAC.Date
WHERE DEA.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated











