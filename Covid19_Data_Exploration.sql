-- Looking at Total Cases vs Total Deaths to see mortality percent
-- Shows likelihood of dying if you contract covid in your country, USA represented here

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as mortality_percent
FROM Cov19_Deaths_Vaccinations..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as infectivity_percent
FROM Cov19_Deaths_Vaccinations..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Country with Highest Infection Rate compared to population

SELECT location, MAX(total_cases) as Highest_Infection, population, (MAX(total_cases)/population)*100 as Percent_Population_Infected
FROM Cov19_Deaths_Vaccinations..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

-- Showing countries with Highest Death Count per Population
-- Need to CAST(total_deaths) as an integer because of an incorrect data type during import

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Cov19_Deaths_Vaccinations..CovidDeaths
WHERE continent IS NOT NULL -- need to add due to data, locations such as "income" or double counting such as ASIA and countries in ASIA
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Showing continents with the highest death count
SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Cov19_Deaths_Vaccinations..CovidDeaths
WHERE continent IS NULL and location not like '%income'
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Location by income

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Cov19_Deaths_Vaccinations..CovidDeaths
WHERE continent IS NULL and location like '%income'
GROUP BY location
ORDER BY Total_Death_Count DESC


-- Global Numbers exploration

SELECT date,
        sum(new_cases) as total_cases,
        SUM(cast(new_deaths as int)) as total_deaths,
        SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Cov19_Deaths_Vaccinations..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT sum(new_cases) as total_cases,
        SUM(cast(new_deaths as int)) as total_deaths,
        SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Cov19_Deaths_Vaccinations..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Joining Vaccination and Death tables

SELECT *
FROM Cov19_Deaths_Vaccinations..CovidDeaths dea
        JOIN Cov19_Deaths_Vaccinations..CovidVaccinations vac
        on dea.location = vac.location
        AND dea.date = vac.date

/* Looking at Total Population vs Vaccinations */

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Cov19_Deaths_Vaccinations..CovidDeaths dea
        JOIN Cov19_Deaths_Vaccinations..CovidVaccinations vac
                on dea.location = vac.location
                AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


SELECT dea.continent,
                dea.location,
                dea.date,
                dea.population,
                vac.new_vaccinations,
                SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPPLVax
FROM Cov19_Deaths_Vaccinations..CovidDeaths dea
        JOIN Cov19_Deaths_Vaccinations..CovidVaccinations vac
                on dea.location = vac.location
                AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3