/*
Observations from initial analysis:

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

-- Changes made as per Observations and saving them as main views
CREATE VIEW MainCovidDeath 
AS
SELECT continent, Location, CAST(date as date) as Date, Population, 
		Total_cases, New_cases, total_deaths, new_deaths, hosp_patients
FROM CovidDeaths
WHERE continent IS NOT NULL

CREATE VIEW MainCovidVaccine
AS
SELECT continent, Location, CAST(date as date) as Date, total_tests,
		new_tests, positive_rate, total_vaccinations, people_vaccinated
FROM CovidVaccines
WHERE continent IS NOT NULL

-- ----

-- Global cases (population vs infections)

SELECT location, date, population, total_cases, ROUND((total_cases/population), 4) as InfectionRate
FROM MainCovidDeath
ORDER BY 1,2;

-- Cases by continents and Cases by countries in descending order over time

SELECT Continent, Location as Country, date, total_cases, ROUND((total_cases/population), 4) as InfectionRate
FROM MainCovidDeath
ORDER BY 4 DESC

-- Deaths and DeathRate
CREATE VIEW Vis1CovidDeath
AS
SELECT Continent, Location as Country, cast(date as date) as Date, total_cases, total_deaths, 
		ROUND((total_cases/population), 4) as InfectionRate, ROUND((total_deaths/total_cases), 4) as DeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL
--ORDER BY 4 DESC

-- Deaths and DeathRate for the most recent date
CREATE VIEW Vis2CovidDeath
AS
SELECT Continent, Location as Country, date, total_cases, total_deaths, 
		ROUND((total_cases/population), 4) as InfectionRate, ROUND((total_deaths/total_cases), 4) as DeathRate
FROM MainCovidDeath
WHERE date = (SELECT max(date) FROM CovidDeaths)
-- ORDER BY 1 DESC


-- Global Cases
SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
		ROUND(SUM(New_Deaths)/SUM(new_cases), 4) as DeathPercentage
FROM MainCovidDeath
GROUP BY Date
ORDER BY date

-- Vaccination Rate by countries over time

SELECT MCD.Continent, MCD.Location, MCD.Date, Population, 
		people_vaccinated, ROUND(people_vaccinated/population, 4) as 'VaccinationRate'
FROM MainCovidDeath MCD
JOIN MainCovidVaccine MCV
ON MCD.location = MCV.location and MCD.Date = MCV.Date
WHERE total_vaccinations/population IS NOT NULL
ORDER BY location, Date DESC


-- Vaccination Rate by countries at the latest date

SELECT MCD.Continent, MCD.Location, MCD.Date, Population, 
		people_vaccinated, ROUND(people_vaccinated/population, 4) as 'VaccinationRate'
FROM MainCovidDeath MCD
JOIN MainCovidVaccine MCV
ON MCD.location = MCV.location and MCD.Date = MCV.Date
WHERE MCD.Date = (SELECT MAX(date) FROM MainCovidDeath)
ORDER BY location;

-- NULL Values observed above, so we will use new_people_vaccinated_smoothed column and roll up those values instead

-- Including new_people_vaccinated_smoothed column in our view

DROP VIEW IF EXISTS MainCovidVaccine
GO
CREATE VIEW MainCovidVaccine
AS
SELECT continent, Location, CAST(date as date) as Date, total_tests,
		new_tests, positive_rate, total_vaccinations, people_vaccinated, new_vaccinations_smoothed, new_vaccinations, new_people_vaccinated_smoothed
FROM CovidVaccines
WHERE continent IS NOT NULL;

-- Vaccination Rate by countries over time

DROP VIEW IF EXISTS Vis3CovidVacc
GO

CREATE VIEW Vis3CovidVacc
AS
SELECT MCD.Continent, MCD.Location, MCD.Date, Population, new_people_vaccinated_smoothed,
		SUM(new_people_vaccinated_smoothed) OVER (Partition by MCD.location order by MCD.date) as TotalVaccinations, 
		ROUND(SUM(new_people_vaccinated_smoothed) OVER (Partition by MCD.location order by MCD.date)/population, 4) as 'VaccinationRate'
FROM MainCovidDeath MCD
JOIN MainCovidVaccine MCV
ON MCD.location = MCV.location and MCD.Date = MCV.Date


ORDER BY location, date DESC;


-- Vaccination Rate by countries at the latest date

DROP VIEW IF EXISTS Vis4CovidVacc
GO

CREATE VIEW Vis4CovidVacc
AS
WITH VaccRate AS
(SELECT MCD.Continent, MCD.Location, MCD.Date, Population, new_people_vaccinated_smoothed,
		SUM(new_people_vaccinated_smoothed) OVER (Partition by MCD.location order by MCD.date) as TotalVaccinations
FROM MainCovidDeath MCD
JOIN MainCovidVaccine MCV
ON MCD.location = MCV.location and MCD.Date = MCV.Date
)

SELECT *, ROUND(TotalVaccinations/population, 4) as 'VaccinationRate'
FROM VaccRate
WHERE Date = (SELECT MAX(date) FROM MainCovidDeath)
ORDER BY location
