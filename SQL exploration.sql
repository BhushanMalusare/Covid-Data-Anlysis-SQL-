SELECT *
FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--SELECT THE DATA WE ARE GOING TO USE

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at total cases Vs Total deaths
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Cases_PER_Death
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Cases_PER_Death
FROM PortfolioProject..CovidDeaths
WHERE location='India'
ORDER BY 1,2

--Looking at total cases vs population
--Shows What percentage of population has gotten covid
SELECT location,date,total_cases,population,(total_cases/population)*100 AS Cases_PER_Population
FROM PortfolioProject..CovidDeaths
WHERE location='India'
ORDER BY 1,2

SELECT location,date,total_cases,population,(total_cases/population)*100 AS Cases_PER_Population
FROM PortfolioProject..CovidDeaths
--WHERE location='India'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) As Highest_Infection_Count, MAX((total_cases/population)*100) AS Cases_PER_Population
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY Cases_PER_Population DESC


--Showing Countries with highest deathcount per population

SELECT location,MAX(CAST(total_deaths AS int)) AS Totaldeathcount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Totaldeathcount DESC


--Lets break things down by continent

SELECT location,MAX(CAST(total_deaths AS int)) AS Totaldeathcount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Totaldeathcount DESC

--Showing continent with the highest death count


SELECT continent,MAX(CAST(total_deaths AS int)) AS Totaldeathcount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Totaldeathcount DESC



-- Global Numbers

SELECT date,SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS int)) AS TotalDeaths--total_deaths,(total_deaths/total_cases)*100 AS Cases_PER_Death
FROM PortfolioProject..CovidDeaths
--WHERE location='India'
 WHERE continent is not null
 GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location Order by dea.location,dea.Date) AS rolling_people_vaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location =vac.location
and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
( 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.Date) AS rolling_people_vaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location =vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TempTable

DROP Table if exists #percentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
Continent nvarchar(255)
,Location nvarchar(255)
,Date datetime,
Population numeric,
new_vaccinations numeric,RollingPeopleVaccinated numeric
)

INSERT INTO  #percentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.Date) AS rolling_people_vaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location =vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #percentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinateds AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.Date) AS rolling_people_vaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location =vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT * FROM PercentPopulationVaccinateds