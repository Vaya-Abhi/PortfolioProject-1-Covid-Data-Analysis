-- Viewing tables to ensure that they were imported correctly

SELECT *
FROM CovidPortfolio.dbo.CovidDeaths
ORDER BY 3,4

GO

SELECT *
FROM CovidPortfolio.dbo.CovidVaccines
ORDER BY 3,4;

-- Selecting data on CovidDeaths table that we will be using for analysis

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM CovidPortfolio.dbo.CovidDeaths
ORDER BY 1,2;

-- Total Cases VS Total Deaths (Death Rate)

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) as DeathRate
FROM CovidPortfolio.dbo.CovidDeaths
ORDER BY 1,2;

-- Total Cases VS Population (% of population that contracted COVID)

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 4) as InfectionRate
FROM CovidPortfolio.dbo.CovidDeaths
ORDER BY 1,2;

-- MAX Total Cases VS Population till date (% of population that contracted COVID)

SELECT Location, MAX(total_cases) as TotalCases, Population, MAX(ROUND((total_cases/population)*100, 4)) as InfectionRate
FROM CovidPortfolio.dbo.CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

-- MAX Death Count till date

SELECT Location, MAX(total_deaths) as TotalDeaths
FROM CovidPortfolio.dbo.CovidDeaths
GROUP BY location
ORDER BY 2 DESC;

/* After running the above script, it was observed that Location field 
had some values other than countries (continent value is also NULL). So, we will create a view to exlude those values.

World	6915273
High income	2866033
Upper middle income	2656109
Europe	2054189
Asia	1630017

 */

-- Create a view with filtered results by location

CREATE VIEW [dbo].[CovidDeathFilteredCountry]
AS
SELECT iso_code, continent, location, date, population, total_cases, new_cases, new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million, total_deaths_per_million, 
             new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate, icu_patients, icu_patients_per_million, hosp_patients, hosp_patients_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions, 
             weekly_hosp_admissions_per_million
FROM   dbo.CovidDeaths
WHERE continent IS NOT NULL
GO

-- Using the new view for previous script (MAX Death Count till date)


SELECT Location, MAX(total_deaths) as TotalDeaths
FROM CovidDeathFilteredCountry
GROUP BY location
ORDER BY 2 DESC;


-- Total Deaths by Continent

SELECT Continent, SUM(new_deaths) as TotalDeaths
FROM CovidDeathFilteredCountry
GROUP BY continent
ORDER BY 2 DESC

-- Global death rate (DeathPercentage)

SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
		SUM(New_Deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeathFilteredCountry
GROUP BY Date
ORDER BY date


