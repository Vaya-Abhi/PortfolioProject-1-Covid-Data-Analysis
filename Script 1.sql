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
--WHERE Continent = 'North America'
GROUP BY location
ORDER BY 2 DESC;

/* After running the above script, it was observed that Location field 
had some values other than countries. So, we will create a view to exlude those values. */

SELECT Location, MAX(total_deaths) as TotalDeaths
FROM CovidDeathFilteredCountry
--WHERE Continent = 'North America'
GROUP BY location
ORDER BY 2 DESC;

-- Total Deaths by Continent

SELECT Continent, SUM(new_deaths) as TotalDeaths
FROM CovidDeathFilteredCountry
GROUP BY continent
ORDER BY 2 DESC

-- Global Cases
--SET ARITHABORT OFF;
--SET ANSI_WARNINGS OFF;
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
		SUM(New_Deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeathFilteredCountry
GROUP BY Date
ORDER BY date

-- ----- Vaccination Rate by countries over time

SELECT continent, location, date, population, people_vaccinated, ROUND(people_vaccinated/population*100, 2) as 'VaccinationRate'
FROM FilteredCombinedData
WHERE total_vaccinations/population IS NOT NULL
ORDER BY location, date DESC

/*
Observations from above analysis:

1. Location column consists values other than country that need to be removed (Continent value is NULL for such columns)
2. DateTime column needs to be converted to just the date as the time component isnt required

Potential views/stats required for visualizations:

1. Global cases
2. Cases by continents
3. Cases by countries in descending order
4. Global Vaccines
5. Vaccines by countries
6. Deaths by countries
7. Global deaths
8. Death, Infection, Vaccination rates

*/

-- Changes made as per Observations

SELECT continent, Location, CAST(date as date) as Date, Population, 
		Total_cases, New_cases, total_deaths, new_deaths, hosp_patients
FROM CovidDeaths
WHERE continent IS NOT NULL


SELECT continent, Location, CAST(date as date) as Date, total_tests,
		new_tests, positive_rate, total_vaccinations, people_vaccinated
FROM CovidVaccines
WHERE continent IS NOT NULL

-- ----

-- 1. Global cases (population vs infections)

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 4) as InfectionRate
FROM CovidPortfolio.dbo.CovidDeaths
ORDER BY 1,2;

